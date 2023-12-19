-- Task 1: Generating an ERD 
/*
	Click Database on the menu bar.
    Then, Select Reverse Engineering or CTR + R 
*/
-- Task 2: Integrating Auditor's report 
USE md_water_services;
-- create table auditor_report 
DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
	`location_id` VARCHAR(32),
	`type_of_water_source` VARCHAR(64),
	`true_water_source_score` int DEFAULT NULL,
	`statements` VARCHAR(255)
);
-- import the auditor report csv file
-- Query the table and see what is inside
SELECT 
	* 
FROM 
	auditor_report;
SELECT 
	location_id
    ,true_water_source_score
FROM 
	auditor_report;
-- Now, join the visits table to the auditor_report and water_quality tables. 
SELECT 
	auditor_report.location_id AS Audit_location
    ,auditor_report.true_water_source_score AS True_water_source_score
    ,visits.location_id AS Visit_location
    ,visits.record_id AS Record_id 
    ,water_quality.subjective_quality_score AS Subjective_quality_score 
FROM 
	auditor_report
JOIN 
	visits 
ON 
	auditor_report.location_id = visits.location_id
JOIN 
	water_quality
ON 
	visits.record_id = water_quality.record_id;
    
/*
Since the above result set is a duplicate, we can drop one of the location_id columns. 
Let's leave record_id and rename the scores to surveyor_score and auditor_score to make it clear which scores
we're looking at in the results set.
*/
SELECT 
	auditor_report.location_id AS Location_id
    ,visits.record_id AS Record_id 
    ,auditor_report.true_water_source_score AS auditor_score
    ,water_quality.subjective_quality_score AS employee_score 
FROM 
	auditor_report
JOIN 
	visits 
ON 
	auditor_report.location_id = visits.location_id
JOIN 
	water_quality
ON 
	visits.record_id = water_quality.record_id;
-- now let's analyse! 
SELECT 
	auditor_report.location_id AS Location_id
    ,visits.record_id AS Record_id 
    ,auditor_report.true_water_source_score AS auditor_score
    ,water_quality.subjective_quality_score AS employee_score 
FROM 
	auditor_report
JOIN 
	visits 
ON 
	auditor_report.location_id = visits.location_id
JOIN 
	water_quality
ON 
	visits.record_id = water_quality.record_id -- with no condition we get 2698 rows
where auditor_report.true_water_source_score = water_quality.subjective_quality_score -- displays 2505 rows
AND 
	visits.visit_count = 1;
 -- displays 1518 rows
-- but we have 1620 rows from the audit report 
-- That is an excellent result. 1518/1620 = 94% of the records the auditor checked were correct!!
-- But that means that 102 records are incorrect. So let's look at those. You can do it by adding one character in the last query! 

SELECT 
	auditor_report.location_id AS Location_id
    ,visits.record_id AS Record_id 
    ,auditor_report.true_water_source_score AS auditor_score
    ,water_quality.subjective_quality_score AS employee_score 
FROM 
	auditor_report
JOIN 
	visits 
ON 
	auditor_report.location_id = visits.location_id
JOIN 
	water_quality
ON 
	visits.record_id = water_quality.record_id;
-- now let's analyse! 
SELECT 
	auditor_report.location_id AS Location_id
    ,visits.record_id AS Record_id 
    ,auditor_report.true_water_source_score AS auditor_score
    ,water_quality.subjective_quality_score AS employee_score 
FROM 
	auditor_report
JOIN 
	visits 
ON 
	auditor_report.location_id = visits.location_id
JOIN 
	water_quality
ON 
	visits.record_id = water_quality.record_id 
where auditor_report.true_water_source_score != water_quality.subjective_quality_score -- displays 102 rows, the incorrect rows
AND 
	visits.visit_count = 1;
-- but we relied a lot on the type_of_water_source, so let's check if there are any errors there. 
SELECT 
	auditor_report.location_id AS Location_id
    ,auditor_report.type_of_water_Source AS Auditor_source
    ,water_source.type_of_water_source AS Survey_source
    ,visits.record_id AS Record_id 
    ,auditor_report.true_water_source_score AS auditor_score
    ,water_quality.subjective_quality_score AS employee_score 
FROM 
	auditor_report
JOIN 
	visits 
ON 
	auditor_report.location_id = visits.location_id
JOIN 
	water_quality
ON 
	visits.record_id = water_quality.record_id
JOIN 
	water_source
ON 
	water_Source.source_id = visits.source_id
WHERE 
	auditor_report.true_water_source_score = water_quality.subjective_quality_score
	AND 
		visits.visit_count = 1;
-- The result set shows that the types of sources look the same!
-- remove the columns and JOIN statement for water_sources again

SELECT 
	auditor_report.location_id AS Location_id
    ,visits.record_id AS Record_id 
    ,auditor_report.true_water_source_score AS auditor_score
    ,water_quality.subjective_quality_score AS employee_score 
FROM 
	auditor_report
JOIN 
	visits 
ON 
	auditor_report.location_id = visits.location_id
JOIN 
	water_quality
ON 
	visits.record_id = water_quality.record_id
WHERE 
	auditor_report.true_water_source_score = water_quality.subjective_quality_score
	AND 
		visits.visit_count = 1;
-- Task 3: Linking records to employees 
-- Where did these errors may have come from. At some of the locations, employees assigned scores incorrectly, 
-- and those records ended up in this results set.
-- let's JOIN the assigned_employee_id for all the people on our list from the visits table to our query
SELECT 
	auditor_report.location_id AS Location_id
    ,visits.record_id AS Record_id 
    ,employee.employee_name AS Assigned_employee_name
    ,auditor_report.true_water_source_score AS auditor_score
    ,water_quality.subjective_quality_score AS employee_score 
FROM 
	auditor_report
JOIN 
	visits 
ON 
	auditor_report.location_id = visits.location_id
JOIN 
	water_quality
ON 
	visits.record_id = water_quality.record_id
JOIN 
	employee 
ON 
	employee.assigned_employee_id = visits.assigned_employee_id
WHERE 
	auditor_report.true_water_source_score != water_quality.subjective_quality_score
	AND 
		visits.visit_count = 1;
        
-- Well this query is massive and complex, so maybe it is a good idea to save this as a CTE, 
-- so when we do more analysis, we can just call that CTE like it was a table
WITH Incorrect_records AS( -- CTE definition 
		SELECT 
		auditor_report.location_id AS Location_id
		,visits.record_id AS Record_id 
		,employee.employee_name AS Assigned_employee_name
		,auditor_report.true_water_source_score AS auditor_score
		,water_quality.subjective_quality_score AS employee_score 
	FROM 
		auditor_report
	JOIN 
		visits 
	ON 
		auditor_report.location_id = visits.location_id
	JOIN 
		water_quality
	ON 
		visits.record_id = water_quality.record_id
	JOIN 
		employee 
	ON 
		employee.assigned_employee_id = visits.assigned_employee_id
	WHERE 
		auditor_report.true_water_source_score != water_quality.subjective_quality_score
		AND 
			visits.visit_count = 1
) 
SELECT 
	assigned_employee_name,
    COUNT(auditor_score) AS Number_of_mistakes_by_surveyor
FROM 
	Incorrect_records
GROUP BY 
	assigned_employee_name
ORDER BY 
	COUNT(auditor_score) DESC; -- outer query 
-- It looks like some of the surveyors are making a lot of "mistakes" while many of the other surveyors are only making a few. 

-- Task four: Gathering some evidence! 
-- Paste the above CTE query here and refine the whole query as it is getting massive and complex.
WITH Incorrect_records AS (
    SELECT 
        ar.location_id AS Location_id,
        v.record_id AS Record_id,
        e.employee_name AS Assigned_employee_name,
        ar.true_water_source_score AS auditor_score,
        wq.subjective_quality_score AS employee_score
    FROM 
        auditor_report ar
    JOIN 
        visits v
    ON 
        ar.location_id = v.location_id
    JOIN 
        water_quality wq
    ON 
        v.record_id = wq.record_id
    JOIN 
        employee e
    ON 
        e.assigned_employee_id = v.assigned_employee_id
    WHERE 
        ar.true_water_source_score != wq.subjective_quality_score
        AND 
        v.visit_count = 1
), 
error_count AS (
    SELECT 
        Assigned_employee_name,
        COUNT(Record_id) AS Number_of_mistakes_by_surveyor
    FROM 
        Incorrect_records
    GROUP BY 
        Assigned_employee_name
),
avg_error AS (
    SELECT 
        ROUND(AVG(Number_of_mistakes_by_surveyor), 0) AS avg_error_count_per_empl
    FROM 
        error_count
)
SELECT
    Assigned_employee_name,
    Number_of_mistakes_by_surveyor AS number_of_mistakes
FROM
    error_count
WHERE
    Number_of_mistakes_by_surveyor > (SELECT avg_error_count_per_empl FROM avg_error);
-- Four employees named Bello Azibo, Zuriel Matembo, Malachi Mavuso, and Lalitha Kaburi are displayed 
/*
	Now clear the code a bit: 
    First, Incorrect_records is a result we'll be using for the rest of the analysis, but it makes the
	query a bit less readable. So, let's convert it to a VIEW.
*/


-- 
CREATE VIEW Incorrect_records AS (
    SELECT 
        ar.location_id AS Location_id,
        v.record_id AS Record_id,
        e.employee_name AS Assigned_employee_name,
        ar.true_water_source_score AS auditor_score,
        wq.subjective_quality_score AS employee_score,
        ar.statements AS statements
    FROM 
        auditor_report ar
    JOIN 
        visits v
    ON 
        ar.location_id = v.location_id
    JOIN 
        water_quality wq
    ON 
        v.record_id = wq.record_id
    JOIN 
        employee e
    ON 
        e.assigned_employee_id = v.assigned_employee_id
    WHERE 
        ar.true_water_source_score != wq.subjective_quality_score
        AND 
        v.visit_count = 1
);
-- Query the view if it working correctly
SELECT 
	*
FROM 
	Incorrect_records;
-- Now add the second CTE from above a new CTE and it will drive data from the view Incorrect_records
WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
    SELECT 
        Assigned_employee_name,
        COUNT(Assigned_employee_name) AS Number_of_mistakes_by_surveyor
    FROM 
        Incorrect_records /*
							Incorrect_records is a view that joins the audit report to the database
							for records where the auditor and
							employees scores are different*/
    GROUP BY 
        Assigned_employee_name 
),
avg_error AS (
    SELECT 
        ROUND(AVG(Number_of_mistakes_by_surveyor), 0) AS avg_error_count_per_empl
    FROM 
        error_count
),
suspect_list AS (SELECT -- This CTE SELECTS the employees with above−average mistakes
    Assigned_employee_name,
    Number_of_mistakes_by_surveyor AS number_of_mistakes
FROM
    error_count
WHERE
    Number_of_mistakes_by_surveyor >= (SELECT avg_error_count_per_empl FROM avg_error)
)
-- This query filters all of the records where the "corrupt" employees gathered data
SELECT 
	Assigned_employee_name,
    Location_id,
    statements
FROM
	Incorrect_records
WHERE
	Assigned_employee_name IN (SELECT Assigned_employee_name FROM suspect_list)
    AND
    statements LIKE '%cash%';
-- 
