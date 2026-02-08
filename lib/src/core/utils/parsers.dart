class Parsers {
  // "159300" (String) -> 159300 (int)
  static int parsePrice(dynamic price) =>
      price is String ? int.parse(price) : (price as int);

  // "-5.80" (String) -> -5.80 (double)
  static double parseRate(dynamic rate) =>
      rate is String ? double.parse(rate) : (rate as double);

  static int parseStringToInt(dynamic value) {
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return value as int? ?? 0;
  }

  static double parseStringToDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return value as double? ?? 0.0;
  }

  static double parseDoubleToPercent(double value) {
    return (value / 100).clamp(0.0, 1.0);
  }
}
