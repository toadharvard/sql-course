CREATE DATABASE Milk_Fabric;

-- Подключение к базе данных milk_fabric
\c milk_fabric;

-- Удаление таблиц в правильном порядке, чтобы избежать проблем с зависимостями
DROP TABLE IF EXISTS product_order_details CASCADE;
DROP TABLE IF EXISTS raw_material_order_details CASCADE;
DROP TABLE IF EXISTS product_orders CASCADE;
DROP TABLE IF EXISTS raw_material_orders CASCADE;
DROP TABLE IF EXISTS products_raw_materials CASCADE;
DROP TABLE IF EXISTS suppliers_raw_materials CASCADE;
DROP TABLE IF EXISTS finished_products CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS raw_materials CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS supplier_regions CASCADE;

-- Создание таблицы для регионов поставщиков
CREATE TABLE supplier_regions (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL UNIQUE
);

-- Создание таблицы для поставщиков
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL UNIQUE,
    contact_info TEXT,
    region_id INT NOT NULL REFERENCES supplier_regions(region_id) ON DELETE CASCADE
);

-- Создание таблицы для сырья
CREATE TABLE raw_materials (
    raw_material_id SERIAL PRIMARY KEY,
    material_name VARCHAR(100) NOT NULL UNIQUE,
    unit VARCHAR(50) NOT NULL
);

-- Создание ассоциативной таблицы для связки поставщиков и предоставляемого ими сырья
CREATE TABLE suppliers_raw_materials (
    supplier_id INT NOT NULL REFERENCES suppliers(supplier_id) ON DELETE CASCADE,
    raw_material_id INT NOT NULL REFERENCES raw_materials(raw_material_id) ON DELETE CASCADE,
    price_per_unit DECIMAL(10,2) NOT NULL CHECK (price_per_unit > 0),
    supply_frequency VARCHAR(50),
    PRIMARY KEY (supplier_id, raw_material_id)
);

-- Создание таблицы для готовой продукции
CREATE TABLE finished_products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL UNIQUE,
    unit VARCHAR(50) NOT NULL,
    volume DECIMAL(10,2) NOT NULL CHECK (volume > 0),
    packaging_type VARCHAR(100)
);

-- Создание ассоциативной таблицы для связки продуктов и используемого в них сырья
CREATE TABLE products_raw_materials (
    product_id INT NOT NULL REFERENCES finished_products(product_id) ON DELETE CASCADE,
    raw_material_id INT NOT NULL REFERENCES raw_materials(raw_material_id) ON DELETE CASCADE,
    quantity_required DECIMAL(10,2) NOT NULL CHECK (quantity_required > 0),
    PRIMARY KEY (product_id, raw_material_id)
);

-- Создание таблицы для клиентов
CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL UNIQUE,
    contact_info TEXT
);

-- Создание таблицы для заказов сырья с предприятия у поставщиков
CREATE TABLE raw_material_orders (
    order_id SERIAL PRIMARY KEY,
    supplier_id INT NOT NULL REFERENCES suppliers(supplier_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    delivery_date DATE,
    status VARCHAR(50) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0)
);

-- Создание таблицы для деталей заказов сырья
CREATE TABLE raw_material_order_details (
    order_id INT NOT NULL REFERENCES raw_material_orders(order_id) ON DELETE CASCADE,
    raw_material_id INT NOT NULL REFERENCES raw_materials(raw_material_id) ON DELETE CASCADE,
    quantity DECIMAL(10,2) NOT NULL CHECK (quantity > 0),
    price_per_unit DECIMAL(10,2) NOT NULL CHECK (price_per_unit > 0),
    PRIMARY KEY (order_id, raw_material_id)
);

-- Создание таблицы для заказов продукции от клиентов
CREATE TABLE product_orders (
    order_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES clients(client_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    delivery_date DATE,
    status VARCHAR(50) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0)
);

-- Создание таблицы для деталей заказов продукции
CREATE TABLE product_order_details (
    order_id INT NOT NULL REFERENCES product_orders(order_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES finished_products(product_id) ON DELETE CASCADE,
    quantity DECIMAL(10,2) NOT NULL CHECK (quantity > 0),
    price_per_unit DECIMAL(10,2) NOT NULL CHECK (price_per_unit > 0),
    PRIMARY KEY (order_id, product_id)
);

-- Создание индексов для улучшения производительности запросов
CREATE INDEX idx_suppliers_region ON suppliers(region_id);
CREATE INDEX idx_suppliers_name ON suppliers(supplier_name);
CREATE INDEX idx_clients_name ON clients(client_name);
CREATE INDEX idx_raw_materials_name ON raw_materials(material_name);
CREATE INDEX idx_finished_products_name ON finished_products(product_name);
CREATE INDEX idx_raw_material_orders_date ON raw_material_orders(order_date);
CREATE INDEX idx_product_orders_date ON product_orders(order_date);

-- Вставка примерных данных в регионы поставщиков
INSERT INTO supplier_regions (region_name) VALUES
    ('Северный округ'),
    ('Восточный округ'),
    ('Южный округ'),
    ('Западный округ');

-- Вставка примерных данных в поставщиков
INSERT INTO suppliers (supplier_name, contact_info, region_id) VALUES
    ('Farm Fresh Co', '123 Фермерский переулок, Северный округ', 1),
    ('Green Fields Ltd', '456 Улица Урожай, Восточный округ', 2),
    ('Dairy Best', '789 Дойная дорога, Южный округ', 3),
    ('Organic Farms', '101 Сарайная улица, Западный округ', 4);

-- Вставка примерных данных в сырье
INSERT INTO raw_materials (material_name, unit) VALUES
    ('Молоко', 'литры'),
    ('Сливки', 'литры'),
    ('Сахар', 'килограммы'),
    ('Какао-порошок', 'килограммы'),
    ('Фруктовое пюре', 'килограммы');

-- Вставка примерных данных в таблицу поставщиков сырья
INSERT INTO suppliers_raw_materials (supplier_id, raw_material_id, price_per_unit, supply_frequency) VALUES
    (1, 1, 0.50, 'Ежедневно'),
    (1, 2, 0.80, 'Еженедельно'),
    (2, 1, 0.55, 'Ежедневно'),
    (2, 3, 1.20, 'Еженедельно'),
    (3, 1, 0.60, 'Ежедневно'),
    (3, 4, 2.50, 'Ежемесячно'),
    (4, 5, 1.80, 'Еженедельно');

-- Вставка примерных данных в готовую продукцию
INSERT INTO finished_products (product_name, unit, volume, packaging_type) VALUES
    ('Цельное молоко', 'бутылка', 1.0, 'Пластиковая бутылка'),
    ('Обезжиренное молоко', 'бутылка', 1.0, 'Пластиковая бутылка'),
    ('Шоколадное молоко', 'бутылка', 0.5, 'Стеклянная бутылка'),
    ('Йогурт с клубникой', 'стакан', 0.2, 'Стакан'),
    ('Масло', 'упаковка', 0.25, 'Фольгированная упаковка');

-- Вставка примерных данных в таблицу продуктов и их сырья
INSERT INTO products_raw_materials (product_id, raw_material_id, quantity_required) VALUES
    (1, 1, 1.0),    -- Цельное молоко требует 1 литр молока
    (2, 1, 1.0),    -- Обезжиренное молоко требует 1 литр молока
    (2, 2, 0.1),    -- Из него снимаются сливки
    (3, 1, 0.5),    -- Шоколадное молоко требует 0.5 литра молока
    (3, 3, 0.05),   -- Требуется сахар
    (3, 4, 0.02),   -- Требуется какао-порошок
    (4, 1, 0.2),    -- Йогурт требует молоко
    (4, 5, 0.05),   -- Требуется фруктовое пюре
    (5, 2, 0.25);   -- Масло требует сливки

-- Вставка примерных данных в таблицу клиентов
INSERT INTO clients (client_name, contact_info) VALUES
    ('Центральный рынок', 'Улица Рынок, Центр города'),
    ('Свежие продукты', 'Главная улица, Верхний район'),
    ('Король бакалеи', 'Королевская улица, Средний район');

-- Вставка примерных данных в таблицу заказов сырья
INSERT INTO raw_material_orders (supplier_id, order_date, delivery_date, status, total_amount) VALUES
    (1, '2023-10-01', '2023-10-02', 'Доставлено', 500.00),
    (2, '2023-10-03', NULL, 'Ожидается', 600.00),
    (3, '2023-10-05', '2023-10-06', 'Доставлено', 300.00);

-- Вставка примерных данных в таблицу деталей заказов сырья
INSERT INTO raw_material_order_details (order_id, raw_material_id, quantity, price_per_unit) VALUES
    (1, 1, 1000.0, 0.50),
    (1, 2, 500.0, 0.80),
    (2, 1, 1200.0, 0.55),
    (2, 3, 200.0, 1.20),
    (3, 1, 500.0, 0.60);

-- Вставка примерных данных в таблицу заказов продукции
INSERT INTO product_orders (client_id, order_date, delivery_date, status, total_amount) VALUES
    (1, '2023-10-04', '2023-10-05', 'Доставлено', 800.00),
    (2, '2023-10-06', NULL, 'Ожидается', 650.00),
    (3, '2023-10-07', NULL, 'Ожидается', 500.00);

-- Вставка примерных данных в таблицу деталей заказов продукции
INSERT INTO product_order_details (order_id, product_id, quantity, price_per_unit) VALUES
    (1, 1, 500.0, 1.50),
    (1, 3, 200.0, 2.00),
    (2, 2, 400.0, 1.40),
    (2, 4, 300.0, 1.80),
    (3, 5, 200.0, 2.50);