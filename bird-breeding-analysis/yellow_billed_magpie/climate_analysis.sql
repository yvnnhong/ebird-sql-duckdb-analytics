WITH yearly_breeding AS (
    SELECT 
        EXTRACT(YEAR FROM CAST("LAST EDITED DATE" AS DATE)) as year,
        EXTRACT(MONTH FROM CAST("LAST EDITED DATE" AS DATE)) as month,
        "BREEDING CODE",
        CASE 
            WHEN "BREEDING CODE" IN ('NY', 'FL', 'FY', 'CF') THEN 'Successful_Breeding'
            WHEN "BREEDING CODE" IN ('NB', 'CN', 'ON', 'N') THEN 'Breeding_Attempt'
            ELSE 'Other'
        END as breeding_status,
        -- Define breeding season timing
        CASE 
            WHEN month IN (3,4,5) THEN 'Peak_Spring'
            WHEN month IN (6,7) THEN 'Early_Summer'
            WHEN month IN (8,9) THEN 'Late_Summer'
            ELSE 'Off_Season'
        END as breeding_period
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt')
    WHERE "COMMON NAME" = 'Yellow-billed Magpie'
        AND "BREEDING CODE" IS NOT NULL
        AND "BREEDING CODE" != ''
        AND TRIM("BREEDING CODE") NOT IN ('F', 'H', 'S', 'P')
),
climate_classification AS (
    SELECT 
        year,
        COUNT(*) as total_observations,
        SUM(CASE WHEN breeding_status = 'Successful_Breeding' THEN 1 ELSE 0 END) as successful_breeding,
        SUM(CASE WHEN breeding_status = 'Breeding_Attempt' THEN 1 ELSE 0 END) as breeding_attempts,
        ROUND(
            SUM(CASE WHEN breeding_status = 'Successful_Breeding' THEN 1 ELSE 0 END) * 100.0 / 
            NULLIF(SUM(CASE WHEN breeding_status IN ('Successful_Breeding', 'Breeding_Attempt') THEN 1 ELSE 0 END), 0), 
            2
        ) as success_rate,
        -- California drought/hot years (adjust based on actual climate data)
        CASE 
            WHEN year IN (2015, 2016, 2021, 2022) THEN 'Drought/Hot_Year'
            WHEN year IN (2017, 2019, 2023) THEN 'Wet/Cool_Year'
            ELSE 'Normal_Year'
        END as climate_year_type
    FROM yearly_breeding
    GROUP BY year
),

breeding_timing_analysis AS (
    SELECT 
        year,
        climate_year_type,
        breeding_period,
        COUNT(*) as period_observations,
        SUM(CASE WHEN breeding_status = 'Successful_Breeding' THEN 1 ELSE 0 END) as period_success
    FROM yearly_breeding
    JOIN climate_classification USING (year)
    WHERE breeding_period != 'Off_Season'
    GROUP BY year, climate_year_type, breeding_period
),

climate_impact_summary AS (
    SELECT 
        climate_year_type,
        COUNT(DISTINCT year) as years_in_category,
        AVG(success_rate) as avg_success_rate,
        AVG(total_observations) as avg_annual_observations,
        STDDEV(success_rate) as success_rate_variability,
        MIN(success_rate) as min_success_rate,
        MAX(success_rate) as max_success_rate
    FROM climate_classification
    WHERE success_rate IS NOT NULL
    GROUP BY climate_year_type
)

-- Main results showing climate impact
SELECT 
    cc.year,
    cc.climate_year_type,
    cc.total_observations,
    cc.successful_breeding,
    cc.success_rate,
    -- Compare to climate type average
    cis.avg_success_rate as climate_type_avg,
    ROUND(cc.success_rate - cis.avg_success_rate, 2) as deviation_from_avg,
    -- Population trend indicator
    LAG(cc.total_observations, 1) OVER (ORDER BY cc.year) as prev_year_obs,
    ROUND(
        (cc.total_observations - LAG(cc.total_observations, 1) OVER (ORDER BY cc.year)) * 100.0 / 
        NULLIF(LAG(cc.total_observations, 1) OVER (ORDER BY cc.year), 0), 
        2
    ) as year_over_year_change_percent
FROM climate_classification cc
JOIN climate_impact_summary cis ON cc.climate_year_type = cis.climate_year_type
ORDER BY cc.year;

-- Summary by climate type
SELECT * FROM climate_impact_summary ORDER BY avg_success_rate DESC;