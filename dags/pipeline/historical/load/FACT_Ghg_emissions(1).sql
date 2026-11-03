
INSERT INTO EnergyGold.fact.Ghg_emissions (yearId, countryId, net_ghg_MtCO2eq, net_ghg_MtCO2eq_per_capita)
SELECT 
    y.yearId,
    c.countryId,
    emi.net_ghg_MtCO2eq,                                        
    emi.Net_ghg_t_CO2eq_per_capita       
FROM EnergySilver.env.ghg_emissions emi                         
    JOIN EnergyGold.dim.[Year] y   ON y.yearId = emi.[year]
    JOIN EnergyGold.dim.Country c  ON c.countryId = emi.countryId        

