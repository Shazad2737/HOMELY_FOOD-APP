import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateUtils', () {
    test('getFormattedTimeOnly returns formatted time', () {
      // Arrange
      final date =
          DateTime(2022, 1, 1, 14, 30); // Replace with your desired date

      // Act
      final formattedTime = AppDateUtils.getFormattedTimeOnly(date);

      // Assert
      expect(formattedTime, '10:30');
    });
  });
}
