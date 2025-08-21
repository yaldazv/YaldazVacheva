-- Създаване на индекси за оптимизация
-- SQL Server 2012/2014 Compatible

USE QualityControlDB;
GO

-- Индекси за Warehouses
CREATE NONCLUSTERED INDEX IX_Warehouses_Code ON dbo.Warehouses(WarehouseCode);
CREATE NONCLUSTERED INDEX IX_Warehouses_Active ON dbo.Warehouses(IsActive);
GO

-- Индекси за Assortments
CREATE NONCLUSTERED INDEX IX_Assortments_Code ON dbo.Assortments(AssortmentCode);
CREATE NONCLUSTERED INDEX IX_Assortments_Warehouse ON dbo.Assortments(WarehouseID);
CREATE NONCLUSTERED INDEX IX_Assortments_Marinated ON dbo.Assortments(IsMarinated);
CREATE NONCLUSTERED INDEX IX_Assortments_Active ON dbo.Assortments(IsActive);
GO

-- Индекси за AssortmentParts
CREATE NONCLUSTERED INDEX IX_AssortmentParts_Assortment ON dbo.AssortmentParts(AssortmentID);
CREATE NONCLUSTERED INDEX IX_AssortmentParts_Active ON dbo.AssortmentParts(IsActive);
GO

-- Индекси за WeightBoundaries
CREATE NONCLUSTERED INDEX IX_WeightBoundaries_Assortment ON dbo.WeightBoundaries(AssortmentID);
CREATE NONCLUSTERED INDEX IX_WeightBoundaries_Part ON dbo.WeightBoundaries(PartID);
CREATE NONCLUSTERED INDEX IX_WeightBoundaries_Active ON dbo.WeightBoundaries(IsActive);
GO

-- Индекси за Batches
CREATE NONCLUSTERED INDEX IX_Batches_Assortment ON dbo.Batches(AssortmentID);
CREATE NONCLUSTERED INDEX IX_Batches_ProductionDate ON dbo.Batches(ProductionDate);
CREATE NONCLUSTERED INDEX IX_Batches_BatchNumber ON dbo.Batches(BatchNumber);
CREATE NONCLUSTERED INDEX IX_Batches_Active ON dbo.Batches(IsActive);
GO

-- Индекси за TestPackages
CREATE NONCLUSTERED INDEX IX_TestPackages_Batch ON dbo.TestPackages(BatchID);
CREATE NONCLUSTERED INDEX IX_TestPackages_TestDate ON dbo.TestPackages(TestDate);
CREATE NONCLUSTERED INDEX IX_TestPackages_Status ON dbo.TestPackages(Status);
CREATE NONCLUSTERED INDEX IX_TestPackages_Operator ON dbo.TestPackages(OperatorName);
GO

-- Индекси за QualityTests
CREATE NONCLUSTERED INDEX IX_QualityTests_Package ON dbo.QualityTests(PackageID);
CREATE NONCLUSTERED INDEX IX_QualityTests_DateTime ON dbo.QualityTests(TestDateTime);
CREATE NONCLUSTERED INDEX IX_QualityTests_Operator ON dbo.QualityTests(OperatorName);
CREATE NONCLUSTERED INDEX IX_QualityTests_Boundaries ON dbo.QualityTests(IsWithinBoundaries);
GO

-- Индекси за WeightMeasurements
CREATE NONCLUSTERED INDEX IX_WeightMeasurements_Test ON dbo.WeightMeasurements(TestID);
CREATE NONCLUSTERED INDEX IX_WeightMeasurements_Part ON dbo.WeightMeasurements(PartID);
CREATE NONCLUSTERED INDEX IX_WeightMeasurements_Boundaries ON dbo.WeightMeasurements(IsWithinBoundaries);
CREATE NONCLUSTERED INDEX IX_WeightMeasurements_Adjusted ON dbo.WeightMeasurements(WasAdjusted);
GO

-- Индекси за MarinationData
CREATE NONCLUSTERED INDEX IX_MarinationData_Test ON dbo.MarinationData(TestID);
CREATE NONCLUSTERED INDEX IX_MarinationData_Yield ON dbo.MarinationData(IsYieldAcceptable);
GO

-- Индекси за AuditLog
CREATE NONCLUSTERED INDEX IX_AuditLog_Table ON dbo.AuditLog(TableName);
CREATE NONCLUSTERED INDEX IX_AuditLog_RecordID ON dbo.AuditLog(RecordID);
CREATE NONCLUSTERED INDEX IX_AuditLog_ChangeDate ON dbo.AuditLog(ChangeDate);
CREATE NONCLUSTERED INDEX IX_AuditLog_ChangedBy ON dbo.AuditLog(ChangedBy);
GO