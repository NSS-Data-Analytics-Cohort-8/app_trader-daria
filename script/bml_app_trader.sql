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
SELECT name, category, rating, review_count, size, install_count, type, price, content_rating, genres 
FROM play_store_apps
UNION ALL
SELECT 
