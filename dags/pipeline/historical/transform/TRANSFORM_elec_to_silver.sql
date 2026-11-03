DROP TABLE IF EXISTS EnergySilver.elec.flow;
DROP TABLE IF EXISTS EnergySilver.elec.load;
DROP TABLE IF EXISTS EnergySilver.elec.installed_capacity;
DROP TABLE IF EXISTS EnergySilver.elec.generation;



---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------ELEC_FLOW---------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------



WITH normalized_eflow AS (
SELECT
	DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME)) AS datetime_utc,
	OutAreaMapCode,
	InAreaMapCode,
    ROUND(AVG(CAST([Flow[MW]]] AS FLOAT)),2) AS 'flow_MWh'
FROM EnergyBronze.elec.flow
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
FROM EnergyBronze.elec.flow
WHERE ( OutAreaMapCode IN (SELECT DISTINCT countryId FROM EnergySilver.demo.countries) )
	AND ( InAreaMapCode IN (SELECT DISTINCT countryId FROM EnergySilver.demo.countries) )
	AND ResolutionCode = 'PT60M'
	AND InAreaTypeCode LIKE '%CTY%'
	AND OutAreaTypeCode LIKE '%CTY%'
)
SELECT 
	CAST(datetime_utc AS DATE) as [date],
	OutAreaMapCode,
	InAreaMapCode,
	SUM(flow_MWh) AS flow_mwh
INTO EnergySilver.elec.flow
FROM normalized_eflow
GROUP BY CAST(datetime_utc AS DATE), OutAreaMapCode, InAreaMapCode;

---------------------------------------------------------------------------------------------------------------------
-----------------------------------------------ELEC_GENERATION-------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------



WITH normalized_egeneration AS (
SELECT
	DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME)) AS datetime_utc,
	AreaMapCode,
	ProductionType,
    ROUND(AVG(CAST([ActualGenerationOutput[MW]]] AS FLOAT)),2) AS 'generation_MWh',
	ROUND(AVG(CAST([ActualConsumption[MW]]] AS FLOAT)),2) AS 'consumption_MWh'
FROM EnergyBronze.elec.generation
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
FROM EnergyBronze.elec.generation
WHERE AreaMapCode IN (SELECT DISTINCT countryId FROM EnergySilver.demo.countries)
	AND ResolutionCode = 'PT60M'
	AND AreaTypeCode LIKE '%CTY%'
)
SELECT 
	CAST(datetime_utc AS DATE) as [date],
	AreaMapCode,
	ProductionType,
	SUM(generation_MWh) AS generation_mwh,
	SUM(consumption_MWh) AS consumption_mwh
INTO EnergySilver.elec.generation
FROM normalized_egeneration
GROUP BY CAST(datetime_utc AS DATE), AreaMapCode, ProductionType;

---------------------------------------------------------------------------------------------------------------------
-----------------------------------------------ELEC_CAPACITY---------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------


SELECT 
	CAST([Year] AS INT) AS [Year],
	AreaMapCode,
	ProductionType,
	CAST([AggregatedInstalledCapacity[MW]]] AS FLOAT) as 'installed_capacity_mw'
INTO EnergySilver.elec.installed_capacity
FROM EnergyBronze.elec.installed_capacity
WHERE AreaMapCode IN (SELECT countryId FROM EnergySilver.demo.countries)
	AND AreaTypeCode LIKE '%CTY%';

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------ELEC_LOAD---------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

WITH normalized_eload AS (
SELECT
	DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME)) AS datetime_utc,
	AreaMapCode,
    ROUND(AVG(CAST([TotalLoad[MW]]] AS FLOAT)),2) AS 'load_MWh'
FROM EnergyBronze.elec.actual_total_load
WHERE ( AreaMapCode IN (SELECT DISTINCT countryId FROM EnergySilver.demo.countries) )
	AND ResolutionCode = 'PT15M'
	AND AreaTypeCode LIKE '%CTY%'
GROUP BY AreaMapCode,DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME))

UNION ALL 

SELECT 
	DATETRUNC(hour,CAST([DateTime(UTC)] AS DATETIME)) AS datetime_utc,
	AreaMapCode,
    CAST([TotalLoad[MW]]] AS FLOAT) AS 'load_MWh'
FROM EnergyBronze.elec.actual_total_load
WHERE AreaMapCode IN (SELECT DISTINCT countryId FROM EnergySilver.demo.countries)
	AND ResolutionCode = 'PT60M'
	AND AreaTypeCode LIKE '%CTY%'
)
SELECT 
	CAST(datetime_utc AS DATE) as [date],
	AreaMapCode,
	SUM(load_MWh) AS load_mwh
INTO EnergySilver.elec.load
FROM normalized_eload
GROUP BY CAST(datetime_utc AS DATE), AreaMapCode;
