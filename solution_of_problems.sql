-- 1. Count the number of Movies vs TV Shows
SELECT
type,
COUNT(*) AS totle_content
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
SELECT 
type,
rating
FROM(
	SELECT 
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS rnk
	FROM netflix
	GROUP BY 1,2
)T
WHERE rnk = 1; 

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT
    title,
    release_year,
    COUNT(*) OVER (PARTITION BY release_year) AS movies_in_same_year
FROM netflix
WHERE type = 'Movie'
ORDER BY release_year, title;

-- 4. Find the top 5 countries with the most content on Netflix
WITH RECURSIVE split_country AS (
    SELECT
        TRIM(SUBSTRING_INDEX(country, ',', 1)) AS country,
        SUBSTRING(country, LENGTH(SUBSTRING_INDEX(country, ',', 1)) + 2) AS rest
    FROM netflix
    WHERE country IS NOT NULL

    UNION ALL

    SELECT
        TRIM(SUBSTRING_INDEX(rest, ',', 1)),
        SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
    FROM split_country
    WHERE rest <> ''
)
SELECT
    country,
    COUNT(*) AS total_content
FROM split_country
WHERE country IS NOT NULL AND country <> ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT 
title,
type,
duration 
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ',1) AS UNSIGNED) DESC;


-- 6. Find content added in the last 5 years
SELECT 
title, date_added, release_year
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM netflix
WHERE director = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- 9.Find each year and the average numbers of content release in India on netflix. 
SELECT
    'India' AS country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) /
        (SELECT COUNT(show_id)
         FROM netflix
         WHERE country LIKE '%India%') * 100
    , 2) AS avg_release
FROM netflix
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 10. List all movies that are documentaries
SELECT *
FROM netflix 
WHERE listed_in LIKE '%Documentaries%';

-- 11. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL;

-- 12. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix 
WHERE cast LIKE '%Salman%'
AND type = 'Movie'
AND release_year BETWEEN 2011 AND 2020;

/* Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
SELECT
content_type,
type,
COUNT(*) AS content_count
FROM (
SELECT 
type,
description,
CASE
	WHEN description LIKE '%KILL%'
    OR
    description LIKE '%violence%'
    THEN 'BAD'
    ELSE 'GOOD'
    END as content_type
FROM netflix 
WHERE description IS NOT NULL
) AS categorized_content
GROUP BY content_type,type
ORDER BY type
