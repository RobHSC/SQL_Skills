#this is a Codecademy Project based on data from Twitch, a streaming platform for gamers.
#Data is found here: https://github.com/Codecademy-Curriculum/Codecademy-Learn-SQL-from-Scratch/tree/master/Twitch
#It combines stream data and chat data

-- 1 examine the data
SELECT *
FROM stream
LIMIT 20;

SELECT *
FROM chat
LIMIT 20;

--2 examine unique games in stream table
SELECT DISTINCT game AS unique_games
FROM stream;

--3 examine unique channels in stream table
SELECT DISTINCT channel AS unique_channels
FROM stream;

--4 most popular games in stream table
SELECT game
  , COUNT(*) AS num_games
FROM stream
GROUP BY game
ORDER BY 2 DESC;

--5 League of Legends viewers locations
SELECT country
  , COUNT(*) AS LoL_viewers
FROM stream
WHERE game = 'League of Legends'
GROUP BY 1
ORDER BY 2 DESC;

--6 create a list of players and their number of streamers.
SELECT player
  , COUNT(*) AS num_streamers
FROM stream
GROUP BY 1
ORDER BY 2 DESC;

--7 create new column called genre for games
SELECT game
  , CASE
    WHEN game = 'League of Legends'
      THEN 'MOBA'
    WHEN game = 'DOTA 2'
      THEN 'MOBA'
    WHEN game = 'Heroes of the Storm'
      THEN 'MOBA'
    WHEN game = 'Counter-Strike: Global Offensive'
      THEN 'FPS'
    WHEN game = 'DayZ'
      THEN 'Survival'
    ELSE 'Other'
  END AS 'genre'
  , COUNT(*) AS num_streams
FROM stream
GROUP BY 1
ORDER BY 3 DESC;

--8 exame the time column
SELECT time
FROM stream
LIMIT 10;

--9 return formatted date seconds
SELECT time,
  strftime('%S', time)
FROM stream
GROUP BY 1
LIMIT 20;

--10 return hours of time column and view count for each hour for US
SELECT strftime('%H', time) AS 'hour'
  , COUNT(*) AS 'num_streams'
FROM stream
WHERE country = 'US'
GROUP BY 1
ORDER BY 2 DESC;

--11 join stream and chat table
SELECT *
FROM stream
JOIN chat
  USING (device_id);

--12 examine Heroes of the Storm counts
SELECT game
  , COUNT(*)
FROM stream
WHERE game = 'Heroes of the Storm';
