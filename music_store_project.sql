


CREATE DATABASE IF NOT EXISTS music_store;
USE music_store;


CREATE TABLE employee (
  employee_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  title VARCHAR(150),
  level INT,
  hire_date DATE,
  email VARCHAR(255),
  phone VARCHAR(50)
);

CREATE TABLE customer (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  email VARCHAR(255),
  phone VARCHAR(50),
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100)
);

CREATE TABLE artist (
  artist_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200)
);

CREATE TABLE album (
  album_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255),
  artist_id INT,
  FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);

CREATE TABLE genre (
  genre_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120)
);

CREATE TABLE track (
  track_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255),
  album_id INT,
  genre_id INT,
  milliseconds INT,
  bytes BIGINT,
  unit_price DECIMAL(10,2),
  FOREIGN KEY (album_id) REFERENCES album(album_id),
  FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

CREATE TABLE invoice (
  invoice_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  invoice_date DATETIME,
  billing_address VARCHAR(255),
  billing_city VARCHAR(100),
  billing_state VARCHAR(100),
  billing_country VARCHAR(100),
  billing_postal_code VARCHAR(20),
  total DECIMAL(12,2),
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE TABLE invoice_line (
  invoice_line_id INT AUTO_INCREMENT PRIMARY KEY,
  invoice_id INT,
  track_id INT,
  unit_price DECIMAL(10,2),
  quantity INT,
  FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id),
  FOREIGN KEY (track_id) REFERENCES track(track_id)
);


LOAD DATA LOCAL INFILE '/path/to/customer.csv'
INTO TABLE customer
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES
(first_name, last_name, email, phone, city, state, country);


-- Q1: Most senior employee
SELECT employee_id, first_name, last_name, title, level
FROM employee
ORDER BY level DESC
LIMIT 1;

-- Q2: Countries with most invoices
SELECT billing_country, COUNT(*) AS invoice_count
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC;

-- Q3: Top 3 invoice totals
SELECT invoice_id, customer_id, invoice_date, total
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4: City with highest total invoice amount
SELECT billing_city, SUM(total) AS city_total
FROM invoice
GROUP BY billing_city
ORDER BY city_total DESC
LIMIT 1;

-- Q5: Customer who spent the most
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 1;

-- Q1: Customers who listen to Rock
SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock';

-- Q2: Top 10 Rock artists
SELECT ar.artist_id, ar.name AS artist_name, COUNT(t.track_id) AS rock_track_count
FROM artist ar
JOIN album al ON al.artist_id = ar.artist_id
JOIN track t ON t.album_id = al.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.artist_id, ar.name
ORDER BY rock_track_count DESC
LIMIT 10;

-- Q3: Tracks longer than average length
WITH avg_len AS (
  SELECT AVG(milliseconds) AS avg_ms FROM track
)
SELECT t.track_id, t.name, t.milliseconds
FROM track t
CROSS JOIN avg_len
WHERE t.milliseconds > avg_len.avg_ms
ORDER BY t.milliseconds DESC;


-- Q1: How much each customer spent on each artist
WITH line_amounts AS (
  SELECT il.invoice_id, il.track_id, (il.unit_price * il.quantity) AS line_total
  FROM invoice_line il
),
track_artist AS (
  SELECT t.track_id, al.artist_id
  FROM track t
  JOIN album al ON t.album_id = al.album_id
),
customer_invoices AS (
  SELECT i.invoice_id, i.customer_id
  FROM invoice i
)
SELECT
  c.customer_id,
  c.first_name,
  c.last_name,
  ar.artist_id,
  ar.name AS artist_name,
  SUM(la.line_total) AS total_spent_on_artist
FROM line_amounts la
JOIN track_artist ta ON la.track_id = ta.track_id
JOIN customer_invoices ci ON la.invoice_id = ci.invoice_id
JOIN customer c ON ci.customer_id = c.customer_id
JOIN artist ar ON ta.artist_id = ar.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, ar.artist_id, ar.name
ORDER BY c.customer_id, total_spent_on_artist DESC;

-- Q2: Most popular genre by country
WITH country_genre_counts AS (
  SELECT i.billing_country,
         g.genre_id,
         g.name AS genre_name,
         COUNT(*) AS purchases
  FROM invoice i
  JOIN invoice_line il ON i.invoice_id = il.invoice_id
  JOIN track t ON il.track_id = t.track_id
  JOIN genre g ON t.genre_id = g.genre_id
  GROUP BY i.billing_country, g.genre_id, g.name
),
ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY purchases DESC) AS rn
  FROM country_genre_counts
)
SELECT billing_country, genre_name, purchases
FROM ranked
WHERE rn = 1
ORDER BY billing_country;

-- Q3: Top spending customer per country
WITH cust_country_spend AS (
  SELECT c.customer_id, c.first_name, c.last_name, i.billing_country,
         SUM(i.total) AS total_spent
  FROM customer c
  JOIN invoice i ON c.customer_id = i.customer_id
  GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
),
ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY total_spent DESC) AS rn
  FROM cust_country_spend
)
SELECT billing_country, customer_id, first_name, last_name, total_spent
FROM ranked
WHERE rn = 1
ORDER BY billing_country;


