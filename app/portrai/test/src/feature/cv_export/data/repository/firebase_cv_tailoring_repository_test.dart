import 'dart:convert';

import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/cv_export/data/_data.dart';
import 'package:portrai/src/feature/cv_export/domain/_domain.dart';

import '../../../../../mock/feature/remote_assistant/data/repository/mock_fb_ai_controller.dart';
import '../../../../../mock/feature/remote_assistant/data/repository/mock_fb_ai_text_model.dart';
import '../../../../../util/cv_export_test_fixture.dart';

void main() {
  group('FirebaseCvTailoringRepository', () {
    late MockFbAiController aiController;
    late MockFbAiTextModel textModel;

    final document = CvExportTestFixture.heavyDocument();
    const target = CvTailoringTargetEntity(
      title: 'Senior Flutter Developer',
      company: 'Acme',
      description: 'Build apps with Flutter.',
      skills: ['Flutter'],
    );

    setUpAll(() {
      registerFallbackValue(FakeFirebaseAiContents());
      registerFallbackValue(GenerationConfig(maxOutputTokens: 1024));
    });

    setUp(() {
      aiController = MockFbAiController();
      textModel = MockFbAiTextModel();
      when(
        () => aiController.createTextModel(
          model: any(named: 'model'),
          generationConfig: any(named: 'generationConfig'),
          systemInstruction: any(named: 'systemInstruction'),
        ),
      ).thenReturn(textModel);
    });

    FirebaseCvTailoringRepository buildRepository({String? model}) =>
        FirebaseCvTailoringRepository(
          aiController,
          PortraiAppConfigEntity(
            minimumRequiredAppVersion: '1.0.0',
            aiAssistantModel: model,
          ),
        );

    void stubResponse(String response) {
      when(
        () => textModel.generateText(any()),
      ).thenAnswer((_) async => response);
    }

    test('should read the tailoring from the JSON response', () async {
      stubResponse(
        jsonEncode({
          'summary': 'Flutter engineer.',
          'projectOrder': [2, 0],
          'skillGroupOrder': [1],
          'prioritizedSkills': ['Skill 3', 4],
        }),
      );

      final tailoring = await buildRepository().tailor(
        document: document,
        target: target,
      );

      expect(
        tailoring,
        const CvTailoringEntity(
          summary: 'Flutter engineer.',
          projectOrder: [2, 0],
          skillGroupOrder: [1],
          prioritizedSkills: ['Skill 3'],
        ),
      );
      verify(() => textModel.close()).called(1);
    });

    test('should send the CV and the job with indexes as data', () async {
      stubResponse(jsonEncode({'summary': 'Summary.'}));

      await buildRepository(
        model: 'configured-model',
      ).tailor(document: document, target: target);

      final contents =
          verify(() => textModel.generateText(captureAny())).captured.single
              as Iterable<Content>;
      final prompt =
          jsonDecode((contents.single.parts.single as TextPart).text)
              as Map<String, dynamic>;
      final cv = prompt['cv'] as Map<String, dynamic>;
      expect((cv['projects'] as List).first, containsPair('index', 0));
      expect((cv['skillGroups'] as List)[1], containsPair('title', 'Group 1'));
      expect(prompt['jobOpening'], containsPair('company', 'Acme'));
      verify(
        () => aiController.createTextModel(
          model: 'configured-model',
          generationConfig: any(named: 'generationConfig'),
          systemInstruction: any(named: 'systemInstruction'),
        ),
      ).called(1);
    });

    test('should throw and close the model when the response is not '
        'valid', () async {
      stubResponse('not json');

      await expectLater(
        buildRepository().tailor(document: document, target: target),
        throwsA(isA<CvTailoringResponseException>()),
      );
      verify(() => textModel.close()).called(1);
    });

    test('should throw when the summary is missing', () async {
      stubResponse(
        jsonEncode({
          'projectOrder': [0],
        }),
      );

      await expectLater(
        buildRepository().tailor(document: document, target: target),
        throwsA(isA<CvTailoringResponseException>()),
      );
    });
  });
}
