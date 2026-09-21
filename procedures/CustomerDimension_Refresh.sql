-- PROCEDURE FOR ADDING NEW CUSTOMERS
CREATE PROCEDURE CustomerDimension_Refresh()
BEGIN

-- INSERTING THE NEW CUSTOMERS THAT OCCURED SINCE THE LAST REFRESH INTO DS
INSERT INTO guded_datastaging.CustomerDimension(CustomerID, CustomerName, CustomerZip, Extraction_Time_Stamp, F_LOADED)
SELECT c.customerid, c.customername, c.customerzip, NOW(), FALSE
FROM guded_source.customer c
WHERE customerid NOT IN (SELECT CustomerID
FROM guded_datastaging.CustomerDimension);

-- INSERTING THE NEW CUSTOMERS THAT OCCURED SINCE THE LAST REFRESH INTO DW
INSERT INTO guded_datawarehousing.CustomerDimension(CustomerKey, CustomerID, CustomerName, CustomerZip)
SELECT CustomerKey, CustomerID, CustomerName, CustomerZip
FROM guded_datastaging.CustomerDimension
WHERE F_LOADED = FALSE;

-- UPDATING THE COLUMN F_LOADED TO TRUE AFTER LOADING NEW CUSTOMERS INTO DW
UPDATE guded_datastaging.CustomerDimension
SET F_LOADED = TRUE
WHERE F_LOADED = FALSE;
END

------ END OF PROCEDURE

-- INSERTING A NEW CUSTOMER INTO DATA SOURCE
INSERT INTO guded_source.customer VALUES('0-1-220','Dan','55499');

-- SPOT CHECK FOR CUSTOMERS
SELECT COUNT(*)
FROM guded_source.customer
UNION
SELECT COUNT(*)
FROM guded_datastaging.CustomerDimension
UNION
SELECT COUNT(*)
FROM guded_datawarehousing.CustomerDimension

-- USING PROCEDURE TO UPDATE NEW CUSTOMERS INTO DS & DW
CALL CustomerDimension_Refresh()