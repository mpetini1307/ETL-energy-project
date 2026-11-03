DROP TABLE IF EXISTS EnergySilver.gas.flow;
DROP TABLE IF EXISTS EnergySilver.gas.interconnections;
DROP TABLE IF EXISTS EnergySilver.gas.storage_capacity;

---------------------------------------------------------------------------------------------------------------------
-------------------------------------------GAS_INTERCONNECTIONS------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------


WITH cleaned_interconnections AS (
SELECT 
    op.pointKey,
    op.directionKey,
    op.operatorKey,
    op.tSOCountry AS from_country,
    CASE 
        WHEN op.pointType = 'LNG Entry point' THEN 'LNG'
        ELSE op.adjacentCountry 
    END AS export_country,
    t.pointType
FROM EnergyBronze.gas.operator_points op
    CROSS APPLY (VALUES                                                     --CROSS APPLY CAR j'ai un type TRANSMISSION + STORAGE
        (CASE
            WHEN op.pointType LIKE '%Production%'   THEN 'Production'
            WHEN op.pointType LIKE '%Transmission%' THEN 'Transmission'
            WHEN op.pointType LIKE '%Consumers%'    THEN 'Consumption'
            WHEN op.pointType LIKE '%Distribution%' THEN 'Consumption'
            WHEN op.pointType LIKE '%Storage%'      THEN 'Storage'
            WHEN op.pointType LIKE '%LNG%'          THEN 'LNG Entry Point'
            ELSE op.pointType
         END),
        (CASE
            WHEN op.pointType = 'Cross-Border Storage IP within EU' THEN 'Transmission'
         END)
    ) AS t(pointType)
WHERE op.pointType <> 'Trading Point'
  AND t.pointType IS NOT NULL
)
SELECT DISTINCT *
INTO EnergySilver.gas.interconnections
FROM cleaned_interconnections
WHERE NOT (pointType = 'Transmission' AND from_country = export_country);

---------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------GAS_FLOW------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

WITH normalized_flow AS (
SELECT
    CAST(SWITCHOFFSET(periodFrom, '+00:00') AS DATETIME2) as datetime_utc,
	pointKey,
	operatorKey,
	directionKey,
	TRY_CAST(NULLIF([value], '') AS FLOAT) / 1000.0 as 'flow_MWh'
FROM EnergyBronze.gas.flow
WHERE unit='kWh/h'
)
SELECT DISTINCT
	CAST(datetime_utc AS DATE) AS [date],
	pointKey,
	operatorKey,
	directionKey,
	SUM(flow_MWh) AS flow_MWh
INTO EnergySilver.gas.flow
FROM normalized_flow
GROUP BY CAST(datetime_utc AS DATE), pointKey, operatorKey,directionKey

UNION ALL

SELECT DISTINCT 
    CAST(SWITCHOFFSET(periodFrom, '+00:00') AS DATE) as [date],
	pointKey,
	operatorKey,
	directionKey,
	TRY_CAST(NULLIF([value], '') AS FLOAT) / 1000.0 as 'flow_MWh'
FROM EnergyBronze.gas.flow
WHERE unit='kWh/d';



---------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------GAS_STORAGE---------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

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
INTO EnergySilver.gas.storage_capacity
FROM EnergyBronze.gas.storage
WHERE NOT code = 'GB';

