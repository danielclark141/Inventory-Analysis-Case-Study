# Inventory-Analysis-Case-Study

# Objective
My goal for this project is to analyze raw inventory data for a fictional company called Any Manufacturing to reveal insights that can help the management team build a robust inventory stocking plan capable of meeting future customer demand.

# About the Data:
For my analysis, I used the Inventory Analysis Case Study dataset found on Kaggle. This dataset contains millions of inventory movement records, including purchases, sales, beginning inventory and ending inventory. For my analysis, I chose to use MySQL to analyze the data and Tableau to visualize some of the insights found in my analysis.

[Click here to view the Kaggle dataset](https://www.kaggle.com/datasets/bhanupratapbiswas/inventory-analysis-case-study?select=SalesFINAL12312016.csv)

[Click here to view my Tableau Dashboard](https://public.tableau.com/app/profile/daniel4029/viz/InventoryAnalysisCaseStudy_16938541269020/Dashboard1)

# Data Discovery
During the data discovery phase, I reviewed the available sales data within the dataset and found there is only sales data present for January and February. To check the data for any anomalies or identifiable trends, I charted the sales data over time in Tableau. I included Cost of Goods sold in my chart to visually understand if the company is profitable. 

![Weekly Sales and COGS](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Weekly%20Sales%20and%20COGS.PNG)
[Link to Tableau dashboard](https://public.tableau.com/app/profile/daniel4029/viz/InventoryAnalysisCaseStudy_16938541269020/Dashboard1)

Charting the sales data revealed that February saw an unusual drop in sales compared to January. To understand how this impacted each region, I created a side by side horizontal bar chart to compare monthly sales by city. This insight revealed that many of the cities with a high volume of sales in January showed no sales in February. This pattern raises the possibility that there is data missing from the original dataset or the business experienced a disruption that impacted sales in the month of February.

![City Sales by Month.PNG](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/City%20Sales%20by%20Month.PNG)

# Annual Demand Forecast
Since I did not have enough information to conclude data may be missing, I chose to continue my analysis by creating and deploying the ![Annual Demand Script](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Annual%20Demand%20Script.sql) to create an annual demand table from the available sales data for use in developing an inventory replenishment plan.

To calculate annual demand for each item, I performed a Left Join to compare the Inventory Info table with the Sales table. This allowed me to set annual demand for items without any sales transactions to zero by using a Case statement. For items with sales transactions, I calculated the average daily sales per item and multiplied those values by 365 days. 

https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/05b3ce6280a490d286b276194f8834682a5d63fc/Annual%20Demand%20Script.sql#L18-L40

# Ending Inventory Analysis
After I calculated annual demand for each item, I conducted an analysis on inventory levels over time by developing the ![Inventory Levels Script](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Inventory%20Level%20Analysis%20Script.sql) to assess the current replenishment program. In this script, I created an inventory transactions table consisting of beginning inventory, purchase transactions, and sales transactions organized by item and date. I used this data to calculate daily ending inventory levels for each item in a temporary table and used this data to compare calculated inventory levels on the last available transaction date against the ending inventory file provided in the dataset to test my theory that there are missing transactions in the dataset. 
\
\
Using the below script, I confirmed that the ending inventory levels in my calculations did not match the original dataset for approximately 191,000 items. These discrepancies further support my theory that there is missing transactional data in this dataset.

https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/1dc24d826cb5cd61428f0298f793ecc925cb600e/Inventory%20Level%20Analysis%20Script.sql#L186-L194

**Output:** \
<img src="https://github.com/danielclark141/Inventory-Analysis-Case-Study/assets/69767270/32e19a04-5c10-40db-b210-531ec65971a6" width="200">

# Stockout Analysis:
To assess the performance of the current replenishment program, I utilized the ending inventory levels temp table created above to build the ![Inventory Levels Script](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Inventory%20Level%20Analysis%20Script.sql) to identify the frequency and average duration of stockouts for each item. Stockouts can lead directly to loss of sales and customers to competitors. 

To easily identify stockout occurrences, I created a temporary table using the below scripts to categorize each ending inventory level by different stock statuses to identify when an item is In Stock, Out of Stock, or Backordered.

https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/b778f95538d9214eecc369c7133c334a35aad1a3/Inventory%20Level%20Analysis%20Script.sql#L124-L162

After categorizing each ending inventory level by stock status, I used another temp table titled Inventory Stockouts to calculate the duration in days of each stockout occurrence. I chose to omit any stockouts dated 1/1/2016 since this was the starting inventory date and it may be possible that these items were not being stocked at that time. 

https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/aac0990a292b919340e04317d8599f9da3a623de/Inventory%20Level%20Analysis%20Script.sql#L199-L227

With each stockout duration calculated, I combined this data with the Annual Demand table I created with the ![Annual Demand Script](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Annual%20Demand%20Script.sql) and the Sales table to measure the missed sales potential throughout the 2-month period. I categorized this data into ABC Classifications using the table created in the ![ABC Analysis Script](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/ABC%20Analysis.sql) to help understand the distribution of potential missed sales due to essential A items, supporting B items, or less common C items. revealed stockouts totaling approximately $2.45 million worth of potential missed sales throughout the 2-month period. Over half of the missed sales, approximately $1.35 million worth, consisted of A-level items. 

https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/ddf28e55ed6e29e7c709a51c8d62581ac04ffaec/Inventory%20Level%20Analysis%20Script.sql#L231-L252
\
![Missed Sales Potential](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Missed%20Sales%20Potential%20by%20ABC%20Code.PNG)

[Link to Tableau dashboard](https://public.tableau.com/app/profile/daniel4029/viz/InventoryAnalysisCaseStudy_16938541269020/Dashboard1)

# Inventory Replenishment Plan
The high level of stockouts discovered in my analysis revealed a need for a more robust inventory replenishment plan. By developing the [Demand Planning Script](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Demand%20Planning.sql) I created a new replenishment plan based on economic order quantity (EOQ) to calculate target reorder points and EOQ for replenishment. 

Since A items are the highest moving product and stockouts of these items could have the most negative impact on the business, I decided to implement a safety stock program on A items only to ensure there is always adequate inventory on hand to cover supplier lead time flunctuations. I calculated these safety stock levels by multiplying the maximum supplier lead time per item by the estimated daily usage. 

https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/f618222d8643b858089fa69e2dc19a7c10345c08/Demand%20Planning.sql#L48-L73

By utilizing this script, management can maintain healthy ranges of inventory to prevent both overstock and understock of inventory.  

# Conclusion
This case study revealed that there is data missing from the dataset that is needed to perform an accurate deep-dive analysis. The data also revealed that the current inventory replenishment process is not performing to expectations and there is room to improve service levels and ordering accuracy by implementing the suggested inventory replenishment program outlined in my analysis. By addressing the missing data and following the new inventory replenishment program, Any Manufacturing Company will have a robust inventory management system capable of meeting future customer demand and maximizing profitability.
