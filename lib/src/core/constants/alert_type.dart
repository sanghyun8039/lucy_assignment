enum AlertType {
    UpperLimit('상한가'),
    LowerLimit('하한가'),
    Bidirectional('양방향');

    final String name;
    const AlertType(this.name);
}