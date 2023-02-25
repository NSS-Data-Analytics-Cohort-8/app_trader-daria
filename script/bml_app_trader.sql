--looking at the data in each table 
SELECT *
FROM play_store_apps
WHERE rating IS NOT NULL
ORDER BY rating DESC;
--Look at Beacon Baptist Church (my gawd)
SELECT *
FROM app_store_apps
WHERE rating IS NOT NULL
ORDER BY rating DESC;
--columns to keep price, ratings
--app_store_apps - name, size_bytes, currency, price, review_count, rating, content_rating, primary_genre
--play_store_apps - name, category, rating, review_count, size, install_count, type, price, content_rating, genres
SELECT name, CAST(price AS money) AS price, rating, genres, content_rating, review_count 
FROM play_store_apps
UNION ALL
SELECT name, CAST(price AS money)AS price, rating, primary_genre, content_rating, CAST(review_count AS integer)AS review_count
FROM app_store_apps
--Original script above--now on to filtering
SELECT genres, COUNT(*) AS genre_count
FROM (
  SELECT name, CAST(price AS money) AS price, 
	rating, genres, content_rating, review_count 
  FROM play_store_apps
  UNION ALL
  SELECT name, CAST(price AS money) AS price, 
	rating, primary_genre AS genres, content_rating, 
	CAST(review_count AS integer) AS review_count
  FROM app_store_apps
) combined_data
GROUP BY genres
ORDER BY genre_count DESC;
--Genre Count--Games, Entertainment, Education, tools, productivity
SELECT name, CAST(price AS money) AS price, rating, genres, content_rating, review_count 
FROM play_store_apps
UNION ALL
SELECT name, CAST(price AS money)AS price, rating, primary_genre, content_rating, CAST(review_count AS integer)AS review_count
FROM app_store_apps
ORDER BY rating DESC
---Above is all Data Examination efforts--
SELECT p.name, CAST(p.price AS money) AS price, p.rating, p.genres, p.content_rating, p.review_count, a.primary_genre
FROM play_store_apps p
FULL JOIN app_store_apps a ON p.name = a.name
ORDER BY a.review_count DESC

SELECT p.name, CAST(p.price AS money) AS price, p.rating, p.genres, p.content_rating, MAX(p.review_count) AS review_count, a.primary_genre
FROM play_store_apps p
INNER JOIN app_store_apps a ON p.name = a.name
GROUP BY p.name, CAST(p.price AS money), p.rating, p.genres, p.content_rating, a.primary_genre
ORDER BY MAX(p.review_count) DESC;
---combined-----  
SELECT 'play store' AS store, p.name, CAST(p.price AS money) AS price, p.rating
FROM play_store_apps p
WHERE rating IS NOT NULL
UNION
SELECT 'app store' AS store, a.name, CAST(a.price AS money) AS price, a.rating
FROM app_store_apps a
WHERE rating IS NOT NULL
ORDER BY rating DESC, price DESC;
-----this is the basic union-----
SELECT 'play store' AS store, p.name, CAST(p.price AS money) AS price, p.rating
FROM play_store_apps p
WHERE rating IS NOT NULL AND NOT EXISTS (
  SELECT 1
  FROM app_store_apps a
  WHERE a.name = p.name
)
UNION
SELECT 'app store' AS store, a.name, CAST(a.price AS money) AS price, a.rating
FROM app_store_apps a
WHERE rating IS NOT NULL
ORDER BY rating DESC, price DESC;
------------union is not working for me on this project so I am going back the first table I created---------------
SELECT p.name, CAST(p.price AS money) AS price, p.rating, p.genres, p.content_rating, MAX(p.review_count) AS review_count, a.primary_genre
FROM play_store_apps p
INNER JOIN app_store_apps a ON p.name = a.name
GROUP BY p.name, CAST(p.price AS money), p.rating, p.genres, p.content_rating, a.primary_genre
ORDER BY MAX(p.review_count) DESC;
--------------------baseline for beginning-------------------------------------------------------------------------
SELECT p.name, CAST(p.price AS money) AS price, p.rating, p.genres, p.content_rating, MAX(p.review_count) AS review_count, a.primary_genre,
ROUND(FLOOR(CAST(p.price AS money)) * 10000, 0) AS purch_price
FROM play_store_apps p
INNER JOIN app_store_apps a ON p.name = a.name
GROUP BY p.name, CAST(p.price AS money), p.rating, p.genres, p.content_rating, a.primary_genre
ORDER BY MAX(p.review_count) DESC;
----------you cannot use floor with "as money"-----------------------
SELECT p.name, CAST(REPLACE(p.price, '$', '') AS money) AS price, p.rating, p.genres, p.content_rating, MAX(p.review_count) AS review_count, a.primary_genre,
ROUND(CAST(REPLACE(p.price, '$', '') AS numeric) * 10000, 0) AS purch_price
FROM play_store_apps p
INNER JOIN app_store_apps a ON p.name = a.name
GROUP BY p.name, CAST(REPLACE(p.price, '$', '') AS money), p.rating, p.genres, p.content_rating, a.primary_genre, ROUND(CAST(REPLACE(p.price, '$', '') AS numeric) * 10000, 0)
ORDER BY MAX(p.review_count) DESC;
------------after multiple attempts I added a column for purchase price--------------
SELECT p.name, CAST(p.price AS money) AS play_store_price, a.price AS app_store_price, p.rating, p.genres, p.content_rating, MAX(p.review_count) AS review_count, a.primary_genre
FROM play_store_apps p
INNER JOIN app_store_apps a ON p.name = a.name
GROUP BY p.name, CAST(p.price AS money), a.price, p.rating, p.genres, p.content_rating, a.primary_genre
ORDER BY MAX(p.rating) DESC, MAX(p.review_count)DESC;

------------add column to show if the app exists in both stores-----------------------
SELECT p.name, 
       CAST(p.price AS money) AS play_store_price, 
       a.price AS app_store_price, 
       p.rating, 
       p.genres, 
       p.content_rating, 
       MAX(p.review_count) AS review_count, 
       a.primary_genre,
       CASE 
           WHEN EXISTS (SELECT 1 FROM play_store_apps WHERE name = p.name) AND EXISTS (SELECT 1 FROM app_store_apps WHERE name = p.name) THEN 'Y' 
           ELSE 'N' 
       END AS exists_in_both
FROM play_store_apps p
LEFT JOIN app_store_apps a ON p.name = a.name
GROUP BY p.name, CAST(p.price AS money), a.price, p.rating, p.genres, p.content_rating, a.primary_genre, exists_in_both
ORDER BY MAX(p.review_count) DESC;
-------------------you overthought this one------instead you just need results for items only in both stores----
SELECT p.name, CAST(p.price AS money) AS play_store_price, a.price AS app_store_price, p.rating, p.genres, p.content_rating, MAX(p.review_count) AS review_count, a.primary_genre
FROM play_store_apps p
INNER JOIN app_store_apps a ON p.name = a.name
GROUP BY p.name, CAST(p.price AS money), a.price, p.rating, p.genres, p.content_rating, a.primary_genre
ORDER BY MAX(p.review_count) DESC; 

SELECT p.name, CAST(REPLACE(p.price, '$', '') AS money) AS price, p.rating, p.genres, p.content_rating, MAX(p.review_count) AS review_count, a.primary_genre,
ROUND(CAST(REPLACE(p.price, '$', '') AS numeric) * 10000, 0) AS purch_price
FROM play_store_apps p
INNER JOIN app_store_apps a ON p.name = a.name
GROUP BY p.name, CAST(REPLACE(p.price, '$', '') AS money), p.rating, p.genres, p.content_rating, a.primary_genre, ROUND(CAST(REPLACE(p.price, '$', '') AS numeric) * 10000, 0)
ORDER BY MAX(p.rating) DESC;
----------combined the price columns showing the greatest number between the two numbers-------------
SELECT p.name, CAST(p.price AS money) AS play_store_price, a.price AS app_store_price, p.rating, p.genres, p.content_rating, MAX(p.review_count) AS review_count, a.primary_genre
FROM play_store_apps p
INNER JOIN app_store_apps a ON p.name = a.name
GROUP BY p.name, CAST(p.price AS money), a.price, p.rating, p.genres, p.content_rating, a.primary_genre
ORDER BY p.rating DESC, MAX(p.review_count) DESC;
-------i am not getting numerous 4.9 star rated items like my teammates-----what'sdifferent-------------
SELECT p.name AS apps,
       ROUND((a.rating + p.rating) / 2, 1) AS avg_rating,
       SUM(CAST(a.review_count AS int) + p.review_count) AS t_review_count,
       p.price AS play_store_price, 
       a.price AS app_store_price              
FROM play_store_apps AS p
INNER JOIN app_store_apps a ON p.name = a.name
GROUP BY p.name, a.rating, p.rating, p.price, a.price
ORDER BY avg_rating DESC;
-----------------------final base script---------------------------------------------------------------
-- I need to find a way to create a new column called price which compares play_store_price to app_store_price and chooses the highest number and displays it as a whole number rounded to the nearest dollar.
-- Next I need to add a column called purch_price
-- which shows output of price times 10K

-- next I want to add an earnings column
-- ADD
-- proj_lifespan column (
-- net_annual_earns 
-- proj_lifespan*earnings
-- monthly earnings 10K-advertising=9K
-- MINUS purch_price

SELECT p.name AS apps,
       ROUND((a.rating + p.rating) / 2, 1) AS avg_rating,
       SUM(CAST(a.review_count AS int) + p.review_count) AS t_review_count,
       ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), CAST(a.price AS numeric)), 0) AS best_price,
       ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), CAST(a.price AS numeric)), 0)*10000 AS purch_price,
	   p.genres
FROM play_store_apps AS p
INNER JOIN app_store_apps a ON p.name = a.name
GROUP BY p.name, a.rating, p.rating, p.price, a.price, p.genres
ORDER BY avg_rating DESC, t_review_count DESC;
---------------------next step-------------------------------------------------------------------------------
SELECT apps, avg_rating, t_review_count, best_price, purch_price, genres,
       CASE
           WHEN avg_rating < 1.0 THEN 1
           WHEN avg_rating >= 1.0 AND avg_rating < 4.0 THEN avg_rating * 3.0 / 2.0
           ELSE 9
       END AS proj_lifespan
FROM (
    SELECT p.name AS apps,
           ROUND((a.rating + p.rating) / 2, 1) AS avg_rating,
           SUM(CAST(a.review_count AS int) + p.review_count) AS t_review_count,
           ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), CAST(a.price AS numeric)), 0) AS best_price,
           ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), CAST(a.price AS numeric)), 0) * 10000 AS purch_price,
           p.genres
    FROM play_store_apps AS p
    INNER JOIN app_store_apps a ON p.name = a.name
    GROUP BY p.name, a.rating, p.rating, p.price, a.price, p.genres
) AS subquery
ORDER BY avg_rating DESC, t_review_count DESC;
--------------next step--------lifetime earnings-------------------------------------------------------------
SELECT apps, avg_rating, t_review_count, best_price, purch_price, genres, proj_lifespan,
       proj_lifespan * 108000 - purch_price AS net_earns
FROM 
		(SELECT p.name AS apps,
           ROUND((a.rating + p.rating) / 2, 1) AS avg_rating,
           SUM(CAST(a.review_count AS int) + p.review_count) AS t_review_count,
           ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), CAST(a.price AS numeric)), 0) AS best_price,
           ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), CAST(a.price AS numeric)), 0) * 10000 AS 					purch_price,
           p.genres,
           CASE WHEN ROUND((a.rating + p.rating) / 2, 1) < 1.0 THEN 1
               	WHEN ROUND((a.rating + p.rating) / 2, 1) >= 1.0 
		 		AND ROUND((a.rating + p.rating) / 2, 1) < 4.0 THEN ROUND((a.rating + p.rating) / 2, 1) * 3.0 / 2.0
               	ELSE 9 END AS proj_lifespan
    FROM play_store_apps AS p
    INNER JOIN app_store_apps a ON p.name = a.name
    GROUP BY p.name, a.rating, p.rating, p.price, a.price, p.genres
) AS subquery
ORDER BY avg_rating DESC, t_review_count DESC;
----------------------reorder by net_earns------------------------------------------------------------------
SELECT apps, CAST(proj_lifespan * 9000 - purch_price AS money) AS net_earns, avg_rating, proj_lifespan, genres, best_price, purch_price, t_review_count
FROM (
    SELECT p.name AS apps,
           ROUND((a.rating + p.rating) / 2, 1) AS avg_rating,
           SUM(CAST(a.review_count AS int) + p.review_count) AS t_review_count,
           ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), CAST(a.price AS numeric)), 0) AS best_price,
           ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), CAST(a.price AS numeric)), 0) * 10000 AS purch_price,
           p.genres,
    CASE
    WHEN ROUND((a.rating + p.rating) / 2, 1) < 1.0 THEN 1
    WHEN ROUND((a.rating + p.rating) / 2, 1) < 4.0 THEN 
    CAST((ROUND((a.rating + p.rating) / 2, 1) * 3.0 / 2.0) AS numeric(5,2))
    ELSE 9
END AS proj_lifespan
    FROM play_store_apps AS p
    INNER JOIN app_store_apps a ON p.name = a.name
    GROUP BY p.name, a.rating, p.rating, p.price, a.price, p.genres
) AS subquery
ORDER BY net_earns DESC;
-------------------------------edit---------------------------------------------------------
SELECT apps, CAST(proj_lifespan * 108000 - purch_price AS money) AS net_earns, avg_rating, proj_lifespan, genres, best_price, purch_price, t_review_count
FROM (
    SELECT p.name AS apps,
           ROUND((a.rating + p.rating) / 2, 1) AS avg_rating,
           SUM(CAST(a.review_count AS int) + p.review_count) AS t_review_count,
           ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), CAST(a.price AS numeric)), 0) AS best_price,
           ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), CAST(a.price AS numeric)), 0) * 10000 AS purch_price,
           p.genres, 2*ROUND((a.rating+p.rating)/2*2,0)/2 + 1 AS proj_lifespan
    FROM play_store_apps AS p
    INNER JOIN app_store_apps a ON p.name = a.name
    GROUP BY p.name, a.rating, p.rating, p.price, a.price, p.genres
) AS subquery
ORDER BY net_earns DESC;
----------------------WALK THROUGH--------corrected my script for proj_lifespan---------------------------
SELECT apps, CAST(proj_lifespan * 108000 - purch_price AS money) AS net_earns, --108K represents 10K a month minus 1k is costs=9K per month times 12 months is 108K annually
	avg_rating, --this is a.rating & p.rating rounded
	proj_lifespan, --used Amanda's code in the selection statement
	genres, --chose to use only the play store's output after reviewing the output of both tables
	best_price, --highest price between the two app stores returned as numeric data 
	purch_price, --10K times every dollar of cost of the app if over a $
	t_review_count --the total of reviews together from both stores
	--then a subquery for the rest of this crap!------
FROM (
    SELECT p.name AS apps,
  	ROUND((a.rating + p.rating) / 2, 1) AS avg_rating,
    SUM(CAST(a.review_count AS int) + p.review_count) AS t_review_count,
    ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), CAST(a.price AS numeric)), 0) AS 	
best_price,---there is a shortcut you can use for cast as ::numeric
	ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), CAST(a.price AS numeric)), 0) * 10000 AS purch_price,
	p.genres, 2*ROUND((a.rating+p.rating)/2*2,0)/2 + 1 AS proj_lifespan--the peren part is getting the average, the rounding to the next half--and that zero is rounding to the whole number
    FROM play_store_apps AS p
    INNER JOIN app_store_apps a ON p.name = a.name
    GROUP BY p.name, a.rating, p.rating, p.price, a.price, p.genres
) AS subquery
ORDER BY net_earns DESC;--last change I made to script as I was sorting on other factors until the end
--------------------final clean script------------------------------------------------------
SELECT apps, CAST(proj_lifespan * 108000 - purch_price AS money) AS net_earns, 
	avg_rating,
	proj_lifespan,
	genres,
	best_price,
	purch_price,
	t_review_count
FROM 
	(SELECT p.name AS apps,
  	ROUND((a.rating + p.rating) / 2, 1) AS avg_rating,
    SUM(CAST(a.review_count AS int) + p.review_count) AS t_review_count,
    ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), 
	CAST(a.price AS numeric)), 0) AS best_price,
	ROUND(GREATEST(CAST(REPLACE(p.price, '$', '') AS numeric), 
	CAST(a.price AS numeric)), 0) * 10000 AS purch_price,
	p.genres, 2*ROUND((a.rating+p.rating)/2*2,0)/2 + 1 AS proj_lifespan
    FROM play_store_apps AS p
    INNER JOIN app_store_apps a ON p.name = a.name
    GROUP BY p.name, a.rating, p.rating, p.price, a.price, p.genres ) AS subquery
	ORDER BY net_earns DESC;
