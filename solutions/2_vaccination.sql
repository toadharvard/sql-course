CREATE TABLE IF NOT EXISTS Vaccination_Type
(
    Vaccination_Type_ID SERIAL,
    Name                VARCHAR(50) NOT NULL,
    CONSTRAINT Vaccination_Type_PK PRIMARY KEY (Vaccination_Type_ID)
);

CREATE TABLE IF NOT EXISTS Vaccination
(
    Vaccination_ID      SERIAL,
    Pet_ID              INTEGER NOT NULL,
    Vaccination_Type_ID INTEGER NOT NULL,
    Vaccination_Date    DATE    NOT NULL,
    Document_Scan       BYTEA,
    -- Здесь будет храниться скан документа о прививке в виде байт.
    -- Возможно, лучше указать путь до файла в S3 или ссылку на директорию с файлами в Google Drive.
    -- Document_Scans_URI VARCHAR(255) NOT NULL,
    -- Или создать отдельную таблицу, где хранятся ссылки на сканы

    CONSTRAINT Vaccination_PK PRIMARY KEY (Vaccination_ID),
    CONSTRAINT FK_Vaccination_Pet FOREIGN KEY (Pet_ID) REFERENCES Pet (Pet_ID),
    CONSTRAINT FK_Vaccination_Type FOREIGN KEY (Vaccination_Type_ID) REFERENCES Vaccination_Type (Vaccination_Type_ID)
);


---------------------------------------------------------------
-- Заполнение таблиц
---------------------------------------------------------------

INSERT INTO Vaccination_Type (Name)
VALUES ('Rabies'),
       ('Distemper'),
       ('Arbovirus'),
       ('Rabies124214'),
       ('Distemper124444'),
       ('Parvovirus');

INSERT INTO Vaccination (Pet_ID, Vaccination_Type_ID, Vaccination_Date)
VALUES (1, 1, '2023-01-01'),
       (1, 2, '2023-01-15'),
       (2, 1, '2022-12-01'),
       (2, 3, '2022-12-15'),
       (3, 1, '2022-11-01');

---------------------------------------------------------------
-- Удаление таблиц
---------------------------------------------------------------

-- DROP TABLE IF EXISTS Vaccination;
-- DROP TABLE IF EXISTS Vaccination_Type;
