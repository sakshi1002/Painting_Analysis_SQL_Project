----------------------------CASE STUDY : PAINTINGS - KAGGLE DATASET -------------------------------------

--Quick look through of the data tables in dataset
SELECT * FROM artist
SELECT * FROM canvas_size
SELECT * FROM image_link
SELECT * FROM museum
SELECT * FROM museum_hours
SELECT * FROM product_size
SELECT * FROM subject
SELECT * FROM work

---------Analysis Begins

--Q1) 1) Fetch all the paintings which are not displayed on any museums?
SELECT * FROM work WHERE museum_id IS NULL;


--Q2) Are there museuems without any paintings? --ans : NO
	
SELECT museum_id
FROM museum m
WHERE  NOT EXISTS (SELECT 1 FROM work w WHERE w.museum_id = m.museum_id )

--Q3) How many paintings have an asking price of more than their regular price? 

SELECT ps.*
FROM product_size ps
JOIN work w ON w.work_id = ps.work_id
WHERE ps.sale_price > ps.regular_price


--Q4) Identify the paintings whose asking price is less than 50% of its regular price

SELECT ps.*, w.name, w.style
FROM product_size ps
JOIN work w ON w.work_id = ps.work_id
WHERE ps.sale_price < ps.regular_price*0.5

--Q5) Which canva size costs the most?


SELECT canvas_size, Price
FROM (
    SELECT cs.label AS canvas_size, ps.sale_price AS Price,
           RANK() OVER(ORDER BY ps.sale_price DESC) rnk
    FROM product_size ps
    JOIN canvas_size cs 
      ON cs.size_id::text = ps.size_id::text
) t
WHERE rnk = 1;



--Q6) Identify the museums with invalid city information in the given dataset

SELECT *
FROM museum
WHERE city ~ '^[0-9]';



--Q7) Museum_Hours table has 1 invalid entry. Identify it and remove it.

DELETE FROM museum_hours 
	WHERE ctid NOT IN (SELECT MIN(ctid)
						FROM museum_hours
						GROUP BY museum_id, day );



--Q8) Fetch the top 10 most famous painting subject

WITH cte as
(SELECT s.subject, count(1),
ROW_NUMBER() OVER(ORDER BY COUNT(1) DESC) as rn
FROM work w
JOIN subject s ON s.work_id = w.work_id
GROUP BY s.subject)
SELECT * 
FROM cte
WHERE rn <= 10



--Q9) Identify the museums which are open on both Sunday and Monday. Display museum name, city.

SELECT DISTINCT m.name AS museum_name, m.city, m.state, m.country
FROM museum m
JOIN museum_hours mh ON m.museum_id = mh.museum_id
WHERE mh.day IN ('Sunday', 'Monday')
GROUP BY m.museum_id, m.name,m.city, m.state, m.country
HAVING COUNT(DISTINCT mh.day) = 2;


--Q10) How many museums are open every single day?

select count(1)
	from (select museum_id, count(1)
		  from museum_hours
		  group by museum_id
		  having count(1) = 7) x;

--Q11)  Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)

SELECT m.museum_id, m.name, m.address,m.city,num_paintings
FROM 
(SELECT m.museum_id, count(*) as num_paintings,
RANK() OVER(ORDER BY COUNT(*) DESC) AS rnk
FROM work w
JOIN museum m ON m.museum_id = w.museum_id
group by m.museum_id) x
JOIN museum m ON m.museum_id = x.museum_id
WHERE x.rnk <= 5




--Q12) Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
SELECT a.artist_id,a.full_name,a.nationality,a.style,no_of_paintings,x.rnk
FROM
(
SELECT a.artist_id, count(*) as no_of_paintings,
RANK() OVER(ORDER BY COUNT(*) DESC) AS rnk
FROM work w
JOIN artist a ON w.artist_id = a.artist_id
GROUP BY a.artist_id
) x
JOIN artist a ON a.artist_id = x.artist_id
WHERE x.rnk <= 5
ORDER BY rnk



--Q13) Display the 3 least popular canva sizes
WITH cte as
(SELECT c.size_id,c.label as canvas, COUNT(1) AS no_of_paintings,
DENSE_RANK() OVER(ORDER BY COUNT(1) ASC) AS rnk
FROM work w
JOIN product_size p ON w.work_id = p.work_id
JOIN canvas_size c ON c.size_id::text = p.size_id
GROUP BY c.size_id,c.label)
SELECT *
FROM cte
WHERE rnk <= 3



--Q14) Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?


SELECT x.museum_id,x.hours_difference,day,m.name,m.city,m.country FROM(
SELECT 
    museum_id,
    day,
    open,
    close,
    EXTRACT(EPOCH FROM (TO_TIMESTAMP(close, 'HH12:MI:AM') - TO_TIMESTAMP(open, 'HH12:MI:AM'))) / 3600 AS hours_difference,
	DENSE_RANK() OVER(ORDER BY (EXTRACT(EPOCH FROM (TO_TIMESTAMP(close, 'HH12:MI:AM') - TO_TIMESTAMP(open, 'HH12:MI:AM'))) / 3600) DESC) AS rnk
FROM museum_hours) x
JOIN museum m ON m.museum_id = x.museum_id
WHERE rnk = 1



--15) Which museum has the most no of most popular painting style?

WITH pop_style AS 
			(SELECT style
			,rank() OVER(ORDER BY COUNT(1) DESC) AS rnk
			FROM work
			GROUP BY style),
		cte AS
			(SELECT w.museum_id,m.name AS museum_name,ps.style, COUNT(1) AS no_of_paintings
			,RANK() OVER(ORDER BY COUNT(1) DESC) AS rnk
			FROM work w
			JOIN museum m ON m.museum_id=w.museum_id
			JOIN pop_style ps ON ps.style = w.style
			WHERE w.museum_id IS NOT NULL
			AND ps.rnk=1
			GROUP BY w.museum_id, m.name,ps.style)
	SELECT museum_name,style,no_of_paintings
	FROM cte 
	WHERE rnk=1;



---16) Identify the artists whose paintings are displayed in multiple countries


WITH most_displayed_artist AS (
    SELECT w.artist_id, COUNT(DISTINCT m.country) AS country_cnt
    FROM work w
    JOIN museum m ON m.museum_id = w.museum_id
    WHERE m.country IS NOT NULL
    GROUP BY w.artist_id
)
SELECT a.artist_id, a.full_name
FROM artist a
JOIN most_displayed_artist da 
  ON da.artist_id = a.artist_id
WHERE da.country_cnt > 1;


--Q17) Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.	


WITH cte_country AS 
			(SELECT country, count(1)
			, RANK() over(ORDER BY COUNT(1) DESC) AS rnk
			FROM museum
			GROUP BY country),
		cte_city AS
			(SELECT city, COUNT(1)
			, RANK() OVER(ORDER BY count(1) DESC) AS rnk
			FROM museum
			GROUP BY city)
	SELECT string_agg(DISTINCT country.country,', '), string_agg(city.city,', ')
	FROM cte_country country
	CROSS JOIN cte_city city
	WHERE country.rnk = 1
	AND city.rnk = 1;



--Q18) Identify the artist and the museum where the most expensive and least expensive painting is placed. 
--Display the artist name, sale_price, painting name, museum name, museum city and canvas label


SELECT w.work_id,MAX(sale_price) as max_price , MIN(sale_price) as min_price
FROM work w
JOIN product_size ps ON w.work_id =ps.work_id
GROUP BY w.work_id

--
WITH cte as
(
SELECT *
		, RANK() OVER(ORDER BY sale_price DESC) AS rnk
		, RANK() OVER(ORDER BY sale_price ) AS rnk_asc
		FROM product_size
)
SELECT a.full_name,x.sale_price,w.name,m.name,m.city,cs.label
FROM cte x
JOIN work w ON w.work_id = x.work_id
JOIN artist a ON w.artist_id = a.artist_id
JOIN museum m ON m.museum_id = w.museum_id
JOIN product_size p ON p.work_id = w.work_id
JOIN canvas_size cs ON cs.size_id::text = p.size_id 
WHERE rnk=1 or rnk_asc=1;



--Q19) Which country has the 5th highest no of paintings?

SELECT country, no_of_paintings, rn
FROM (
SELECT m.country AS country ,count(work_id) as no_of_paintings,
ROW_NUMBER() OVER(ORDER BY count(work_id) DESC) as  rn
FROM work w
JOIN museum m ON m.museum_id = w.museum_id
GROUP BY m.country 
)
WHERE rn = 5




--Q20 Which are the 3 most popular and 3 least popular painting styles?

WITH style_counts AS (
    SELECT style,
           COUNT(*) AS cnt
    FROM work
    WHERE style IS NOT NULL
    GROUP BY style
),
ranked AS (
    SELECT style, cnt,
           DENSE_RANK() OVER(ORDER BY cnt DESC) AS rnk_desc,
           DENSE_RANK() OVER(ORDER BY cnt ASC) AS rnk_asc
    FROM style_counts
)
SELECT style,
       CASE 
           WHEN rnk_desc <= 3 THEN 'Most Popular'
           WHEN rnk_asc <= 3 THEN 'Least Popular'
       END AS remarks
FROM ranked
WHERE rnk_desc <= 3 OR rnk_asc <= 3;

--Q21) Which artist has the most no of Portraits paintings outside USA?. Display artist name, no of paintings and the artist nationality.

WITH cte as (
SELECT w.artist_id as artistID, COUNT(*) as cnt_paintings,
DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) as rnk
FROM artist a
JOIN work w ON a.artist_id = w.artist_id
JOIN subject s ON s.work_id = w.work_id
JOIN museum m ON m.museum_id = w.museum_id
WHERE s.subject = 'Portraits' AND  m.country <> 'USA'
GROUP BY w.artist_id
)
SELECT t.artistID, t.cnt_paintings, t.rnk, a.full_name, a.nationality
FROM cte as t
JOIN artist a ON t.artistID = a.artist_id
WHERE rnk = 1


-----









