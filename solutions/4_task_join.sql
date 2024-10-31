-- Данные на Партизана (включая вид животного). Без JOIN
SELECT P.Nick, T.Name
FROM Pet P,
     Pet_Type T
WHERE P.Pet_Type_Id = T.Pet_Type_Id
  AND P.Nick = 'Partizan';

-- +--------+----+
-- |nick    |name|
-- +--------+----+
-- |Partizan|CAT |
-- +--------+----+


-- Список всех собак с кличками, породой и возрастом. Без JOIN
SELECT P.Nick, P.Breed, P.Age
FROM Pet P,
     Pet_Type T
WHERE P.Pet_Type_Id = T.Pet_Type_Id
  AND T.Name = 'DOG';


-- +-------+-------+---+
-- |nick   |breed  |age|
-- +-------+-------+---+
-- |Bobik  |unknown|3  |
-- |Apelsin|poodle |5  |
-- |Daniel |spaniel|14 |
-- |Markiz |poodle |1  |
-- +-------+-------+---+


-- Средний возраст кошек. Без JOIN
SELECT AVG(P.Age)
FROM Pet P,
     Pet_Type T
WHERE P.Pet_Type_Id = T.Pet_Type_Id
  AND T.Name = 'CAT';

-- +---+
-- |avg|
-- +---+
-- |6.6|
-- +---+



--Время и исполнители невыполненных заказов. Без JOIN
SELECT O.Time_Order, P.Last_Name
FROM Order1 O,
     Employee E,
     Person P
WHERE O.Employee_Id = E.Employee_Id
  AND E.Person_Id = P.Person_Id
  AND O.Is_Done != 1;

-- +--------------------------+---------+
-- |time_order                |last_name|
-- +--------------------------+---------+
-- |2023-09-19 18:00:00.000000|Orlov    |
-- |2023-09-20 10:00:00.000000|Vorobiev |
-- |2023-09-20 11:00:00.000000|Vorobiev |
-- |2023-09-22 10:00:00.000000|Vorobiev |
-- |2023-09-23 10:00:00.000000|Vorobiev |
-- |2023-10-01 11:00:00.000000|Ivanov   |
-- |2023-10-02 11:00:00.000000|Ivanov   |
-- |2023-10-03 16:00:00.000000|Orlov    |
-- +--------------------------+---------+

-- Список хозяев собак (имя, фамилия, телефон). C JOIN
SELECT P.First_Name, P.Last_Name, P.Phone
FROM Pet
         JOIN Owner ON Pet.Owner_Id = Owner.Owner_Id
         JOIN Pet_Type T ON Pet.Pet_Type_Id = T.Pet_Type_Id
         JOIN Person P ON Owner.Person_Id = P.Person_Id
WHERE T.Name = 'DOG';

-- +----------+---------+------------+
-- |first_name|last_name|phone       |
-- +----------+---------+------------+
-- |Petia     |Petrov   |+79234567890|
-- |Vasia     |Vasiliev |+7345678901 |
-- |Galia     |Galkina  |+7567890123 |
-- |Vano      |Ivanov   |+7789012345 |
-- +----------+---------+------------+


--  Все виды питомцев и клички представителей этих видов (внешнее соединение). C Left JOIN
SELECT T.Name, P.Nick
FROM Pet_Type T
         LEFT JOIN Pet P ON T.Pet_Type_Id = P.Pet_Type_Id
ORDER BY T.Name;

-- +----+--------+
-- |name|nick    |
-- +----+--------+
-- |CAT |Musia   |
-- |CAT |Zombi   |
-- |CAT |Las     |
-- |CAT |Partizan|
-- |CAT |Katok   |
-- |COW |Model   |
-- |DOG |Bobik   |
-- |DOG |Apelsin |
-- |DOG |Daniel  |
-- |DOG |Markiz  |
-- |FISH|null    |
-- +----+--------+



-- Сколько имеется котов, собак и т.д. в возрасте 1 год, 2 года, и т.д. С JOIN
SELECT P.Age, T.Name, COUNT(*)
FROM Pet P
         JOIN Pet_Type T ON P.Pet_Type_Id = T.Pet_Type_Id
GROUP BY P.Age, T.Name
ORDER BY P.Age, T.Name;

-- +---+----+-----+
-- |age|name|count|
-- +---+----+-----+
-- |1  |DOG |1    |
-- |2  |CAT |1    |
-- |3  |DOG |1    |
-- |5  |CAT |1    |
-- |5  |COW |1    |
-- |5  |DOG |1    |
-- |7  |CAT |2    |
-- |12 |CAT |1    |
-- |14 |DOG |1    |
-- +---+----+-----+


--  Фамилии сотрудников, выполнивших более трех заказов. С JOIN
SELECT P.Last_Name, COUNT(*) AS Count_Of_Orders
FROM Person P
         JOIN Employee E ON P.Person_Id = E.Person_Id
         JOIN Order1 O ON E.Employee_Id = O.Employee_Id
WHERE O.Is_Done = 1
GROUP BY P.Last_Name
HAVING COUNT(*) > 3;

-- +---------+---------------+
-- |last_name|count_of_orders|
-- +---------+---------------+
-- |Vorobiev |11             |
-- +---------+---------------+


-- Придумайте какой-нибудь осмысленный запрос про прививки, в котором задействованы не менее четырех таблиц базы данных.
-- Не забудьте добавить текстовую формулировку.
--
-- Формулировка: Выведите уникальные имена людей, у которых есть животные с прививкой Rabies
SELECT DISTINCT P.Last_Name, P.First_Name
FROM Person P
JOIN Owner O ON P.Person_Id = O.Person_Id
JOIN Pet P2 ON O.Owner_Id = P2.Owner_Id
JOIN Vaccination V ON P2.Pet_Id = V.Pet_Id
JOIN Vaccination_Type T ON V.Vaccination_Type_Id = T.Vaccination_Type_Id
WHERE T.Name = 'Rabies';

-- +---------+----------+
-- |last_name|first_name|
-- +---------+----------+
-- |Petrov   |Petia     |
-- +---------+----------+
