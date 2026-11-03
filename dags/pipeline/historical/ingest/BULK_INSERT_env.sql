TRUNCATE TABLE env.degree_days
TRUNCATE TABLE env.ghg_emissions

BULK INSERT env.degree_days
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\eurostat\nrg_chdd_a.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
)


BULK INSERT env.ghg_emissions
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\eurostat\sdg_13_10.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
)
