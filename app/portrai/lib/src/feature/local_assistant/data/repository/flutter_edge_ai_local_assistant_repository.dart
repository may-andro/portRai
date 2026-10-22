import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/data/cache/_cache.dart';
import 'package:portrai/src/feature/local_assistant/data/repository/local_assistant_context_selector.dart';
import 'package:portrai/src/feature/local_assistant/data/repository/local_assistant_direct_answerer.dart';
import 'package:portrai/src/feature/local_assistant/domain/exception/_exception.dart';
import 'package:portrai/src/feature/local_assistant/domain/feature_flag/_feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/domain/repository/_repository.dart';

@RegisterSingleton(as: LocalAssistantRepository, disposeMethodName: 'dispose')
class FlutterEdgeAiLocalAssistantRepository
    implements LocalAssistantRepository {
  FlutterEdgeAiLocalAssistantRepository(
    this._enabledCache, {
    required IsFeatureEnabledUseCase this._isFeatureEnabled,
  });

  @visibleForTesting
  FlutterEdgeAiLocalAssistantRepository.withModelLoader(
    this._modelLoader, {
    LocalAssistantEnabledCache? enabledCache,
    this._isFeatureEnabled,
  }) : _enabledCache = enabledCache ?? LocalAssistantEnabledCache();

  final LocalAssistantEnabledCache _enabledCache;
  final IsFeatureEnabledUseCase? _isFeatureEnabled;
  int _generation = 0;
  bool _requestActive = false;
  bool _disabled = false;
  int _preferenceRevision = 0;
  Future<void> _preferenceMutation = Future.value();

  Future<void> _ensureFeatureEnabled() async {
    final flag = await _isFeatureEnabled?.call(
      LocalAssistantFeatureFlags.aiAssistant,
    );
    if (flag != null && flag.isLeft) throw const LocalAssistantFlagException();
    if (flag != null && !flag.right) {
      throw const LocalAssistantUnavailableException();
    }
  }

  void _ensureCurrent(int generation) {
    if (generation != _generation || _disabled) {
      throw const LocalAssistantCancelledException();
    }
  }

  // Gemma 4's chat template accepts the structured message content that
  // flutter_edge_ai sends. The Qwen3 1.7B/4B exports only accept plain string
  // content, so the native runtime fails to apply their template.
  static const _modelRepository = 'litert-community/gemma-4-E2B-it-litert-lm';
  static const _modelRevision = 'b3ca0d2f076785a8f4b2219ddbd2bdb99954eae1';
  static const _maxTokens = 8192;
  static const _modelFile = 'gemma-4-E2B-it.litertlm';
  // The owner's name comes from the portfolio, so the instruction follows the
  // data instead of repeating it.
  static String _systemInstruction(String name) =>
      "You are the Q&A assistant for $name's professional portfolio. "
      'You are not a general-purpose chatbot. Answer questions only about '
      '$name, their contact details, background, experience, projects, '
      'skills, services, and availability, using only the portfolio '
      "information below. If asked who to contact, give $name's name and "
      'the contact details provided. Greet only when the message is nothing '
      'but a greeting; otherwise answer the question directly. For unrelated '
      "questions, politely say you can only help with $name's portfolio. "
      'For questions about $name that the portfolio does not cover, such as '
      'salary, age, visa or hobbies, say that this is not in the portfolio '
      'and do not guess. For questions about a year, period, order, country, '
      'remote or freelance work, years with a technology, career gaps, '
      'leadership, spoken languages, longest or shortest, use the overview '
      'lines and copy their numbers. Spoken languages come only from the '
      'spoken languages line, never from country names. Answer a follow-up for what it asks, not like the '
      'previous question. When asked for a link, copy the URL exactly as '
      'written, and if it says "not found" say that no such link was found. '
      'Keep answers direct and concise. Write plain sentences: no markdown, '
      'no bullet symbols, and never mention field names, paths or brackets '
      'such as experiences[0].';

  Future<void>? _initialization;
  Future<void>? _preparation;
  Future<InferenceModel> Function(void Function(int))? _modelLoader;
  InferenceModel? _model;
  InferenceChat? _chat;
  String? _previousQuestion;
  CancelToken? _cancelToken;
  // The last decoded portfolio context and its source. Questions about the
  // same portfolio reuse it instead of decoding the JSON again.
  String? _decodedPortfolioSource;
  Map<String, dynamic>? _decodedPortfolio;

  @override
  Future<bool> isEnabled() async => await _enabledCache.get() ?? false;

  @override
  Future<void> setEnabled({required bool enabled}) async {
    final revision = ++_preferenceRevision;
    if (!enabled) {
      _disabled = true;
      _generation++;
    }
    final previous = _preferenceMutation;
    final completion = Completer<void>();
    _preferenceMutation = completion.future;
    await previous;
    try {
      if (enabled) await _ensureFeatureEnabled();
      final saved = await _enabledCache.put(enabled);
      if (!saved) throw const LocalAssistantPreferenceException();
      if (enabled && revision == _preferenceRevision) _disabled = false;
    } finally {
      completion.complete();
      if (!enabled) await _unloadModel();
    }
  }

  @override
  Future<bool> isModelDownloaded() async {
    await _initialize();
    return await FlutterEdgeAi.isModelInstalled(_modelFile);
  }

  @override
  Future<void> prepareModel({required void Function(int) onProgress}) async {
    await _ensureFeatureEnabled();
    if (_model != null) return;
    await (_preparation ??= _prepareModel(onProgress));
  }

  Future<InferenceModel> _loadModel(void Function(int) onProgress) async {
    await _initialize();
    final cancelToken = _cancelToken = CancelToken();
    await FlutterEdgeAi.installModel(
          modelType: ModelType.gemma4,
          fileType: ModelFileType.litertlm,
        )
        .fromHuggingFace(
          _modelRepository,
          file: _modelFile,
          revision: _modelRevision,
        )
        .withProgress(onProgress)
        .withCancelToken(cancelToken)
        .install();
    onProgress(100);

    return await FlutterEdgeAi.getActiveModel(
      maxTokens: _maxTokens,
      preferredBackend: PreferredBackend.gpu,
    );
  }

  Future<void> _prepareModel(void Function(int) onProgress) async {
    final generation = _generation;
    InferenceModel? candidate;
    InferenceChat? probe;
    try {
      candidate = await (_modelLoader ?? _loadModel)(onProgress);
      // Web loads its engine lazily. A real generation must succeed before
      // the portfolio advertises that the assistant is ready.
      probe = await candidate.createChat(temperature: 0.2, maxOutputTokens: 16);
      await probe.addQueryChunk(
        const Message(text: 'Reply with the word Ready.', isUser: true),
      );
      final response = await probe.generateChatResponse();
      if (response is! TextResponse || response.token.trim().isEmpty) {
        throw StateError('The model readiness check returned no text.');
      }
      await probe.close();
      probe = null;
      _ensureCurrent(generation);
      _model = candidate;
    } finally {
      try {
        await probe?.close();
      } finally {
        if (candidate != null && !identical(candidate, _model)) {
          await candidate.close();
        }
        _preparation = null;
      }
    }
  }

  @override
  Future<String> answer({
    required String question,
    required String portfolioContext,
  }) async {
    if (_requestActive) throw const LocalAssistantBusyException();
    _requestActive = true;
    final generation = _generation;
    try {
      await _ensureFeatureEnabled();
      if (_isFeatureEnabled != null && !await isEnabled()) {
        throw const LocalAssistantUnavailableException();
      }
      _ensureCurrent(generation);
      final answer = await _answer(
        question: question,
        portfolioContext: portfolioContext,
        generation: generation,
      );
      _ensureCurrent(generation);
      _previousQuestion = question;
      return answer;
    } finally {
      _requestActive = false;
    }
  }

  Future<String> _answer({
    required String question,
    required String portfolioContext,
    required int generation,
  }) async {
    final portfolio = _decodePortfolio(portfolioContext);
    if (portfolio == null) {
      throw const FormatException(
        'Assistant context must be a portfolio object.',
      );
    }
    // Facts the app already computed are answered without waiting for the
    // engine, which is loaded on the first question that needs it.
    final answerer = LocalAssistantDirectAnswerer(portfolio);
    final previous = _previousQuestion;
    final direct =
        answerer.answer(question) ??
        (previous == null
            ? null
            : answerer.answerFollowUp(question, previousQuestion: previous));
    if (direct != null) {
      return direct;
    }

    await prepareModel(onProgress: (_) {});
    _ensureCurrent(generation);
    final model = _model;
    if (model == null) {
      throw StateError('The on-device model could not be loaded.');
    }

    // A standalone question must not see the previous one: the small model
    // tends to answer that instead.
    final previousQuestion =
        LocalAssistantContextSelector.isFollowUp(portfolio, question)
        ? _previousQuestion
        : null;
    // UTF-8 bytes conservatively bound token count. Reserve room for the
    // answer and chat-template tokens rather than silently truncating input.
    // English text averages about 3 bytes per token or more.
    final profileName = (portfolio['profile'] as Map?)?['name'];
    final systemInstruction = _systemInstruction(
      profileName is String && profileName.trim().isNotEmpty
          ? profileName.trim()
          : 'the portfolio owner',
    );
    final availableBytes =
        (_maxTokens - 1024) * 2 -
        utf8
            .encode('$systemInstruction$question${previousQuestion ?? ''}')
            .length;
    if (availableBytes < 512) {
      throw ArgumentError.value(question, 'question', 'Question is too long.');
    }
    final maxBytes =
        availableBytes < LocalAssistantContextSelector.maxContextBytes
        ? availableBytes
        : LocalAssistantContextSelector.maxContextBytes;

    // The small model occasionally collapses into a repeated character on a
    // long prompt. Retry once with livelier sampling and a shorter context.
    var answer = '';
    for (final (temperature, bytes) in [
      (0.2, maxBytes),
      (0.7, maxBytes < 6000 ? maxBytes : 6000),
    ]) {
      final selectedContext = LocalAssistantContextSelector().select(
        portfolio,
        question,
        previousQuestion: previousQuestion,
        maxBytes: bytes,
      );
      answer = _groundAnswer(
        _cleanAnswer(
          await _generate(
            model,
            generation: generation,
            systemInstruction: systemInstruction,
            temperature: temperature,
            text:
                'Portfolio information:\n$selectedContext\n\n'
                '${previousQuestion == null ? '' : 'Previous user question: $previousQuestion\n\n'}'
                'Answer only this question, using only the portfolio '
                'information above: $question',
          ),
        ),
        selectedContext,
      );
      if (kDebugMode) {
        debugPrint('[Assistant] Q: $question\n[Assistant] A: $answer');
      }
      if (!_isDegenerate(answer)) break;
    }
    if (answer.isEmpty || _isDegenerate(answer)) {
      throw StateError('The on-device model did not return a usable answer.');
    }
    return answer;
  }

  Future<String> _generate(
    InferenceModel model, {
    required int generation,
    required String systemInstruction,
    required double temperature,
    required String text,
  }) async {
    await _chat?.close();
    _chat = null;
    _ensureCurrent(generation);
    final chat = await model.createChat(
      systemInstruction: systemInstruction,
      temperature: temperature,
      topK: 40,
      maxOutputTokens: 512,
    );
    if (generation != _generation || _disabled) {
      await chat.close();
      throw const LocalAssistantCancelledException();
    }
    _chat = chat;
    // The facts sit next to the question in the user turn, where the small
    // model attends to them far better than in a long system prompt.
    await chat.addQueryChunk(Message(text: text, isUser: true));
    _ensureCurrent(generation);
    final response = await chat.generateChatResponse();
    _ensureCurrent(generation);
    return response is TextResponse ? response.token.trim() : '';
  }

  /// Returns the decoded [portfolioContext], or null when it is not a JSON
  /// object. The result is kept until a different context is passed.
  Map<String, dynamic>? _decodePortfolio(String portfolioContext) {
    if (portfolioContext == _decodedPortfolioSource) return _decodedPortfolio;
    Map<String, dynamic>? portfolio;
    try {
      final decoded = jsonDecode(portfolioContext);
      if (decoded is Map<String, dynamic>) portfolio = decoded;
    } on FormatException {
      portfolio = null;
    }
    _decodedPortfolioSource = portfolioContext;
    _decodedPortfolio = portfolio;
    return portfolio;
  }

  static final _repeatedRun = RegExp(r'(\S)\1{11,}');
  // The same two to six words four or more times in a row.
  static final _repeatedPhrase = RegExp(
    r'(\b\w+(?:\s+\w+){1,5}\b)(?:\W+\1\b){3,}',
    caseSensitive: false,
  );

  static bool _isDegenerate(String answer) =>
      _repeatedRun.hasMatch(answer) || _repeatedPhrase.hasMatch(answer);

  static final _emphasisMarkers = RegExp(r'\*\*|__');
  static final _headingMarkers = RegExp(r'^#{1,6}\s+', multiLine: true);
  static final _bulletMarkers = RegExp(r'^\s*[*•]\s+', multiLine: true);
  static final _answerLabel = RegExp(r'^(answer|a):\s*', caseSensitive: false);
  static final _blankLines = RegExp(r'\n{3,}');

  // The chat renders plain text, so markdown the model adds despite the
  // instruction would show up as literal asterisks.
  static String _cleanAnswer(String answer) => answer
      .replaceAll(_emphasisMarkers, '')
      .replaceAll(_headingMarkers, '')
      .replaceAll(_bulletMarkers, '- ')
      .replaceFirst(_answerLabel, '')
      .replaceAll(_blankLines, '\n\n')
      .trim();

  static final _url = RegExp(r'https?://[^\s<>"]+');
  static final _urlTrailingPunctuation = RegExp(r'[.,;:!?)\]]+$');
  static final _sentenceEnd = RegExp(r'[.!?](?=\s|$)');
  static const _missingLink = '(no link listed in the portfolio)';
  static const _answerBytesNearLimit = 1600;

  // A link the facts do not contain was made up, so it is replaced rather
  // than shown. An answer about as long as the output limit was cut off, so
  // it ends at its last full sentence instead of mid-word.
  static String _groundAnswer(String answer, String selectedContext) {
    var grounded = answer.replaceAllMapped(_url, (match) {
      final text = match[0]!;
      final url = text.replaceFirst(_urlTrailingPunctuation, '');
      final trailing = text.substring(url.length);
      return selectedContext.contains(url) ? text : '$_missingLink$trailing';
    });
    if (utf8.encode(grounded).length >= _answerBytesNearLimit &&
        !grounded.endsWith('.') &&
        !grounded.endsWith('!') &&
        !grounded.endsWith('?')) {
      final lastEnd = _sentenceEnd.allMatches(grounded).lastOrNull;
      if (lastEnd != null) grounded = grounded.substring(0, lastEnd.end);
    }
    return grounded.trim();
  }

  @override
  Future<void> cancelPreparation() async {
    final pending = _preparation;
    _cancelToken?.cancel('The assistant was turned off.');
    try {
      await pending;
    } on Object {
      // The cancelled download is expected to fail.
    }
    await deleteModel();
  }

  @override
  Future<void> deleteModel() async {
    await _unloadModel();
    await _initialize();
    if (await FlutterEdgeAi.isModelInstalled(_modelFile)) {
      await FlutterEdgeAi.uninstallModel(_modelFile);
    }
  }

  Future<void> _unloadModel() async {
    _generation++;
    final chat = _chat;
    final model = _model;
    _chat = null;
    _model = null;
    _previousQuestion = null;
    await chat?.close();
    await model?.close();
  }

  @override
  Future<void> resetSession() async {
    _generation++;
    _previousQuestion = null;
    final chat = _chat;
    _chat = null;
    await chat?.close();
  }

  @override
  Future<void> dispose() async {
    _generation++;
    await _chat?.close();
    await _model?.close();
  }

  Future<void> _initialize() {
    return _initialization ??= FlutterEdgeAi.initialize(
      inferenceEngines: const [LiteRtLmEngine()],
    );
  }
}
