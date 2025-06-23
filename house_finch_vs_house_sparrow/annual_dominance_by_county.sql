-- House Finch vs House Sparrow: Geographic Distribution by County and Year
-- California 2005-2025
-- 
-- Shows year-by-year trends to identify changes in species dominance over time

-- HOUSE FINCH by County and Year
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

-- HOUSE SPARROW by County and Year
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
)

-- Combine results with year-by-year breakdown
SELECT 
    hf.county,
    hf.observation_year,
    hf.house_finch_total,
    COALESCE(hs.house_sparrow_total, 0) as house_sparrow_total,
    (hf.house_finch_total + COALESCE(hs.house_sparrow_total, 0)) as total_birds_both_species,
    
    -- Dominance ratio
    CASE 
        WHEN COALESCE(hs.house_sparrow_total, 0) = 0 THEN 999.9
        ELSE ROUND((hf.house_finch_total * 1.0 / hs.house_sparrow_total), 2)
    END as finch_to_sparrow_ratio,
    
    -- Species dominance determination
    CASE 
        WHEN hf.house_finch_total > COALESCE(hs.house_sparrow_total, 0) * 2 THEN 'House_Finch_Dominant'
        WHEN COALESCE(hs.house_sparrow_total, 0) > hf.house_finch_total * 2 THEN 'House_Sparrow_Dominant'
        ELSE 'Roughly_Equal'
    END as species_dominance,
    
    -- Percentage breakdowns (double precision)
    ROUND((hf.house_finch_total * 100.0 / NULLIF(hf.house_finch_total + COALESCE(hs.house_sparrow_total, 0), 0)), 2) as finch_percentage_double,
    ROUND((COALESCE(hs.house_sparrow_total, 0) * 100.0 / NULLIF(hf.house_finch_total + COALESCE(hs.house_sparrow_total, 0), 0)), 2) as sparrow_percentage_double

FROM house_finch_yearly hf
LEFT JOIN house_sparrow_yearly hs ON hf.county = hs.county AND hf.observation_year = hs.observation_year

UNION ALL

-- Add county-years that only have House Sparrows
SELECT 
    hs.county,
    hs.observation_year,
    0 as house_finch_total,
    hs.house_sparrow_total,
    hs.house_sparrow_total as total_birds_both_species,
    0.0 as finch_to_sparrow_ratio,
    'House_Sparrow_Dominant' as species_dominance,
    0.0 as finch_percentage_double,
    100.0 as sparrow_percentage_double

FROM house_sparrow_yearly hs
LEFT JOIN house_finch_yearly hf ON hs.county = hf.county AND hs.observation_year = hf.observation_year
WHERE hf.county IS NULL

ORDER BY county, observation_year;