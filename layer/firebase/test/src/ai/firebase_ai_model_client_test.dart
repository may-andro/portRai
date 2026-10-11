import 'dart:convert';

import 'package:firebase/src/ai/ai_model_client.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

import '../../util/ai_test_model.dart';

void main() {
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  const body = {
    'candidates': [
      {
        'content': {
          'role': 'model',
          'parts': [
            {'text': 'SDK answer'},
          ],
        },
        'finishReason': 'STOP',
      },
    ],
  };

  test(
    'should forward single requests when using the real SDK adapter',
    () async {
      final requests = <Request>[];
      final httpClient = MockClient((request) async {
        requests.add(request);
        return Response(jsonEncode(body), 200);
      });
      final client = FirebaseAiModelClient(
        createAiTestModel(httpClient: httpClient),
        httpClient,
      );
      addTearDown(client.close);

      final result = await client.generateContent([Content.text('Question')]);

      expect(result.text, 'SDK answer');
      expect(requests.single.url.path, endsWith('test-model:generateContent'));
      final payload = jsonDecode(requests.single.body) as Map<String, dynamic>;
      expect(payload['contents'], [Content.text('Question').toJson()]);
    },
  );

  test(
    'should parse SSE responses when using the real SDK stream adapter',
    () async {
      final requests = <Request>[];
      final httpClient = MockClient((request) async {
        requests.add(request);
        return Response('data: ${jsonEncode(body)}\n\n', 200);
      });
      final client = FirebaseAiModelClient(
        createAiTestModel(httpClient: httpClient),
        httpClient,
      );
      addTearDown(client.close);

      final responses = await client.generateContentStream([
        Content.text('Question'),
      ]).toList();

      expect(responses.single.text, 'SDK answer');
      expect(
        requests.single.url.path,
        endsWith('test-model:streamGenerateContent'),
      );
      expect(requests.single.url.queryParameters['alt'], 'sse');
    },
  );
}
