IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'actual_total_load' AND SCHEMA_NAME(schema_id) = 'elec')
    BEGIN 
        CREATE TABLE elec.actual_total_load (
        [DateTime(UTC)]     VARCHAR(400),
        [ResolutionCode]    VARCHAR(400),
        [AreaCode]          VARCHAR(400),
        [AreaDisplayName]   VARCHAR(400),
        [AreaTypeCode]      VARCHAR(400),
        [AreaMapCode]       VARCHAR(400),
        [TotalLoad[MW]]]    VARCHAR(400),
        [UpdateTime(UTC)]   VARCHAR(400)
        )
    END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'generation' AND SCHEMA_NAME(schema_id) = 'elec')
    BEGIN 
        CREATE TABLE elec.generation (
            [DateTime(UTC)]                 VARCHAR(400),
            [ResolutionCode]                VARCHAR(400),
            [AreaCode]                      VARCHAR(400),
            [AreaDisplayName]               VARCHAR(400),
            [AreaTypeCode]                  VARCHAR(400),
            [AreaMapCode]                   VARCHAR(400),
            [ProductionType]                VARCHAR(400),
            [ActualGenerationOutput[MW]]]   VARCHAR(400),
            [ActualConsumption[MW]]]        VARCHAR(400),
            [UpdateTime(UTC)]               VARCHAR(400)
        )
    END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'installed_capacity' AND SCHEMA_NAME(schema_id) = 'elec')
    BEGIN 
        CREATE TABLE elec.installed_capacity (
            [Year]                              VARCHAR(400),
            [TimeZone]                          VARCHAR(400),
            [ResolutionCode]                    VARCHAR(400),
            [AreaCode]                          VARCHAR(400),
            [AreaDisplayName]                   VARCHAR(400),
            [AreaTypeCode]                      VARCHAR(400),
            [AreaMapCode]                       VARCHAR(400),
            [ProductionType]                    VARCHAR(400),
            [AggregatedInstalledCapacity[MW]]]  VARCHAR(400),
            [UpdateTime(UTC)]                   VARCHAR(400)
        )
    END;


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'flow' AND SCHEMA_NAME(schema_id) = 'elec')
    BEGIN 
        CREATE TABLE elec.flow (
            [DateTime(UTC)]         VARCHAR(400),
            [ResolutionCode]        VARCHAR(400),
            [OutAreaCode]           VARCHAR(400),
            [OutAreaDisplayName]    VARCHAR(400),
            [OutAreaTypeCode]       VARCHAR(400),
            [OutAreaMapCode]        VARCHAR(400),
            [InAreaCode]            VARCHAR(400),
            [InAreaDisplayName]     VARCHAR(400),
            [InAreaTypeCode]        VARCHAR(400),
            [InAreaMapCode]         VARCHAR(400),
            [Flow[MW]]]             VARCHAR(400),
            [UpdateTime(UTC)]       VARCHAR(400)
        )
    END;


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'flow' AND SCHEMA_NAME(schema_id) = 'gas')
    BEGIN 
        CREATE TABLE gas.flow (
            [id]                                VARCHAR(400),
            [dataSet]                           VARCHAR(400),
            [indicator]                         VARCHAR(400),
            [periodType]                        VARCHAR(400),
            [periodFrom]                        VARCHAR(400),
            [periodTo]                          VARCHAR(400),
            [operatorKey]                       VARCHAR(400),
            [tsoEicCode]                        VARCHAR(400),
            [operatorLabel]                     VARCHAR(400),
            [pointKey]                          VARCHAR(400),
            [pointLabel]                        VARCHAR(400),
            [tsoItemIdentifier]                 VARCHAR(400),
            [directionKey]                      VARCHAR(400),
            [unit]                              VARCHAR(400),
            [itemRemarks]                       VARCHAR(MAX),
            [generalRemarks]                    VARCHAR(MAX),
            [value]                             VARCHAR(400),
            [lastUpdateDateTime]                VARCHAR(400),
            [isUnlimited]                       VARCHAR(400),
            [flowStatus]                        VARCHAR(400),
            [interruptionType]                  VARCHAR(400),
            [restorationInformation]            VARCHAR(MAX),
            [capacityType]                      VARCHAR(400),
            [capacityBookingStatus]             VARCHAR(400),
            [isCamRelevant]                     VARCHAR(400),
            [isNA]                              VARCHAR(400),
            [originalPeriodFrom]                VARCHAR(400),
            [isCmpRelevant]                     VARCHAR(400),
            [bookingPlatformKey]                VARCHAR(400),
            [bookingPlatformLabel]              VARCHAR(400),
            [bookingPlatformURL]                VARCHAR(MAX),
            [interruptionCalculationRemark]     VARCHAR(MAX),
            [pointType]                         VARCHAR(400),
            [idPointType]                       VARCHAR(400),
            [isArchived]                        VARCHAR(400)
        ) 
    END;


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'storage' AND SCHEMA_NAME(schema_id) = 'gas')
    BEGIN 
        CREATE TABLE gas.storage (
            [name]                  VARCHAR(400),
            [code]                  VARCHAR(400),
            [url]                   VARCHAR(MAX),
            [updatedAt]             VARCHAR(400),
            [gasDayStart]           VARCHAR(400),
            [gasDayEnd]             VARCHAR(400),
            [gasInStorage]          VARCHAR(400),
            [consumption]           VARCHAR(400),
            [consumptionFull]       VARCHAR(400),
            [injection]             VARCHAR(400),
            [withdrawal]            VARCHAR(400),
            [netWithdrawal]         VARCHAR(400),
            [workingGasVolume]      VARCHAR(400),
            [injectionCapacity]     VARCHAR(400),
            [withdrawalCapacity]    VARCHAR(400),
            [contractedCapacity]    VARCHAR(400),
            [availableCapacity]     VARCHAR(400),
            [coveredCapacity]       VARCHAR(400),
            [status]                VARCHAR(400),
            [trend]                 VARCHAR(400),
            [full]                  VARCHAR(400),
            [info]                  VARCHAR(MAX)
        )
    END;
