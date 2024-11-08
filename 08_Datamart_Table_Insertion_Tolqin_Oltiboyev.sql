-- FactSupplierPurchases table insertion
INSERT INTO star.FactSupplierPurchases (SupplierID, TotalPurchaseAmount, PurchaseDate, NumberOfProducts)
SELECT
    p.SupplierID,
    SUM(od.UnitPrice * od.Quantity) AS TotalPurchaseAmount,
    CURRENT_DATE AS PurchaseDate, -- We are using the current date as the purchase date
    COUNT(DISTINCT od.ProductID) AS NumberOfProducts
FROM staging.stagingorderdetails od
         JOIN staging.stagingproducts p ON od.ProductID = p.ProductID
GROUP BY p.SupplierID;

-- FactProductSales table insertion
INSERT INTO star.FactProductSales (DateID, ProductID, QuantitySold, TotalSales)
SELECT d.DateID, p.ProductID, sod.Quantity, (sod.Quantity * sod.UnitPrice) AS TotalSales
FROM staging.stagingorderdetails sod
         JOIN staging.stagingorders s ON sod.OrderID = s.OrderID
         JOIN staging.stagingproducts p ON sod.ProductID = p.ProductID
         JOIN star.DimDate d ON s.OrderDate = d.Date;

-- FactCustomerSales table insertion
INSERT INTO star.FactCustomerSales (DateID, CustomerID, TotalAmount, TotalQuantity, NumberOfTransactions)
SELECT
    d.DateID,
    o.CustomerID,
    SUM((od.UnitPrice * od.Quantity) - (od.UnitPrice * od.Quantity * od.Discount)) AS TotalAmount, -- Computing the total amount considering discounts
    SUM(od.Quantity) AS TotalQuantity,
    COUNT(DISTINCT o.OrderID) AS NumberOfTransactions
FROM
    staging.stagingorders AS o
        JOIN
    staging.stagingorderdetails AS od ON o.OrderID = od.OrderID
        JOIN
    star.DimDate AS d ON d.Date = o.OrderDate
        JOIN
    star.DimCustomer AS c ON c.CustomerID = o.CustomerID
GROUP BY
    d.DateID,
    o.CustomerID;

-- FactSales already inserted in the previous script (05_Data_Insertion_Star_Tolqin_Oltiboyev.sql)