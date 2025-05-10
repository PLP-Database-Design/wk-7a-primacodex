-- QUESTION 1
-- Query to transform the ProductDetail table to achieve 1NF

-- Create a temporary table to hold the intermediate results
CREATE TEMPORARY TABLE NormalizedProductDetail AS
SELECT
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n), ',', -1)) AS Product
FROM
    ProductDetail
CROSS JOIN
    (
        -- This subquery generates a sequence of numbers (1, 2, 3, ...)
        -- up to the maximum number of products in a single order.
        -- The actual maximum might need to be adjusted based on your data.
        SELECT 1 AS n UNION ALL
        SELECT 2 UNION ALL
        SELECT 3
    ) AS numbers
ON
    LENGTH(Products) - LENGTH(REPLACE(Products, ',', '')) >= numbers.n - 1;

-- Select all columns from the normalized temporary table
SELECT OrderID, CustomerName, Product
FROM NormalizedProductDetail;

-- Drop the temporary table (optional, depends on the SQL environment)
DROP TEMPORARY TABLE IF EXISTS NormalizedProductDetail;



-- QUESTION 2
-- Query to transform the OrderDetails table to achieve 2NF

-- Create a new table for Customer information
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT, -- Assuming a new primary key for Customers
    CustomerName VARCHAR(255) NOT NULL
);

-- Insert distinct customer names into the Customers table
INSERT INTO Customers (CustomerName)
SELECT DISTINCT CustomerName
FROM OrderDetails;

-- Create a new table for Order information with CustomerID
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Insert order information into the Orders table
INSERT INTO Orders (OrderID, CustomerID)
SELECT DISTINCT od.OrderID, c.CustomerID
FROM OrderDetails od
JOIN Customers c ON od.CustomerName = c.CustomerName;

-- Create a new table for Order Items (linking Orders and Products)
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    Product VARCHAR(255) NOT NULL,
    Quantity INT NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Insert order item details into the OrderItems table
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;

-- Display the newly created tables in 2NF
SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM OrderItems;

