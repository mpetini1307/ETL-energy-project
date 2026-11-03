WITH new_rows AS (
	SELECT 
		CAST([Year] AS INT) AS [Year],
		AreaMapCode,
		ProductionType,
		CAST([AggregatedInstalledCapacity[MW]]] AS FLOAT) as 'installed_capacity_mw'
	FROM EnergyBronzeUpdate.elec.installed_capacity
	WHERE AreaMapCode IN (SELECT countryId FROM EnergySilver.demo.countries)
		AND AreaTypeCode LIKE '%CTY%'
)
MERGE EnergySilver.elec.installed_capacity AS db
USING new_rows AS new
	ON db.year = new.year
	AND db.AreaMapCode = new.AreaMapCode
	AND db.ProductionType = new.ProductionType
WHEN MATCHED THEN
	UPDATE SET db.installed_capacity_mw = new.installed_capacity_mw

WHEN NOT MATCHED BY TARGET THEN 
	INSERT (year,AreaMapCode,ProductionType,installed_capacity_mw)
	VALUES (new.year,new.AreaMapCode,new.ProductionType,new.installed_capacity_mw);
