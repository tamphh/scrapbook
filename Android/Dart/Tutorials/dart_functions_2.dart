add(int x, int y) {
  return x + y;
}

subtract(int x, int y) {
  return x - y;
}

Function calculation(String op) {
  if (op == '+') return add;
  if (op == '-') return subtract;
  return add;
}

void main() {
  var fn = calculation('+');
  print(fn(10, 20));

  fn = calculation('-');
  print(fn(30, 20));
}