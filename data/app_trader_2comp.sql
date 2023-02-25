-- ### App Trader

-- Your team has been hired by a new company called App Trader to help them explore and gain insights from apps that are made available through the Apple App Store and Android Play Store. App Trader is a broker that purchases the rights to apps from developers in order to market the apps and offer in-app purchase. 

-- Unfortunately, the data for Apple App Store apps and Android Play Store Apps is located in separate tables with no referential integrity.

-- #### 1. Loading the data
-- a. Launch PgAdmin and create a new database called app_trader.  

-- b. Right-click on the app_trader database and choose `Restore...`  

-- c. Use the default values under the `Restore Options` tab. 

-- d. In the `Filename` section, browse to the backup file `app_store_backup.backup` in the data folder of this repository.  

-- e. Click `Restore` to load the database.  

-- f. Verify that you have two tables:  
--     - `app_store_apps` with 7197 rows  
--     - `play_store_apps` with 10840 rows

SELECT * 
FROM app_store_apps

SELECT *
FROM play_store_apps

-- #### 2. Assumptions

-- Based on research completed prior to launching App Trader as a company, you can assume the following:

-- a. App Trader will purchase apps for 10,000 times the price of the app. For apps that are priced from free up to $1.00, the purchase price is $10,000.
    
-- b. Apps earn $5000 per month, per app store it is on, from in-app advertising and in-app purchases, regardless of the price of the app
	

-- - An app that costs $200,000 will make the same per month as an app that costs $1.00. 

-- - An app that is on both app stores will make $10,000 per month. 



-- c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.
    
-- - An app that costs $200,000 and an app that costs $1.00 will both cost $1000 a month for marketing, regardless of the number of stores it is in.

-- d. For every half point that an app gains in rating, its projected lifespan increases by one year. In other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years.
  
	
-- - App store ratings should be calculated by taking the average of the scores from both app stores and rounding to the nearest 0.5.

-- e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.
	
	SELECT name, ROUND((a.rating + b.rating)/2,1) AS rated, CAST(a.price AS money) AS app_price, CAST(b.price AS money) AS play_price
	FROM app_store_apps AS a
	INNER JOIN play_store_apps AS b USING (name)
	GROUP BY name, a.rating, b.rating, a.price, b.price
	ORDER BY rated DESC
	
	--ANSWER: AVG rating shown between the two and slight price differences shown between app and play stores. Focusing solely on apps in both stores. Number in both 329.

-- #### 3. Deliverables

-- a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

	SELECT primary_genre AS genre, COUNT(DISTINCT name) AS most
	FROM app_store_apps
	GROUP BY genre
	UNION
	SELECT genres AS genre, COUNT(DISTINCT name) AS most
	FROM play_store_apps
	GROUP BY genre
	ORDER BY most DESC
	
	--ANSWER: Slight variation on genre categorization between two but top three most include games, tools, and entertainment. These are more likely to be top recommended. 
	
	SELECT *
	FROM app_store_apps AS a
	INNER JOIN play_store_apps AS b USING (name)
	ORDER BY b.rating DESC, a.rating DESC
	
	--ANSWER: Variation between apps shown in terms of rating, installs, and price. 
	
	SELECT name, ROUND((a.rating + b.rating)/2,1) AS rated, CAST(a.price AS money) AS app_price, CAST(b.price AS money) AS play_price
	FROM app_store_apps AS a
	INNER JOIN play_store_apps AS b USING (name)
	GROUP BY name, a.rating, b.rating, a.price, b.price
	ORDER BY rated DESC, app_price ASC, play_price ASC
	
	--ANSWER: Further investigation into price differences
	
	SELECT name, ROUND((a.rating + b.rating)/2,1) AS rated, 
		CASE WHEN CAST(a.price AS money) > CAST(b.price AS money) THEN CAST(a.price*10000 AS money)
			WHEN CAST(a.price AS money) < CAST(b.price AS money) THEN CAST(CAST(b.price AS money)*10000 AS money)
			WHEN CAST(a.price AS money) <= '$1.00' AND CAST(b.price AS money) <= '$1.00' THEN '$10,000.00'
			WHEN CAST(a.price AS money) = CAST(b.price AS money) AND CAST(b.price AS money) > '$1.00' AND CAST(b.price AS money) > '$1.00' THEN CAST(CAST(b.price AS 									money)*10000 AS money)
			END AS app_cost,
		(((a.rating + b.rating)/2)*2+1)*12 AS app_life_months,
		CAST(((((a.rating + b.rating)/2)*2+1)*12)*10000-(((a.rating + b.rating)/2)*2+1)*12*1000 AS money) AS revenue_lifetime_app,
		CAST(((((a.rating + b.rating)/2)*2+1)*12)*10000-(((a.rating + b.rating)/2)*2+1)*12*1000 AS money) 
		-
		CASE WHEN CAST(a.price AS money) > CAST(b.price AS money) THEN CAST(a.price*10000 AS money)
			WHEN CAST(a.price AS money) < CAST(b.price AS money) THEN CAST(CAST(b.price AS money)*10000 AS money)
			WHEN CAST(a.price AS money) <= '$1.00' AND CAST(b.price AS money) <= '$1.00' THEN '$10,000.00'
			WHEN CAST(a.price AS money) = CAST(b.price AS money) AND CAST(b.price AS money) > '$1.00' AND CAST(b.price AS money) > '$1.00' THEN CAST(CAST(b.price AS 									money)*10000 AS money)
			END AS app_full_earn
	FROM app_store_apps AS a
	INNER JOIN play_store_apps AS b USING (name)
	GROUP BY name, a.rating, b.rating, a.price, b.price
	ORDER BY app_full_earn DESC 
	
	--ANSWER: Base calculations for what final formula has to include. 
	
-- b. Develop a Top 10 List of the apps that App Trader should buy.

	WITH app_cost AS 
		(
		SELECT name, ((((a.rating+b.rating)/2)*2)+1)*12 AS applife_months,
		CASE WHEN CAST(a.price AS money) > CAST(b.price AS money) THEN CAST(a.price*10000 AS money)
			WHEN CAST(a.price AS money) < CAST(b.price AS money) THEN CAST(CAST(b.price AS money)*10000 AS money)
			WHEN CAST(a.price AS money) <= '$1.00' AND CAST(b.price AS money) <= '$1.00' THEN '$10,000.00'
			WHEN CAST(a.price AS money) = CAST(b.price AS money) AND CAST(b.price AS money) > '$1.00' AND CAST(a.price AS money) > '$1.00' THEN CAST(CAST(b.price AS 									money)*10000 AS money)
			END AS front_cost
		FROM app_store_apps AS a
		INNER JOIN play_store_apps AS b USING (name)
		GROUP BY name, a.price, b.price, a.rating, b.rating
		)
	SELECT name, (CAST(applife_months*10000 AS money)-CAST(applife_months*1000 AS money)-front_cost) AS app_earnings
	FROM app_cost
	ORDER BY app_earnings DESC
	LIMIT 10;
	
	--Final formula output for top 10 recommended apps. 
	
-- updated 2/18/2023
