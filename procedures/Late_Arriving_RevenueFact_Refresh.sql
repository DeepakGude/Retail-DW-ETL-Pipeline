-- PROCEDURE FOR ADDING LATE ARRIVING FACTS
CREATE PROCEDURE Late_Arriving_RevenueFact_Refresh()
BEGIN
DROP TABLE IF EXISTS IFT;

--  CREATING AN INTERMEDIATE FACT TABLE TO STORE ONLY NEW FACTS
CREATE TABLE IFT AS
SELECT sv.noofitems AS UnitsSold, sv.noofitems*p.productprice AS DollarsGenerated, sv.tid AS TID, 'Sales' AS RevenueType, p.productid, st.customerid, st.storeid, st.tdate
FROM guded_source.salestransaction st, guded_source.soldvia sv, guded_source.product p
WHERE p.productid = sv.productid
AND sv.tid = st.tid
AND st.tid NOT IN (SELECT tid
FROM guded_datastaging.RevenueFact)
UNION
SELECT rv.duration AS UnitsSold, rv.duration*rp.productpricedaily AS DollarsGenerated, rv.tid AS TID, 'Rental,daily' AS RevenueType, rp.productid, rt.customerid, rt.storeid, rt.tdate
FROM guded_source.rentaltransaction rt, guded_source.rentvia rv, guded_source.rentalProducts rp
WHERE rp.productid = rv.productid
AND rv.tid = rt.tid
AND rv.rentaltype = 'D'
AND rt.tid NOT IN (SELECT tid
FROM guded_datastaging.RevenueFact)
UNION
SELECT rv.duration AS UnitsSold, rv.duration*rp.productpriceweekly AS DollarsGenerated, rv.tid AS TID, 'Rental,weekly' AS RevenueType, rp.productid, rt.customerid, rt.storeid, rt.tdate
FROM guded_source.rentaltransaction rt, guded_source.rentvia rv, guded_source.rentalProducts rp
WHERE rp.productid = rv.productid
AND rv.tid = rt.tid
AND rv.rentaltype = 'W'
AND rt.tid NOT IN (SELECT tid
FROM guded_datastaging.RevenueFact);

-- FIX A COLLATION MISMATCH BETWEEN RevenueType IN IFT and RevenueType in RevenueFact
ALTER TABLE IFT
MODIFY RevenueType VARCHAR(25) COLLATE utf8mb4_0900_ai_ci;

-- INSERTING THE NEW FACTS THAT OCCURED SINCE THE LAST REFRESH INTO DS
INSERT INTO guded_datastaging.RevenueFact(RevenueType, TID, UnitsSold, DollarsGenerated, ProductKey, StoreKey, CustomerKey, CalendarKey, Extraction_Time_Stamp, F_LOADED)
SELECT i.RevenueType AS RevenueType, i.TID as TID, i.UnitsSold AS UnitsSold, i.DollarsGenerated AS DollarsGenerated, pd.ProductKey, sd.StoreKey, cd.CustomerKey, cc.CalendarKey, NOW(), FALSE
FROM guded_datastaging.IFT i, guded_datastaging.ProductDimension pd, guded_datastaging.StoreDimension sd, guded_datastaging.CalendarDimension cc, guded_datastaging.CustomerDimension cd
WHERE i.productid = pd.productid
AND i.storeid = sd.storeid
AND i.customerid = cd.customerid
AND i.tdate = cc.FullDate
AND LEFT(i.RevenueType,1) = LEFT(pd.ProductType,1);

-- INSERTING THE NEW FACTS THAT OCCURED SINCE THE LAST REFRESH INTO DW
INSERT INTO guded_datawarehousing.RevenueFact(DollarsGenerated, UnitsSold, TID, RevenueType, ProductKey, StoreKey, CustomerKey, CalendarKey)
SELECT DollarsGenerated, UnitsSold, TID, RevenueType, ProductKey, StoreKey, CustomerKey, CalendarKey
FROM guded_datastaging.RevenueFact
WHERE F_LOADED = FALSE;

-- UPDATING THE COLUMN F_LOADED TO TRUE AFTER LOADING NEW FACTS INTO DW
UPDATE guded_datastaging.RevenueFact
SET F_LOADED = TRUE
WHERE F_LOADED = FALSE;
END

------ END OF PROCEDURE

----- ADDING NEW SALES TRANSACTIONS
INSERT INTO guded_source.salestransaction VALUES ('N022','9-0-111','S5','2026-09-21');
 
INSERT INTO guded_source.soldvia VALUES('1X1','N022',1);
INSERT INTO guded_source.soldvia VALUES('2X2','N022',1);

----- ADDING NEW RENTAL TRANSACTIONS
INSERT INTO guded_source.rentaltransaction(tid, customerid, storeid, tdate) VALUES('R65','6-7-888','S7','2026-09-21');
 
INSERT INTO guded_source.rentvia(productid, tid, rentaltype, duration) VALUES ('4X4','R65','W',2);
INSERT INTO guded_source.rentvia(productid, tid, rentaltype, duration) VALUES ('5X5','R65','D',3);

-- SPOT CHECK FOR NEW TRANSACTIONS
SELECT COUNT(*)
FROM guded_source.rentvia
UNION
SELECT COUNT(*)
FROM guded_source.soldvia
UNION
SELECT COUNT(*)
FROM guded_datastaging.RevenueFact
UNION
SELECT COUNT(*)
FROM guded_datawarehousing.RevenueFact

-- USING PROCEDURE TO UPDATE LATE ARRIVING REVENUE FACTS INTO DS & DW
CALL Late_Arriving_RevenueFact_Refresh()