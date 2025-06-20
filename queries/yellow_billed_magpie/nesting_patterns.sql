--sql query order: (put @ top of every file for personal reference)
-- SELECT      -- What columns to return
-- FROM        -- What table/source
-- WHERE       -- Filter individual rows
-- GROUP BY    -- Group rows together
-- HAVING      -- Filter groups (after GROUP BY)
-- ORDER BY    -- Sort the results


/*YELLOW-BILLED MAGPIE CORE BREEDING BEHAVIORS BY SEASON*/
/*
Goal of this query: Identify the top 3 breeding behaviors (codes) for each season across 
47GB California bird sightings dataset (2015–2025), excluding non-breeding behaviors 
and noise (e.g., flyovers).
*/

--THIS ONE BELOW ACTUALLY WORKS 
-- Top breeding codes for each season (fall, winter, spring, summer)
-- Excludes flyovers and non-breeding behaviors
-- Modified version with broader exclusions
WITH seasonal_breeding AS (
    SELECT
        CASE
            WHEN EXTRACT(MONTH FROM CAST("LAST EDITED DATE" AS DATE)) IN (3,4,5) THEN 'Spring'
            WHEN EXTRACT(MONTH FROM CAST("LAST EDITED DATE" AS DATE)) IN (6,7,8) THEN 'Summer'
            WHEN EXTRACT(MONTH FROM CAST("LAST EDITED DATE" AS DATE)) IN (9,10,11) THEN 'Fall'
            WHEN EXTRACT(MONTH FROM CAST("LAST EDITED DATE" AS DATE)) IN (12,1,2) THEN 'Winter'
        END as season, -- first column 
        "BREEDING CODE", -- second column  
        COUNT(*) as observations -- third column 
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', max_line_size=25000000, strict_mode=false, ignore_errors=true)
    WHERE LOWER("COMMON NAME") LIKE '%yellow-billed magpie%'
        AND "BREEDING CODE" IS NOT NULL
        AND "BREEDING CODE" != ''
        AND TRIM("BREEDING CODE") NOT IN ('F', 'H', 'S', 'P')  
        -- TRIM removes whitespace, tabs, newline before and after the text 
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


-- Query to see all remaining breeding codes for Yellow-billed Magpie
-- (after excluding non-breeding indicators F, H, S, P)

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
