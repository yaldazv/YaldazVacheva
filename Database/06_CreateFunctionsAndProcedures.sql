-- Създаване на функции и процедури
-- SQL Server 2012/2014 Compatible

USE QualityControlDB;
GO

-- Функция за проверка дали тегло е в границите
CREATE FUNCTION dbo.fn_IsWeightWithinBoundaries(
    @Weight decimal(8,2),
    @MinWeight decimal(8,2),
    @MaxWeight decimal(8,2)
)
RETURNS bit
AS
BEGIN
    DECLARE @Result bit = 0;
    
    IF @Weight >= @MinWeight AND @Weight <= @MaxWeight
        SET @Result = 1;
    
    RETURN @Result;
END
GO

-- Функция за изчисляване на рандеман
CREATE FUNCTION dbo.fn_CalculateYieldPercentage(
    @WeightBefore decimal(8,2),
    @WeightAfter decimal(8,2)
)
RETURNS decimal(5,2)
AS
BEGIN
    DECLARE @YieldPercentage decimal(5,2) = 0;
    
    IF @WeightBefore > 0
        SET @YieldPercentage = (@WeightAfter / @WeightBefore) * 100;
    
    RETURN @YieldPercentage;
END
GO

-- Функция за корекция на тегло в границите
CREATE FUNCTION dbo.fn_AdjustWeightToBoundaries(
    @OriginalWeight decimal(8,2),
    @MinWeight decimal(8,2),
    @MaxWeight decimal(8,2),
    @TargetWeight decimal(8,2) = NULL
)
RETURNS decimal(8,2)
AS
BEGIN
    DECLARE @AdjustedWeight decimal(8,2) = @OriginalWeight;
    
    -- Ако има целево тегло, използваме го
    IF @TargetWeight IS NOT NULL AND @TargetWeight >= @MinWeight AND @TargetWeight <= @MaxWeight
    BEGIN
        SET @AdjustedWeight = @TargetWeight;
    END
    ELSE
    BEGIN
        -- Ако теглото е под минимума, задаваме минимума
        IF @OriginalWeight < @MinWeight
            SET @AdjustedWeight = @MinWeight;
        
        -- Ако теглото е над максимума, задаваме максимума
        IF @OriginalWeight > @MaxWeight
            SET @AdjustedWeight = @MaxWeight;
    END
    
    RETURN @AdjustedWeight;
END
GO

-- Процедура за създаване на нов тест
CREATE PROCEDURE dbo.sp_CreateQualityTest
    @PackageID int,
    @TestNumber int,
    @OperatorName nvarchar(100),
    @TotalPieces int,
    @TestID int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO dbo.QualityTests (
            PackageID,
            TestNumber,
            TestDateTime,
            OperatorName,
            TotalPieces,
            TotalWeight,
            OriginalTotalWeight,
            IsWithinBoundaries,
            RequiredCorrection
        )
        VALUES (
            @PackageID,
            @TestNumber,
            GETDATE(),
            @OperatorName,
            @TotalPieces,
            0, -- Ще се актуализира след добавяне на измерванията
            0, -- Ще се актуализира след добавяне на измерванията
            0,
            0
        );
        
        SET @TestID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Процедура за добавяне на измерване на тегло
CREATE PROCEDURE dbo.sp_AddWeightMeasurement
    @TestID int,
    @PartID int = NULL,
    @PieceNumber int,
    @OriginalWeight decimal(8,2)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Получаваме границите за теглото
        DECLARE @MinWeight decimal(8,2), @MaxWeight decimal(8,2), @TargetWeight decimal(8,2);
        DECLARE @AssortmentID int;
        
        SELECT @AssortmentID = b.AssortmentID
        FROM dbo.QualityTests qt
        INNER JOIN dbo.TestPackages tp ON qt.PackageID = tp.PackageID
        INNER JOIN dbo.Batches b ON tp.BatchID = b.BatchID
        WHERE qt.TestID = @TestID;
        
        SELECT @MinWeight = MinWeight, @MaxWeight = MaxWeight, @TargetWeight = TargetWeight
        FROM dbo.WeightBoundaries
        WHERE AssortmentID = @AssortmentID 
        AND (PartID = @PartID OR (PartID IS NULL AND @PartID IS NULL))
        AND IsActive = 1;
        
        -- Проверяваме дали теглото е в границите
        DECLARE @IsWithinBoundaries bit = dbo.fn_IsWeightWithinBoundaries(@OriginalWeight, @MinWeight, @MaxWeight);
        
        -- Изчисляваме коригирано тегло ако е необходимо
        DECLARE @AdjustedWeight decimal(8,2) = NULL;
        DECLARE @WasAdjusted bit = 0;
        
        IF @IsWithinBoundaries = 0
        BEGIN
            SET @AdjustedWeight = dbo.fn_AdjustWeightToBoundaries(@OriginalWeight, @MinWeight, @MaxWeight, @TargetWeight);
            SET @WasAdjusted = 1;
        END
        
        INSERT INTO dbo.WeightMeasurements (
            TestID,
            PartID,
            PieceNumber,
            MeasuredWeight,
            OriginalWeight,
            AdjustedWeight,
            IsWithinBoundaries,
            WasAdjusted
        )
        VALUES (
            @TestID,
            @PartID,
            @PieceNumber,
            COALESCE(@AdjustedWeight, @OriginalWeight),
            @OriginalWeight,
            @AdjustedWeight,
            @IsWithinBoundaries,
            @WasAdjusted
        );
        
        -- Актуализираме общото тегло на теста
        UPDATE dbo.QualityTests
        SET 
            TotalWeight = (
                SELECT SUM(MeasuredWeight) 
                FROM dbo.WeightMeasurements 
                WHERE TestID = @TestID
            ),
            OriginalTotalWeight = (
                SELECT SUM(OriginalWeight) 
                FROM dbo.WeightMeasurements 
                WHERE TestID = @TestID
            ),
            IsWithinBoundaries = CASE 
                WHEN EXISTS (SELECT 1 FROM dbo.WeightMeasurements WHERE TestID = @TestID AND IsWithinBoundaries = 0)
                THEN 0 ELSE 1 
            END,
            RequiredCorrection = CASE 
                WHEN EXISTS (SELECT 1 FROM dbo.WeightMeasurements WHERE TestID = @TestID AND WasAdjusted = 1)
                THEN 1 ELSE 0 
            END
        WHERE TestID = @TestID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- Процедура за добавяне на данни за мариноване
CREATE PROCEDURE dbo.sp_AddMarinationData
    @TestID int,
    @SampleSize int,
    @WeightBeforeMarination decimal(8,2),
    @WeightAfterMarination decimal(8,2),
    @TargetYieldPercentage decimal(5,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Изчисляваме рандемана
        DECLARE @YieldPercentage decimal(5,2) = dbo.fn_CalculateYieldPercentage(@WeightBeforeMarination, @WeightAfterMarination);
        
        -- Проверяваме дали рандемана е приемлив
        DECLARE @IsYieldAcceptable bit = 1;
        IF @TargetYieldPercentage IS NOT NULL AND @YieldPercentage < @TargetYieldPercentage
            SET @IsYieldAcceptable = 0;
        
        INSERT INTO dbo.MarinationData (
            TestID,
            SampleSize,
            WeightBeforeMarination,
            WeightAfterMarination,
            YieldPercentage,
            TargetYieldPercentage,
            IsYieldAcceptable
        )
        VALUES (
            @TestID,
            @SampleSize,
            @WeightBeforeMarination,
            @WeightAfterMarination,
            @YieldPercentage,
            @TargetYieldPercentage,
            @IsYieldAcceptable
        );
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO