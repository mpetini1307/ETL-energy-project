TRUNCATE TABLE gas.flow
TRUNCATE TABLE gas.operator_points
TRUNCATE TABLE gas.storage

BULK INSERT gas.flow
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\compacted\entsog\entsog_2021.csv'
WITH(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0a',  
    TABLOCK
)

BULK INSERT gas.flow
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\compacted\entsog\entsog_2022.csv'
WITH(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0a', 
    TABLOCK
)

BULK INSERT gas.flow
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\compacted\entsog\entsog_2023.csv'
WITH(   
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0a',   
    TABLOCK
)

BULK INSERT gas.flow
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\compacted\entsog\entsog_2024.csv'
WITH(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0a',   
    TABLOCK
)

BULK INSERT gas.flow
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\compacted\entsog\entsog_2025.csv'
WITH(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', 
    TABLOCK
)

BULK INSERT gas.flow
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\compacted\entsog\entsog_2026.csv'
WITH(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',  
    TABLOCK
)

BULK INSERT gas.storage
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\compacted\agsi\agsi.csv'
WITH(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0a',  
    TABLOCK
)

BULK INSERT gas.operator_points
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\entsog\operator_points\all_operator_points.csv'
WITH(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0a',  
    TABLOCK
)
