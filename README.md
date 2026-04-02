# 📱 Jumia Nigeria Phones - Web Scraping & SQL Analysis 

---

## 📂 Project Overview
This project scrapes phone listings from Jumia Nigeria, cleans the data with Python/Pandas, and performs structured SQL analysis to uncover pricing trends, brand dominance, discount patterns, and value-for-money insights in the Nigerian mobile phone market.

---

## Data Source

- **Website**: Jumia Nigeria — Electronics > Phones
- **Scrape Date**: 23rd February, 2026
- **Pages Scraped**: 9 pages in a single function
- **Raw Records**: 360 rows
- **Clean Records**: 315 rows
- **Unique Brands**: 31

---

## 📃 Data Collection
Scraped 9 pages of phone listings from Jumia Nigeria using Python. All 9 pages were scraped in a single function call. 
The raw dataset contained the following columns:
| Column | Description |
| --------------| ------------- |
| Today | Date of scrape |
| Title | Full product listing title |
| Brand |Phone brand name |
| Price | Current selling price (₦) | 
| Old Price | Original price before discount (₦) |
| Rating | Average customer rating (out of 5) |
| Reviews | Number of verified customer reviews |


--- 

## 🧹 Data Cleaning
All cleaning was done in Python using Pandas. Key steps:

 **Brand Column**
- Rows where the brand field contained review text (e.g. "98 verified ratings") instead of a brand name were identified and replaced with NaN
- Brands that could be identified from the product title were filled in using a keyword mapping dictionary
- Non-phone products (phone holders, washing machine pads, screen magnifiers, car mounts) that were scraped by mistake were dropped
- Final null brand rows were dropped.

**Price & Old Price**
- Removed the ₦ symbol and commas
- For listings with price ranges (e.g. 3500 - ₦ 12500), extracted only the price after the ₦ symbol
- Converted string 'nan' values to proper NaN using pd.to_numeric(errors='coerce')
- 74 missing Old Price values were filled with the current Price (indicating no discount)
- Converted both columns to int.

**Rating**
- Extracted numeric value from strings like "4 out of 5" → 4.0
- Converted to float.

**Reviews**
- Extracted numeric value from strings like "(2010 verified ratings)" → 2010
- Filled null values with 0 (new listings with no reviews yet)
- Converted to int.

**Title**
- Stripped non-ASCII characters (emojis) that caused MySQL import errors *Not included in any of the notebooks above.*

**Duplicates**
- Removed in MySQL using CREATE TABLE ... AS SELECT DISTINCT *.

---

## SQL Analysis
A Discount column was calculated directly in MySQL:
Query: 
ALTER TABLE jumia_phones ADD COLUMN Discount FLOAT;
UPDATE jumia_phones
SET Discount = ROUND(((Old_Price - Price) / Old_Price) * 100, 2);

1. 💹 Market Overview

- Total listings per brand
- Market share percentage per brand
- Total reviews per brand (popularity proxy)

2. 💰 Pricing Analysis

- Average price by brand
- Most expensive and cheapest phones (Top 10 each)
- Price range distribution (Budget / Mid-Range / Premium / Luxury)

3. 🏷️ Discount Analysis

- Average discount percentage by brand
- Brands with the highest maximum discounts
- Top 10 most discounted products
- Brands with zero discount listings

4. ⭐ Ratings & Popularity

- Highest rated phones (filtered by 50+ reviews)
- Brand with the best average rating
- Average rating by price segment
- Most reviewed (most popular) phones

5. 💳 Value for Money

- Best rated phones under ₦50,000
- Best deals — high rating (≥4.0) + high discount (≥10%)
- Best value phone per price segment
- Most reviewed affordable phones (under ₦100,000)

---

## 🔦 Key Findings

- 31 unique brands are listed across 315 cleaned phone records
- Samsung, Nokia, itel, Tecno, and Apple are the top 5 brands by listing count
- Samsung leads with 66 listings, representing the largest market presence on Jumia NG
- Budget and mid-range phones dominate the Nigerian market
- Some scraped listings included non-phone accessories (car mounts, washing machine pads) — these were cleaned out before analysis

--- 
## 🪜 How to Run
1. **Scraping**
*Run the scraper notebook*
> Check commits for file

3. **Cleaning**
*Run the cleaning notebook*
> Check commits for file

4. **MySQL Import**

Open MySQL Workbench
Create the database and table:

CREATE DATABASE jumiadata;
USE jumiadata;

CREATE TABLE jumia_phones (
    Today DATE,
    Title TEXT,
    Brand VARCHAR(100),
    Price INT,
    Old_Price INT,
    Rating FLOAT,
    Reviews INT
);

- Copy Jumia_cleaned_data.csv to your MySQL secure uploads folder
- Import using LOAD DATA INFILE

4. Analysis
*Run all queries in*
([sql](./sql/Jumia_Analysis.sql))

---

## 🛠️Tools Used
| Tool | Purpose | 
|-------|--------|
| Python (BeautifulSoup / Requests) | Web scraping |
| Pandas | Data cleaning |
| MySQL Workbench 8.2 | Data storage & SQL analysis |

---

**AUTHOR**: Oluwanifemi Dipe | Python | SQL | Web Scraping
