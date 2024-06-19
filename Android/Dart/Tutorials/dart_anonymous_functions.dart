void show(fn) {
  for (var i = 0; i < 10; i++) {
    if (fn(i)) {
      print(i);
    }
  }
}

void main() {
  print("Even numbers:");
  // short form
  show((int x) { return x % 2 == 0; });

  print("Odd numbers:");
  // long form
  var isOddNumber = (int x) { return x % 2 != 0; };
  show(isOddNumber);
}