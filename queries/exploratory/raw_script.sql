
-- This script create Database

CREATE DATABASE sales_project;
USE sales_project;


-- Table staging 

CREATE TABLE sales_staging (
    Invoice_No INT,
    Stock_Code VARCHAR(50),
    Description VARCHAR(100),
    Quantity INT,
    Invoice_Date VARCHAR(50),
    Unit_Price DECIMAL(10,2),
    Customer_ID INT,
    Country VARCHAR(100),
    Discount DECIMAL(10,4),
    Payment_Method VARCHAR(50),
    Shipping_Cost DECIMAL(10,2),
    Category VARCHAR(50),
    Sales_Channel VARCHAR(50),
    Return_Status VARCHAR(50),
    Shipment_Provider VARCHAR(50),
    Ware_house_Location VARCHAR(100),
    Order_Priority VARCHAR(20)
);

-- Preving the datasets 
-- Note i had to set limit within the rang of 0-1000
SELECT *
FROM sales_staging
LIMIT 20;

-- To check total_record 
SELECT COUNT(*) AS total_rows
FROM sales_staging;

-- Main isues find in the dataset  Negative Quantity Values, Negative Unit Price, Missing Customer IDs,
-- Missing Warehouse Locations, Invalid Discounts, Inconsistent Payment Method spellings, Data Stored As Text