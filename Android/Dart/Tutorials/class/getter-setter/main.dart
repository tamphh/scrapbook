import 'circle.dart';

void main() {
  var circle = Circle(22);
  print(circle);

  circle.radius = 33;
  print(circle);
  print('The area is ${circle.area}');
}