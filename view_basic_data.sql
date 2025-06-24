-- eBird Dataset Exploration and Validation Queries
-- Purpose: Initial data exploration, column inspection, and basic validation
-- Dataset: 47GB eBird observation data from Cornell Lab API
-- Platform: DuckDB SQL with CSV auto-detection
-- Note: Run .mode column first to ensure all columns display properly

-- =============================================================================
-- DATASET OVERVIEW AND STRUCTURE ANALYSIS
-- =============================================================================

-- Preview first 10 records to understand data structure
-- (.mode column recommended for proper column display)
SELECT * 
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', 
                   max_line_size=25000000,
                   strict_mode=false, 
                   ignore_errors=true) 
LIMIT 10;

-- =============================================================================
-- COLUMN SCHEMA INSPECTION
-- =============================================================================

-- Create temporary table for column analysis
CREATE TEMPORARY TABLE ebird_schema AS
SELECT * 
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', 
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
LIMIT 1;

-- Extract all column names for documentation
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'ebird_schema'
ORDER BY ordinal_position;

-- =============================================================================
-- CORE DATA CATEGORIES EXPLORATION
-- =============================================================================

-- Taxonomic and identification data
SELECT 
    "COMMON NAME", 
    "SCIENTIFIC NAME", 
    "CATEGORY",
    "TAXONOMIC ORDER"
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
LIMIT 20;

-- Observation and effort data
SELECT 
    "COMMON NAME",
    "OBSERVATION COUNT",
    "OBSERVATION DATE",
    "DURATION MINUTES",
    "NUMBER OBSERVERS",
    "PROTOCOL NAME"
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
LIMIT 20;

-- Geographic and location data
SELECT 
    "COMMON NAME",
    "COUNTRY",
    "STATE",
    "COUNTY",
    "LOCALITY",
    "LATITUDE",
    "LONGITUDE"
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
LIMIT 20;

-- Breeding and behavioral data
SELECT 
    "COMMON NAME",
    "BREEDING CODE",
    "BREEDING CATEGORY",
    "BEHAVIOR CODE",
    "AGE/SEX"
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
WHERE "BREEDING CODE" IS NOT NULL
LIMIT 20;

-- =============================================================================
-- DATA QUALITY VALIDATION
-- =============================================================================

-- Check for distinct species in dataset
SELECT COUNT(DISTINCT "COMMON NAME") as total_species_count
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
WHERE "COMMON NAME" IS NOT NULL;

-- Verify California data coverage
SELECT 
    "STATE",
    COUNT(*) as observation_count,
    COUNT(DISTINCT "COMMON NAME") as species_count,
    MIN("OBSERVATION DATE") as earliest_date,
    MAX("OBSERVATION DATE") as latest_date
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
WHERE "STATE" = 'California'
GROUP BY "STATE";

-- =============================================================================
-- SPECIES-SPECIFIC VALIDATION QUERIES
-- =============================================================================

-- Verify target species presence: Yellow-billed Magpie
SELECT DISTINCT 
    "COMMON NAME",
    "SCIENTIFIC NAME",
    COUNT(*) as total_observations
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
WHERE LOWER("COMMON NAME") LIKE '%yellow-billed magpie%'
GROUP BY "COMMON NAME", "SCIENTIFIC NAME";

-- Verify target species presence: House Finch and House Sparrow
SELECT DISTINCT 
    "COMMON NAME",
    "SCIENTIFIC NAME",
    COUNT(*) as total_observations
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
WHERE (LOWER("COMMON NAME") LIKE '%house finch%' 
       OR LOWER("COMMON NAME") LIKE '%house sparrow%')
   AND "STATE" = 'California'
GROUP BY "COMMON NAME", "SCIENTIFIC NAME"
ORDER BY total_observations DESC;

-- Verify target species presence: Ridgway's Rail
SELECT DISTINCT 
    "COMMON NAME",
    "SCIENTIFIC NAME",
    COUNT(*) as total_observations
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
WHERE (LOWER("COMMON NAME") LIKE '%ridgway%rail%'
       OR LOWER("COMMON NAME") LIKE '%clapper rail%'
       OR LOWER("SCIENTIFIC NAME") LIKE '%rallus obsoletus%')
   AND "STATE" = 'California'
GROUP BY "COMMON NAME", "SCIENTIFIC NAME"
ORDER BY total_observations DESC;

-- =============================================================================
-- BREEDING CODE ANALYSIS
-- =============================================================================

-- Distribution of breeding codes across all species
SELECT 
    "BREEDING CODE", 
    COUNT(*) as frequency,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
WHERE "BREEDING CODE" IS NOT NULL 
   AND "BREEDING CODE" != ''
   AND "STATE" = 'California'
GROUP BY "BREEDING CODE"
ORDER BY frequency DESC
LIMIT 15;

-- =============================================================================
-- TEMPORAL COVERAGE ANALYSIS
-- =============================================================================

-- Annual observation coverage
SELECT 
    EXTRACT(YEAR FROM CAST("OBSERVATION DATE" AS DATE)) as observation_year,
    COUNT(*) as annual_observations,
    COUNT(DISTINCT "COMMON NAME") as species_count
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
WHERE "STATE" = 'California'
   AND "OBSERVATION DATE" IS NOT NULL
GROUP BY observation_year
ORDER BY observation_year;

-- =============================================================================
-- PROTOCOL AND EFFORT ANALYSIS
-- =============================================================================

-- Survey protocol distribution
SELECT 
    "PROTOCOL NAME",
    COUNT(*) as observation_count,
    ROUND(AVG(CAST("DURATION MINUTES" AS DOUBLE)), 1) as avg_duration_minutes
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
WHERE "PROTOCOL NAME" IS NOT NULL 
   AND "STATE" = 'California'
GROUP BY "PROTOCOL NAME"
ORDER BY observation_count DESC
LIMIT 10;