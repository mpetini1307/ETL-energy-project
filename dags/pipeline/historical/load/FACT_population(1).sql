INSERT INTO EnergyGold.fact.Population (yearId,countryId,population)
SELECT 
	y.yearId,
	c.countryId,
	population
FROM EnergySilver.demo.population p
	JOIN EnergyGold.dim.Country c ON (c.countryId = p.countryId)
	JOIN EnergyGold.dim.Year y ON (y.yearId = p.Year)

