WITH cleaned AS (
    SELECT
        customer_id,
        LOWER(email) AS email,
        CASE 
            WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) = 10
                THEN REGEXP_REPLACE(phone, '[^0-9]', '')
            ELSE 'Unknown'
        END AS phone,
        LOWER(country_code) AS country_raw,
        COALESCE(created_at, '1900-01-01'::timestamp) AS created_at,
        updated_at
    FROM HEVOA2_CUSTOMERS_RAW
),

dedup AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY updated_at DESC) AS rn
    FROM cleaned
),

with_country AS (
    SELECT 
        d.customer_id,
        d.email,
        d.phone,
        COALESCE(cd.iso_code, 'Unknown') AS country_code,
        d.created_at,
        d.updated_at
    FROM dedup d
    LEFT JOIN HEVOA2_COUNTRY_DIM cd
        ON LOWER(d.country_raw) IN (LOWER(cd.country_name), LOWER(cd.iso_code))
    WHERE rn = 1
)

SELECT *,
    CASE 
        WHEN email IS NULL AND phone = 'Unknown' AND country_code = 'Unknown'
            THEN 'Invalid Customer'
        ELSE 'Valid'
    END AS status
FROM with_country