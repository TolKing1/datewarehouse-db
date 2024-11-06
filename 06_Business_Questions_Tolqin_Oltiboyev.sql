-- Query to calculate average sales and rolling averages

-- 1) Display average sales (total amount, net amount, tax; number of transactions),
-- the rolling average for three months (January–February; January–February–March; February–March–April)
-- per day (specifying the month and date range) across all product categories (selected category, list of categories)
-- in geographical sections (regions, countries, states), in gender sections (men, women),
-- by age group (0–18, 19–28, 28–45, 45–60, 60+), by income (0–20000, 20001–40000, 40001–60000, 60001–80000, 80001-100000).
-- This involves querying the FactSales and DimDate tables.
WITH sales_data AS (
    SELECT
        fs.salesID,
        fs.dateID,
        fs.customerID,
        fs.productID,
        fs.employeeID,
        fs.categoryID,
        fs.shipperID,
        fs.supplierID,
        fs.quantitySold,
        fs.unitPrice,
        fs.discount,
        fs.totalAmount,
        fs.taxAmount,
        dd.date,
        dd.month,
        dd.year,
        dd.quarter,
        dd.weekOfYear,
        dc.region,
        dc.country,
        dc.city
    FROM
        star.factSales fs
            JOIN
        star.dimDate dd ON fs.dateID = dd.dateID
            JOIN
        star.dimCustomer dc ON fs.customerID = dc.customerID
),
     aggregated_data AS (
         SELECT
             date,
             month,
             year,
             region,
             country,
             city,
             COUNT(*) AS num_transactions,
             AVG(totalAmount) AS avg_total_amount,
             AVG(totalAmount - taxAmount) AS avg_net_amount,
             AVG(taxAmount) AS avg_tax_amount
         FROM
             sales_data
         GROUP BY
             date, month, year, region, country, city
     ),
     rolling_avg AS (
         SELECT
             date,
             month,
             year,
             region,
             country,
             city,
             num_transactions,
             avg_total_amount,
             avg_net_amount,
             avg_tax_amount,
             AVG(avg_total_amount) OVER (PARTITION BY region, country, city ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_3_months
         FROM
             aggregated_data
     )
SELECT
    date,
    month,
    year,
    region,
    country,
    city,
    num_transactions,
    avg_total_amount,
    avg_net_amount,
    avg_tax_amount,
    rolling_avg_3_months
FROM
    rolling_avg
ORDER BY
    date, region, country, city;


-- So strange and unclear that we dont have any columns income, gender and age in customers table, So I tried my best

-- 2)Display the top (worst) five products by number of transactions, total sales, and tax (add category section).
--   This involves querying the FactSales table.
-- Top 5 Products by Transactions Count
SELECT fs.productID,
       dp.productName,
       COUNT(fs.salesID) AS transactionsCount
FROM star.factSales fs
         JOIN
     star.dimProduct dp ON fs.productID = dp.productID
GROUP BY fs.productID, dp.productName
ORDER BY transactionsCount DESC
LIMIT 5;

-- Worst 5 Products by Transactions Count
SELECT fs.productID,
       dp.productName,
       COUNT(fs.salesID) AS transactionsCount
FROM star.factSales fs
         JOIN
     star.dimProduct dp ON fs.productID = dp.productID
GROUP BY fs.productID, dp.productName
ORDER BY transactionsCount
LIMIT 5;

-- Top 5 Products by Total Sales
SELECT p.productName,
       SUM(f.totalAmount) AS totalSales
FROM star.factSales f
         JOIN star.dimProduct p ON f.productID = p.productID
GROUP BY p.productName
ORDER BY totalSales DESC
LIMIT 5;

-- Worst 5 Products by Total Sales
SELECT p.productName,
       SUM(f.totalAmount) AS totalSales
FROM star.factSales f
         JOIN star.dimProduct p ON f.productID = p.productID
GROUP BY p.productName
ORDER BY totalSales
LIMIT 5;

-- Top 5 Products by Tax
SELECT p.productName,
       SUM(f.taxAmount) AS totalTax
FROM star.factSales f
         JOIN star.dimProduct p ON f.productID = p.productID
GROUP BY p.productName
ORDER BY totalTax DESC
LIMIT 5;

-- Worst 5 Products by Tax
SELECT p.productName,
       SUM(f.taxAmount) AS totalTax
FROM star.factSales f
         JOIN star.dimProduct p ON f.productID = p.productID
GROUP BY p.productName
ORDER BY totalTax
LIMIT 5;

-- Ambiguous question, That's why I created multiple queries for each case

-- 3)Display the top (worst) five customers by number of transactions and purchase amount (add gender section, region, country, product categories, age group).
--  This involves querying the FactSales table.

-- Top 5 Customers by Number of Transactions
WITH FilteredCustomers AS (SELECT c.contactname,
                                  c.region,
                                  c.country,
                                  p.categoryID,
                                  COUNT(f.salesID)   AS numTransactions,
                                  SUM(f.totalAmount) AS totalPurchaseAmount
                           FROM star.factSales f
                                    JOIN star.dimCustomer c ON f.customerID = c.customerID
                                    JOIN star.dimProduct p ON f.productID = p.productID
                           WHERE c.region IS NULL       -- Change for region filter (Well since all customers region are null, we will get 0 results. That's why I will use IS NULL)
                             AND c.country = 'UK'       -- Change for country filter
                             AND p.categoryID IN (2, 3) -- Change for category filter
                           GROUP BY c.customerID, c.contactname, c.region, c.country, p.categoryID)
SELECT contactname,
       totalPurchaseAmount,
       numTransactions
FROM FilteredCustomers
ORDER BY totalPurchaseAmount DESC, numTransactions DESC
LIMIT 5;

-- Worst 5 Customers by Number of Transactions
WITH FilteredCustomers AS (SELECT c.contactname,
                                  c.region,
                                  c.country,
                                  p.categoryID,
                                  COUNT(f.salesID)   AS numTransactions,
                                  SUM(f.totalAmount) AS totalPurchaseAmount
                           FROM star.factSales f
                                    JOIN star.dimCustomer c ON f.customerID = c.customerID
                                    JOIN star.dimProduct p ON f.productID = p.productID
                           WHERE c.region IS NULL       -- Change for region filter (Well since all customers region are null, we will get 0 results. That's why I will use IS NULL)
                             AND c.country = 'UK'       -- Change for country filter
                             AND p.categoryID IN (2, 3) -- Change for category filter
                           GROUP BY c.customerID, c.contactname, c.region, c.country, p.categoryID)
SELECT contactname,
       totalPurchaseAmount,
       numTransactions
FROM FilteredCustomers
ORDER BY totalPurchaseAmount, numTransactions
LIMIT 5;

-- And again... we don't have gender and age columns in customers table, so I will use region, country, and category filters

-- 4) Display a sales chart (with the total amount of sales and the quantity of items sold) for the first week of each month.
--      This involves querying the FactSales and DimDate tables.

SELECT d.month,
       d.year,
       SUM(f.totalAmount)  AS totalSales,
       SUM(f.quantitySold) AS totalQuantitySold
FROM star.factSales f
         JOIN star.dimDate d ON f.dateID = d.dateID
WHERE d.day <= 7
GROUP BY d.month, d.year
ORDER BY d.month;

-- 5) Display a weekly sales report (with monthly totals) by product category (period: one year).
--    This involves querying the FactSales, DimDate, and DimProduct tables.

SELECT p.categoryID,
       d.year,
       d.month,
       d.weekOfYear,
       SUM(f.totalAmount)  AS totalSales,
       SUM(f.quantitySold) AS totalQuantitySold
FROM star.factSales f
         JOIN star.dimDate d ON f.dateID = d.dateID
         JOIN star.dimProduct p ON f.productID = p.productID
WHERE d.year = 2012-- or specify the desired year
GROUP BY p.categoryID,
         d.year,
         d.month,
         d.weekOfYear
ORDER BY p.categoryID,
         d.year,
         d.month,
         d.weekOfYear;

-- 6) Display the median monthly sales value by product category and country.
--      This involves querying the FactSales, DimProduct, and DimCustomer tables and requires a more complex query or a custom function to calculate the median.
WITH MonthlySales AS (SELECT p.categoryID,
                             c.country,
                             d.year,
                             d.month,
                             SUM(f.totalAmount) AS totalSales
                      FROM star.factSales f
                               JOIN star.dimDate d ON f.dateID = d.dateID
                               JOIN star.dimProduct p ON f.productID = p.productID
                               JOIN star.dimCustomer c ON f.customerID = c.customerID
                      GROUP BY p.categoryID,
                               c.country,
                               d.year,
                               d.month),
     RankedSales AS (SELECT categoryID,
                            country,
                            year,
                            month,
                            totalSales,
                            ROW_NUMBER()
                            OVER (PARTITION BY categoryID, country, year, month ORDER BY totalSales) AS row_num,
                            COUNT(*) OVER (PARTITION BY categoryID, country, year, month)            AS total_count
                     FROM MonthlySales)
SELECT categoryID,
       country,
       year,
       month,
       AVG(totalSales) AS median_sales
FROM RankedSales
WHERE row_num IN (FLOOR((total_count + 1) / 2.0), CEIL((total_count + 1) / 2.0))
GROUP BY categoryID,
         country,
         year,
         month
ORDER BY categoryID,
         country,
         year,
         month;

-- 7) Display sales rankings by product category (with the best-selling categories at the top).
-- This involves querying the FactSales and DimProduct tables.
SELECT
    f.categoryid,
    SUM(f.totalAmount) AS totalSales,
    RANK() OVER (ORDER BY SUM(f.totalAmount) DESC) AS salesRank
FROM
    star.factSales f
        JOIN star.dimProduct p ON f.productID = p.productID
GROUP BY
    f.categoryID
ORDER BY
    salesRank;
