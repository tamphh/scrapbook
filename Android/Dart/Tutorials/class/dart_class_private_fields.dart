class Point {
  int _x = 0;
  int _y = 0;

  Point({int x = 0, int y = 0}) {
    this._x = x;
    this._y = y;
  }

  show() {
    print('Point(x=$_x, y=$_y)');
  }
}

void main() {
  var p = Point(x: 10, y: 20);
  p.show();

/*
  Code language: Dart (dart)
The code works in a way that you may not expect because _x and _y fields are supposed to be private.

In Dart, privacy is at the library level rather than the class level. Adding an underscore to a variable makes it library private not class private.

For now, you can understand that a library is simply a Dart file. Because both the Point class and the main() function are on the same file, they’re in the same library. Therefore, the main() function can access the private fields of the Point class.

To prevent other functions from accessing the private fields of the Point class, you need to create a new library and place the class in it.

ref: https://www.darttutorial.org/dart-tutorial/dart-private-fields/
*/
  p._x = 100;
  p._y = 200;
  p.show();
}