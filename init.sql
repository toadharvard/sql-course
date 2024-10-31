CREATE DATABASE Pet_Db;
-- PostgresQL statement
\c pet_db;
---------------------------------------------------------------
-- Создание таблиц и PK 
---------------------------------------------------------------
CREATE TABLE Person
(
    Person_Id  INTEGER     NOT NULL,
    Last_Name  VARCHAR(20) NOT NULL,
    First_Name VARCHAR(20),
    Phone      VARCHAR(15) NOT NULL,
    Address    VARCHAR(50) NOT NULL,
    CONSTRAINT Person_Pk PRIMARY KEY (Person_Id)
);

-- Замечание: 
-- Выделение сущности Person в этой предметной области искусственно, 
-- она добавлена исключительно в учебных целях 
-- (чтобы продемонстрировать реализацию связей наследования).
CREATE TABLE Owner
(
    Owner_Id    INTEGER NOT NULL,
    Description VARCHAR(50),
    Person_Id   INTEGER NOT NULL,
    CONSTRAINT Owner_Pk PRIMARY KEY (Owner_Id)
);

CREATE TABLE Employee
(
    Employee_Id INTEGER NOT NULL,
    Spec        VARCHAR(15),
    Person_Id   INTEGER NOT NULL,
    CONSTRAINT Employee_Pk PRIMARY KEY (Employee_Id)
);

CREATE TABLE Pet_Type
(
    Pet_Type_Id INTEGER     NOT NULL,
    Name        VARCHAR(15) NOT NULL,
    CONSTRAINT Pet_Type_Pk PRIMARY KEY (Pet_Type_Id)
);

CREATE TABLE Pet
(
    Pet_Id      INTEGER     NOT NULL,
    Nick        VARCHAR(15) NOT NULL,
    Breed       VARCHAR(20),
    Age         INTEGER,
    Description VARCHAR(50),
    Pet_Type_Id INTEGER     NOT NULL,
    Owner_Id    INTEGER     NOT NULL,
    CONSTRAINT Pet_Pk PRIMARY KEY (Pet_Id)
);

CREATE TABLE Service
(
    Service_Id INTEGER     NOT NULL,
    Name       VARCHAR(15) NOT NULL,
    CONSTRAINT Service_Pk PRIMARY KEY (Service_Id)
);

CREATE TABLE Employee_Service
(
    Employee_Id INTEGER NOT NULL,
    Service_Id  INTEGER NOT NULL,
    Is_Basic    INTEGER
);

CREATE TABLE Order1
(
    Order_Id    INTEGER           NOT NULL,
    Owner_Id    INTEGER           NOT NULL,
    Service_Id  INTEGER           NOT NULL,
    Pet_Id      INTEGER           NOT NULL,
    Employee_Id INTEGER           NOT NULL,
    Time_Order  TIMESTAMP         NOT NULL,
    Is_Done     INTEGER DEFAULT 0 NOT NULL,
    Mark        INTEGER,
    Comments    VARCHAR(50),
    CONSTRAINT Order_Is_Done CHECK (Is_Done IN (0, 1)),
    CONSTRAINT Order_Pk PRIMARY KEY (Order_Id)
);

---------------------------------------------------------------
-- Создание FK 
---------------------------------------------------------------
ALTER TABLE
    Owner
    ADD
        CONSTRAINT Fk_Owner_Person FOREIGN KEY (Person_Id) REFERENCES Person (Person_Id);

ALTER TABLE
    Employee
    ADD
        CONSTRAINT Fk_Employee_Person FOREIGN KEY (Person_Id) REFERENCES Person (Person_Id);

ALTER TABLE
    Pet
    ADD
        CONSTRAINT Fk_Pet_0wner FOREIGN KEY (Owner_Id) REFERENCES Owner (Owner_Id);

ALTER TABLE
    Pet
    ADD
        CONSTRAINT Fk_Pet_Pet_Type FOREIGN KEY (Pet_Type_Id) REFERENCES Pet_Type (Pet_Type_Id);

ALTER TABLE
    Employee_Service
    ADD
        CONSTRAINT Fk_Empl_Serv_Employee FOREIGN KEY (Employee_Id) REFERENCES Employee (Employee_Id);

ALTER TABLE
    Employee_Service
    ADD
        CONSTRAINT Fk_Empl_Serv_Service FOREIGN KEY (Service_Id) REFERENCES Service (Service_Id);

ALTER TABLE
    Order1
    ADD
        CONSTRAINT Fk_Order_Employee FOREIGN KEY (Employee_Id) REFERENCES Employee (Employee_Id);

ALTER TABLE
    Order1
    ADD
        CONSTRAINT Fk_Order_0wner FOREIGN KEY (Owner_Id) REFERENCES Owner (Owner_Id);

ALTER TABLE
    Order1
    ADD
        CONSTRAINT Fk_Order_Pet FOREIGN KEY (Pet_Id) REFERENCES Pet (Pet_Id);

ALTER TABLE
    Order1
    ADD
        CONSTRAINT Fk_Order_Service FOREIGN KEY (Service_Id) REFERENCES Service (Service_Id);

---------------------------------------------------------------
-- Заполнение таблиц тестовыми данными
---------------------------------------------------------------
INSERT INTO Person(Person_Id, Last_Name, First_Name, Phone, Address)
VALUES (1,
        'Ivanov',
        'Vania',
        '+79123456789',
        'Srednii pr VO, 34-2');

INSERT INTO Person(Person_Id, Last_Name, First_Name, Phone, Address)
VALUES (2,
        'Petrov',
        'Petia',
        '+79234567890',
        'Sadovaia ul, 17\2-23');

INSERT INTO Person(Person_Id, Last_Name, First_Name, Phone, Address)
VALUES (3,
        'Vasiliev',
        'Vasia',
        '+7345678901',
        'Nevskii pr, 9-11');

INSERT INTO Person(Person_Id, Last_Name, First_Name, Phone, Address)
VALUES (4,
        'Orlov',
        'Oleg',
        '+7456789012',
        '5 linia VO, 45-8');

INSERT INTO Person(Person_Id, Last_Name, First_Name, Phone, Address)
VALUES (5,
        'Galkina',
        'Galia',
        '+7567890123',
        '10 linia VO, 35-26');

INSERT INTO Person(Person_Id, Last_Name, First_Name, Phone, Address)
VALUES (6,
        'Sokolov',
        'S.',
        '+7678901234',
        'Srednii pr VO, 27-1');

INSERT INTO Person(Person_Id, Last_Name, First_Name, Phone, Address)
VALUES (7,
        'Vorobiev',
        'Vova',
        '123-45-67',
        'Universitetskaia nab, 17');

INSERT INTO Person(Person_Id, Last_Name, First_Name, Phone, Address)
VALUES (8,
        'Ivanov',
        'Vano',
        '+7789012345',
        'Malyi pr VO, 33-2');

INSERT INTO Person(Person_Id, Last_Name, First_Name, Phone, Address)
VALUES (9, 'Sokolova', 'Sveta', '234-56-78', '');

INSERT INTO Person(Person_Id, Last_Name, First_Name, Phone, Address)
VALUES (10, 'Zotov', 'Misha', '111-56-22', '');

INSERT INTO Owner(Owner_Id, Description, Person_Id)
VALUES (1, 'good boy', 2);

INSERT INTO Owner(Owner_Id, Description, Person_Id)
VALUES (2, '', 3);

INSERT INTO Owner(Owner_Id, Description, Person_Id)
VALUES (3, '', 5);

INSERT INTO Owner(Owner_Id, Description, Person_Id)
VALUES (4, 'from the ArtsAcademy', 6);

INSERT INTO Owner(Owner_Id, Description, Person_Id)
VALUES (5, '', 8);

INSERT INTO Owner(Owner_Id, Description, Person_Id)
VALUES (6, 'mean', 9);

INSERT INTO Employee(Employee_Id, Spec, Person_Id)
VALUES (1, 'boss', 1);

INSERT INTO Employee(Employee_Id, Spec, Person_Id)
VALUES (2, 'hairdresser', 4);

INSERT INTO Employee(Employee_Id, Spec, Person_Id)
VALUES (3, 'student', 7);

INSERT INTO Employee(Employee_Id, Spec, Person_Id)
VALUES (4, 'student', 10);

INSERT INTO Pet_Type(Pet_Type_Id, Name)
VALUES (1, 'DOG');

INSERT INTO Pet_Type(Pet_Type_Id, Name)
VALUES (2, 'CAT');

INSERT INTO Pet_Type(Pet_Type_Id, Name)
VALUES (3, 'COW');

INSERT INTO Pet_Type(Pet_Type_Id, Name)
VALUES (4, 'FISH');

INSERT INTO Pet(Pet_Id,
                Nick,
                Breed,
                Age,
                Description,
                Pet_Type_Id,
                Owner_Id)
VALUES (1, 'Bobik', 'unknown', 3, NULL, 1, 1);

INSERT INTO Pet(Pet_Id,
                Nick,
                Breed,
                Age,
                Description,
                Pet_Type_Id,
                Owner_Id)
VALUES (2, 'Musia', NULL, 12, NULL, 2, 1);

INSERT INTO Pet(Pet_Id,
                Nick,
                Breed,
                Age,
                Description,
                Pet_Type_Id,
                Owner_Id)
VALUES (3, 'Katok', NULL, 2, 'crazy guy', 2, 1);

INSERT INTO Pet(Pet_Id,
                Nick,
                Breed,
                Age,
                Description,
                Pet_Type_Id,
                Owner_Id)
VALUES (4, 'Apelsin', 'poodle', 5, NULL, 1, 2);

INSERT INTO Pet(Pet_Id,
                Nick,
                Breed,
                Age,
                Description,
                Pet_Type_Id,
                Owner_Id)
VALUES (5, 'Partizan', 'Siamese', 5, 'very big', 2, 2);

INSERT INTO Pet(Pet_Id,
                Nick,
                Breed,
                Age,
                Description,
                Pet_Type_Id,
                Owner_Id)
VALUES (6, 'Daniel', 'spaniel', 14, NULL, 1, 3);

INSERT INTO Pet(Pet_Id,
                Nick,
                Breed,
                Age,
                Description,
                Pet_Type_Id,
                Owner_Id)
VALUES (7, 'Model', NULL, 5, NULL, 3, 4);

INSERT INTO Pet(Pet_Id,
                Nick,
                Breed,
                Age,
                Description,
                Pet_Type_Id,
                Owner_Id)
VALUES (8, 'Markiz', 'poodle', 1, NULL, 1, 5);

INSERT INTO Pet(Pet_Id,
                Nick,
                Breed,
                Age,
                Description,
                Pet_Type_Id,
                Owner_Id)
VALUES (9, 'Zombi', 'unknown', 7, 'wild', 2, 6);

INSERT INTO Pet(Pet_Id,
                Nick,
                Breed,
                Age,
                Description,
                Pet_Type_Id,
                Owner_Id)
VALUES (10, 'Las', 'Siamese', 7, '', 2, 6);

INSERT INTO Service(Service_Id, Name)
VALUES (1, 'Walking');

INSERT INTO Service(Service_Id, Name)
VALUES (2, 'Combing');

INSERT INTO Service(Service_Id, Name)
VALUES (3, 'Milking');

INSERT INTO Employee_Service(Employee_Id, Service_Id, Is_Basic)
VALUES (1, 1, 0);

INSERT INTO Employee_Service(Employee_Id, Service_Id, Is_Basic)
VALUES (1, 2, 0);

INSERT INTO Employee_Service(Employee_Id, Service_Id, Is_Basic)
VALUES (1, 3, 1);

INSERT INTO Employee_Service(Employee_Id, Service_Id, Is_Basic)
VALUES (2, 1, 0);

INSERT INTO Employee_Service(Employee_Id, Service_Id, Is_Basic)
VALUES (2, 2, 1);

INSERT INTO Employee_Service(Employee_Id, Service_Id, Is_Basic)
VALUES (3, 1, 1);

-- установка формата даты:
-- set dateformat ymd;
INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (1, 1, 1, 1, 3, '2023-09-11 08:00', 1, 5, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (2, 1, 2, 2, 2, '2023-09-11 09:00', 1, 4, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (3,
        1,
        2,
        3,
        2,
        '2023-09-11 09:00',
        1,
        4,
        'That cat is crazy!');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (4, 1, 1, 1, 3, '2023-09-11 00:00', 1, 5, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (5,
        1,
        1,
        1,
        3,
        '2023-09-16 11:00',
        1,
        3,
        'Comming late');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (6, 1, 1, 1, 3, '2023-09-17 17:00', 1, 5, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (7, 1, 2, 2, 2, '2023-09-17 18:00', 1, 5, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (8, 2, 1, 5, 3, '2023-09-17 18:00', 1, 4, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (9, 2, 1, 4, 3, '2023-09-17 10:00', 1, 4, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (10, 2, 1, 5, 3, '2023-09-18 17:00', 1, 4, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (11, 2, 1, 4, 3, '2023-09-18 18:00', 1, 4, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (12, 2, 1, 5, 3, '2023-09-18 12:00', 1, 4, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (13, 2, 1, 4, 3, '2023-09-18 14:00', 1, 4, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (14, 3, 1, 6, 3, '2023-09-19 10:00', 1, 5, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (15, 3, 2, 6, 2, '2023-09-19 18:00', 0, 0, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (16, 3, 1, 6, 3, '2023-09-20 10:00', 0, 0, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (17, 3, 1, 6, 3, '2023-09-20 11:00', 0, 0, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (18, 3, 1, 6, 3, '2023-09-22 10:00', 0, 0, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (19, 3, 1, 6, 3, '2023-09-23 10:00', 0, 0, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark,
                   Comments)
VALUES (20, 4, 3, 7, 1, '2023-09-30 11:00', 1, 5, '');

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark)
VALUES (21, 4, 3, 7, 1, '2023-10-01 11:00', 0, 0);

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark)
VALUES (22, 4, 3, 7, 1, '2023-10-02 11:00', 0, 0);

INSERT INTO Order1(Order_Id,
                   Owner_Id,
                   Service_Id,
                   Pet_Id,
                   Employee_Id,
                   Time_Order,
                   Is_Done,
                   Mark)
VALUES (23, 5, 2, 8, 2, '2023-10-03 16:00', 0, 0);

---------------------------------------------------------------
-- Удаление таблиц 
---------------------------------------------------------------
/*
 DROP TABLE Order1;
 DROP TABLE Employee_Service;
 DROP TABLE Service;
 DROP TABLE Pet;
 DROP TABLE Pet_Type;
 DROP TABLE Employee;
 DROP TABLE Owner;
 DROP TABLE Person;
 */