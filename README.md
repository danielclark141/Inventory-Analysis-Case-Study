# Inventory-Analysis-Case-Study

https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/1dc24d826cb5cd61428f0298f793ecc925cb600e/Inventory%20Level%20Analysis%20Script.sql

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

# Ending Inventory Analysis
Next, I conducted an analysis on inventory levels over time. I created a temporary table to store beginning inventory, purchase receipts and sales transactions organized by date for each inventory ID. To test my calculations, I compared the inventory level on the last available transaction date against the original ending inventory provided in the dataset. The ending inventory levels that I calculated did not match the ending inventory provided in the original dataset.  

[Link to script](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Inventory%20Level%20Analysis%20Script.sql)

Further investigation into the data revealed the original dataset only contains sales transactions up to 2/29/2016 and purchase transactions up to 6/30/2016. The ending inventory dataset is based on data from 12/31/2016. These discrepancies further support my conclusion that there is likely missing data in this dataset. 

# Annual Demand Forecast
I have calculated annual usage expectations by extending total YTD sales and extending those sales to annual demand. Due to the concern of missing data, I would not recommend utilizing this data for demand forecasting in the current state, however once all missing sales data has been collected, these queries can be utilized to calculate the actual annual demand.

# Stockout Analysis:
The inventory levels over time analysis revealed stockouts totaling approximately $2.45 million worth of potential missed sales throughout the 2-month period. Over half of the missed sales, approximately $1.35 million worth, consisted of A-level items. 

![Missed Sales Potential](https://github.com/danielclark141/Inventory-Analysis-Case-Study/blob/main/Missed%20Sales%20Potential%20by%20ABC%20Code.PNG)

[Link to Tableau dashboard](https://public.tableau.com/app/profile/daniel4029/viz/InventoryAnalysisCaseStudy_16938541269020/Dashboard1)

# Inventory Replenishment Plan
Due to the high level of stockouts, I have created a demand planning script based on economic order quantity (EOQ) to calculate target reorder points and EOQ for replenishment. I have also calculated safety stock levels for all A items by multiplying the maximum supplier lead time per item by the estimated daily usage. By utilizing this script, management can maintain healthy ranges of inventory to prevent both overstock and understock of inventory.  

# Conclusion
This analysis revealed that there is missing data needed to perform an accurate deep-dive analysis on company ABC. The data also revealed that the current inventory replenishment process is not meeting expectations and there is room to improve service levels and ordering accuracy by implementing the suggested demand planning program outlined in this project. By addressing the missing data and following the new inventory replenishment structure found in my analysis, Any Manufacturing Company will have a robust inventory management system capable of meeting future customer demand and maximizing profitability.
