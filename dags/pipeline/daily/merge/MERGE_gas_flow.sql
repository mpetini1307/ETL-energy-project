
WITH normalized_flow AS (
SELECT
    CAST(SWITCHOFFSET(periodFrom, '+00:00') AS DATETIME2) as datetime_utc,
	pointKey,
	operatorKey,
	directionKey,
	TRY_CAST(NULLIF([value], '') AS FLOAT) / 1000.0 as 'flow_MWh'
FROM EnergyBronzeUpdate.gas.flow
WHERE unit='kWh/h'
), new_rows AS (
SELECT DISTINCT
	CAST(datetime_utc AS DATE) AS [date],
	pointKey,
	operatorKey,
	directionKey,
	SUM(flow_MWh) AS flow_MWh
FROM normalized_flow
GROUP BY CAST(datetime_utc AS DATE), pointKey, operatorKey,directionKey

UNION ALL

SELECT DISTINCT 
    CAST(SWITCHOFFSET(periodFrom, '+00:00') AS DATE) as [date],
	pointKey,
	operatorKey,
	directionKey,
	TRY_CAST(NULLIF([value], '') AS FLOAT) / 1000.0 as 'flow_MWh'
FROM EnergyBronzeUpdate.gas.flow
WHERE unit='kWh/d'
)
MERGE EnergySilver.gas.flow AS historical_gas_flow
USING new_rows AS daily_gas_flow
	ON historical_gas_flow.date = daily_gas_flow.date
	AND historical_gas_flow.pointKey = daily_gas_flow.pointKey
	AND historical_gas_flow.operatorKey = daily_gas_flow.operatorKey
	AND historical_gas_flow.directionKey = daily_gas_flow.directionKey
WHEN MATCHED THEN
    UPDATE SET historical_gas_flow.flow_MWh = daily_gas_flow.flow_MWh
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([date], pointKey, operatorKey, directionKey, flow_MWh)
    VALUES (daily_gas_flow.[date], daily_gas_flow.pointKey, daily_gas_flow.operatorKey, daily_gas_flow.directionKey, daily_gas_flow.flow_MWh)
OUTPUT $action, inserted.[date], inserted.pointKey, inserted.directionKey,
       deleted.flow_MWh AS ancien_flow_MWh, inserted.flow_MWh AS nouveau_flow_MWh;
