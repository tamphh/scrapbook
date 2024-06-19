void main() {
  var inputs = ['1.24', '2.35', '4.56', 'abc'];
  // var numbers = inputs.map((n) => double.tryParse(n)).where((e) => e != null);
  var numbers = inputs.map(double.tryParse).where((e) => e != null).toList();

  print(numbers);
}