-- CREATE TABLE Customer, Orders, Products

CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    segment VARCHAR(50)
);

CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

CREATE TABLE orders (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10),
    product_id VARCHAR(10),
    order_date DATE,
    quantity INT,
    price NUMERIC,
    sales NUMERIC,
    cost NUMERIC,

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Look at in data
SELECT *
FROM customers;

SELECT *
FROM orders;

SELECT *
FROM products;

-- Look at in data number
SELECT count(*)
FROM customers;

SELECT count(*)
FROM orders;

SELECT count(*)
FROM products;

-- SUM Total Sales
SELECT customer_id,
	SUM(sales) AS Total_Sales
FROM orders
GROUP BY customer_id
ORDER BY Total_Sales DESC;


-- TOP products by sales

SELECT product_id,
	SUM(quantity) AS Total_Quantity_Slod
FROM orders
GROUP BY product_id
ORDER BY Total_Quantity_Slod DESC;


-- Recency Frequency Monetary (RFM) Metrics Customers Segment

SELECT customer_id,
	MAX(order_date) AS Last_Purchase,
	CURRENT_DATE - MAX(order_date) AS Recency,
	COUNT(order_id) AS Frequency,
	SUM(sales) AS Monetary
FROM orders
GROUP BY customer_id;

-- Customer Segment (Segment) 

SELECT customer_id,
	MAX(order_date) AS Last_Purchase,
	COUNT(order_id) AS Frequency,
	SUM(sales) AS Monetary,
		CASE
			WHEN SUM(sales) > 8000 AND COUNT(order_id) >12 THEN 'VIP'
			WHEN CURRENT_DATE - MAX(order_date) > 180 THEN 'Churned'
			WHEN COUNT(order_id) BETWEEN 5 AND 12 THEN 'Regular'
			ELSE 'New'
			END AS Customer_Segment
FROM orders
GROUP BY customer_id;


-- Monthly active customers
SELECT 
	DATE_TRUNC('month', order_date) AS Month,
	COUNT(DISTINCT customer_id) AS Active_customer
FROM orders
GROUP BY Month
ORDER BY Month;

-- Retention Rate Query

WITH monthly_customers AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_date) AS month
    FROM orders
),

retention AS (
    SELECT
        m1.month AS current_month,
        COUNT(DISTINCT m1.customer_id) AS customers_this_month,
        COUNT(DISTINCT m2.customer_id) AS retained_customers
    FROM monthly_customers m1
    LEFT JOIN monthly_customers m2
        ON m1.customer_id = m2.customer_id
        AND m2.month = m1.month + INTERVAL '1 month'
    GROUP BY m1.month
)

SELECT *,
    ROUND(retained_customers::numeric / customers_this_month * 100, 2)
    AS retention_rate
FROM retention;



-- Retention + Churn Rate

WITH monthly_customers AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_date) AS month
    FROM orders
),

retention_data AS (
    SELECT
        m1.month AS current_month,

        COUNT(DISTINCT m1.customer_id) AS customers_this_month,

        COUNT(DISTINCT m2.customer_id) AS retained_customers

    FROM monthly_customers m1

    LEFT JOIN monthly_customers m2
        ON m1.customer_id = m2.customer_id
        AND m2.month = m1.month + INTERVAL '1 month'

    GROUP BY m1.month
)

SELECT
    current_month,

    customers_this_month,

    retained_customers,

    (customers_this_month - retained_customers) AS churned_customers,

    ROUND(
        retained_customers::numeric / customers_this_month * 100
    , 2) AS retention_rate_percent,

    ROUND(
        (customers_this_month - retained_customers)::numeric
        / customers_this_month * 100
    , 2) AS churn_rate_percent

FROM retention_data
ORDER BY current_month;












































































































































