-- =========================================
-- 1. Bases
-- =========================================
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'EnergyBronze')
    CREATE DATABASE EnergyBronze;
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'EnergyBronzeUpdate')
    CREATE DATABASE EnergyBronzeUpdate;
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'EnergySilver')
    CREATE DATABASE EnergySilver;
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'EnergyGold')
    CREATE DATABASE EnergyGold;

-- =========================================
-- 3. Schémas
-- =========================================
USE EnergyBronze;
IF SCHEMA_ID('elec') IS NULL EXEC('CREATE SCHEMA elec');
IF SCHEMA_ID('gas')  IS NULL EXEC('CREATE SCHEMA gas');
IF SCHEMA_ID('demo') IS NULL EXEC('CREATE SCHEMA demo');
IF SCHEMA_ID('env')  IS NULL EXEC('CREATE SCHEMA env');

USE EnergySilver;
IF SCHEMA_ID('elec') IS NULL EXEC('CREATE SCHEMA elec');
IF SCHEMA_ID('gas')  IS NULL EXEC('CREATE SCHEMA gas');
IF SCHEMA_ID('demo') IS NULL EXEC('CREATE SCHEMA demo');
IF SCHEMA_ID('env')  IS NULL EXEC('CREATE SCHEMA env');


USE EnergyGold;
IF SCHEMA_ID('dim')  IS NULL EXEC('CREATE SCHEMA dim');
IF SCHEMA_ID('fact') IS NULL EXEC('CREATE SCHEMA fact');

USE EnergyBronzeUpdate;
IF SCHEMA_ID('elec') IS NULL EXEC('CREATE SCHEMA elec');
IF SCHEMA_ID('gas')  IS NULL EXEC('CREATE SCHEMA gas');
