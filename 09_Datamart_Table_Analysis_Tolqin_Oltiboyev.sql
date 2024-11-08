-- FactSupplierPurchases Performance Report
SELECT
    s.CompanyName,
    COUNT(fsp.PurchaseID) AS TotalOrders,
    SUM(fsp.TotalPurchaseAmount) AS TotalPurchaseValue,
    AVG(fsp.NumberOfProducts) AS AverageProductsPerOrder
FROM
    star.FactSupplierPurchases fsp
        JOIN
    star.dimSupplier s ON fsp.SupplierID = s.SupplierID
GROUP BY
    s.CompanyName
ORDER BY
    TotalOrders DESC, TotalPurchaseValue DESC;

-- FactSupplierPurchases Spending Analysis
SELECT
    s.CompanyName,
    SUM(fsp.TotalPurchaseAmount) AS TotalSpend,
    EXTRACT(YEAR FROM fsp.PurchaseDate) AS Year,
    EXTRACT(MONTH FROM fsp.PurchaseDate) AS Month
FROM star.FactSupplierPurchases fsp
         JOIN star.dimSupplier s ON fsp.SupplierID = s.SupplierID
GROUP BY s.CompanyName, Year, Month
ORDER BY TotalSpend DESC;

-- FactSupplierPurchases Product Cost Breakdown
SELECT
    s.CompanyName,
    p.ProductName,
    AVG(od.UnitPrice) AS AverageUnitPrice,
    SUM(od.Quantity) AS TotalQuantityPurchased,
    SUM(od.UnitPrice * od.Quantity) AS TotalSpend
FROM staging.stagingorderdetails od
         JOIN staging.stagingproducts p ON od.ProductID = p.ProductID
         JOIN star.dimSupplier s ON p.SupplierID = s.SupplierID
GROUP BY s.CompanyName, p.ProductName
ORDER BY s.CompanyName, TotalSpend DESC;

-- FactSupplierPurchases Supplier reliability
SELECT
    s.CompanyName,
    COUNT(fsp.PurchaseID) AS TotalTransactions,
    SUM(fsp.TotalPurchaseAmount) AS TotalSpent
FROM star.FactSupplierPurchases fsp
         JOIN star.dimSupplier s ON fsp.SupplierID = s.SupplierID
GROUP BY s.CompanyName
ORDER BY TotalTransactions DESC, TotalSpent DESC;

-- Top Five Products by Total Purchases per Supplier
SELECT
    s.CompanyName,
    p.ProductName,
    SUM(od.UnitPrice * od.Quantity) AS TotalSpend
FROM staging.stagingorderdetails od
         JOIN staging.stagingproducts p ON od.ProductID = p.ProductID
         JOIN star.dimSupplier s ON p.SupplierID = s.SupplierID
GROUP BY s.CompanyName, p.ProductName
ORDER BY s.CompanyName, TotalSpend DESC
LIMIT 5;


------------------------------------------------------------------------


-- Top-Selling Products
SELECT
    p.ProductName,
    SUM(fps.QuantitySold) AS TotalQuantitySold,
    SUM(fps.TotalSales) AS TotalRevenue
FROM
    star.FactProductSales fps
        JOIN star.DimProduct p ON fps.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalRevenue DESC
LIMIT 5;

-- Products With Low Stock Levels
SELECT
    ProductID,
    ProductName,
    UnitsInStock
FROM
    star.DimProduct
WHERE
    UnitsInStock < 10;  -- Assumes a critical low stock level is 10 units

-- Sales Trends by Product Category
SELECT
    c.CategoryName,
    EXTRACT(YEAR FROM d.Date) AS Year,
    EXTRACT(MONTH FROM d.Date) AS Month,
    SUM(fps.QuantitySold) AS TotalQuantitySold,
    SUM(fps.TotalSales) AS TotalRevenue
FROM
    star.FactProductSales fps
        JOIN star.DimProduct p ON fps.ProductID = p.ProductID
        JOIN star.DimCategory c ON p.CategoryID = c.CategoryID
        JOIN star.DimDate d ON fps.DateID = d.DateID
GROUP BY c.CategoryName, Year, Month, d.date
ORDER BY Year, Month, TotalRevenue DESC;

-- Inventory Valuation
SELECT
    p.ProductName,
    p.UnitsInStock,
    p.UnitPrice,
    (p.UnitsInStock * p.UnitPrice) AS InventoryValue
FROM
    star.DimProduct p
ORDER BY InventoryValue DESC;

-- Supplier Performance Based on Product Sales
SELECT
    s.CompanyName,
    COUNT(DISTINCT fps.FactSalesID) AS NumberOfSalesTransactions,
    SUM(fps.QuantitySold) AS TotalProductsSold,
    SUM(fps.TotalSales) AS TotalRevenueGenerated
FROM
    star.FactProductSales fps
        JOIN star.DimProduct p ON fps.ProductID = p.ProductID
        JOIN star.dimSupplier s ON p.SupplierID = s.SupplierID
GROUP BY s.CompanyName
ORDER BY TotalRevenueGenerated DESC;


------------------------------------------------------------------------


-- Customer Sales Overview
SELECT
    c.CustomerID,
    c.CompanyName,
    SUM(fcs.TotalAmount) AS TotalSpent,
    SUM(fcs.TotalQuantity) AS TotalItemsPurchased,
    SUM(fcs.NumberOfTransactions) AS TransactionCount
FROM
    star.FactCustomerSales fcs
        JOIN star.DimCustomer c ON fcs.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY TotalSpent DESC;

-- Top Five Customers by Total Sales
SELECT
    c.CompanyName,
    SUM(fcs.TotalAmount) AS TotalSpent
FROM
    star.FactCustomerSales fcs
        JOIN star.DimCustomer c ON fcs.CustomerID = c.CustomerID
GROUP BY c.CompanyName
ORDER BY TotalSpent DESC
LIMIT 5;

-- Customers by Region
SELECT
    c.Region,
    COUNT(*) AS NumberOfCustomers,
    SUM(fcs.TotalAmount) AS TotalSpentInRegion
FROM
    star.FactCustomerSales fcs
        JOIN star.DimCustomer c ON fcs.CustomerID = c.CustomerID
GROUP BY c.Region
ORDER BY NumberOfCustomers DESC;

-- Customer Segmentation Analysis
SELECT
    c.CustomerID,
    c.CompanyName,
    CASE
        WHEN SUM(fcs.TotalAmount) > 10000 THEN 'VIP'
        WHEN SUM(fcs.TotalAmount) BETWEEN 5000 AND 10000 THEN 'Premium'
        ELSE 'Standard'
        END AS CustomerSegment
FROM
    star.FactCustomerSales fcs
        JOIN star.DimCustomer c ON fcs.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CompanyName
ORDER BY SUM(fcs.TotalAmount) DESC;


------------------------------------------------------------------------


-- Aggregate Sales by Month and Category
SELECT d.Month, d.Year, c.CategoryName, SUM(fs.TotalAmount) AS TotalSales
FROM star.FactSales fs
         JOIN star.DimDate d ON fs.DateID = d.DateID
         JOIN star.DimCategory c ON fs.CategoryID = c.CategoryID
GROUP BY d.Month, d.Year, c.CategoryName
ORDER BY d.Year, d.Month, TotalSales DESC;

-- Top-Selling Products per Quarter
SELECT d.Quarter, d.Year, p.ProductName, SUM(fs.QuantitySold) AS TotalQuantitySold
FROM star.FactSales fs
         JOIN star.DimDate d ON fs.DateID = d.DateID
         JOIN star.DimProduct p ON fs.ProductID = p.ProductID
GROUP BY d.Quarter, d.Year, p.ProductName
ORDER BY d.Year, d.Quarter, TotalQuantitySold DESC
LIMIT 5;

-- Sales Performance by Employee
SELECT e.FirstName, e.LastName, COUNT( fs.salesID || '-' || fs.productID) AS NumberOfSales, SUM(fs.TotalAmount) AS TotalSales -- Since we don't have a unique identifier for sales, we concatenate the salesID and productID (in my case both of them composite key)
FROM star.FactSales fs
         JOIN star.DimEmployee e ON fs.EmployeeID = e.EmployeeID
GROUP BY e.FirstName, e.LastName
ORDER BY TotalSales DESC;

-- Customer Sales Overview
SELECT cu.CompanyName, SUM(fs.TotalAmount) AS TotalSpent, COUNT( DISTINCT fs.salesID || '-' || fs.productID) AS TransactionsCount
FROM star.FactSales fs
         JOIN star.DimCustomer cu ON fs.CustomerID = cu.CustomerID
GROUP BY cu.CompanyName
ORDER BY TotalSpent DESC;

-- Monthly Sales Growth Rate
WITH MonthlySales AS (
    SELECT
        d.Year,
        d.Month,
        SUM(fs.TotalAmount) AS TotalSales
    FROM star.FactSales fs
             JOIN star.DimDate d ON fs.DateID = d.DateID
    GROUP BY d.Year, d.Month
),
     MonthlyGrowth AS (
         SELECT
             Year,
             Month,
             TotalSales,
             LAG(TotalSales) OVER (ORDER BY Year, Month) AS PreviousMonthSales,
             (TotalSales - LAG(TotalSales) OVER (ORDER BY Year, Month)) / LAG(TotalSales) OVER (ORDER BY Year, Month) AS GrowthRate
         FROM MonthlySales
     )
SELECT * FROM MonthlyGrowth;
