--a trigger function to run procedure refresh_customer_genre() to accomodate for new data
CREATE OR REPLACE FUNCTION trigger_on_rental_insert()
	RETURNS TRIGGER
		LANGUAGE PLPGSQL
			AS
			$$
			BEGIN
				CALL refresh_customer_genre();
				RETURN NEW;
			END;
			$$;

--a trigger to update for new data when an insert query event acts on the rental table
CREATE TRIGGER new_rental
	AFTER INSERT
	ON rental
	FOR EACH STATEMENT
		EXECUTE PROCEDURE trigger_on_rental_insert();