-- Loading each CSV file into MySQL using LOAD DATA INFILE 
USE inventory_analysis;


-- Using a SET command to change values of Unknown found in the raw data to NULL
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Brands.csv'
INTO TABLE brands
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Brand_id, Description, Size, Volume, Classification)
SET Size = NULLIF(Size, 'Unknown'),
	Volume = NULLIF(Volume, '0');


-- Using a SET command to format mm/dd/yyyy dates in CSV file to mysql
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Ending_Inventory.csv'
INTO TABLE ending_inventory
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Inventory_id, On_Hand_Inventory, @End_Date)
SET End_Date = STR_TO_DATE(TRIM(@End_Date), '%m/%d/%Y');


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Inventory_id.csv'
INTO TABLE inventory_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/invoices.csv'
INTO TABLE invoices
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(PO_Number, @Invoice_Date, @Pay_Date, Quantity, Freight, Invoice_Total, Approval)
SET Invoice_Date = STR_TO_DATE(TRIM(@Invoice_Date), '%m/%d/%Y'),
	Pay_Date = STR_TO_DATE(TRIM(@Pay_Date), '%m/%d/%Y');
    

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Pricing.csv'
INTO TABLE pricing
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Purchase_Orders.csv'
INTO TABLE purchase_orders
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(PO_Number, Supplier_id, Store, @PO_Date)
SET PO_Date = STR_TO_DATE(TRIM(@PO_Date), '%m/%d/%Y');


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Purchase_Order_Lines.csv'
INTO TABLE purchase_order_lines
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Finding the next iteration of the PO_Line_id to set an Auto-Increment up for future line additions.
SELECT MAX(PO_Line_id) + 1 AS next_id
FROM purchase_order_lines;

-- Adding the Auto-Increment value found in the above query to start the next sequence
ALTER TABLE purchase_order_lines
MODIFY COLUMN PO_Line_id	INT	AUTO_INCREMENT,
AUTO_INCREMENT = 1048576;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Purchase_Order_Receipts.csv'
INTO TABLE purchase_order_receipts
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(PO_Number, Inventory_id, @Receiving_Date, Quantity, PO_Line_id)
SET Receiving_Date = STR_TO_DATE(TRIM(@Receiving_Date), '%m/%d/%Y');


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Sales.csv'
INTO TABLE sales
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Store_id, Inventory_id, Sales_Quantity, Sales_Price, Excise_Tax, @Sales_Date)
SET Sales_Date = STR_TO_DATE(TRIM(@Sales_Date), '%m/%d/%Y');


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/starting_inventory.csv'
INTO TABLE starting_inventory
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Inventory_id, On_Hand_Inventory, @Start_Date)
SET Start_Date = STR_TO_DATE(TRIM(@Start_Date), '%m/%d/%Y');


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Stores.csv'
INTO TABLE stores
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Suppliers.csv'
INTO TABLE suppliers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Supplier_id, Supplier_Name);