void main() {
  var price = 10;
  var tax = 0.08;
  var message = 'The price with tax is ${price + price * tax}';

  print(message);

  var sql = '''select phone
    from phone_books
    where name = ?
  ''';
  print(sql);
}