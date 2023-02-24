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
ORDER BY MAX(p.review_count) DESC; 
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
ORDER BY MAX(p.review_count) DESC;
----------combined the price columns showing the greatest number between the two numbers-------------

