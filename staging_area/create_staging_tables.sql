CREATE TABLE ProductDimension
(
  ProductKey INT NOT NULL AUTO_INCREMENT,
  ProductID CHAR(3) NOT NULL,
  ProductName VARCHAR(25) NOT NULL,

  -- Sales price can be NULL for rental products
  SalesProductPrice DECIMAL(7,2) NULL,

  ProductType VARCHAR(20) NOT NULL,
  VendorID CHAR(2) NOT NULL,
  VendorName VARCHAR(25) NOT NULL,
  CategoryID CHAR(2) NOT NULL,
  CategoryName VARCHAR(25) NOT NULL,

  -- Rental prices can be NULL for sales products
  RentalProductPriceDaily DECIMAL(7,2) NULL,
  RentalProductPriceWeekly DECIMAL(7,2) NULL,

  PRIMARY KEY (ProductKey)
);

CREATE TABLE CustomerDimension
(
  CustomerKey INT NOT NULL,
  CustomerID CHAR(7) NOT NULL,
  CustomerName VARCHAR(15) NOT NULL,
  CustomerZip CHAR(5) NOT NULL,
  PRIMARY KEY (CustomerKey)
);

CREATE TABLE CalendarDimension
(
  CalendarKey INT NOT NULL AUTO_INCREMENT,
  FullDate DATE NOT NULL,
  MonthYear INT NOT NULL,
  Year INT NOT NULL,
  PRIMARY KEY (CalendarKey)
);

CREATE TABLE StoreDimension
(
  StoreKey INT NOT NULL AUTO_INCREMENT,
  StoreID VARCHAR(3) NOT NULL,
  StoreZip CHAR(5) NOT NULL,
  RegionID CHAR(1) NOT NULL,
  RegionName VARCHAR(25) NOT NULL,
  PRIMARY KEY (StoreKey)
);

CREATE TABLE RevenueFact
(
  DollarsGenerated NUMERIC(7,2) NOT NULL,
  UnitsSold INT NOT NULL,
  TID VARCHAR(8) NOT NULL,
  RevenueType VARCHAR(25) NOT NULL,
  ProductKey INT NOT NULL,
  StoreKey INT NOT NULL,
  CustomerKey INT NOT NULL,
  CalendarKey INT NOT NULL,
  PRIMARY KEY (ProductKey, StoreKey, CustomerKey, CalendarKey, TID, RevenueType)
);