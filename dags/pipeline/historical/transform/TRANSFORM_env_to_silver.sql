DROP TABLE IF EXISTS EnergySilver.env.ghg_emissions;
DROP TABLE IF EXISTS EnergySilver.env.degree_days;

---------------------------------------------------------------------------------------------------------------------
-----------------------------------------------GHG_EMISSIONS---------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------


WITH ghg_emissions_unpivot AS (
SELECT
	CASE 
		WHEN [geo\TIME_PERIOD] = 'EL' then 'GR'
		ELSE [geo\TIME_PERIOD]
	END as countryCode, [year], ghg_emissions, unit
FROM (
	SELECT unit, [geo\TIME_PERIOD], [2015],[2016],[2017],[2018],[2019],[2020],[2021],[2022],[2023],[2024]
	FROM EnergyBronze.env.ghg_emissions
	WHERE src_crf = 'TOTXMEMO' AND unit IN ('MTCO2E','T_HAB')
)p2
UNPIVOT(
	ghg_emissions FOR [year] IN ( [2015],[2016],[2017],[2018],[2019],[2020],[2021],[2022],[2023],[2024])
)unpvt2)
SELECT 
	CAST(countryCode AS NVARCHAR(2)) AS countryId,
	CAST([year] as INT) AS [year],
	MAX(CASE WHEN unit = 'MTCO2E' THEN CAST(ghg_emissions AS FLOAT) END) as Net_ghg_MtCO2eq,
	MAX(CASE WHEN unit = 'T_HAB' THEN CAST(ghg_emissions AS FLOAT) END) as Net_ghg_t_CO2eq_per_capita
INTO EnergySilver.env.ghg_emissions
FROM ghg_emissions_unpivot
GROUP BY countryCode,[year];


---------------------------------------------------------------------------------------------------------------------
-----------------------------------------------GHG_EMISSIONS---------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------


WITH degree_days_unpivot AS (
SELECT 
	CASE 
		WHEN [geo\TIME_PERIOD] = 'EL' then 'GR'
		ELSE [geo\TIME_PERIOD]
	END as countryCode, [year], degree_days, indic_nrg
FROM (
	SELECT indic_nrg, [geo\TIME_PERIOD], [2015],[2016],[2017],[2018],[2019],[2020],[2021],[2022],[2023],[2024],[2025]
	FROM EnergyBronze.env.degree_days
)p
UNPIVOT(
	degree_days FOR [year] IN ( [2015],[2016],[2017],[2018],[2019],[2020],[2021],[2022],[2023],[2024],[2025])
)unpvt)
SELECT 
	CAST(countryCode AS NVARCHAR(2)) AS countryId,
	CAST([year] as INT) AS [year],
	MAX(CASE WHEN indic_nrg = 'HDD' THEN CAST(degree_days AS FLOAT) END) as heating_dd,
	MAX(CASE WHEN indic_nrg = 'CDD' THEN CAST(degree_days AS FLOAT) END) as cooling_dd
INTO EnergySilver.env.degree_days
FROM degree_days_unpivot
GROUP BY countryCode,[year];
