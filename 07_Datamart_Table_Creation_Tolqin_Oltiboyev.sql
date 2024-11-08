-- Fact table for supplier purchases
CREATE TABLE IF NOT EXISTS star.FactSupplierPurchases
(
    PurchaseID          SERIAL PRIMARY KEY,
    SupplierID          INT,
    TotalPurchaseAmount DECIMAL,
    PurchaseDate        DATE,
    NumberOfProducts    INT,
    FOREIGN KEY (SupplierID) REFERENCES star.dimSupplier (SupplierID)
);

-- Fact table for product sales
CREATE TABLE IF NOT EXISTS star.FactProductSales
(
    FactSalesID  SERIAL PRIMARY KEY,
    DateID       INT,
    ProductID    INT,
    QuantitySold INT,
    TotalSales   DECIMAL(10, 2),
    FOREIGN KEY (DateID) REFERENCES star.DimDate (DateID),
    FOREIGN KEY (ProductID) REFERENCES star.DimProduct (ProductID)
);

-- Fact table for customer sales
CREATE TABLE IF NOT EXISTS star.FactCustomerSales
(
    FactCustomerSalesID  SERIAL PRIMARY KEY,
    DateID               INT,
    CustomerID           VARCHAR(5),
    TotalAmount          DECIMAL(10, 2),
    TotalQuantity        INT,
    NumberOfTransactions INT,
    FOREIGN KEY (DateID) REFERENCES star.DimDate (DateID),
    FOREIGN KEY (CustomerID) REFERENCES star.DimCustomer (CustomerID)
);

-- Fact sales already created in the previous script (03_Table_Creation_Star_Tolqin_Oltiboyev.sql)
