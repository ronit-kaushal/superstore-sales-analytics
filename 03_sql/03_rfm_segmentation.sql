-- =========================
-- RFM 1: CUSTOMER LEVEL RFM METRICS
-- =========================

WITH rfm_reference_date AS (
	SELECT MAX(order_date) + 1 AS reference_date FROM superstore_orders
),

rfm AS (
	SELECT
		customer_id,
		customer_name,
		(SELECT reference_date FROM rfm_reference_date) - MAX(order_date) AS recency_days,
		COUNT(DISTINCT order_id) AS frequency,
		ROUND(SUM(sales), 2) AS monetary
	FROM superstore_orders
	GROUP BY customer_id, customer_name
)

SELECT
	customer_id,
	customer_name,
	recency_days,
	frequency,
	monetary
FROM rfm
ORDER BY monetary DESC;
-- Result: RFM table created at customer level.
-- Insight: Lower recency_days = more recent customer; higher frequency/monetary = higher value.
-- Use: This dataset is used for RFM scoring and segmentation.


-- =========================
-- RFM 2: RFM SCORING
-- =========================

WITH rfm_reference_date AS (
	SELECT MAX(order_date) + 1 AS reference_date FROM superstore_orders
),

rfm AS (
	SELECT
		customer_id,
		customer_name,
		(SELECT reference_date FROM rfm_reference_date) - MAX(order_date) AS recency_days,
		COUNT(DISTINCT order_id) AS frequency,
		ROUND(SUM(sales), 2) AS monetary
	FROM superstore_orders
	GROUP BY customer_id, customer_name
),

rfm_scores AS (
	SELECT
		*,
		NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
		NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
		NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
	FROM rfm
)

SELECT
	customer_id,
	customer_name,
	recency_days,
	frequency,
	monetary,
	r_score,
	f_score,
	m_score,
	(r_score + f_score + m_score) AS rfm_total_score
FROM rfm_scores
ORDER BY rfm_total_score DESC, monetary DESC;
-- Result: Customers are scored using NTILE(5) for Recency, Frequency, and Monetary (5 = best).
-- Insight: High RFM scores highlight top customers for retention/upsell, low scores highlight inactive/low-value customers for reactivation campaigns.


-- =========================
-- RFM 3: CUSTOMER SEGMENTATION
-- =========================

WITH rfm_reference_date AS (
	SELECT MAX(order_date) + 1 AS reference_date FROM superstore_orders
),

rfm AS (
	SELECT
		customer_id,
		customer_name,
		(SELECT reference_date FROM rfm_reference_date) - MAX(order_date) AS recency_days,
		COUNT(DISTINCT order_id) AS frequency,
		ROUND(SUM(sales), 2) AS monetary
	FROM superstore_orders
	GROUP BY customer_id, customer_name
),

rfm_scores AS (
	SELECT
		*,
		NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
		NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
		NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
	FROM rfm
),

rfm_segment AS (
	SELECT
		*,
		(r_score + f_score + m_score) AS rfm_total_score,

		CASE
			WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
			WHEN r_score >= 4 AND f_score >= 4 THEN 'Loyal Customers'
			WHEN r_score >= 4 AND m_score >= 4 THEN 'Big Spenders (Recent)'
			WHEN r_score >= 4 THEN 'Recent Customers'
			WHEN r_score <= 2 AND m_score >= 4 THEN 'At Risk (High Value)'
			WHEN r_score <= 2 AND f_score >= 4 THEN 'At Risk (Previously Loyal)'
			WHEN r_score <= 2 THEN 'Lost / Inactive'
			ELSE 'Potential / Average'
		END AS customer_segment
	FROM rfm_scores
)

SELECT
	customer_segment,
	COUNT(*) AS customers,
	ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS customer_share_pct,
	ROUND(AVG(recency_days), 1) AS avg_recency_days,
	ROUND(AVG(frequency), 1) AS avg_frequency,
	ROUND(AVG(monetary), 2) AS avg_monetary,
	ROUND(SUM(monetary), 2) AS total_revenue
FROM rfm_segment
GROUP BY customer_segment
ORDER BY total_revenue DESC;
-- Result: Champions (13% customers) generate the highest revenue (542,553) with low avg recency (25 days), high frequency (9.3) and high spend (5,268).
-- Insight: At Risk (High Value) generates almost similar revenue (512,146) but with very high recency (254 days) - these high-value customers must be reactivated urgently.
-- Insight: Lost/Inactive is the largest group (24.7%) but low value (avg monetary 1,205), so reactivation should focus on high-value lapsed customers first.