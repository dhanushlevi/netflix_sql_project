--NEXFLIX PROJECT
DROP TABLE IF EXISTS netflix;
CREATE TABLE  NETFLIX(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(280),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description	VARCHAR(250)
);
select * from netflix;

select count(*) as total_count
from netflix;

select distinct type
from netflix;

-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows

select type,count(*) as total_content
from netflix
group by type;



--2. Find the most common rating for movies and TV shows

select type,rating
from ( select type,rating,count(*),rank() over(partition by type order by count(*) desc) as ranking
	from netflix 
	group by 1,2
)as t1
where ranking=1;



--3. List all movies released in a specific year (e.g., 2020)

select *
from netflix
where release_year = 2020 and type ='Movie';

--4. Find the top 5 countries with the most content on Netflix

select country ,count(*) as count_of_content
from netflix
group by country
order by count_of_content desc;
---
select unnest(string_to_array(country,',') )as new_country ,count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5
;


--5. Identify the longest movie

select title,duration
from netflix
where type ='Movie'and duration is not null
order by duration desc

limit 1; 

--or 
select * from netflix
where type='Movie' and duration = (select max(duration) from netflix);
--6. Find content added in the last 5 years

select *from netflix
where to_date(date_added,'Month DD ,YYYY')>=current_date -interval '5 years' ;


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select title,type
from netflix
where director = 'Rajiv Chilaka';

--or
select *
from netflix
where director ilike '%Rajiv Chilaka%';


--8. List all TV shows with more than 5 seasons

SELECT *
FROM NETFLIX
WHERE TYPE ='TV Show' AND SPLIT_PART(duration,' ',1)::INT >5

SELECT *
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5
--9. Count the number of content items in each genre:

select unnest(STRING_TO_ARRAY(listed_in,',')) AS new_listed_in ,count(Show_id)
from netflix
group by new_listed_in;

--10.Find each year and the average numbers of content release in India on netflix.return top 5 year with highest avg content release!

select avg(count_content) as average ,years
from (select count(show_id) as count_content ,release_year as  years
from netflix
where country ='India'
group by release_year
)
group by years 
order by average desc
limit 5;

---corrcet 
select EXTRACT (YEAR FROM to_date(date_added,'Month DD,YYY') ) AS year, count(*) as counts ,round(count(*)::numeric/(select count(*) from netflix where country='India')::numeric*100,2) as average_content
from netflix
where country ='India'
group by year

--11. List all movies that are documentaries

select *
from netflix
where type='Movie' and listed_in ilike '%Documentaries%';

--12. Find all content without a director

select *
from netflix
where director is null;


--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select *
from netflix
where casts ilike '%Salman Khan%' and release_year between 2014 and 2024;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
--  24-25

select UNNEST(STRING_TO_ARRAY(casts,',')) as actor ,count(*)
from netflix
where country ilike 'India' and type ilike 'Movie'
group by actor
order by 2 desc
limit 10


--15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
with new_table
as(
select *,
	CASE
		WHEN
			description ilike '%kill%' or description ilike '%violence%' THEN 'Bad content'
		ELSE 'Good content'
	END category
from netflix)
SELECT category,count(*)
from new_table
group by 1
