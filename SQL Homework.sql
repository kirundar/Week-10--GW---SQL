
USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER (CONCAT(first_name,' ', last_name)) AS 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor,of whom you know only the first name, "Joe."
   -- What is one query would you use to obtain this information?
   
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';
   
-- 2b. Find all actors whose last name contain the letters GEN:

SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT actor_id, last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name ASC;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country
FROM country
WHERE country IN('Afghanistan','Bangladesh','China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.

ALTER TABLE actor
ADD middle_name VARCHAR(30)
AFTER first_name;


-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor
MODIFY COLUMN middle_name BLOB;
SELECT * FROM actor
LIMIT 10;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor
DROP middle_name;
SELECT * FROM actor
LIMIT 10;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name) AS '# of Actors with Last Name'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, 
	COUNT(last_name) AS '# of Actors with Last Name'
FROM actor
WHERE '# of Actors with Last Name' > 2
GROUP BY last_name;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE actor
SET first_name='HARPO'
WHERE first_name='GROUCHO'AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)


SELECT * FROM actor;

UPDATE actor
IF first_name = 'HARPO' THEN SET first_name='GROUCHO'
	[ELSEIF first_name = 'GROUCHO' THEN SET first_name='MUCHO GROUCHO']	
END IF;

 
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

CREATE SCHEMA test;
CREATE TABLE address(
address_id INTEGER (10),
address VARCHAR(30),
address2 VARCHAR(30),
district VARCHAR(30),
city_id INTEGER (10),
postal_code INTEGER (10),
phone INTEGER (10),
location BLOB,
last_update INTEGER
);


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT first_name, last_name, address
FROM staff INNER JOIN address
ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT * FROM payment;
SELECT * FROM staff;
																																																																																																																																																																																																																																																																																																																																																																																																
SELECT staff_id,  SUM(amount)
FROM payment
GROUP BY staff_id;


SELECT first_name, last_name, sum_amount AS 'Total Amount', payment_date
FROM staff a INNER JOIN(
	SELECT staff_id, SUM(amount) AS sum_amount , payment_date
	FROM payment
   GROUP BY staff_id, payment_date) b
ON a.staff_id = b.staff_id
WHERE payment_date LIKE '%2005-08%';

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT * FROM film_actor;
SELECT * FROM film;
						
SELECT  film_id,COUNT(actor_id) AS num_actor
FROM film_actor
GROUP BY film_id;

SELECT title, num_actor AS 'Number of Actors'
FROM film a INNER JOIN (
	SELECT film_id,COUNT(actor_id) AS num_actor
	FROM film_actor 
	GROUP BY film_id) b
ON a.film_id = b.film_id
ORDER BY title ASC;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?


SELECT * FROM inventory;
SELECT * FROM film;

SELECT  film_id,COUNT(inventory_id) AS num_copies
FROM inventory
GROUP BY film_id;

SELECT title, num_copies AS 'Number of Copies'
FROM film a INNER JOIN (
	SELECT  film_id,COUNT(inventory_id) AS num_copies
	FROM inventory
	GROUP BY film_id) b
ON a.film_id = b.film_id
WHERE title = 'HUNCHBACK IMPOSSIBLE';



-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT * FROM payment;
SELECT * FROM customer;

SELECT  customer_id,SUM(amount) AS sum_amount
FROM payment
GROUP BY customer_id;

SELECT last_name, first_name, sum_amount AS 'Total Paid'
FROM customer a INNER JOIN (
	SELECT  customer_id,SUM(amount) AS sum_amount
	FROM payment
	GROUP BY customer_id) b
ON a.customer_id = b.customer_id
ORDER BY last_name ASC;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
	-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
	-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT * FROM film;
SELECT * FROM sakila.language;

SELECT title, name
FROM film a INNER JOIN (
	SELECT language_id, name
	FROM sakila.language
	WHERE name = 'English') b
ON a.language_id = b.language_id
WHERE title LIKE 'K%' OR'Q%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT * FROM film;
SELECT * FROM film_actor;
SELECT * FROM actor;

SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
	FROM film_actor
	WHERE film_id IN (
		SELECT film_id
		FROM FILM
		WHERE title = 'ALONE TRIP'));


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
	-- Use joins to retrieve this information.

SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;


SELECT 
    a.last_name, /* TableA.nameA */
    a.first_name,/* TableD.nameD */
	b.address, /* TableA.nameA */
    b.district,/* TableD.nameD */
	b.postal_code, /* TableA.nameA */
    b.district,/* TableD.nameD */
    d.country
FROM customer a 
    INNER JOIN address b on b.address_id = a.address_id 
    INNER JOIN city c on c.city_id= b.city_id
    INNER JOIN country d on d.country_id= c.country_id
WHERE country = 'Canada';


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
	-- Identify all movies categorized as family films.
 
SELECT * FROM film;
SELECT * FROM film_category;
SELECT * FROM category;

SELECT 
    a.title, /* TableA.nameA */
    c.name/* TableD.nameD */
FROM film a 
    INNER JOIN film_category b on b.film_id = a.film_id 
    INNER JOIN category c on c.category_id= b.category_id
WHERE name = 'Family';

    
-- 7e. Display the most frequently rented movies in descending order.

SELECT * FROM film;

SELECT 
    a.title AS 'Title',
    a.rental_duration AS 'Frequently Revented Movies'
FROM film a 
ORDER BY rental_duration DESC;


SELECT 
    a.title AS 'Title',
    MAX(a.rental_duration) AS 'Frequently Revented Movies'
FROM film a 
GROUP BY a.title
ORDER BY title DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT * FROM store;
SELECT * FROM rental;
SELECT * FROM payment;
SELECT * FROM inventory;


SELECT payment_id, amount AS 'Total Business ($)'
FROM payment a 
    INNER JOIN rental b on b.rental_id = a.rental_id 
    INNER JOIN inventory c on c.inventory_id= b.inventory_id
    INNER JOIN store d on d.store_id= c.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT * FROM store;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

SELECT 
    a.store_id, 
	b.address, 
    b.district,
	b.postal_code, 
    b.district,
    d.country
FROM store a 
    INNER JOIN address b on b.address_id = a.address_id 
    INNER JOIN city c on c.city_id= b.city_id
    INNER JOIN country d on d.country_id= c.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
	-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM inventory; 
SELECT * FROM rental;
SELECT * FROM payment;


SELECT
	a.category_id,
    a.name,
	SUM(e.amount) AS 'Gross Revenue ($)'
FROM category a 
    INNER JOIN film_category b on b.category_id = a.category_id 
    INNER JOIN inventory c on c.film_id= b.film_id
    INNER JOIN rental d on d.inventory_id= c.inventory_id
    INNER JOIN payment e on e.rental_id= d.rental_id
GROUP BY category_id, name
ORDER BY 'Gross Revenue' DESC
LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
	-- Use the solution from the problem above to create a view. 
	-- If you haven't solved 7h, you can substitute another query to create a view.
    
CREATE VIEW Top_5_Genres AS 
	SELECT
		a.category_id,
		a.name,
		SUM(e.amount) AS 'Gross Revenue ($)'
	FROM category a 
		INNER JOIN film_category b on b.category_id = a.category_id 
		INNER JOIN inventory c on c.film_id= b.film_id
		INNER JOIN rental d on d.inventory_id= c.inventory_id
		INNER JOIN payment e on e.rental_id= d.rental_id
	GROUP BY category_id, name
	ORDER BY 'Gross Revenue' DESC
	LIMIT 5;

    
-- 8b. How would you display the view that you created in 8a?

SELECT * FROM Top_5_Genres;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW Top_5_Genres;