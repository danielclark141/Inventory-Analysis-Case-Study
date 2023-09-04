-- Creating tables to interact with. Each table is dropped if exists to ensure all data is new.
-- Each table contains information that can be called upon as needed to optimize database efficiency.

DROP SCHEMA IF EXISTS inventory_analysis;
CREATE SCHEMA inventory_analysis;
USE inventory_analysis;


DROP TABLE IF EXISTS brands;
CREATE TABLE brands (
	Brand_id			INT 			PRIMARY KEY,
    Description			VARCHAR(50) 	NOT NULL,
    Size				VARCHAR(25) 	NULL,
    Volume				FLOAT 			NULL,
    Classification		SMALLINT		NULL
);


DROP TABLE IF EXISTS ending_inventory;
CREATE TABLE ending_inventory (
	Inventory_id 		VARCHAR(75) 	PRIMARY KEY,
	On_Hand_Inventory	INT 			NOT NULL,
    End_Date			DATE 			NOT NULL
);


DROP TABLE IF EXISTS inventory_info;
CREATE TABLE inventory_info (
	Inventory_id		VARCHAR(75) 	PRIMARY KEY,	
    Store_id			INT 			NOT NULL,
    Brand_id			INT 			NOT NULL
);


DROP TABLE IF EXISTS invoices;
CREATE TABLE invoices (
	PO_Number			INT 			PRIMARY KEY,
    Invoice_Date		DATE			NOT NULL,
    Pay_Date			DATE			NULL,
    Quantity			INT				NOT NULL,
    Freight				DECIMAL(6,2)	NULL,
    Invoice_Total		DECIMAL(9,2)	NOT NULL,
    Approval			VARCHAR(50)		NULL
);


DROP TABLE IF EXISTS pricing;
CREATE TABLE pricing (
	Inventory_id		VARCHAR(75)		PRIMARY KEY,
    Supplier_id			INT				NOT NULL,
    Price				DECIMAL(6,2)	NOT NULL
);


-- for purchase orders, I am creating separate tables to store the header and line details separately

DROP TABLE IF EXISTS purchase_orders;
CREATE TABLE purchase_orders (
	PO_Number			INT 			PRIMARY KEY,
    Supplier_id			INT				NOT NULL,
    Store				INT				NOT NULL,
    PO_Date				DATE			NOT NULL
);


-- for the purchase order lines, I am using a composite key between PO # and PO Line # to indicate one unique record. 
-- I have added PO line #s to existing rows using a python command to add the PO Line # to existing records based on each unique PO #

DROP TABLE IF EXISTS purchase_order_lines;
CREATE TABLE purchase_order_lines (
	PO_Line_id			INT				PRIMARY KEY,
    PO_Number       	INT				NOT NULL,
    Inventory_id    	VARCHAR(75)		NOT NULL,
    Quantity        	INT				NOT NULL,
    Price				DECIMAL(6,2)	NOT NULL
);


DROP TABLE IF EXISTS purchase_order_receipts;
CREATE TABLE purchase_order_receipts (
	Receipt_id			INT 			AUTO_INCREMENT 	PRIMARY KEY,
	PO_Number			INT				NOT NULL,
    Inventory_id		VARCHAR(75)		NOT NULL,
    Receiving_Date		DATE			NOT NULL,
    Quantity			INT				NOT NULL,
    PO_Line_id			INT				NOT NULL
);


DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
    Sales_id 			INT 		AUTO_INCREMENT 	PRIMARY KEY, 
    Store_id			int			NOT NULL,
    Inventory_id 		VARCHAR(75) NOT NULL,
    Sales_Quantity 		INT 		NOT NULL,
    Sales_Price 		FLOAT 		NOT NULL,
    Excise_Tax			FLOAT 		NOT NULL,
    Sales_Date 			DATE		NOT NULL
) 	AUTO_INCREMENT = 100;


DROP TABLE IF EXISTS starting_inventory;
CREATE TABLE starting_inventory (
	Inventory_id		VARCHAR(75) PRIMARY KEY,
    On_Hand_Inventory	INT 		NOT NULL,
    Start_Date			DATE		NOT NULL
);


DROP TABLE IF EXISTS stores;
CREATE TABLE stores (
	Store_id			INT 		PRIMARY KEY,
    City				VARCHAR(50) NOT NULL
);


DROP TABLE IF EXISTS suppliers;
CREATE TABLE suppliers (
	Supplier_id 		INT 		PRIMARY KEY,
    Supplier_Name 		VARCHAR(50) NOT NULL
);