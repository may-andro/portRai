import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  test('should expose only DS components when creating the catalog', () {
    final catalog = createAssistantCatalog();

    expect(catalog.catalogId, 'dev.portrai.assistant');
    expect(catalog.items.map((item) => item.name), [
      'DSText',
      'DSMetric',
      'DSBulletList',
      'DSCard',
      'DSColumn',
      'DSWrap',
      'DSDivider',
      'DSTag',
      'DSInfoChip',
      'DSLabeledInfoRow',
      'DSExpandable',
    ]);
    expect(catalog.functions, isEmpty);
    expect(catalog.catalogIdAliases, isEmpty);
    expect(catalog.items.first.dataSchema.value['required'], [
      'component',
      'text',
    ]);
  });

  testWidgets(
    'should compose DS text and update its binding when A2UI changes the surface',
    (tester) async {
      final controller = SurfaceController(
        catalogs: [createAssistantCatalog()],
      );
      addTearDown(controller.dispose);
      final errors = <ChatMessage>[];
      final subscription = controller.onSubmit.listen(errors.add);
      addTearDown(subscription.cancel);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: Surface(surfaceContext: controller.contextFor('fixture')),
        ),
      );

      final events = await _feed(tester, controller, [
        '{"version":"v0.9","createSurface":{"surfaceId":"fixture",',
        '"catalogId":"dev.portrai.assistant"}}\n',
        '''
{"version":"v0.9","updateDataModel":{"surfaceId":"fixture","path":"/","value":{"message":"Initial fixture"}}}
{"version":"v0.9","updateComponents":{"surfaceId":"fixture","components":[
  {"id":"root","component":"DSCard","child":"body"},
  {"id":"body","component":"DSText","text":{"path":"/message"}}
]}}
''',
      ]);
      await tester.pump();

      expect(events, hasLength(3));
      expect(controller.activeSurfaceIds, ['fixture']);
      expect(find.byType(DSCardWidget), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DSCardWidget),
          matching: find.byType(DSTextWidget),
        ),
        findsOneWidget,
      );
      expect(find.text('Initial fixture'), findsOneWidget);

      await _feed(tester, controller, [
        '''
{"version":"v0.9","updateDataModel":{"surfaceId":"fixture","path":"/message","value":"Updated fixture"}}
''',
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Initial fixture'), findsNothing);
      expect(find.text('Updated fixture'), findsOneWidget);
      expect(errors, isEmpty);

      await _feed(tester, controller, [
        '{"version":"v0.9","deleteSurface":{"surfaceId":"fixture"}}',
      ]);
      await tester.pumpAndSettle();

      expect(controller.activeSurfaceIds, isEmpty);
      expect(find.byType(DSCardWidget), findsNothing);
      expect(find.byType(DSTextWidget), findsNothing);
      expect(errors, isEmpty);
    },
  );

  testWidgets(
    'should render composed DS components when A2UI describes a rich answer',
    (tester) async {
      final controller = SurfaceController(
        catalogs: [createAssistantCatalog()],
      );
      addTearDown(controller.dispose);
      final errors = <ChatMessage>[];
      final subscription = controller.onSubmit.listen(errors.add);
      addTearDown(subscription.cancel);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SingleChildScrollView(
            child: Surface(surfaceContext: controller.contextFor('rich')),
          ),
        ),
      );
      await _feed(tester, controller, [
        '''
{"version":"v0.9","createSurface":{"surfaceId":"rich","catalogId":"dev.portrai.assistant"}}
{"version":"v0.9","updateComponents":{"surfaceId":"rich","components":[
  {"id":"root","component":"DSColumn","children":["head","metric","chips","facts","list","div","more"]},
  {"id":"head","component":"DSText","text":"Flutter experience","variant":"heading"},
  {"id":"metric","component":"DSMetric","value":"5+","label":"years"},
  {"id":"chips","component":"DSWrap","children":["tag","chip"]},
  {"id":"tag","component":"DSTag","label":"Dart"},
  {"id":"chip","component":"DSInfoChip","icon":"location","label":"Remote"},
  {"id":"facts","component":"DSLabeledInfoRow","icon":"unknown","label":"Company","value":"Acme"},
  {"id":"list","component":"DSBulletList","items":["First point","Second point"]},
  {"id":"div","component":"DSDivider"},
  {"id":"more","component":"DSExpandable","title":"Details","child":"card"},
  {"id":"card","component":"DSCard","child":"note"},
  {"id":"note","component":"DSText","text":"Hidden note","variant":"caption"}
]}}
''',
      ]);
      await tester.pumpAndSettle();

      expect(errors, isEmpty);
      expect(tester.takeException(), isNull);
      for (final text in [
        'Flutter experience',
        '5+',
        'years',
        'Dart',
        'Remote',
        'Company',
        'Acme',
        'Details',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(find.byType(DSBulletPointListWidget), findsOneWidget);
      expect(find.byType(DSTagWidget), findsOneWidget);
      expect(find.byType(DSInfoChipWidget), findsOneWidget);
      expect(find.byType(DSLabeledInfoRowWidget), findsOneWidget);
      expect(find.byType(DSHorizontalDividerWidget), findsOneWidget);
      expect(find.byType(DSExpandableCardWidget), findsOneWidget);
    },
  );

  testWidgets(
    'should render literal DS text when A2UI supplies an unbound value',
    (tester) async {
      final controller = SurfaceController(
        catalogs: [createAssistantCatalog()],
      );
      addTearDown(controller.dispose);

      await _feed(tester, controller, [
        '''
{"version":"v0.9","createSurface":{"surfaceId":"fixture","catalogId":"dev.portrai.assistant"}}
{"version":"v0.9","updateComponents":{"surfaceId":"fixture","components":[
  {"id":"root","component":"DSText","text":"Literal fixture"}
]}}
''',
      ]);
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: Surface(surfaceContext: controller.contextFor('fixture')),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<DSTextWidget>(find.byType(DSTextWidget));
      final context = tester.element(find.byType(DSTextWidget));
      expect(text.data, 'Literal fixture');
      expect(text.style, context.typography.bodyMedium);
      expect(text.color, context.colorPalette.neutral.grey9);
    },
  );

  testWidgets(
    'should report a framework error when A2UI requests an unsupported component',
    (tester) async {
      final controller = SurfaceController(
        catalogs: [createAssistantCatalog()],
      );
      addTearDown(controller.dispose);
      final errors = <ChatMessage>[];
      final subscription = controller.onSubmit.listen(errors.add);
      addTearDown(subscription.cancel);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: Surface(surfaceContext: controller.contextFor('fixture')),
        ),
      );
      await _feed(tester, controller, [
        '''
{"version":"v0.9","createSurface":{"surfaceId":"fixture","catalogId":"dev.portrai.assistant"}}
{"version":"v0.9","updateComponents":{"surfaceId":"fixture","components":[
  {"id":"root","component":"Image"}
]}}
''',
      ]);
      await tester.pumpAndSettle();

      expect(find.byType(DSTextWidget), findsNothing);
      expect(find.byType(DSCardWidget), findsNothing);
      expect(errors, isNotEmpty);
      final interactions = errors
          .expand((message) => message.parts.uiInteractionParts)
          .map((part) => part.interaction);
      expect(interactions.any((value) => value.contains('"error"')), isTrue);
      expect(
        interactions.any((value) => value.contains('VALIDATION_FAILED')),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Future<List<A2uiMessageEvent>> _feed(
  WidgetTester tester,
  SurfaceController controller,
  List<String> chunks,
) async {
  // Framework schema validation needs the real async zone, not the fake clock.
  return (await tester.runAsync(() async {
    final events = await Stream.fromIterable(
      chunks,
    ).transform(const A2uiParserTransformer()).toList();
    final messages = events.whereType<A2uiMessageEvent>().toList();
    for (final event in messages) {
      controller.handleMessage(event.message);
    }
    return messages;
  }))!;
}
