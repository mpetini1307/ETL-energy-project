WITH normalized_egeneration AS (
	SELECT
		DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME)) AS datetime_utc,
		AreaMapCode,
		ProductionType,
		ROUND(AVG(CAST([ActualGenerationOutput[MW]]] AS FLOAT)),2) AS 'generation_MWh',
		ROUND(AVG(CAST([ActualConsumption[MW]]] AS FLOAT)),2) AS 'consumption_MWh'
	FROM EnergyBronzeUpdate.elec.generation
	WHERE ( AreaMapCode IN (SELECT DISTINCT countryId FROM EnergySilver.demo.countries) )
		AND ResolutionCode = 'PT15M'
		AND AreaTypeCode LIKE '%CTY%'
	GROUP BY AreaMapCode, ProductionType, DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME))

	UNION ALL 

	SELECT 
		DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME)) AS datetime_utc,
		AreaMapCode,
		ProductionType,
		CAST([ActualGenerationOutput[MW]]] AS FLOAT) AS 'generation_MWh',
		CAST([ActualConsumption[MW]]] AS FLOAT) AS 'consumption_MWh'
	FROM EnergyBronzeUpdate.elec.generation
	WHERE AreaMapCode IN (SELECT DISTINCT countryId FROM EnergySilver.demo.countries)
		AND ResolutionCode = 'PT60M'
		AND AreaTypeCode LIKE '%CTY%'
), new_rows AS (
	SELECT 
		CAST(datetime_utc AS DATE) as [date],
		AreaMapCode,
		ProductionType,
		SUM(generation_MWh) AS generation_mwh,
		SUM(consumption_MWh) AS consumption_mwh
	FROM normalized_egeneration
	GROUP BY CAST(datetime_utc AS DATE), AreaMapCode, ProductionType
)
MERGE EnergySilver.elec.generation AS db
USING new_rows AS new
	ON db.date = new.date
	AND db.AreaMapCode = new.AreaMapCode
	AND db.ProductionType = new.ProductionType
WHEN MATCHED THEN
	UPDATE SET 
		db.generation_mwh = new.generation_mwh,
		db.consumption_mwh = new.consumption_mwh
WHEN NOT MATCHED BY TARGET THEN
	INSERT (date,AreaMapCode,ProductionType,generation_mwh,consumption_mwh)
	VALUES (new.date,new.AreaMapCode,new.ProductionType,new.generation_mwh,new.consumption_mwh)
OUTPUT $action, inserted.date,inserted.AreaMapCode,inserted.ProductionType, deleted.generation_mwh as old_generation_mwh, inserted.generation_mwh,(inserted.generation_mwh - deleted.generation_mwh) AS difference_mwh, deleted.consumption_mwh as old_consumption_mwh, inserted.consumption_mwh;