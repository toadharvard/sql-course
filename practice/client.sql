-- (01) Данные о клиентах, включая количество сделанных заказов
\c milk_fabric;

SELECT
    c.client_name,
    c.contact_info,
    COUNT(po.order_id) AS total_orders
FROM
    clients c
LEFT JOIN product_orders po ON c.client_id = po.client_id
GROUP BY
    c.client_id,
    c.client_name,
    c.contact_info;

-- (02) Клиенты, не сделавшие за прошлый год ни одного заказа

SELECT
    c.client_name,
    c.contact_info
FROM
    clients c
WHERE NOT EXISTS (
    SELECT 1 FROM product_orders po
    WHERE po.client_id = c.client_id
    AND EXTRACT(YEAR FROM po.order_date) = EXTRACT(YEAR FROM CURRENT_DATE) - 1
);

-- (03) Клиенты с наибольшим количеством заказов

SELECT
    c.client_name,
    c.contact_info,
    COUNT(po.order_id) AS total_orders
FROM
    clients c
JOIN product_orders po ON c.client_id = po.client_id
GROUP BY
    c.client_id,
    c.client_name,
    c.contact_info
HAVING COUNT(po.order_id) = (
    SELECT MAX(order_count) FROM (
        SELECT COUNT(po2.order_id) AS order_count
        FROM product_orders po2
        GROUP BY po2.client_id
    ) sub
);

-- (04) Продукты, начинающиеся на буквы 'C' и 'F', их упаковка и объем

SELECT
    fp.product_name,
    fp.packaging_type,
    fp.volume
FROM
    finished_products fp
WHERE
    fp.product_name LIKE 'C%' OR fp.product_name LIKE 'F%'
ORDER BY
    fp.product_name;

-- (05) Поставщики, не получившие ни одного заказа на сырье

SELECT
    s.supplier_name,
    s.contact_info
FROM
    suppliers s
LEFT JOIN raw_material_orders rmo ON s.supplier_id = rmo.supplier_id
WHERE
    rmo.order_id IS NULL;

-- (06) Поставщики, выполнившие в текущем году более пятидесяти поставок сырья

SELECT
    s.supplier_name,
    COUNT(rmo.order_id) AS total_deliveries
FROM
    suppliers s
JOIN raw_material_orders rmo ON s.supplier_id = rmo.supplier_id
WHERE
    rmo.status = 'Доставлен'
    AND EXTRACT(YEAR FROM rmo.delivery_date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY
    s.supplier_id,
    s.supplier_name
HAVING COUNT(rmo.order_id) > 50;

-- (07) Рейтинг поставщиков по надежности (процент своевременных поставок), упорядоченный по убыванию рейтинга

SELECT
    s.supplier_name,
    s.supplier_rating
FROM
    suppliers s
ORDER BY
    s.supplier_rating DESC NULLS LAST;

-- (08) Количество доступных поставщиков по каждому сырью

SELECT
    rm.material_name,
    COUNT(srm.supplier_id) AS supplier_count
FROM
    raw_materials rm
LEFT JOIN suppliers_raw_materials srm ON rm.raw_material_id = srm.raw_material_id
GROUP BY
    rm.raw_material_id,
    rm.material_name
ORDER BY
    rm.material_name;

-- (09) Заказы на продукцию за период

SELECT
    po.order_id,
    po.order_number,
    po.order_date,
    po.delivery_date,
    po.status,
    c.client_name,
    po.total_amount
FROM
    product_orders po
JOIN clients c ON po.client_id = c.client_id
WHERE
    po.order_date BETWEEN '2023-10-01' AND '2023-10-31'
ORDER BY
    po.order_date DESC;

-- (10) Количество проданных продуктов по каждому виду продукции

SELECT
    fp.product_name,
    SUM(pod.quantity) AS total_sold
FROM
    finished_products fp
JOIN product_order_details pod ON fp.product_id = pod.product_id
JOIN product_orders po ON pod.order_id = po.order_id
WHERE
    po.status = 'Доставлен'
GROUP BY
    fp.product_id,
    fp.product_name
ORDER BY
    total_sold DESC;
