-- Ridgway's Rail Conservation Impact by County (2005-2025)
-- 
-- This query analyzes which California counties show the greatest improvement
-- in Ridgway's Rail populations, helping identify where conservation efforts
-- have been most successful. Compares early period (2005-2010) vs recent 
-- period (2019-2024) to measure conservation program effectiveness by location.
--
-- Results can be cross-referenced with known habitat restoration projects
-- in SF Bay Area counties to validate conservation program impacts.

WITH county_periods AS (
    SELECT 
        "COUNTY",
        -- Early period (2005-2010) - before major restoration scaling
        SUM(CASE 
            WHEN EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2010
            THEN CASE
                WHEN UPPER(TRIM("OBSERVATION COUNT")) = 'X' THEN 1
                ELSE CAST("OBSERVATION COUNT" AS INTEGER)
            END
            ELSE 0
        END) as early_period_birds,
        
        COUNT(CASE 
            WHEN EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2010
            THEN 1 
        END) as early_period_observations,
        
        -- Recent period (2019-2024) - peak conservation results
        SUM(CASE 
            WHEN EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2019 AND 2024
            THEN CASE
                WHEN UPPER(TRIM("OBSERVATION COUNT")) = 'X' THEN 1
                ELSE CAST("OBSERVATION COUNT" AS INTEGER)
            END
            ELSE 0
        END) as recent_period_birds,
        
        COUNT(CASE 
            WHEN EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2019 AND 2024
            THEN 1 
        END) as recent_period_observations,
        
        -- Total for context
        COUNT(*) as total_observations_all_years
        
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                       max_line_size=25000000,
                       strict_mode=false,
                       ignore_errors=true)
    WHERE
        -- Target Ridgway's Rail
        (LOWER("COMMON NAME") LIKE '%ridgway%rail%'
         OR LOWER("COMMON NAME") LIKE '%clapper rail%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%rallus obsoletus%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%rallus longirostris obsoletus%')
        
        AND "STATE" = 'California'
        AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2024
        AND "OBSERVATION COUNT" IS NOT NULL
        AND "OBSERVATION COUNT" != ''
        AND (UPPER(TRIM("OBSERVATION COUNT")) = 'X'
             OR (TRY_CAST("OBSERVATION COUNT" AS INTEGER) IS NOT NULL
                 AND CAST("OBSERVATION COUNT" AS INTEGER) > 0
                 AND CAST("OBSERVATION COUNT" AS INTEGER) < 100))
        AND "COUNTY" IS NOT NULL
        
    GROUP BY "COUNTY"
)

SELECT 
    "COUNTY",
    early_period_birds,
    recent_period_birds,
    (recent_period_birds - early_period_birds) as bird_count_improvement,
    
    early_period_observations,
    recent_period_observations,
    (recent_period_observations - early_period_observations) as observation_improvement,
    
    -- Calculate percentage improvement (handle division by zero)
    CASE 
        WHEN early_period_birds > 0 
        THEN ROUND(((recent_period_birds - early_period_birds) * 100.0 / early_period_birds), 1)
        ELSE NULL 
    END as percent_bird_improvement,
    
    CASE 
        WHEN early_period_observations > 0 
        THEN ROUND(((recent_period_observations - early_period_observations) * 100.0 / early_period_observations), 1)
        ELSE NULL 
    END as percent_observation_improvement,
    
    total_observations_all_years

FROM county_periods
WHERE early_period_birds > 0  -- Only counties with baseline data
ORDER BY bird_count_improvement DESC;