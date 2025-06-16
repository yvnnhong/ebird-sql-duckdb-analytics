-- creating a temporary table to view the column headers/data categories for the FAKE table
CREATE TEMPORARY TABLE ebird_temp AS
SELECT * FROM read_csv_auto('C:/Data/Birds/ebird_data.txt', strict_mode=false)
LIMIT 1;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'ebird_temp';

-- view first 10 rows of data of the fake file 
SELECT * FROM read_csv_auto('C:/Data/Birds/false_random_data.txt', strict_mode=false) LIMIT 10;

-- view first 10 rows of data of the real file 
SELECT * FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', strict_mode=false) LIMIT 10;

-- creating a temporary table to view the column headers/data categories for the REAL table
CREATE TEMPORARY TABLE ebird_temp AS
SELECT * FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', strict_mode=false)
LIMIT 1;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'ebird_temp';

--view first 20 rows of the following categories 
SELECT 
  "COMMON NAME", 
  "SCIENTIFIC NAME", 
  "BREEDING CATEGORY"
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', strict_mode=false)
LIMIT 20;

--view other 4 cool column categories 
SELECT 
  "COMMON NAME",          -- Bird species name
  "OBSERVATION COUNT",    -- How many birds were counted in that sighting
  "STATE",                -- Location (state)
  "DURATION MINUTES"      -- How long observer spent on the checklist (effort)
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', strict_mode=false)
LIMIT 20;

-- search for a specific species / filter for keywords 
SELECT DISTINCT "COMMON NAME"
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', strict_mode=false)
WHERE LOWER("COMMON NAME") LIKE '%yellow-billed magpie%';


-- search for the yellow-billed magpie 
-- Use ignore_errors to skip malformed lines
SELECT DISTINCT "COMMON NAME"
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt', 
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)  -- This will skip problematic lines
WHERE "COMMON NAME" IS NOT NULL 
  AND LOWER("COMMON NAME") LIKE '%yellow-billed magpie%';

--more efficient search: 
SELECT *
FROM (
    SELECT *
    FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                       max_line_size=25000000,
                       strict_mode=false,
                       ignore_errors=true,
                       sample_size=100000)  -- Process in smaller chunks
    WHERE LOWER("COMMON NAME") LIKE '%yellow-billed magpie%'
    LIMIT 10
);

-- view actual sighting records for the yellow-billed magpie: 
SELECT "COMMON NAME", "SCIENTIFIC NAME", "STATE", "COUNTY", "OBSERVATION DATE", "LOCALITY"
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
WHERE LOWER("COMMON NAME") LIKE '%yellow-billed magpie%'
LIMIT 10;

--view breeding data for the yellow-billed magpie: 

--query to get the top 10 breeding codes for the yellow-billed magpie: 
SELECT "BREEDING CODE", COUNT(*) as frequency
FROM read_csv_auto('C:/Data/Birds/ebird_observation_data.txt',
                   max_line_size=25000000,
                   strict_mode=false,
                   ignore_errors=true)
WHERE "BREEDING CODE" IS NOT NULL
GROUP BY "BREEDING CODE"
ORDER BY COUNT(*) DESC
LIMIT 10;

