-- Създаване на изгледи за лесен достъп до данни
-- SQL Server 2012/2014 Compatible

USE QualityControlDB;
GO

-- Изглед за пълна информация за асортиментите
CREATE VIEW dbo.vw_AssortmentDetails AS
SELECT 
    a.AssortmentID,
    a.AssortmentName,
    a.AssortmentCode,
    a.Description,
    a.PiecesPerPackage,
    a.IsMarinated,
    a.HasMultipleParts,
    w.WarehouseName,
    w.WarehouseCode,
    a.IsActive,
    a.CreatedDate
FROM dbo.Assortments a
INNER JOIN dbo.Warehouses w ON a.WarehouseID = w.WarehouseID;
GO

-- Изглед за границите на теглото с детайли
CREATE VIEW dbo.vw_WeightBoundariesDetails AS
SELECT 
    wb.BoundaryID,
    a.AssortmentName,
    a.AssortmentCode,
    ap.PartName,
    wb.MinWeight,
    wb.MaxWeight,
    wb.TargetWeight,
    wb.IsActive
FROM dbo.WeightBoundaries wb
INNER JOIN dbo.Assortments a ON wb.AssortmentID = a.AssortmentID
LEFT JOIN dbo.AssortmentParts ap ON wb.PartID = ap.PartID;
GO

-- Изглед за тестове с детайли
CREATE VIEW dbo.vw_QualityTestDetails AS
SELECT 
    qt.TestID,
    tp.PackageNumber,
    b.BatchNumber,
    a.AssortmentName,
    a.AssortmentCode,
    w.WarehouseName,
    qt.TestNumber,
    qt.TestDateTime,
    qt.OperatorName,
    qt.TotalPieces,
    qt.TotalWeight,
    qt.OriginalTotalWeight,
    qt.IsWithinBoundaries,
    qt.RequiredCorrection,
    tp.Status as PackageStatus
FROM dbo.QualityTests qt
INNER JOIN dbo.TestPackages tp ON qt.PackageID = tp.PackageID
INNER JOIN dbo.Batches b ON tp.BatchID = b.BatchID
INNER JOIN dbo.Assortments a ON b.AssortmentID = a.AssortmentID
INNER JOIN dbo.Warehouses w ON a.WarehouseID = w.WarehouseID;
GO

-- Изглед за измервания на тегло с детайли
CREATE VIEW dbo.vw_WeightMeasurementDetails AS
SELECT 
    wm.MeasurementID,
    qt.TestID,
    tp.PackageNumber,
    b.BatchNumber,
    a.AssortmentName,
    ap.PartName,
    wm.PieceNumber,
    wm.MeasuredWeight,
    wm.OriginalWeight,
    wm.AdjustedWeight,
    wm.IsWithinBoundaries,
    wm.WasAdjusted,
    wb.MinWeight,
    wb.MaxWeight,
    wb.TargetWeight
FROM dbo.WeightMeasurements wm
INNER JOIN dbo.QualityTests qt ON wm.TestID = qt.TestID
INNER JOIN dbo.TestPackages tp ON qt.PackageID = tp.PackageID
INNER JOIN dbo.Batches b ON tp.BatchID = b.BatchID
INNER JOIN dbo.Assortments a ON b.AssortmentID = a.AssortmentID
LEFT JOIN dbo.AssortmentParts ap ON wm.PartID = ap.PartID
LEFT JOIN dbo.WeightBoundaries wb ON a.AssortmentID = wb.AssortmentID 
    AND (wb.PartID = wm.PartID OR (wb.PartID IS NULL AND wm.PartID IS NULL));
GO

-- Изглед за данни за мариноване с детайли
CREATE VIEW dbo.vw_MarinationDetails AS
SELECT 
    md.MarinationID,
    qt.TestID,
    tp.PackageNumber,
    b.BatchNumber,
    a.AssortmentName,
    md.SampleSize,
    md.WeightBeforeMarination,
    md.WeightAfterMarination,
    md.YieldPercentage,
    md.TargetYieldPercentage,
    md.IsYieldAcceptable,
    qt.TestDateTime,
    qt.OperatorName
FROM dbo.MarinationData md
INNER JOIN dbo.QualityTests qt ON md.TestID = qt.TestID
INNER JOIN dbo.TestPackages tp ON qt.PackageID = tp.PackageID
INNER JOIN dbo.Batches b ON tp.BatchID = b.BatchID
INNER JOIN dbo.Assortments a ON b.AssortmentID = a.AssortmentID;
GO

-- Изглед за дневни отчети
CREATE VIEW dbo.vw_DailyReports AS
SELECT 
    CAST(qt.TestDateTime AS date) as TestDate,
    w.WarehouseName,
    a.AssortmentName,
    COUNT(DISTINCT tp.PackageID) as PackagesTested,
    COUNT(qt.TestID) as TotalTests,
    SUM(CASE WHEN qt.IsWithinBoundaries = 1 THEN 1 ELSE 0 END) as TestsWithinBoundaries,
    SUM(CASE WHEN qt.RequiredCorrection = 1 THEN 1 ELSE 0 END) as TestsRequiringCorrection,
    AVG(qt.TotalWeight) as AveragePackageWeight
FROM dbo.QualityTests qt
INNER JOIN dbo.TestPackages tp ON qt.PackageID = tp.PackageID
INNER JOIN dbo.Batches b ON tp.BatchID = b.BatchID
INNER JOIN dbo.Assortments a ON b.AssortmentID = a.AssortmentID
INNER JOIN dbo.Warehouses w ON a.WarehouseID = w.WarehouseID
GROUP BY 
    CAST(qt.TestDateTime AS date),
    w.WarehouseName,
    a.AssortmentName;
GO