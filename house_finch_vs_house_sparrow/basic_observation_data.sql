-- House Finch vs House Sparrow: Native vs Introduced Species Urban Ecology Analysis
-- California 2005-2025
-- 
-- This analysis compares how native California House Finches vs introduced European House Sparrows
-- have adapted to urban environments over the past two decades

-- =============================================================================
-- HOUSE FINCH ANALYSIS (Native California Species)
-- =============================================================================
-- Expected: Stable or increasing trends as they adapt to urban environments

WITH house_finch_data AS (
    SELECT 
        "COUNTY",
        "SAMPLING EVENT IDENTIFIER",
        "OBSERVATION DATE",
        "BREEDING CODE",
        "LATITUDE",
        "LONGITUDE",
        
        -- Get the maximum count per sampling event
        MAX(CASE
            WHEN UPPER(TRIM("OBSERVATION COUNT")) = 'X' THEN 1
            WHEN TRY_CAST("OBSERVATION COUNT" AS INTEGER) IS NOT NULL 
            THEN CAST("OBSERVATION COUNT" AS INTEGER)
            ELSE 0
        END) as max_birds_in_event,
        
        EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as observation_year
        
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                       max_line_size=25000000,
                       strict_mode=false,
                       ignore_errors=true)
    WHERE
        -- Target House Finch
        (LOWER("COMMON NAME") LIKE '%house%finch%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%haemorhous mexicanus%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%carpodacus mexicanus%')
        
        AND "STATE" = 'California'
        AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2025
        AND "OBSERVATION COUNT" IS NOT NULL
        AND "OBSERVATION COUNT" != ''
        AND "COUNTY" IS NOT NULL
        AND "SAMPLING EVENT IDENTIFIER" IS NOT NULL
        
    GROUP BY "COUNTY", "SAMPLING EVENT IDENTIFIER", "OBSERVATION DATE", 
             "BREEDING CODE", "LATITUDE", "LONGITUDE", observation_year
)

-- Yearly summary with breeding data
SELECT 
    observation_year,
    COUNT(*) as total_observations,
    COUNT(DISTINCT "SAMPLING EVENT IDENTIFIER") as unique_surveys,
    SUM(max_birds_in_event) as total_birds_observed,
    COUNT(CASE WHEN "BREEDING CODE" IS NOT NULL AND "BREEDING CODE" != '' THEN 1 END) as breeding_observations,
    COUNT(DISTINCT "COUNTY") as counties_with_data,
    ROUND((COUNT(CASE WHEN "BREEDING CODE" IS NOT NULL AND "BREEDING CODE" != '' THEN 1 END) * 100.0 / COUNT(*)), 1) as breeding_percentage
FROM house_finch_data
GROUP BY observation_year
ORDER BY observation_year;

-- =============================================================================
-- HOUSE SPARROW ANALYSIS (Introduced European Species)
-- =============================================================================
-- Expected: Declining or stable trends (introduced species struggling vs native)

WITH house_sparrow_data AS (
    SELECT 
        "COUNTY",
        "SAMPLING EVENT IDENTIFIER",
        "OBSERVATION DATE",
        "BREEDING CODE",
        "LATITUDE",
        "LONGITUDE",
        
        -- Get the maximum count per sampling event
        MAX(CASE
            WHEN UPPER(TRIM("OBSERVATION COUNT")) = 'X' THEN 1
            WHEN TRY_CAST("OBSERVATION COUNT" AS INTEGER) IS NOT NULL 
            THEN CAST("OBSERVATION COUNT" AS INTEGER)
            ELSE 0
        END) as max_birds_in_event,
        
        EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as observation_year
        
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                       max_line_size=25000000,
                       strict_mode=false,
                       ignore_errors=true)
    WHERE
        -- Target House Sparrow
        (LOWER("COMMON NAME") LIKE '%house%sparrow%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%passer domesticus%')
        
        AND "STATE" = 'California'
        AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2025
        AND "OBSERVATION COUNT" IS NOT NULL
        AND "OBSERVATION COUNT" != ''
        AND "COUNTY" IS NOT NULL
        AND "SAMPLING EVENT IDENTIFIER" IS NOT NULL
        
    GROUP BY "COUNTY", "SAMPLING EVENT IDENTIFIER", "OBSERVATION DATE", 
             "BREEDING CODE", "LATITUDE", "LONGITUDE", observation_year
)

-- Yearly summary with breeding data (identical format to House Finch)
SELECT 
    observation_year,
    COUNT(*) as total_observations,
    COUNT(DISTINCT "SAMPLING EVENT IDENTIFIER") as unique_surveys,
    SUM(max_birds_in_event) as total_birds_observed,
    COUNT(CASE WHEN "BREEDING CODE" IS NOT NULL AND "BREEDING CODE" != '' THEN 1 END) as breeding_observations,
    COUNT(DISTINCT "COUNTY") as counties_with_data,
    ROUND((COUNT(CASE WHEN "BREEDING CODE" IS NOT NULL AND "BREEDING CODE" != '' THEN 1 END) * 100.0 / COUNT(*)), 1) as breeding_percentage
FROM house_sparrow_data
GROUP BY observation_year
ORDER BY observation_year;

-- =============================================================================
-- HOUSE FINCH TOTAL BIRDS OBSERVED ONLY
-- =============================================================================
-- Simplified query showing only actual bird count trends (population analysis focus)

WITH house_finch_data AS (
    SELECT 
        "COUNTY",
        "SAMPLING EVENT IDENTIFIER",
        "OBSERVATION DATE",
        "BREEDING CODE",
        "LATITUDE",
        "LONGITUDE",
        
        -- Get the maximum count per sampling event
        MAX(CASE
            WHEN UPPER(TRIM("OBSERVATION COUNT")) = 'X' THEN 1
            WHEN TRY_CAST("OBSERVATION COUNT" AS INTEGER) IS NOT NULL 
            THEN CAST("OBSERVATION COUNT" AS INTEGER)
            ELSE 0
        END) as max_birds_in_event,
        
        EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as observation_year
        
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                       max_line_size=25000000,
                       strict_mode=false,
                       ignore_errors=true)
    WHERE
        -- Target House Finch
        (LOWER("COMMON NAME") LIKE '%house%finch%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%haemorhous mexicanus%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%carpodacus mexicanus%')
        
        AND "STATE" = 'California'
        AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2025
        AND "OBSERVATION COUNT" IS NOT NULL
        AND "OBSERVATION COUNT" != ''
        AND "COUNTY" IS NOT NULL
        AND "SAMPLING EVENT IDENTIFIER" IS NOT NULL
        
    GROUP BY "COUNTY", "SAMPLING EVENT IDENTIFIER", "OBSERVATION DATE", 
             "BREEDING CODE", "LATITUDE", "LONGITUDE", observation_year
)

-- Show only year and total birds observed
SELECT 
    observation_year,
    SUM(max_birds_in_event) as total_birds_observed
FROM house_finch_data
GROUP BY observation_year
ORDER BY observation_year;

-- =============================================================================
-- HOUSE SPARROW TOTAL BIRDS OBSERVED ONLY
-- =============================================================================
-- Simplified query showing only actual bird count trends (population analysis focus)

WITH house_sparrow_data AS (
    SELECT 
        "COUNTY",
        "SAMPLING EVENT IDENTIFIER",
        "OBSERVATION DATE",
        "BREEDING CODE",
        "LATITUDE",
        "LONGITUDE",
        
        -- Get the maximum count per sampling event
        MAX(CASE
            WHEN UPPER(TRIM("OBSERVATION COUNT")) = 'X' THEN 1
            WHEN TRY_CAST("OBSERVATION COUNT" AS INTEGER) IS NOT NULL 
            THEN CAST("OBSERVATION COUNT" AS INTEGER)
            ELSE 0
        END) as max_birds_in_event,
        
        EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as observation_year
        
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                       max_line_size=25000000,
                       strict_mode=false,
                       ignore_errors=true)
    WHERE
        -- Target House Sparrow
        (LOWER("COMMON NAME") LIKE '%house%sparrow%'
         OR LOWER("SCIENTIFIC NAME") LIKE '%passer domesticus%')
        
        AND "STATE" = 'California'
        AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2025
        AND "OBSERVATION COUNT" IS NOT NULL
        AND "OBSERVATION COUNT" != ''
        AND "COUNTY" IS NOT NULL
        AND "SAMPLING EVENT IDENTIFIER" IS NOT NULL
        
    GROUP BY "COUNTY", "SAMPLING EVENT IDENTIFIER", "OBSERVATION DATE", 
             "BREEDING CODE", "LATITUDE", "LONGITUDE", observation_year
)

-- Show only year and total birds observed
SELECT 
    observation_year,
    SUM(max_birds_in_event) as total_birds_observed
FROM house_sparrow_data
GROUP BY observation_year
ORDER BY observation_year;