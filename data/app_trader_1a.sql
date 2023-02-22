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
    
	SELECT name, rating, CAST(price AS money) AS priced, primary_genre AS genre, CAST(review_count AS INT)
	FROM app_store_apps
	UNION ALL 
	SELECT name, rating, CAST(price AS money) AS priced, genres AS genre, review_count
	FROM play_store_apps
	WHERE rating IS NOT NULL
	ORDER BY rating DESC
	
	
-- b. Apps earn $5000 per month, per app store it is on, from in-app advertising and in-app purchases, regardless of the price of the app.
    
-- - An app that costs $200,000 will make the same per month as an app that costs $1.00. 

-- - An app that is on both app stores will make $10,000 per month. 

WITH bot AS (SELECT name, CAST(price AS money) AS priced, primary_genre AS genre
	FROM app_store_apps
	INTERSECT
	SELECT name, CAST(price AS money) AS priced, genres AS genre
	FROM play_store_apps)
	SELECT b.name, a.rating, bot.priced, a.rating, a.review_count
	FROM app_store_apps AS a
	INNER JOIN bot USING(name) AS b
	ORDER BY rating DESC, review_count ASC

-- c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.
    
-- - An app that costs $200,000 and an app that costs $1.00 will both cost $1000 a month for marketing, regardless of the number of stores it is in.

-- d. For every half point that an app gains in rating, its projected lifespan increases by one year. In other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years.
    
-- - App store ratings should be calculated by taking the average of the scores from both app stores and rounding to the nearest 0.5.

-- e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.

	WITH a AS (
		SELECT name 
		FROM app_store_apps
		INTERSECT
		SELECT name
		FROM play_store_apps
		)
	b AS (
		SELECT name, CAST(price AS money) AS priced, CAST(review_count AS INT), rating, primary_genre AS genre
		FROM app_store_apps
		UNION ALL
		SELECT name, CAST(price AS money) AS priced, CAST(review_count AS INT), rating, genres AS genre
		FROM play_store_apps
		)
		
		

-- #### 3. Deliverables

-- a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

-- b. Develop a Top 10 List of the apps that App Trader should buy.



-- updated 2/18/2023
