-- =========================
-- KPI 1: MONTHLY SALES & PROFIT TREND
-- =========================

SELECT
	order_year_month,
	SUM(sales) AS total_sales,
	SUM(profit) AS total_profit,
	ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct,
	COUNT(DISTINCT order_id) AS total_orders,
	COUNT(DISTINCT customer_id) AS total_customers,
	ROUND(AVG(ship_days), 2) AS avg_ship_days
FROM superstore_orders
GROUP BY order_year_month
ORDER BY order_year_month;
-- Result: Data covers 48 months (Jan 2014 to Dec 2017).
-- Insight: Sales peak every year in Q4 (Sep–Dec), with the highest month in Nov-2017.
-- Insight: Jan/Feb are usually slow, and a few months even show losses (Jul-2014, Jan-2015).


-- =========================
-- KPI 2: CATEGORY PERFORMANCE
-- =========================

SELECT
	category,
	SUM(sales) AS total_sales,
	SUM(profit) AS total_profit,
	ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct,
	COUNT(DISTINCT order_id) AS total_orders
FROM superstore_orders
GROUP BY category
ORDER BY total_sales DESC;
-- Result: Technology has the highest Sales (836,154) and Profit (145,455) with 17.40% margin.
-- Insight: Technology is the strongest category, furniture has weak margin (2.49%) despite high sales.


-- =========================
-- KPI 3: SUB-CATEGORY PERFORMANCE
-- =========================

SELECT
	category,
	sub_category,
	SUM(sales) AS total_sales,
	SUM(profit) AS total_profit,
	ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct,
	COUNT(DISTINCT order_id) AS total_orders
FROM superstore_orders
GROUP BY category, sub_category
ORDER BY total_profit DESC;
-- Result: Top profit sub-categories = Copiers (55,618), Phones (44,516), Accessories (41,937).
-- Insight: Copiers and Phones are key profit drivers within Technology.


-- =========================
-- KPI 4: LOSS MAKING SUB-CATEGORIES
-- =========================

SELECT
	category,
	sub_category,
	SUM(sales) AS total_sales,
	SUM(profit) AS total_profit,
	ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM superstore_orders
GROUP BY category, sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;
-- Result: Biggest loss maker = Tables (-17,725), followed by Bookcases (-3,473), Supplies (-1,189).
-- Insight: Furniture losses are mainly coming from Tables.


-- =========================
-- KPI 5: DISCOUNT GROUP ANALYSIS
-- =========================

SELECT
	CASE
		WHEN discount = 0 THEN '0%'
		WHEN discount > 0 AND discount <= 0.10 THEN '0-10%'
		WHEN discount > 0.10 AND discount <= 0.20 THEN '10-20%'
		WHEN discount > 0.20 AND discount <= 0.40 THEN '20-40%'
		ELSE '>40%'
	END AS discount_group,

	CASE
        WHEN discount = 0 THEN 1
        WHEN discount > 0 AND discount <= 0.10 THEN 2
        WHEN discount > 0.10 AND discount <= 0.20 THEN 3
        WHEN discount > 0.20 AND discount <= 0.40 THEN 4
        ELSE 5
    END AS group_order,
	
	COUNT(*) AS total_rows,
	ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM superstore_orders), 2) AS row_share_pct,

	SUM(sales) AS total_sales,
	SUM(profit) AS total_profit,
	ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct,

	SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) AS loss_rows,
	ROUND(100.0 * SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS loss_rate_pct

FROM superstore_orders
GROUP BY discount_group, group_order
ORDER BY group_order;
-- Result: Orders with 0% discount give the best profit margin (29.51%) and 0% loss rate.
-- Insight: Discounts above 20% is highly unprofitable (20–40% margin = -15.30%, loss rate = 90.22%).
-- Insight: Heavy discounting (>40%) is always loss-making (profit margin = -77.40%, loss rate = 100%).


-- =========================
-- KPI 6: HIGH DISCOUNT IMPACT (SUB-CATEGORY)
-- =========================

SELECT
	category,
	sub_category,
	COUNT(*) AS high_discount_rows,
	SUM(sales) AS total_sales,
	SUM(profit) AS total_profit,
	ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM superstore_orders
WHERE discount > 0.20
GROUP BY category, sub_category
ORDER BY total_profit ASC;
-- Result: With discounts >20%, Binders (-38,510), Tables (-30,698), and Machines (-29,555) cause the biggest losses.
-- Insight: High discounting makes multiple sub-categories unprofitable, especially Binders and Furniture (Tables/Bookcases).
-- Insight: Copiers still stay profitable even on high discounts (strong pricing power).