-- INITIAL LOAD OF ONE WAY AGGREGATE BY PRODUCT CATEGORY FROM DS TO DW
CREATE TABLE guded_datawarehousing.ProductCategoryDimension AS
SELECT *
FROM guded_datastaging.ProductCategoryDimension

ALTER TABLE guded_datawarehousing.ProductCategoryDimension
ADD PRIMARY KEY (ProductCategoryKey);

CREATE TABLE guded_datawarehousing.One_Way_Revenue_Agg_By_ProductCategory AS
SELECT *
FROM guded_datastaging.One_Way_Revenue_Agg_By_ProductCategory

ALTER TABLE guded_datawarehousing.One_Way_Revenue_Agg_By_ProductCategory
ADD PRIMARY KEY(CalendarKey, CustomerKey, StoreKey, ProductCategoryKey);

ALTER TABLE guded_datawarehousing.One_Way_Revenue_Agg_By_ProductCategory
ADD FOREIGN KEY (CalendarKey) REFERENCES guded_datawarehousing.CalendarDimension(CalendarKey),
ADD FOREIGN KEY (CustomerKey) REFERENCES guded_datawarehousing.CustomerDimension(CustomerKey),
ADD FOREIGN KEY (StoreKey) REFERENCES guded_datawarehousing.StoreDimension(StoreKey),
ADD FOREIGN KEY (ProductCategoryKey) REFERENCES guded_datawarehousing.ProductCategoryDimension(ProductCategoryKey)

-- INITIAL LOAD OF ONE WAY AGGREGATE BY CUSTOMER ZIP FROM DS TO DW

CREATE TABLE guded_datawarehousing.One_Way_Revenue_Agg_By_CustomerZip AS
SELECT *
FROM guded_datastaging.One_Way_Revenue_Agg_By_CustomerZip

ALTER TABLE guded_datawarehousing.One_Way_Revenue_Agg_By_CustomerZip
ADD PRIMARY KEY(CalendarKey, CustomerZip, StoreKey, ProductKey);

ALTER TABLE guded_datawarehousing.One_Way_Revenue_Agg_By_CustomerZip
ADD FOREIGN KEY (StoreKey) REFERENCES guded_datawarehousing.StoreDimension(StoreKey),
ADD FOREIGN KEY (CalendarKey) REFERENCES guded_datawarehousing.CalendarDimension(CalendarKey),
ADD FOREIGN KEY (ProductKey) REFERENCES guded_datawarehousing.ProductDimension(ProductKey)

-- INITIAL LOAD OF DAILY STORE SNAPSHOT TABLE FROM DS TO DW

CREATE TABLE guded_datawarehousing.Daily_Store_Snapshot AS
SELECT *
FROM guded_datastaging.Daily_Store_Snapshot

ALTER TABLE guded_datawarehousing.Daily_Store_Snapshot
ADD PRIMARY KEY(CalendarKey, StoreKey);

ALTER TABLE guded_datawarehousing.Daily_Store_Snapshot
ADD FOREIGN KEY (StoreKey) REFERENCES guded_datawarehousing.StoreDimension(StoreKey),
ADD FOREIGN KEY (CalendarKey) REFERENCES guded_datawarehousing.CalendarDimension(CalendarKey)