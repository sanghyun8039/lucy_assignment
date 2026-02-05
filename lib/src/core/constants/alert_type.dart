enum AlertType {
  upperLimit('상한가'),
  lowerLimit('하한가'),
  bidirectional('양방향');

  final String name;
  const AlertType(this.name);
}
