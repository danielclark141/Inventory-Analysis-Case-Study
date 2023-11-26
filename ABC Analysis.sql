-- Performing ABC Analysis based on the total sales amount of each part
-- Prerequisites: Annual Demand Script should be run first. 
USE inventory_analysis;


-- Creating a Temp table to hold the total sales amount by part to be used later in a cumulative sales by part percenatage analysis
-- This will make the next steps easier to read and put less load on each query run.
DROP TEMPORARY TABLE IF EXISTS temp_total_sales;
CREATE TEMPORARY TABLE temp_total_sales (
	Inventory_id		VARCHAR(75),
	Total_Part_Sales	FLOAT	NOT NULL,
	Total_Sales		FLOAT	NOT NULL
);


-- Inserting data into temp table
-- Using a windows function for Total Sales to see Total Sales for all parts 
INSERT INTO temp_total_sales (Inventory_id, Total_Part_Sales, Total_Sales)
SELECT
	i.Inventory_id,
	(p.Price * d.Total_Demand) AS Total_Part_Sales,
	SUM(p.Price * d.Total_Demand) OVER() AS Total_Sales
FROM inventory_info i
INNER JOIN pricing p
	ON i.Inventory_id = p.Inventory_id
-- Joining demand table to get demand by part
INNER JOIN annual_demand d
	ON i.Inventory_id = d.Inventory_id
GROUP BY i.Inventory_id;


-- Checking to make sure my calculations are correct.
SELECT 
	t.Inventory_id,
	p.Price,
	d.Total_Demand,
	t.Total_Part_Sales
FROM temp_total_sales t
INNER JOIN annual_demand d
	ON t.inventory_id = d.inventory_id
INNER JOIN inventory_info i
	ON t.inventory_id = i.inventory_id
	INNER JOIN pricing p
		ON i.Inventory_id = p.Inventory_id
LIMIT 20;


-- Performing cumulative calculations:
-- Using variables to store the cumulative total of each part line. These variables must be set to zero between each run of the corresponding query.
SET @CumulativeSum = 0;
SET @CumulativePercent = 0;

-- Identifying ABC Classification by part. The order by is critical in this query to see top selling items first.
SELECT 
	Inventory_id, 
	total_sales,
-- The variables are called by adding the total part sales to the cumulative variable. This updates the cumulative total from row to row.
	Total_Part_Sales,
	(@CumulativeSum := @CumulativeSum + Total_Part_Sales) AS cumulative_total,
    
	(Total_Part_Sales / Total_Sales) AS Percent_Of_Sales,
	(@CumulativePercent := @CumulativePercent + (Total_Part_Sales / Total_Sales)) AS cumulative_percent,

-- Setting the ABC Classification. A items represent 80% of revenue, B items represent 15% of revenue, and C items represent remaining 5%.
	CASE	WHEN @CumulativePercent BETWEEN 0 AND 0.8 THEN 'A'
		WHEN @CumulativePercent <= 0.95 THEN 'B'
        	WHEN @CumulativePercent <= 1 THEN 'C' 
		ELSE 'Error'
	END AS ABC_Classification
FROM temp_total_sales
ORDER BY Total_Part_Sales DESC;


-- Running an error check to ensure there are no cumulative percentages greater than 1
SET @CumulativeSum = 0;
SET @CumulativePercent = 0;
SELECT
	CASE	WHEN @CumulativePercent > 1 THEN 'Error'
		WHEN @CumulativePercent < 0 THEN 'Error'
	END AS Error_Check
FROM temp_total_sales
GROUP BY Error_Check
ORDER BY Error_Check DESC
LIMIT 2;


-- Using my results to create an ABC Classification table.
DROP TABLE IF EXISTS abc_classification;
CREATE TABLE abc_classification (
	Inventory_id	VARCHAR(75)	PRIMARY KEY,
	ABC_Code	VARCHAR(1)	NOT NULL
);


-- Using a common table expression to filter out the cumulative percent column from my insert statement.
-- MySQL will not allow a subquery within a temp table.
SET @CumulativePercent = 0;
INSERT INTO abc_classification (Inventory_id, ABC_Code)
(
WITH cte AS (
SELECT 
	Inventory_id,
	(@CumulativePercent := @CumulativePercent + (Total_Part_Sales / Total_Sales)) AS cumulative_percent,
	CASE	WHEN @CumulativePercent BETWEEN 0 AND 0.8 THEN 'A'
		WHEN @CumulativePercent <= 0.95 THEN 'B'
        	WHEN @CumulativePercent <= 1 THEN 'C' 
		ELSE 'Error'
	END AS ABC_Classification
FROM temp_total_sales
ORDER BY Total_Part_Sales DESC
)
SELECT 
	Inventory_id,
	ABC_Classification
FROM cte
);


-- Checking the percentage distribution of A, B, and C class items using a subquery.
SELECT 
	ABC_Code,
	COUNT(ABC_Code),
	Total_Count,
	COUNT(ABC_Code) / Total_Count As Distribution
FROM 
	(SELECT 
		ABC_Code, 
		COUNT(ABC_Code) OVER () AS Total_Count 
	FROM abc_classification a) a2
GROUP BY a2.ABC_Code
ORDER BY ABC_Code;

SELECT * FROM abc_classification;
