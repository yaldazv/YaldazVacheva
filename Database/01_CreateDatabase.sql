-- Създаване на база данни за система за контрол на качеството
-- SQL Server 2012/2014 Compatible

USE master;
GO

-- Създаване на база данни, ако не съществува
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'QualityControlDB')
BEGIN
    CREATE DATABASE QualityControlDB
    ON 
    ( NAME = 'QualityControlDB_Data',
      FILENAME = 'C:\Database\QualityControlDB.mdf',
      SIZE = 100MB,
      MAXSIZE = 1GB,
      FILEGROWTH = 10MB )
    LOG ON 
    ( NAME = 'QualityControlDB_Log',
      FILENAME = 'C:\Database\QualityControlDB.ldf',
      SIZE = 10MB,
      FILEGROWTH = 10% );
END
GO

USE QualityControlDB;
GO

-- Настройки за база данни
ALTER DATABASE QualityControlDB SET RECOVERY SIMPLE;
GO