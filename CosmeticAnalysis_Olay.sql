SELECT * FROM COSMETICS.dbo.cleaned_data


----creat table for rating of olay based on year to see the pattern and compare with otheer compettitirs


DROP TABLE IF EXISTS OlayScoresTable;

-- Create a new table to store the result
CREATE TABLE dbo.OlayScoresTable (
    year NVARCHAR(10),
    score_1 INT,
    score_2 INT,
    score_3 INT,
    score_4 INT,
    score_5 INT,
    total_ratings INT
);

-- Insert the query result into the table
INSERT INTO OlayScoresTable
SELECT
    YEAR(review_date) AS year,
    SUM(CASE WHEN review_rating = 1 THEN 1 ELSE 0 END) AS score_1,
    SUM(CASE WHEN review_rating = 2 THEN 1 ELSE 0 END) AS score_2,
    SUM(CASE WHEN review_rating = 3 THEN 1 ELSE 0 END) AS score_3,
    SUM(CASE WHEN review_rating = 4 THEN 1 ELSE 0 END) AS score_4,
    SUM(CASE WHEN review_rating = 5 THEN 1 ELSE 0 END) AS score_5,
    SUM(CASE WHEN brand_name = 'Olay' THEN 1 ELSE 0 END) AS total_ratings
FROM
    COSMETICS.dbo.cleaned_data
WHERE
    brand_name = 'Olay'
GROUP BY
    YEAR(review_date)
WITH ROLLUP;


---
SELECT * from OlayScoresTable



SELECT DISTINCT review_label
FROM COSMETICS.dbo.cleaned_data;

-- how many of review table for olay are verified how many professional
SELECT review_label, COUNT(*) AS count
FROM COSMETICS.dbo.cleaned_data
WHERE brand_name = 'Olay'
GROUP BY review_label;


--- how many of the "Verified Buyer" in "review_label" columns are "TRUE" in "is_a_buyer" column, and how many are FALSE

SELECT
    SUM(CASE WHEN is_a_buyer = 'TRUE' THEN 1 ELSE 0 END) AS true_count,
    SUM(CASE WHEN is_a_buyer = 'FALSE' THEN 1 ELSE 0 END) AS false_count
FROM COSMETICS.dbo.cleaned_data
WHERE brand_name = 'Olay' AND review_label = 'Verified Buyer';


--- howmany of the verified buyer in review_label column, are "TRUE" in pro_user clumn, how many false


SELECT
    SUM(CASE WHEN pro_user = 'TRUE' THEN 1 ELSE 0 END) AS true_count,
    SUM(CASE WHEN pro_user = 'FALSE' THEN 1 ELSE 0 END) AS false_count
FROM COSMETICS.dbo.cleaned_data
WHERE brand_name = 'Olay' AND review_label = 'Verified Buyer';


--how many "TRUE" is in "pro_user" column for olay


SELECT COUNT(*) AS professional_buyer_count
FROM COSMETICS.dbo.cleaned_data
WHERE brand_name = 'Olay' AND pro_user = 'TRUE';  -- it shows just one of the veview for olay is from professional use. we can use it in iterprete




--- how many distinct product title have olay, how many each of them

SELECT product_title, COUNT(*) AS product_count
FROM COSMETICS.dbo.cleaned_data
WHERE brand_name = 'Olay'
GROUP BY product_title
ORDER BY product_count DESC;--- it shows 3 product have better performance.



---- the relationship of mrp and price in top product.

SELECT TOP 7 product_title, COUNT(*) AS review_count, 
    SUM(CASE WHEN mrp > price THEN 1 ELSE 0 END) AS mrp_higher_count,
    SUM(CASE WHEN mrp < price THEN 1 ELSE 0 END) AS price_higher_count
FROM COSMETICS.dbo.cleaned_data
WHERE brand_name = 'Olay'
GROUP BY product_title
ORDER BY review_count DESC; 


--- selling price of each product is lower than the maximum price recommended by the brand

--- it could indicate a potential pricing strategy issue or a mismatch between the perceived value of the product by the company and the perceived value by the customers.



-- lets see the diffrence of mrp and price in top 3 product and see the diffrence in descending order
SELECT DISTINCT
    product_title,
    CONVERT(decimal(10, 2), MRP) - CONVERT(decimal(10, 2), Price) AS price_difference
FROM
    COSMETICS.dbo.cleaned_data
WHERE
    brand_name = 'Olay'
    AND product_title IN ('Olay Eye Cream - With Niacinamide & Pentapeptides', 'Olay Total Effects Day Cream For Sensitive Skin - Niacinamide', 'Olay Total Effects 7 In One Anti-Ageing Day Cream Normal SPF 15')
ORDER BY
    price_difference DESC;


---number of reviews and the average score of each product of olay

SELECT
    product_title,
    COUNT(review_rating) AS review_count,
    AVG(CAST(review_rating AS DECIMAL(10, 2))) AS average_review_rating
FROM
    COSMETICS.dbo.cleaned_data
WHERE
    brand_name = 'Olay'
GROUP BY
    product_title
		
ORDER BY average_review_rating DESC ;


-- lets see the the product rating and the number of rating for each product in olay

SELECT DISTINCT
    product_title,
    product_rating,
    product_rating_count
FROM
    COSMETICS.dbo.cleaned_data
WHERE
    brand_name = 'Olay'
ORDER BY
    product_rating DESC;


--- Creat table for Olay Rating 

IF OBJECT_ID('dbo.OlayRatingTable', 'U') IS NOT NULL
    DROP TABLE dbo.OlayRatingTable;

-- Create the OlayRatingTable
CREATE TABLE dbo.OlayRatingTable (
    product_title NVARCHAR(255),
    review_count INT,
    average_review_rating DECIMAL(10, 2),
    product_rating DECIMAL(10, 2),
    product_rating_count INT
);

-- Insert the query result into the OlayRatingTable
INSERT INTO dbo.OlayRatingTable (product_title, review_count, average_review_rating, product_rating, product_rating_count)
SELECT
    product_title,
    COUNT(review_rating) AS review_count,
    CAST(AVG(CAST(review_rating AS DECIMAL(10, 2))) AS DECIMAL(10, 2)) AS average_review_rating,
    CAST(product_rating AS DECIMAL(10, 2)) AS product_rating,
    CAST(product_rating_count AS INT) AS product_rating_count
FROM
    COSMETICS.dbo.cleaned_data
WHERE
    brand_name = 'Olay'
GROUP BY
    product_title, product_rating, product_rating_count;

-- Retrieve the final results from the OlayRatingTable, ordered by product rating count descending
SELECT *
FROM dbo.OlayRatingTable
ORDER BY product_rating_count DESC, product_title;

-- Drop the OlayRatingTable if no longer needed
-- DROP TABLE dbo.OlayRatingTable;
-----------

----now let's do the same for other brands


