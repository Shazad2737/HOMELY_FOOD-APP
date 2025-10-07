import 'package:core/src/utils/string_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringX', () {
    test('capitalize', () {
      expect(''.capitalize(), equals(''));
      expect('a'.capitalize(), equals('A'));
      expect('abc'.capitalize(), equals('Abc'));
      expect('ABC'.capitalize(), equals('ABC'));
      expect('aBc'.capitalize(), equals('ABc'));
    });
    group('capitalizeAllWords', () {
      test('should capitalize the first letter of each word', () {
        expect('hello world'.toTitleCase(), 'Hello World');
      });

      test('should handle empty strings gracefully', () {
        expect(''.toTitleCase(), '');
      });

      test('should trim leading and trailing spaces', () {
        expect('  hello world  '.toTitleCase(), 'Hello World');
      });

      test('should lowercase the rest of each word', () {
        expect('HELLO WORLD'.toTitleCase(), 'Hello World');
      });

      test('should handle multiple spaces between words', () {
        expect('hello   world'.toTitleCase(), 'Hello   World');
      });

      test('should handle strings with punctuation', () {
        expect('hello, world!'.toTitleCase(), 'Hello, World!');
      });

      test('should process hyphenated words as separate words', () {
        expect('hello-world'.toTitleCase(), 'Hello-World');
      });

      test('should work with a single character', () {
        expect('h'.toTitleCase(), 'H');
      });

      test('should work with numbers within the string', () {
        expect(
          'hello world 2 times'.toTitleCase(),
          'Hello World 2 Times',
        );
      });

      test('should handle non-ascii characters correctly', () {
        expect('élan vital'.toTitleCase(), 'Élan Vital');
      });
    });
  });
}
