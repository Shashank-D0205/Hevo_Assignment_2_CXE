WITH base AS (
    SELECT
        product_id,
        INITCAP(product_name) AS product_name_clean,
        INITCAP(category) AS category_clean,
        active_flag
    FROM HEVOA2_PRODUCTS_RAW
),

fix_missing AS (
    SELECT
        product_id,
        COALESCE(product_name_clean, 'Unknown Product') AS product_name,
        COALESCE(category_clean, 'Unknown Category') AS category,
        active_flag
    FROM base
),

status_flagged AS (
    SELECT
        product_id,
        product_name,
        category,
        CASE
            WHEN active_flag = 'N' THEN 'Discontinued Product'
            WHEN active_flag = 'Y' THEN 'Active Product'
            ELSE 'Unknown Status'
        END AS product_status
    FROM fix_missing
)

SELECT *
FROM status_flagged