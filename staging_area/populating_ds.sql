-- EXTRACTING THE DATA FROM source INTO datastaging FOR PRODUCT DIMENSION
INSERT INTO ProductDimension(ProductID, ProductName, SalesProductPrice, ProductType, VendorID, VendorName, CategoryID, CategoryName, RentalProductPriceDaily, RentalProductPriceWeekly)

SELECT p.productid, p.productname, p.productprice, 'Sales Product', v.vendorid, v.vendorname, c.categoryid, c.categoryname, NULL, NULL
FROM guded_source.product p, guded_source.vendor v, guded_source.category c
WHERE p.categoryid = c.categoryid
AND v.vendorid = p.vendorid

UNION

SELECT r.productid, r.productname, NULL, 'Rental Product', v.vendorid, v.vendorname, c.categoryid, c.categoryname, r.productpricedaily, r.productpriceweekly
FROM guded_source.rentalProducts r, guded_source.vendor v, guded_source.category c
WHERE r.categoryid = c.categoryid
AND v.vendorid = r.vendorid

-- EXTRACTING THE DATA FROM source INTO datastaging FOR STORE DIMENSION
INSERT INTO StoreDimension(StoreID, StoreZip, RegionID, RegionName)

SELECT s.storeid, s.storezip, r.regionid, r.regionname
FROM guded_source.store s, guded_source.region r
WHERE s.regionid= r.regionid

-- EXTRACTING THE DATA FROM source INTO datastaging FOR CUSTOMER DIMENSION
INSERT INTO CustomerDimension(CustomerID, CustomerName, CustomerZip)

SELECT c.customerid, c.customername, c.customerzip
FROM guded_source.customer c

-- CODE FOR EXTRACTING SALES REVENUE FACTS
SELECT sv.noofitems AS UnitsSold, sv.noofitems*p.productprice AS DollarsGenerated, sv.tid AS TID, 'Sales' AS RevenueType, p.productid, st.customerid, st.storeid, st.tdate
FROM guded_source.salestransaction st, guded_source.soldvia sv, guded_source.product p
WHERE p.productid = sv.productid
AND sv.tid = st.tid

-- CODE FOR EXTRACTING RENTAL REVENUE FACTS
SELECT rv.duration AS UnitsSold, rv.duration*rp.productpricedaily AS DollarsGenerated, rv.tid AS TID, 'Rental,daily' AS RevenueType, rp.productid, rt.customerid, rt.storeid, rt.tdate
FROM guded_source.rentaltransaction rt, guded_source.rentvia rv, guded_source.rentalProducts rp
WHERE rp.productid = rv.productid
AND rv.tid = rt.tid
AND rv.rentaltype = 'D'

UNION

SELECT rv.duration AS UnitsSold, rv.duration*rp.productpriceweekly AS DollarsGenerated, rv.tid AS TID, 'Rental,weekly' AS RevenueType, rp.productid, rt.customerid, rt.storeid, rt.tdate
FROM guded_source.rentaltransaction rt, guded_source.rentvia rv, guded_source.rentalProducts rp
WHERE rp.productid = rv.productid
AND rv.tid = rt.tid
AND rv.rentaltype = 'W'

-- CREATING  AN INTERMEDIATE TABLE
DROP TABLE IF EXISTS IFT;

CREATE TABLE IFT AS

SELECT sv.noofitems AS UnitsSold, sv.noofitems*p.productprice AS DollarsGenerated, sv.tid AS TID, 'Sales' AS RevenueType, p.productid, st.customerid, st.storeid, st.tdate
FROM guded_source.salestransaction st, guded_source.soldvia sv, guded_source.product p
WHERE p.productid = sv.productid
AND sv.tid = st.tid

UNION

SELECT rv.duration AS UnitsSold, rv.duration*rp.productpricedaily AS DollarsGenerated, rv.tid AS TID, 'Rental,daily' AS RevenueType, rp.productid, rt.customerid, rt.storeid, rt.tdate
FROM guded_source.rentaltransaction rt, guded_source.rentvia rv, guded_source.rentalProducts rp
WHERE rp.productid = rv.productid
AND rv.tid = rt.tid
AND rv.rentaltype = 'D'

UNION

SELECT rv.duration AS UnitsSold, rv.duration*rp.productpriceweekly AS DollarsGenerated, rv.tid AS TID, 'Rental,weekly' AS RevenueType, rp.productid, rt.customerid, rt.storeid, rt.tdate
FROM guded_source.rentaltransaction rt, guded_source.rentvia rv, guded_source.rentalProducts rp
WHERE rp.productid = rv.productid
AND rv.tid = rt.tid
AND rv.rentaltype = 'W'

-- INSERTING DATA INTO THE FACT TABLE
INSERT INTO RevenueFact(RevenueType, TID, UnitsSold, DollarsGenerated, ProductKey, StoreKey, CustomerKey, CalendarKey)
SELECT i.RevenueType AS RevenueType, i.TID as TID, i.UnitsSold AS UnitsSold, i.DollarsGenerated AS DollarsGenerated, pd.ProductKey, sd.StoreKey, cd.CustomerKey, cc.CalendarKey
FROM IFT i, ProductDimension pd, StoreDimension sd, CalendarDimension cc, CustomerDimension cd
WHERE i.productid = pd.productid
AND i.storeid = sd.storeid
AND i.customerid = cd.customerid
AND i.tdate = cc.FullDate
AND LEFT(i.RevenueType,1) = LEFT(pd.ProductType,1)