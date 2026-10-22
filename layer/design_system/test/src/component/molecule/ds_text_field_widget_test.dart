import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util/alchemist_utils.dart';
import '../../../util/test_wrapper_widget.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSTextFieldWidget',
    (theme) => [
      const TestCase(
        'empty with hint',
        SizedBox(
          width: 280,
          child: DSTextFieldWidget(hintText: 'Enter your email'),
        ),
      ),
      const TestCase(
        'with label',
        SizedBox(
          width: 280,
          child: DSTextFieldWidget(
            labelText: 'Email',
            hintText: 'Enter your email',
          ),
        ),
      ),
      const TestCase(
        'disabled',
        SizedBox(
          width: 280,
          child: DSTextFieldWidget(
            labelText: 'Email',
            hintText: 'Enter your email',
            enabled: false,
          ),
        ),
      ),
      const TestCase(
        'password',
        SizedBox(
          width: 280,
          child: DSTextFieldWidget(
            labelText: 'Password',
            hintText: 'Enter your password',
            textFieldType: TextFieldType.password,
          ),
        ),
      ),
      const TestCase(
        'with helper text',
        SizedBox(
          width: 280,
          child: DSTextFieldWidget(
            labelText: 'Username',
            hintText: 'Enter username',
            helperText: 'Must be at least 4 characters',
          ),
        ),
      ),
    ],
  );
  group('controller', () {
    Future<void> pumpTextField(
      WidgetTester tester,
      TextEditingController controller,
    ) {
      return tester.pumpWidget(
        TestWidgetWrapper(
          brightness: Brightness.light,
          designSystem: DesignSystem.values.first,
          child: DSTextFieldWidget(controller: controller),
        ),
      );
    }

    TextFormField textFormField(WidgetTester tester) =>
        tester.widget<TextFormField>(find.byType(TextFormField));

    testWidgets('should not rebuild when a keystroke keeps the field filled', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'a');
      addTearDown(controller.dispose);
      await pumpTextField(tester, controller);
      final filledTextFormField = textFormField(tester);

      controller.text = 'ab';
      await tester.pump();

      expect(textFormField(tester), same(filledTextFormField));
    });

    testWidgets('should rebuild when the field becomes empty', (tester) async {
      final controller = TextEditingController(text: 'a');
      addTearDown(controller.dispose);
      await pumpTextField(tester, controller);
      final filledTextFormField = textFormField(tester);

      controller.clear();
      await tester.pump();

      expect(textFormField(tester), isNot(same(filledTextFormField)));
    });

    testWidgets('should follow the new controller when the controller '
        'changes', (tester) async {
      final firstController = TextEditingController();
      final secondController = TextEditingController();
      addTearDown(firstController.dispose);
      addTearDown(secondController.dispose);
      await pumpTextField(tester, firstController);
      await pumpTextField(tester, secondController);
      final emptyTextFormField = textFormField(tester);

      firstController.text = 'a';
      await tester.pump();

      expect(textFormField(tester), same(emptyTextFormField));

      secondController.text = 'a';
      await tester.pump();

      expect(textFormField(tester), isNot(same(emptyTextFormField)));
      expect(textFormField(tester).controller, same(secondController));
    });
  });
}
