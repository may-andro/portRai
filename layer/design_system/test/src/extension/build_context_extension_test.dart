import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const textStyle = DSTextStyle(fontSize: 16, height: 1.5);

  Future<BuildContext> pumpContext(
    WidgetTester tester, {
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    late BuildContext measuredContext;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Builder(
          builder: (context) {
            measuredContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return measuredContext;
  }

  double paragraphWidth(String text, TextScaler textScaler) {
    final renderParagraph = RenderParagraph(
      TextSpan(text: text, style: textStyle.textStyle),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    );
    final paragraphWidth = renderParagraph.getMaxIntrinsicWidth(
      double.infinity,
    );
    renderParagraph.dispose();
    return paragraphWidth;
  }

  double paragraphLineHeight(TextScaler textScaler) {
    final renderParagraph = RenderParagraph(
      TextSpan(text: 'Measured line', style: textStyle.textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      strutStyle: StrutStyle.fromTextStyle(textStyle.textStyle),
      textScaler: textScaler,
    );
    final lineHeight = renderParagraph.getMaxIntrinsicHeight(double.infinity);
    renderParagraph.dispose();
    return lineHeight;
  }

  group('getTextWidth', () {
    testWidgets('should measure the width a paragraph lays the text out at '
        'when the text is scaled', (tester) async {
      const textScaler = TextScaler.linear(1.5);
      final context = await pumpContext(tester, textScaler: textScaler);

      expect(
        context.getTextWidth('Measured text', textStyle),
        paragraphWidth('Measured text', textScaler),
      );
    });
  });

  group('getTextHeight', () {
    testWidgets('should measure the height of a paragraph line times the '
        'number of lines', (tester) async {
      final context = await pumpContext(tester);

      expect(
        context.getTextHeight(textStyle, 3),
        paragraphLineHeight(TextScaler.noScaling) * 3,
      );
    });

    testWidgets('should measure again when the text scaler changes', (
      tester,
    ) async {
      final unscaledContext = await pumpContext(tester);
      final unscaledHeight = unscaledContext.getTextHeight(textStyle, 1);
      const textScaler = TextScaler.linear(2);
      final scaledContext = await pumpContext(tester, textScaler: textScaler);

      final scaledHeight = scaledContext.getTextHeight(textStyle, 1);

      expect(scaledHeight, paragraphLineHeight(textScaler));
      expect(scaledHeight, greaterThan(unscaledHeight));
    });
  });
}
