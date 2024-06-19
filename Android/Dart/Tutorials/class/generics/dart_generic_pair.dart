class Pair<T> {
  T x;
  T y;
  Pair(this.x, this.y);
}

void main() {
  var pairInt = Pair<int>(10, 20);
  print('x=${pairInt.x}, y=${pairInt.y}');

  var pairStr = Pair<String>('abc', 'xyz');
  print('x=${pairStr.x}, y=${pairStr.y}');
}