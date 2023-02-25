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


WITH my_cte AS(
SELECT a.name AS apps_in_both,
ROUND((a.rating + p.rating)/2, 1) AS rating_avg,
	CASE WHEN ROUND((a.rating + p.rating)/2, 1) < 0.5 THEN 1*(10000*12)
	WHEN ROUND((a.rating + p.rating)/2, 1) < 1.0 THEN 2*(10000*12)
	WHEN ROUND((a.rating + p.rating)/2, 1) < 1.5 THEN 3*(10000*12)
	WHEN ROUND((a.rating + p.rating)/2, 1) < 2.0 THEN 4*(10000*12)
	WHEN ROUND((a.rating + p.rating)/2, 1) < 2.5 THEN 5*(10000*12)
	WHEN ROUND((a.rating + p.rating)/2, 1) < 3.0 THEN 6*(10000*12)
	WHEN ROUND((a.rating + p.rating)/2, 1) < 3.5 THEN 7*(10000*12)
	WHEN ROUND((a.rating + p.rating)/2, 1) < 4.0 THEN 8*(10000*12)
	WHEN ROUND((a.rating + p.rating)/2, 1) < 4.5 THEN 9*(10000*12)
	WHEN ROUND((a.rating + p.rating)/2, 1) < 5.0 THEN 10*(10000*12) END AS app_lifetime_profit,
	CASE WHEN CAST(REPLACE(REPLACE(p.price, '$',''),'0','1')AS numeric) > a.price THEN CAST(REPLACE(REPLACE(p.price, '$',''),'0','1')AS numeric)*10000
	ELSE a.price*10000 END AS purchase_price, 
	CASE WHEN ROUND((a.rating + p.rating)/2, 1) < 0.5 THEN 1*1000
	WHEN ROUND((a.rating + p.rating)/2, 1) < 1.0 THEN 2*1000
	WHEN ROUND((a.rating + p.rating)/2, 1) < 1.5 THEN 3*1000
	WHEN ROUND((a.rating + p.rating)/2, 1) < 2.0 THEN 4*1000
	WHEN ROUND((a.rating + p.rating)/2, 1) < 2.5 THEN 5*1000
	WHEN ROUND((a.rating + p.rating)/2, 1) < 3.0 THEN 6*1000
	WHEN ROUND((a.rating + p.rating)/2, 1) < 3.5 THEN 7*1000
	WHEN ROUND((a.rating + p.rating)/2, 1) < 4.0 THEN 8*1000
	WHEN ROUND((a.rating + p.rating)/2, 1) < 4.5 THEN 9*1000
	WHEN ROUND((a.rating + p.rating)/2, 1) < 5.0 THEN 10*1000 END AS investment_cost
FROM app_store_apps AS a
INNER JOIN play_store_apps As p
ON a.name = p.name
GROUP BY a.name, rating_avg, app_lifetime_profit, purchase_price, investment_cost
)
SELECT apps_in_both,
rating_avg,
app_lifetime_profit - (purchase_price + investment_cost) AS revenue
FROM my_cte
ORDER BY revenue DESC,
rating_avg DESC;






SELECT *
FROM play_store_apps

SELECT *
FROM app_store_apps