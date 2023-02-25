SELECT name,
CAST(price AS text),
CAST(review_count AS int),
rating,
content_rating,
primary_genre
FROM app_store_apps
WHERE price BETWEEN 0.00 AND 0.99
AND rating = 5.0
UNION 
SELECT name,
price,
review_count,
rating,
content_rating,
genres
FROM play_store_apps
WHERE price = '0'
AND rating = 5.0
ORDER BY review_count DESC
LIMIT 10;



SELECT a.name AS apps_in_both,
	CASE WHEN ROUND((a.rating + p.rating)/2, 1) < 0.5 THEN 1
	WHEN ROUND((a.rating + p.rating)/2, 1) < 1.0 THEN 2
	WHEN ROUND((a.rating + p.rating)/2, 1) < 1.5 THEN 3
	WHEN ROUND((a.rating + p.rating)/2, 1) < 2.0 THEN 4
	WHEN ROUND((a.rating + p.rating)/2, 1) < 2.5 THEN 5
	WHEN ROUND((a.rating + p.rating)/2, 1) < 3.0 THEN 6
	WHEN ROUND((a.rating + p.rating)/2, 1) < 3.5 THEN 7
	WHEN ROUND((a.rating + p.rating)/2, 1) < 4.0 THEN 8
	WHEN ROUND((a.rating + p.rating)/2, 1) < 4.5 THEN 9
	WHEN ROUND((a.rating + p.rating)/2, 1) < 5.0 THEN 10 END AS years_on_store,
a.price AS app_store_price,
p.price AS play_store_price
FROM app_store_apps AS a
INNER JOIN play_store_apps As p
ON a.name = p.name
GROUP BY a.name, years_on_store, a.price, p.price
ORDER BY years_on_store DESC,
a.price;

SELECT *
FROM play_store_apps

SELECT *
FROM app_store_apps