-- Представления для системы молокозавода
\c milk_fabric;
----------------------------------------------------------------------
-- Заказы на продукцию (информация о заказах, продуктах и клиентах)
----------------------------------------------------------------------
CREATE OR REPLACE VIEW v_product_orders AS
SELECT
    po.order_id,
    po.order_number,
    po.order_date,
    po.delivery_date,
    po.status,
    c.client_name,
    c.contact_info,
    p.product_name,
    pod.quantity,
    pod.price_per_unit,
    po.total_amount
FROM
    product_orders po
JOIN clients c ON po.client_id = c.client_id
JOIN product_order_details pod ON po.order_id = pod.order_id
JOIN finished_products p ON pod.product_id = p.product_id;

-- Проверка:
-- SELECT * FROM v_product_orders;

----------------------------------------------------------------------
-- Клиенты и их заказы
----------------------------------------------------------------------
CREATE OR REPLACE VIEW v_clients_and_their_orders AS
SELECT
    c.client_id,
    c.client_name,
    c.contact_info,
    po.order_id,
    po.order_number,
    po.order_date,
    po.status,
    po.total_amount
FROM
    clients c
LEFT JOIN product_orders po ON c.client_id = po.client_id;

-- Проверка:
-- SELECT * FROM v_clients_and_their_orders;

----------------------------------------------------------------------
-- Продукты и необходимые для них сырьевые материалы
----------------------------------------------------------------------
CREATE OR REPLACE VIEW v_products_and_required_raw_materials AS
SELECT
    fp.product_id,
    fp.product_name,
    fp.packaging_type,
    rm.raw_material_id,
    rm.material_name,
    prm.quantity_required
FROM
    finished_products fp
JOIN products_raw_materials prm ON fp.product_id = prm.product_id
JOIN raw_materials rm ON prm.raw_material_id = rm.raw_material_id;

-- Проверка:
-- SELECT * FROM v_products_and_required_raw_materials;

----------------------------------------------------------------------
-- Реестр продуктов по типам упаковки
----------------------------------------------------------------------
CREATE OR REPLACE VIEW v_products_by_packaging AS
SELECT
    packaging_type,
    COUNT(*) AS product_count,
    ARRAY_AGG(product_name) AS products
FROM
    finished_products
GROUP BY
    packaging_type;

-- Проверка:
-- SELECT * FROM v_products_by_packaging;

----------------------------------------------------------------------
-- Список поставщиков и сырья, которое они поставляют
----------------------------------------------------------------------
CREATE OR REPLACE VIEW v_suppliers_and_their_raw_materials AS
SELECT
    s.supplier_id,
    s.supplier_name,
    sr.region_name,
    rm.raw_material_id,
    rm.material_name,
    srm.price_per_unit,
    srm.supply_frequency
FROM
    suppliers s
JOIN supplier_regions sr ON s.region_id = sr.region_id
JOIN suppliers_raw_materials srm ON s.supplier_id = srm.supplier_id
JOIN raw_materials rm ON srm.raw_material_id = rm.raw_material_id;

-- Проверка:
-- SELECT * FROM v_suppliers_and_their_raw_materials;

----------------------------------------------------------------------
-- Сырьевые материалы, поставляемые определенными поставщиками
-- Пример для поставщика с ID = 1
----------------------------------------------------------------------
CREATE OR REPLACE VIEW v_raw_materials_from_supplier_1 AS
SELECT
    rm.raw_material_id,
    rm.material_name,
    rm.unit,
    srm.price_per_unit,
    srm.supply_frequency
FROM
    suppliers_raw_materials srm
JOIN raw_materials rm ON srm.raw_material_id = rm.raw_material_id
WHERE
    srm.supplier_id = 1;

-- Проверка:
-- SELECT * FROM v_raw_materials_from_supplier_1;

----------------------------------------------------------------------
-- Рейтинг поставщиков по надежности
----------------------------------------------------------------------
CREATE OR REPLACE VIEW v_suppliers_ratings AS
SELECT
    s.supplier_id,
    s.supplier_name,
    s.supplier_rating,
    sr.region_name
FROM
    suppliers s
JOIN supplier_regions sr ON s.region_id = sr.region_id
ORDER BY
    s.supplier_rating DESC NULLS LAST;

-- Проверка:
-- SELECT * FROM v_suppliers_ratings;

----------------------------------------------------------------------
-- Рейтинг клиентов по количеству заказов
----------------------------------------------------------------------
CREATE OR REPLACE VIEW v_clients_order_count AS
SELECT
    c.client_id,
    c.client_name,
    COUNT(po.order_id) AS total_orders,
    SUM(po.total_amount) AS total_spent
FROM
    clients c
LEFT JOIN product_orders po ON c.client_id = po.client_id
GROUP BY
    c.client_id,
    c.client_name
ORDER BY
    total_orders DESC;

-- Проверка:
-- SELECT * FROM v_clients_order_count;

----------------------------------------------------------------------
-- Заказы на сырье (информация о заказах, сырье и поставщиках)
----------------------------------------------------------------------
CREATE OR REPLACE VIEW v_raw_material_orders AS
SELECT
    ro.order_id,
    ro.order_date,
    ro.delivery_date,
    ro.status,
    s.supplier_name,
    s.contact_info,
    rm.raw_material_id,
    rm.material_name,
    rod.quantity,
    rod.price_per_unit,
    ro.total_amount
FROM
    raw_material_orders ro
JOIN suppliers s ON ro.supplier_id = s.supplier_id
JOIN raw_material_order_details rod ON ro.order_id = rod.order_id
JOIN raw_materials rm ON rod.raw_material_id = rm.raw_material_id;

-- Проверка:
-- SELECT * FROM v_raw_material_orders;

----------------------------------------------------------------------
-- Продукты, произведенные из определенного сырья
-- Пример для сырья с ID = 1 (Молоко)
----------------------------------------------------------------------
CREATE OR REPLACE VIEW v_products_from_raw_material_1 AS
SELECT
    DISTINCT fp.product_id,
    fp.product_name,
    fp.packaging_type
FROM
    products_raw_materials prm
JOIN finished_products fp ON prm.product_id = fp.product_id
WHERE
    prm.raw_material_id = 1;

-- Проверка:
-- SELECT * FROM v_products_from_raw_material_1;

----------------------------------------------------------------------
-- Список активных клиентов
----------------------------------------------------------------------
CREATE OR REPLACE VIEW v_active_clients AS
SELECT
    client_id,
    client_name,
    contact_info
FROM
    clients
WHERE
    is_active = TRUE;

-- Проверка:
-- SELECT * FROM v_active_clients;

----------------------------------------------------------------------
-- Список деактивированных клиентов
----------------------------------------------------------------------
CREATE OR REPLACE VIEW v_inactive_clients AS
SELECT
    client_id,
    client_name,
    contact_info
FROM
    clients
WHERE
    is_active = FALSE;

-- Проверка:
-- SELECT * FROM v_inactive_clients;
