import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
      'DSTimeline',
      'DSSkillBars',
      'DSQuote',
      'DSStatGrid',
      'DSCarousel',
      'DSTabs',
      'DSCallout',
      'DSProgressRing',
      'DSCodeBlock',
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

  test('should add DSImage only when image URLs are allowed', () {
    final catalog = createAssistantCatalog(
      allowedUrls: {'https://cdn.test/a.png'},
    );

    expect(catalog.items.map((item) => item.name), contains('DSImage'));
  });

  test('should extract unique https URLs when reading portfolio context', () {
    final urls = assistantUrlsFrom(
      '{"a":"https://cdn.test/a.png","b":"https://cdn.test/a.png",'
      '"c":"http://insecure.test/x.png","d":"https://cdn.test/b.jpg?x=1"}',
    );

    expect(urls, {'https://cdn.test/a.png', 'https://cdn.test/b.jpg?x=1'});
  });

  testWidgets(
    'should render only allowed URLs when A2UI describes DSImage components',
    (tester) async {
      final controller = SurfaceController(
        catalogs: [
          createAssistantCatalog(allowedUrls: {'https://cdn.test/a.png'}),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SingleChildScrollView(
            child: Surface(surfaceContext: controller.contextFor('img')),
          ),
        ),
      );
      await _feed(tester, controller, [
        '''
{"version":"v0.9","createSurface":{"surfaceId":"img","catalogId":"dev.portrai.assistant"}}
{"version":"v0.9","updateComponents":{"surfaceId":"img","components":[
  {"id":"root","component":"DSColumn","children":["ok","bad"]},
  {"id":"ok","component":"DSImage","url":"https://cdn.test/a.png","variant":"avatar"},
  {"id":"bad","component":"DSImage","url":"https://evil.test/x.png"}
]}}
''',
      ]);
      await tester.pump();

      expect(find.byType(DSNetworkImageWidget), findsOneWidget);
    },
  );

  test('should add DSLinkButton only when URLs and a callback are given', () {
    List<String> names(Catalog c) => c.items.map((i) => i.name).toList();

    expect(
      names(createAssistantCatalog(allowedUrls: {'https://a.test'})),
      isNot(contains('DSLinkButton')),
    );
    expect(
      names(createAssistantCatalog(onOpenLink: (_) {})),
      isNot(contains('DSLinkButton')),
    );
    expect(
      names(
        createAssistantCatalog(
          allowedUrls: {'https://a.test'},
          onOpenLink: (_) {},
        ),
      ),
      contains('DSLinkButton'),
    );
  });

  testWidgets('should open only allowed URLs when DSLinkButton is tapped', (
    tester,
  ) async {
    final opened = <String>[];
    final controller = SurfaceController(
      catalogs: [
        createAssistantCatalog(
          allowedUrls: {'https://a.test/p'},
          onOpenLink: opened.add,
        ),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      TestWidgetWrapper(
        child: SingleChildScrollView(
          child: Surface(surfaceContext: controller.contextFor('link')),
        ),
      ),
    );
    await _feed(tester, controller, [
      '''
{"version":"v0.9","createSurface":{"surfaceId":"link","catalogId":"dev.portrai.assistant"}}
{"version":"v0.9","updateComponents":{"surfaceId":"link","components":[
  {"id":"root","component":"DSColumn","children":["ok","bad"]},
  {"id":"ok","component":"DSLinkButton","label":"Open project","url":"https://a.test/p"},
  {"id":"bad","component":"DSLinkButton","label":"Evil","url":"https://evil.test"}
]}}
''',
    ]);
    await tester.pump();

    expect(find.byType(DSButtonWidget), findsOneWidget);
    await tester.tap(find.byType(DSButtonWidget));
    expect(opened, ['https://a.test/p']);
  });

  testWidgets(
    'should render timeline, skill bars and quote when A2UI describes them',
    (tester) async {
      final controller = SurfaceController(
        catalogs: [createAssistantCatalog()],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SingleChildScrollView(
            child: Surface(surfaceContext: controller.contextFor('story')),
          ),
        ),
      );
      await _feed(tester, controller, [
        '''
{"version":"v0.9","createSurface":{"surfaceId":"story","catalogId":"dev.portrai.assistant"}}
{"version":"v0.9","updateComponents":{"surfaceId":"story","components":[
  {"id":"root","component":"DSColumn","children":["t","s","q"]},
  {"id":"t","component":"DSTimeline","entries":[
    {"period":"2021 - 2024","title":"Lead Engineer","subtitle":"Acme"},
    {"title":"Engineer"}]},
  {"id":"s","component":"DSSkillBars","items":[
    {"label":"Flutter","value":6,"display":"6 yrs"},
    {"label":"Kotlin","value":3}]},
  {"id":"q","component":"DSQuote","text":"Great to work with.","author":"Sam","role":"CTO"}
]}}
''',
      ]);
      await tester.pump();

      expect(find.text('Lead Engineer'), findsOneWidget);
      expect(find.text('Engineer'), findsOneWidget);
      expect(find.text('Acme'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('6 yrs'), findsOneWidget);
      expect(find.byType(DSQuoteTextWidget), findsOneWidget);
      expect(find.text('Sam, CTO'), findsOneWidget);
    },
  );

  test('should add DSMap only when locations are allowed', () {
    final catalog = createAssistantCatalog(
      allowedLocations: [(latitude: 1.0, longitude: 2.0)],
    );

    expect(catalog.items.map((item) => item.name), contains('DSMap'));
  });

  test('should extract nested coordinates when reading portfolio context', () {
    expect(
      assistantLocationsFrom(
        '{"location":{"city":"Oslo","latitude":59.9,"longitude":10.7}}',
      ),
      [(latitude: 59.9, longitude: 10.7)],
    );
    expect(assistantLocationsFrom('not json'), isEmpty);
    expect(
      assistantLocationsFrom(
        '{"location":{"latitude":1,"longitude":2},'
        '"experiences":[{"latitude":3.5,"longitude":4.5},'
        '{"latitude":null,"longitude":null}]}',
      ),
      [(latitude: 1.0, longitude: 2.0), (latitude: 3.5, longitude: 4.5)],
    );
  });

  testWidgets(
    'should render nothing when A2UI describes DSMap with coordinates outside the portfolio',
    (tester) async {
      final controller = SurfaceController(
        catalogs: [
          createAssistantCatalog(
            allowedLocations: [(latitude: 59.9, longitude: 10.7)],
          ),
        ],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: SingleChildScrollView(
            child: Surface(surfaceContext: controller.contextFor('map')),
          ),
        ),
      );
      await _feed(tester, controller, [
        '''
{"version":"v0.9","createSurface":{"surfaceId":"map","catalogId":"dev.portrai.assistant"}}
{"version":"v0.9","updateComponents":{"surfaceId":"map","components":[
  {"id":"root","component":"DSMap","places":[{"latitude":10.0,"longitude":20.0}]}
]}}
''',
      ]);
      await tester.pump();

      expect(find.byType(GoogleMap), findsNothing);
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

  testWidgets('should render metrics side by side when DSStatGrid is used', (
    tester,
  ) async {
    await _pumpSurface(tester, createAssistantCatalog(), '''
{"id":"root","component":"DSStatGrid","children":["a","b"]},
{"id":"a","component":"DSMetric","value":"8+","label":"Years"},
{"id":"b","component":"DSMetric","value":"20","label":"Projects"}''');

    expect(find.text('8+'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('20')).dx,
      greaterThan(tester.getTopLeft(find.text('8+')).dx),
    );
  });

  testWidgets('should render every child when DSCarousel is used', (
    tester,
  ) async {
    await _pumpSurface(tester, createAssistantCatalog(), '''
{"id":"root","component":"DSCarousel","children":["a","b"]},
{"id":"a","component":"DSText","text":"First card"},
{"id":"b","component":"DSText","text":"Second card"}''');

    expect(find.text('First card'), findsOneWidget);
    expect(find.text('Second card'), findsOneWidget);
  });

  testWidgets('should switch content when a DSTabs tab is tapped', (
    tester,
  ) async {
    await _pumpSurface(tester, createAssistantCatalog(), '''
{"id":"root","component":"DSTabs","tabs":[
  {"title":"Frontend","child":"f"},{"title":"Backend","child":"b"}]},
{"id":"f","component":"DSText","text":"Flutter"},
{"id":"b","component":"DSText","text":"Kotlin"}''');

    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Kotlin'), findsNothing);

    await tester.tap(find.text('Backend'));
    await tester.pump();

    expect(find.text('Kotlin'), findsOneWidget);
    expect(find.text('Flutter'), findsNothing);
  });

  testWidgets('should render its text when DSCallout is used', (tester) async {
    await _pumpSurface(
      tester,
      createAssistantCatalog(),
      '''
{"id":"root","component":"DSCallout","text":"Open to work","variant":"success"}''',
    );

    expect(find.text('Open to work'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('should render a clamped gauge when DSProgressRing is used', (
    tester,
  ) async {
    await _pumpSurface(tester, createAssistantCatalog(), '''
{"id":"root","component":"DSProgressRing","value":250,"label":"Flutter"}''');

    final ring = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(ring.value, 1.0);
    expect(find.text('250%'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
  });

  testWidgets('should keep line breaks when DSCodeBlock is used', (
    tester,
  ) async {
    await _pumpSurface(
      tester,
      createAssistantCatalog(),
      '''
{"id":"root","component":"DSCodeBlock","code":"flutter pub get\\nflutter run"}''',
    );

    expect(find.text('flutter pub get\nflutter run'), findsOneWidget);
  });
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

Future<void> _pumpSurface(
  WidgetTester tester,
  Catalog catalog,
  String components,
) async {
  final controller = SurfaceController(catalogs: [catalog]);
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    TestWidgetWrapper(
      child: SingleChildScrollView(
        child: Surface(surfaceContext: controller.contextFor('s')),
      ),
    ),
  );
  await _feed(tester, controller, [
    '''
{"version":"v0.9","createSurface":{"surfaceId":"s","catalogId":"dev.portrai.assistant"}}
{"version":"v0.9","updateComponents":{"surfaceId":"s","components":[$components]}}
''',
  ]);
  await tester.pump();
}
