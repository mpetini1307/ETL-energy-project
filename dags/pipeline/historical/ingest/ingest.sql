BULK INSERT elec.actual_total_load
FROM 'C:\Users\PC\Documents\Projets\TFF\data\raw\compacted\entsoe\entsog_ActualTotalLoad_6.1.A_r3.csv'
WITH(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    TABLOCK
)