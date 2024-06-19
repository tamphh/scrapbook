extension on String {
  String capitalize() => '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}';
}

void main() {
  print('hello'.capitalize());
}