-- ==================================================
-- Jumia Nigeria Phones — SQL Analysis
-- Author: Oluwanifemi Dipe
-- Date: February 2026
-- Database: jumiadata
-- ==================================================


-- ==================================================
-- DATABASE
-- ==================================================

-- Create a database to use for this analysis
CREATE DATABASE jumiadata;

-- Select the database created to be used for the analysis
USE jumiadata;


-- ===================================================
-- TABLE CREATION AND IMPORTATION
-- ===================================================

-- Created tables headers to insert the data rown into
CREATE TABLE jumia_phones (
    Today DATE,
    Title TEXT,
    Brand VARCHAR(100),
    Price INT,
    Old_Price INT,
    Rating FLOAT,
    Reviews INT
);


SHOW VARIABLES LIKE 'secure_file_priv';

-- Loading the data through infile 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.2/Uploads/Jumia_cleaned_data.csv'
INTO TABLE jumia_phones
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


ALTER TABLE jumia_phones MODIFY Today VARCHAR(20);

-- Selecting the top 10 rows of data to be sure the right data was imported and to have a data overview before analysis
SELECT * FROM jumia_phones
LIMIT 10;


-- ========================================
-- LITTLE DATA CLEANING
-- ========================================

-- Checking for duplicates
SELECT TODAY,
TITLE,
BRAND,
PRICE,
OLD_PRICE,
RATING,
REVIEWS,
COUNT(*) AS COUNT
FROM JUMIA_PHONES
GROUP BY TODAY, TITLE, BRAND, PRICE, OLD_PRICE, RATING, REVIEWS
HAVING COUNT(*) > 1;

DELETE FROM JUMIA_PHONES WHERE BRAND = 'Call 07006000000 To Place Your Order' 
OR BRAND = 'See More Offers';

-- Removing duplicates by transferring unique details to new table. Deleting old table, then renaming new table to Old_name
CREATE TABLE jumia_phones_cleaned AS
SELECT DISTINCT * FROM jumia_phones;

DROP TABLE jumia_phones;

RENAME TABLE jumia_phones_cleaned TO jumia_phones;
-- END OF CLEANING

-- ======================================
-- SETUP
-- ======================================

-- Adding a discount column that was not calculated during data scraping
ALTER TABLE jumia_phones ADD COLUMN Discount FLOAT;

-- Automatically calculating discount to be inserted into the discount column
UPDATE jumia_phones 
SET Discount = ROUND(((Old_Price - Price) / Old_Price) * 100, 2);

-- Glancing at data to see if calculation was succesful
SELECT * FROM jumia_phones
LIMIT 10;


-- ========================================
##             ANALYSIS QUERY
-- ========================================

-- ========================================
-- 1. MARKET OVERVIEW ANALYSIS
-- ========================================

-- 1a. How many phones did each brand list
SELECT BRAND, 
COUNT(*) AS TOTAL_LISTING
FROM JUMIA_PHONES
GROUP BY BRAND
ORDER BY TOTAL_LISTING DESC;


-- 1b. Which brands dominate the Nigerian market on Jumia?
SELECT BRAND, 
COUNT(*) as TOTAL_LISTING,
ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM JUMIA_PHONES), 2) AS MARKET_SHARE_PERCENTAGE
FROM JUMIA_PHONES
GROUP BY BRAND 
ORDER BY TOTAL_LISTING DESC;


-- 1c. Total review per brand (popularity indicator)
SELECT BRAND,
SUM(REVIEWS) AS TOTAL_REVIEWS
FROM JUMIA_PHONES 
GROUP BY BRAND
ORDER BY TOTAL_REVIEWS DESC; 


-- ==========================================
-- 2. PRICING ANALYSIS
-- ==========================================

-- 2a. Average price by Brand
SELECT BRAND, ROUND(AVG(PRICE) ,2) AS AVG_PRICE
FROM JUMIA_PHONES
GROUP BY BRAND
ORDER BY AVG_PRICE DESC;


-- 2b. Most expensive vs cheapest phones
SELECT TITLE, BRAND, PRICE
FROM JUMIA_PHONES
ORDER BY PRICE DESC
LIMIT 10;


SELECT TITLE, BRAND, PRICE
FROM JUMIA_PHONES
ORDER BY PRICE ASC
LIMIT 10;


-- =========================================
-- 2c. PRICE RANGE DISTRIBUTION
-- =========================================

SELECT
	CASE 
		WHEN PRICE < 50000 THEN 'BUDGET (UNDER 50K)'
		WHEN PRICE BETWEEN 50000 AND 150000 THEN 'MID-RANGE (50K - 150K)'
        WHEN PRICE BETWEEN 150000 AND 300000 THEN 'PREMIUM (150K - 300K)'
        ELSE 'LUXURY (300K ABOVE)'
	END AS PRICE_SEGMENT,
COUNT(*) AS TOTAL_PHONES
FROM JUMIA_PHONES
GROUP BY PRICE_SEGMENT
ORDER BY TOTAL_PHONES DESC;


-- ========================================
-- 3. DISCOUNT ANALYSIS 
-- ========================================

-- 3a. Average discount by brand 
SELECT BRAND, 
ROUND(AVG(DISCOUNT), 2)  AS AVG_DISCOUNT
FROM JUMIA_PHONES
GROUP BY BRAND 
ORDER BY AVG_DISCOUNT DESC;


-- 3b. Which brand offers the biggest discounts ? 
SELECT BRAND,
MAX(DISCOUNT) AS MAX_DISCOUNT
FROM JUMIA_PHONES
GROUP BY BRAND
ORDER BY MAX_DISCOUNT DESC;


-- 3c. Products with the highest discount
SELECT TITLE,
BRAND,
PRICE,
OLD_PRICE,
DISCOUNT
FROM JUMIA_PHONES
ORDER BY DISCOUNT DESC
LIMIT 10;


-- 3D. Brand with no discount 
SELECT BRAND,
COUNT(*) AS NO_DISCOUNT_COUNT
FROM JUMIA_PHONES
WHERE DISCOUNT = 0
GROUP BY BRAND
ORDER BY NO_DISCOUNT_COUNT DESC;


-- =======================================
-- 4. RATINGs AND POPULARITY ANALYSIS 
-- =======================================

-- 4a. Highest rated phones 
SELECT TITLE,
BRAND,
RATING,
REVIEWS
FROM JUMIA_PHONES
WHERE REVIEWS > 50
ORDER BY REVIEWS DESC
LIMIT 10;


-- 4b. Brand with best average rating 
SELECT BRAND, 
ROUND(AVG(RATING), 2) AS AVG_RATING
FROM JUMIA_PHONES
GROUP BY BRAND 
ORDER BY AVG_RATING DESC;


-- 4c. Do expensive phones rate higher than cheaper ones 
SELECT 
	CASE 
		WHEN PRICE < 50000 THEN "BUDGET"
        WHEN PRICE BETWEEN 50000 AND 150000 THEN "MID-RANGE"
        WHEN PRICE BETWEEN 150000 AND 300000 THEN "PREMIUM"
		ELSE "LUXURY"
	END AS PRICE_SEGMENT,
ROUND(AVG(RATING), 2) AS AVG_RATING
FROM JUMIA_PHONES
GROUP BY PRICE_SEGMENT
ORDER BY AVG_RATING DESC;


-- 4d. Most reviewed phones
SELECT TITLE,
BRAND,
RATING,
REVIEWS
FROM JUMIA_PHONES
ORDER BY REVIEWS DESC
LIMIT 10;


-- =========================================
-- 5. MONEY VALUE ANALYSIS 
-- =========================================

-- 5a. Best rated phones below 50,000 naira
SELECT TITLE,
BRAND,
PRICE,
RATING,
REVIEWS
FROM JUMIA_PHONES 
WHERE PRICE < 50000 AND REVIEWS > 50
ORDER BY RATING DESC, REVIEWS DESC
LIMIT 10;


-- 5b. Best deals combination (High discount + High reviews)
SELECT TITLE, 
BRAND,
OLD_PRICE,
PRICE,
DISCOUNT,
RATING
FROM JUMIA_PHONES
WHERE RATING >=  4.0 AND DISCOUNT >= 10
ORDER BY DISCOUNT DESC, RATING DESC
LIMIT 10;


-- 5c. Best value per price segment
SELECT 
	CASE 
		WHEN PRICE < 50000 THEN "BUDGET"
        WHEN PRICE BETWEEN 50000 AND 150000 THEN "MID-RANGE"
        WHEN PRICE BETWEEN 150000 AND 300000 THEN "PREMIUM"
		ELSE "LUXURY"
	END AS PRICE_SEGMENT,
TITLE,
BRAND,
PRICE,
RATING 
FROM JUMIA_PHONES
WHERE (PRICE, RATING) IN (
		SELECT PRICE, MAX(RATING)
        FROM JUMIA_PHONES
        GROUP BY PRICE
		)
ORDER BY PRICE_SEGMENT, RATING DESC
LIMIT 20;


-- 5D. Highly reviewed and affordable phones
SELECT TITLE, 
BRAND,
PRICE,
REVIEWS,
RATING
FROM JUMIA_PHONES 
WHERE PRICE < 150000 
ORDER BY REVIEWS DESC, PRICE ASC
LIMIT 10;
    