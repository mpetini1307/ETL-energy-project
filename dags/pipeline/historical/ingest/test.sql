-- =========================================
-- 1. Les 3 bases existent ? Avec quel mode de récupération et quel propriétaire ?
-- =========================================
SELECT name                       AS base,
       recovery_model_desc        AS recuperation,
       SUSER_SNAME(owner_sid)     AS proprietaire,
       create_date                AS creee_le
FROM sys.databases
WHERE name IN ('EnergyBronze', 'EnergySilver', 'EnergyGold')
ORDER BY name;

-- =========================================
-- 2. Les schémas de chaque base
-- =========================================
SELECT 'EnergyBronze' AS base, name AS schema_name FROM EnergyBronze.sys.schemas WHERE name IN ('elec','gaz','demo','env')
UNION ALL
SELECT 'EnergySilver', name FROM EnergySilver.sys.schemas WHERE name IN ('elec','gaz','demo','env')
UNION ALL
SELECT 'EnergyGold',   name FROM EnergyGold.sys.schemas   WHERE name IN ('dim','fact')
ORDER BY base, schema_name;

-- =========================================
-- 3. Rien n'a atterri dans master par erreur ?
-- =========================================
SELECT name AS schema_dans_master_a_supprimer
FROM master.sys.schemas
WHERE name IN ('elec','gaz','demo','env','dim','fact');

-- =========================================
-- 4. Les rôles serveur de ton compte
-- =========================================
SELECT r.name AS role_serveur
FROM sys.server_role_members m
JOIN sys.server_principals r ON r.principal_id = m.role_principal_id
JOIN sys.server_principals u ON u.principal_id = m.member_principal_id
WHERE u.name = 'user';