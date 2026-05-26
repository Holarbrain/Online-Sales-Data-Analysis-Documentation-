-- Creating Table to clean Raw datasets.

CREATE TABLE sales_clean AS
SELECT *
FROM sales_staging;

-- Cleaning datasets

-- Step 1. Standardize Payment Methods

-- Checking Distinct Values
SELECT DISTINCT Payment_Method
FROM sales_clean;

-- Temporarily Disable Safe Update Mode (Recommended for cleaning projects)
SET SQL_SAFE_UPDATES = 0;

-- Fixing Inconsistent Spellings 
UPDATE sales_clean
SET Payment_Method = 'PayPal'
WHERE Payment_Method = 'paypall';

-- Note that you can disable Save Update Mode afterward 
SET SQL_SAFE_UPDATES = 1;

-- Handlimng  NULL CustomrIDS & Check Missing Customer IDs
SELECT *
FROM sales_clean
WHERE Customer_ID IS NULL;


-- HANDLE MISSING WAREHOUSE LOCATIONS
-- Check Missing Values
SELECT *
FROM sales_clean
WHERE Ware_house_Location IS NULL
OR Ware_house_Location = '';

-- Replace Missing Values
UPDATE sales_clean
SET Ware_house_Location = 'Unknown'
WHERE Ware_house_Location IS NULL
OR Ware_house_Location = '';


-- TO REMOVE INVALID QUANTITIES

-- Inspect Invalid Quantities
SELECT *
FROM sales_clean
WHERE Quantity <= 0;

-- Delete Invalid Rows(If applicable to inspection). Note in this case it will not affect because the ispection return 0 rows that is <=0. 
DELETE FROM sales_clean
WHERE Quantity <= 0;


-- TO REMOVE INVALID UNIT PRICES
-- Inspect Invalid Prices
SELECT *
FROM sales_clean
WHERE Unit_Price <= 0;

-- Delete Invalid Rows (Note inspection return 0 row for the condition <= 0 so this may not be applicable in this case)
DELETE FROM sales_clean
WHERE Unit_Price <= 0;


-- TO HANDLE INVALID DISCOUNTS
-- Inspect Discounts
SELECT *
FROM sales_clean
WHERE Discount < 0
OR Discount > 1;

-- Replace Invalid Discounts( No change made)
UPDATE sales_clean
SET Discount = 0
WHERE Discount < 0
OR Discount > 1;


-- TO CONVERT DATE FORMAT
-- Add Clean Date Column
ALTER TABLE sales_clean
ADD COLUMN Clean_Invoice_Date DATETIME;

-- Convert Date Format
UPDATE sales_clean
SET Clean_Invoice_Date = STR_TO_DATE(
Invoice_Date,
'%m/%d/%Y %H:%i'
);

-- To check date formt effect
SELECT Clean_Invoice_Date
FROM sales_clean
Limit 100;

-- TO CHECK DUPLICATES
-- Find Duplicate Invoice Numbers(Very Applicable) Note: Some duplicate invoice numbers may be valid because one invoice can contain multiple products.
-- am not to delete duplicates unless the entire row is duplicated.

SELECT Invoice_No,
COUNT(*) AS duplicate_count
FROM sales_clean
GROUP BY Invoice_No
HAVING COUNT(*) > 1;

-- CREATE SALES AMOUNT COLUMN
-- Add Calculated Revenue Column
ALTER TABLE sales_clean
ADD COLUMN Total_Sales DECIMAL(12,2);

-- Calculate Revenue
UPDATE sales_clean
SET Total_Sales = Quantity * Unit_Price * (1 - Discount);

-- DATA VALIDATION
-- To Confirm Cleaned Data
SELECT *
FROM sales_clean
LIMIT 20;

-- Validate Removed Errors
-- Invalid Quantities ( Output = Expected: 0 rows)
SELECT *
FROM sales_clean
WHERE Quantity <= 0;

-- Invalid Prices(Expected: 0 rows)
SELECT *
FROM sales_clean
WHERE Unit_Price <= 0;


-- BUSINESS QUESTIONS & SQL ANALYSIS

-- BUSINESS QUESTION 1 — Total Revenue
SELECT ROUND(SUM(Total_Sales), 2) AS total_revenue
FROM sales_clean;

-- BUSINESS QUESTION 2 — Total Orders
SELECT COUNT(DISTINCT Invoice_No) AS total_orders
FROM sales_clean;

-- BUSINESS QUESTION 3 — Top 10 Selling Products
SELECT Description,
SUM(Quantity) AS total_quantity_sold
FROM sales_clean
GROUP BY Description
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- BUSINESS QUESTION 4 — Revenue by Category
SELECT Category,
ROUND(SUM(Total_Sales),2) AS revenue
FROM sales_clean
GROUP BY Category
ORDER BY revenue DESC;

-- BUSINESS QUESTION 5 — Revenue by Country
SELECT Country,
ROUND(SUM(Total_Sales),2) AS revenue
FROM sales_clean
GROUP BY Country
ORDER BY revenue DESC;

-- BUSINESS QUESTION 6 — Monthly Sales Trend
SELECT MONTH(Clean_Invoice_Date) AS sales_month,
ROUND(SUM(Total_Sales),2) AS revenue
FROM sales_clean
GROUP BY MONTH(Clean_Invoice_Date)
ORDER BY sales_month;

-- BUSINESS QUESTION 7 — Most Used Payment Method
SELECT Payment_Method,
COUNT(*) AS usage_count
FROM sales_clean
GROUP BY Payment_Method
ORDER BY usage_count DESC;


-- BUSINESS QUESTION 8 — Return Analysis
SELECT Return_Status,
COUNT(*) AS total_returns
FROM sales_clean
GROUP BY Return_Status;

-- BUSINESS QUESTION 9 — Top Shipment Providers
SELECT Shipment_Provider,
COUNT(*) AS shipment_count
FROM sales_clean
GROUP BY Shipment_Provider
ORDER BY shipment_count DESC;

-- BUSINESS QUESTION 10 — High Priority Orders
SELECT Order_Priority,
COUNT(*) AS total_orders
FROM sales_clean
GROUP BY Order_Priority;


-- BUSINESS QUESTION 11 — Average_Shipping_Cost
SELECT 
    ROUND(AVG(Shipping_Cost), 2) AS Average_Shipping_Cost
FROM sales_clean;

-- BUSINESS QUESTION 12 — Top shipment_Provider
SELECT 
    Shipment_Provider,
    COUNT(*) AS Total_Shipments
FROM sales_clean
GROUP BY Shipment_Provider
ORDER BY Total_Shipments DESC;

-- BUSINESS QUESTION 13 — Which sales channels have the highest return rate?
SELECT 
    Sales_Channel,
    COUNT(
        CASE 
            WHEN Return_Status = 'Returned' 
            THEN 1 
        END
    ) AS Returned_Orders,
    COUNT(*) AS Total_Orders,
    ROUND(
        COUNT(
            CASE 
                WHEN Return_Status = 'Returned' 
                THEN 1 
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Return_Rate_Percentage
FROM sales_clean
GROUP BY Sales_Channel
ORDER BY Return_Rate_Percentage DESC;


-- To Export Final Clean Table
SELECT *
FROM sales_clean;













