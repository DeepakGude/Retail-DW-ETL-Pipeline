-- CREATING PRODUCT CATEGORY DIMENSION TABLE IN DS

CREATE TABLE ProductCategoryDimension AS
SELECT DISTINCT p.CategoryID, p.CategoryName
FROM ProductDimension p;

ALTER TABLE ProductCategoryDimension
ADD COLUMN ProductCategoryKey INT AUTO_INCREMENT Primary Key;

-- CREATING ONE WAY AGGREGATE BY PRODUCT CATEGORY

CREATE TABLE One_Way_Revenue_Agg_By_ProductCategory AS
SELECT SUM(r.UnitsSold) AS TotalUnitsSold, SUM(r.DollarsGenerated) AS
TotalDollarsGenerated,
r.CalendarKey, r.CustomerKey, r.StoreKey, pcd.ProductCategoryKey
FROM RevenueFact AS r, ProductCategoryDimension AS pcd, ProductDimension AS pd
WHERE r.ProductKey = pd.ProductKey
AND
pcd.CategoryID = pd.CategoryID
GROUP BY r.CalendarKey, r.CustomerKey, r.StoreKey, pcd.ProductCategoryKey;

ALTER TABLE One_Way_Revenue_Agg_By_ProductCategory
ADD PRIMARY KEY(CalendarKey, CustomerKey, StoreKey, ProductCategoryKey);