CREATE SCHEMA staging;

-- Set the default schema for this session to 'staging'
SET search_path TO staging;

-- Staging Tables
CREATE TABLE staging.stagingOrders
(
    orderID      int,
    customerID   varchar(5),
    employeeID   int,
    orderDate    date,
    requiredDate date,
    shippedDate  date,
    shipVia      int,
    freight      numeric(10, 2)
);

CREATE TABLE staging.stagingOrderDetails
(
    orderID   int,
    productID int,
    unitPrice numeric(10, 2),
    quantity  int,
    discount  real
);

CREATE TABLE staging.stagingProducts
(
    productID       int,
    productName     varchar(40),
    supplierID      int,
    categoryID      int,
    quantityPerUnit varchar(20),
    unitPrice       numeric(10, 2),
    unitsInStock    int,
    unitsOnOrder    int,
    reorderLevel    int,
    discontinued    bool
);

CREATE TABLE staging.stagingCustomers
(
    customerID   varchar(5),
    companyName  varchar(40),
    contactName  varchar(30),
    contactTitle varchar(30),
    address      varchar(60),
    city         varchar(15),
    region       varchar(15),
    postalCode   varchar(10),
    country      varchar(15),
    phone        varchar(24),
    fax          varchar(24)
);

CREATE TABLE staging.stagingEmployees
(
    employeeID      int,
    lastName        varchar(20),
    firstName       varchar(10),
    title           varchar(30),
    titleOfCourtesy VARCHAR(25),
    birthDate       date,
    hireDate        date,
    address         varchar(60),
    city            varchar(15),
    region          varchar(15),
    postalCode      varchar(10),
    country         varchar(15),
    homePhone       varchar(24),
    extension       varchar(4),
    notes           TEXT,
    reportsTo       INTEGER
);

CREATE TABLE staging.stagingCategories
(
    categoryID   int,
    categoryName varchar(15),
    description  text
);

CREATE TABLE staging.stagingShippers
(
    shipperID   int,
    companyName varchar(40),
    phone       varchar(24)
);

CREATE TABLE staging.stagingSuppliers
(
    supplierID   int,
    companyName  varchar(40),
    contactName  varchar(30),
    contactTitle varchar(30),
    address      varchar(60),
    city         varchar(15),
    region       varchar(15),
    postalCode   varchar(10),
    country      varchar(15),
    phone        varchar(24),
    fax          varchar(24),
    homePage     text
);