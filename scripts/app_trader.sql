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



SELECT a.name AS app_store
FROM app_store_apps AS a
INNER JOIN play_store_apps As p
ON a.name = p.name;