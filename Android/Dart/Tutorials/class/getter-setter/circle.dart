class Circle {
  double _radius = 0;

  Circle(double radius) {
    this._radius = radius;
  }

  set radius(double value) {
    if (value >= 0) {
      _radius = value;
    }
  }

  double get radius => _radius;

  // Computed property
  get area => _radius * _radius * 3.14;

  @override
  String toString() {
    return 'Circle -> radius = $_radius, area = $area';
  }
}