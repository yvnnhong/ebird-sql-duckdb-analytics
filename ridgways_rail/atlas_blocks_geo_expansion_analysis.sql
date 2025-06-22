-- Ridgway's Rail Geographic Expansion Analysis Using Atlas Blocks (2005-2025)
-- 
-- This query tracks the precise geographic expansion of Ridgway's Rail populations
-- using Atlas Blocks (standardized grid system) to detect fine-scale range changes.
-- Atlas blocks provide higher resolution than counties for mapping colonization
-- events and detecting habitat-specific expansion patterns.
--
-- Measures:
-- - New atlas blocks colonized each year (primary expansion metric)
-- - New counties as secondary measure 
-- - Geographic spread using coordinate ranges of new blocks
-- - Range expansion velocity and patterns

WITH first_appearances AS (
    SELECT 
        "ATLAS BLOCK",
        "COUNTY",
        "LOCALITY ID",
        "LOCALITY",
        "LATITUDE",
        "LONGITUDE",
        MIN(EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE))) as first_year_observed,
        
        -- Get additional context for first appearance
        MIN("OBSERVATION DATE") as first_observation_date,
        COUNT(*) as total_observations_in_block
        
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
        AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2025
        AND "OBSERVATION COUNT" IS NOT NULL
        AND "OBSERVATION COUNT" != ''
        AND (UPPER(TRIM("OBSERVATION COUNT")) = 'X'
             OR (TRY_CAST("OBSERVATION COUNT" AS INTEGER) IS NOT NULL
                 AND CAST("OBSERVATION COUNT" AS INTEGER) > 0
                 AND CAST("OBSERVATION COUNT" AS INTEGER) < 100))
        AND "ATLAS BLOCK" IS NOT NULL
        AND "ATLAS BLOCK" != ''
        AND "LATITUDE" IS NOT NULL
        AND "LONGITUDE" IS NOT NULL
        
    GROUP BY "ATLAS BLOCK", "COUNTY", "LOCALITY ID", "LOCALITY", "LATITUDE", "LONGITUDE"
),

yearly_expansion AS (
    SELECT 
        first_year_observed,
        
        -- Primary expansion metrics (Atlas Blocks)
        COUNT(DISTINCT "ATLAS BLOCK") as new_atlas_blocks_colonized,
        COUNT(DISTINCT "COUNTY") as new_counties_discovered,
        COUNT(DISTINCT "LOCALITY ID") as new_localities_discovered,
        
        -- Geographic measurements of new blocks
        MIN("LATITUDE") as min_latitude_new_blocks,
        MAX("LATITUDE") as max_latitude_new_blocks,
        MIN("LONGITUDE") as min_longitude_new_blocks,
        MAX("LONGITUDE") as max_longitude_new_blocks,
        
        -- Calculate spatial spread of new colonizations
        (MAX("LATITUDE") - MIN("LATITUDE")) as latitude_span_new_blocks,
        (MAX("LONGITUDE") - MIN("LONGITUDE")) as longitude_span_new_blocks,
        
        -- Average coordinates of expansion (centroid)
        ROUND(AVG("LATITUDE"), 4) as avg_latitude_new_blocks,
        ROUND(AVG("LONGITUDE"), 4) as avg_longitude_new_blocks
        
    FROM first_appearances
    GROUP BY first_year_observed
),

cumulative_expansion AS (
    SELECT 
        first_year_observed,
        new_atlas_blocks_colonized,
        new_counties_discovered,
        new_localities_discovered,
        
        -- Running totals - showing cumulative range expansion
        SUM(new_atlas_blocks_colonized) OVER (ORDER BY first_year_observed ROWS UNBOUNDED PRECEDING) as cumulative_atlas_blocks,
        SUM(new_counties_discovered) OVER (ORDER BY first_year_observed ROWS UNBOUNDED PRECEDING) as cumulative_counties,
        SUM(new_localities_discovered) OVER (ORDER BY first_year_observed ROWS UNBOUNDED PRECEDING) as cumulative_localities,
        
        -- Geographic expansion metrics
        latitude_span_new_blocks,
        longitude_span_new_blocks,
        (latitude_span_new_blocks * longitude_span_new_blocks) as geographic_area_new_blocks,
        
        avg_latitude_new_blocks,
        avg_longitude_new_blocks
        
    FROM yearly_expansion
)

SELECT 
    first_year_observed as expansion_year,
    
    -- Primary expansion metrics
    new_atlas_blocks_colonized,
    cumulative_atlas_blocks,
    
    -- Secondary metrics
    new_counties_discovered,
    cumulative_counties,
    new_localities_discovered,
    cumulative_localities,
    
    -- Geographic spread of expansion
    ROUND(latitude_span_new_blocks, 4) as lat_span_new_colonizations,
    ROUND(longitude_span_new_blocks, 4) as lon_span_new_colonizations,
    ROUND(geographic_area_new_blocks, 6) as area_coverage_new_blocks,
    
    -- Expansion center coordinates
    avg_latitude_new_blocks as expansion_center_lat,
    avg_longitude_new_blocks as expansion_center_lon,
    
    -- Expansion velocity (blocks per year as rolling average)
    ROUND(AVG(new_atlas_blocks_colonized) OVER (
        ORDER BY first_year_observed 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 1) as three_year_avg_block_expansion

FROM cumulative_expansion
ORDER BY first_year_observed;



