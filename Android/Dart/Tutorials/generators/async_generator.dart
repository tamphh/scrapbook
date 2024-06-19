import 'dart:async';

Stream<int> range(int start, int end) async* {
  for (var i = start; i < end; i++) {
    await Future.delayed(Duration(seconds: 2));
    yield await i;
  }
}

Future<void> main() async {
  var stream = range(1, 5);
  stream.listen((n) => print(n));
}