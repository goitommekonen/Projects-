/*The SQL queries contained in this file answers the integrated project Maji Ndogo part I. 
They correspond to the questions in the order they were presented. 
This section entails the completion of four specific tasks. */

-- Task 1: Get to know our data 
-- identify the total number of tables in our database. 
SHOW TABLES; -- displayed eight different tables
-- Retrieving five recrods from each tables 

SELECT 
	* 
FROM 
	md_water_services.data_dictionary
LIMIT 5;

SELECT 
	* 
FROM 
	md_water_services.employee
LIMIT 5;

SELECT 
	* 
FROM 
	md_water_services.global_water_access
LIMIT 5;

SELECT 
	* 
FROM 
	md_water_services.location
LIMIT 5;

SELECT 
	* 
FROM 
	md_water_services.visits
LIMIT 5;

SELECT 
	* 
FROM 
	md_water_services.water_quality
LIMIT 5;

SELECT 
	* 
FROM 
	md_water_services.water_source
LIMIT 5;

SELECT 
	* 
FROM 
	md_water_services.well_pollution
LIMIT 5;

-- Task 2: Dive deep into the water sources 
-- this query displays the distinct types of water sources from our water_source table 
SELECT DISTINCT 
    type_of_water_source  -- we are specifying the type of water sources
FROM water_source; 

-- unpack the visits to water sources 
-- Write an SQL query that retrieves all records from this table where the time_in_queue 
-- is more than some crazy time, say 500 min. How would it feel to queue 8 hours for water?
SELECT 
	*
FROM 
	md_water_services.visits
WHERE 
	time_in_queue > 500; -- 105 rows affected. 
    
-- using source_id we get from the above query, identify the types of water source from another table
SELECT 
	type_of_water_source
    , number_of_people_served
FROM 
	md_water_services.water_source
WHERE 
	source_id IN ('AkKi00881224', 'SoRu37635224', 'SoRu36096224');

-- Task 3: access to the quality of water sources
 SELECT 
	* 
FROM 
	md_water_services.water_quality
LIMIT 5;

/*So please write a query to find records where the subject_quality_score is 10 -- 
only looking for home taps -- and where the source
was visited a second time. What will this tell us?*/

SELECT 
	* 
FROM 
	md_water_services.water_quality
WHERE 
	subjective_quality_score = 10 
AND 
	visit_count = 2; -- 218 rows affected 
    
-- Task 5: Investigate pollution issues 
-- Find the right table and print the first few rows. 
SELECT 
	* 
FROM 
	md_water_services.well_pollution
LIMIT 5;

-- Write a query that checks if the results is Clean but the biological column is > 0.01.
SELECT 
	*
FROM 
	md_water_services.well_pollution
WHERE 
	results = 'Clean'
AND 
	biological >0.01; -- ehm, 64 rows affected. 
-- we have some inconsistencies in how the well statuses are recorded.
-- It seems like, in some cases, if the description field begins with the word “Clean”, the results have been classified as “Clean” 
-- in the results column, even though the biological column is > 0.01.
-- we need to fix this error
SELECT 
	* 
FROM 
	md_water_services.well_pollution
WHERE 
	description LIKE 'Clean_%'; -- ehm, 38 rows affected
-- update Clean Bacteria: E. coli should updated to Bacteria: E. coli
-- but before we need to create a copy well pollution table

/*Ok, so here is how I did it:
−− Case 1a: Update descriptions that mistakenly mention
`Clean Bacteria: E. coli` to `Bacteria: E. coli`
−− Case 1b: Update the descriptions that mistakenly mention
`Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia
−− Case 2: Update the `result` to `Contaminated: Biological` where
`biological` is greater than 0.01 plus current results is `Clean`*/

DROP TABLE IF EXISTS well_pollution_copy;

CREATE TABLE
md_water_services.well_pollution_copy
AS (
SELECT
*
FROM
md_water_services.well_pollution
);

-- case 1a
UPDATE 
	md_water_services.well_pollution_copy
SET 
	description = 'Bacteria: E. coli'
WHERE 
	description = 'Clean Bacteria: E. coli';-- 26 rows affected
    
-- case 1b
UPDATE 
	md_water_services.well_pollution_copy
SET 
	description = 'Bacteria: Giardia Lamblia'
WHERE 
	description = 'Clean Bacteria: Giardia Lamblia';-- 12 rows affected 
-- case 2
UPDATE
	well_pollution_copy
SET
	results = 'Contaminated: Biological'
WHERE
	biological > 0.01 AND results = 'Clean'; -- 64 rows affected 
    
-- a test query to make sure the errors are fixed. 
SELECT
	*
FROM
	well_pollution_copy
WHERE
	description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01); -- 0 rows affected, which implies our data is now correct

-- now we can change the values in well_pollution same way as we did in well_pollution_copy

UPDATE 
	md_water_services.well_pollution
SET 
	description =  'Bacteria: E. coli'
WHERE 
	description = 'Clean Bacteria: E. coli';
    
UPDATE 
	md_water_services.well_pollution
SET 
	description = 'Bacteria: Giardia Lamblia'
WHERE 
	description = 'Clean Bacteria: Giardia Lamblia';
UPDATE 
	md_water_services.well_pollution
SET 
	results = 'Contaminated: Biological'
WHERE 
	biological > 0.01 
AND 
	results = 'Clean';
    
-- Now we delete well_pollution_copy table
-- we don't it any longer 
DROP TABLE md_water_services.well_pollution_copy;

-- End of project part I 

