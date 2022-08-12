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

CREATE TRIGGER run_summary_update
	AFTER INSERT
	ON customer_detail
	FOR EACH STATEMENT
		EXECUTE PROCEDURE summary_update();