-- House Sparrow Dominance Analysis: Where the Introduced Species Wins
-- California 2005-2025
-- 
-- This query identifies counties and years where House Sparrows dominate over House Finches
-- Focus on understanding WHERE and WHEN the introduced European species outcompetes the native

WITH house_finch_yearly AS (
    SELECT 
        "COUNTY" as county,
        EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as observation_year,
        SUM(CASE
            WHEN UPPER(TRIM("OBSERVATION COUNT")) = 'X' THEN 1
            WHEN TRY_CAST("OBSERVATION COUNT" AS INTEGER) IS NOT NULL 
            THEN CAST("OBSERVATION COUNT" AS INTEGER)
            ELSE 0
        END) as house_finch_total
        
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                       max_line_size=25000000,
                       strict_mode=false,
                       ignore_errors=true)
    WHERE
        (LOWER("COMMON NAME") LIKE '%house%finch%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%haemorhous mexicanus%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%carpodacus mexicanus%')
        AND "STATE" = 'California'
        AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2025
        AND "OBSERVATION COUNT" IS NOT NULL
        AND "OBSERVATION COUNT" != ''
        AND "COUNTY" IS NOT NULL
        
    GROUP BY "COUNTY", EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE))
),

house_sparrow_yearly AS (
    SELECT 
        "COUNTY" as county,
        EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as observation_year,
        SUM(CASE
            WHEN UPPER(TRIM("OBSERVATION COUNT")) = 'X' THEN 1
            WHEN TRY_CAST("OBSERVATION COUNT" AS INTEGER) IS NOT NULL 
            THEN CAST("OBSERVATION COUNT" AS INTEGER)
            ELSE 0
        END) as house_sparrow_total
        
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                       max_line_size=25000000,
                       strict_mode=false,
                       ignore_errors=true)
    WHERE
        (LOWER("COMMON NAME") LIKE '%house%sparrow%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%passer domesticus%')
        AND "STATE" = 'California'
        AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2025
        AND "OBSERVATION COUNT" IS NOT NULL
        AND "OBSERVATION COUNT" != ''
        AND "COUNTY" IS NOT NULL
        
    GROUP BY "COUNTY", EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE))
),

combined_data AS (
    SELECT 
        COALESCE(hf.county, hs.county) as county,
        COALESCE(hf.observation_year, hs.observation_year) as observation_year,
        COALESCE(hf.house_finch_total, 0) as house_finch_total,
        COALESCE(hs.house_sparrow_total, 0) as house_sparrow_total,
        (COALESCE(hf.house_finch_total, 0) + COALESCE(hs.house_sparrow_total, 0)) as total_birds_both_species
        
    FROM house_finch_yearly hf
    FULL OUTER JOIN house_sparrow_yearly hs 
        ON hf.county = hs.county AND hf.observation_year = hs.observation_year
    WHERE (COALESCE(hf.house_finch_total, 0) + COALESCE(hs.house_sparrow_total, 0)) > 0
)

-- MAIN QUERY: Only show cases where House Sparrows dominate
SELECT 
    county,
    observation_year,
    house_finch_total,
    house_sparrow_total,
    total_birds_both_species,
    
    -- Dominance metrics
    ROUND((house_sparrow_total * 1.0 / house_finch_total), 2) as sparrow_to_finch_ratio,
    ROUND((house_sparrow_total * 100.0 / total_birds_both_species), 2) as sparrow_percentage,
    ROUND((house_finch_total * 100.0 / total_birds_both_species), 2) as finch_percentage,
    
    -- Magnitude of dominance
    CASE 
        WHEN house_sparrow_total > house_finch_total * 3 THEN 'STRONG_Sparrow_Dominance'
        WHEN house_sparrow_total > house_finch_total * 1.5 THEN 'MODERATE_Sparrow_Dominance' 
        ELSE 'WEAK_Sparrow_Dominance'
    END as dominance_strength,
    
    -- Raw numerical advantage
    (house_sparrow_total - house_finch_total) as sparrow_numerical_advantage

FROM combined_data

-- FILTER: Only show House Sparrow dominance cases
WHERE house_sparrow_total > house_finch_total
  AND total_birds_both_species >= 10  -- Filter out very small sample sizes

-- ORDER: Show strongest dominance first, then by year
ORDER BY sparrow_to_finch_ratio DESC, observation_year DESC;


-- =============================================================================
-- SUMMARY QUERY: County-level House Sparrow dominance patterns
-- =============================================================================

WITH house_finch_yearly AS (
    SELECT 
        "COUNTY" as county,
        EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as observation_year,
        SUM(CASE
            WHEN UPPER(TRIM("OBSERVATION COUNT")) = 'X' THEN 1
            WHEN TRY_CAST("OBSERVATION COUNT" AS INTEGER) IS NOT NULL 
            THEN CAST("OBSERVATION COUNT" AS INTEGER)
            ELSE 0
        END) as house_finch_total
        
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                       max_line_size=25000000,
                       strict_mode=false,
                       ignore_errors=true)
    WHERE
        (LOWER("COMMON NAME") LIKE '%house%finch%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%haemorhous mexicanus%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%carpodacus mexicanus%')
        AND "STATE" = 'California'
        AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2025
        AND "OBSERVATION COUNT" IS NOT NULL
        AND "OBSERVATION COUNT" != ''
        AND "COUNTY" IS NOT NULL
        
    GROUP BY "COUNTY", EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE))
),

house_sparrow_yearly AS (
    SELECT 
        "COUNTY" as county,
        EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as observation_year,
        SUM(CASE
            WHEN UPPER(TRIM("OBSERVATION COUNT")) = 'X' THEN 1
            WHEN TRY_CAST("OBSERVATION COUNT" AS INTEGER) IS NOT NULL 
            THEN CAST("OBSERVATION COUNT" AS INTEGER)
            ELSE 0
        END) as house_sparrow_total
        
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                       max_line_size=25000000,
                       strict_mode=false,
                       ignore_errors=true)
    WHERE
        (LOWER("COMMON NAME") LIKE '%house%sparrow%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%passer domesticus%')
        AND "STATE" = 'California'
        AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2025
        AND "OBSERVATION COUNT" IS NOT NULL
        AND "OBSERVATION COUNT" != ''
        AND "COUNTY" IS NOT NULL
        
    GROUP BY "COUNTY", EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE))
),

combined_data AS (
    SELECT 
        COALESCE(hf.county, hs.county) as county,
        COALESCE(hf.observation_year, hs.observation_year) as observation_year,
        COALESCE(hf.house_finch_total, 0) as house_finch_total,
        COALESCE(hs.house_sparrow_total, 0) as house_sparrow_total,
        (COALESCE(hf.house_finch_total, 0) + COALESCE(hs.house_sparrow_total, 0)) as total_birds_both_species
        
    FROM house_finch_yearly hf
    FULL OUTER JOIN house_sparrow_yearly hs 
        ON hf.county = hs.county AND hf.observation_year = hs.observation_year
    WHERE (COALESCE(hf.house_finch_total, 0) + COALESCE(hs.house_sparrow_total, 0)) > 0
),

dominance_by_county AS (
    SELECT 
        county,
        COUNT(*) as total_years_with_data,
        COUNT(CASE WHEN house_sparrow_total > house_finch_total THEN 1 END) as years_sparrow_dominated,
        COUNT(CASE WHEN house_sparrow_total > house_finch_total * 2 THEN 1 END) as years_strong_sparrow_dominance,
        MAX(CASE WHEN house_sparrow_total > house_finch_total 
            THEN (house_sparrow_total * 1.0 / house_finch_total) END) as max_sparrow_dominance_ratio,
        MAX(CASE WHEN house_sparrow_total > house_finch_total 
            THEN observation_year END) as most_recent_sparrow_dominance_year
    FROM combined_data
    WHERE total_birds_both_species >= 10
    GROUP BY county
)

-- SUMMARY: Counties where House Sparrows have EVER dominated
SELECT 
    county,
    total_years_with_data,
    years_sparrow_dominated,
    years_strong_sparrow_dominance,
    ROUND((years_sparrow_dominated * 100.0 / total_years_with_data), 1) as sparrow_dominance_percentage,
    ROUND(max_sparrow_dominance_ratio, 2) as peak_dominance_ratio,
    most_recent_sparrow_dominance_year,
    
    -- Classification
    CASE 
        WHEN years_sparrow_dominated = 0 THEN 'Never_Sparrow_Dominated'
        WHEN (years_sparrow_dominated * 100.0 / total_years_with_data) >= 50 THEN 'Frequently_Sparrow_Dominated'
        WHEN years_strong_sparrow_dominance > 0 THEN 'Occasionally_Strong_Sparrow_Dominance'
        ELSE 'Rarely_Sparrow_Dominated'
    END as dominance_pattern

FROM dominance_by_county
WHERE years_sparrow_dominated > 0  -- Only show counties where sparrows have dominated at least once

ORDER BY sparrow_dominance_percentage DESC, peak_dominance_ratio DESC;