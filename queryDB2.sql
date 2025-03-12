## Continental Ecological Performance Analysis ##
SELECT cl.continent,
       COUNT(gts.country_id) AS country_count,
       AVG(gts.green_index) AS avg_green_index,
       SUM(gts.total_emissions) AS total_emissions,
       SUM(gts.total_clean_innovation) AS total_innovation
FROM continent_list cl
LEFT JOIN green_totalscores gts ON cl.country_id = gts.country_id
GROUP BY cl.continent
ORDER BY avg_green_index DESC, total_emissions ASC;
## High Emission Countries with Low Energy Investment Analysis
SELECT ce.country_id,
       ce.carbon_emissions,
       ci.energy_investment,
       ci.patents,
       (SELECT AVG(energy_investment)
        FROM clean_innovation ci_sub
        WHERE ci_sub.country_id IN (SELECT country_id FROM carbon_emissions WHERE carbon_emissions BETWEEN ce.carbon_emissions - 2 AND ce.carbon_emissions + 2)) AS avg_energy_investment
FROM carbon_emissions ce
JOIN clean_innovation ci ON ce.country_id = ci.country_id
WHERE ce.carbon_emissions > (SELECT AVG(carbon_emissions) FROM carbon_emissions)
AND ci.energy_investment < (SELECT AVG(energy_investment) FROM clean_innovation)
ORDER BY ce.carbon_emissions DESC, ci.energy_investment ASC;
## Analysis of Low Climate Action Countries with High Green Index ##
SELECT cp.country_id,
       gts.green_index,
       cp.climate_action,
       gts.total_emissions
FROM green_totalscores gts
JOIN climate_policy cp ON gts.country_id = cp.country_id
WHERE cp.climate_action < (SELECT AVG(climate_action) FROM climate_policy) + 2  -- Allowing a wider range for low climate action
  AND gts.green_index > (SELECT AVG(green_index) FROM green_totalscores) - 1  -- Allowing a lower threshold for green index
ORDER BY gts.green_index DESC, gts.total_emissions ASC;
## Analysis of High Population Countries (more than 10 millions people) with Carbon Emissions and Innovation Metrics ##
SELECT pi.country,
       pi.population_2021,
       ce.carbon_emissions,
       ci.energy_investment,
       gts.green_index
FROM population_index pi
JOIN carbon_emissions ce ON pi.country = ce.country_id
JOIN clean_innovation ci ON pi.country = ci.country_id
JOIN green_totalscores gts ON pi.country = gts.country_id
WHERE pi.population_2021 > 10e6
ORDER BY ce.carbon_emissions DESC, ci.energy_investment DESC;