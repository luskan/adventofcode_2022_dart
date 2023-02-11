class Point {
  int x;
  int y;

  Point(this.x, this.y);

  Point.clone(Point point): this(point.x, point.y);

  @override
  bool operator ==(dynamic other) {
    return x == other.x && y == other.y;
  }

  @override
  int get hashCode => x^y;

}

final int maxInt = (double.infinity is int) ? double.infinity as int : ~minInt;
final int minInt = (double.infinity is int) ? -double.infinity as int : (-1 << 63);