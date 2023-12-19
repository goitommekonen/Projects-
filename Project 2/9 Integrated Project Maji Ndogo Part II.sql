-- Access to our database 
USE md_water_services;
-- querying data dictionary and learn the other tables 
SELECT 
	* 
FROM 
	md_water_services.data_dictionary;
    
-- Task 1: Cleaning our data 
-- the email column in our employee table is empty so lets update it
-- Rule: first_name.last_name@ndogowater.gov. 
SELECT 
	employee_name
	,CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),'@ndogowater.gov') AS email 
FROM 
	employee;
-- now update the email 
UPDATE 
	employee 
SET 
	email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),'@ndogowater.gov');
-- check if the updated value is correct by qurtying the table again
SELECT 
	*
FROM 
	employee;
-- clean phone number and check if length is 12 characters 
SELECT 
	phone_number
    ,LENGTH(phone_number)
from employee;
-- use TRIM()
SELECT 
	TRIM(phone_number)
    ,LENGTH(TRIM(phone_number))
FROM 
	employee;
-- now update the table as what we did above
UPDATE 
	employee
SET 
	phone_number = TRIM(phone_number);
-- check the updated data 
SELECT 
	phone_number
    ,LENGTH(phone_number)
FROM
	employee;
-- Task 2: Honouring the workers 
-- check where the employees live first, 
SELECT 
	town_name
    , COUNT(town_name) as Number_of_employees
FROM 
	employee
GROUP BY 
	town_name;
-- 
SELECT * FROM md_water_services.visits LIMIT 10;

SELECT 
	assigned_employee_id
    , COUNT(visit_count) AS Number_of_visits
FROM
	md_water_services.visits
GROUP BY 
	assigned_employee_id
ORDER BY 
	Number_of_visits DESC
LIMIT 3;
-- display the name of the top three employees for their visit
SELECT 
	employee_name
    ,phone_number 
    ,email
FROM 
	employee 
WHERE 
	assigned_employee_id IN (1,30,34);
    
-- Task 3: Analysing Locations 
-- let's dive deep into the location table
SELECT 
	* 
FROM 
	location; -- so columns: location_id, address, province_name, town name, and location_type
-- analyse where the water sources are in Maji Ndogo
-- let's create a query that counts the number of records per town. 
SELECT 
	town_name
    , COUNT(town_name) as Number_of_records 
FROM 
	location
GROUP BY 
	town_name
ORDER BY 
	Number_of_records DESC
LIMIT 6;
-- count the records for province
SELECT 
	province_name
    , COUNT(province_name) as Number_of_records 
FROM 
	location
GROUP BY 
	province_name
ORDER BY 
	Number_of_records DESC
LIMIT 6;

-- aggregated count of the province and town names
SELECT 
	province_name
	,town_name
    ,COUNT(town_name) AS Number_of_records 
FROM 
	location
GROUP BY 
	province_name, town_name
ORDER BY
	province_name, Number_of_records DESC
LIMIT 6;
-- we find the records for the location_type as well

SELECT 
	location_type
    ,COUNT(location_type) AS Number_of_records 
FROM
	location
GROUP BY
	location_type
ORDER BY
	Number_of_records;
-- calculate percentage of water sources: Urban = 15910, Rural = 23740. 
SELECT 
	23740/(23740 + 15910)*100 AS Water_source_percentage; -- App. 60%
/*
-- we can see that 60% of all water sources are in the rural communities
-- facts to flashback!
-- Our entire country was properly canvassed, and our dataset represents the situation on the ground.
-- 2. 60% of our water sources are in rural communities across Maji Ndogo. We need to keep this in mind when we make decisions.
*/

-- Task 4: Diving into the sources, water_Source, a big table with a lot of stories in it to strap in.

SELECT 
	* 
FROM 
	water_source
LIMIT 10;
-- number of records for each water source
SELECT 
	type_of_water_source
    ,COUNT(type_of_water_source) AS Number_of_records
FROM 
	water_source 
GROUP BY 
	type_of_water_source
ORDER BY 
	Number_of_records DESC;
-- number of people served in each water source
 SELECT 
	type_of_water_source
    ,COUNT(type_of_water_source) AS Number_of_records
    , SUM(number_of_people_served) AS Total_people_served
FROM 
	water_source 
GROUP BY 
	type_of_water_source
ORDER BY 
	Number_of_records DESC;
-- How many people did we survey in total?
SELECT 
	SUM(number_of_people_served) AS Number_of_people_surveyed
FROM 
	water_source;
-- how many wells, taps, and rivers are there?
SELECT 
	type_of_water_source
    ,COUNT(type_of_water_source) AS Number_of_sources
FROM 
	water_source 
WHERE 
	type_of_water_source LIKE 'well' 
    OR type_of_water_source LIKE 'tap%'
    OR type_of_water_source LIKE '%_tap'
    OR type_of_water_source LIKE 'river'
GROUP BY 
	type_of_water_source
ORDER BY 
	Number_of_sources DESC;
-- How many people share particular source of water on average
SELECT 
	type_of_water_source
    , ROUND(AVG(number_of_people_served),0) AS Total_people_served
FROM 
	water_source
GROUP BY
	type_of_water_source 
ORDER BY 
	Total_people_served DESC;
-- Population served by each type of water source 
SELECT 
	type_of_water_source
    ,SUM(number_of_people_served) as Population_served
FROM
	water_source 
GROUP BY
	type_of_water_source
ORDER BY
	Population_Served DESC;
-- the number we got above didn't make much sense as they are a little harder to comprehend
-- We use percentages instead
-- 1) calculate the total people surveyed 
-- 2) and divide each of the SUM(number_of_people_served) by that number, times 100, to get percentages.
SELECT 
	type_of_water_source
    ,ROUND(SUM(number_of_people_served)/27628140*100,2) as Population_served
FROM
	water_source 
GROUP BY
	type_of_water_source
ORDER BY
	Population_Served DESC;
/* Fun facts:
-- 43% of our people are using shared taps in their communities, and on average, 
-- we saw earlier, that 2000 people share one shared_tap. in Maji Ndogo
-- By adding tap_in_home and tap_in_home_broken together, we see that 31% of people have water 
infrastructure installed in their homes, but 45%
(14/31) of these taps are not working! This isn't the tap itself that is broken, 
but rather the infrastructure like treatment plants, reservoirs, pipes, and
pumps that serve these homes that are broken.
*/
-- Task 5: Start of a Solution! 
-- Use rank function
SELECT 
	type_of_water_source
    ,SUM(number_of_people_served) as Population_served
    ,RANK() OVER(
		ORDER BY SUM(number_of_people_served) DESC
    ) AS Rank_water_source
FROM
	water_source 
WHERE 
	type_of_water_source NOT IN ('tap_in_home','tap_in_home_broken') -- to not include taps in our analysis 
GROUP BY
	type_of_water_source
ORDER BY
	Population_Served DESC;
-- But the next question is, which shared taps or wells should be fixed first? 
-- We can use the same logic; the most used sources should really be fixed first.
SELECT 
	source_id
    ,type_of_water_source
    ,number_of_people_served
    ,RANK() OVER(
		PARTITION BY type_of_water_source
		ORDER BY number_of_people_served DESC) AS Priority_rank
FROM 
	water_source
WHERE 
	type_of_water_source NOT IN ('tap_in_home','tap_in_home_broken');
-- By using RANK() teams doing the repairs can use the value of rank to measure how many they have fixed, 
-- but what would be the benefits of using DENSE_RANK()?
-- ANSWER: provides a more compact ranking without gaps 
-- because RANK()  createes gaps in the ranking.
SELECT 
	source_id
    ,type_of_water_source
    ,number_of_people_served
    ,DENSE_RANK() OVER(
		PARTITION BY type_of_water_source
		ORDER BY number_of_people_served DESC) AS Priority_rank
FROM 
	water_source
WHERE 
	type_of_water_source NOT IN ('tap_in_home','tap_in_home_broken');
-- How about ROW_NUMBER()
-- unique rank is assigned for each row regardless of the number of people they serve
SELECT 
	source_id
    ,type_of_water_source
    ,number_of_people_served
    ,ROW_NUMBER() OVER(
		PARTITION BY type_of_water_source
		ORDER BY number_of_people_served DESC) AS Priority_rank
FROM 
	water_source
WHERE 
	type_of_water_source NOT IN ('tap_in_home','tap_in_home_broken');
    
-- Task 6: Analysing Queues
-- dive deep into the visits table
SELECT
	*
FROM 
	visits
LIMIT 10;
-- Now calculate the total duration of the survey, in other word, how long did the survey took?
SELECT
	TIMESTAMPDIFF(DAY, MIN(time_of_record), MAX(time_of_record)) AS Survey_duration_in_days
FROM 
	visits;
-- What is the average total queue time for water?
SELECT
	AVG(NULLIF(time_in_queue,0)) AS Avg_total_queue
FROM 
	visits;
-- what is the average queue time for different days of the week?
 SELECT 
    DAYNAME(time_of_record) AS Day_of_week
	,ROUND(AVG(AVG(time_in_queue)) OVER(
		PARTITION BY DAYNAME(time_of_record)
    ),0) AS Avg_queue_time
FROM 
	visits
WHERE time_in_queue !=0
GROUP BY 
	DAYNAME(time_of_record)
ORDER BY 
	Avg_queue_time DESC;
-- without window function 
SELECT 
    DAYNAME(time_of_record) AS Day_of_week,
    ROUND(AVG(time_in_queue), 0) AS Avg_queue_time
FROM 
    visits
WHERE time_in_queue !=0
GROUP BY 
    DAYNAME(time_of_record)
ORDER BY 
    Avg_queue_time DESC;

-- At what time during the day people collect water? Try to order the results in a meaningful way

SELECT 
    TIME_FORMAT(TIME(time_of_record),'%H:00') AS Hour_of_day
    ,ROUND(AVG(time_in_queue), 0) AS Avg_queue_time
FROM 
    visits
WHERE time_in_queue !=0
GROUP BY 
    TIME_FORMAT(TIME(time_of_record),'%H:00')
ORDER BY 
	TIME_FORMAT(TIME(time_of_record),'%H:00');

/*Can you see that mornings and evenings are the busiest? It looks like people collect water before 
and after work. Wouldn't it be nice to break down
the queue times for each hour of each day? In a spreadsheet, we can just create a pivot table.
Pivot tables are not widely used in SQL, despite being useful for interpreting results. 
So there are no built-in functions to do this for us. Sometimes
the dataset is just so massive that it is the only option.*/

SELECT
	TIME_FORMAT(TIME(time_of_record), '%H:00') AS Hour_of_day
	-- Sunday
	,ROUND(AVG(
		CASE
			WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
			ELSE NULL
		END
	),0) AS Sunday
	-- Monday
	,ROUND(AVG(
		CASE
			WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
			ELSE NULL
		END
	),0) AS Monday
	-- Tuesday
	,ROUND(AVG(
		CASE
			WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
			ELSE NULL
		END
	),0) AS Tuesday
	-- Wednesday
	, ROUND(AVG(
		CASE
			WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
			ELSE NULL
		END
	),0) AS Wednesday
	-- Thursday
	,ROUND(AVG(
		CASE
			WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
			ELSE NULL
		END
	),0) AS Thursday
	-- Friday
	,ROUND(AVG(
		CASE
			WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
			ELSE NULL
		END
	),0) AS Friday
	-- Saturday
	,ROUND(AVG(
		CASE
			WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
			ELSE NULL
		END
	),0) AS Saturday
FROM
	visits
WHERE
	time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
	Hour_of_day
ORDER BY
	Hour_of_day;
-- Water accessibility and infrastructure summary report 
/*
	Insights
1. Most water sources are rural.
2. 43% of our people are using shared taps. 2000 people often share one tap.
3. 31% of our population has water infrastructure in their homes, but within that group, 45% face non-functional systems due to issues with pipes,
pumps, and reservoirs.
4. 18% of our people are using wells of which, but within that, only 28% are clean..
5. Our citizens often face long wait times for water, averaging more than 120 minutes.
6. In terms of queues:
- Queues are very long on Saturdays.
- Queues are longer in the mornings and evenings.
- Wednesdays and Sundays have the shortest queues.
*/
-- End of project 
-- Questions! 
-- 3. What are the names of the two worst-performing employees who visited the fewest sites, 
-- and how many sites did the worst-performing employee visit?
SELECT 
    assigned_employee_id
    , COUNT(visit_count) AS Number_of_visits
FROM
	md_water_services.visits
GROUP BY 
	assigned_employee_id
ORDER BY 
	Number_of_visits
LIMIT 3;
-- now we collect the name from employee table
SELECT 
	employee_name
FROM 
	employee
WHERE 
	assigned_employee_id IN (20,22,44);
-- 4. What is the output of the following query and what it does? 
SELECT 
    location_id,
    time_in_queue,
    AVG(time_in_queue) OVER (PARTITION BY location_id ORDER BY visit_count) AS total_avg_queue_time
FROM 
    visits
WHERE 
visit_count > 1 -- Only shared taps were visited > 1
ORDER BY 
    location_id, time_of_record;
    
-- End of Project! 
    