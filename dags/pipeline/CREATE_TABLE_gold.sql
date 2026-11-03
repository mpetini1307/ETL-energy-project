
ALTER TABLE EnergyGold.fact.Median_Income DROP CONSTRAINT PK_median_incomeId 
ALTER TABLE EnergyGold.fact.Median_Income DROP CONSTRAINT FK_Median_Income_yearId 
ALTER TABLE EnergyGold.fact.Median_Income DROP CONSTRAINT FK_Median_Income_countryId

ALTER TABLE EnergyGold.fact.Degree_Days DROP CONSTRAINT PK_degreeDayId
ALTER TABLE EnergyGold.fact.Degree_Days DROP CONSTRAINT FK_Degree_Days_yearId 
ALTER TABLE EnergyGold.fact.Degree_Days DROP CONSTRAINT FK_Degree_Days_countryId

ALTER TABLE EnergyGold.fact.Ghg_emissions DROP CONSTRAINT PK_ghg_emissionId
ALTER TABLE EnergyGold.fact.Ghg_emissions DROP CONSTRAINT FK_ghg_emissions_yearId 
ALTER TABLE EnergyGold.fact.Ghg_emissions DROP CONSTRAINT FK_ghg_emissions_countryId

ALTER TABLE EnergyGold.fact.Population DROP CONSTRAINT PK_populationId
ALTER TABLE EnergyGold.fact.Population DROP CONSTRAINT FK_Population_yearId 
ALTER TABLE EnergyGold.fact.Population DROP CONSTRAINT FK_Population_countryId

ALTER TABLE EnergyGold.fact.Production DROP CONSTRAINT FK_Production_countryId
ALTER TABLE EnergyGold.fact.Production DROP CONSTRAINT FK_Production_productionTypeId
ALTER TABLE EnergyGold.fact.Production DROP CONSTRAINT FK_Production_dateId 
ALTER TABLE EnergyGold.fact.Production DROP CONSTRAINT PK_productionId

ALTER TABLE EnergyGold.fact.Storage DROP CONSTRAINT FK_Storage_countryId
ALTER TABLE EnergyGold.fact.Storage DROP CONSTRAINT FK_Storage_storageTypeId
ALTER TABLE EnergyGold.fact.Storage DROP CONSTRAINT FK_Storage_dateId 
ALTER TABLE EnergyGold.fact.Storage DROP CONSTRAINT PK_storageId

ALTER TABLE EnergyGold.fact.Consumption DROP CONSTRAINT FK_Consumption_countryId
ALTER TABLE EnergyGold.fact.Consumption DROP CONSTRAINT FK_Consumption_energyTypeId
ALTER TABLE EnergyGold.fact.Consumption DROP CONSTRAINT FK_Consumption_dateId 
ALTER TABLE EnergyGold.fact.Consumption DROP CONSTRAINT PK_consumptionId

ALTER TABLE EnergyGold.fact.Flow DROP CONSTRAINT FK_Flow_fromCountryId
ALTER TABLE EnergyGold.fact.Flow DROP CONSTRAINT FK_Flow_toCountryId
ALTER TABLE EnergyGold.fact.Flow DROP CONSTRAINT FK_Flow_flowTypeId
ALTER TABLE EnergyGold.fact.Flow DROP CONSTRAINT FK_Flow_dateId 
ALTER TABLE EnergyGold.fact.Flow DROP CONSTRAINT PK_flowId

ALTER TABLE EnergyGold.fact.Installed_Capacity DROP CONSTRAINT FK_Installed_Capacity_yearId 
ALTER TABLE EnergyGold.fact.Installed_Capacity DROP CONSTRAINT FK_Installed_Capacity_productionTypeId
ALTER TABLE EnergyGold.fact.Installed_Capacity DROP CONSTRAINT FK_Installed_Capacity_countryId
ALTER TABLE EnergyGold.fact.Installed_Capacity DROP CONSTRAINT PK_installedCapacityId

ALTER TABLE EnergyGold.fact.Storage_Capacity DROP CONSTRAINT FK_Storage_Capacity_yearId 
ALTER TABLE EnergyGold.fact.Storage_Capacity DROP CONSTRAINT FK_Storage_Capacity_storageTypeId
ALTER TABLE EnergyGold.fact.Storage_Capacity DROP CONSTRAINT FK_Storage_Capacity_countryId
ALTER TABLE EnergyGold.fact.Storage_Capacity DROP CONSTRAINT PK_storageCapacityId

ALTER TABLE EnergyGold.dim.Date DROP CONSTRAINT FK_Date_yearId
ALTER TABLE EnergyGold.dim.Date DROP CONSTRAINT PK_dateId

ALTER TABLE EnergyGold.dim.Production_Type DROP CONSTRAINT FK_Production_Type_energyTypeId
ALTER TABLE EnergyGold.dim.Production_Type DROP CONSTRAINT PK_productionTypeId

ALTER TABLE EnergyGold.dim.Storage_Type DROP CONSTRAINT FK_Storage_Type_energyTypeId
ALTER TABLE EnergyGold.dim.Storage_Type DROP CONSTRAINT PK_storageTypeId

ALTER TABLE EnergyGold.dim.Flow_Type DROP CONSTRAINT FK_Flow_Type_energyTypeId

ALTER TABLE EnergyGold.dim.Year DROP CONSTRAINT PK_yearId

ALTER TABLE EnergyGold.dim.Country DROP CONSTRAINT PK_countryId

ALTER TABLE EnergyGold.dim.Energy_Type DROP CONSTRAINT PK_energyTypeId

DROP TABLE IF EXISTS EnergyGold.dim.Year
DROP TABLE IF EXISTS EnergyGold.dim.Date
DROP TABLE IF EXISTS EnergyGold.dim.Country
DROP TABLE IF EXISTS EnergyGold.dim.Energy_Type
DROP TABLE IF EXISTS EnergyGold.dim.Production_Type
DROP TABLE IF EXISTS EnergyGold.dim.Storage_Type
DROP TABLE IF EXISTS EnergyGold.dim.Flow_Type
DROP TABLE IF EXISTS EnergyGold.fact.Production
DROP TABLE IF EXISTS EnergyGold.fact.Consumption
DROP TABLE IF EXISTS EnergyGold.fact.Flow
DROP TABLE IF EXISTS EnergyGold.fact.Storage
DROP TABLE IF EXISTS EnergyGold.fact.Installed_Capacity
DROP TABLE IF EXISTS EnergyGold.fact.Storage_Capacity
DROP TABLE IF EXISTS EnergyGold.fact.population
DROP TABLE IF EXISTS EnergyGold.fact.Ghg_emissions
DROP TABLE IF EXISTS EnergyGold.fact.Degree_Days
DROP TABLE IF EXISTS EnergyGold.fact.Median_Income


CREATE TABLE EnergyGold.dim.Year(
	yearId INT,

	CONSTRAINT PK_yearId PRIMARY KEY (yearId)
)

CREATE TABLE EnergyGold.dim.Date(
	dateId INT,
	[date] DATE,
	[yearId] INT,
	[month] INT,
	[day] INT,
	[quarter] INT,
	[month_name] NVARCHAR(15),
	[week] INT,
	[weekday] INT,
	[weekday_name] NVARCHAR(15),

	CONSTRAINT PK_dateId PRIMARY KEY (dateId),
	CONSTRAINT FK_Date_yearId FOREIGN KEY (yearId) REFERENCES EnergyGold.dim.year(yearId)
)


CREATE TABLE EnergyGold.dim.Country(
	countryId NVARCHAR(5),
	countryName NVARCHAR(50),
	latitude FLOAT,
	longitude FLOAT,
	is_eu BIT,
	is_europe BIT

	CONSTRAINT PK_countryId PRIMARY KEY (countryId)
)

CREATE TABLE EnergyGold.dim.Energy_Type(
	energyTypeId NVARCHAR(25),

	CONSTRAINT PK_energyTypeId PRIMARY KEY (energyTypeId)
)

CREATE TABLE EnergyGold.dim.Production_Type(
	productionTypeId INT,
	energyTypeId NVARCHAR(25),
	productionTypeName NVARCHAR(50),
	isRenewable BIT,
	lowCarbon BIT,

	CONSTRAINT PK_productionTypeId PRIMARY KEY (productionTypeId),
	CONSTRAINT FK_Production_Type_energyTypeId FOREIGN KEY (energyTypeId) REFERENCES EnergyGold.dim.Energy_Type(energyTypeId)
)

CREATE TABLE EnergyGold.dim.Storage_Type(
	storageTypeId INT,
	energyTypeId NVARCHAR(25),
	storageTypeName NVARCHAR(25),

	CONSTRAINT PK_storageTypeId PRIMARY KEY (storageTypeId),
	CONSTRAINT FK_Storage_Type_energyTypeId FOREIGN KEY (energyTypeId) REFERENCES EnergyGold.dim.Energy_Type(energyTypeId)
)

CREATE TABLE EnergyGold.dim.Flow_Type (
    flowTypeId INT,
	energyTypeId NVARCHAR(25),
    flowTypeName  NVARCHAR(30) NOT NULL,

    CONSTRAINT PK_flowTypeId PRIMARY KEY (flowTypeId),
	CONSTRAINT FK_Flow_Type_energyTypeId FOREIGN KEY (energyTypeId) REFERENCEs EnergyGold.dim.Energy_Type(energyTypeId)
)


CREATE TABLE EnergyGold.fact.Production(
	productionId INT IDENTITY,
	dateId INT,
	productionTypeId INT,
	countryId NVARCHAR(5),
	[production_MWh] FLOAT,

	CONSTRAINT PK_productionId PRIMARY KEY (productionId),
	CONSTRAINT UQ_Production UNIQUE (dateId, productionTypeId, countryId),
	CONSTRAINT FK_Production_dateId FOREIGN KEY (dateId) REFERENCES EnergyGold.dim.Date (dateId),
	CONSTRAINT FK_Production_productionTypeId FOREIGN KEY (productionTypeId) REFERENCES EnergyGold.dim.Production_Type (productionTypeId),
	CONSTRAINT FK_Production_countryId FOREIGN KEY (countryId) REFERENCES EnergyGold.dim.Country (countryId)
)

CREATE TABLE EnergyGold.fact.Consumption(
	consumptionId INT IDENTITY,
	dateId INT,
	energyTypeId NVARCHAR(25),
	countryId NVARCHAR(5),
	[consumption_MWh] FLOAT,

	CONSTRAINT PK_consumptionId PRIMARY KEY (consumptionId),
	CONSTRAINT UQ_Consumption UNIQUE (dateId, energyTypeId, countryId),
	CONSTRAINT FK_Consumption_dateId FOREIGN KEY (dateId) REFERENCES EnergyGold.dim.Date (dateId),
	CONSTRAINT FK_Consumption_energyTypeId FOREIGN KEY (energyTypeId) REFERENCES EnergyGold.dim.Energy_Type (energyTypeId),
	CONSTRAINT FK_Consumption_countryId FOREIGN KEY (countryId) REFERENCES EnergyGold.dim.Country (countryId)
)

CREATE TABLE EnergyGold.fact.Flow(
	flowId INT IDENTITY,
	dateId INT,
	flowTypeId INT,
	fromCountryId NVARCHAR(5),
	toCountryId NVARCHAR(5),
	[quantity_to_MWh] FLOAT,
	[quantity_from_MWh] FLOAT,

	CONSTRAINT PK_flowId PRIMARY KEY (flowId),
	CONSTRAINT UQ_Flow UNIQUE (dateId, flowTypeId, fromCountryId, toCountryId),
	CONSTRAINT FK_Flow_dateId FOREIGN KEY (dateId) REFERENCES EnergyGold.dim.Date (dateId),
	CONSTRAINT FK_Flow_flowTypeId FOREIGN KEY (flowTypeId) REFERENCES EnergyGold.dim.Flow_Type (flowTypeId),
	CONSTRAINT FK_Flow_fromCountryId FOREIGN KEY (fromCountryId) REFERENCES EnergyGold.dim.Country (countryId),
	CONSTRAINT FK_Flow_toCountryId FOREIGN KEY (toCountryId) REFERENCES EnergyGold.dim.Country (countryId)
)

CREATE TABLE EnergyGold.fact.Storage(
	storageId INT IDENTITY,
	dateId INT,
	storageTypeId INT,
	countryId NVARCHAR(5),
	[injection_MWh] FLOAT,
	[withdrawal_MWh] FLOAT,
	[stock_MWh] FLOAT,
	[agsi_injection_MWh] FLOAT,
	[agsi_withdrawal_MWh] FLOAT,
	[agsi_stock_MWh] FLOAT,

	CONSTRAINT PK_storageId PRIMARY KEY (storageId),
	CONSTRAINT UQ_Storage UNIQUE (dateId, storageTypeId, countryId),
	CONSTRAINT FK_Storage_dateId FOREIGN KEY (dateId) REFERENCES EnergyGold.dim.Date (dateId),
	CONSTRAINT FK_Storage_storageTypeId FOREIGN KEY (storageTypeId) REFERENCES EnergyGold.dim.Storage_Type (storageTypeId),
	CONSTRAINT FK_Storage_countryId FOREIGN KEY (countryId) REFERENCES EnergyGold.dim.Country (countryId)
)

CREATE TABLE EnergyGold.fact.Installed_Capacity(
	installedCapacityId INT IDENTITY,
	yearId INT,
	productionTypeId INT,
	countryId NVARCHAR(5),
	[capacity_MW] FLOAT,

	CONSTRAINT PK_installedCapacityId PRIMARY KEY (installedCapacityId),
	CONSTRAINT UQ_Installed_Capacity UNIQUE (yearId, productionTypeId, countryId),
	CONSTRAINT FK_Installed_Capacity_yearId FOREIGN KEY (yearId) REFERENCES EnergyGold.dim.Year (yearId),
	CONSTRAINT FK_Installed_Capacity_productionTypeId FOREIGN KEY (productionTypeId) REFERENCES EnergyGold.dim.Production_Type (productionTypeId),
	CONSTRAINT FK_Installed_Capacity_countryId FOREIGN KEY (countryId) REFERENCES EnergyGold.dim.Country (countryId)
)

CREATE TABLE EnergyGold.fact.Storage_Capacity(
	storageCapacityId INT IDENTITY,
	yearId INT,
	storageTypeId INT,
	countryId NVARCHAR(5),
	[capacity_MWh] FLOAT,
	[capacity_MW] FLOAT,

	CONSTRAINT PK_storageCapacityId PRIMARY KEY (storageCapacityId),
	CONSTRAINT UQ_Storage_Capacity UNIQUE (yearId, storageTypeId, countryId),
	CONSTRAINT FK_Storage_Capacity_yearId FOREIGN KEY (yearId) REFERENCES EnergyGold.dim.Year (yearId),
	CONSTRAINT FK_Storage_Capacity_storageTypeId FOREIGN KEY (storageTypeId) REFERENCES EnergyGold.dim.Storage_Type (storageTypeId),
	CONSTRAINT FK_Storage_Capacity_countryId FOREIGN KEY (countryId) REFERENCES EnergyGold.dim.Country (countryId)
)

CREATE TABLE EnergyGold.fact.Population(
	populationId INT IDENTITY,
	yearId INT,
	countryId NVARCHAR(5),
	[population] INT,

	CONSTRAINT PK_populationId PRIMARY KEY (populationId),
	CONSTRAINT UQ_Population UNIQUE (yearId, countryId),
	CONSTRAINT FK_Population_yearId FOREIGN KEY (yearId) REFERENCES EnergyGold.dim.Year (yearId),
	CONSTRAINT FK_Population_countryId FOREIGN KEY (countryId) REFERENCES EnergyGold.dim.Country (countryId)
)

CREATE TABLE EnergyGold.fact.Ghg_emissions(
	ghg_emissionId INT IDENTITY,
	yearId INT,
	countryId NVARCHAR(5),
	net_ghg_MtCO2eq FLOAT,
	net_ghg_MtCO2eq_per_capita FLOAT,

	CONSTRAINT PK_ghg_emissionId PRIMARY KEY (ghg_emissionId),
	CONSTRAINT UQ_Ghg_emissions UNIQUE (yearId, countryId),
	CONSTRAINT FK_ghg_emissions_yearId FOREIGN KEY (yearId) REFERENCES EnergyGold.dim.Year (yearId),
	CONSTRAINT FK_ghg_emissions_countryId FOREIGN KEY (countryId) REFERENCES EnergyGold.dim.Country (countryId)
)

CREATE TABLE EnergyGold.fact.Degree_Days(
	degreeDayId INT IDENTITY,
	yearId INT,
	countryId NVARCHAR(5),
	heating_dd FLOAT,
	cooling_dd FLOAT,

	CONSTRAINT PK_degreeDayId PRIMARY KEY (degreeDayId),
	CONSTRAINT UQ_Degree_Days UNIQUE (yearId, countryId),
	CONSTRAINT FK_Degree_Days_yearId FOREIGN KEY (yearId) REFERENCES EnergyGold.dim.Year (yearId),
	CONSTRAINT FK_Degree_Days_countryId FOREIGN KEY (countryId) REFERENCES EnergyGold.dim.Country (countryId)
)

CREATE TABLE EnergyGold.fact.Median_Income(
	median_incomeId INT IDENTITY,
	yearId INT,
	countryId NVARCHAR(5),
	median_income_eur FLOAT

	CONSTRAINT PK_median_incomeId PRIMARY KEY (median_incomeId),
	CONSTRAINT UQ_Median_Income UNIQUE (yearId, countryId),
	CONSTRAINT FK_Median_Income_yearId FOREIGN KEY (yearId) REFERENCES EnergyGold.dim.Year (yearId),
	CONSTRAINT FK_Median_Income_countryId FOREIGN KEY (countryId) REFERENCES EnergyGold.dim.Country (countryId)
)
