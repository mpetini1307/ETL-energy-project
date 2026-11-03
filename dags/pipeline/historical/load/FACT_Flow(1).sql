-- 1. Gaz : intercountry
INSERT INTO EnergyGold.fact.Flow (dateId, flowTypeId, fromCountryId, toCountryId, quantity_to_MWh, quantity_from_MWh)
SELECT 
    d.dateId,
    1,
    x.from_c,
    x.to_c,
    SUM(CASE WHEN x.directionKey = 'entry' THEN x.flow_MWh END),   -- déclaré par l'importateur
    SUM(CASE WHEN x.directionKey = 'exit'  THEN x.flow_MWh END)    -- déclaré par l'exportateur
FROM (
    SELECT
        f.[date],
        f.flow_MWh,
        i.directionKey,
        CASE WHEN i.directionKey = 'entry' THEN i.export_country ELSE i.from_country   END AS from_c,
        CASE WHEN i.directionKey = 'entry' THEN i.from_country   ELSE i.export_country END AS to_c
    FROM EnergySilver.gas.flow f
        JOIN EnergySilver.gas.interconnections i
            ON  i.pointKey     = f.pointKey
            AND i.operatorKey  = f.operatorKey
            AND i.directionKey = f.directionKey
    WHERE i.pointType = 'Transmission'
) x
    JOIN EnergyGold.dim.[Date] d    ON d.[date] = x.[date]
    JOIN EnergyGold.dim.Country cf  ON cf.countryId = x.from_c
    JOIN EnergyGold.dim.Country ct  ON ct.countryId = x.to_c
GROUP BY d.dateId, x.from_c, x.to_c;

-- 2. Gaz : LNG
INSERT INTO EnergyGold.fact.Flow (dateId, flowTypeId, fromCountryId, toCountryId, quantity_to_MWh, quantity_from_MWh)
SELECT 
    d.dateId,
    2,
    'LNG',
    i.from_country,
    SUM(f.flow_MWh),
    SUM(f.flow_MWh)
FROM EnergySilver.gas.flow f
    JOIN EnergySilver.gas.interconnections i
        ON  i.pointKey     = f.pointKey
        AND i.operatorKey  = f.operatorKey
        AND i.directionKey = f.directionKey
    JOIN EnergyGold.dim.[Date] d   ON d.[date] = f.[date]
    JOIN EnergyGold.dim.Country c  ON c.countryId = i.from_country
WHERE i.pointType = 'LNG Entry Point'
  AND i.directionKey = 'entry'
GROUP BY d.dateId, i.from_country;

-- 3 elec

INSERT INTO EnergyGold.fact.Flow (dateId, flowTypeId, fromCountryId, toCountryId, quantity_to_MWh, quantity_from_MWh)
SELECT 
    d.dateId,
    3,
    ef.OutAreaMapCode,
    ef.InAreaMapCode,
    SUM(ef.flow_mwh),
    SUM(ef.flow_mwh)
FROM EnergySilver.elec.flow ef
    JOIN EnergyGold.dim.[Date] d    ON d.[date] = ef.[date]
    JOIN EnergyGold.dim.Country cf  ON cf.countryId = ef.OutAreaMapCode
    JOIN EnergyGold.dim.Country ct  ON ct.countryId = ef.InAreaMapCode
GROUP BY d.dateId, ef.OutAreaMapCode, ef.InAreaMapCode;