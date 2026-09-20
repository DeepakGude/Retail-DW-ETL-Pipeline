-- INITIAL LOAD OF ONE WAY AGGREGATE BY PRODUCT CATEGORY FROM DS TO DW
CREATE TABLE guded_datawarehousing.ProductCategoryDimension AS
SELECT *
FROM guded_datawarehousing.ProductCategoryDimension

ALTER TABLE guded_datawarehousing.ProductCategoryDimension
ADD PRIMARY KEY ProductCategoryKey;

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