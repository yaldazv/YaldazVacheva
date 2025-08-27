-- ========================================
-- SQL код за създаване на база данни
-- Database Schema Creation Script
-- ========================================

-- Създаване на базата данни
CREATE DATABASE IF NOT EXISTS ecommerce_db
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE ecommerce_db;

-- ========================================
-- Таблица за потребители (Users)
-- ========================================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    birth_date DATE,
    gender ENUM('male', 'female', 'other'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
);

-- ========================================
-- Таблица за адреси (Addresses)
-- ========================================
CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    address_type ENUM('billing', 'shipping', 'both') DEFAULT 'both',
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL DEFAULT 'Bulgaria',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_country (country)
);

-- ========================================
-- Таблица за категории (Categories)
-- ========================================
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id INT NULL,
    image_url VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    INDEX idx_parent_category (parent_category_id),
    INDEX idx_name (name),
    INDEX idx_sort_order (sort_order)
);

-- ========================================
-- Таблица за продукти (Products)
-- ========================================
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    short_description VARCHAR(500),
    sku VARCHAR(100) UNIQUE,
    price DECIMAL(10, 2) NOT NULL,
    discount_price DECIMAL(10, 2),
    stock_quantity INT NOT NULL DEFAULT 0,
    min_stock_level INT DEFAULT 5,
    weight DECIMAL(8, 3),
    dimensions VARCHAR(100), -- "length x width x height"
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    rating DECIMAL(3, 2) DEFAULT 0.00, -- Average rating 0.00 to 5.00
    review_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT,
    INDEX idx_category_id (category_id),
    INDEX idx_sku (sku),
    INDEX idx_price (price),
    INDEX idx_name (name),
    INDEX idx_is_active (is_active),
    INDEX idx_is_featured (is_featured),
    INDEX idx_stock_quantity (stock_quantity)
);

-- ========================================
-- Таблица за изображения на продукти (Product Images)
-- ========================================
CREATE TABLE product_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    alt_text VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_product_id (product_id),
    INDEX idx_is_primary (is_primary),
    INDEX idx_sort_order (sort_order)
);

-- ========================================
-- Таблица за поръчки (Orders)
-- ========================================
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    order_status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    payment_method ENUM('credit_card', 'debit_card', 'paypal', 'bank_transfer', 'cash_on_delivery') NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0.00,
    shipping_cost DECIMAL(10, 2) DEFAULT 0.00,
    discount_amount DECIMAL(10, 2) DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL,
    currency_code VARCHAR(3) DEFAULT 'BGN',
    billing_address_id INT,
    shipping_address_id INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    shipped_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id) ON DELETE SET NULL,
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id) ON DELETE SET NULL,
    INDEX idx_user_id (user_id),
    INDEX idx_order_number (order_number),
    INDEX idx_order_status (order_status),
    INDEX idx_payment_status (payment_status),
    INDEX idx_created_at (created_at),
    INDEX idx_total_amount (total_amount)
);

-- ========================================
-- Таблица за елементи от поръчки (Order Items)
-- ========================================
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
);

-- ========================================
-- Таблица за количка за пазаруване (Shopping Cart)
-- ========================================
CREATE TABLE shopping_cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product (user_id, product_id),
    INDEX idx_user_id (user_id),
    INDEX idx_product_id (product_id)
);

-- ========================================
-- Таблица за отзиви (Reviews)
-- ========================================
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    comment TEXT,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product_review (user_id, product_id),
    INDEX idx_product_id (product_id),
    INDEX idx_user_id (user_id),
    INDEX idx_rating (rating),
    INDEX idx_is_approved (is_approved),
    INDEX idx_created_at (created_at)
);

-- ========================================
-- Таблица за купони за отстъпка (Discount Coupons)
-- ========================================
CREATE TABLE coupons (
    coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL,
    min_order_amount DECIMAL(10, 2) DEFAULT 0.00,
    max_discount_amount DECIMAL(10, 2),
    usage_limit INT,
    used_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP NOT NULL,
    valid_until TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_code (code),
    INDEX idx_is_active (is_active),
    INDEX idx_valid_dates (valid_from, valid_until)
);

-- ========================================
-- Таблица за използвани купони (Coupon Usage)
-- ========================================
CREATE TABLE coupon_usage (
    usage_id INT AUTO_INCREMENT PRIMARY KEY,
    coupon_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT NOT NULL,
    discount_amount DECIMAL(10, 2) NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    INDEX idx_coupon_id (coupon_id),
    INDEX idx_user_id (user_id),
    INDEX idx_order_id (order_id)
);

-- ========================================
-- Таблица за списък с желания (Wishlist)
-- ========================================
CREATE TABLE wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_product_wishlist (user_id, product_id),
    INDEX idx_user_id (user_id),
    INDEX idx_product_id (product_id)
);

-- ========================================
-- Добавяне на тригери за автоматично обновяване на статистики
-- ========================================

-- Тригер за обновяване на рейтинга на продукти при добавяне на отзив
DELIMITER //
CREATE TRIGGER update_product_rating_after_review_insert
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    UPDATE products 
    SET rating = (
        SELECT AVG(rating) 
        FROM reviews 
        WHERE product_id = NEW.product_id AND is_approved = TRUE
    ),
    review_count = (
        SELECT COUNT(*) 
        FROM reviews 
        WHERE product_id = NEW.product_id AND is_approved = TRUE
    )
    WHERE product_id = NEW.product_id;
END//

-- Тригер за обновяване на рейтинга на продукти при обновяване на отзив
CREATE TRIGGER update_product_rating_after_review_update
AFTER UPDATE ON reviews
FOR EACH ROW
BEGIN
    UPDATE products 
    SET rating = (
        SELECT AVG(rating) 
        FROM reviews 
        WHERE product_id = NEW.product_id AND is_approved = TRUE
    ),
    review_count = (
        SELECT COUNT(*) 
        FROM reviews 
        WHERE product_id = NEW.product_id AND is_approved = TRUE
    )
    WHERE product_id = NEW.product_id;
END//

-- Тригер за обновяване на общата цена в order_items
CREATE TRIGGER update_order_item_total_price
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    SET NEW.total_price = NEW.quantity * NEW.unit_price;
END//

CREATE TRIGGER update_order_item_total_price_on_update
BEFORE UPDATE ON order_items
FOR EACH ROW
BEGIN
    SET NEW.total_price = NEW.quantity * NEW.unit_price;
END//

DELIMITER ;

-- ========================================
-- Създаване на view-та за често използвани заявки
-- ========================================

-- View за активни продукти с информация за категорията
CREATE VIEW active_products_with_category AS
SELECT 
    p.product_id,
    p.name as product_name,
    p.description,
    p.price,
    p.discount_price,
    p.stock_quantity,
    p.rating,
    p.review_count,
    c.name as category_name,
    c.category_id,
    (SELECT image_url FROM product_images WHERE product_id = p.product_id AND is_primary = TRUE LIMIT 1) as primary_image
FROM products p
JOIN categories c ON p.category_id = c.category_id
WHERE p.is_active = TRUE AND c.is_active = TRUE;

-- View за поръчки с детайли за потребителя
CREATE VIEW orders_with_user_details AS
SELECT 
    o.order_id,
    o.order_number,
    o.order_status,
    o.payment_status,
    o.total_amount,
    o.created_at,
    u.username,
    u.email,
    u.first_name,
    u.last_name,
    COUNT(oi.order_item_id) as total_items
FROM orders o
JOIN users u ON o.user_id = u.user_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id;

-- ========================================
-- Примерни данни за тестване
-- ========================================

-- Добавяне на категории
INSERT INTO categories (name, description, parent_category_id, sort_order) VALUES
('Електроника', 'Електронни устройства и аксесоари', NULL, 1),
('Компютри', 'Настолни и преносими компютри', 1, 1),
('Телефони', 'Смартфони и аксесоари', 1, 2),
('Дрехи', 'Мъжки и дамски дрехи', NULL, 2),
('Мъжки дрехи', 'Дрехи за мъже', 4, 1),
('Дамски дрехи', 'Дрехи за жени', 4, 2),
('Домакинство', 'Продукти за дома', NULL, 3);

-- Добавяне на потребители
INSERT INTO users (username, email, password_hash, first_name, last_name, phone, birth_date, gender) VALUES
('ivan_petrov', 'ivan.petrov@example.com', '$2y$10$example_hash_1', 'Иван', 'Петров', '+359888123456', '1990-05-15', 'male'),
('maria_georgieva', 'maria.georgieva@example.com', '$2y$10$example_hash_2', 'Мария', 'Георгиева', '+359888234567', '1985-08-22', 'female'),
('petar_dimitrov', 'petar.dimitrov@example.com', '$2y$10$example_hash_3', 'Петър', 'Димитров', '+359888345678', '1995-12-03', 'male');

-- Добавяне на адреси
INSERT INTO addresses (user_id, address_type, street_address, city, postal_code, country, is_default) VALUES
(1, 'both', 'ул. Витоша 15, ап. 5', 'София', '1000', 'Bulgaria', TRUE),
(2, 'both', 'бул. Христо Ботев 25', 'Пловдив', '4000', 'Bulgaria', TRUE),
(3, 'both', 'ул. Князь Борис I 10', 'Варна', '9000', 'Bulgaria', TRUE);

-- Добавяне на продукти
INSERT INTO products (category_id, name, description, short_description, sku, price, stock_quantity, weight, is_featured) VALUES
(2, 'Лаптоп Dell XPS 13', 'Високопроизводителен ултрабук с 13.3" дисплей', 'Компактен и мощен лаптоп за професионалисти', 'DELL-XPS13-001', 2499.99, 15, 1.2, TRUE),
(3, 'iPhone 15 Pro', 'Най-новия iPhone с А17 Pro чип', 'Флагмански смартфон от Apple', 'APPLE-IP15P-128', 1899.99, 25, 0.187, TRUE),
(5, 'Мъжка риза Nike', 'Спортна риза от висококачествен памук', 'Удобна риза за ежедневно носене', 'NIKE-SHIRT-M-L', 89.99, 50, 0.3, FALSE),
(6, 'Дамска рокля Zara', 'Елегантна рокля за специални поводи', 'Стилна рокля в черен цвят', 'ZARA-DRESS-W-M', 129.99, 30, 0.4, FALSE),
(7, 'Кафемашина DeLonghi', 'Автоматична кафемашина с капучинатор', 'Професионална кафемашина за дома', 'DELONGHI-CM-001', 899.99, 8, 8.5, TRUE);

-- Добавяне на изображения на продукти
INSERT INTO product_images (product_id, image_url, alt_text, is_primary, sort_order) VALUES
(1, '/images/products/dell-xps13-main.jpg', 'Dell XPS 13 основно изображение', TRUE, 1),
(1, '/images/products/dell-xps13-side.jpg', 'Dell XPS 13 странично изображение', FALSE, 2),
(2, '/images/products/iphone15pro-main.jpg', 'iPhone 15 Pro основно изображение', TRUE, 1),
(3, '/images/products/nike-shirt-main.jpg', 'Nike мъжка риза', TRUE, 1),
(4, '/images/products/zara-dress-main.jpg', 'Zara дамска рокля', TRUE, 1),
(5, '/images/products/delonghi-coffee-main.jpg', 'DeLonghi кафемашина', TRUE, 1);

-- Добавяне на купони
INSERT INTO coupons (code, name, description, discount_type, discount_value, min_order_amount, usage_limit, valid_from, valid_until) VALUES
('WELCOME10', 'Добре дошли отстъпка', '10% отстъпка за нови клиенти', 'percentage', 10.00, 100.00, 100, '2024-01-01 00:00:00', '2024-12-31 23:59:59'),
('SAVE50', 'Спести 50 лв', '50 лв отстъпка при покупка над 500 лв', 'fixed_amount', 50.00, 500.00, 50, '2024-06-01 00:00:00', '2024-06-30 23:59:59');

-- ========================================
-- Създаване на индекси за оптимизация
-- ========================================

-- Допълнителни индекси за по-добра производителност
CREATE INDEX idx_products_category_price ON products(category_id, price);
CREATE INDEX idx_products_featured_active ON products(is_featured, is_active);
CREATE INDEX idx_orders_user_status ON orders(user_id, order_status);
CREATE INDEX idx_orders_date_status ON orders(created_at, order_status);
CREATE INDEX idx_reviews_product_approved ON reviews(product_id, is_approved);

-- ========================================
-- Процедури за често използвани операции
-- ========================================

DELIMITER //

-- Процедура за добавяне на продукт в количката
CREATE PROCEDURE AddToCart(
    IN p_user_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    INSERT INTO shopping_cart (user_id, product_id, quantity)
    VALUES (p_user_id, p_product_id, p_quantity)
    ON DUPLICATE KEY UPDATE 
        quantity = quantity + p_quantity,
        updated_at = CURRENT_TIMESTAMP;
    
    COMMIT;
END//

-- Процедура за създаване на поръчка от количката
CREATE PROCEDURE CreateOrderFromCart(
    IN p_user_id INT,
    IN p_payment_method VARCHAR(50),
    IN p_billing_address_id INT,
    IN p_shipping_address_id INT,
    OUT p_order_id INT
)
BEGIN
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
    DECLARE v_tax_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE v_order_number VARCHAR(50);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Изчисляване на общата сума
    SELECT SUM(sc.quantity * p.price) INTO v_subtotal
    FROM shopping_cart sc
    JOIN products p ON sc.product_id = p.product_id
    WHERE sc.user_id = p_user_id;
    
    -- Изчисляване на ДДС (20%)
    SET v_tax_amount = v_subtotal * 0.20;
    SET v_total_amount = v_subtotal + v_tax_amount;
    
    -- Генериране на номер на поръчка
    SET v_order_number = CONCAT('ORD-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(FLOOR(RAND() * 10000), 4, '0'));
    
    -- Създаване на поръчката
    INSERT INTO orders (
        user_id, order_number, payment_method, subtotal, 
        tax_amount, total_amount, billing_address_id, shipping_address_id
    ) VALUES (
        p_user_id, v_order_number, p_payment_method, v_subtotal,
        v_tax_amount, v_total_amount, p_billing_address_id, p_shipping_address_id
    );
    
    SET p_order_id = LAST_INSERT_ID();
    
    -- Добавяне на елементи от количката към поръчката
    INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price)
    SELECT p_order_id, sc.product_id, sc.quantity, p.price, sc.quantity * p.price
    FROM shopping_cart sc
    JOIN products p ON sc.product_id = p.product_id
    WHERE sc.user_id = p_user_id;
    
    -- Изчистване на количката
    DELETE FROM shopping_cart WHERE user_id = p_user_id;
    
    COMMIT;
END//

DELIMITER ;

-- ========================================
-- Край на скрипта
-- ========================================