/*
TRICOLORED BLACKBIRD DROUGHT IMPACT ANALYSIS (2015-2017 California Drought)
==============================================================================
Dataset: 47GB eBird observation data (2015-2025) from Cornell Lab API
Objective: Analyze ecological impacts of severe California drought on tricolored blackbirds
Key Finding: Drought caused habitat compression rather than simple population decline

Tech Stack: DuckDB, SQL, 47GB CSV processing with robust error handling
Business Impact: Environmental compliance, ESG reporting, conservation strategy
*/

-- QUERY 1: BREEDING SUCCESS ANALYSIS
-- Purpose: Measure reproductive stress during drought vs normal conditions
-- Hypothesis: Breeding activity may be suppressed or altered during drought years
-- Key Insight: Breeding patterns show stress signals, with erratic percentages during drought
WITH breeding_comparison AS (
    SELECT 
        EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as year,
        CASE 
            WHEN EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2015 AND 2017 
            THEN 'Drought Period'
            ELSE 'Non-Drought'
        END as period_type,
        COUNT(*) as total_observations,
        -- Count breeding observations (any non-null breeding code indicates reproductive behavior)
        SUM(CASE WHEN "BREEDING CODE" IS NOT NULL AND "BREEDING CODE" != '' THEN 1 ELSE 0 END) as breeding_observations,
        -- Calculate breeding percentage as key performance indicator
        ROUND(100.0 * SUM(CASE WHEN "BREEDING CODE" IS NOT NULL AND "BREEDING CODE" != '' THEN 1 ELSE 0 END) / COUNT(*), 2) as breeding_percentage
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', 
                       max_line_size=25000000, strict_mode=false, ignore_errors=true)
    WHERE LOWER("COMMON NAME") LIKE '%tricolored blackbird%'
        AND "OBSERVATION DATE" IS NOT NULL
        AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2013 AND 2020
    GROUP BY year, period_type
)
SELECT * FROM breeding_comparison
ORDER BY year;

-- QUERY 2: HABITAT COMPRESSION ANALYSIS  
-- Purpose: Detect if drought forced birds into fewer, more crowded locations
-- Hypothesis: Habitat loss leads to larger flock sizes and concentration effects
-- Key Insight: 42% larger average flock sizes during drought = classic habitat compression
WITH flock_analysis AS (
    SELECT 
        EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as year,
        CASE 
            WHEN EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2015 AND 2017 
            THEN 'Drought Period'
            ELSE 'Non-Drought'
        END as period_type,
        -- Robust type conversion handling non-numeric values ('X' = present but not counted)
        TRY_CAST("OBSERVATION COUNT" AS INTEGER) as flock_size,
        "COUNTY",
        "LOCALITY"
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', 
                       max_line_size=25000000, strict_mode=false, ignore_errors=true)
    WHERE LOWER("COMMON NAME") LIKE '%tricolored blackbird%'
        AND "OBSERVATION DATE" IS NOT NULL
        AND TRY_CAST("OBSERVATION COUNT" AS INTEGER) IS NOT NULL  -- Filter to numeric counts only
        AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2013 AND 2020
)
SELECT 
    period_type,
    COUNT(*) as total_numeric_observations,
    -- Central tendency measures to detect distribution shifts
    ROUND(AVG(flock_size), 2) as avg_flock_size,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY flock_size), 2) as median_flock_size,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY flock_size), 2) as q75_flock_size,
    ROUND(PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY flock_size), 2) as q95_flock_size,
    MAX(flock_size) as max_flock_size,
    -- Categorical analysis: count observations by flock size buckets
    SUM(CASE WHEN flock_size >= 1000 THEN 1 ELSE 0 END) as mega_flocks_1000_plus,
    SUM(CASE WHEN flock_size >= 500 THEN 1 ELSE 0 END) as large_flocks_500_plus,
    SUM(CASE WHEN flock_size >= 100 THEN 1 ELSE 0 END) as medium_flocks_100_plus,
    SUM(CASE WHEN flock_size < 10 THEN 1 ELSE 0 END) as small_groups_under_10
FROM flock_analysis
GROUP BY period_type
ORDER BY period_type;

/*
RESULTS SUMMARY:
================
Breeding Analysis: Erratic breeding patterns during drought (1.22% → 1.49% → 3.79%)
Habitat Compression: 42% larger average flock sizes during drought (133.8 vs 93.86 birds/flock)
Business Value: Quantified environmental impact for ESG reporting and conservation planning
*/