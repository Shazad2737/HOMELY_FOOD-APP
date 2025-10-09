import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('shows label and does not shift layout when loading',
        (tester) async {
      const label = 'Continue';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.standard,
          home: Scaffold(
            body: Center(
              child: PrimaryButton(
                text: label,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final initial = tester.getSize(find.byType(PrimaryButton));
      expect(find.text(label), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.standard,
          home: Scaffold(
            body: Center(
              child: PrimaryButton(
                text: label,
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      final loading = tester.getSize(find.byType(PrimaryButton));
      expect(loading, equals(initial));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
