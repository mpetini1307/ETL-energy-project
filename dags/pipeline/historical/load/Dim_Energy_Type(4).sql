INSERT INTO EnergyGold.dim.Energy_Type(energyTypeId)
	VALUES('gas'),('elec')

SELECT DISTINCT ProductionType FROM EnergySilver.elec.installed_capacity
WHERE ProductionType LIKE '%Storage%'

INSERT INTO EnergyGold.dim.Storage_Type(storageTypeId,energyTypeId,storageTypeName)
VALUES (1, 'gas', 'Gas Storage'),
		(2, 'elec', 'Hydro Pumped Storage'),
       (3, 'elec', 'Energy Storage');

SELECT DISTINCT ProductionType FROM EnergySilver.elec.installed_capacity
WHERE ProductionType NOT LIKE '%Storage%'

INSERT INTO EnergyGold.dim.Production_Type (productionTypeId, energyTypeId, productionTypeName, isRenewable, lowCarbon)
VALUES (1,  'elec', 'Biomass',                         1, 1),
       (2,  'elec', 'Fossil Brown coal/Lignite',       0, 0),
       (3,  'elec', 'Fossil Coal-derived gas',         0, 0),
       (4,  'elec', 'Fossil Gas',                      0, 0),
       (5,  'elec', 'Fossil Hard coal',                0, 0),
       (6,  'elec', 'Fossil Oil',                      0, 0),
       (7,  'elec', 'Fossil Oil shale',                0, 0),
       (8,  'elec', 'Fossil Peat',                     0, 0),
       (9,  'elec', 'Geothermal',                      1, 1),
       (10, 'elec', 'Hydro Run-of-river and pondage',  1, 1),
       (11, 'elec', 'Hydro Water Reservoir',           1, 1),
       (12, 'elec', 'Marine',                          1, 1),
       (13, 'elec', 'Nuclear',                         0, 1),
       (14, 'elec', 'Other',                           NULL, NULL),
       (15, 'elec', 'Other renewable',                 1, 1),
       (16, 'elec', 'Solar',                           1, 1),
       (17, 'elec', 'Waste',                           0, 0),
       (18, 'elec', 'Wind Offshore',                   1, 1),
       (19, 'elec', 'Wind Onshore',                    1, 1),
       (20, 'gas' , 'Gas',                             0, 0);

INSERT INTO EnergyGold.dim.Flow_Type(flowTypeId, energyTypeId, flowTypeName) VALUES
    (1, 'gas', 'Pipeline'),
    (2, 'gas', 'LNG'),
    (3, 'elec', 'Power Line')