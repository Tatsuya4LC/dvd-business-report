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
