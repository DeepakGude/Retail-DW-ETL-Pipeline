-- CREATING PRODUCT CATEGORY DIMENSION TABLE IN DS

CREATE TABLE ProductCategoryDimension AS
SELECT DISTINCT p.CategoryID, p.CategoryName
FROM ProductDimension p;

ALTER TABLE ProductCategoryDimension
ADD COLUMN ProductCategoryKey INT AUTO_INCREMENT Primary Key;

-- CREATING ONE WAY AGGREGATE BY PRODUCT CATEGORY

CREATE TABLE One_Way_Revenue_Agg_By_ProductCategory AS
SELECT SUM(r.UnitsSold) AS TotalUnitsSold, SUM(r.DollarsGenerated) AS TotalDollarsGenerated, r.CalendarKey, r.CustomerKey, r.StoreKey, pcd.ProductCategoryKey
FROM RevenueFact AS r, ProductCategoryDimension AS pcd, ProductDimension AS pd
WHERE r.ProductKey = pd.ProductKey
AND
pcd.CategoryID = pd.CategoryID
GROUP BY r.CalendarKey, r.CustomerKey, r.StoreKey, pcd.ProductCategoryKey;

ALTER TABLE One_Way_Revenue_Agg_By_ProductCategory
ADD PRIMARY KEY(CalendarKey, CustomerKey, StoreKey, ProductCategoryKey);

-- ONE WAY REVENUE AGGREGATE BY CUSTOMER ZIP

DROP TABLE IF EXISTS One_Way_Revenue_Agg_By_CustomerZip;
CREATE TABLE One_Way_Revenue_Agg_By_CustomerZip AS
SELECT SUM(r.UnitsSold) AS TotalUnitsSold, SUM(r.DollarsGenerated) AS TotalDollarsGenerated, r.CalendarKey, r.ProductKey, r.StoreKey, c.CustomerZip
FROM RevenueFact r, CustomerDimension c
WHERE r.CustomerKey = c.CustomerKey
GROUP BY r.CalendarKey, r.ProductKey, r.StoreKey, c.CustomerZip

ALTER TABLE One_Way_Revenue_Agg_By_CustomerZip
ADD PRIMARY KEY(CalendarKey, CustomerZip, StoreKey, ProductKey);

-- CREATING DAILY STORE SNAPSHOT TABLE

CREATE TABLE Daily_Store_Snapshot AS
SELECT SUM(r.UnitsSold) AS TotalUnitsSold, SUM(r.DollarsGenerated) AS TotalDollarsGenerated, COUNT(DISTINCT r.TID) AS TotalNumberOfTransactions, AVG(r.DollarsGenerated)
AS AverageDollarsGenerated, r.CalendarKey, r.StoreKey
FROM RevenueFact AS r
GROUP BY r.CalendarKey, r.StoreKey;

ALTER TABLE Daily_Store_Snapshot
ADD PRIMARY KEY (CalendarKey, StoreKey)

-- ADDING METRICS TO SNAPSHOT

ALTER TABLE Daily_Store_Snapshot
ADD Footwear_Revenue DECIMAL(9,2),
ADD High_Revenue_Transaction_Count INT,
ADD Local_Revenue INT

-- CREATING TABLE LOCAL REVENUE IN DS
CREATE TABLE Local_Revenue AS 
SELECT SUM(r.DollarsGenerated) AS Local_Revenue, r.CalendarKey, r.StoreKey
FROM RevenueFact AS r, CustomerDimension c, StoreDimension s
WHERE r.CustomerKey = c.CustomerKey
AND s.StoreKey = r.StoreKey
AND LEFT(c.CustomerZip,2) = LEFT(s.StoreZip,2)
GROUP BY r.CalendarKey, r.StoreKey;

-- UPDATING LOCAL REVENUE IN DAILY STORE SNAPSHOT IN DS
UPDATE Daily_Store_Snapshot DS, Local_Revenue LR
SET DS.Local_Revenue = LR.Local_Revenue
WHERE DS.CalendarKey = LR.CalendarKey
AND DS.StoreKey = LR.StoreKey

UPDATE Daily_Store_Snapshot
SET Local_Revenue = 0
WHERE Local_Revenue IS NULL

-- CREATING TABLE HIGH REVENUE TRANSACTION COUNT IN DS
CREATE TABLE High_Revenue_Transaction_Count AS 
SELECT COUNT(DISTINCT TID) AS High_Revenue_Transaction_Count, CalendarKey, StoreKey
FROM RevenueFact
WHERE TID IN (SELECT TID
FROM RevenueFact
GROUP BY TID
HAVING SUM(DollarsGenerated) > 100)
GROUP BY CalendarKey, StoreKey

-- UPDATING HIGH REVENUE TRANSACTION COUNT IN DAILY STORE SNAPSHOT IN DS
UPDATE Daily_Store_Snapshot DS, High_Revenue_Transaction_Count HRTC
SET DS.High_Revenue_Transaction_Count = HRTC.High_Revenue_Transaction_Count
WHERE DS.CalendarKey = HRTC.CalendarKey
AND DS.StoreKey = HRTC.StoreKey

UPDATE Daily_Store_Snapshot
SET High_Revenue_Transaction_Count = 0
WHERE High_Revenue_Transaction_Count IS NULL

-- CREATING TABLE FOOTWEAR REVENUE IN DS
CREATE TABLE Footwear_Revenue AS
SELECT SUM(r.TotalDollarsGenerated) AS Footwear_Revenue, r.CalendarKey, r.StoreKey
FROM One_Way_Revenue_Agg_By_ProductCategory r, CalendarDimension c, StoreDimension s, ProductCategoryDimension p
WHERE r.CalendarKey = c.CalendarKey
AND s.StoreKey = r.StoreKey
AND r.ProductCategoryKey = p.ProductCategoryKey
AND p.CategoryID = 'FW'
GROUP BY r.CalendarKey, r.StoreKey

-- UPDATING FOOTWEAR REVENUE IN DAILY STORE SNAPSHOT IN DS
UPDATE Daily_Store_Snapshot DS, Footwear_Revenue FR
SET DS.Footwear_Revenue = FR.Footwear_Revenue
WHERE DS.CalendarKey = FR.CalendarKey
AND DS.StoreKey = FR.StoreKey

UPDATE Daily_Store_Snapshot
SET Footwear_Revenue= 0
WHERE Footwear_Revenue IS NULL