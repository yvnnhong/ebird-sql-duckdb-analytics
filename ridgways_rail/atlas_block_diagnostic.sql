-- Atlas Block Data Availability Diagnostic
-- Check if Atlas Block data exists for Ridgway's Rail

SELECT 
    COUNT(*) as total_ridgways_rail_records,
    COUNT("ATLAS BLOCK") as records_with_atlas_block,
    COUNT(CASE WHEN "ATLAS BLOCK" IS NOT NULL AND "ATLAS BLOCK" != '' THEN 1 END) as records_with_valid_atlas_block,
    COUNT(DISTINCT "ATLAS BLOCK") as unique_atlas_blocks,
    
    -- Sample of atlas block values
    MIN("ATLAS BLOCK") as sample_atlas_block_1,
    MAX("ATLAS BLOCK") as sample_atlas_block_2,
    
    -- Check what percentage have atlas blocks
    ROUND((COUNT(CASE WHEN "ATLAS BLOCK" IS NOT NULL AND "ATLAS BLOCK" != '' THEN 1 END) * 100.0 / COUNT(*)), 1) as percent_with_atlas_blocks

FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
WHERE
    (LOWER("COMMON NAME") LIKE '%ridgway%rail%'
     OR LOWER("COMMON NAME") LIKE '%clapper rail%'
     OR LOWER("SCIENTIFIC NAME") LIKE '%rallus obsoletus%'
     OR LOWER("SCIENTIFIC NAME") LIKE '%rallus longirostris obsoletus%')
    AND "STATE" = 'California'
    AND EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) BETWEEN 2005 AND 2025;