TRUNCATE TABLE demo.countries
TRUNCATE TABLE demo.median_income
TRUNCATE TABLE demo.population


BULK INSERT demo.countries
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\countries\countries.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
)

BULK INSERT demo.median_income
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\eurostat\ilc_di03.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
)

BULK INSERT demo.population
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\eurostat\tps00001.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
)

