-- Demand Planning Script
-- Prerequisites: Annual Demand Script and ABC Analysis Script must be run first.
USE inventory_analysis;

-- Reorder point calculations - (daily sales * AVG lead time)
-- reference: https://www.shipbob.com/blog/reorder-quantity-formula/

-- EOQ = square root of: [2 * (D: Annual Demand) * (S: Order Cost)] / (H: Holding Cost).
-- reference: https://www.investopedia.com/terms/e/economicorderquantity.asp

-- I will use $30 for (S: Order Cost) and $10 for (H: Holding Cost). 
-- (D: Annual Demand) has already been calculated in the annual_demand table.


-- Calculating Average Purchase Lead Time in a temp table
DROP TEMPORARY TABLE IF EXISTS temp_lead_time;
CREATE TEMPORARY TABLE temp_lead_time (
	Inventory_id		VARCHAR(75)	PRIMARY KEY,
	Average_Lead_Time_Days	INT		NOT NULL,
	Max_Lead_Time_Days	INT		NOT NULL
);

-- Inserting average lead time days rounded into temp table using DATEDIFF between po receipt date and po order date
INSERT INTO temp_lead_time (Inventory_id, Average_Lead_Time_Days, Max_Lead_Time_Days)
SELECT 
	por.Inventory_id,
	ROUND(AVG(DATEDIFF(por.Receiving_Date, po.PO_Date))) AS Average_Lead_Time_Days,
	ROUND(MAX(DATEDIFF(por.Receiving_Date, po.PO_Date))) AS Max_Lead_Time
FROM purchase_order_receipts por
INNER JOIN purchase_order_lines pol
	ON por.PO_Number = pol.PO_Number
	AND por.PO_Line_id = pol.PO_Line_id
	INNER JOIN purchase_orders po
		ON pol.PO_Number = po.PO_Number
GROUP BY por.Inventory_id;


-- Creating a table to calculate and store Reorder Point, EOQ, and Safety Stock for A items only per item.
DROP TABLE IF EXISTS inventory_reordering;
CREATE TABLE inventory_reordering (
	Inventory_id	VARCHAR(75)	PRIMARY KEY,
	Reorder_Point	INT		NOT NULL,
	EOQ		INT		NOT NULL,
	Safety_Stock	INT		NULL,
	Lead_Time	INT		NOT NULL
);

INSERT INTO Inventory_Reordering (Inventory_id, Reorder_Point, EOQ, Safety_Stock, Lead_Time)
SELECT 
	t.Inventory_id,
-- Reorder Point (daily sales * AVG lead time) rounded up to nearest integer.
	CEILING(t.Average_Lead_Time_Days * (d.Total_Demand / 365)) AS Reorder_Point,
    
-- Calculating EOQ rounded to nearest integer.
-- Formula: square root of: [2 * (D: Annual Demand) * (S: Order Cost)] / (H: Holding Cost) - (S: $30), (H: $10). 
	ROUND(SQRT((2 * d.Total_Demand * 30) / 10)) AS EOQ,
    
-- Adding Safety Stock Days for A class items only based on Max Lead Time minus Average Lead Time.
	CASE 
		WHEN abc.ABC_Code LIKE 'A' THEN CEILING( (t.Max_Lead_Time_Days - t.Average_Lead_Time_Days) * (d.Total_Demand / 365) )
        ELSE 0
	END AS Safety_Stock,
	t.Average_Lead_Time_Days
FROM temp_lead_time t
INNER JOIN annual_demand d
	ON t.Inventory_id = d.Inventory_id
INNER JOIN abc_classification abc
	on t.Inventory_id = abc.Inventory_id
INNER JOIN purchase_order_lines pol
	ON t.Inventory_id = pol.Inventory_id
INNER JOIN purchase_order_receipts por
	ON pol.PO_Number = por.PO_Number AND pol.PO_Line_id = por.PO_Line_id
GROUP BY t.Inventory_id;
