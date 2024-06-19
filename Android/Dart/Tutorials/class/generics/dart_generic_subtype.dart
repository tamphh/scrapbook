abstract class Shape {
  double get area;
}

class Circle extends Shape {
  double radius;

  Circle({required this.radius});

  @override
  double get area => 3.14 * radius * radius;
}

class Square extends Shape {
  double length;

  Square({required this.length});

  @override
  double get area => length * length;
}

class Region<T extends Shape> {
  List<T> shapes;

  Region({required this.shapes});

  double get area {
    double totalArea = 0;
    for (var shape in shapes) {
      totalArea += shape.area;
    }

    return totalArea;
  }
}

void main() {
  var region = Region(
    shapes: [
      Circle(radius: 10),
      Square(length: 10),
      Square(length: 10)
    ]
  );

  print(region.area);
}