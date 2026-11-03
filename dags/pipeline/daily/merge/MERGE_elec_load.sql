WITH normalized_eload AS (
	SELECT
		DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME)) AS datetime_utc,
		AreaMapCode,
		ROUND(AVG(CAST([TotalLoad[MW]]] AS FLOAT)),2) AS 'load_MWh'
	FROM EnergyBronzeUpdate.elec.actual_total_load
	WHERE ( AreaMapCode IN (SELECT DISTINCT countryId FROM EnergySilver.demo.countries) )
		AND ResolutionCode = 'PT15M'
		AND AreaTypeCode LIKE '%CTY%'
	GROUP BY AreaMapCode,DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME))

	UNION ALL 

	SELECT 
		DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME)) AS datetime_utc,
		AreaMapCode,
		CAST([TotalLoad[MW]]] AS FLOAT) AS 'load_MWh'
	FROM EnergyBronzeUpdate.elec.actual_total_load
	WHERE AreaMapCode IN (SELECT DISTINCT countryId FROM EnergySilver.demo.countries)
		AND ResolutionCode = 'PT60M'
		AND AreaTypeCode LIKE '%CTY%'
), new_rows AS(
	SELECT 
		CAST(datetime_utc AS DATE) as [date],
		AreaMapCode,
		SUM(load_MWh) AS load_mwh
	FROM normalized_eload
	GROUP BY CAST(datetime_utc AS DATE), AreaMapCode
)
MERGE EnergySilver.elec.load AS db
USING new_rows AS new
	ON db.date = new.date
	AND db.AreaMapCode = new.AreaMapCode
WHEN MATCHED THEN
	UPDATE SET db.load_mwh = new.load_mwh
WHEN NOT MATCHED BY TARGET THEN
	INSERT (date,AreaMapCode,load_mwh)
	VALUES(new.date,new.AreaMapCode,new.load_mwh)
OUTPUT $action, inserted.date,inserted.AreaMapcode, deleted.load_mwh as old_load, inserted.load_mwh,( deleted.load_mwh -inserted.load_mwh ) AS difference_mwh ;