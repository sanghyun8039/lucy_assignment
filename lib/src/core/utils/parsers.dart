class Parsers {
  static int parsePrice(dynamic price) =>
      price is String ? int.parse(price) : (price as int);

  static double parseRate(dynamic rate) =>
      rate is String ? double.parse(rate) : (rate as double);

  static int parseStringToInt(dynamic value) {
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  static double parseStringToDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  static double parseDoubleToPercent(double value) {
    return (value / 100).clamp(0.0, 1.0);
  }
}
