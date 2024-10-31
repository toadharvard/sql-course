---------------------------------------------------------------
--  Все оценки по выполненным заказам, исполнителями которых являлись студенты.
-- (используйте IN (SELECT...))
---------------------------------------------------------------

SELECT Order1.Mark
FROM Order1
         JOIN Employee ON Order1.Employee_Id = Employee.Employee_Id
         JOIN Person ON Employee.Person_Id = Person.Person_Id
WHERE Order1.Is_Done = 1
  AND Order1.Mark IS NOT NULL
  AND Employee.Employee_Id IN (SELECT Employee.Employee_Id
                               FROM Employee
                               WHERE Employee.Spec = 'student');
-- +----+
-- |mark|
-- +----+
-- |5   |
-- |5   |
-- |3   |
-- |5   |
-- |4   |
-- |4   |
-- |4   |
-- |4   |
-- |4   |
-- |4   |
-- |5   |
-- +----+

---------------------------------------------------------------
--  Фамилии исполнителей, не получивших еще ни одного заказа.
--  Последовательность отладки:
--      - id исполнителей, у которых нет заказов,
--          (используйте NOT IN (SELECT...))
--      - фамилии этих исполнителей.
--          (присоедините еще одну таблицу)
---------------------------------------------------------------


-- Первый вывод: id исполнителей без заказов
SELECT Employee.Employee_Id
FROM Employee
WHERE Employee.Employee_Id NOT IN (SELECT Order1.Employee_Id
                                   FROM Order1);

-- +-----------+
-- |employee_id|
-- +-----------+
-- |4          |
-- +-----------+


-- Второй вывод: Фамилии этих исполнителей
SELECT Person.Last_Name
FROM Employee
         JOIN Person ON Employee.Person_Id = Person.Person_Id
WHERE Employee.Employee_Id NOT IN (SELECT Order1.Employee_Id
                                   FROM Order1);
-- +---------+
-- |last_name|
-- +---------+
-- |Zotov    |
-- +---------+


-- Список заказов (вид услуги, время, фамилия исполнителя, кличка питомца, фамилия владельца).
-- (используйте псевдонимы, см. в презентации раздел 2.3. Сложные соединения таблиц)

SELECT S.Name,
       O1.Time_Order,
       P_Exec.Last_Name,
       P.Nick,
       P_Owner.Last_Name
FROM Order1 O1
         JOIN Service S ON O1.Service_Id = S.Service_Id
         JOIN Employee E ON O1.Employee_Id = E.Employee_Id
         JOIN Person P_Exec ON E.Person_Id = P_Exec.Person_Id
         JOIN Pet P ON O1.Pet_Id = P.Pet_Id
         JOIN Owner O ON P.Owner_Id = O.Owner_Id
         JOIN Person P_Owner ON O.Person_Id = P_Owner.Person_Id
ORDER BY O1.Time_Order;

-- +-------+--------------------------+---------+--------+---------+
-- |name   |time_order                |last_name|nick    |last_name|
-- +-------+--------------------------+---------+--------+---------+
-- |Walking|2023-09-11 00:00:00.000000|Vorobiev |Bobik   |Petrov   |
-- |Walking|2023-09-11 08:00:00.000000|Vorobiev |Bobik   |Petrov   |
-- |Combing|2023-09-11 09:00:00.000000|Orlov    |Musia   |Petrov   |
-- |Combing|2023-09-11 09:00:00.000000|Orlov    |Katok   |Petrov   |
-- |Walking|2023-09-16 11:00:00.000000|Vorobiev |Bobik   |Petrov   |
-- |Walking|2023-09-17 10:00:00.000000|Vorobiev |Apelsin |Vasiliev |
-- |Walking|2023-09-17 17:00:00.000000|Vorobiev |Bobik   |Petrov   |
-- |Combing|2023-09-17 18:00:00.000000|Orlov    |Musia   |Petrov   |
-- |Walking|2023-09-17 18:00:00.000000|Vorobiev |Partizan|Vasiliev |
-- |Walking|2023-09-18 12:00:00.000000|Vorobiev |Partizan|Vasiliev |
-- |Walking|2023-09-18 14:00:00.000000|Vorobiev |Apelsin |Vasiliev |
-- |Walking|2023-09-18 17:00:00.000000|Vorobiev |Partizan|Vasiliev |
-- |Walking|2023-09-18 18:00:00.000000|Vorobiev |Apelsin |Vasiliev |
-- |Walking|2023-09-19 10:00:00.000000|Vorobiev |Daniel  |Galkina  |
-- |Combing|2023-09-19 18:00:00.000000|Orlov    |Daniel  |Galkina  |
-- |Walking|2023-09-20 10:00:00.000000|Vorobiev |Daniel  |Galkina  |
-- |Walking|2023-09-20 11:00:00.000000|Vorobiev |Daniel  |Galkina  |
-- |Walking|2023-09-22 10:00:00.000000|Vorobiev |Daniel  |Galkina  |
-- |Walking|2023-09-23 10:00:00.000000|Vorobiev |Daniel  |Galkina  |
-- |Milking|2023-09-30 11:00:00.000000|Ivanov   |Model   |Sokolov  |
-- |Milking|2023-10-01 11:00:00.000000|Ivanov   |Model   |Sokolov  |
-- |Milking|2023-10-02 11:00:00.000000|Ivanov   |Model   |Sokolov  |
-- |Combing|2023-10-03 16:00:00.000000|Orlov    |Markiz  |Ivanov   |
-- +-------+--------------------------+---------+--------+---------+

-- Общий список комментариев, имеющихся в базе.
-- (“Хватит захламлять базу, посмотрите, что вы пишите в комментариях!”).
-- (используйте UNION)
-- (комментарии есть в трех таблицах). Это таблицы order, owner, pet

SELECT *
FROM (SELECT O.Comments
      FROM Order1 O
      UNION ALL
      SELECT O.Description
      FROM Owner O
      UNION ALL
      SELECT P.Description
      FROM Pet P) AS All_Comments
WHERE All_Comments.Comments <> '';

-- +--------------------+
-- |comments            |
-- +--------------------+
-- |That cat is crazy!  |
-- |Comming late        |
-- |good boy            |
-- |from the ArtsAcademy|
-- |mean                |
-- |crazy guy           |
-- |very big            |
-- |wild                |
-- +--------------------+

-- Имена и фамилии сотрудников, хотя бы раз получивших четверку за выполнение заказа.
-- (используйте EXISTS)
SELECT P.Last_Name, P.First_Name
FROM Person P
WHERE EXISTS(SELECT E.Person_Id
             FROM Employee E,
                  Order1 O
             WHERE E.Employee_Id = O.Employee_Id
               AND P.Person_Id = E.Person_Id
               AND O.Mark = 4);

-- +---------+----------+
-- |last_name|first_name|
-- +---------+----------+
-- |Orlov    |Oleg      |
-- |Vorobiev |Vova      |
-- +---------+----------+


-- Перепишите предыдущий запрос в каком-либо ином синтаксисе, без EXISTS.
SELECT DISTINCT P.Last_Name, P.First_Name
FROM Person P
         JOIN Employee E ON P.Person_Id = E.Person_Id
         JOIN Order1 O ON E.Employee_Id = O.Employee_Id
WHERE O.Mark = 4;

-- +---------+----------+
-- |last_name|first_name|
-- +---------+----------+
-- |Orlov    |Oleg      |
-- |Vorobiev |Vova      |
-- +---------+----------+
