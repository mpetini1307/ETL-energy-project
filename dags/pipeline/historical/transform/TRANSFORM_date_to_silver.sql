DROP TABLE IF EXISTS EnergySilver.dbo.Dim_Date;
DROP TABLE IF EXISTS EnergySilver.dbo.Dim_Year;


--Creation Dim_Date
EXEC sp_create_calender_dim_table @start_date = '2014-01-01', @end_date = '2026-12-31' 

--Creation Dim_Year
SELECT DISTINCT
	cal_year
INTO EnergySilver.dbo.Dim_Year
FROM EnergySilver.dbo.Dim_Date
