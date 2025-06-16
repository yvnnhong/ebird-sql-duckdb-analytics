-- creating a temporary table to view the column headers/data categories
CREATE TEMPORARY TABLE ebird_temp AS
SELECT * FROM read_csv_auto('C:/Data/Birds/ebird_data.txt', strict_mode=false)
LIMIT 1;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'ebird_temp';

-- view first 10 rows of data 
SELECT * FROM read_csv_auto('C:/Data/Birds/ebird_data.txt', strict_mode=false) LIMIT 10;
