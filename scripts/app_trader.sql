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
ROUND((a.rating + p.rating)/2, 1) AS both_stores_avg,
a.price,
p.price,
SUM(CAST(a.review_count AS int) + p.review_count) AS total_review_count,
p.install_count
FROM app_store_apps AS a
INNER JOIN play_store_apps As p
ON a.name = p.name
GROUP BY a.name, both_stores_avg, a.price, p.price, p.install_count
ORDER BY both_stores_avg DESC,
a.price,
total_review_count DESC;

SELECT *
FROM play_store_apps

SELECT *
FROM app_store_apps