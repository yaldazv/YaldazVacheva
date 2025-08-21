-- Създаване на основни таблици
-- SQL Server 2012/2014 Compatible

USE QualityControlDB;
GO

-- Таблица за складове
CREATE TABLE dbo.Warehouses (
    WarehouseID int IDENTITY(1,1) PRIMARY KEY,
    WarehouseName nvarchar(100) NOT NULL,
    WarehouseCode nvarchar(20) NOT NULL UNIQUE,
    Address nvarchar(255),
    IsActive bit DEFAULT 1,
    CreatedDate datetime2 DEFAULT GETDATE(),
    ModifiedDate datetime2 DEFAULT GETDATE()
);
GO

-- Таблица за асортименти
CREATE TABLE dbo.Assortments (
    AssortmentID int IDENTITY(1,1) PRIMARY KEY,
    AssortmentName nvarchar(200) NOT NULL,
    AssortmentCode nvarchar(50) NOT NULL UNIQUE,
    Description nvarchar(500),
    PiecesPerPackage int NOT NULL,
    IsMarinated bit DEFAULT 0,
    HasMultipleParts bit DEFAULT 0,
    WarehouseID int NOT NULL,
    IsActive bit DEFAULT 1,
    CreatedDate datetime2 DEFAULT GETDATE(),
    ModifiedDate datetime2 DEFAULT GETDATE(),
    
    CONSTRAINT FK_Assortments_Warehouses 
        FOREIGN KEY (WarehouseID) REFERENCES dbo.Warehouses(WarehouseID)
);
GO

-- Таблица за части на асортименти (например горно и долно бутче)
CREATE TABLE dbo.AssortmentParts (
    PartID int IDENTITY(1,1) PRIMARY KEY,
    AssortmentID int NOT NULL,
    PartName nvarchar(100) NOT NULL,
    PartOrder int NOT NULL,
    PiecesPerPart int NOT NULL,
    IsActive bit DEFAULT 1,
    CreatedDate datetime2 DEFAULT GETDATE(),
    
    CONSTRAINT FK_AssortmentParts_Assortments 
        FOREIGN KEY (AssortmentID) REFERENCES dbo.Assortments(AssortmentID),
    CONSTRAINT UK_AssortmentParts_Order 
        UNIQUE (AssortmentID, PartOrder)
);
GO

-- Таблица за границите на теглото
CREATE TABLE dbo.WeightBoundaries (
    BoundaryID int IDENTITY(1,1) PRIMARY KEY,
    AssortmentID int NOT NULL,
    PartID int NULL, -- NULL означава цял асортимент, иначе специфична част
    MinWeight decimal(8,2) NOT NULL,
    MaxWeight decimal(8,2) NOT NULL,
    TargetWeight decimal(8,2),
    IsActive bit DEFAULT 1,
    CreatedDate datetime2 DEFAULT GETDATE(),
    ModifiedDate datetime2 DEFAULT GETDATE(),
    
    CONSTRAINT FK_WeightBoundaries_Assortments 
        FOREIGN KEY (AssortmentID) REFERENCES dbo.Assortments(AssortmentID),
    CONSTRAINT FK_WeightBoundaries_Parts 
        FOREIGN KEY (PartID) REFERENCES dbo.AssortmentParts(PartID),
    CONSTRAINT CK_WeightBoundaries_MinMax 
        CHECK (MinWeight <= MaxWeight),
    CONSTRAINT CK_WeightBoundaries_Target 
        CHECK (TargetWeight IS NULL OR (TargetWeight >= MinWeight AND TargetWeight <= MaxWeight))
);
GO

-- Таблица за партиди
CREATE TABLE dbo.Batches (
    BatchID int IDENTITY(1,1) PRIMARY KEY,
    BatchNumber nvarchar(50) NOT NULL,
    AssortmentID int NOT NULL,
    ProductionDate date NOT NULL,
    ExpiryDate date,
    Notes nvarchar(500),
    IsActive bit DEFAULT 1,
    CreatedDate datetime2 DEFAULT GETDATE(),
    
    CONSTRAINT FK_Batches_Assortments 
        FOREIGN KEY (AssortmentID) REFERENCES dbo.Assortments(AssortmentID),
    CONSTRAINT UK_Batches_Number_Date 
        UNIQUE (BatchNumber, AssortmentID, ProductionDate)
);
GO