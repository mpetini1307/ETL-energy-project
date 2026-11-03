INSERT INTO EnergyGold.dim.Year(yearId)
SELECT 
	*
FROM EnergySilver.dbo.Dim_Year


INSERT INTO EnergyGold.dim.Date (dateId, [date], yearId, [month], [day], [quarter], month_name, [week], [weekday], weekday_name)
SELECT
	d.dateId,
	d.cal_date,
	y.yearId,
	d.cal_month,
	d.cal_month_day,
	d.cal_quarter,
	d.cal_month_name,
	d.cal_week,
	d.cal_week_day,
	d.cal_day_name
FROM EnergySilver.dbo.Dim_Date d
	JOIN EnergyGold.dim.Year y ON (d.cal_year = y.yearId)

