📌 Overview

This repository contains my solution for Hevo’s Assessment II – Post-Load Cleaning & Hevo Models.
The objective was to work with messy e-commerce data loaded from PostgreSQL into Snowflake, and then clean, standardize, and model it using Hevo Models to produce a final analytics-ready dataset.

🛠️ Task Summary

The assessment involved four main steps:

1️⃣ PostgreSQL Setup

Created a new PostgreSQL instance using Docker (port: 5432).

Created the required raw tables:

customers_raw

orders_raw

products_raw

country_dim

Inserted the messy data exactly as provided in the assessment.

2️⃣ Hevo Pipeline Setup

Exposed local PostgreSQL using LocalToNet TCP tunneling.

Connected PostgreSQL to Hevo using Logical Replication.

Configured destination using Snowflake Partner Connect.

Loaded all raw tables into Snowflake with prefix: HEVOA2_.

3️⃣ Data Cleaning Using Hevo Models

Created three transformation models for cleaning:

🧩 MODEL 1 — CLEAN_CUSTOMERS
Tasks Completed

✔ Deduplicated customers (kept most recent using ROW_NUMBER()).
✔ Standardized email → lowercase.
✔ Cleaned phone numbers → extracted digits → validated 10-digit → else “Unknown”.
✔ Normalized country codes using country_dim.
✔ Replaced missing created_at with '1900-01-01'.
✔ Marked customers with all NULL values as "Invalid Customer".

Output Table

CLEAN_CUSTOMERS

🧩 MODEL 2 — CLEAN_ORDERS
Tasks Completed

✔ Removed exact duplicate order rows.
✔ Negative amounts → replaced with 0.
✔ NULL amounts → replaced with median per customer (fallback = 0).
✔ Standardized currency → uppercase (usd → USD).
✔ Converted all currencies into USD → created amount_usd.
✔ Preserved orphaned customer rows for final join.

Output Table

CLEAN_ORDERS

🧩 MODEL 3 — CLEAN_PRODUCTS
Tasks Completed

✔ Product names standardized to Title Case.
✔ Categories standardized to Title Case.
✔ Products with active_flag = 'N' → marked "Discontinued Product".
✔ Added placeholders for missing values.

Output Table

CLEAN_PRODUCTS

🧩 MODEL 4 — JOIN the resultants (Joined Table)

Joined together:

CLEAN_CUSTOMERS

CLEAN_ORDERS

CLEAN_PRODUCTS

Handled all edge cases:

✔ Orphan customers

customer_email = "Orphan Customer"

✔ Invalid products

product_name = "Unknown Product"

✔ Missing fields

Filled using consistent placeholders:

"Unknown"

"Invalid Customer"

"Unknown Product"

✔ Mixed currency handling

All final rows contain a consistent USD value via amount_usd.

Final Output Columns
ORDER_ID  
CUSTOMER_ID  
PRODUCT_ID  
AMOUNT_FINAL  
AMOUNT_USD  
CURRENCY_STD  
CREATED_AT  
CUSTOMER_EMAIL  
CUSTOMER_PHONE  
CUSTOMER_COUNTRY  
CUSTOMER_STATUS  
PRODUCT_NAME  
PRODUCT_CATEGORY  
PRODUCT_STATUS

Output Table

FINAL_TABLE

🧪 Validation Queries (Snowflake)
Verify row counts:
SELECT COUNT(*) FROM HEVOA2_CUSTOMERS_RAW;
SELECT COUNT(*) FROM CLEAN_CUSTOMERS;

SELECT COUNT(*) FROM HEVOA2_ORDERS_RAW;
SELECT COUNT(*) FROM CLEAN_ORDERS;

SELECT COUNT(*) FROM HEVOA2_PRODUCTS_RAW;
SELECT COUNT(*) FROM CLEAN_PRODUCTS;

Check invalid customers:
SELECT * FROM CLEAN_CUSTOMERS WHERE status = 'Invalid Customer';

Verify orphan orders:
SELECT *
FROM FINAL_DATASET
WHERE customer_email = 'Orphan Customer';

Verify unknown products:
SELECT *
FROM FINAL_DATASET
WHERE product_name = 'Unknown Product';

🎥 Loom Video Link

➡️ “[Loom Video: https://www.loom.com/…](https://www.loom.com/share/487e2f9dacf7448db7390522facf4eb5)”

📬 Submission Details

Hevo Account Team Name: gmail.com_187 (workspace name)

Pipeline Number: 3

Model Numbers:

Model 3: CLEAN CUSTOMERS

Model 4: CLEAN ORDERS

Model 5: CLEAN PRODUCTS

Model 6: JOIN the resultants# Hevo_Assignment_2_CXE
