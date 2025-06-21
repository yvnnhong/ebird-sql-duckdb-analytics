-- TRICOLORED BLACKBIRD POPULATION TRENDS (2005-2025)
-- Basic population overview showing total observations, counties, and estimated birds per year
-- This query reveals the dramatic population swings contradicting official survey data

SELECT 
    EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as year,
    COUNT(*) as total_observations,
    COUNT(DISTINCT "COUNTY") as counties,
    SUM(CASE 
        WHEN "OBSERVATION COUNT" = 'X' THEN 1 
        ELSE CAST("OBSERVATION COUNT" AS INTEGER) 
    END) as total_birds
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt')
WHERE "COMMON NAME" = 'Tricolored Blackbird'
GROUP BY year
ORDER BY year;