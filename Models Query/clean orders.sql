WITH base AS (
    SELECT
        order_id,
        customer_id,
        product_id,
        amount,
        created_at,
        UPPER(currency) AS currency_std
    FROM HEVOA2_ORDERS_RAW
),
dedup AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id, customer_id, product_id, amount, currency_std 
            ORDER BY created_at DESC
        ) AS rn
    FROM base
),
unique_orders AS (
    SELECT *
    FROM dedup
    WHERE rn = 1
),
amount_fixed AS (
    SELECT
        order_id,
        customer_id,
        product_id,
        CASE 
            WHEN amount < 0 THEN 0
            WHEN amount IS NULL THEN NULL  
            ELSE amount
        END AS amount_cleaned,
        created_at,
        currency_std
    FROM unique_orders
),
median_amounts AS (
    SELECT
        customer_id,
        MEDIAN(amount_cleaned) AS median_amount
    FROM amount_fixed
    WHERE amount_cleaned IS NOT NULL
    GROUP BY customer_id
),
amount_final AS (
    SELECT
        a.order_id,
        a.customer_id,
        a.product_id,
        COALESCE(a.amount_cleaned, m.median_amount, 0) AS amount_final,
        a.created_at,
        a.currency_std
    FROM amount_fixed a
    LEFT JOIN median_amounts m USING (customer_id)
),usd_converted AS (
    SELECT
        order_id,
        customer_id,
        product_id,
        amount_final,
        currency_std,
        created_at,
        CASE 
            WHEN currency_std = 'USD' THEN amount_final
            WHEN currency_std = 'INR' THEN amount_final * 0.012
            WHEN currency_std = 'EUR' THEN amount_final * 1.16
            WHEN currency_std = 'SGD' THEN amount_final * 0.77
            ELSE amount_final  
        END AS amount_usd
    FROM amount_final
)

SELECT *

FROM usd_converted
