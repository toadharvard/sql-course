-- Триггеры для системы молокозавода
\c milk_fabric;

----------------------------------------------------------------------
-- Запрет на удаление поставщика
----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION prevent_supplier_delete()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Удаление поставщиков запрещено.';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_prevent_supplier_delete
BEFORE DELETE ON suppliers
FOR EACH ROW
EXECUTE FUNCTION prevent_supplier_delete();

-- Проверка:
-- DELETE FROM suppliers WHERE supplier_id = 1;

----------------------------------------------------------------------
-- Деактивация клиента вместо удаления
----------------------------------------------------------------------
-- Добавим поле is_active в таблицу clients
ALTER TABLE  clients ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;

-- Создаем функцию триггера
CREATE OR REPLACE FUNCTION deactivate_client_instead_of_delete()
RETURNS TRIGGER AS $$
BEGIN
    -- Устанавливаем is_active в FALSE для текущей строки
    UPDATE clients SET is_active = FALSE WHERE client_id = OLD.client_id;
    -- Возвращаем NULL, чтобы отменить операцию DELETE
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Создаем триггер BEFORE DELETE на таблице clients
CREATE OR REPLACE TRIGGER trg_deactivate_client_instead_of_delete
BEFORE DELETE ON clients
FOR EACH ROW
EXECUTE FUNCTION deactivate_client_instead_of_delete();


-- Проверка:
-- DELETE FROM clients WHERE client_id = 1;
-- SELECT * FROM clients WHERE client_id = 1;

----------------------------------------------------------------------
-- Контроль повторного добавления клиента
----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION check_duplicate_client()
RETURNS TRIGGER AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM clients WHERE client_name = NEW.client_name;
    IF v_count > 0 THEN
        RAISE EXCEPTION 'Клиент с именем % уже существует.', NEW.client_name;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_check_duplicate_client
BEFORE INSERT ON clients
FOR EACH ROW
EXECUTE FUNCTION check_duplicate_client();

-- Проверка:
-- INSERT INTO clients (client_name, contact_info) VALUES ('Downtown Market', 'Another Address');

----------------------------------------------------------------------
-- Формирование номера при добавлении заказа на продукцию
----------------------------------------------------------------------
-- Добавим поле order_number в таблицу product_orders
ALTER TABLE product_orders ADD COLUMN IF NOT EXISTS order_number VARCHAR(20);

CREATE SEQUENCE IF NOT EXISTS product_order_seq START WITH 1;

CREATE OR REPLACE FUNCTION set_product_order_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_number := 'PO-' || TO_CHAR(NEXTVAL('product_order_seq'), 'FM000000');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_set_product_order_number
BEFORE INSERT ON product_orders
FOR EACH ROW
EXECUTE FUNCTION set_product_order_number();

-- Проверка:
-- INSERT INTO product_orders (client_id, order_date, delivery_date, status, total_amount)
-- VALUES (1, '2023-10-15', '2023-10-17', 'В обработке', 1000.00);
-- SELECT order_number FROM product_orders WHERE order_id = (SELECT MAX(order_id) FROM product_orders);

----------------------------------------------------------------------
-- После 100-го заказа клиент переводится в категорию VIP
----------------------------------------------------------------------
-- Добавим поле client_status в таблицу clients
ALTER TABLE clients ADD COLUMN IF NOT EXISTS client_status VARCHAR(20) DEFAULT 'Обычный';

CREATE OR REPLACE FUNCTION upgrade_client_to_vip()
RETURNS TRIGGER AS $$
DECLARE
    v_total_orders INT;
BEGIN
    SELECT COUNT(*) INTO v_total_orders FROM product_orders WHERE client_id = NEW.client_id;
    IF v_total_orders >= 100 THEN
        UPDATE clients SET client_status = 'VIP' WHERE client_id = NEW.client_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_upgrade_client_to_vip
AFTER INSERT ON product_orders
FOR EACH ROW
EXECUTE FUNCTION upgrade_client_to_vip();

----------------------------------------------------------------------
-- Пересчет рейтинга поставщика после обновления заказа на сырье
----------------------------------------------------------------------
-- Добавим поле supplier_rating в таблицу suppliers
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS supplier_rating NUMERIC DEFAULT 0;

CREATE OR REPLACE FUNCTION recalculate_supplier_rating()
RETURNS TRIGGER AS $$
DECLARE
    v_rating NUMERIC;
BEGIN
    -- Используем ранее созданную функцию get_supplier_reliability_rating
    SELECT get_supplier_reliability_rating(NEW.supplier_id) INTO v_rating;
    UPDATE suppliers SET supplier_rating = v_rating WHERE supplier_id = NEW.supplier_id;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_recalculate_supplier_rating
AFTER UPDATE ON raw_material_orders
FOR EACH ROW
WHEN (NEW.status = 'Доставлен' AND NEW.status <> OLD.status)
EXECUTE FUNCTION recalculate_supplier_rating();

-- Проверка:
-- UPDATE raw_material_orders SET status = 'Доставлен', delivery_date = '2023-10-20' WHERE order_id = 1;
-- SELECT supplier_rating FROM suppliers WHERE supplier_id = (SELECT supplier_id FROM raw_material_orders WHERE order_id = 1);
