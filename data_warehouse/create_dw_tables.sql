CREATE TABLE ProductDimension
(
  ProductKey INT NOT NULL,
  ProductID CHAR(3) NOT NULL,
  ProductName VARCHAR(25) NOT NULL,
  SalesProductPrice NUMERIC(7,2) NOT NULL,
  ProductType VARCHAR(20) NOT NULL,
  VendorID CHAR(2) NOT NULL,
  VendorName VARCHAR(25) NOT NULL,
  CategoryID CHAR(2) NOT NULL,
  CategoryName VARCHAR(25) NOT NULL,
  RentalProductPriceDaily NUMERIC(7,2) NOT NULL,
  RentalProductPriceWeekly NUMERIC(7,2) NOT NULL,
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
  CalendarKey INT NOT NULL,
  FullDate DATE NOT NULL,
  MonthYear INT NOT NULL,
  Year INT NOT NULL,
  PRIMARY KEY (CalendarKey)
);

CREATE TABLE StoreDimension
(
  StoreKey INT NOT NULL,
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
  PRIMARY KEY (ProductKey, StoreKey, CustomerKey, CalendarKey, TID, RevenueType),
  FOREIGN KEY (ProductKey) REFERENCES ProductDimension(ProductKey),
  FOREIGN KEY (StoreKey) REFERENCES StoreDimension(StoreKey),
  FOREIGN KEY (CustomerKey) REFERENCES CustomerDimension(CustomerKey),
  FOREIGN KEY (CalendarKey) REFERENCES CalendarDimension(CalendarKey)
);