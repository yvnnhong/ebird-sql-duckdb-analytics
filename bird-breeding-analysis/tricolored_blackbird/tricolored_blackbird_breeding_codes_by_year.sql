-- TRICOLORED BLACKBIRD BREEDING CODES BY YEAR (2005-2025)
-- Shows which breeding behaviors were observed each year
-- Reveals the dramatic explosion of breeding activity in 2024

SELECT 
    EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as year,
    "BREEDING CODE",
    COUNT(*) as observations
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt')
WHERE "COMMON NAME" = 'Tricolored Blackbird'
    AND "BREEDING CODE" IS NOT NULL
    AND "BREEDING CODE" != ''
GROUP BY year, "BREEDING CODE"
ORDER BY year, "BREEDING CODE";