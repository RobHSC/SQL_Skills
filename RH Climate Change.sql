-- Climate Change
-- This Codecademy Project examines climate data

-- 1 examine data
SELECT *
FROM state_climate
LIMIT 10
;

--2 average temp changes over time in each state
SELECT state
  , year
  , tempf
  , AVG(tempf) OVER (
      PARTITION BY state
      ORDER BY year
  ) AS 'running_avg_temp'
FROM state_climate
;

--3 lowest temperatures for each state
SELECT state
  , year
  , tempf
  , AVG(tempf) OVER (
      PARTITION BY state
      ORDER BY year
  ) AS 'running_avg_temp'
  , FIRST_VALUE(tempf) OVER (
      PARTITION BY state
      ORDER BY tempf
  ) AS 'lowest_temp'
FROM state_climate
;

--4 highest temperature for each state
SELECT state
  , year
  , tempf
  , LAST_VALUE(tempf) OVER (
      PARTITION BY state
      ORDER BY tempf
      RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS 'highest_temp'
FROM state_climate
;

--5 examine change in temperature from year to year
SELECT state
  , year
  , tempf
  , (tempf - LAG(tempf, 1, 0) OVER (
      PARTITION BY state
      ORDER BY year
  )
  ) AS 'change_in_temp'
FROM state_climate
ORDER BY change_in_temp DESC
;

--6 rank the coldest temperatures on record
SELECT state
  , year
  , tempf
  , RANK() OVER (
      ORDER BY tempf
  ) AS 'coldest_rank'
FROM state_climate
;

-- 7 rank the warmest temperatures
SELECT state
  , year
  , tempf
  , RANK() OVER (
      PARTITION BY state
      ORDER BY tempf DESC
  ) AS 'warmest_rank'
FROM state_climate
;

-- 8 return average yearly temperatures in quartiles
SELECT NTILE(4) OVER (
      PARTITION BY state
      ORDER BY tempf
  ) AS 'quartile'
  , state
  , year
  , tempf
FROM state_climate
;

-- 9 return average yearly temperatures in quintiles
SELECT NTILE(5) OVER (
            PARTITION BY state
            ORDER BY tempf
  ) AS 'quintile'
  , year
  , state
  , tempf
FROM state_climate
;
