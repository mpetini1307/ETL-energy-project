WITH gas_prod AS (SELECT
	f.date,
	f.pointKey,
	f.operatorKey,
	f.directionKey,
	i.from_country,
	i.export_country,
	i.pointType,
	f.flow_MWh
FROM EnergySilver.gas.flow f
	JOIN EnergySilver.gas.interconnections i
		ON (f.pointKey = i.pointKey ) 
		AND (f.operatorKey = i.operatorKey) 
		AND (f.directionKey = i.directionKey)
WHERE i.pointType = 'Production'
)
INSERT INTO EnergyGold.fact.Production (dateId,productionTypeId,countryId,production_MWh)
SELECT
	d.dateId,
	20,
	c.countryId,
	SUM(flow_MWh) as flow_MWh
FROM gas_prod prod
	JOIN EnergyGold.dim.date d ON (d.date = prod.date)
	JOIN EnergyGold.dim.Country c ON (prod.from_country = c.countryId)
GROUP BY d.dateId,c.countryId;

INSERT INTO EnergyGold.fact.Production (dateId,productionTypeId,countryId,production_MWh)
SELECT 
	d.dateId,
	ptype.productionTypeId,
	c.countryId,
	prod.[generation_MWh]
FROM EnergySilver.elec.generation prod
	JOIN EnergyGold.dim.date d ON (d.date = prod.date)
	JOIN EnergyGold.dim.Country c ON (prod.AreaMapCode = c.countryId)
	JOIN EnergyGold.dim.Production_Type ptype ON (prod.ProductionType = ptype.productionTypeName)
