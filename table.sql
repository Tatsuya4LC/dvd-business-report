DROP TABLE IF EXISTS customer_detail;

CREATE TABLE customer_detail (
customer_id INT,
name VARCHAR(25),
times_rented SMALLINT,
spent_on_genre NUMERIC(5,2));

DROP TABLE IF EXISTS customer_summary;

CREATE TABLE customer_summary (
total_spent NUMERIC(5,2),
full_name VARCHAR(255),
preferred_genre VARCHAR(255),
amount_spent NUMERIC(5,2),
email VARCHAR(50),
address VARCHAR(50),
address2 VARCHAR(50),
city VARCHAR(50),
postal_code VARCHAR(10),
country VARCHAR(50));
