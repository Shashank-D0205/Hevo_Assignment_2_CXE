WITH orders AS (
    SELECT *
    FROM CLEAN_ORDERS
),
customers AS (
    SELECT 
        customer_id,
        email AS customer_email,
        phone AS customer_phone,
        country_code AS customer_country,
        status AS customer_status
    FROM CLEAN_CUSTOMERS
),
products AS (
    SELECT
        product_id,
        product_name,
        category,
        product_status
    FROM CLEAN_PRODUCTS
)

SELECT

    o.order_id,
    o.customer_id,
    o.product_id,
    o.amount_final,
    o.amount_usd,
    o.currency_std,
    o.created_at,

    COALESCE(c.customer_email, 'Orphan Customer') AS customer_email,
    COALESCE(c.customer_phone, 'Unknown') AS customer_phone,
    COALESCE(c.customer_country, 'Unknown') AS customer_country,
    COALESCE(c.customer_status, 'Invalid Customer') AS customer_status,

    COALESCE(p.product_name, 'Unknown Product') AS product_name,
    COALESCE(p.category, 'Unknown Category') AS product_category,
    COALESCE(p.product_status, 'Unknown Status') AS product_status

FROM orders o
LEFT JOIN customers c USING (customer_id)
LEFT JOIN products p USING (product_id)