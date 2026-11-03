WITH new_rows AS (
    SELECT 
        CASE 
            WHEN code = 'GB*' THEN 'UK'
            ELSE code
        END AS code,
	    CAST(gasDayStart AS DATE) as [Date],
	    CAST(updatedAt AS DATETIME) as updatedAt,
        CAST(NULLIF(injection, '-') AS FLOAT) as injection_GWh,
        CAST(NULLIF(withdrawal, '-') AS FLOAT) as withdrawal_GWh,
        CAST(NULLIF(gasInStorage, '-') AS FLOAT) as stock_TWh,
	    CASE
		    WHEN workingGasVolume = '-' THEN NULL
		    ELSE ROUND(CAST(workingGasVolume AS FLOAT),2)
	    END AS 'technicalCapacity[TWh]'
    FROM EnergyBronzeUpdate.gas.storage
 WHERE NOT code = 'GB'
)
MERGE EnergySilver.gas.storage_capacity AS db
USING new_rows AS new
    ON db.Date = new.Date
    AND db.code = new.code
WHEN MATCHED THEN
    UPDATE SET 
        db.injection_GWh = new.injection_GWh,
        db.withdrawal_GWh = new.withdrawal_GWh,
        db.stock_TWh = new.stock_TWh,
        db.[technicalCapacity[TWh]]] = new.[technicalCapacity[TWh]]]
WHEN NOT MATCHED BY TARGET THEN
    INSERT (code, Date, updatedAt, injection_GWh, withdrawal_GWh, stock_TWh, [technicalCapacity[TWh]]])
    VALUES (new.code, new.Date, new.updatedAt, new.injection_GWh, new.withdrawal_GWh, new.stock_TWh, new.[technicalCapacity[TWh]]])

OUTPUT $action, inserted.code, inserted.Date, inserted.updatedAt, inserted.injection_GWh,inserted.withdrawal_GWh, inserted.stock_TWh, inserted.[technicalCapacity[TWh]]];
