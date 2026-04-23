USE sakila;

# Creating a Customer Summary Report
# In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details. 
# The report will be generated using a combination of views, CTEs, and temporary tables.

# Step 1: Create a View
# First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

DROP VIEW IF EXISTS view_rental_summary;

CREATE VIEW view_rental_summary AS
SELECT c.customer_id, 
	CONCAT(c.first_name, ' ',c.last_name) AS customer_name, 
	email, 
	COUNT(rental_id) AS total_number_rentals
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id;

# viewing the view
SELECT * FROM view_rental_summary;

# Step 2: Create a Temporary Table
# Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
# The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

DROP TEMPORARY TABLE IF EXISTS temp_total_paid_cust;

CREATE TEMPORARY TABLE temp_total_paid_cust AS
SELECT p.customer_id, 
	SUM(p.amount) AS total_paid
FROM payment p
INNER JOIN view_rental_summary rs ON p.customer_id = rs.customer_id
GROUP BY p.customer_id;

# viewing the table
SELECT * FROM temp_total_paid_cust;

# Step 3: Create a CTE and the Customer Summary Report
# Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.

WITH cte_customer_summary AS (
	SELECT rs.customer_name,
    rs. email,
    rs.total_number_rentals,
	temp_tp.total_paid
FROM view_rental_summary rs
INNER JOIN temp_total_paid_cust temp_tp ON rs.customer_id = temp_tp.customer_id    
)

SELECT * FROM cte_customer_summary;

# Next, using the CTE, create the query to generate the final customer summary report, which should include: 
# customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH cte_customer_summary AS (
	SELECT rs.customer_name,
    rs. email,
    rs.total_number_rentals,
	temp_tp.total_paid
FROM view_rental_summary rs
INNER JOIN temp_total_paid_cust temp_tp ON rs.customer_id = temp_tp.customer_id    
)

SELECT cte.customer_name,
    cte. email,
    cte.total_number_rentals,
	cte.total_paid AS total_paid,
    ROUND(cte.total_paid / cte.total_number_rentals, 2) AS average_payment_per_rental
    FROM cte_customer_summary cte;
