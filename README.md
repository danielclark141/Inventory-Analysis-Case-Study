# Inventory-Analysis-Case-Study

The goal of this project is to review inventory data sourced from Kaggle for a hypothetical company and reveal insights about the data that can help the management team put together a strong inventory management plan capable of meeting future customer demand. 

# Overview 
The dataset for this project was sourced from Kaggle and contains inventory transactional data for a hypothetical manufacturing company. Data included in this dataset includes sales, purchasing, beginning and ending inventory, and invoicing.
[Click here to view the dataset](https://www.kaggle.com/datasets/bhanupratapbiswas/inventory-analysis-case-study?select=SalesFINAL12312016.csv)

# Findings:
During the initial data cleaning and discovery phase, I analyzed sales data and found that there are only two months of sales data available for January and February. When I charted this data, I found that February experienced a very steep drop in sales compared to January. Many cities that had significant sales in January had no sales in February at all. This pattern raises the possibility that there is data missing from the original dataset or the business experienced a disruption that impacted sales in the month of February.

![Weekly Sales and COGS](https://github.com/danielclark141/Inventory-Analysis-Case-Study/assets/69767270/177d6f01-6da1-40d5-ad8e-4a1f56cbe29e)
[Click here to view the dashboard](https://public.tableau.com/app/profile/daniel4029/viz/InventoryAnalysisCaseStudy_16938541269020/Dashboard1)

Next, I conducted an analysis on inventory levels over time. I created a temporary table to store beginning inventory, purchase receipts and sales transactions organized by date for each inventory ID. To test my calculations, I compared the inventory level on the last available transaction date against the original ending inventory provided in the dataset. The ending inventory I calculated did not match the original ending inventory. 


Further investigation into the data revealed the original dataset only contains sales transactions up to 2/29/2016 and purchase transactions up to 6/30/2016. The ending inventory dataset is based on data from 12/31/2016. These discrepancies further support my conclusion that there is likely missing data in this dataset. 

The inventory levels over time analysis revealed stockouts totaling approximately $2.45 million worth of potential missed sales throughout the 2-month period. Over half of the missed sales, approximately $1.35 million worth, consisted of A-level items. Due to the high level of stockouts, I have created a stocking plan based on economic order quantity (EOQ) to calculate target reorder points and EOQ for replenishment. I have also calculated safety stock levels for all A items by multiplying the maximum supplier lead time per item by the estimated daily usage. This will ensure the highest selling items will always be available to meet customer demand, while the less common moving items will see improved fill rates without risk of overstock.  
