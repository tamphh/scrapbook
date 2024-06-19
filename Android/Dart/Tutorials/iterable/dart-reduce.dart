void main() {
  var numbers = [1, 2, 3, 4, 5];
  var sum = numbers.reduce((value, element) {
    var result = value + element;
    print('value = $value element=$element result=$result');
    
    return result;
  });

  print(sum);
}