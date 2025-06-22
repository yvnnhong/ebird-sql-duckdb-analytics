-- Ridgway's Rail Geographic Expansion Analysis Using Localities & Coordinates (2005-2025)
-- 
-- This query tracks the geographic expansion of Ridgway's Rail populations using
-- locality IDs and coordinate-based grid analysis since Atlas Blocks may be sparse.
-- Creates custom geographic grid cells for fine-scale expansion detection.
--
-- Measures:
-- - New localities colonized each year (primary expansion metric)
-- - New coordinate grid cells occupied
-- - Geographic spread and expansion direction
-- - Range expansion velocity over time

WITH coordinate_grid AS (
    SELECT 
        "LOCALITY ID",
        "LOCALITY",
        "COUNTY",
        "LATITUDE",
        "LONGITUDE",
        
        -- Create custom grid cells (0.01 degree = ~1km resolution)
        FLOOR("LATITUDE" * 100) / 100 as lat_grid,
        FLOOR("LONGITUDE" * 100) / 100 as lon_grid,
        
        -- Combined grid cell identifier
        CONCAT(
            CAST(FLOOR("LATITUDE" * 100) / 100 AS VARCHAR), 
            '_', 
            CAST(FLOOR("LONGITUDE" * 100) / 100 AS VARCHAR)
        ) as grid_cell,
        
        MIN(EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE))) as first_year_observed,
        MIN("OBSERVATION DATE") as first_observation_date,
        COUNT(*) as total_observations_at_location
        
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
        AND "LATITUDE" IS NOT NULL
        AND "LONGITUDE" IS NOT NULL
        AND "LOCALITY ID" IS NOT NULL
        
    GROUP BY "LOCALITY ID", "LOCALITY", "COUNTY", "LATITUDE", "LONGITUDE", lat_grid, lon_grid, grid_cell
),

yearly_expansion AS (
    SELECT 
        first_year_observed,
        
        -- Primary expansion metrics
        COUNT(DISTINCT "LOCALITY ID") as new_localities_colonized,
        COUNT(DISTINCT grid_cell) as new_grid_cells_occupied,
        COUNT(DISTINCT "COUNTY") as new_counties_discovered,
        
        -- Geographic measurements
        MIN("LATITUDE") as min_latitude_new_sites,
        MAX("LATITUDE") as max_latitude_new_sites,
        MIN("LONGITUDE") as min_longitude_new_sites,
        MAX("LONGITUDE") as max_longitude_new_sites,
        
        -- Calculate spatial spread of new colonizations
        (MAX("LATITUDE") - MIN("LATITUDE")) as latitude_span_expansion,
        (MAX("LONGITUDE") - MIN("LONGITUDE")) as longitude_span_expansion,
        
        -- Center of expansion (geographic centroid)
        ROUND(AVG("LATITUDE"), 4) as expansion_center_lat,
        ROUND(AVG("LONGITUDE"), 4) as expansion_center_lon,
        
        -- Range metrics
        ROUND(SQRT(POWER(MAX("LATITUDE") - MIN("LATITUDE"), 2) + POWER(MAX("LONGITUDE") - MIN("LONGITUDE"), 2)), 4) as diagonal_range_new_sites
        
    FROM coordinate_grid
    GROUP BY first_year_observed
),

cumulative_expansion AS (
    SELECT 
        first_year_observed,
        new_localities_colonized,
        new_grid_cells_occupied,
        new_counties_discovered,
        
        -- Running totals showing cumulative range expansion
        SUM(new_localities_colonized) OVER (ORDER BY first_year_observed ROWS UNBOUNDED PRECEDING) as cumulative_localities,
        SUM(new_grid_cells_occupied) OVER (ORDER BY first_year_observed ROWS UNBOUNDED PRECEDING) as cumulative_grid_cells,
        SUM(new_counties_discovered) OVER (ORDER BY first_year_observed ROWS UNBOUNDED PRECEDING) as cumulative_counties,
        
        -- Geographic expansion metrics
        latitude_span_expansion,
        longitude_span_expansion,
        (latitude_span_expansion * longitude_span_expansion) as geographic_area_new_sites,
        expansion_center_lat,
        expansion_center_lon,
        diagonal_range_new_sites
        
    FROM yearly_expansion
),

expansion_direction AS (
    SELECT 
        *,
        -- Calculate expansion direction (compared to previous year)
        LAG(expansion_center_lat) OVER (ORDER BY first_year_observed) as prev_center_lat,
        LAG(expansion_center_lon) OVER (ORDER BY first_year_observed) as prev_center_lon,
        
        -- Expansion velocity metrics
        ROUND(AVG(new_localities_colonized) OVER (
            ORDER BY first_year_observed 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 1) as three_year_avg_locality_expansion,
        
        ROUND(AVG(new_grid_cells_occupied) OVER (
            ORDER BY first_year_observed 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 1) as three_year_avg_grid_expansion
        
    FROM cumulative_expansion
)

SELECT 
    first_year_observed as expansion_year,
    
    -- Primary expansion metrics
    new_localities_colonized,
    cumulative_localities,
    new_grid_cells_occupied,
    cumulative_grid_cells,
    
    -- Secondary metrics
    new_counties_discovered,
    cumulative_counties,
    
    -- Geographic spread of expansion
    ROUND(latitude_span_expansion, 4) as lat_span_new_sites,
    ROUND(longitude_span_expansion, 4) as lon_span_new_sites,
    ROUND(geographic_area_new_sites, 6) as area_coverage_new_sites,
    
    -- Expansion center and direction
    expansion_center_lat,
    expansion_center_lon,
    
    -- Direction of expansion (lat/lon shift from previous year)
    CASE 
        WHEN prev_center_lat IS NOT NULL 
        THEN ROUND(expansion_center_lat - prev_center_lat, 4) 
        ELSE NULL 
    END as lat_shift_from_prev_year,
    
    CASE 
        WHEN prev_center_lon IS NOT NULL 
        THEN ROUND(expansion_center_lon - prev_center_lon, 4) 
        ELSE NULL 
    END as lon_shift_from_prev_year,
    
    -- Expansion velocity
    three_year_avg_locality_expansion,
    three_year_avg_grid_expansion,
    
    -- Range diagonal (overall spatial extent)
    diagonal_range_new_sites

FROM expansion_direction
ORDER BY first_year_observed;