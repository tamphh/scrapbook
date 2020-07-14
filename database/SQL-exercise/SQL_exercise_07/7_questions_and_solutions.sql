-- https://en.wikibooks.org/wiki/SQL_Exercises/Planet_Express 
-- 7.1 Who receieved a 1.5kg package?
    -- The result is "Al Gore's Head".
   select * from Client
    where AccountNumber = (
      select Recipient from Package where Weight=1.5
    )
-- 7.2 What is the total weight of all the packages that he sent?
  select sum(p.Weight) from Package p
  where p.Recipient = (
    select Recipient from Package where Weight=1.5
  )
  group by p.Recipient;

  select c.*, sum(p.Weight) from Package p
  inner join
    (
      select Recipient from Package where Weight=1.5
    ) as tmp
    on tmp.Recipient = p.Sender
  inner join Client c
    on c.AccountNumber = tmp.Recipient
  group by p.Sender;

  select c.*, sum(p.Weight) from Package p
  inner join Client c
    on c.AccountNumber = p.Sender
  where p.Sender = (
    select Recipient from Package where Weight=1.5
  )
  group by p.Sender;

  SELECT SUM(p.weight), COUNT(1)
  FROM Client AS c
    JOIN Package as P
    ON c.AccountNumber = p.Sender
  WHERE c.AccountNumber = (
    SELECT Client.AccountNumber
    FROM Client JOIN Package
      ON Client.AccountNumber = Package.Recipient
    WHERE Package.weight = 1.5
  );
-- 7.3 Which pilots transported those packages?
