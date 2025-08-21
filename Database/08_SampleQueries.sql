-- Примерни заявки за извличане на данни от системата
-- SQL Server 2012/2014 Compatible

USE QualityControlDB;
GO

-- 1. Показване на всички асортименти с техните складове
SELECT * FROM dbo.vw_AssortmentDetails;
GO

-- 2. Показване на границите на теглото за всички асортименти
SELECT * FROM dbo.vw_WeightBoundariesDetails WHERE IsActive = 1;
GO

-- 3. Показване на всички тестове за качество за определена дата
SELECT * FROM dbo.vw_QualityTestDetails 
WHERE CAST(TestDateTime AS date) = '2024-01-01'
ORDER BY TestDateTime;
GO

-- 4. Показване на измервания, които са изисквали корекция
SELECT * FROM dbo.vw_WeightMeasurementDetails 
WHERE WasAdjusted = 1;
GO

-- 5. Показване на данни за мариноване
SELECT * FROM dbo.vw_MarinationDetails;
GO

-- 6. Дневен отчет за всички складове
SELECT * FROM dbo.vw_DailyReports 
WHERE TestDate = '2024-01-01'
ORDER BY WarehouseName, AssortmentName;
GO

-- 7. Статистика за тестове по асортимент
SELECT 
    AssortmentName,
    COUNT(*) as TotalTests,
    SUM(CASE WHEN IsWithinBoundaries = 1 THEN 1 ELSE 0 END) as TestsWithinBoundaries,
    SUM(CASE WHEN RequiredCorrection = 1 THEN 1 ELSE 0 END) as TestsWithCorrection,
    AVG(TotalWeight) as AverageWeight,
    AVG(OriginalTotalWeight) as AverageOriginalWeight
FROM dbo.vw_QualityTestDetails
GROUP BY AssortmentName
ORDER BY AssortmentName;
GO

-- 8. Намиране на парчета извън границите
SELECT 
    AssortmentName,
    PartName,
    PieceNumber,
    OriginalWeight,
    MeasuredWeight,
    MinWeight,
    MaxWeight,
    CASE 
        WHEN OriginalWeight < MinWeight THEN 'Под минимума'
        WHEN OriginalWeight > MaxWeight THEN 'Над максимума'
        ELSE 'В границите'
    END as WeightStatus
FROM dbo.vw_WeightMeasurementDetails
WHERE IsWithinBoundaries = 0 OR WasAdjusted = 1
ORDER BY AssortmentName, PartName, PieceNumber;
GO

-- 9. Анализ на рандемана при мариноване
SELECT 
    AssortmentName,
    AVG(YieldPercentage) as AverageYield,
    MIN(YieldPercentage) as MinYield,
    MAX(YieldPercentage) as MaxYield,
    COUNT(*) as TotalTests,
    SUM(CASE WHEN IsYieldAcceptable = 1 THEN 1 ELSE 0 END) as AcceptableTests
FROM dbo.vw_MarinationDetails
GROUP BY AssortmentName;
GO

-- 10. Месечен отчет за качество
SELECT 
    YEAR(TestDate) as Year,
    MONTH(TestDate) as Month,
    WarehouseName,
    COUNT(DISTINCT AssortmentName) as DifferentAssortments,
    SUM(PackagesTested) as TotalPackages,
    SUM(TotalTests) as TotalTests,
    CAST(SUM(TestsWithinBoundaries) * 100.0 / SUM(TotalTests) AS decimal(5,2)) as PercentWithinBoundaries
FROM dbo.vw_DailyReports
WHERE TestDate >= '2024-01-01' AND TestDate < '2024-02-01'
GROUP BY YEAR(TestDate), MONTH(TestDate), WarehouseName
ORDER BY Year, Month, WarehouseName;
GO

-- 11. Актуални партиди по асортимент
SELECT 
    a.AssortmentName,
    b.BatchNumber,
    b.ProductionDate,
    b.ExpiryDate,
    DATEDIFF(day, GETDATE(), b.ExpiryDate) as DaysToExpiry,
    COUNT(tp.PackageID) as PackagesTested
FROM dbo.Assortments a
INNER JOIN dbo.Batches b ON a.AssortmentID = b.AssortmentID
LEFT JOIN dbo.TestPackages tp ON b.BatchID = tp.BatchID
WHERE b.IsActive = 1 AND b.ExpiryDate >= GETDATE()
GROUP BY a.AssortmentName, b.BatchNumber, b.ProductionDate, b.ExpiryDate
ORDER BY a.AssortmentName, b.ProductionDate;
GO

-- 12. Операторски отчет
SELECT 
    qt.OperatorName,
    COUNT(*) as TotalTests,
    COUNT(DISTINCT tp.PackageID) as PackagesTested,
    AVG(qt.TotalWeight) as AveragePackageWeight,
    SUM(CASE WHEN qt.IsWithinBoundaries = 1 THEN 1 ELSE 0 END) as TestsWithinBoundaries,
    CAST(SUM(CASE WHEN qt.IsWithinBoundaries = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS decimal(5,2)) as PercentAccuracy
FROM dbo.QualityTests qt
INNER JOIN dbo.TestPackages tp ON qt.PackageID = tp.PackageID
WHERE qt.TestDateTime >= DATEADD(day, -30, GETDATE())
GROUP BY qt.OperatorName
ORDER BY qt.OperatorName;
GO