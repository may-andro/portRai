import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

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
}
