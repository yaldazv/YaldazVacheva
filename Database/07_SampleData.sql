-- Примерни данни за тестване на системата
-- SQL Server 2012/2014 Compatible

USE QualityControlDB;
GO

-- Вмъкване на складове
INSERT INTO dbo.Warehouses (WarehouseName, WarehouseCode, Address) VALUES
('Склад София', 'SOF001', 'бул. България 1, София'),
('Склад Пловдив', 'PLV001', 'ул. Марица 15, Пловдив'),
('Склад Варна', 'VAR001', 'ул. Черно море 8, Варна');
GO

-- Вмъкване на асортименти
INSERT INTO dbo.Assortments (AssortmentName, AssortmentCode, Description, PiecesPerPackage, IsMarinated, HasMultipleParts, WarehouseID) VALUES
('Пилешко филе', 'PF001', 'Пилешко филе 80-110г', 10, 0, 0, 1),
('Пилешко бутче', 'PB001', 'Пилешко бутче горно/долно', 8, 0, 1, 1),
('Маринован свински врат', 'MSV001', 'Маринован свински врат парчета', 12, 1, 0, 2),
('Телешко филе', 'TF001', 'Телешко филе премиум', 6, 0, 0, 3);
GO

-- Вмъкване на части за многокомпонентни асортименти
INSERT INTO dbo.AssortmentParts (AssortmentID, PartName, PartOrder, PiecesPerPart) VALUES
(2, 'Горно бутче', 1, 4),
(2, 'Долно бутче', 2, 4);
GO

-- Вмъкване на границите на теглото
INSERT INTO dbo.WeightBoundaries (AssortmentID, PartID, MinWeight, MaxWeight, TargetWeight) VALUES
-- Пилешко филе
(1, NULL, 80.00, 110.00, 95.00),
-- Пилешко бутче - горно
(2, 1, 120.00, 150.00, 135.00),
-- Пилешко бутче - долно  
(2, 2, 100.00, 130.00, 115.00),
-- Маринован свински врат
(3, NULL, 90.00, 120.00, 105.00),
-- Телешко филе
(4, NULL, 150.00, 200.00, 175.00);
GO

-- Вмъкване на партиди
INSERT INTO dbo.Batches (BatchNumber, AssortmentID, ProductionDate, ExpiryDate) VALUES
('PF20240101', 1, '2024-01-01', '2024-01-15'),
('PB20240101', 2, '2024-01-01', '2024-01-10'),
('MSV20240102', 3, '2024-01-02', '2024-01-20'),
('TF20240103', 4, '2024-01-03', '2024-01-25');
GO

-- Вмъкване на тестови пакети
INSERT INTO dbo.TestPackages (PackageNumber, BatchID, PackageWeight, OriginalPackageWeight, TestDate, OperatorName, Status) VALUES
('PKG001', 1, 950.00, 975.00, '2024-01-01', 'Мария Петрова', 'Tested'),
('PKG002', 2, 1800.00, 1820.00, '2024-01-01', 'Иван Георгиев', 'Tested'),
('PKG003', 3, 1260.00, 1290.00, '2024-01-02', 'Елена Стоянова', 'Active'),
('PKG004', 4, 1050.00, 1070.00, '2024-01-03', 'Петър Николов', 'Active');
GO

-- Примерни тестове на качеството
INSERT INTO dbo.QualityTests (PackageID, TestNumber, TestDateTime, OperatorName, TotalPieces, TotalWeight, OriginalTotalWeight, IsWithinBoundaries, RequiredCorrection) VALUES
(1, 1, '2024-01-01 09:00:00', 'Мария Петрова', 10, 950.00, 975.00, 1, 1),
(1, 2, '2024-01-01 11:00:00', 'Мария Петрова', 10, 945.00, 970.00, 1, 1),
(2, 1, '2024-01-01 10:00:00', 'Иван Георгиев', 8, 1800.00, 1820.00, 1, 1),
(3, 1, '2024-01-02 08:30:00', 'Елена Стоянова', 12, 1260.00, 1290.00, 1, 1);
GO

-- Примерни измервания на тегло за пилешко филе (пакет 1, тест 1)
INSERT INTO dbo.WeightMeasurements (TestID, PartID, PieceNumber, MeasuredWeight, OriginalWeight, AdjustedWeight, IsWithinBoundaries, WasAdjusted) VALUES
(1, NULL, 1, 95.00, 98.00, 95.00, 1, 1),
(1, NULL, 2, 92.00, 92.00, NULL, 1, 0),
(1, NULL, 3, 88.00, 88.00, NULL, 1, 0),
(1, NULL, 4, 110.00, 115.00, 110.00, 1, 1),
(1, NULL, 5, 95.00, 95.00, NULL, 1, 0),
(1, NULL, 6, 97.00, 97.00, NULL, 1, 0),
(1, NULL, 7, 93.00, 93.00, NULL, 1, 0),
(1, NULL, 8, 89.00, 89.00, NULL, 1, 0),
(1, NULL, 9, 96.00, 96.00, NULL, 1, 0),
(1, NULL, 10, 95.00, 92.00, 95.00, 1, 1);
GO

-- Примерни измервания за пилешко бутче (пакет 2, тест 1)
-- Горно бутче
INSERT INTO dbo.WeightMeasurements (TestID, PartID, PieceNumber, MeasuredWeight, OriginalWeight, AdjustedWeight, IsWithinBoundaries, WasAdjusted) VALUES
(3, 1, 1, 135.00, 138.00, 135.00, 1, 1),
(3, 1, 2, 142.00, 142.00, NULL, 1, 0),
(3, 1, 3, 128.00, 128.00, NULL, 1, 0),
(3, 1, 4, 145.00, 145.00, NULL, 1, 0);
GO

-- Долно бутче
INSERT INTO dbo.WeightMeasurements (TestID, PartID, PieceNumber, MeasuredWeight, OriginalWeight, AdjustedWeight, IsWithinBoundaries, WasAdjusted) VALUES
(3, 2, 1, 115.00, 118.00, 115.00, 1, 1),
(3, 2, 2, 122.00, 122.00, NULL, 1, 0),
(3, 2, 3, 108.00, 108.00, NULL, 1, 0),
(3, 2, 4, 125.00, 125.00, NULL, 1, 0);
GO

-- Примерни данни за мариноване
INSERT INTO dbo.MarinationData (TestID, SampleSize, WeightBeforeMarination, WeightAfterMarination, YieldPercentage, TargetYieldPercentage, IsYieldAcceptable) VALUES
(4, 50, 5250.00, 4725.00, 90.00, 85.00, 1);
GO

-- Примерни записи в аудит лога
INSERT INTO dbo.AuditLog (TableName, RecordID, FieldName, OldValue, NewValue, ChangeType, ChangedBy) VALUES
('WeightMeasurements', 1, 'MeasuredWeight', '98.00', '95.00', 'UPDATE', 'Мария Петрова'),
('WeightMeasurements', 4, 'MeasuredWeight', '115.00', '110.00', 'UPDATE', 'Мария Петрова'),
('TestPackages', 1, 'Status', 'Active', 'Tested', 'UPDATE', 'Мария Петрова');
GO