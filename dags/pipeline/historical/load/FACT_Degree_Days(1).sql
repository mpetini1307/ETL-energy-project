INSERT INTO EnergyGold.fact.Degree_Days (yearId, countryId, heating_dd, cooling_dd)
SELECT
    y.yearId,
    c.countryId,
    dd.heating_dd,
    dd.cooling_dd
FROM EnergySilver.env.degree_days dd
    JOIN EnergyGold.dim.[Year] y   ON y.yearId = dd.[year]
    JOIN EnergyGold.dim.Country c  ON c.countryId = dd.countryId;
