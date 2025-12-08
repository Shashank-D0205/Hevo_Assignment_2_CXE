CREATE TABLE customers_raw (
  customer_id INT,
  email VARCHAR,
  phone VARCHAR,
  country_code VARCHAR,
  updated_at TIMESTAMP,
  created_at TIMESTAMP
);

CREATE TABLE orders_raw (
  order_id INT,
  customer_id INT,
  product_id VARCHAR,
  amount FLOAT,
  created_at TIMESTAMP,
  currency VARCHAR
);
CREATE TABLE products_raw (
  product_id VARCHAR,
  product_name VARCHAR,
  category VARCHAR,
  active_flag VARCHAR
);


CREATE TABLE country_dim (
  country_name VARCHAR,
  iso_code VARCHAR
);
