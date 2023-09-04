-- Calculating Annual Demand based on available sales data
USE inventory_analysis;

-- Checking my table to review schema.
SELECT *
FROM SALES
LIMIT 1;


-- Creating an Inventory Demand table to show estimated annual demand per store and total demand per item
DROP TABLE IF EXISTS annual_demand;
CREATE TABLE annual_demand (
    Inventory_id		VARCHAR(75)		PRIMARY KEY,
    Total_Demand		INT				NOT NULL
);


-- Inserting the demand data into the inventory demand table.
INSERT INTO annual_demand (Inventory_id, Total_Demand)
SELECT
	i.Inventory_id,
-- 		s2.Sales_Date_Range,	   Using this field to test my query calculations
--   	SUM(s2.Sales_Quantity),   	Using this field to test my query calculations

-- Using Case statement with a Left Join to check for any parts with no demand by setting Nulls to 0 
-- Otherwise, calculating annual demand by dividing Total Quantity by Sales Date Range to get daily sales and multiplying by 365.
	CASE	WHEN SUM(s2.Sales_Quantity) IS NULL THEN 0
			ELSE ( 365 *SUM(s2.Sales_Quantity) ) / s2.Sales_Date_Range 
    END AS Total_Demand									
FROM inventory_info i
-- Using a subquery to calculate Sales Date Range
LEFT JOIN 
	(	SELECT 
		s.inventory_id,
        s.Sales_Date,
        s.Sales_Quantity,
		DATEDIFF( MAX(s.Sales_Date) OVER(), MIN(s.Sales_Date) OVER() ) AS Sales_Date_Range
	FROM sales s
	) s2
ON i.Inventory_id = s2.Inventory_id
GROUP BY i.Inventory_id, s2.Sales_Date_Range;


-- Viewing total demand by each brand to see what the top moving brands are.
SELECT 
	b.Description,
	SUM(ad.Total_Demand) AS Total_Demand_Consolidated
FROM annual_demand ad
INNER JOIN inventory_info i
	ON ad.Inventory_id = i.Inventory_id
	INNER JOIN brands b
		ON i.Brand_id = b.Brand_id
GROUP BY i.Brand_id
ORDER BY Total_Demand_Consolidated DESC;