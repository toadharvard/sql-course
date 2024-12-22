-- Хранимые процедуры и функции для системы молокозавода
\c milk_fabric;

----------------------------------------------------------------------
-- Регистрация нового поставщика
----------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE add_new_supplier(
    p_supplier_name VARCHAR(100),
    p_contact_info TEXT,
    p_region_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO suppliers (supplier_name, contact_info, region_id)
    VALUES (p_supplier_name, p_contact_info, p_region_id);
END;
$$;
-- Пример вызова:
CALL add_new_supplier('Сельхоз Компания', 'ул. Фермерская, д.1', 2);
----------------------------------------------------------------------
-- Регистрация нового клиента
----------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_new_client(
    p_client_name VARCHAR(100),
    p_contact_info TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO clients (client_name, contact_info)
    VALUES (p_client_name, p_contact_info);
END;
$$;
-- Пример вызова:
-- CALL add_new_client('Магазин Продукты', 'г. Москва, ул. Центральная, д.5');

----------------------------------------------------------------------
-- Оформление нового заказа на сырье
----------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE place_new_raw_material_order(
    p_supplier_id INT,
    p_order_date DATE,
    p_delivery_date DATE,
    p_status VARCHAR(50),
    p_raw_material_ids INT[],
    p_quantities NUMERIC[],
    p_price_per_units NUMERIC[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_id INT;
    v_total_amount NUMERIC := 0;
    i INT;
    v_item_total NUMERIC;
BEGIN
    -- Вставка в таблицу заказов на сырье
    INSERT INTO raw_material_orders (supplier_id, order_date, delivery_date, status, total_amount)
    VALUES (p_supplier_id, p_order_date, p_delivery_date, p_status, 0)
    RETURNING order_id INTO v_order_id;

    -- Цикл по массивам для вставки деталей заказа
    FOR i IN 1..array_length(p_raw_material_ids, 1) LOOP
        INSERT INTO raw_material_order_details (order_id, raw_material_id, quantity, price_per_unit)
        VALUES (v_order_id, p_raw_material_ids[i], p_quantities[i], p_price_per_units[i]);

        -- Рассчет общей суммы
        v_item_total := p_quantities[i] * p_price_per_units[i];
        v_total_amount := v_total_amount + v_item_total;
    END LOOP;

    -- Обновление общей суммы в заказе
    UPDATE raw_material_orders
    SET total_amount = v_total_amount
    WHERE order_id = v_order_id;
END;
$$;
-- Пример вызова:
-- CALL place_new_raw_material_order(
--     1, -- supplier_id
--     '2023-10-10', -- order_date
--     '2023-10-12', -- delivery_date
--     'Ожидается', -- status
--     ARRAY[1,3], -- raw_material_ids
--     ARRAY[1000.0, 200.0], -- quantities
--     ARRAY[0.50, 1.20] -- price_per_units
-- );

----------------------------------------------------------------------
-- Оформление нового заказа от клиента на продукцию
----------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE place_new_product_order(
    p_client_id INT,
    p_order_date DATE,
    p_delivery_date DATE,
    p_status VARCHAR(50),
    p_product_ids INT[],
    p_quantities NUMERIC[],
    p_price_per_units NUMERIC[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_id INT;
    v_total_amount NUMERIC := 0;
    i INT;
    v_item_total NUMERIC;
BEGIN
    -- Вставка в таблицу заказов на продукцию
    INSERT INTO product_orders (client_id, order_date, delivery_date, status, total_amount)
    VALUES (p_client_id, p_order_date, p_delivery_date, p_status, 0)
    RETURNING order_id INTO v_order_id;

    -- Цикл по массивам для вставки деталей заказа
    FOR i IN 1..array_length(p_product_ids, 1) LOOP
        INSERT INTO product_order_details (order_id, product_id, quantity, price_per_unit)
        VALUES (v_order_id, p_product_ids[i], p_quantities[i], p_price_per_units[i]);

        -- Рассчет общей суммы
        v_item_total := p_quantities[i] * p_price_per_units[i];
        v_total_amount := v_total_amount + v_item_total;
    END LOOP;

    -- Обновление общей суммы в заказе
    UPDATE product_orders
    SET total_amount = v_total_amount
    WHERE order_id = v_order_id;
END;
$$;
-- Пример вызова:
-- CALL place_new_product_order(
--     2, -- client_id
--     '2023-10-11', -- order_date
--     '2023-10-13', -- delivery_date
--     'В обработке', -- status
--     ARRAY[1,4], -- product_ids
--     ARRAY[500.0, 300.0], -- quantities
--     ARRAY[1.50, 1.80] -- price_per_units
-- );

----------------------------------------------------------------------
-- Обработка заказа (обновление статуса заказа на сырье)
----------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE update_raw_material_order_status(
    p_order_id INT,
    p_status VARCHAR(50),
    p_delivery_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE raw_material_orders
    SET status = p_status,
        delivery_date = p_delivery_date
    WHERE order_id = p_order_id;
END;
$$;
-- Пример вызова:
-- CALL update_raw_material_order_status(1, 'Доставлен', '2023-10-12');

----------------------------------------------------------------------
-- Удаление заказа на продукцию
----------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE delete_product_order(
    p_order_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM product_orders
    WHERE order_id = p_order_id;
END;
$$;
-- Пример вызова:
-- CALL delete_product_order(3);

----------------------------------------------------------------------
-- Функция для получения количества заказов на продукт за период
----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_total_orders_for_product(
    p_product_id INT,
    p_start_date DATE,
    p_end_date DATE
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_quantity NUMERIC;
BEGIN
    SELECT COALESCE(SUM(pod.quantity), 0) INTO v_total_quantity
    FROM product_orders po
    INNER JOIN product_order_details pod ON po.order_id = pod.order_id
    WHERE pod.product_id = p_product_id
      AND po.order_date BETWEEN p_start_date AND p_end_date;

    RETURN v_total_quantity;
END;
$$;
-- Пример вызова:
-- SELECT get_total_orders_for_product(1, '2023-10-01', '2023-10-31');

----------------------------------------------------------------------
-- Вычисление рейтинга поставщика (процент своевременных поставок)
----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_supplier_reliability_rating(
    p_supplier_id INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_orders INT;
    v_on_time_deliveries INT;
    v_rating NUMERIC;
BEGIN
    SELECT COUNT(*) INTO v_total_orders
    FROM raw_material_orders
    WHERE supplier_id = p_supplier_id;

    SELECT COUNT(*) INTO v_on_time_deliveries
    FROM raw_material_orders
    WHERE supplier_id = p_supplier_id
      AND delivery_date IS NOT NULL
      AND delivery_date <= order_date + INTERVAL '1 day'
      AND status = 'Доставлен';

    IF v_total_orders = 0 THEN
        RETURN NULL;
    ELSE
        v_rating := (v_on_time_deliveries::NUMERIC / v_total_orders) * 100;
        RETURN v_rating;
    END IF;
END;
$$;
-- Пример вызова:
-- SELECT get_supplier_reliability_rating(1);

----------------------------------------------------------------------
-- Добавление нового сырья
----------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_new_raw_material(
    p_material_name VARCHAR(100),
    p_unit VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO raw_materials (material_name, unit)
    VALUES (p_material_name, p_unit);
END;
$$;
-- Пример вызова:
-- CALL add_new_raw_material('Мёд', 'килограмм');

----------------------------------------------------------------------
-- Добавление нового конечного продукта
----------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_new_finished_product(
    p_product_name VARCHAR(100),
    p_unit VARCHAR(50),
    p_volume NUMERIC,
    p_packaging_type VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO finished_products (product_name, unit, volume, packaging_type)
    VALUES (p_product_name, p_unit, p_volume, p_packaging_type);
END;
$$;
-- Пример вызова:
-- CALL add_new_finished_product('Йогурт с мёдом', 'стакан', 0.2, 'Пластиковый стакан');

----------------------------------------------------------------------
-- Удаление заказа на сырье
----------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE delete_raw_material_order(
    p_order_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM raw_material_orders
    WHERE order_id = p_order_id;
END;
$$;
-- Пример вызова:
-- CALL delete_raw_material_order(2);

----------------------------------------------------------------------
-- Функция для расчета общего количества заказов на сырье
----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_total_raw_material_orders(
    p_raw_material_id INT,
    p_start_date DATE,
    p_end_date DATE
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_quantity NUMERIC;
BEGIN
    SELECT COALESCE(SUM(rod.quantity), 0) INTO v_total_quantity
    FROM raw_material_orders ro
    INNER JOIN raw_material_order_details rod ON ro.order_id = rod.order_id
    WHERE rod.raw_material_id = p_raw_material_id
      AND ro.order_date BETWEEN p_start_date AND p_end_date;

    RETURN v_total_quantity;
END;
$$;
-- Пример вызова:
-- SELECT get_total_raw_material_orders(1, '2023-10-01', '2023-10-31');

