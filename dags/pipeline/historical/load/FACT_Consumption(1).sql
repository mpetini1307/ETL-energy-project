
-- 1. elec
INSERT INTO EnergyGold.fact.Consumption (dateId, energyTypeId, countryId, consumption_MWh)
SELECT 
    d.dateId,
    'elec',
    c.countryId,
    SUM(l.load_MWh)
FROM EnergySilver.elec.load l
    JOIN EnergyGold.dim.[Date] d   ON d.[date] = l.[date]
    JOIN EnergyGold.dim.Country c  ON c.countryId = l.AreaMapCode
GROUP BY d.dateId, c.countryId;

-- 2. Gas
INSERT INTO EnergyGold.fact.Consumption (dateId, energyTypeId, countryId, consumption_MWh)
SELECT 
    d.dateId,
    'gas',
    c.countryId,
    SUM(f.flow_MWh)
FROM EnergySilver.gas.flow f
    JOIN EnergySilver.gas.interconnections i
        ON  i.pointKey     = f.pointKey
        AND i.operatorKey  = f.operatorKey
        AND i.directionKey = f.directionKey
    JOIN EnergyGold.dim.[Date] d   ON d.[date] = f.[date]
    JOIN EnergyGold.dim.Country c  ON c.countryId = i.from_country
WHERE i.pointType = 'Consumption'
  AND f.directionKey = 'exit'
GROUP BY d.dateId, c.countryId;
