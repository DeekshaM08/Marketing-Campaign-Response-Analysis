CREATE DATABASE marketing_db ;
USE marketing_db ;
CREATE TABLE customers (
ID INT, 
Year_Birth INT, 
Age INT,
Age_Group VARCHAR (7), 
Education VARCHAR (10),
Marital_Status VARCHAR (10),
Income INT, 
Income_Bracket VARCHAR (20), 
Kidhome INT, 
Teenhome INT, 
Dt_Customer DATE, 
Recency INT, 
Active_Inactive VARCHAR (10), 
MntWines INT, 
MntFruits INT, 
MntMeatProducts INT, 
MntFishProducts INT, 
MntSweetProducts INT, 
MntGoldProds INT, 
NumDealsPurchases INT, 
NumWebPurchases INT, 
NumCatalogPurchases INT, 
NumStorePurchases INT, 
NumWebVisitsMonth INT, 
AcceptedCmp1 TINYINT, 
AcceptedCmp2 TINYINT, 
AcceptedCmp3 TINYINT,
AcceptedCmp4 TINYINT,
AcceptedCmp5 TINYINT,
Complain TINYINT, 
Response TINYINT ); 

LOAD DATA INFILE '"C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Marketing_Campaign(Converted).csv"'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

SHOW VARIABLES LIKE 'secure_file_priv';
Select * from customers
LIMIT 10;
#Count customers per demographic segment
SELECT 
  Age_Group, 
  Income_Bracket, 
  Education, 
  Marital_Status, 
  COUNT(*) AS customer_count
FROM customers
GROUP BY Age_Group, Income_Bracket, Education, Marital_Status;

SELECT 
  Age_Group, 
  Income_Bracket, 
  Education, 
  Marital_Status, 
  COUNT(*) AS customer_count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customers), 2) AS customer_percentage
FROM customers
GROUP BY Age_Group, Income_Bracket, Education, Marital_Status
ORDER BY customer_percentage DESC;
#Response Rate
SELECT 
  Age_Group, 
  Income_Bracket, 
  COUNT(*) AS total_customers,
  SUM(Response) AS total_responded,
  ROUND(100.0 * SUM(Response)/COUNT(*), 2) AS response_rate_pct
FROM customers
GROUP BY Age_Group, Income_Bracket
ORDER BY response_rate_pct DESC;

#Response Rate by Activity Status
SELECT 
  Active_Inactive, 
  COUNT(*) AS customer_count,
  SUM(Active_Inactive) AS Total,
  ROUND(100.0 * SUM(Active_Inactive)/Count(*),2) AS Active_Inactive_pct
FROM customers
GROUP BY Active_Inactive;

SELECT 
  Active_Inactive, 
  COUNT(*) AS customer_count,
  SUM(CASE WHEN Active_Inactive = 'Active' THEN 1 ELSE 0 END) AS Total_Active,
  ROUND(100.0 * 
    SUM(CASE WHEN Active_Inactive = 'Active' THEN 1 ELSE 0 END) / COUNT(*), 2
  ) AS Active_pct
FROM customers
GROUP BY Active_Inactive;

#Channel Purchase Behaviour 
SELECT
  Income_Bracket,
  Age_Group,
  ROUND(AVG(NumDealsPurchases), 2) AS avg_deals_purchases,
  ROUND(AVG(NumWebPurchases), 2) AS avg_web_purchases,
  ROUND(AVG(NumCatalogPurchases), 2) AS avg_catalog_purchases,
  ROUND(AVG(NumStorePurchases), 2) AS avg_store_purchases
FROM customers
GROUP BY Income_Bracket, Age_Group
ORDER BY Income_Bracket, Age_Group;

#Campaign Effectiveness 
SELECT 
  Education, 
  Marital_Status, 
  SUM(Response) AS total_responses,
  COUNT(*) AS total_customers,
  ROUND(100.0 * SUM(Response)/COUNT(*), 2) AS response_rate
FROM customers
GROUP BY Education, Marital_Status
ORDER BY response_rate DESC;

#Share of Bucket wrt Income 
SELECT 
  Income_Bracket, 
  SUM(MntWines+MntFruits+MntMeatProducts+MntFishProducts+MntSweetProducts+MntGoldProds) AS Total_spend_2yrs
FROM customers	
GROUP BY Income_Bracket;
# Lower - Middle seems to spend maximum spend on edible items and Gold products in Last 2 years

#| Segment                    | Channel Preference                   | Strategy Suggestion                              |
#| -------------------------- | ------------------------------------ | ------------------------------------------------ |
#| Middle 36–45               | High Deals & Catalog                 | Combo: Catalog mailers + strong offers           |
#| Lower-Middle 56–65         | High Web + Store                     | Omnichannel push: Online + store incentives      |
#| Very Low Income 46–65      | Moderate Deals, Low Web              | Offline, SMS-based, value-driven messaging       |
#| Middle 66+                 | High Web, 0 Deals                    | Upsell premium products via digital only         |
#| Very Low Income (all ages) | Low across all except moderate Deals | Simple messaging, focus on price + accessibility |
