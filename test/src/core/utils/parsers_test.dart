import 'package:flutter_test/flutter_test.dart';
import 'package:lucy_assignment/src/core/utils/parsers.dart';

void main() {
  group('Parsers', () {
    group('parsePrice', () {
      test('should parse valid String integer', () {
        expect(Parsers.parsePrice('159300'), 159300);
        expect(Parsers.parsePrice('-500'), -500);
      });

      test('should return int when input is already int', () {
        expect(Parsers.parsePrice(12345), 12345);
      });

      test('should throw FormatException for invalid String', () {
        expect(() => Parsers.parsePrice('invalid'), throwsFormatException);
      });

      test(
        'should throw CastError (or TypeError) for non-String, non-int input',
        () {
          // dynamic cast to int fails for double
          expect(() => Parsers.parsePrice(12.5), throwsA(isA<TypeError>()));
        },
      );
    });

    group('parseRate', () {
      test('should parse valid String double', () {
        expect(Parsers.parseRate('10.5'), 10.5);
        expect(Parsers.parseRate('-5.80'), -5.80);
      });

      test('should return double when input is already double', () {
        expect(Parsers.parseRate(3.14), 3.14);
      });

      test('should throw FormatException for invalid String', () {
        expect(() => Parsers.parseRate('invalid'), throwsFormatException);
      });
    });

    group('parseStringToInt', () {
      test('should parse valid String to int', () {
        expect(Parsers.parseStringToInt('100'), 100);
      });

      test('should return 0 for invalid String', () {
        expect(Parsers.parseStringToInt('abc'), 0);
      });

      test('should return value if it is int', () {
        expect(Parsers.parseStringToInt(50), 50);
      });

      test('should return truncated int for double input', () {
        expect(Parsers.parseStringToInt(12.34), 12);
      });

      test('should return 0 for null', () {
        expect(Parsers.parseStringToInt(null), 0);
      });
    });

    group('parseStringToDouble', () {
      test('should parse valid String to double', () {
        expect(Parsers.parseStringToDouble('12.34'), 12.34);
      });

      test('should return 0.0 for invalid String', () {
        expect(Parsers.parseStringToDouble('xyz'), 0.0);
      });

      test('should return value if it is double', () {
        expect(Parsers.parseStringToDouble(5.67), 5.67);
      });

      test('should convert int to double', () {
        expect(Parsers.parseStringToDouble(100), 100.0);
      });

      test('should return 0.0 for null', () {
        expect(Parsers.parseStringToDouble(null), 0.0);
      });
    });

    group('parseDoubleToPercent', () {
      test('should convert and clamp value', () {
        expect(Parsers.parseDoubleToPercent(50.0), 0.5);
        expect(Parsers.parseDoubleToPercent(0.0), 0.0);
        expect(Parsers.parseDoubleToPercent(100.0), 1.0);
      });

      test('should clamp negative values to 0.0', () {
        expect(Parsers.parseDoubleToPercent(-10.0), 0.0);
      });

      test('should clamp values > 100 to 1.0', () {
        expect(Parsers.parseDoubleToPercent(150.0), 1.0);
      });
    });
  });
}
