DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix(
	show_id	VARCHAR(10) PRIMARY KEY
	,type VARCHAR(20)
	,title VARCHAR(150)
	,director VARCHAR(210)	
	,casts VARCHAR(1000)	
	,country VARCHAR(150)
	,date_added	VARCHAR(50)
	,release_year INT
	,rating	VARCHAR(10)
	,duration VARCHAR(15)
	,listed_in VARCHAR(100)
	,description VARCHAR(250)
);


--1. Count the number of Movies vs TV Shows
	
	select type,count(type)
	from netflix
	group by type

--2. Find the most common rating for movies and TV shows

		select type,rating from
			(
				select type,rating,
				dense_rank()over(partition by type order by count(rating) desc) as ranks
				from netflix
				group by type,rating
			) 
		where ranks=1

--3. List all movies released in a specific year (e.g., 2020)

	select * from netflix 
	where release_year=2020 and type='Movie'

--4. Find the top 5 countries with the most content on Netflix

		select 
		unnest(STRING_TO_ARRAY(country,','))as NEW_COUNTRY
		,count(show_id)
		from netflix
		group by 1
		order by count(show_id)desc
		limit 5 

--5. Identify the longest movie
		
		select * from netflix
		where type='Movie'
		and duration=
					(select max(duration) from netflix)

--6. Find content added in the last 5 years
	
		select * from netflix
		where
		to_date(date_added,'month dd,yyyy') >= current_date-interval '5 years'

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

		select * from netflix
		where director ilike'%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons

		select * from netflix
		where type='TV Show' and 
		split_part(duration,' ',1)::numeric > 5

--9. Count the number of content items in each 
	
		with contents as(
			select *,unnest(String_to_array(listed_in,',')) as gener 
			from netflix
			)
	select gener,count(show_id) as total_count 
	from contents 
	group by gener

/*10.Find each year and the average numbers of content release in India on netflix.
	return top 5 year with highest avg content release!*/

		SELECT 
	country,
	release_year,
	COUNT(show_id) as total_release,
	ROUND(
		COUNT(show_id)::numeric/
								(SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100 
		,2
		)
		as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY country, 2
ORDER BY avg_release DESC 
LIMIT 5


	
--11. List all movies that are documentaries
	
		select * from netflix 
		where listed_in ilike'%Documentaries%'
	
--12.Find all content without a director
		
		select * from netflix 
		where type ='Movie' and director is null
	
--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

		select count(*) from netflix
		where casts ilike'%Salman Khan%'
		and	to_date(date_added,'month dd,yyyy') >= current_date-interval '10 years'
		and type='Movie'

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
		
		with actor as(
			select *,(unnest(STRING_TO_ARRAY(casts,',')))as actors 
			from netflix
			)
	select actors,country,count(actors)
	from actor
	where country ilike'%india%'
	group by actors,country
	order by count(actors) desc
	limit 10

/*15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

		with categorize as(
			select *,
				case
					when description ilike'%kill%' or description ilike'%violence%'  then 'bad'
				else 'good' end as category
			from netflix
		)
	select category,count(show_id)
	from categorize
	group by category
	
	
	