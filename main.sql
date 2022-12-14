/* This business report ensures that the company has a proper understanding of the customer
before engaging in Customer Relationship Management */

-- [SECTION B] a detailed table consisting of film genre frequency and total amount spent per film genre
DROP TABLE IF EXISTS customer_detail;

CREATE TABLE customer_detail (
customer_id INT,
name VARCHAR(25),
times_rented SMALLINT, --frequency per film genre
spent_on_genre NUMERIC(5,2)); --cost per film genre

SELECT * FROM customer_detail;

-- [SECTION B] a table consisting of a summary report for targeted interaction towards the customer
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

SELECT * FROM customer_summary;

-- [SECTION C] adding data to the detailed table customer_detail
INSERT INTO customer_detail (
	SELECT rental.customer_id, name, COUNT(name), SUM(amount)
	FROM rental
	INNER JOIN inventory
	ON (rental.inventory_id = inventory.inventory_id)
	INNER JOIN film_category
	ON (inventory.film_ID = film_category.film_id)
	INNER JOIN category
	ON (film_category.category_id = category.category_id)
	INNER JOIN payment
	ON (rental.rental_id = payment.rental_id)
	WHERE payment.customer_id = rental.customer_id
	GROUP BY rental.customer_id, name
	ORDER BY rental.customer_id);

SELECT * FROM customer_detail;

-- [SECTION D] a function to transform frequency data times_rented from customer_detail into preferred_genre, INT to STRING
CREATE OR REPLACE FUNCTION preferred(c_id INT)
    RETURNS TEXT
    LANGUAGE PLPGSQL
    AS
    $$ 
    DECLARE genre VARCHAR(255);
    BEGIN
    	SELECT STRING_AGG(name, ', ') INTO genre
			FROM customer_detail
    		WHERE customer_id = c_id
	    	GROUP BY customer_detail.times_rented
		    ORDER BY times_rented DESC
			LIMIT 1;
		RETURN genre;
	END;
    $$;

-- [SECTION D] a function that transform spent_on_genre from customer_detail into total spent (amount_spent) on preferred_genre
CREATE OR REPLACE FUNCTION spent_genre(c_id INT)
	RETURNS NUMERIC(5,2)
	LANGUAGE PLPGSQL
	AS
	$$
	DECLARE spent NUMERIC(5,2);
	BEGIN
		SELECT SUM(spent_on_genre) INTO spent
			FROM customer_detail
			WHERE customer_id = c_id
			GROUP BY customer_detail.times_rented
			ORDER BY times_rented DESC
			LIMIT 1;
		RETURN spent;
	END;
	$$;

-- [SECTION E] a trigger function that insert data to the customer_summary table
CREATE OR REPLACE FUNCTION summary_update()
	RETURNS TRIGGER
	LANGUAGE PLPGSQL
	AS
	$$
	BEGIN
		INSERT INTO customer_summary (
			SELECT sum(payment.amount) AS total_spent, CONCAT(customer.first_name, ' ', customer.last_name),
				preferred(customer.customer_id), spent_genre(customer.customer_id), customer.email, address.address, address.address2,
				city.city, address.postal_code, country.country
			FROM customer
			INNER JOIN address
			ON (customer.address_id = address.address_id)
			INNER JOIN city
			ON (address.city_id = city.city_id)
			INNER JOIN country
			ON (city.country_id = country.country_id)
			INNER JOIN payment
			ON (customer.customer_id = payment.customer_id)
			GROUP BY customer.customer_id, address.address, address.address2, city.city, address.postal_code, country.country
			ORDER BY total_spent DESC);
			
			RETURN NEW;
		END;
		$$;

-- [SECTION E] a trigger that fires every time there is an INSERT query on the customer_detail table
CREATE TRIGGER run_summary_update
	AFTER INSERT
	ON customer_detail
	FOR EACH STATEMENT
		EXECUTE PROCEDURE summary_update();

SELECT * FROM customer_summary;

-- [SECTION F] a procedure to refresh customer_detail and customer_summary table for new data
--this procedure should be run monthly to prepare for the next month's CRM
-- [SECTION F1] this procedure can be automated with the use of pgAgent that's available for postgreSQL
CREATE OR REPLACE PROCEDURE refresh_customer_detail()
	LANGUAGE PLPGSQL
	AS
	$$
	BEGIN
		TRUNCATE customer_detail;
		TRUNCATE customer_summary;
	
		-- [SECTION C] adding data to the detailed table customer_detail
		INSERT INTO customer_detail (
			SELECT rental.customer_id, name, COUNT(name), SUM(amount)
			FROM rental
			INNER JOIN inventory
			ON (rental.inventory_id = inventory.inventory_id)
			INNER JOIN film_category
			ON (inventory.film_ID = film_category.film_id)
			INNER JOIN category
			ON (film_category.category_id = category.category_id)
			INNER JOIN payment
			ON (rental.rental_id = payment.rental_id)
			WHERE payment.customer_id = rental.customer_id
			GROUP BY rental.customer_id, name
			ORDER BY rental.customer_id);
			
	END;
	$$;

--check if trigger and function are properly working
CALL refresh_customer_detail();

--check
SELECT * FROM customer_detail;
SELECT * FROM customer_summary;
