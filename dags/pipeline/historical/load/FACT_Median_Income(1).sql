INSERT INTO EnergyGold.fact.Median_Income (yearId, countryId,median_income_eur)
SELECT
	y.yearId,
	c.countryId,
	m.median_income_eur
FROM EnergySilver.demo.median_income m 
	JOIN EnergyGold.dim.Year y ON (y.yearId = m.year)
	JOIN EnergyGold.dim.Country c ON (c.countryId = m.countryId)
