import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PasswordField toggles obscureText', (tester) async {
    final controller = TextEditingController(text: 'secret');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.standard,
        home: Scaffold(
          body: PasswordField(
            controller: controller,
            labelText: 'Password',
            hintText: 'Enter password',
          ),
        ),
      ),
    );

    // Initially obscured
    final editable = find.byType(EditableText);
    expect(editable, findsOneWidget);
    var obscure = tester.widget<EditableText>(editable).obscureText;
    expect(obscure, isTrue);

    // Tap suffix icon to toggle
    final suffixIcon = find.byType(IconButton);
    await tester.tap(suffixIcon);
    await tester.pumpAndSettle();

    obscure = tester.widget<EditableText>(editable).obscureText;
    expect(obscure, isFalse);
  });
}
