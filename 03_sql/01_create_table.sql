-- =========================
-- CREATING TABLE + DATA IMPORT
-- =========================

-- 1. CREATE TABLE: superstore_orders
CREATE TABLE superstore_orders (
	row_id INT,
	order_id VARCHAR(20),
	order_date DATE,
	ship_date DATE,
	ship_mode VARCHAR(50),
	customer_id VARCHAR(20),
	customer_name VARCHAR(100),
	segment VARCHAR(50),
	country VARCHAR(50),
	city VARCHAR(100),
	state VARCHAR(100),
	postal_code INT,
	region VARCHAR(20),
	product_id VARCHAR(30),
	category VARCHAR(50),
	sub_category VARCHAR(50),
	product_name TEXT,
	sales NUMERIC(10,2),
	quantity INT,
	discount NUMERIC(4,2),
	profit NUMERIC(10,4),
	ship_days INT,
	order_year INT,
	order_month INT,
	order_quarter INT,
	order_year_month VARCHAR(10),
	profit_margin_pct NUMERIC(10,2),
	discount_flag INT
);


-- 2. IMPORT CLEAN CSV INTO TABLE
COPY superstore_orders
FROM 'C:\Program Files\PostgreSQL\18\Superstore_Sales_Analytics\superstore_clean.csv' DELIMITER ',' CSV HEADER;


-- =========================
-- VALIDATION CHECK
-- =========================

-- 1. ROW COUNT CHECK
SELECT COUNT(*) FROM superstore_orders;
-- Result: 9994 (Matches the csv data)

-- 2. PREVIEW DATA
SELECT *
FROM superstore_orders
LIMIT 5;