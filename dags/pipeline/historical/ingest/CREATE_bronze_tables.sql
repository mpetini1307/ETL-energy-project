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


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'operator_points' AND SCHEMA_NAME(schema_id) = 'gas')
    BEGIN 
        CREATE TABLE gas.operator_points (
            [pointKey]                                  VARCHAR(400),
            [pointLabel]                                VARCHAR(400),
            [operatorKey]                               VARCHAR(400),
            [tsoEicCode]                                VARCHAR(400),
            [operatorLabel]                             VARCHAR(400),
            [directionKey]                              VARCHAR(400),
            [validFrom]                                 VARCHAR(400),
            [validTo]                                   VARCHAR(400),
            [hasData]                                   VARCHAR(400),
            [isVirtualizedCommercially]                 VARCHAR(400),
            [virtualizedCommerciallySince]              VARCHAR(400),
            [isVirtualizedOperationally]                VARCHAR(400),
            [virtualizedOperationallySince]             VARCHAR(400),
            [isPipeInPipe]                              VARCHAR(400),
            [relatedOperators]                          VARCHAR(MAX),
            [relatedPoints]                             VARCHAR(MAX),
            [pipeInPipeWithTsoKey]                      VARCHAR(400),
            [pipeInPipeWithTsoLabel]                    VARCHAR(400),
            [isDoubleReporting]                         VARCHAR(400),
            [doubleReportingWithTsoKey]                 VARCHAR(400),
            [doubleReportingWithTsoLabel]               VARCHAR(400),
            [tsoItemIdentifier]                         VARCHAR(400),
            [tpTsoItemLabel]                            VARCHAR(400),
            [tpTsoValidFrom]                            VARCHAR(400),
            [tpTsoValidTo]                              VARCHAR(400),
            [tpTsoRemarks]                              VARCHAR(MAX),
            [tpTsoConversionFactor]                     VARCHAR(400),
            [tpRmkGridConversionFactorCapacityDefault]  VARCHAR(400),
            [tpTsoGCVMin]                               VARCHAR(400),
            [tpTsoGCVMax]                               VARCHAR(400),
            [tpTsoGCVRemarks]                           VARCHAR(MAX),
            [tpTsoGCVUnit]                              VARCHAR(400),
            [tpTsoEntryExitType]                        VARCHAR(400),
            [multiAnnualContractsIsAvailable]           VARCHAR(400),
            [multiAnnualContractsRemarks]               VARCHAR(MAX),
            [annualContractsIsAvailable]                VARCHAR(400),
            [annualContractsRemarks]                    VARCHAR(MAX),
            [halfAnnualContractsIsAvailable]            VARCHAR(400),
            [halfAnnualContractsRemarks]                VARCHAR(MAX),
            [quarterlyContractsIsAvailable]             VARCHAR(400),
            [quarterlyContractsRemarks]                 VARCHAR(MAX),
            [monthlyContractsIsAvailable]               VARCHAR(400),
            [monthlyContractsRemarks]                   VARCHAR(MAX),
            [dailyContractsIsAvailable]                 VARCHAR(400),
            [dailyContractsRemarks]                     VARCHAR(MAX),
            [dayAheadContractsIsAvailable]              VARCHAR(400),
            [dayAheadContractsRemarks]                  VARCHAR(MAX),
            [availableContractsRemarks]                 VARCHAR(MAX),
            [sentenceCMPUnsuccessful]                   VARCHAR(MAX),
            [sentenceCMPUnavailable]                    VARCHAR(MAX),
            [sentenceCMPAuction]                        VARCHAR(MAX),
            [sentenceCMPMadeAvailable]                  VARCHAR(MAX),
            [lastUpdateDateTime]                        VARCHAR(400),
            [isInvalid]                                 VARCHAR(400),
            [isCAMRelevant]                             VARCHAR(400),
            [isCMPRelevant]                             VARCHAR(400),
            [bookingPlatformKey]                        VARCHAR(400),
            [bookingPlatformLabel]                      VARCHAR(400),
            [bookingPlatformURL]                        VARCHAR(MAX),
            [virtualReverseFlow]                        VARCHAR(400),
            [virtualReverseFlowRemark]                  VARCHAR(MAX),
            [tSOCountry]                                VARCHAR(400),
            [tSOBalancingZone]                          VARCHAR(400),
            [crossBorderPointType]                      VARCHAR(400),
            [eURelationship]                            VARCHAR(400),
            [connectedOperators]                        VARCHAR(MAX),
            [adjacentTsoEic]                            VARCHAR(400),
            [adjacentOperatorKey]                       VARCHAR(400),
            [adjacentCountry]                           VARCHAR(400),
            [pointType]                                 VARCHAR(400),
            [idPointType]                               VARCHAR(400),
            [adjacentZones]                             VARCHAR(MAX),
            [id]                                        VARCHAR(400),
            [dataSet]                                   VARCHAR(400),
            [virtualPointKey]                           VARCHAR(400),
            [virtualPointLabel]                         VARCHAR(400),
            [pointId]                                   VARCHAR(400)
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


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'countries' AND SCHEMA_NAME(schema_id) = 'demo')
    BEGIN 
        CREATE TABLE demo.countries (
            [code]       VARCHAR(400),
            [pays]       VARCHAR(400),
            [latitude]   VARCHAR(400),
            [longitude]  VARCHAR(400)
        )
    END;


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'median_income' AND SCHEMA_NAME(schema_id) = 'demo')
    BEGIN 
        CREATE TABLE demo.median_income (
            [freq]              VARCHAR(400),
            [age]               VARCHAR(400),
            [sex]               VARCHAR(400),
            [statinfo]          VARCHAR(400),
            [unit]              VARCHAR(400),
            [geo\TIME_PERIOD]   VARCHAR(400),
            [1995] VARCHAR(400), [1996] VARCHAR(400), [1997] VARCHAR(400), [1998] VARCHAR(400),
            [1999] VARCHAR(400), [2000] VARCHAR(400), [2001] VARCHAR(400), [2003] VARCHAR(400),
            [2004] VARCHAR(400), [2005] VARCHAR(400), [2006] VARCHAR(400), [2007] VARCHAR(400),
            [2008] VARCHAR(400), [2009] VARCHAR(400), [2010] VARCHAR(400), [2011] VARCHAR(400),
            [2012] VARCHAR(400), [2013] VARCHAR(400), [2014] VARCHAR(400), [2015] VARCHAR(400),
            [2016] VARCHAR(400), [2017] VARCHAR(400), [2018] VARCHAR(400), [2019] VARCHAR(400),
            [2020] VARCHAR(400), [2021] VARCHAR(400), [2022] VARCHAR(400), [2023] VARCHAR(400),
            [2024] VARCHAR(400), [2025] VARCHAR(400)
        )
    END;

    
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'population' AND SCHEMA_NAME(schema_id) = 'demo')
    BEGIN 
        CREATE TABLE demo.population (
            [freq]              VARCHAR(400),
            [indic_de]          VARCHAR(400),
            [geo\TIME_PERIOD]   VARCHAR(400),
            [2015] VARCHAR(400), [2016] VARCHAR(400), [2017] VARCHAR(400), [2018] VARCHAR(400),
            [2019] VARCHAR(400), [2020] VARCHAR(400), [2021] VARCHAR(400), [2022] VARCHAR(400),
            [2023] VARCHAR(400), [2024] VARCHAR(400), [2025] VARCHAR(400), [2026] VARCHAR(400)
        )
    END;


IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ghg_emissions' AND SCHEMA_NAME(schema_id) = 'env')
    BEGIN 
        CREATE TABLE env.ghg_emissions (
            [freq]              VARCHAR(400),
            [src_crf]           VARCHAR(400),
            [unit]              VARCHAR(400),
            [geo\TIME_PERIOD]   VARCHAR(400),
            [1990] VARCHAR(400), [1991] VARCHAR(400), [1992] VARCHAR(400), [1993] VARCHAR(400),
            [1994] VARCHAR(400), [1995] VARCHAR(400), [1996] VARCHAR(400), [1997] VARCHAR(400),
            [1998] VARCHAR(400), [1999] VARCHAR(400), [2000] VARCHAR(400), [2001] VARCHAR(400),
            [2002] VARCHAR(400), [2003] VARCHAR(400), [2004] VARCHAR(400), [2005] VARCHAR(400),
            [2006] VARCHAR(400), [2007] VARCHAR(400), [2008] VARCHAR(400), [2009] VARCHAR(400),
            [2010] VARCHAR(400), [2011] VARCHAR(400), [2012] VARCHAR(400), [2013] VARCHAR(400),
            [2014] VARCHAR(400), [2015] VARCHAR(400), [2016] VARCHAR(400), [2017] VARCHAR(400),
            [2018] VARCHAR(400), [2019] VARCHAR(400), [2020] VARCHAR(400), [2021] VARCHAR(400),
            [2022] VARCHAR(400), [2023] VARCHAR(400), [2024] VARCHAR(400)
        )
    END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'degree_days' AND SCHEMA_NAME(schema_id) = 'env')
    BEGIN 
        CREATE TABLE env.degree_days (
            [freq]              VARCHAR(400),
            [unit]              VARCHAR(400),
            [indic_nrg]         VARCHAR(400),
            [geo\TIME_PERIOD]   VARCHAR(400),
            [1980] VARCHAR(400), [1981] VARCHAR(400), [1982] VARCHAR(400), [1983] VARCHAR(400),
            [1984] VARCHAR(400), [1985] VARCHAR(400), [1986] VARCHAR(400), [1987] VARCHAR(400),
            [1988] VARCHAR(400), [1989] VARCHAR(400), [1990] VARCHAR(400), [1991] VARCHAR(400),
            [1992] VARCHAR(400), [1993] VARCHAR(400), [1994] VARCHAR(400), [1995] VARCHAR(400),
            [1996] VARCHAR(400), [1997] VARCHAR(400), [1998] VARCHAR(400), [1999] VARCHAR(400),
            [2000] VARCHAR(400), [2001] VARCHAR(400), [2002] VARCHAR(400), [2003] VARCHAR(400),
            [2004] VARCHAR(400), [2005] VARCHAR(400), [2006] VARCHAR(400), [2007] VARCHAR(400),
            [2008] VARCHAR(400), [2009] VARCHAR(400), [2010] VARCHAR(400), [2011] VARCHAR(400),
            [2012] VARCHAR(400), [2013] VARCHAR(400), [2014] VARCHAR(400), [2015] VARCHAR(400),
            [2016] VARCHAR(400), [2017] VARCHAR(400), [2018] VARCHAR(400), [2019] VARCHAR(400),
            [2020] VARCHAR(400), [2021] VARCHAR(400), [2022] VARCHAR(400), [2023] VARCHAR(400),
            [2024] VARCHAR(400), [2025] VARCHAR(400)
        )
    END;

