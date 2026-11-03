
WITH normalized_eflow AS (
SELECT
	DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME)) AS datetime_utc,
	OutAreaMapCode,
	InAreaMapCode,
    ROUND(AVG(CAST([Flow[MW]]] AS FLOAT)),2) AS 'flow_MWh'
FROM EnergyBronzeUpdate.elec.flow
WHERE ( OutAreaMapCode IN (SELECT DISTINCT countryId FROM EnergySilver.demo.countries) )
	AND ( InAreaMapCode IN (SELECT DISTINCT countryId FROM EnergySilver.demo.countries) )
	AND ResolutionCode = 'PT15M'
	AND InAreaTypeCode LIKE '%CTY%'
	AND OutAreaTypeCode LIKE '%CTY%'
GROUP BY OutAreaMapCode, InAreaMapCode,DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME))

UNION ALL 

SELECT 
	DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME)) AS datetime_utc,
	OutAreaMapCode,
	InAreaMapCode,
    CAST([Flow[MW]]] AS FLOAT) AS 'flow_MWh'
FROM EnergyBronzeUpdate.elec.flow
WHERE ( OutAreaMapCode IN (SELECT DISTINCT countryId FROM EnergySilver.demo.countries) )
	AND ( InAreaMapCode IN (SELECT DISTINCT countryId FROM EnergySilver.demo.countries) )
	AND ResolutionCode = 'PT60M'
	AND InAreaTypeCode LIKE '%CTY%'
	AND OutAreaTypeCode LIKE '%CTY%'
), new_rows AS (
SELECT 
	CAST(datetime_utc AS DATE) as [date],
	OutAreaMapCode,
	InAreaMapCode,
	SUM(flow_MWh) AS flow_mwh
FROM normalized_eflow
GROUP BY CAST(datetime_utc AS DATE), OutAreaMapCode, InAreaMapCode
)
MERGE EnergySilver.elec.flow AS db
USING new_rows AS new
	ON db.date = new.date
	AND db.OutAreaMapCode = new.OutAreaMapCode 
	AND db.InAreaMapCode = new.InAreaMapCode
WHEN MATCHED THEN
	UPDATE SET db.flow_mwh = new.flow_mwh
WHEN NOT MATCHED BY TARGET THEN
	INSERT (date,OutAreaMapCode, InAreaMapCode,flow_mwh)
	VALUES (new.date,new.OutAreaMapCode, new.InAreaMapCode,new.flow_mwh)
OUTPUT $action ,inserted.date,inserted.OutAreaMapCode, inserted.InAreaMapCode,deleted.flow_mwh as before_flow_mwh, inserted.flow_mwh as new_flow_mwh;
