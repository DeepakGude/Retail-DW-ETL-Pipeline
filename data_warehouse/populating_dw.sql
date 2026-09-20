-- LOADING THE CONTENT OF PRODUCT DIMENSION FROM DATA STAGING TO DATA WAREHOUSING

INSERT INTO guded_datawarehousing.ProductDimension(ProductKey, ProductID, ProductName, ProductType, SalesProductPrice, VendorID, VendorName, CategoryID, CategoryName, RentalProductPriceDaily, RentalProductPriceWeekly)
SELECT ProductKey, ProductID, ProductName, ProductType, SalesProductPrice, VendorID, VendorName, CategoryID, CategoryName, RentalProductPriceDaily, RentalProductPriceWeekly
FROM guded_datastaging.ProductDimension

-- LOADING THE CONTENT OF STORE DIMENSION FROM DATA STAGING TO DATA WAREHOUSING

INSERT INTO guded_datawarehousing.StoreDimension(StoreKey, StoreID, StoreZip, RegionID, RegionName)
SELECT StoreKey, StoreID, StoreZip, RegionID, RegionName
FROM guded_datastaging.StoreDimension

-- LOADING THE CONTENT OF CUSTOMER DIMENSION FROM DATA STAGING TO DATA WAREHOUSING

INSERT INTO guded_datawarehousing.CustomerDimension(CustomerKey, CustomerID, CustomerName, CustomerZip)
SELECT CustomerKey, CustomerID, CustomerName, CustomerZip
FROM guded_datastaging.CustomerDimension

-- LOADING THE CONTENT OF REVENUE FACT FROM DATA STAGING TO DATA WAREHOUSING

INSERT INTO guded_datawarehousing.RevenueFact(DollarsGenerated, UnitsSold, TID, RevenueType, ProductKey, StoreKey, CustomerKey, CalendarKey)
SELECT DollarsGenerated, UnitsSold, TID, RevenueType, ProductKey, StoreKey, CustomerKey, CalendarKey
FROM guded_datastaging.RevenueFact