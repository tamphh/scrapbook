void main() {
  var multiplier = (int x) {
    return (int y) {
      return x * y;
    };
  };

  var doubleIt = multiplier(2);
  print(doubleIt(10));

  print(multiplier(3)(10));
}