

-- Question 1 

SELECT MIN(year), MAX(year)
FROM homegames;
-- 1871 to 2016


-- Question 2 

SELECT playerid, namegiven, height
FROM people
ORDER BY height
LIMIT 1;
-- Edward Carl


WITH shortest_player_id AS (
	SELECT playerid
	FROM people
	ORDER BY height
	LIMIT 1
)
SELECT *
FROM appearances
JOIN shortest_player_id AS s USING(playerid);
 -- 1 Game

SELECT 
    namefirst, namelast,
    height,
    SUM(a.g_all) AS total_games,
    t.name AS team_name
FROM people
JOIN appearances a ON p.playerid = a.playerid
JOIN teams t ON a.teamid = t.teamid AND a.yearid = t.yearid
WHERE height = (
    SELECT MIN(height)
    FROM people
    WHERE height IS NOT NULL
)
GROUP BY namefirst, namelast, height, t.name;



-- Question 3 

SELECT 
    namefirst, namelast,
    SUM(s.salary) AS total_salary
FROM people
JOIN collegeplaying AS cp USING(playerid)
JOIN schools AS sch USING(schoolid)
JOIN salaries AS s USING(playerid)
WHERE sch.schoolname = 'Vanderbilt University'
GROUP BY namefirst, namelast
ORDER BY total_salary DESC;



-- Question 4 

SELECT CASE WHEN pos = 'OF' THEN 'Outfield'
    		WHEN pos IN ('1B', '2B', '3B', 'SS') THEN 'Infield'
    		WHEN pos IN ('P', 'C') THEN 'Battery' END AS position_group,
  		SUM(po) AS total_putouts
FROM fielding
WHERE yearid = 2016
  AND pos IN ('OF', '1B', '2B', '3B', 'SS', 'P', 'C')
GROUP BY position_group;



-- Question 5

SELECT CASE WHEN yearid BETWEEN 1920 AND 1929 THEN '1920s'
			WHEN yearid BETWEEN 1930 AND 1939 THEN '1930s'
			WHEN yearid BETWEEN 1940 AND 1949 THEN '1940s'
			WHEN yearid BETWEEN 1950 AND 1959 THEN '1950s'
			WHEN yearid BETWEEN 1960 AND 1969 THEN '1960s'
			WHEN yearid BETWEEN 1970 AND 1979 THEN '1970s'
			WHEN yearid BETWEEN 1980 AND 1989 THEN '1980s'
			WHEN yearid BETWEEN 1990 AND 1999 THEN '1990s'
			WHEN yearid BETWEEN 2000 AND 2009 THEN '2000s'
			WHEN yearid BETWEEN 2010 AND 2020 THEN '2010s' END AS decade,
			ROUND(SUM(so)::numeric / SUM(g), 2) AS avg_so_per_game,
			ROUND(SUM(hr)::numeric / SUM(g), 2) AS avg_hr_per_game


FROM batting
WHERE yearid >= 1920
GROUP BY decade;
-- Strikeouts increased greatly over time where homeruns have barely increased



-- Question 6 

SELECT playerid, namefirst, namelast,((sb::numeric) / ((sb::numeric) + (cs::numeric))) AS success_percentage
FROM batting
JOIN people USING(playerid)
WHERE yearid = 2016
GROUP BY playerid, sb, cs,namefirst, namelast
HAVING (sb + cs) >= 20
ORDER BY success_percentage DESC;



-- Question 7 

SELECT name, w
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'N'
ORDER BY w DESC;
-- Seattle Mariners

SELECT name, w, yearid
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'Y'
ORDER BY w ;
-- Los Angeles Dodgers, this was a year that had fewer games due to a strike from the players

SELECT name, w, yearid
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'Y' AND yearid <> 1981
ORDER BY w ;
-- St Louis Cardinals

WITH max_wins AS (
	SELECT yearid, MAX(w) AS highest_wins 
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid
)
SELECT name, yearid
FROM teams
JOIN max_wins AS mw USING(yearid)
WHERE w = highest_wins AND wswin = 'Y'
-- 12 Teams Won with having the most wins

WITH max_wins AS (
	SELECT yearid, MAX(w) AS highest_wins, COUNT(*)
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid
)
SELECT name, yearid
FROM teams
JOIN max_wins AS mw USING(yearid)
WHERE w = highest_wins AND wswin = 'Y'

-- Question 8 



-- Question 9 

WITH tsn_winners AS (
    SELECT 
        am.playerid,
        p.namefirst, p.namelast,
        am.yearid,
        am.lgid,
        m.teamid
    FROM awardsmanagers AS am
    JOIN people p ON am.playerid = p.playerid
    JOIN managers m ON am.playerid = m.playerid AND am.yearid = m.yearid
    WHERE am.awardid = 'TSN Manager of the Year'
),
dual_league_winners AS (
    SELECT playerid
    FROM tsn_winners
    GROUP BY playerid
    HAVING COUNT(DISTINCT lgid) >= 2
)
SELECT 
    t.namefirst, t.namelast,
    t.lgid,
    t.teamid,
    t.yearid
FROM tsn_winners AS t
JOIN dual_league_winners d ON t.playerid = d.playerid
ORDER BY t.namefirst, t.namelast, t.yearid;



-- Question 10 

WITH career_lengths AS (
  SELECT playerid
  FROM batting
  GROUP BY playerid
  HAVING COUNT(DISTINCT yearid) >= 10
),
hr_2016 AS (
  SELECT playerid, hr
  FROM batting
  WHERE yearid = 2016 AND hr > 0
),
career_highs AS (
  SELECT playerid, MAX(hr) AS max_hr
  FROM batting
  GROUP BY playerid
)
SELECT 
  p.namefirst, p.namelast,
  h.hr AS hr_in_2016
FROM hr_2016 AS h
JOIN career_lengths c ON h.playerid = c.playerid
JOIN career_highs ch ON h.playerid = ch.playerid AND h.hr = ch.max_hr
JOIN people p ON h.playerid = p.playerid
ORDER BY h.hr DESC;

























