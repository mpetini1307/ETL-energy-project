
-- INSERTION DU STOCKAGE GAS


WITH storage_flow AS (
    -- Injections / retraits journaliers par pays (ENTSOG)
    SELECT
        f.[date],
        i.from_country AS countryId,
        SUM(CASE WHEN f.directionKey = 'exit'  THEN f.flow_MWh ELSE 0 END) AS injection_MWh,
        SUM(CASE WHEN f.directionKey = 'entry' THEN f.flow_MWh ELSE 0 END) AS withdrawal_MWh
    FROM EnergySilver.gas.flow f
        JOIN EnergySilver.gas.interconnections i
            ON  f.pointKey     = i.pointKey
            AND f.operatorKey  = i.operatorKey
            AND f.directionKey = i.directionKey
    WHERE i.pointType = 'Storage'
    GROUP BY f.[date], i.from_country
),
agsi AS (
    -- Données AGSI converties en MWh
    SELECT
        code AS countryId,
        [Date] AS [date],
        injection_GWh    * 1000    AS agsi_injection_MWh,
        withdrawal_GWh   * 1000    AS agsi_withdrawal_MWh,
        stock_TWh * 1000000 AS agsi_stock_MWh
    FROM EnergySilver.gas.storage_capacity
),
first_date AS (
    SELECT countryId, MIN([date]) AS first_date
    FROM storage_flow
    GROUP BY countryId
),
initial_stock AS ( -- Prend le stock AGSI de la veille du premier jour ENTSOG
    SELECT fd.countryId, a.agsi_stock_MWh AS initial_MWh
    FROM first_date fd
        JOIN agsi a
            ON  a.countryId = fd.countryId
            AND a.[date] = DATEADD(day, -1, fd.first_date)
)
INSERT INTO EnergyGold.fact.Storage (dateId, storageTypeId, countryId,
                          [injection_MWh], [withdrawal_MWh], [stock_MWh],
                          [AGSI_injection_MWh], [AGSI_withdrawal_MWh], [AGSI_stock_MWh])
SELECT
    d.dateId,
    1 AS storageTypeId,
    c.countryId,
    sf.injection_MWh,
    sf.withdrawal_MWh,
    ist.initial_MWh
      + SUM(sf.injection_MWh - sf.withdrawal_MWh)
          OVER (PARTITION BY sf.countryId ORDER BY sf.[date] ROWS UNBOUNDED PRECEDING) AS stock_MWh,
    a.agsi_injection_MWh,
    a.agsi_withdrawal_MWh,
    a.agsi_stock_MWh
FROM storage_flow sf
    LEFT JOIN initial_stock ist ON ist.countryId = sf.countryId
    LEFT JOIN agsi a
        ON  a.countryId = sf.countryId
        AND a.[date] = sf.[date]
    JOIN EnergyGold.dim.[Date] d  ON d.[date] = sf.[date]
    JOIN EnergyGold.dim.Country c ON c.countryId = sf.countryId
ORDER BY c.countryId, d.dateId;


-- Insertion du stockage elec


INSERT INTO EnergyGold.fact.Storage(dateId, storageTypeId, countryId,
                          [injection_MWh], [withdrawal_MWh], [stock_MWh],
                          [AGSI_injection_MWh], [AGSI_withdrawal_MWh], [AGSI_stock_MWh])
SELECT 
	d.dateId,
	stype.storageTypeId,
	c.countryId,
	gene.[consumption_mwh],
	gene.[generation_mwh],
	SUM(ISNULL(gene.[consumption_mwh], 0) - ISNULL(gene.[generation_mwh], 0)) OVER (PARTITION BY gene.ProductionType, gene.AreaMapCode ORDER BY d.[Date]),
    NULL,
    NULL,
    NULL
FROM EnergySilver.elec.generation gene
	JOIN EnergyGold.dim.Date d ON (d.Date = gene.[Date])
	JOIN EnergyGold.dim.Country c ON (c.countryId = gene.AreaMapCode)
	JOIN EnergyGold.dim.Storage_Type stype ON (stype.storageTypeName = gene.ProductionType)
WHERE gene.ProductionType IN (SELECT storageTypeName FROM EnergyGold.dim.Storage_Type WHERE energyTypeId = 'elec')
ORDER BY ProductionType,d.[Date]
