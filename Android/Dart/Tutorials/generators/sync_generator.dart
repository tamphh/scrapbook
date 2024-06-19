Iterable<int> range(int start, int end) sync* {
  for (var i = start; i < end; i++) {
    yield i;
  }
}

void main() {
  var numbers = range(1, 5);
  for (var number in numbers) {
    print(number);
  }
}