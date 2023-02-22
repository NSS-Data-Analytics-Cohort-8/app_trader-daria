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
ORDER BY rating, asc
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
--Genre Count--