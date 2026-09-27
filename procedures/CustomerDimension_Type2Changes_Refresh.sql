-- TYPE 2 CHANGES FOR CUSTOMER DIMENSION - LIST OF ATTRIBUTES
CustomerName, CustomerZip

-- ADD DATE VALID FROM, DATE VALID UNTIL, CURRENT STATUS IN DS
ALTER TABLE guded_datastaging.CustomerDimension
ADD DVF DATE, 
ADD DVU DATE,
ADD CURRENT_STATUS BOOLEAN

-- SET DVF, DVU, CURRENT_STATUS IN DS
UPDATE guded_datastaging.CustomerDimension
SET DVF = '2013-01-01', DVU = '2030-01-01', CURRENT_STATUS = TRUE

-- SPOT CHECK QUERY FOR TYPE 2 CHANGES IN CUSTOMER DIMENSION
SELECT cd1.CustomerKey, cd1.DVF, cd1.DVU, cd1.CURRENT_STATUS, cd2.CustomerKey, cd2.DVF, cd2.DVU, cd2.CURRENT_STATUS
FROM guded_datastaging.CustomerDimension cd1, guded_datastaging.CustomerDimension cd2
WHERE cd1.CustomerID = cd2.CustomerID
AND cd1.DVF < cd2.DVF

-- FOR DW
ALTER TABLE guded_datawarehousing.CustomerDimension
ADD DVF DATE, 
ADD DVU DATE,
ADD CURRENT_STATUS BOOLEAN

UPDATE guded_datawarehousing.CustomerDimension
SET DVF = '2013-01-01',
DVU = '2030-01-01',
CURRENT_STATUS = TRUE;

-- SPOT CHECK FOR CUSTOMERS
SELECT COUNT(*)
FROM guded_source.customer
UNION
SELECT COUNT(*)
FROM guded_datastaging.CustomerDimension
WHERE CURRENT_STATUS = TRUE
UNION
SELECT COUNT(*)
FROM guded_datawarehousing.CustomerDimension
WHERE CURRENT_STATUS = TRUE

-- PROCEDURE FOR ADDING NEW CUSTOMERS
CREATE PROCEDURE CustomerDimension_Refresh()
BEGIN

-- INSERTING THE NEW CUSTOMERS THAT OCCURED SINCE THE LAST REFRESH INTO DS
INSERT INTO guded_datastaging.CustomerDimension(CustomerID, CustomerName, CustomerZip, Extraction_Time_Stamp, F_LOADED, DVF, DVU, CURRENT_STATUS)
SELECT c.customerid, c.customername, c.customerzip, NOW(), FALSE, DATE(NOW()), '2030-01-01', TRUE
FROM guded_source.customer c
WHERE customerid NOT IN (SELECT CustomerID
FROM guded_datastaging.CustomerDimension);

-- INSERTING THE NEW CUSTOMERS THAT OCCURED SINCE THE LAST REFRESH INTO DW
INSERT INTO guded_datawarehousing.CustomerDimension(CustomerKey, CustomerID, CustomerName, CustomerZip, DVF, DVU, CURRENT_STATUS)
SELECT CustomerKey, CustomerID, CustomerName, CustomerZip, DVF, DVU, CURRENT_STATUS
FROM guded_datastaging.CustomerDimension
WHERE F_LOADED = FALSE;

-- UPDATING THE COLUMN F_LOADED TO TRUE AFTER LOADING NEW CUSTOMERS INTO DW
UPDATE guded_datastaging.CustomerDimension
SET F_LOADED = TRUE
WHERE F_LOADED = FALSE;
END

-- END OF PROCEDURE

-- PROCEDURE FOR TYPE 2 CHANGES TO CUSTOMER DIMENSION
CREATE PROCEDURE CustomerDimension_Type2Changes_Refresh()
BEGIN

-- INSERTING CUSTOMERS WITH TYPE 2 CHANGES THAT OCCURED SINCE THE LAST REFRESH INTO DS 
INSERT INTO guded_datastaging.CustomerDimension(CustomerID, CustomerName, CustomerZip, Extraction_Time_Stamp, F_LOADED, DVF, DVU, CURRENT_STATUS)
SELECT c.customerid, c.customername, c.customerzip, NOW(), FALSE, DATE(NOW()), '2030-01-01', TRUE
FROM guded_source.customer c, guded_datastaging.CustomerDimension cd
WHERE c.customerid = cd.CustomerID
AND (c.customername <> cd.CustomerName OR c.customerzip <> cd.CustomerZip)
AND cd.CURRENT_STATUS = TRUE;

-- UPDATING THE DATE VALID UNTIL IN DS 
UPDATE guded_datastaging.CustomerDimension cd1, guded_datastaging.CustomerDimension cd2
SET cd1.DVU = DATE(NOW())-INTERVAL 1 DAY,
cd1.CURRENT_STATUS = FALSE
WHERE cd1.CustomerID = cd2.CustomerID
AND cd1.DVF < cd2.DVF
AND cd1.CURRENT_STATUS = TRUE;

-- INSERTING THE CUSTOMERS WITH NEW TYPE 2 CHANGES THAT OCCURED SINCE THE LAST REFRESH INTO DW
REPLACE INTO guded_datawarehousing.CustomerDimension(CustomerKey, CustomerID, CustomerName, CustomerZip, DVF, DVU, CURRENT_STATUS)
SELECT CustomerKey, CustomerID, CustomerName, CustomerZip, DVF, DVU, CURRENT_STATUS
FROM guded_datastaging.CustomerDimension;

-- UPDATING THE COLUMN F_LOADED TO TRUE AFTER INSERTING THE CUSTOMERS WITH NEW TYPE 2 CHANGES INTO DW
UPDATE guded_datastaging.CustomerDimension
SET F_LOADED = TRUE
WHERE F_LOADED = FALSE;
END

-- END OF PROCEDURE