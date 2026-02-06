class Parsers {
  // "159300" (String) -> 159300 (int)
  static int parsePrice(dynamic price) =>
      price is String ? int.parse(price) : (price as int);

  // "-5.80" (String) -> -5.80 (double)
  static double parseRate(dynamic rate) =>
      rate is String ? double.parse(rate) : (rate as double);
}
