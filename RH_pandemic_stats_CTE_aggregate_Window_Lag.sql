USE pandemic;
SELECT *
FROM demographics;
SELECT *
FROM statistics;

/*Q1.Compute new cases for each day.
Q1. compute the difference per state;
total new cases = sum(new cases per state) */
WITH stats AS
	(SELECT date
		, state
		, CASE
			WHEN total_cases - LAG(total_cases, 1, 0) OVER
				(PARTITION BY state
				ORDER BY date) > 0
			THEN total_cases - LAG(total_cases, 1, 0) OVER
				(PARTITION BY state
				ORDER BY date)
			ELSE 0
		END AS new_cases
	FROM statistics
	)
SELECT date
	, SUM(new_cases) AS total_new_cases
FROM stats
GROUP BY date
ORDER BY date;

/*Q2.To account for "administrative weekends" with fewer reports or missing data, 
compute the smoothed rolling average between two preceding days and two following days. */
WITH stats AS
	(SELECT date
		, state
		, CASE
			WHEN total_cases - LAG(total_cases, 1, 0) OVER
				(PARTITION BY state
				ORDER BY date) >0
			THEN total_cases - LAG(total_cases, 1, 0) OVER
				(PARTITION BY state
				ORDER BY date)
			ELSE 0
		END AS new_cases
		, CASE
			WHEN total_deaths - LAG(total_deaths, 1, 0) OVER
				(PARTITION BY state
				ORDER BY date) >0
			THEN total_deaths - LAG(total_deaths, 1, 0) OVER
				(PARTITION BY state
				ORDER BY date)
			ELSE 0
		END AS new_deaths
	FROM statistics
	)
, stats2 AS
	(SELECT date
		, state 
		, AVG(new_cases) 
			 OVER (ORDER BY date ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS state_smoothed_average_cases
		, AVG(new_deaths) 
			 OVER (ORDER BY date ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS state_smoothed_average_deaths 
	FROM stats
	)
SELECT date
	, ROUND(AVG(state_smoothed_average_cases), 2) AS smoothed_average_cases
	, ROUND(AVG(state_smoothed_average_deaths), 2) AS smoothed_average_deaths
FROM stats2
GROUP BY date
;
/*Q3. Fetch latest available per state data from statistics. Note that states may have different latest submission dates. (hint: ROW_NUMBER())*/
WITH stats AS
	(SELECT *
		    , CASE
				WHEN total_cases - LAG(total_cases, 1, 0) OVER
					(PARTITION BY state
					ORDER BY date) >0
				THEN total_cases - LAG(total_cases, 1, 0) OVER
					(PARTITION BY state
					ORDER BY date)
				ELSE 0
			END AS new_cases
			, CASE
				WHEN total_deaths - LAG(total_deaths, 1, 0) OVER
					(PARTITION BY state
					ORDER BY date) >0
				THEN total_deaths - LAG(total_deaths, 1, 0) OVER
					(PARTITION BY state
					ORDER BY date)
				ELSE 0
			END AS new_deaths
			, ROW_NUMBER() OVER
				(PARTITION BY state
				ORDER BY date DESC)
				AS row_num
	FROM statistics
    )
SELECT *
	, AVG(stats.new_cases)
		OVER w AS rolling_5_day_avg_cases
	, AVG(stats.new_deaths)
	OVER w AS rolling_5_day_avg_deaths
FROM stats
WHERE row_num = 1
WINDOW w AS 
	(PARTITION BY state
    ORDER BY date
    ROWS BETWEEN 2 PRECEDING and 2 FOLLOWING)
;

/*Q4.Use the "latest data" derived from the above query and demographic information to compute the mortality per 100,000 population.*/
WITH stats AS
	(SELECT *
		, CASE
			WHEN total_cases - LAG(total_cases, 1, 0) OVER
				(PARTITION BY state
				ORDER BY date) >0
			THEN total_cases - LAG(total_cases, 1, 0) OVER
				(PARTITION BY state
				ORDER BY date)
			ELSE 0
		END AS new_cases
		, CASE
			WHEN total_deaths - LAG(total_deaths, 1, 0) OVER
				(PARTITION BY state
				ORDER BY date) >0
			THEN total_deaths - LAG(total_deaths, 1, 0) OVER
				(PARTITION BY state
				ORDER BY date)
			ELSE 0
		END AS new_deaths
		, ROW_NUMBER() OVER
			(PARTITION BY state
			ORDER BY date DESC)
			AS row_num
	FROM statistics
    )
SELECT *
	, AVG(stats.new_cases)
		OVER w AS rolling_5_day_avg_cases
	, AVG(stats.new_deaths)
		OVER w AS rolling_5_day_avg_deaths
    , 100000 * total_deaths / population AS mortality_per_100k
FROM stats
JOIN demographics
	USING (state)
WHERE row_num = 1
WINDOW w AS 
	(PARTITION BY state
    ORDER BY date
    ROWS BETWEEN 2 PRECEDING and 2 FOLLOWING
    )
;

/*Q5.Find the biggest spike in new deaths per country. Sort them by the most recent date, then by the count of new deaths. (hint: RANK())*/
WITH stats AS
	(SELECT *
		, CASE
		WHEN total_cases - LAG(total_cases, 1, 0) OVER
			(PARTITION BY state
			ORDER BY date) >0
        THEN total_cases - LAG(total_cases, 1, 0) OVER
			(PARTITION BY state
			ORDER BY date)
        ELSE 0
		END AS new_cases
		, CASE
			WHEN total_deaths - LAG(total_deaths, 1, 0) OVER
				(PARTITION BY state
				ORDER BY date) >0
			THEN total_deaths - LAG(total_deaths, 1, 0) OVER
				(PARTITION BY state
				ORDER BY date)
			ELSE 0
		END AS new_deaths
		, ROW_NUMBER() OVER
			(PARTITION BY state
			ORDER BY date DESC)
			AS row_num
	FROM statistics
    )
, stats2 AS
		(SELECT *
			, AVG(stats.new_cases)
				OVER w AS rolling_5_day_avg_cases
			, AVG(stats.new_deaths)
				OVER w AS rolling_5_day_avg_deaths
			, 100000 * total_deaths / population AS mortality_per_100k
			, RANK() OVER
				(
				PARTITION BY STATE
				ORDER BY new_deaths DESC
				) AS spike_rank
	FROM stats
	JOIN demographics
		USING (state)
	WINDOW w AS 
		(PARTITION BY state
		ORDER BY date
		ROWS BETWEEN 2 PRECEDING and 2 FOLLOWING
        )
	)
SELECT state
	, date
    , total_cases
    , total_deaths
    , new_cases
    , new_deaths
    , population
    , ROUND(rolling_5_day_avg_cases, 2) AS rolling_5_day_avg_cases
    , ROUND(rolling_5_day_avg_deaths, 2) AS rolling_5_day_avg_deaths
    , ROUND(mortality_per_100k, 2) AS mortality_per_100k
FROM stats2
WHERE spike_rank = 1
ORDER BY date DESC, new_deaths DESC
;