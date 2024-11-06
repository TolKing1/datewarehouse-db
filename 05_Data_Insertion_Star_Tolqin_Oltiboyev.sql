INSERT INTO star.dimCustomer (customerID, companyName, contactName, contactTitle, address, city, region, postalCode, country, phone)
SELECT customerID, companyName, contactName, contactTitle, address, city, region, postalCode, country, phone
FROM staging.stagingCustomers;

INSERT INTO star.dimEmployee (employeeID, lastName, firstName, title, birthDate, hireDate, address, city, region, postalCode, country, homePhone, extension)
SELECT employeeID, lastName, firstName, title, birthDate, hireDate, address, city, region, postalCode, country, homePhone, extension
FROM staging.stagingEmployees;

INSERT INTO star.dimCategory (categoryID, categoryName, description)
SELECT categoryID, categoryName, description
FROM staging.stagingCategories;

INSERT INTO star.dimShipper (shipperID, companyName, phone)
SELECT shipperID, companyName, phone
FROM staging.stagingShippers;

INSERT INTO star.dimSupplier (supplierID, companyName, contactName, contactTitle, address, city, region, postalCode, country, phone)
SELECT supplierID, companyName, contactName, contactTitle, address, city, region, postalCode, country, phone
FROM staging.stagingSuppliers;

INSERT INTO star.dimProduct (productID, productName, supplierID, categoryID, quantityPerUnit, unitPrice, unitsInStock)
SELECT productID, productName, supplierID, categoryID, quantityPerUnit, unitPrice, unitsInStock
FROM staging.stagingProducts;

DO $$
    DECLARE
        rec RECORD;
    BEGIN
        FOR rec IN
            (SELECT orderDate AS date FROM staging.stagingOrders
             WHERE orderDate IS NOT NULL)
            LOOP
                IF NOT EXISTS (SELECT 1 FROM star.dimDate WHERE date = rec.date) THEN
                    INSERT INTO star.dimDate (date, day, month, year, quarter, weekOfYear)
                    VALUES (
                               rec.date,
                               EXTRACT(DAY FROM rec.date),
                               EXTRACT(MONTH FROM rec.date),
                               EXTRACT(YEAR FROM rec.date),
                               EXTRACT(QUARTER FROM rec.date),
                               EXTRACT(WEEK FROM rec.date)
                           );
                END IF;
            END LOOP;
    END $$;


-- Load data into factSales
INSERT INTO star.factSales
(
    salesid, dateID, customerID, productID, employeeID, categoryID, shipperID, supplierID, quantitySold, unitPrice, discount, taxAmount
)
SELECT
    o.orderID,
    d.dateID,
    c.customerID,
    p.productID,
    e.employeeID,
    cat.categoryID,
    s.shipperID,
    sup.supplierID,
    od.quantity,
    od.unitPrice,
    od.discount,
    (od.quantity * od.unitPrice - od.discount) * 0.1 AS taxAmount
FROM staging.stagingOrderDetails od
         JOIN staging.stagingOrders o ON od.orderID = o.orderID
         JOIN staging.stagingCustomers c ON o.customerID = c.customerID
         JOIN staging.stagingProducts p ON od.productID = p.productID
         LEFT JOIN staging.stagingEmployees e ON o.employeeID = e.employeeID
         LEFT JOIN staging.stagingCategories cat ON p.categoryID = cat.categoryID
         LEFT JOIN staging.stagingShippers s ON o.shipVia = s.shipperID
         LEFT JOIN staging.stagingSuppliers sup ON p.supplierID = sup.supplierID
         LEFT JOIN star.dimDate d ON o.orderDate = d.date;