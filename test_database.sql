-- ========================================
-- Тестови заявки за проверка на базата данни
-- Test queries to verify the database
-- ========================================

-- Проверка на създадените таблици
SHOW TABLES;

-- Проверка на структурата на основните таблици
DESCRIBE users;
DESCRIBE products;
DESCRIBE orders;
DESCRIBE order_items;

-- Проверка на вмъкнатите примерни данни
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_categories FROM categories;
SELECT COUNT(*) as total_products FROM products;
SELECT COUNT(*) as total_addresses FROM addresses;

-- Тест на view-тата
SELECT * FROM active_products_with_category LIMIT 5;
SELECT * FROM orders_with_user_details LIMIT 5;

-- Тест на процедурите

-- Добавяне на продукт в количката
CALL AddToCart(1, 1, 2); -- потребител 1, продукт 1, количество 2
CALL AddToCart(1, 2, 1); -- потребител 1, продукт 2, количество 1

-- Проверка на количката
SELECT 
    sc.user_id,
    sc.product_id,
    p.name as product_name,
    sc.quantity,
    p.price,
    (sc.quantity * p.price) as total_price
FROM shopping_cart sc
JOIN products p ON sc.product_id = p.product_id
WHERE sc.user_id = 1;

-- Създаване на поръчка от количката
CALL CreateOrderFromCart(1, 'credit_card', 1, 1, @new_order_id);

-- Проверка на създадената поръчка
SELECT @new_order_id as created_order_id;

SELECT 
    o.order_id,
    o.order_number,
    o.total_amount,
    o.order_status,
    oi.product_id,
    p.name as product_name,
    oi.quantity,
    oi.unit_price
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_id = @new_order_id;

-- Проверка дали количката е изчистена
SELECT COUNT(*) as items_in_cart FROM shopping_cart WHERE user_id = 1;

-- Добавяне на отзив за тестване на тригерите
INSERT INTO reviews (product_id, user_id, rating, title, comment, is_approved) 
VALUES (1, 2, 5, 'Отличен продукт!', 'Много съм доволна от покупката.', TRUE);

INSERT INTO reviews (product_id, user_id, rating, title, comment, is_approved) 
VALUES (1, 3, 4, 'Добро качество', 'Препоръчвам го.', TRUE);

-- Проверка на обновения рейтинг на продукта
SELECT 
    product_id,
    name,
    rating,
    review_count
FROM products 
WHERE product_id = 1;

-- Проверка на всички отзиви
SELECT 
    r.review_id,
    r.rating,
    r.title,
    r.comment,
    u.first_name,
    u.last_name,
    p.name as product_name
FROM reviews r
JOIN users u ON r.user_id = u.user_id
JOIN products p ON r.product_id = p.product_id
WHERE r.is_approved = TRUE;

-- Статистики на базата данни
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Categories', COUNT(*) FROM categories
UNION ALL
SELECT 'Products', COUNT(*) FROM products
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Order Items', COUNT(*) FROM order_items
UNION ALL
SELECT 'Reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'Addresses', COUNT(*) FROM addresses
UNION ALL
SELECT 'Product Images', COUNT(*) FROM product_images
UNION ALL
SELECT 'Coupons', COUNT(*) FROM coupons;

-- Проверка на индексите
SHOW INDEX FROM products;
SHOW INDEX FROM orders;
SHOW INDEX FROM users;

-- Проверка на тригерите
SHOW TRIGGERS;

-- Проверка на процедурите
SHOW PROCEDURE STATUS WHERE Db = 'ecommerce_db';

-- ========================================
-- Край на тестовите заявки
-- ========================================