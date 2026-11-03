DROP TABLE IF EXISTS #selected_country;

SELECT InAreaMapCode AS countryCode
INTO #selected_country
FROM EnergySilver.elec.flow
UNION
SELECT OutAreaMapCode FROM EnergySilver.elec.flow
UNION
SELECT from_country FROM EnergySilver.gas.interconnections
UNION
SELECT export_country FROM EnergySilver.gas.interconnections;


INSERT INTO EnergyGold.dim.Country(countryId, countryName, latitude, longitude,is_eu, is_europe)
SELECT 
	countryId,
	country_name,
	latitude,
	longitude,
	is_eu,
	is_europe
FROM EnergySilver.demo.countries
WHERE countryId IN (SELECT countryCode FROM #selected_country)

INSERT INTO EnergyGold.dim.Country(countryId, countryName, latitude, longitude, is_eu, is_europe)
VALUES ('LNG', NULL, NULL, NULL, 0,0)

SELECT * FROM EnergyGold.dim.Country


