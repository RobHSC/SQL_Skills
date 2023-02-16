USE Cinema;
SELECT *
FROM Movie;
SELECT *
FROM Rating;
SELECT *
FROM Reviewer;

-- created a combined table of the above tables
CREATE TABLE if not exists Movie_Reviews (SELECT Rating.*
	, Movie.title
    , Movie.year
    , Movie.director
    , Reviewer.name AS reviewer_name
FROM Rating
RIGHT JOIN Movie
	ON Rating.mID = Movie.mID
LEFT JOIN Reviewer
	ON Rating.rID = Reviewer.rID);

SELECT *
FROM Movie_Reviews;
-- Q1. Find the titles of all movies directed by Steven Spielberg.
SELECT title, director
FROM Movie
WHERE director = 'Steven Spielberg';
-- Answer: E.T. and Raiders of the Lost Ark

-- Q2. Find the movies names that contain the word "THE"
SELECT title
FROM Movie
WHERE title LIKE '%the%';
-- Answer: Gone with the Wind, The Sound of Music, Raiders of the Lost Ark

-- Q3. Find those rating records higher than 3 stars before 2011/1/15 or after 2011/1/20 

SELECT rID, mID, title, stars, ratingDate
FROM Movie_Reviews
WHERE stars > 3
	AND (ratingDate < '2011-01-15' OR ratingDate > '2011-01-20');
-- Answer: rID 201 mID 101 Gone with the Wind and rID 203 mID 108 Raiders of the Lost Ark

/* Q4. Some reviewers did rating on the same movie more than once. 
How many rating records are there with different movie and different reviewer's rating? */

SELECT COUNT(DISTINCT rID, mID) AS diff_rID_mID
FROM Rating;

-- Answer: 12

-- Q5. Which are the top 3 records with the highest ratings?
SELECT mID
	, title
    , AVG(stars) AS average_rating
FROM Movie_Reviews
GROUP BY mID, title
ORDER BY 3 DESC
LIMIT 3;
-- Answer A: mID: 106, average rating: 4.5; mID 107, average rating: 4.0; mID 108, average rating: 3.3;

SELECT *
FROM Movie_Reviews
ORDER BY stars DESC
LIMIT 10;

/*
Answer B: OR the top 3 reviews are rID 207 on 2011-01-20 with 5 stars,
rID 206 on 2011-01-19 with 5 stars,
and rID 202 without a date with 4 stars rID 203 on 2011-01-12
Note that there are FOUR reviews with 4 stars including the previous one and they are not listed 
To see these, I would do LIMIT 6 or I would show all reviews with stars >= 4.
*/

-- Q6. Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
SELECT year
FROM Movie_Reviews
WHERE stars IN (4, 5)
GROUP BY year
ORDER BY year;
-- Answer: 1937, 1939, 1981, 2009


-- Q7. Find the titles of all movies that have no ratings.
SELECT title
FROM Movie
LEFT JOIN Rating
	ON Movie.mID = Rating.mID
WHERE stars IS NULL;
-- ANSWER: Star Wars and Titanic have no ratings

/* Q8. Some reviewers didn't provide a date with their rating. 
 Find the names of all reviewers who have ratings with a NULL value for the date. */
SELECT reviewer_name, ratingdate
FROM Movie_Reviews
WHERE ratingdate IS NULL;

 -- Answer: Daniel Lewis and Chris Jackson have reviews with NULL values
 
/* Q9. Write a query to return the ratings data in a more readable format in only one field(column): 
"reviewer name, movie title, stars, ratingDate". 
Assign a new name to the new column as "Review_details"
Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 
Hint: join three tables, using join twice. 
Hint: use CONCAT_WS(separator, string1, string2) instead of CONCAT() for creating new column because of NULL values */

SELECT CONCAT_WS(', '
	, Reviewer.name
	, Movie.title
    , Rating.stars
    , Rating.ratingDate
    ) AS Review_details
FROM Rating
RIGHT JOIN Movie
	ON Rating.mID = Movie.mID
LEFT JOIN Reviewer
	ON Rating.rID = Reviewer.rID
ORDER BY name, title, stars DESC;