TRUNCATE TABLE elec.actual_total_load
TRUNCATE TABLE elec.generation
TRUNCATE TABLE elec.installed_capacity
TRUNCATE TABLE elec.flow


BULK INSERT elec.actual_total_load
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\compacted\entsoe\entsoe_ActualTotalLoad_6.1.A_r3.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
)

BULK INSERT elec.generation
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\compacted\entsoe\entsoe_AggregatedGenerationPerType_16.1.B_C_r3.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
)

BULK INSERT elec.installed_capacity
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\compacted\entsoe\entsoe_InstalledGenerationCapacityAggregated_14.1.A_r3.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
)

BULK INSERT elec.flow
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\compacted\entsoe\entsoe_PhysicalFlows_12.1.G_r3.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
)