-- SQL Mini Project 10/10
-- SQL Mentor User Performance

DROP TABLE user_submissions; 

CREATE TABLE user_submissions (
    id SERIAL PRIMARY KEY,
    user_id BIGINT,
    question_id INT,
    points INT,
    submitted_at TIMESTAMP WITH TIME ZONE,
    username VARCHAR(30)
);

SELECT * FROM user_submissions;


-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
-- Q.2 Calculate the daily average points for each user.
-- Q.3 Find the top 3 users with the most positive submissions for each day.
-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
-- Q.5 Find the top 10 performers for each week.


-- Please note for each questions return current stats for the users
-- user_name, total points earned, correct submissions, incorrect submissions no


-- -------------------
-- My Solutions
-- -------------------

-- Q.1 List all distinct users and their stats (return user_name, total_submissions, points earned)
SELECT 
	 username,
	 COUNT(id) AS total_submissions,
	 SUM(points) AS points_earned
FROM user_submissions
GROUP BY 1
ORDER BY total_submissions DESC

-- Q.2 Calculate the daily average points for each user.
--each day
--each user and their daily avg points
--group by day or user

Direction of Conversion: TO_DATE converts a string to a date, while TO_CHAR converts a date to a string.
Purpose: TO_DATE is used to interpret string representations of dates for database operations, 
while TO_CHAR is used to format dates for display or string manipulation.

SELECT *
FROM user_submissions

SELECT 
	--EXTRACT (DAY FROM submitted_at) as day,
	 TO_CHAR(submitted_at, 'DD-MM') as day,
	 username,
	 AVG(points) AS daily_avg_points
FROM user_submissions
GROUP BY 1,2
ORDER BY 3 DESC


-- Q.3 Find the top 3 users with the most positive submissions for each day.
WITH daily_submissions
AS
(
	SELECT 
		-- EXTRACT(DAY FROM submitted_at) as day,
		TO_CHAR(submitted_at, 'DD-MM') as daily,
		username,
		SUM(CASE 
			WHEN points > 0 THEN 1 ELSE 0
		END) as correct_submissions
	FROM user_submissions
	GROUP BY 1, 2
),
users_rank
as
(SELECT 
	daily,
	username,
	correct_submissions,
	DENSE_RANK() OVER(PARTITION BY daily ORDER BY correct_submissions DESC) as rank
FROM daily_submissions
)

SELECT 
	daily,
	username,
	correct_submissions
FROM users_rank
WHERE rank <= 3;

-- Q.4 Find the top 5 users with the highest number of incorrect submissions.
SELECT 
	username,
	SUM(CASE 
		WHEN points < 0 THEN 1 ELSE 0
	    END) as incorrect_submissions,
	SUM(CASE 
		WHEN points > 0 THEN 1 ELSE 0
	    END) as correct_submissions,
	SUM(CASE 
		WHEN points < 0 THEN points ELSE 0
	    END) as incorrect_point_loses,
	SUM(CASE 
		WHEN points > 0 THEN points ELSE 0
	    END) as correct_submissions_point_earned
FROM user_submissions
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Q.5 Find the top 10 performers for each week.
SELECT * 
FROM (
	SELECT 
		--WEEK() in mysql
		EXTRACT(WEEK FROM submitted_at) AS week_no,
		SUM(points) AS total_points_earned,
		username,
		DENSE_RANK() OVER (PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) as points_each_week
	FROM user_submissions
	GROUP BY 1,3
	ORDER BY week_no,total_points_earned DESC

)
WHERE points_each_week <=10



