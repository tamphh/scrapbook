void main() {
  var numbers = [2, 1, 7, 4, 9];
  // var results = <int>[];
  // for (var number in numbers) {
  //   if (number > 5) {
  //     results.add(number);
  //   }
  // }
  var results = numbers.where((number) => number > 5).toList();

  print(results);
}