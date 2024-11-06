CREATE SCHEMA star;

-- Set the default schema for this session to 'star'
SET search_path TO star;

-- Dimension Tables
CREATE TABLE star.dimDate
(
    dateID     serial PRIMARY KEY,
    date       date,
    day        int,
    month      int,
    year       int,
    quarter    int,
    weekOfYear int
);

CREATE TABLE star.dimCustomer
(
    customerID   varchar(5) PRIMARY KEY,
    companyName  varchar(40),
    contactName  varchar(30),
    contactTitle varchar(30),
    address      varchar(60),
    city         varchar(15),
    region       varchar(15),
    postalCode   varchar(10),
    country      varchar(15),
    phone        varchar(24)
);



CREATE TABLE star.dimEmployee
(
    employeeID int PRIMARY KEY,
    lastName   varchar(20),
    firstName  varchar(10),
    title      varchar(30),
    birthDate  date,
    hireDate   date,
    address    varchar(60),
    city       varchar(15),
    region     varchar(15),
    postalCode varchar(10),
    country    varchar(15),
    homePhone  varchar(24),
    extension  varchar(4)
);

CREATE TABLE star.dimCategory
(
    categoryID   int PRIMARY KEY,
    categoryName varchar(15),
    description  text
);

CREATE TABLE star.dimShipper
(
    shipperID   int PRIMARY KEY,
    companyName varchar(40),
    phone       varchar(24)
);

CREATE TABLE star.dimSupplier
(
    supplierID   int PRIMARY KEY,
    companyName  varchar(40),
    contactName  varchar(30),
    contactTitle varchar(30),
    address      varchar(60),
    city         varchar(15),
    region       varchar(15),
    postalCode   varchar(10),
    country      varchar(15),
    phone        varchar(24)
);

CREATE TABLE star.dimProduct
(
    productID       int PRIMARY KEY,
    productName     varchar(40),
    supplierID      int REFERENCES star.dimSupplier (supplierID),
    categoryID      int REFERENCES star.dimCategory (categoryID),
    quantityPerUnit varchar(20),
    unitPrice       numeric(10, 2),
    unitsInStock    int
);


-- Fact Table

CREATE TABLE star.factSales
(
    salesID      serial,
    dateID       int REFERENCES star.dimDate(dateID),
    customerID   varchar(5) REFERENCES star.dimCustomer(customerID),
    productID    int REFERENCES star.dimProduct(productID),
    employeeID   int REFERENCES star.dimEmployee(employeeID),
    categoryID   int REFERENCES star.dimCategory(categoryID),
    shipperID    int REFERENCES star.dimShipper(shipperID),
    supplierID   int REFERENCES star.dimSupplier(supplierID),
    quantitySold int,
    unitPrice    numeric(10, 2),
    discount     real,
    totalAmount  numeric(10, 2) GENERATED ALWAYS AS (quantitySold * unitPrice - discount) STORED,
    taxAmount    numeric(10, 2),
    PRIMARY KEY (salesID, productID) -- Order might have multiple products. That;s why we need to make the combination of salesID and productID unique. Strange that we don't have such instruction in example.
);