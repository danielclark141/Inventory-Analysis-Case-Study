-- Inventory Transaction Analysis
-- Prerequisites: Annual Demand script and ABC Analysis Script should be ran first. 

USE inventory_analysis;

-- Creating a temp table to store each inventory transaction by date
-- For sales transactions, these will be input as negative values to show a reduction in inventory
DROP  TABLE IF EXISTS inventory_transactions;
CREATE TABLE inventory_transactions (
	id							INT			AUTO_INCREMENT	PRIMARY KEY,
	Inventory_id			VARCHAR(75)	NOT NULL,
    Transaction_Date		DATE		NOT NULL,
    Order_id				INT			NOT NULL,
    Transaction_Type		VARCHAR(25)	NOT NULL,
    Transaction_Quantity	INT			NOT NULL
);

-- Inserting starting inventory as beginning status, using 0 as the order_id
INSERT INTO inventory_transactions 
(Inventory_id, Transaction_Date, Order_id, Transaction_Type, Transaction_Quantity)
SELECT 
	Inventory_id,
    Start_Date AS Transaction_Date,
    0 AS Order_id,
    'Starting Inventory' AS Transaction_Type,
    On_Hand_Inventory AS Transaction_Quantity
FROM starting_inventory
ORDER BY Start_Date;

-- Inserting purchase transactions based on receipt date
INSERT INTO inventory_transactions 
(Inventory_id, Transaction_Date, Order_id, Transaction_Type, Transaction_Quantity)
SELECT 
	Inventory_id,
    Receiving_Date AS Transaction_Date,
    PO_Number AS Order_id,
    'Purchase' AS Transaction_Type,
    Quantity AS Transaction_Quantity
FROM purchase_order_receipts
ORDER BY Receiving_Date;

-- Inserting sales transactions based on sale date
INSERT INTO inventory_transactions 
(Inventory_id, Transaction_Date, Order_id, Transaction_Type, Transaction_Quantity)
SELECT 
	Inventory_id,
    Sales_Date AS Transaction_Date,
    Sales_id AS Order_id,
    'Sale' AS Transaction_Type,
    (-1 * Sales_Quantity) AS Transaction_Quantity
FROM sales
ORDER BY Sales_Date;


-- Using a query to calculate a running on hand total after each transaction. 
SELECT 
	id,
	Inventory_id,
    Transaction_Date,
    Transaction_Type,
    Transaction_Quantity,
	SUM(Transaction_Quantity) OVER(PARTITION BY Inventory_id ORDER BY Transaction_Date, id) AS New_On_Hand_Quantity
FROM inventory_transactions
-- WHERE Inventory_id LIKE '1_HARDERSFIELD_10058'	-- Using this item to check if the running totals are correct.
ORDER BY Inventory_id, Transaction_Date
LIMIT 100;


-- Creating temp table to store PO order dates and receiving dates for each inventory ID to use for calculating quantity on order.
DROP TEMPORARY TABLE IF EXISTS temp_order_dates;
CREATE TEMPORARY TABLE temp_order_dates (
	id				INT			AUTO_INCREMENT	PRIMARY KEY,
	PO_Number		INT			NOT NULL,
    PO_Date			DATE		NOT NULL,
    Receiving_Date	DATE		NULL,
    Inventory_id	VARCHAR(75)	NOT NULL,
    Quantity		INT			NOT NULL
);

-- Inserting the data into the temp order date table.
INSERT INTO temp_order_dates (PO_Number, PO_Date, Receiving_Date, Inventory_id, Quantity)
SELECT 
    po.PO_Number,
    po.PO_Date,
	por.Receiving_Date,
	pol.Inventory_id,
    pol.Quantity
FROM purchase_orders po
INNER JOIN purchase_order_lines pol
	ON po.PO_Number = pol.PO_Number
LEFT JOIN purchase_order_receipts por
	ON pol.PO_Number = por.PO_Number 
    AND pol.PO_Line_id = por.PO_Line_id;


-- Creating temp table to view ending inventory per day
DROP TEMPORARY TABLE IF EXISTS temp_daily_ending_inventory;
CREATE TEMPORARY TABLE temp_daily_ending_inventory (
	id					INT			PRIMARY KEY	AUTO_INCREMENT,
	Inventory_id		VARCHAR(75)	NOT NULL,
    Transaction_Date	DATE		NOT NULL,	
    Total_Quantity		INT			NOT NULL,
    Ending_Inventory	INT			NOT NULL
);

-- Inserting data into the temp daily ending inventory table.
INSERT INTO temp_daily_ending_inventory (Inventory_id, Transaction_Date, Total_Quantity, Ending_Inventory)
SELECT 
	Inventory_id,
    Transaction_Date,
    SUM(Transaction_Quantity) AS Total_Quantity,
    SUM(SUM(Transaction_Quantity)) OVER(PARTITION BY Inventory_id ORDER BY Transaction_Date) AS Ending_Inventory
FROM inventory_transactions
GROUP BY Transaction_Date, Inventory_id;


-- Checking to make sure daily ending inventory looks correct.
SELECT * 
FROM temp_daily_ending_inventory 
WHERE Inventory_id LIKE '1_HARDERSFIELD_10058'
LIMIT 100;


-- Creating temp table to view a running ending inventory level ordered by inventory id and transaction date.
DROP TEMPORARY TABLE IF EXISTS temp_inventory_level;
CREATE TEMPORARY TABLE temp_inventory_level (
	id					INT	PRIMARY KEY	AUTO_INCREMENT,
    Inventory_id		VARCHAR(75),
    Transaction_Date	DATE,
    Ending_Inventory	INT,
    Quantity_On_Order	INT,
    Status				VARCHAR(25)
);

-- Inserting data into the temp inventory level table. 
-- Using a CTE to calculate quantity on order and to improve performance on the query. 
INSERT INTO temp_inventory_level 
(Inventory_id, Transaction_Date, Ending_Inventory, Quantity_On_Order, Status)
WITH cte_inventory AS (
SELECT
	t.Inventory_id,
    t.Transaction_Date,
    t.Ending_Inventory,
	SUM(CASE	WHEN t.Transaction_Date >= t2.PO_Date AND t.Transaction_Date < t2.Receiving_Date 
				THEN t2.Quantity ELSE 0 END) 
	AS Quantity_On_Order
FROM temp_daily_ending_inventory t
LEFT JOIN temp_order_dates t2
	ON t.Inventory_id = t2.Inventory_id
GROUP BY t.Inventory_id, t.transaction_Date, t.Ending_Inventory
)
SELECT 
	Inventory_id,
    Transaction_Date,
	Ending_Inventory,
	Quantity_On_Order,
	CASE		WHEN Ending_Inventory > 0 THEN 'In Stock'
				WHEN Ending_Inventory  = 0 THEN 'Out of Stock'
				ELSE 'Backordered'
	END AS Status
FROM cte_inventory;


-- Checking the count of records with a stockout where the transaction date does not equal beginning inventory date.
SELECT COUNT(*)
FROM temp_inventory_level
WHERE Status LIKE 'Out of Stock' AND transaction_date != '2016-01-01';


-- Creating table to hold records of all inventory stockouts.
DROP TABLE IF EXISTS inventory_stockouts;
CREATE TABLE inventory_stockouts (
	id					INT			AUTO_INCREMENT	PRIMARY KEY,
    Inventory_id		VARCHAR(75)	NOT NULL,
    Stockout_Date		DATE		NOT NULL,
    Stockout_Duration	INT			NOT NULL
);


-- Inserting the stockout data into the inventory stockout table.
INSERT INTO inventory_stockouts (Inventory_id, Stockout_Date, Stockout_Duration)
SELECT 
	Inventory_id, 
    prev_status_date,
    DATEDIFF(Transaction_Date, prev_status_date) AS days_between_changes
FROM (
-- Using subquery to calculate the length of time of each stockout by looking at the previous row status with a LAG function.
-- Filtering the data where the LAG transaction date is after the beginning inventory date.
    SELECT
        t1.Inventory_id,
        LAG(t1.Status) OVER (PARTITION BY t1.Inventory_id ORDER BY t1.Transaction_Date) AS prev_status,
        LAG(t1.Transaction_Date) OVER (PARTITION BY t1.Inventory_id ORDER BY t1.Transaction_Date) AS prev_status_date,
        t1.Transaction_Date,
        Status
    FROM temp_inventory_level t1
    WHERE t1.Transaction_Date > '2016-01-02'
) AS subquery
WHERE prev_status LIKE 'Out of Stock';


-- Calculating the average duration of each stockout and the total missed sales potential caused by stockouts for each ABC Code.
SELECT 
	ABC_Code,
    ROUND(AVG(stockout_duration),2) AS AVG_Stockout_Duration,
	ROUND(SUM(Missed_Sales),2) AS Total_Missed_Sales
FROM
(
SELECT 
	i.Inventory_id,
    i.Stockout_Date,
	abc.ABC_Code,
    ROUND(AVG(i.Stockout_duration)) AS stockout_duration,
    ROUND(AVG(i.Stockout_duration * s.Sales_Price),2) AS missed_sales
FROM inventory_stockouts i
INNER JOIN sales s
	ON i.Inventory_id = s.Inventory_id
INNER JOIN annual_demand a
	ON i.Inventory_id = a.Inventory_id
INNER JOIN abc_classification abc
	ON i.Inventory_id = abc.Inventory_id
GROUP BY i.Inventory_id, i.Stockout_Date
) AS subquery
GROUP BY ABC_Code