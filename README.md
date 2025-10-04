# Netflix Movies and TV shows Data Analysis Using SQL 

![Netflix logo](https://github.com/samseptwo/Netflix_sql_project/blob/main/Movie%20Buff.jpg)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.


## Schema

```sql
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select type,count(type)
	from netflix
	group by type
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
select type,rating from
			(
				select type,rating,
				dense_rank()over(partition by type order by count(rating) desc) as ranks
				from netflix
				group by type,rating
			) 
		where ranks=1
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
select * from netflix 
	where release_year=2020 and type='Movie'
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
select 
		unnest(STRING_TO_ARRAY(country,','))as NEW_COUNTRY
		,count(show_id)
		from netflix
		group by 1
		order by count(show_id)desc
		limit 5 
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
select * from netflix
		where type='Movie'
		and duration=
					(select max(duration) from netflix)
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
select * from netflix
		where
		to_date(date_added,'month dd,yyyy') >= current_date-interval '5 years'
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
select * from netflix
		where director ilike'%Rajiv Chilaka%'
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
select * from netflix
		where type='TV Show' and 
		split_part(duration,' ',1)::numeric > 5
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
with contents as(
			select *,unnest(String_to_array(listed_in,',')) as gener 
			from netflix
			)
	select gener,count(show_id) as total_count 
	from contents 
	group by gener
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql

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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
select * from netflix 
		where listed_in ilike'%Documentaries%'
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
select * from netflix 
		where type ='Movie' and director is null
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
select count(*) from netflix
		where casts ilike'%Salman Khan%'
		and	to_date(date_added,'month dd,yyyy') >= current_date-interval '10 years'
		and type='Movie'
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.


