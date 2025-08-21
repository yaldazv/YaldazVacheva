-- Скрипт за валидация на базата данни
-- Проверява дали всички обекти са създадени правилно

USE QualityControlDB;
GO

PRINT '=== ВАЛИДАЦИЯ НА БАЗА ДАННИ ===';
PRINT '';

-- Проверка на таблици
PRINT 'Проверка на таблици:';
SELECT 
    'Таблица' as ObjectType,
    TABLE_NAME as ObjectName,
    'OK' as Status
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

PRINT '';

-- Проверка на изгледи
PRINT 'Проверка на изгледи:';
SELECT 
    'Изглед' as ObjectType,
    TABLE_NAME as ObjectName,
    'OK' as Status
FROM INFORMATION_SCHEMA.VIEWS 
ORDER BY TABLE_NAME;

PRINT '';

-- Проверка на процедури и функции
PRINT 'Проверка на процедури и функции:';
SELECT 
    CASE 
        WHEN ROUTINE_TYPE = 'PROCEDURE' THEN 'Процедура'
        WHEN ROUTINE_TYPE = 'FUNCTION' THEN 'Функция'
    END as ObjectType,
    ROUTINE_NAME as ObjectName,
    'OK' as Status
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_SCHEMA = 'dbo'
ORDER BY ROUTINE_TYPE, ROUTINE_NAME;

PRINT '';

-- Проверка на индекси
PRINT 'Проверка на индекси:';
SELECT 
    'Индекс' as ObjectType,
    i.name as ObjectName,
    t.name as TableName,
    'OK' as Status
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE i.index_id > 0 AND t.name IN (
    'Warehouses', 'Assortments', 'AssortmentParts', 'WeightBoundaries',
    'Batches', 'TestPackages', 'QualityTests', 'WeightMeasurements',
    'MarinationData', 'AuditLog'
)
ORDER BY t.name, i.name;

PRINT '';

-- Проверка на foreign key constraints
PRINT 'Проверка на foreign key връзки:';
SELECT 
    'FK Constraint' as ObjectType,
    fk.name as ObjectName,
    tp.name as ParentTable,
    tr.name as ReferencedTable,
    'OK' as Status
FROM sys.foreign_keys fk
INNER JOIN sys.tables tp ON fk.parent_object_id = tp.object_id
INNER JOIN sys.tables tr ON fk.referenced_object_id = tr.object_id
ORDER BY tp.name, fk.name;

PRINT '';

-- Проверка на check constraints
PRINT 'Проверка на check constraints:';
SELECT 
    'Check Constraint' as ObjectType,
    cc.name as ObjectName,
    t.name as TableName,
    'OK' as Status
FROM sys.check_constraints cc
INNER JOIN sys.tables t ON cc.parent_object_id = t.object_id
ORDER BY t.name, cc.name;

PRINT '';
PRINT '=== ВАЛИДАЦИЯТА ЗАВЪРШИ ===';
GO