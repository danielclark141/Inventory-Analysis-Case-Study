# Inventory-Analysis-Case-Study

# Objective
The goal of this project is to analyze raw inventory data for fictional Any Manufacturing Company to reveal insights that can help the management team build a robust inventory stocking plan capable of meeting future customer demand.

# About the Data:
The Inventory Analysis Case Study found on Kaggle was used for this analysis. This dataset contains millions of inventory movement records, including purchases, sales, beginning inventory and ending inventory. For my analysis, I chose to use MySQL to analyze the data and Tableau to visualize some of the insights found in my analysis.

[Click here to view the dataset](https://www.kaggle.com/datasets/bhanupratapbiswas/inventory-analysis-case-study?select=SalesFINAL12312016.csv)

[Click here to view the Tableau Dashboard](https://public.tableau.com/app/profile/daniel4029/viz/InventoryAnalysisCaseStudy_16938541269020/Dashboard1)

# Data Discovery
During the data discovery phase, I reviewed sales data and found that there is only sales data available for January and February. To check the data for any anomalies or identifiable trends, I charted the sales data in Tableau. I included Cost of Goods sold in my chart to understand if Any Manufacturing is profitable. 

![Weekly Sales and COGS](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Weekly%20Sales%20and%20COGS.PNG)
[Link to Tableau dashboard](https://public.tableau.com/app/profile/daniel4029/viz/InventoryAnalysisCaseStudy_16938541269020/Dashboard1)

Charting the sales data revealed that February saw an unusual drop in sales compared to January. Many of the cities with a high volume of sales in January showed no sales in February at all. This pattern raises the possibility that there is data missing from the original dataset or the business experienced a disruption that impacted sales in the month of February.

# Annual Demand Forecast
I have calculated annual usage expectations using the ![Annual Demand Script](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Annual%20Demand%20Script.sql) by extending total YTD sales and extending those sales to annual demand. Due to the concern of missing data, I would not recommend utilizing this data for demand forecasting in the current state, however once all missing sales data has been collected, these queries can be utilized to calculate the actual annual demand.

# Ending Inventory Analysis
Next, I conducted an analysis on inventory levels over time using the ![Inventory Levels Script](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Inventory%20Level%20Analysis%20Script.sql). In this script, I created an inventory transactions table consisting of beginning inventory, purchase transactions, and sales transactions organized by inventory ID and date. I used this data to calculate daily ending inventory levels for each inventory ID in a temporary table and used this data to compare the inventory level on the last available transaction date against the original ending inventory provided in the dataset. Using the below script, I confirmed that the ending inventory levels in my calculations did not match the original dataset for approximately 191,000 inventory IDs. These discrepancies further support my theory that there is missing transactional data in this dataset.

https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/1dc24d826cb5cd61428f0298f793ecc925cb600e/Inventory%20Level%20Analysis%20Script.sql#L186-L194

**Output:** \
<img src="https://github.com/danielclark141/Inventory-Analysis-Case-Study/assets/69767270/32e19a04-5c10-40db-b210-531ec65971a6" width="200">

# Stockout Analysis:
I also utilized the ending inventory levels temporary table in the ![Inventory Levels Script](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Inventory%20Level%20Analysis%20Script.sql) to identify the frequency and duration of stockouts for each inventory ID. Stockouts can be very costly for a business due to the risk of missed sales and loss of customers. To easily identify stockout occurrences, I created a temporary table using the below scripts to categorize each ending inventory level by different statuses to identify when an item is In Stock, Out of Stock, or Backordered.

https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/ddf28e55ed6e29e7c709a51c8d62581ac04ffaec/Inventory%20Level%20Analysis%20Script.sql#L124-L168

The inventory levels over time analysis revealed stockouts totaling approximately $2.45 million worth of potential missed sales throughout the 2-month period. Over half of the missed sales, approximately $1.35 million worth, consisted of A-level items. 

![Missed Sales Potential](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Missed%20Sales%20Potential%20by%20ABC%20Code.PNG)

[Link to Tableau dashboard](https://public.tableau.com/app/profile/daniel4029/viz/InventoryAnalysisCaseStudy_16938541269020/Dashboard1)

# Inventory Replenishment Plan
Due to the high level of stockouts, I have created a demand planning script based on economic order quantity (EOQ) to calculate target reorder points and EOQ for replenishment. I have also calculated safety stock levels for all A items by multiplying the maximum supplier lead time per item by the estimated daily usage. By utilizing this script, management can maintain healthy ranges of inventory to prevent both overstock and understock of inventory.  

# Conclusion
This analysis revealed that there is missing data needed to perform an accurate deep-dive analysis on company ABC. The data also revealed that the current inventory replenishment process is not meeting expectations and there is room to improve service levels and ordering accuracy by implementing the suggested demand planning program outlined in this project. By addressing the missing data and following the new inventory replenishment structure found in my analysis, Any Manufacturing Company will have a robust inventory management system capable of meeting future customer demand and maximizing profitability.
