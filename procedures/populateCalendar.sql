CREATE PROCEDURE populateCalendar()
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE fd DATE DEFAULT '2013-01-01';
  DECLARE nd DATE;

  SET nd = fd;

  myloop: LOOP
    INSERT INTO CalendarDimension(FullDate, MonthYear, Year)
    VALUES (
      nd,
      CONCAT(LPAD(MONTH(nd),2,'0'),YEAR(nd)),
      YEAR(nd)
    );

    SET nd = DATE_ADD(fd, INTERVAL i DAY);
    SET i = i + 1;

    IF i > 8000 THEN
      LEAVE myloop;
    END IF;
  END LOOP myloop;

END;


/* 
  For Populating Calendar Dimension Records into Data WareHousing From Data Staging
  we use the code below

  INSERT INTO guded_datawarehousing.CalendarDimension(CalendarKey,FullDate,MonthYear,Year)
  SELECT CalendarKey,FullDate,MonthYear,Year
  FROM guded_datastaging.CalendarDimension;
*/