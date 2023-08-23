# Inventory-Analysis-Case-Study

The goal of this project is to build a robust inventory stocking plan for a management team.

# Overview 
The dataset for this project was sourced from Kaggle and contains inventory transactional data for a hypothetical manufacturing company. Data included in this dataset includes sales, purchasing, beginning and ending inventory, and invoicing.
[Click here to view the dataset](https://www.kaggle.com/datasets/bhanupratapbiswas/inventory-analysis-case-study?select=SalesFINAL12312016.csv)

# Findings:
Sales month over month experienced a steep decline for February. Many cities that saw significant sales in January had no sales in February at all. This pattern raises the possibility that there is data missing from the original dataset or the business experienced a disruption that impacted sales in the month of February.

While conducting an analysis on inventory levels over time, I created a temporary table to store beginning inventory, purchase receipts and sales transactions organized by date for each inventory ID. To test my calculations, I compared the inventory level on the last available transaction date against the original ending inventory provided in the dataset. The ending inventory I calculated did not match the original ending inventory. 

Further investigation into the data revealed the original dataset only contains sales transactions up to 2/29/2016 and purchase transactions up to 6/30/2016. The ending inventory dataset is based on data from 12/31/2016. These discrepancies further back up my conclusion that there is data likely missing in this dataset. 
