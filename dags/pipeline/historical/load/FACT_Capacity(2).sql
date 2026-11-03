INSERT INTO EnergyGold.fact.Installed_Capacity (yearId, productionTypeId, countryId, [capacity_MW])
SELECT 
	y.yearId,
	prodType.productionTypeId,
	c.countryId,
	instCap.[installed_capacity_mw]
FROM EnergySilver.elec.installed_capacity instCap
	JOIN EnergyGold.dim.Year y ON (y.yearId = instCap.Year)
	JOIN EnergyGold.dim.Country c ON (c.countryId = instCap.AreaMapCode)
	JOIN EnergyGold.dim.Production_Type prodType ON (prodType.ProductionTypeName = instCap.ProductionType)

INSERT INTO EnergyGold.fact.Storage_Capacity(yearId, storageTypeId, countryId, [capacity_MWh], [capacity_MW])
SELECT 
	y.yearId,
	1,
	c.countryId,
	stoCap.[technicalCapacity[TWh]]]*1000000,
	NULL
FROM EnergySilver.gas.storage_capacity stoCap
	JOIN EnergyGold.dim.Year y ON (y.yearId = YEAR(stoCap.[Date]))
	JOIN EnergyGold.dim.Country c ON (c.countryId = stoCap.code)
WHERE DAY(Date) = '01' AND MONTH(Date) = '01' AND YEAR(Date) > '2013'


INSERT INTO EnergyGold.fact.Storage_Capacity(yearId, storageTypeId, countryId, [capacity_MWh], [capacity_MW])
SELECT 
	y.yearId,
	stoType.storageTypeId,
	c.countryId,
	NULL,
	instCap.[installed_capacity_mw]
FROM EnergySilver.elec.installed_capacity instCap
	JOIN EnergyGold.dim.Year y ON (y.yearId = instCap.Year)
	JOIN EnergyGold.dim.Country c ON (c.countryId = instCap.AreaMapCode)
	JOIN EnergyGold.dim.Storage_Type stoType ON (stoType.storageTypeName = instCap.ProductionType)
WHERE ProductionType LIKE '%Storage%'

