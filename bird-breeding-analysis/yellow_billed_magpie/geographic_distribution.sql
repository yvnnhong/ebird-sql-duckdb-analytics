-- Yellow-billed Magpie Geographic Distribution Analysis
-- County-level breeding success rates and range expansion patterns
-- Includes urban/rural habitat classification
-- Consistent with seasonal_breeding.sql: excludes only F, H, S, P codes

WITH breeding_success AS (
    SELECT 
        COUNTY,
        LATITUDE,
        LONGITUDE,
        EXTRACT(YEAR FROM CAST("LAST EDITED DATE" AS DATE)) as year,
        "BREEDING CODE",
        CASE 
            WHEN "BREEDING CODE" IN ('NY', 'FL', 'FY', 'CF', 'ON') THEN 'Successful_Breeding'
            WHEN "BREEDING CODE" IN ('NB', 'CN', 'N', 'C', 'T', 'A', 'PE', 'NE', 'M', 'DD', 'UN', 'S7') THEN 'Breeding_Attempt'
            ELSE 'Other_Breeding'
        END as breeding_status,
        -- Urban/rural classification based on county-level observation density
        CASE 
            WHEN COUNT(*) OVER (PARTITION BY COUNTY) > 100 
            THEN 'Urban/Suburban'
            ELSE 'Rural' 
        END as habitat_type
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', max_line_size=25000000, strict_mode=false, ignore_errors=true)
    WHERE "COMMON NAME" = 'Yellow-billed Magpie'
        AND "BREEDING CODE" IS NOT NULL
        AND "BREEDING CODE" != ''
        AND TRIM("BREEDING CODE") NOT IN ('F', 'H', 'S', 'P')
        AND LATITUDE IS NOT NULL 
        AND LONGITUDE IS NOT NULL
        AND COUNTY IS NOT NULL
),
county_summary AS (
    SELECT 
        COUNTY,
        habitat_type,
        year,
        COUNT(*) as total_observations,
        SUM(CASE WHEN breeding_status = 'Successful_Breeding' THEN 1 ELSE 0 END) as successful_breeding,
        SUM(CASE WHEN breeding_status = 'Breeding_Attempt' THEN 1 ELSE 0 END) as breeding_attempts,
        ROUND(
            SUM(CASE WHEN breeding_status = 'Successful_Breeding' THEN 1 ELSE 0 END) * 100.0 / 
            NULLIF(COUNT(*), 0), 
            2
        ) as success_rate_percent,
        MIN(year) as first_observed,
        MAX(year) as last_observed
    FROM breeding_success
    GROUP BY COUNTY, habitat_type, year
),
range_analysis AS (
    SELECT 
        COUNTY,
        habitat_type,
        COUNT(DISTINCT year) as years_active,
        MIN(year) as first_year,
        MAX(year) as last_year,
        AVG(success_rate_percent) as avg_success_rate,
        -- Range expansion indicator
        CASE 
            WHEN MIN(year) >= 2020 THEN 'Recent_Colonization'
            WHEN MAX(year) <= 2018 THEN 'Possible_Abandonment' 
            ELSE 'Stable_Range'
        END as range_status
    FROM county_summary
    WHERE success_rate_percent IS NOT NULL
    GROUP BY COUNTY, habitat_type
)
SELECT 
    ra.COUNTY,
    ra.habitat_type,
    ra.avg_success_rate,
    SUM(cs.total_observations) as total_obs,
    ra.years_active,
    ra.range_status,
    ra.first_year,
    ra.last_year
FROM range_analysis ra
JOIN county_summary cs ON ra.COUNTY = cs.COUNTY AND ra.habitat_type = cs.habitat_type
GROUP BY ra.COUNTY, ra.habitat_type, ra.avg_success_rate, ra.years_active, ra.range_status, ra.first_year, ra.last_year
ORDER BY ra.avg_success_rate DESC, total_obs DESC;