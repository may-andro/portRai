import 'dart:async';
import 'dart:convert';

import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_edge_ai_litertlm/flutter_edge_ai_litertlm.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/data/cache/_cache.dart';
import 'package:portrai/src/feature/assistant/data/repository/assistant_context_selector.dart';
import 'package:portrai/src/feature/assistant/data/repository/assistant_direct_answerer.dart';
import 'package:portrai/src/feature/assistant/domain/_domain.dart';

@RegisterSingleton(as: AssistantRepository, disposeMethodName: 'dispose')
class FlutterEdgeAiAssistantRepository implements AssistantRepository {
  FlutterEdgeAiAssistantRepository(this._enabledCache);

  @visibleForTesting
  FlutterEdgeAiAssistantRepository.withModelLoader(
    this._modelLoader, {
    AssistantEnabledCache? enabledCache,
  }) : _enabledCache = enabledCache ?? AssistantEnabledCache();

  final AssistantEnabledCache _enabledCache;

  // Gemma 4's chat template accepts the structured message content that
  // flutter_edge_ai sends. The Qwen3 1.7B/4B exports only accept plain string
  // content, so the native runtime fails to apply their template.
  static const _modelRepository = 'litert-community/gemma-4-E2B-it-litert-lm';
  static const _modelRevision = 'b3ca0d2f076785a8f4b2219ddbd2bdb99954eae1';
  static const _maxTokens = 8192;
  static const _modelFile = 'gemma-4-E2B-it.litertlm';
  static const _systemInstruction =
      "You are the Q&A assistant for Mayank Rai's professional portfolio. "
      'You are not a general-purpose chatbot. Answer questions only about '
      'Mayank, his contact details, background, experience, projects, skills, '
      'services, and availability, using only the portfolio information below. '
      "If asked who to contact, give Mayank Rai's name and the contact "
      'details provided. Greet only when the message is nothing but a '
      'greeting; otherwise answer the question directly. For unrelated '
      "questions, politely say you can only help with Mayank's portfolio. "
      'For questions about Mayank that the portfolio does not cover, such as '
      'salary, age, visa or hobbies, say that this is not in the portfolio '
      'and do not guess. For questions about a year, period, order, country, '
      'remote or freelance work, years with a technology, career gaps, '
      'leadership, spoken languages, longest or shortest, use the overview '
      'lines and copy their numbers. Spoken languages come only from the '
      'spoken languages line, never from country names. Answer a follow-up for what it asks, not like the '
      'previous question. When asked for a link, copy the URL exactly as '
      'written, and if it says "not found" say that no such link was found. '
      'Keep answers direct and concise.';

  Future<void>? _initialization;
  Future<void>? _preparation;
  Future<InferenceModel> Function(void Function(int))? _modelLoader;
  InferenceModel? _model;
  InferenceChat? _chat;
  String? _previousQuestion;
  CancelToken? _cancelToken;

  @override
  Future<bool> isEnabled() async => await _enabledCache.get() ?? false;

  @override
  Future<void> setEnabled({required bool enabled}) async {
    await _enabledCache.put(enabled);
    if (!enabled) await _unloadModel();
  }

  @override
  Future<bool> isModelDownloaded() async {
    await _initialize();
    return await FlutterEdgeAi.isModelInstalled(_modelFile);
  }

  @override
  Future<void> prepareModel({required void Function(int) onProgress}) {
    if (_model != null) return Future.value();
    return _preparation ??= _prepareModel(onProgress);
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
    // The engine is loaded on the first question rather than at startup.
    await prepareModel(onProgress: (_) {});
    final model = _model;
    if (model == null) {
      throw StateError('The on-device model could not be loaded.');
    }

    final direct = AssistantDirectAnswerer(portfolioContext).answer(question);
    if (direct != null) {
      _previousQuestion = question;
      return direct;
    }

    final previousQuestion = _previousQuestion ?? 'none';
    // UTF-8 bytes conservatively bound token count. Reserve room for the
    // answer and chat-template tokens rather than silently truncating input.
    final availableBytes =
        _maxTokens -
        utf8.encode('$_systemInstruction$question$previousQuestion').length -
        1024;
    if (availableBytes < 512) {
      throw ArgumentError.value(question, 'question', 'Question is too long.');
    }
    final selectedContext = AssistantContextSelector().select(
      portfolioContext,
      question,
      previousQuestion: _previousQuestion,
      maxBytes: availableBytes < AssistantContextSelector.maxContextBytes
          ? availableBytes
          : AssistantContextSelector.maxContextBytes,
    );
    await _chat?.close();
    _chat = null;
    _chat = await model.createChat(
      systemInstruction: _systemInstruction,
      temperature: 0.2,
      topK: 40,
      maxOutputTokens: 512,
    );

    final chat = _chat!;
    // The facts sit next to the question in the user turn, where the small
    // model attends to them far better than in a long system prompt.
    await chat.addQueryChunk(
      Message(
        text:
            'Portfolio information:\n$selectedContext\n\n'
            'Previous user question: $previousQuestion\n\n'
            'Answer only this new question, using only the portfolio '
            'information above. It may be a follow-up to the previous '
            'question, but never repeat the previous answer: $question',
        isUser: true,
      ),
    );
    final response = await chat.generateChatResponse();
    final answer = response is TextResponse ? response.token.trim() : '';
    if (answer.isEmpty) {
      throw StateError('The on-device model returned an empty answer.');
    }
    _previousQuestion = question;
    return answer;
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
    final chat = _chat;
    final model = _model;
    _chat = null;
    _model = null;
    _previousQuestion = null;
    await chat?.close();
    await model?.close();
  }

  @override
  Future<void> dispose() async {
    await _chat?.close();
    await _model?.close();
  }

  Future<void> _initialize() {
    return _initialization ??= FlutterEdgeAi.initialize(
      inferenceEngines: const [LiteRtLmEngine()],
    );
  }
}
