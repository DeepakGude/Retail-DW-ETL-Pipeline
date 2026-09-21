-- PROCEDURE FOR ADDING NEW STORES
CREATE PROCEDURE StoreDimension_Refresh()
BEGIN

-- INSERTING THE NEW STORES THAT OCCURED SINCE THE LAST REFRESH INTO DS
INSERT INTO guded_datastaging.StoreDimension(StoreID, StoreZip, RegionID, RegionName, Extraction_Time_Stamp, F_LOADED)
SELECT s.storeid, s.storezip, s.regionid, r.regionname, NOW(), FALSE
FROM guded_source.store s, guded_source.region r
WHERE storeid NOT IN (SELECT StoreID
FROM guded_datastaging.StoreDimension)
AND s.regionid = r.regionid;

-- INSERTING THE NEW STORES THAT OCCURED SINCE THE LAST REFRESH INTO DW
INSERT INTO guded_datawarehousing.StoreDimension(StoreKey, StoreID, StoreZip, RegionID, RegionName)
SELECT StoreKey, StoreID, StoreZip, RegionID, RegionName
FROM guded_datastaging.StoreDimension
WHERE F_LOADED = FALSE;

-- UPDATING THE COLUMN F_LOADED TO TRUE AFTER LOADING NEW STORES INTO DW
UPDATE guded_datastaging.StoreDimension
SET F_LOADED = TRUE
WHERE F_LOADED = FALSE;
END

------ END OF PROCEDURE

-- INSERTING A NEW STORE INTO DATA SOURCE
INSERT INTO guded_source.store VALUES('S16','60600','C ');

-- SPOT CHECK FOR STORES
SELECT COUNT(*)
FROM guded_source.store
UNION
SELECT COUNT(*)
FROM guded_datastaging.StoreDimension
UNION
SELECT COUNT(*)
FROM guded_datawarehousing.StoreDimension

-- USING PROCEDURE TO UPDATE NEW STORES INTO DS & DW
CALL StoreDimension_Refresh()