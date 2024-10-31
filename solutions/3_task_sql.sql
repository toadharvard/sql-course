-- Данные на Партизана
SELECT *
FROM Pet
WHERE Nick = 'Partizan';

-- +------+--------+-------+---+-----------+-----------+--------+
-- |pet_id|nick    |breed  |age|description|pet_type_id|owner_id|
-- +------+--------+-------+---+-----------+-----------+--------+
-- |5     |Partizan|Siamese|5  |very big   |2          |2       |
-- +------+--------+-------+---+-----------+-----------+--------+


-- Клички и породы всех питомцев с сортировкой по возрасту.
SELECT P.Nick, P.Breed, P.Age
FROM Pet P
ORDER BY P.Age;


-- +--------+-------+---+
-- |nick    |breed  |age|
-- +--------+-------+---+
-- |Markiz  |poodle |1  |
-- |Katok   |null   |2  |
-- |Bobik   |unknown|3  |
-- |Model   |null   |5  |
-- |Apelsin |poodle |5  |
-- |Partizan|Siamese|5  |
-- |Las     |Siamese|7  |
-- |Zombi   |unknown|7  |
-- |Musia   |null   |12 |
-- |Daniel  |spaniel|14 |
-- +--------+-------+---+


-- Питомцы, имеющие хоть какое-нибудь описание.
SELECT P.Nick, P.Description
FROM Pet P
WHERE P.Description <> '';

-- +--------+-----------+
-- |nick    |description|
-- +--------+-----------+
-- |Katok   |crazy guy  |
-- |Partizan|very big   |
-- |Zombi   |wild       |
-- +--------+-----------+


-- Средний возраст пуделей.
SELECT AVG(Age)
FROM Pet
WHERE Pet.Breed = 'poodle';


-- +---+
-- |avg|
-- +---+
-- |3  |
-- +---+


-- Количество владельцев.
SELECT COUNT(DISTINCT Owner_Id)
FROM Pet;

-- +-----+
-- |count|
-- +-----+
-- |6    |
-- +-----+


-- Сколько имеется питомцев каждой породы.
SELECT Breed, COUNT(Pet_Id)
FROM Pet
GROUP BY Breed
ORDER BY COUNT(Pet_Id);

-- +-------+-----+
-- |breed  |count|
-- +-------+-----+
-- |spaniel|1    |
-- |poodle |2    |
-- |Siamese|2    |
-- |unknown|2    |
-- |null   |3    |
-- +-------+-----+


-- Сколько имеется питомцев каждой породы (если только один - не показывать эту породу).
SELECT Breed, COUNT(Pet_Id)
FROM Pet
GROUP BY Breed
HAVING COUNT(Pet_Id) > 1
ORDER BY COUNT(Pet_Id);

-- +-------+-----+
-- |breed  |count|
-- +-------+-----+
-- |poodle |2    |
-- |Siamese|2    |
-- |unknown|2    |
-- |null   |3    |
-- +-------+-----+


-- запрос с BETWEEN.
--
-- Ники питомцев, количество посещений с этим ником и время последнего посещения в период с 2020-01-01 по 2023-06-01
SELECT P.Nick, COUNT(P.Pet_Id) AS Pet_Count, MAX(V.Vaccination_Date) AS Last_Vaccination_Date
FROM Pet P
         JOIN Vaccination V ON P.Pet_Id = V.Pet_Id
WHERE V.Vaccination_Date BETWEEN '2020-01-01' AND '2023-06-01'
GROUP BY P.Nick;

-- +-----+---------+---------------------+
-- |nick |pet_count|last_vaccination_date|
-- +-----+---------+---------------------+
-- |Bobik|2        |2023-01-15           |
-- |Katok|1        |2022-11-01           |
-- |Musia|2        |2022-12-15           |
-- +-----+---------+---------------------+


-- запрос с LIKE. Все люди, имена которых начинаются с V
SELECT *
FROM Person
WHERE Person.First_Name LIKE 'V%';
-- +---------+---------+----------+------------+------------------------+
-- |person_id|last_name|first_name|phone       |address                 |
-- +---------+---------+----------+------------+------------------------+
-- |1        |Ivanov   |Vania     |+79123456789|Srednii pr VO, 34-2     |
-- |3        |Vasiliev |Vasia     |+7345678901 |Nevskii pr, 9-11        |
-- |7        |Vorobiev |Vova      |123-45-67   |Universitetskaia nab, 17|
-- |8        |Ivanov   |Vano      |+7789012345 |Malyi pr VO, 33-2       |
-- +---------+---------+----------+------------+------------------------+


-- запрос с IN(...)      (без вложенного select)
-- Фамилия и имя каждого сотрудника, кто является hairdresser или student
SELECT Last_Name, First_Name, Spec
FROM Person
         JOIN Employee ON Person.Person_Id = Employee.Person_Id
WHERE Spec IN ('hairdresser', 'student');

-- +---------+----------+-----------+
-- |last_name|first_name|spec       |
-- +---------+----------+-----------+
-- |Orlov    |Oleg      |hairdresser|
-- |Vorobiev |Vova      |student    |
-- |Zotov    |Misha     |student    |
-- +---------+----------+-----------+
