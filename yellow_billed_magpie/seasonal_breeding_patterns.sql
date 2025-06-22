-- Yellow-billed Magpie Seasonal Breeding Patterns
-- Analysis of top 3 breeding behaviors by season and overall distribution
-- Excludes non-breeding behaviors (F, H, S, P)

-- Top breeding codes for each season
WITH seasonal_breeding AS (
    SELECT
        CASE
            WHEN EXTRACT(MONTH FROM CAST("LAST EDITED DATE" AS DATE)) IN (3,4,5) THEN 'Spring'
            WHEN EXTRACT(MONTH FROM CAST("LAST EDITED DATE" AS DATE)) IN (6,7,8) THEN 'Summer'
            WHEN EXTRACT(MONTH FROM CAST("LAST EDITED DATE" AS DATE)) IN (9,10,11) THEN 'Fall'
            WHEN EXTRACT(MONTH FROM CAST("LAST EDITED DATE" AS DATE)) IN (12,1,2) THEN 'Winter'
        END as season,
        "BREEDING CODE",
        COUNT(*) as observations
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', max_line_size=25000000, strict_mode=false, ignore_errors=true)
    WHERE LOWER("COMMON NAME") LIKE '%yellow-billed magpie%'
        AND "BREEDING CODE" IS NOT NULL
        AND "BREEDING CODE" != ''
        AND TRIM("BREEDING CODE") NOT IN ('F', 'H', 'S', 'P')
    GROUP BY season, "BREEDING CODE"
),
ranked_codes AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY season ORDER BY observations DESC) as rank
    FROM seasonal_breeding
)
SELECT season, "BREEDING CODE", observations
FROM ranked_codes
WHERE rank <= 3
ORDER BY season, rank;

-- All breeding codes distribution
SELECT 
    TRIM("BREEDING CODE") as cleaned_breeding_code,
    COUNT(*) as frequency,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () as percentage
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', 
                   max_line_size=25000000, 
                   strict_mode=false, 
                   ignore_errors=true)
WHERE LOWER("COMMON NAME") LIKE '%yellow-billed magpie%'
    AND "BREEDING CODE" IS NOT NULL
    AND "BREEDING CODE" != ''
    AND TRIM("BREEDING CODE") NOT IN ('F', 'H', 'S', 'P')
GROUP BY TRIM("BREEDING CODE")
ORDER BY frequency DESC;