DROP TABLE IF EXISTS EnergySilver.demo.median_income
DROP TABLE IF EXISTS EnergySilver.demo.population
DROP TABLE IF EXISTS EnergySilver.demo.countries


---------------------------------------------------------------------------------------------------------------------
------------------------------------------------MEDIAN_INCOME--------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

WITH median_income_unpivot AS
	(SELECT [geo\TIME_PERIOD] as countryCode, statinfo, [year], [income]
	FROM (
		SELECT statinfo, [geo\TIME_PERIOD], [2015],[2016],[2017],[2018],[2019],[2020],[2021],[2022],[2023],[2024],[2025]
		FROM demo.median_income
		WHERE age = 'TOTAL' AND sex = 'T'
	) p
	UNPIVOT
	(
		[income] FOR [year] IN ([2015],[2016],[2017],[2018],[2019],[2020],[2021],[2022],[2023],[2024],[2025])
	)AS unpvt
)
SELECT 
	CAST(countryCode as NVARCHAR(2)) as countryId,
	CAST([year] AS INT) as [year],
	CAST(income AS FLOAT) as median_income_eur
FROM median_income_unpivot


---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------COUNTRIES----------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------

SELECT
    CAST([code] AS NVARCHAR(2))                     AS countryId,
    CAST([pays] AS NVARCHAR(100))                AS country_name,
    CAST([latitude]  AS FLOAT)          AS latitude,
    CAST([longitude] AS FLOAT)          AS longitude,

    CAST(CASE WHEN [code] IN ('AT','BE','BG','HR','CY','CZ','DK','EE','FI','FR','DE','GR','HU','IE',
                              'IT','LV','LT','LU','MT','NL','PL','PT','RO','SK','SI','ES','SE')
              THEN 1 ELSE 0 END AS BIT)             AS is_eu,

    CAST(CASE WHEN [code] IN ('AD','AL','AT','BA','BE','BG','BY','CH','CY','CZ','DE','DK','EE','ES',
                              'FI','FR','GB','GR','HR','HU','IE','IS','IT','LI','LT','LU','LV','MC',
                              'MD','ME','MK','MT','NL','NO','PL','PT','RO','RS','RU','SE','SI','SK',
                              'SM','UA','VA','XK')
              THEN 1 ELSE 0 END AS BIT) AS is_europe
FROM demo.countries
	WHERE code != 'SH'

---------------------------------------------------------------------------------------------------------------------
-------------------------------------------------POPULATION----------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------


WITH population_unpivot AS (
SELECT [geo\TIME_PERIOD] as countryCode, [year], population
FROM (
	SELECT [geo\TIME_PERIOD], [2015],[2016],[2017],[2018],[2019],[2020],[2021],[2022],[2023],[2024],[2025],[2026]
	FROM demo.population
)p2
UNPIVOT(
	population FOR [year] IN ( [2015],[2016],[2017],[2018],[2019],[2020],[2021],[2022],[2023],[2024],[2025],[2026])
)unpvt2
)
SELECT 
	CAST(countryCode AS NVARCHAR(2)) AS countryId,
	CAST([year] as INT) AS [year],
	CAST(CAST([population] as FLOAT) as INT) AS [population]
FROM population_unpivot