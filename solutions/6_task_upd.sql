-- Напишите оператор, добавляющий пометку “(s)” в начало комментария по каждому заказу,
-- исполнитель которого – студент. Выполните этот оператор.

UPDATE Order1
SET Comments = CONCAT('(s)', Comments)
WHERE Employee_Id IN (SELECT E.Employee_Id
                      FROM Employee E
                      WHERE E.Spec = 'student');
-- +--------+--------+----------+------+-----------+--------------------------+-------+----+------------------+
-- |order_id|owner_id|service_id|pet_id|employee_id|time_order                |is_done|mark|comments          |
-- +--------+--------+----------+------+-----------+--------------------------+-------+----+------------------+
-- |2       |1       |2         |2     |2          |2023-09-11 09:00:00.000000|1      |4   |                  |
-- |3       |1       |2         |3     |2          |2023-09-11 09:00:00.000000|1      |4   |That cat is crazy!|
-- |7       |1       |2         |2     |2          |2023-09-17 18:00:00.000000|1      |5   |                  |
-- |15      |3       |2         |6     |2          |2023-09-19 18:00:00.000000|0      |0   |                  |
-- |20      |4       |3         |7     |1          |2023-09-30 11:00:00.000000|1      |5   |                  |
-- |21      |4       |3         |7     |1          |2023-10-01 11:00:00.000000|0      |0   |null              |
-- |22      |4       |3         |7     |1          |2023-10-02 11:00:00.000000|0      |0   |null              |
-- |23      |5       |2         |8     |2          |2023-10-03 16:00:00.000000|0      |0   |null              |
-- |1       |1       |1         |1     |3          |2023-09-11 08:00:00.000000|1      |5   |(s)               |
-- |4       |1       |1         |1     |3          |2023-09-11 00:00:00.000000|1      |5   |(s)               |
-- |5       |1       |1         |1     |3          |2023-09-16 11:00:00.000000|1      |3   |(s)Comming late   |
-- |6       |1       |1         |1     |3          |2023-09-17 17:00:00.000000|1      |5   |(s)               |
-- |8       |2       |1         |5     |3          |2023-09-17 18:00:00.000000|1      |4   |(s)               |
-- |9       |2       |1         |4     |3          |2023-09-17 10:00:00.000000|1      |4   |(s)               |
-- |10      |2       |1         |5     |3          |2023-09-18 17:00:00.000000|1      |4   |(s)               |
-- |11      |2       |1         |4     |3          |2023-09-18 18:00:00.000000|1      |4   |(s)               |
-- |12      |2       |1         |5     |3          |2023-09-18 12:00:00.000000|1      |4   |(s)               |
-- |13      |2       |1         |4     |3          |2023-09-18 14:00:00.000000|1      |4   |(s)               |
-- |14      |3       |1         |6     |3          |2023-09-19 10:00:00.000000|1      |5   |(s)               |
-- |16      |3       |1         |6     |3          |2023-09-20 10:00:00.000000|0      |0   |(s)               |
-- |17      |3       |1         |6     |3          |2023-09-20 11:00:00.000000|0      |0   |(s)               |
-- |18      |3       |1         |6     |3          |2023-09-22 10:00:00.000000|0      |0   |(s)               |
-- |19      |3       |1         |6     |3          |2023-09-23 10:00:00.000000|0      |0   |(s)               |
-- +--------+--------+----------+------+-----------+--------------------------+-------+----+------------------+

-- Напишите оператор, удаляющий все заказы по combing-у,
-- которые еще не выполнены (“Мы приостанавливаем оказание этой услугу из-за не продления лицензии”).

DELETE
FROM Order1
WHERE Service_Id = (SELECT Service_Id
                    FROM Service
                    WHERE Name = 'Combing')
  AND Is_Done = 0;

-- pet_db.public> DELETE
--                FROM Order1
--                WHERE Service_Id = (SELECT Service_Id
--                                    FROM Service
--                                    WHERE Name = 'Combing')
--                  AND Is_Done = 0
-- [2024-10-31 22:07:41] 2 rows affected in 8 ms

INSERT INTO Person (Person_Id, Last_Name, First_Name, Phone, Address)
VALUES (
    (SELECT COALESCE(MAX(Person_Id), 0) + 1 FROM Person),
    'Yakshigulov',
    'Vadim',
    '88005553535',
    'V Ryazani, gde gribi s glazami'
);
-- +---------+-----------+----------+------------+------------------------------+
-- |person_id|last_name  |first_name|phone       |address                       |
-- +---------+-----------+----------+------------+------------------------------+
-- |1        |Ivanov     |Vania     |+79123456789|Srednii pr VO, 34-2           |
-- |2        |Petrov     |Petia     |+79234567890|Sadovaia ul, 17\2-23          |
-- |3        |Vasiliev   |Vasia     |+7345678901 |Nevskii pr, 9-11              |
-- |4        |Orlov      |Oleg      |+7456789012 |5 linia VO, 45-8              |
-- |5        |Galkina    |Galia     |+7567890123 |10 linia VO, 35-26            |
-- |6        |Sokolov    |S.        |+7678901234 |Srednii pr VO, 27-1           |
-- |7        |Vorobiev   |Vova      |123-45-67   |Universitetskaia nab, 17      |
-- |8        |Ivanov     |Vano      |+7789012345 |Malyi pr VO, 33-2             |
-- |9        |Sokolova   |Sveta     |234-56-78   |                              |
-- |10       |Zotov      |Misha     |111-56-22   |                              |
-- |11       |Yakshigulov|Vadim     |88005553535 |V Ryazani, gde gribi s glazami|
-- +---------+-----------+----------+------------+------------------------------+
-- pet_db.public> INSERT INTO Person (Person_Id, Last_Name, First_Name, Phone, Address)
--                VALUES (
--                    (SELECT COALESCE(MAX(Person_Id), 0) + 1 FROM Person),
--                    'Yakshigulov',
--                    'Vadim',
--                    '88005553535',
--                    'V Ryazani, gde gribi s glazami'
--                )
-- [2024-10-31 22:10:05] 1 row affected in 10 ms

CREATE TABLE Person_Document
(
    Document_Id   SERIAL PRIMARY KEY,
    Person_Id     INTEGER NOT NULL,
    Document_Type VARCHAR(50) NOT NULL,
    Document_Number VARCHAR(20) NOT NULL,
    CONSTRAINT Fk_Person_Document FOREIGN KEY (Person_Id)
    REFERENCES Person (Person_Id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

INSERT INTO Person_Document (Person_Id, Document_Type, Document_Number)
VALUES
    ((SELECT MAX(Person_Id) FROM Person), 'Passport', '1234 567890'),
    ((SELECT MAX(Person_Id) FROM Person), 'Driver License', 'AB1234567');
-- +-----------+---------+--------------+---------------+
-- |document_id|person_id|document_type |document_number|
-- +-----------+---------+--------------+---------------+
-- |1          |11       |Passport      |1234 567890    |
-- |2          |11       |Driver License|AB1234567      |
-- +-----------+---------+--------------+---------------+


UPDATE Person
SET Person_Id = 1337
WHERE Person_Id = (SELECT MAX(Person_Id) FROM Person);

SELECT * FROM Person_Document WHERE Person_Id = 1337;

-- +-----------+---------+--------------+---------------+
-- |document_id|person_id|document_type |document_number|
-- +-----------+---------+--------------+---------------+
-- |1          |1337     |Passport      |1234 567890    |
-- |2          |1337     |Driver License|AB1234567      |
-- +-----------+---------+--------------+---------------+

DELETE FROM Person WHERE Person_Id = 1337;
SELECT * FROM Person_Document WHERE Person_Id = 1337;
-- pet_db.public> DELETE FROM Person WHERE Person_Id = 1337
-- [2024-10-31 22:17:16] 1 row affected in 10 ms
-- pet_db.public> SELECT * FROM Person_Document WHERE Person_Id = 1337
-- [2024-10-31 22:17:19] 0 rows retrieved in 20 ms (execution: 2 ms, fetching: 18 ms)



-- Возможные варианты добавления каскадности

-- ALTER TABLE Owner
--     DROP CONSTRAINT Fk_Owner_Person,
--     ADD CONSTRAINT Fk_Owner_Person
--     FOREIGN KEY (Person_Id)
--     REFERENCES Person(Person_Id)
--     ON UPDATE CASCADE
--     ON DELETE CASCADE;
--
-- ALTER TABLE Employee
--     DROP CONSTRAINT Fk_Employee_Person,
--     ADD CONSTRAINT Fk_Employee_Person
--     FOREIGN KEY (Person_Id)
--     REFERENCES Person(Person_Id)
--     ON UPDATE CASCADE
--     ON DELETE CASCADE;
