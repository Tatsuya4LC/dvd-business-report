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
