SELECT *
FROM app_store_apps
WHERE price BETWEEN 0.00 AND 0.99
AND rating = 5.0
AND content_rating = '4+'
ORDER BY CAST(review_count AS int) DESC;