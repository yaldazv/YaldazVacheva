-- Създаване на таблици за качествен контрол и тестове
-- SQL Server 2012/2014 Compatible

USE QualityControlDB;
GO

-- Таблица за пакети за тестване
CREATE TABLE dbo.TestPackages (
    PackageID int IDENTITY(1,1) PRIMARY KEY,
    PackageNumber nvarchar(50) NOT NULL,
    BatchID int NOT NULL,
    PackageWeight decimal(8,2), -- Общо тегло на пакета
    OriginalPackageWeight decimal(8,2), -- Реално тегло преди корекции
    TestDate date NOT NULL,
    OperatorName nvarchar(100) NOT NULL,
    Status nvarchar(20) DEFAULT 'Active', -- Active, Tested, Approved, Rejected
    Notes nvarchar(500),
    CreatedDate datetime2 DEFAULT GETDATE(),
    ModifiedDate datetime2 DEFAULT GETDATE(),
    
    CONSTRAINT FK_TestPackages_Batches 
        FOREIGN KEY (BatchID) REFERENCES dbo.Batches(BatchID),
    CONSTRAINT CK_TestPackages_Status 
        CHECK (Status IN ('Active', 'Tested', 'Approved', 'Rejected'))
);
GO

-- Таблица за тестове на качеството
CREATE TABLE dbo.QualityTests (
    TestID int IDENTITY(1,1) PRIMARY KEY,
    PackageID int NOT NULL,
    TestNumber int NOT NULL, -- 1, 2, 3, 4 (обикновено правят по 4 теста)
    TestDateTime datetime2 NOT NULL,
    OperatorName nvarchar(100) NOT NULL,
    TotalPieces int NOT NULL,
    TotalWeight decimal(8,2) NOT NULL,
    OriginalTotalWeight decimal(8,2) NOT NULL, -- Реално тегло преди корекции
    IsWithinBoundaries bit DEFAULT 0,
    RequiredCorrection bit DEFAULT 0,
    Notes nvarchar(500),
    CreatedDate datetime2 DEFAULT GETDATE(),
    
    CONSTRAINT FK_QualityTests_Packages 
        FOREIGN KEY (PackageID) REFERENCES dbo.TestPackages(PackageID),
    CONSTRAINT UK_QualityTests_Package_Number 
        UNIQUE (PackageID, TestNumber)
);
GO

-- Таблица за измервания на тегло на отделни парчета
CREATE TABLE dbo.WeightMeasurements (
    MeasurementID int IDENTITY(1,1) PRIMARY KEY,
    TestID int NOT NULL,
    PartID int NULL, -- NULL за еднокомпонентни асортименти
    PieceNumber int NOT NULL,
    MeasuredWeight decimal(8,2) NOT NULL,
    OriginalWeight decimal(8,2) NOT NULL, -- Реално измерено тегло
    AdjustedWeight decimal(8,2), -- Коригирано тегло (ако е необходимо)
    IsWithinBoundaries bit DEFAULT 0,
    WasAdjusted bit DEFAULT 0,
    CreatedDate datetime2 DEFAULT GETDATE(),
    
    CONSTRAINT FK_WeightMeasurements_Tests 
        FOREIGN KEY (TestID) REFERENCES dbo.QualityTests(TestID),
    CONSTRAINT FK_WeightMeasurements_Parts 
        FOREIGN KEY (PartID) REFERENCES dbo.AssortmentParts(PartID),
    CONSTRAINT UK_WeightMeasurements_Test_Part_Piece 
        UNIQUE (TestID, PartID, PieceNumber)
);
GO

-- Таблица за данни за мариноване
CREATE TABLE dbo.MarinationData (
    MarinationID int IDENTITY(1,1) PRIMARY KEY,
    TestID int NOT NULL,
    SampleSize int NOT NULL DEFAULT 50, -- Брой парчета в пробата
    WeightBeforeMarination decimal(8,2) NOT NULL,
    WeightAfterMarination decimal(8,2) NOT NULL,
    YieldPercentage decimal(5,2) NOT NULL,
    TargetYieldPercentage decimal(5,2),
    IsYieldAcceptable bit DEFAULT 0,
    Notes nvarchar(500),
    CreatedDate datetime2 DEFAULT GETDATE(),
    
    CONSTRAINT FK_MarinationData_Tests 
        FOREIGN KEY (TestID) REFERENCES dbo.QualityTests(TestID),
    CONSTRAINT CK_MarinationData_SampleSize 
        CHECK (SampleSize > 0),
    CONSTRAINT CK_MarinationData_Weights 
        CHECK (WeightBeforeMarination > 0 AND WeightAfterMarination >= 0),
    CONSTRAINT CK_MarinationData_Yield 
        CHECK (YieldPercentage >= 0 AND YieldPercentage <= 100)
);
GO

-- Таблица за аудит на промени
CREATE TABLE dbo.AuditLog (
    AuditID int IDENTITY(1,1) PRIMARY KEY,
    TableName nvarchar(100) NOT NULL,
    RecordID int NOT NULL,
    FieldName nvarchar(100),
    OldValue nvarchar(500),
    NewValue nvarchar(500),
    ChangeType nvarchar(20) NOT NULL, -- INSERT, UPDATE, DELETE
    ChangedBy nvarchar(100) NOT NULL,
    ChangeDate datetime2 DEFAULT GETDATE(),
    
    CONSTRAINT CK_AuditLog_ChangeType 
        CHECK (ChangeType IN ('INSERT', 'UPDATE', 'DELETE'))
);
GO