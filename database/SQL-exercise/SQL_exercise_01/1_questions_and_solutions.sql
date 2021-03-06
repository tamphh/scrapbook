-- LINK: https://en.wikibooks.org/wiki/SQL_Exercises/The_computer_store

-- 1.1 Select the names of all the products in the store.
SELECT 
  Name 
FROM 
  Products;
  
-- 1.2 Select the names and the prices of all the products in the store.
SELECT 
  Name, 
  Price 
FROM 
  Products;
  
-- 1.3 Select the name of the products with a price less than or equal to $200.
SELECT 
  Name 
FROM 
  Products 
WHERE 
  price <= 200;
  
-- 1.4 Select all the products with a price between $60 and $120.
SELECT 
  * 
FROM 
  Products 
WHERE 
  price BETWEEN 60 
  AND 120;
  
-- 1.5 Select the name and price in cents (i.e., the price must be multiplied by 100).
SELECT 
  Name, 
  (price * 100) Price_in_cents 
FROM 
  Products;
  
-- 1.6 Compute the average price of all the products.
SELECT 
  avg(price) 
FROM 
  Products;
  
-- 1.7 Compute the average price of all products with manufacturer code equal to 2.
SELECT 
  avg(price) 
FROM 
  Products 
WHERE 
  Manufacturer = 2;
  
-- 1.8 Compute the number of products with a price larger than or equal to $180.
SELECT 
  *, 
  count(*) 
FROM 
  Products 
WHERE 
  Price >= 180;
  
-- 1.9 Select the name and price of all products with a price larger than or equal to $180, and sort first by price (in descending order), and then by name (in ascending order).
SELECT 
  Name, 
  Price 
FROM 
  Products 
WHERE 
  price >= 180 
ORDER BY 
  Price DESC, 
  Name ASC;
  
-- 1.10 Select all the data from the products, including all the data for each product's manufacturer.
SELECT 
  * 
FROM 
  Products p 
  INNER JOIN Manufacturers m ON m.code = p.Manufacturer;
  
-- 1.11 Select the product name, price, and manufacturer name of all the products.
SELECT 
  p.Name, 
  p.Price, 
  m.name Manufacturer_Name 
FROM 
  Products p 
  INNER JOIN Manufacturers m ON m.code = p.Manufacturer;
  
-- 1.12 Select the average price of each manufacturer's products, showing only the manufacturer's code.
SELECT 
  Manufacturer, 
  avg(Price) Average_Price 
FROM 
  Products 
GROUP BY 
  Manufacturer;
  
-- 1.13 Select the average price of each manufacturer's products, showing the manufacturer's name.
SELECT 
  m.Name Manufacturer_Name, 
  avg(p.Price) Average_Price 
FROM 
  Products p 
  INNER JOIN Manufacturers m ON m.code = p.Manufacturer 
GROUP BY 
  m.code;
  
-- 1.14 Select the names of manufacturer whose products have an average price larger than or equal to $150.
SELECT 
  m.Name Manufacturer_Name, 
  avg(p.Price) Average_Price 
FROM 
  Products p 
  INNER JOIN Manufacturers m ON m.code = p.Manufacturer 
GROUP BY 
  m.code 
HAVING 
  Average_Price >= 150;
  
-- 1.15 Select the name and price of the cheapest product.
-- #S1
SELECT 
  Name, 
  Price 
FROM 
  Products 
ORDER BY 
  Price ASC 
LIMIT 
  1;
-- #S2
SELECT 
  name, 
  price 
FROM 
  Products 
WHERE 
  price = (
    SELECT 
      min(price) 
    FROM 
      products
  );
  
-- 1.16 Select the name of each manufacturer along with the name and price of its most expensive product.
SELECT 
  max_price_mapping.Manufacturer_Name, 
  Products.Name, 
  max_price_mapping.Price 
FROM 
  (
    SELECT 
      m.Name Manufacturer_Name, 
      p.Name Product_Name, 
      max(p.Price) Price, 
      m.code Manufacturer_Code 
    FROM 
      Products p 
      INNER JOIN Manufacturers m ON m.code = p.Manufacturer 
    GROUP BY 
      m.code
  ) AS max_price_mapping 
  LEFT JOIN Products ON Products.Manufacturer = max_price_mapping.Manufacturer_Code 
  AND Products.Price = max_price_mapping.Price 
ORDER BY 
  max_price_mapping.Price;

-- 1.17 Add a new product: Loudspeakers, $70, manufacturer 2.
INSERT INTO Products(Code, Name, Price, Manufacturer) 
VALUES 
  (11, 'Loudspeakers', 70, 2);
  
-- 1.18 Update the name of product 8 to "Laser Printer".
UPDATE 
  Products 
SET 
  Name = 'Laser Printer' 
WHERE 
  code = 8;
  
-- 1.19 Apply a 10% discount to all products.
UPDATE 
  Products 
SET 
  Price = Price * 0.9;
  
-- 1.20 Apply a 10% discount to all products with a price larger than or equal to $120.
UPDATE 
  Products 
SET 
  Price = Price * 0.9 
WHERE 
  Price >= 120;
