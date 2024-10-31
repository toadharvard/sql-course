-- Создайте представление “Собаки” со следующими атрибутами:
-- кличка, порода, возраст, фамилия и имя хозяина.
-- Используя это представление, получите список пуделей: кличка, фамилия хозяина.

-- PS: пока писал запросы, обнаружил, что можно использовать русские символы. В духе:
-- CREATE OR REPLACE VIEW Собаки AS
-- SELECT
--     p.Nick AS Кличка,
--     p.Breed AS Порода,
--     p.Age AS Возраст,
--     per.Last_Name AS Фамилия_Хозяина,
--     per.First_Name AS Имя_Хозяина
-- FROM
--     Pet p
-- JOIN
--     Owner o ON p.Owner_Id = o.Owner_Id
-- JOIN
--     Person per ON o.Person_Id = per.Person_Id;
-- После создания этого представления можно получить кличку и фамилию хозяина пуделей:
--
-- SELECT
--     Кличка, Фамилия_Хозяина
-- FROM
--     Собаки
-- WHERE
--     Порода = 'poodle';
--
-- Забавно.

CREATE OR REPLACE VIEW Dogs AS
SELECT
    p.Nick AS Nickname,
    p.Breed AS Breed,
    p.Age AS Age,
    per.Last_Name AS Owner_Last_Name,
    per.First_Name AS Owner_First_Name
FROM
    Pet p
JOIN
    Owner o ON p.Owner_Id = o.Owner_Id
JOIN
    Person per ON o.Person_Id = per.Person_Id;

SELECT
    Nickname, Owner_Last_Name
FROM
    Dogs
WHERE
    Breed = 'poodle';

-- +--------+---------------+
-- |nickname|owner_last_name|
-- +--------+---------------+
-- |Apelsin |Vasiliev       |
-- |Markiz  |Ivanov         |
-- +--------+---------------+



-- Создайте представление “Рейтинг сотрудников”: фамилия, имя, количество выполненных заказов,
-- средний балл (по оценке).
-- Используя это представление, выведите рейтинг с сортировкой по убыванию балла.

CREATE OR REPLACE VIEW Employee_Rating AS
SELECT
    p.Last_Name AS Last_Name,
    p.First_Name AS First_Name,
    COUNT(o.Order_Id) AS Completed_Orders,
    AVG(o.Mark) AS Average_Rating
FROM
    Employee e
JOIN
    Person p ON e.Person_Id = p.Person_Id
JOIN
    Order1 o ON e.Employee_Id = o.Employee_Id
WHERE
    o.Is_Done = 1
GROUP BY
    p.Last_Name, p.First_Name;

SELECT
    Last_Name, First_Name, Completed_Orders, Average_Rating
FROM
    Employee_Rating
ORDER BY
    Average_Rating DESC;

-- +---------+----------+----------------+------------------+
-- |last_name|first_name|completed_orders|average_rating    |
-- +---------+----------+----------------+------------------+
-- |Ivanov   |Vania     |1               |5                 |
-- |Orlov    |Oleg      |3               |4.3333333333333333|
-- |Vorobiev |Vova      |11              |4.2727272727272727|
-- +---------+----------+----------------+------------------+


-- Создайте представление “Заказчики”: фамилия, имя, телефон, адрес. Используя это представление, напишите оператор,
-- после выполнения которого у всех заказчиков без адреса в это поле добавится вопросительный знак.
CREATE OR REPLACE VIEW Customers AS
SELECT
    p.Last_Name AS Last_Name,
    p.First_Name AS First_Name,
    p.Phone AS Phone,
    p.Address AS Address
FROM
    Owner o
JOIN
    Person p ON o.Person_Id = p.Person_Id;

-- Простой запрос с заменой пустых адресов на '?'
SELECT
    Last_Name,
    First_Name,
    Phone,
    CASE
        WHEN Address = '' THEN '?'
        ELSE Address
    END AS Address
FROM
    Customers;

-- +---------+----------+------------+--------------------+
-- |last_name|first_name|phone       |address             |
-- +---------+----------+------------+--------------------+
-- |Petrov   |Petia     |+79234567890|Sadovaia ul, 17\2-23|
-- |Vasiliev |Vasia     |+7345678901 |Nevskii pr, 9-11    |
-- |Galkina  |Galia     |+7567890123 |10 linia VO, 35-26  |
-- |Sokolov  |S.        |+7678901234 |Srednii pr VO, 27-1 |
-- |Ivanov   |Vano      |+7789012345 |Malyi pr VO, 33-2   |
-- |Sokolova |Sveta     |234-56-78   |?                   |
-- +---------+----------+------------+--------------------+


-- Вообще говоря, PostgresQL не умеет редактировать VIEW с JOIN
-- UPDATE Customers
-- SET Address = '?'
-- WHERE Address = '';

-- [55000] ERROR: cannot update view "customers"
-- Detail: Views that do not select from a single table or view are not automatically updatable.
-- Hint: To enable updating the view, provide an INSTEAD OF UPDATE trigger or an unconditional ON UPDATE DO INSTEAD rule.


-- Есть два подхода — триггеры или однотабличные простые представления (в них можно)

-- Добавим Person_Id для триггера во VIEW
DROP VIEW IF EXISTS Customers CASCADE;
CREATE OR REPLACE VIEW Customers AS
SELECT
    p.Person_Id as Person_Id,
    p.Last_Name AS Last_Name,
    p.First_Name AS First_Name,
    p.Phone AS Phone,
    p.Address AS Address
FROM
    Owner o
JOIN
    Person p ON o.Person_Id = p.Person_Id;

CREATE OR REPLACE FUNCTION update_customers()
RETURNS TRIGGER AS
$$
BEGIN
    UPDATE Person
    -- Возможно, тут нужно добавить проверку, что '' меняется на '?'
    SET Address = NEW.Address
    WHERE Person_Id = NEW.Person_Id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER instead_of_update_customers
INSTEAD OF UPDATE ON Customers
FOR EACH ROW
EXECUTE FUNCTION update_customers();

UPDATE Customers
SET Address = '?'
WHERE Address = '';

-- Таблица Person
-- +---------+---------+----------+------------+------------------------+
-- |person_id|last_name|first_name|phone       |address                 |
-- +---------+---------+----------+------------+------------------------+
-- |1        |Ivanov   |Vania     |+79123456789|Srednii pr VO, 34-2     |
-- |2        |Petrov   |Petia     |+79234567890|Sadovaia ul, 17\2-23    |
-- |3        |Vasiliev |Vasia     |+7345678901 |Nevskii pr, 9-11        |
-- |4        |Orlov    |Oleg      |+7456789012 |5 linia VO, 45-8        |
-- |5        |Galkina  |Galia     |+7567890123 |10 linia VO, 35-26      |
-- |6        |Sokolov  |S.        |+7678901234 |Srednii pr VO, 27-1     |
-- |7        |Vorobiev |Vova      |123-45-67   |Universitetskaia nab, 17|
-- |8        |Ivanov   |Vano      |+7789012345 |Malyi pr VO, 33-2       |
-- |10       |Zotov    |Misha     |111-56-22   |                        |
-- |9        |Sokolova |Sveta     |234-56-78   |?                       |
-- +---------+---------+----------+------------+------------------------+
