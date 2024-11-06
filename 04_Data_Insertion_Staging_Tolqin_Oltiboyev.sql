-- Load data into staging tables
INSERT INTO staging.stagingCustomers
SELECT * FROM northwind.customers;

INSERT INTO staging.stagingEmployees
SELECT * FROM northwind.employees;

INSERT INTO staging.stagingCategories
SELECT * FROM northwind.categories;

INSERT INTO staging.stagingShippers
SELECT * FROM northwind.shippers;

INSERT INTO staging.stagingSuppliers
SELECT * FROM northwind.suppliers;

INSERT INTO staging.stagingProducts
SELECT * FROM northwind.products;

INSERT INTO staging.stagingOrders
SELECT * FROM northwind.orders;

INSERT INTO staging.stagingOrderDetails
SELECT * FROM northwind.order_details;