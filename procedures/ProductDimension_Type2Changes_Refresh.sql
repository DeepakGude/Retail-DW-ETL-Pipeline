-- TYPE 2 CHANGES FOR PRODUCT DIMENSION - LIST OF ATTRIBUTES
ProductName, VendorID, VendorName, SalesProductPrice
ProductName, VendorID, VendorName, RentalProductPriceDaily, RentalProductPriceWeekly

-- ADD DATE VALID FROM, DATE VALID UNTIL, CURRENT STATUS IN DS
ALTER TABLE guded_datastaging.ProductDimension
ADD DVF DATE, 
ADD DVU DATE,
ADD CURRENT_STATUS BOOLEAN

-- SET DVF, DVU, CURRENT_STATUS IN DS
UPDATE guded_datastaging.ProductDimension
SET DVF = '2013-01-01', DVU = '2030-01-01', CURRENT_STATUS = TRUE

-- SPOT CHECK QUERY
SELECT pd1.ProductKey, pd1.DVF, pd1.DVU, pd1.CURRENT_STATUS, pd2.ProductKey, pd2.DVF, pd2.DVU, pd2.CURRENT_STATUS
FROM guded_datastaging.ProductDimension pd1, guded_datastaging.ProductDimension pd2
WHERE pd1.ProductID = pd2.ProductID
AND pd1.ProductType = pd2.ProductType
AND pd1.DVF < pd2.DVF

-- FOR DW
ALTER TABLE guded_datawarehousing.ProductDimension
ADD DVF DATE, 
ADD DVU DATE,
ADD CURRENT_STATUS BOOLEAN

UPDATE guded_datawarehousing.ProductDimension
SET DVF = '2013-01-01',
DVU = '2030-01-01',
CURRENT_STATUS = TRUE;

-- PROCEDURE FOR ADDING NEW PRODUCTS
CREATE PROCEDURE ProductsDimension_Refresh()
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

-- PROCEDURE FOR TYPE 2 CHANGES TO PRODUCT DIMENSION
CREATE PROCEDURE ProductDimension_Type2Changes_Refresh()
BEGIN

-- INSERTING THE SALES PRODUCTS WITH TYPE 2 CHANGES THAT OCCURED SINCE THE LAST REFRESH INTO DS
INSERT INTO guded_datastaging.ProductDimension (ProductID,ProductName,SalesProductPrice,ProductType,VendorID,VendorName,CategoryID,CategoryName,RentalProductPriceDaily,RentalProductPriceWeekly,Extraction_Time_Stamp,F_LOADED,DVF,DVU,CURRENT_STATUS)
SELECT s.productid,s.productname,s.productprice,'Sales Product',s.vendorid,v.vendorname,s.categoryid,c.categoryname,NULL,NULL,NOW(),FALSE,DATE(NOW()),'2030-01-01',TRUE
FROM guded_source.product s, guded_source.vendor v, guded_source.category c, guded_datastaging.ProductDimension pd
WHERE s.productid = pd.ProductID
AND s.vendorid = v.vendorid
AND s.categoryid = c.categoryid
AND (s.productname <> pd.ProductName OR s.productprice <> pd.SalesProductPrice OR s.vendorid <> pd.VendorID OR v.vendorname <> pd.VendorName)
AND pd.ProductType = 'Sales Product'
AND pd.CURRENT_STATUS = TRUE;

-- INSERTING THE RENTAL PRODUCTS WITH TYPE 2 CHANGES THAT OCCURED SINCE THE LAST REFRESH INTO DS
INSERT INTO guded_datastaging.ProductDimension (ProductID,ProductName,SalesProductPrice,ProductType,VendorID,VendorName,CategoryID,CategoryName,RentalProductPriceDaily,RentalProductPriceWeekly,Extraction_Time_Stamp,F_LOADED,DVF,DVU,CURRENT_STATUS)
SELECT s.productid,s.productname,NULL,'Rental Product',s.vendorid,v.vendorname,s.categoryid,c.categoryname,s.productpricedaily,s.productpriceweekly,NOW(),FALSE,DATE(NOW()),'2030-01-01',TRUE
FROM guded_source.rentalProducts s, guded_source.vendor v, guded_source.category c, guded_datastaging.ProductDimension pd
WHERE s.productid = pd.ProductID
AND s.vendorid = v.vendorid
AND s.categoryid = c.categoryid
AND (s.productname <> pd.ProductName OR s.productpricedaily <> pd.RentalProductPriceDaily OR s.productpriceweekly <> pd.RentalProductPriceWeekly OR s.vendorid <> pd.VendorID OR v.vendorname <> pd.VendorName)
AND pd.ProductType = 'Rental Product'
AND pd.CURRENT_STATUS = TRUE;

-- UPDATING THE DATE VALID UNTIL IN DS 
UPDATE guded_datastaging.ProductDimension pd1, guded_datastaging.ProductDimension pd2
SET pd1.DVU = DATE(NOW())-INTERVAL 1 DAY,
pd1.CURRENT_STATUS = FALSE
WHERE pd1.ProductID = pd2.ProductID
AND pd1.ProductType = pd2.ProductType
AND pd1.DVF < pd2.DVF
AND pd1.CURRENT_STATUS = TRUE;

-- INSERTING THE PRODUCTS WITH NEW TYPE 2 CHANGES THAT OCCURED SINCE THE LAST REFRESH INTO DW
REPLACE INTO guded_datawarehousing.ProductDimension(ProductKey, ProductID, ProductName, ProductType, SalesProductPrice, VendorID, VendorName, CategoryID, CategoryName, RentalProductPriceDaily, RentalProductPriceWeekly, DVF, DVU, CURRENT_STATUS)
SELECT ProductKey, ProductID, ProductName, ProductType, SalesProductPrice, VendorID, VendorName, CategoryID, CategoryName, RentalProductPriceDaily, RentalProductPriceWeekly, DVF, DVU, CURRENT_STATUS
FROM guded_datastaging.ProductDimension;

-- UPDATING THE COLUMN F_LOADED TO TRUE AFTER INSERTING THE PRODUCTS WITH NEW TYPE 2 CHANGES INTO DW
UPDATE guded_datastaging.ProductDimension
SET F_LOADED = TRUE
WHERE F_LOADED = FALSE;
END

-- END OF PROCEDURE

-- SPOT CHECK FOR TYPE 2 CHANGES IN PRODUCTS
SELECT COUNT(*)
FROM guded_source.product
UNION
SELECT COUNT(*)
FROM guded_source.rentalProducts
UNION
SELECT COUNT(*)
FROM guded_datastaging.ProductDimension
WHERE CURRENT_STATUS = TRUE
UNION
SELECT COUNT(*)
FROM guded_datawarehousing.ProductDimension
WHERE CURRENT_STATUS = TRUE