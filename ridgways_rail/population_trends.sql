-- Ridgway's Rail Population Trends Analysis (2005-2025)
-- 
-- This query analyzes 20-year population trends for the endangered Ridgway's Rail 
-- in California to assess conservation program effectiveness. The species was 
-- formerly known as California Clapper Rail and has been the focus of extensive
-- habitat restoration efforts in San Francisco Bay salt marshes.
--
-- Key metrics tracked:
-- - Annual observation counts and bird populations
-- - Geographic distribution (counties and locations)
-- - Observer engagement patterns
-- - Handling of 'X' records (species present but not counted)

SELECT
    EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as observation_year,
    COUNT(*) as total_observations,
    -- Handle 'X' values (present but not counted) by treating them as 1
    SUM(CASE
        WHEN UPPER(TRIM("OBSERVATION COUNT")) = 'X' THEN 1
        ELSE CAST("OBSERVATION COUNT" AS INTEGER)
    END) as total_birds_observed,
    COUNT(DISTINCT "OBSERVER ID") as unique_observers,
    COUNT(DISTINCT "LOCALITY ID") as unique_locations,
    -- Average calculation excluding X values
    ROUND(AVG(CASE
        WHEN UPPER(TRIM("OBSERVATION COUNT")) = 'X' THEN NULL
        ELSE CAST("OBSERVATION COUNT" AS DOUBLE)
    END), 2) as avg_birds_per_sighting,
    COUNT(DISTINCT "COUNTY") as counties_with_sightings,
    -- Count how many 'X' observations (present but not counted)
    SUM(CASE WHEN UPPER(TRIM("OBSERVATION COUNT")) = 'X' THEN 1 ELSE 0 END) as x_observations
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
WHERE
    -- Target Ridgway's Rail (may be listed under both old and new names)
    (LOWER("COMMON NAME") LIKE '%ridgway%rail%'
     OR LOWER("COMMON NAME") LIKE '%clapper rail%'
     OR LOWER("SCIENTIFIC NAME") LIKE '%rallus obsoletus%'
     OR LOWER("SCIENTIFIC NAME") LIKE '%rallus longirostris obsoletus%')

    -- California only
    AND "STATE" = 'California'

    -- Date range 2005-2025
    AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2025

    -- Filter for valid observation counts (numbers or X)
    AND "OBSERVATION COUNT" IS NOT NULL
    AND "OBSERVATION COUNT" != ''
    AND (UPPER(TRIM("OBSERVATION COUNT")) = 'X'
         OR (TRY_CAST("OBSERVATION COUNT" AS INTEGER) IS NOT NULL
             AND CAST("OBSERVATION COUNT" AS INTEGER) > 0
             AND CAST("OBSERVATION COUNT" AS INTEGER) < 100))

GROUP BY observation_year
ORDER BY observation_year;