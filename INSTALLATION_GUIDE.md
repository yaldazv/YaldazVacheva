# Инсталационно ръководство / Installation Guide

## За бързо стартиране / Quick Start

### Стъпка 1: Изисквания / Requirements
- MySQL 8.0+ или MariaDB 10.3+
- Достъп до MySQL сървър със привилегии за създаване на база данни

### Стъпка 2: Създаване на базата данни / Database Creation

```bash
# Влизане в MySQL
mysql -u root -p

# Изпълняване на основния скрипт
source database_schema.sql

# Или ако сте в друга директория
source /path/to/database_schema.sql
```

### Стъпка 3: Тестване / Testing

```bash
# Изпълняване на тестовете
source test_database.sql
```

## Подробни инструкции / Detailed Instructions

### 1. Подготовка на средата / Environment Setup

```sql
-- Проверка на версията на MySQL
SELECT VERSION();

-- Проверка на настройките за кодиране
SHOW VARIABLES LIKE 'character_set%';
SHOW VARIABLES LIKE 'collation%';
```

### 2. Изпълняване на скрипта / Script Execution

Скриптът `database_schema.sql` ще създаде:
- База данни `ecommerce_db`
- 12 таблици с всички необходими връзки
- Индекси за оптимизация
- 4 тригера за автоматизация
- 2 view-та за често използвани заявки  
- 2 процедури за основни операции
- Примерни данни за тестване

### 3. Проверка на резултата / Verification

```sql
-- Преглед на всички таблици
USE ecommerce_db;
SHOW TABLES;

-- Проверка на примерните данни
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM categories;

-- Тест на view-тата
SELECT * FROM active_products_with_category LIMIT 3;
```

## Настройки за производство / Production Settings

### Оптимизация на производителността / Performance Optimization

```sql
-- Задаване на допълнителни параметри за производство
SET GLOBAL innodb_buffer_pool_size = 1G;
SET GLOBAL query_cache_type = ON;
SET GLOBAL query_cache_size = 256M;
```

### Сигурност / Security

```sql
-- Създаване на специфичен потребител за приложението
CREATE USER 'ecommerce_user'@'localhost' IDENTIFIED BY 'strong_password_here';
GRANT SELECT, INSERT, UPDATE, DELETE ON ecommerce_db.* TO 'ecommerce_user'@'localhost';
FLUSH PRIVILEGES;
```

### Backup и възстановяване / Backup and Restore

```bash
# Създаване на backup
mysqldump -u root -p ecommerce_db > ecommerce_backup.sql

# Възстановяване от backup
mysql -u root -p ecommerce_db < ecommerce_backup.sql
```

## Чести проблеми / Common Issues

### Проблем: "Access denied for user"
**Решение:** Проверете потребителското име и парола за MySQL

### Проблем: "Database already exists"
**Решение:** Скриптът използва `CREATE DATABASE IF NOT EXISTS`, така че това не е грешка

### Проблем: Кодиране на символите
**Решение:** Убедете се, че MySQL е настроен за UTF-8:
```sql
SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;
```

## Поддръжка / Maintenance

### Редовни задачи / Regular Tasks

```sql
-- Анализ на таблиците за оптимизация
ANALYZE TABLE products, orders, users;

-- Оптимизация на таблиците
OPTIMIZE TABLE products, orders, users;

-- Проверка на статистиките
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'ecommerce_db';
```

### Мониторинг / Monitoring

```sql
-- Проверка на активните връзки
SHOW PROCESSLIST;

-- Статистики за заявки
SHOW STATUS LIKE 'Com_%';

-- Проверка на бавни заявки
SHOW VARIABLES LIKE 'slow_query_log';
```

## Поддръжка / Support

За въпроси или проблеми, моля вижте:
- `DATABASE_README.md` - Подробна документация
- `SCHEMA_DIAGRAM.md` - Визуална схема на базата данни
- `test_database.sql` - Примери за използване