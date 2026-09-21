-- PROCEDURE FOR ADDING NEW PRODUCTS
CREATE PROCEDURE ProductDimension_Refresh()
BEGIN

-- INSERTING THE NEW SALES PRODUCTS THAT OCCURED SINCE THE LAST REFRESH INTO DS
INSERT INTO guded_datastaging.ProductDimension(ProductID, ProductName, SalesProductPrice, ProductType, VendorID, VendorName, CategoryID, CategoryName, Extraction_Time_Stamp, F_LOADED)
SELECT s.productid, s.productname, s.productprice, 'Sales Product', s.vendorid, v.vendorname, s.categoryid, c.categoryname, NOW(), FALSE
FROM guded_source.product s, guded_source.vendor v, guded_source.category c
WHERE s.productid NOT IN (SELECT ProductID
FROM guded_datastaging.ProductDimension
WHERE ProductType = 'Sales Product')
AND s.vendorid = v.vendorid
AND s.categoryid = c.categoryid;

-- INSERTING THE NEW RENTAL PRODUCTS THAT OCCURED SINCE THE LAST REFRESH INTO DS
INSERT INTO guded_datastaging.ProductDimension(ProductID, ProductName, ProductType, VendorID, VendorName, CategoryID, CategoryName, RentalProductPriceDaily, RentalProductPriceWeekly, Extraction_Time_Stamp, F_LOADED)
SELECT s.productid, s.productname, 'Rental Product', s.vendorid, v.vendorname, s.categoryid, c.categoryname, s.productpricedaily, s.productpriceweekly, NOW(), FALSE
FROM guded_source.rentalProducts s, guded_source.vendor v, guded_source.category c
WHERE s.productid NOT IN (SELECT ProductID
FROM guded_datastaging.ProductDimension
WHERE ProductType = 'Rental Product')
AND s.vendorid = v.vendorid
AND s.categoryid = c.categoryid;

-- INSERTING THE NEW PRODUCTS THAT OCCURED SINCE THE LAST REFRESH INTO DW
INSERT INTO guded_datawarehousing.ProductDimension(ProductKey, ProductID, ProductName, ProductType, SalesProductPrice, VendorID, VendorName, CategoryID, CategoryName, RentalProductPriceDaily, RentalProductPriceWeekly)
SELECT ProductKey, ProductID, ProductName, ProductType, SalesProductPrice, VendorID, VendorName, CategoryID, CategoryName, RentalProductPriceDaily, RentalProductPriceWeekly
FROM guded_datastaging.ProductDimension
WHERE F_LOADED = FALSE;

-- UPDATING THE COLUMN F_LOADED TO TRUE AFTER LOADING NEW PRODUCTS INTO DW
UPDATE guded_datastaging.ProductDimension
SET F_LOADED = TRUE
WHERE F_LOADED = FALSE;
END

------ END OF PROCEDURE

-- INSERTING A NEW SALES PRODUCT INTO DATA SOURCE
INSERT INTO guded_source.product VALUES('9x8','Luxo Tent',500,'OA','CP');

-- INSERTING A NEW RENTAL PRODUCT INTO DATA SOURCE
INSERT INTO guded_source.rentalProducts(productid, productname, productpricedaily, productpriceweekly, vendorid, categoryid) VALUES ('9X8','Hi-Tec GPS',20, 80,'OA','EL');

-- SPOT CHECK FOR PRODUCTS
SELECT COUNT(*)
FROM guded_source.product
UNION
SELECT COUNT(*)
FROM guded_source.rentalProducts
UNION
SELECT COUNT(*)
FROM guded_datastaging.ProductDimension
UNION
SELECT COUNT(*)
FROM guded_datawarehousing.ProductDimension

-- USING PROCEDURE TO UPDATE NEW PRODUCTS INTO DS & DW
CALL ProductDimension_Refresh()