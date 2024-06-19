import 'dart:io';

Future<void> main() async {
  try {
    var file = File('hello_world.dart');
    print(file.absolute.path);
    var contents = await file.readAsString();
    print(contents);
  } on FileSystemException catch (e) {
    print(e);
  }
}