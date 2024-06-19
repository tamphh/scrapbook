import 'dart:async';

class Number {
  Number() {
    Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        _controller.sink.add(_count);
        _count++;
      }
    );
  }

  final _controller = StreamController<int>();
  var _count = 1;

  Stream<int> get stream => _controller.stream;
}

void main() {
  var stream = Number().stream;

  var subscription = stream.listen(
    (event) => print(event)
  );
}