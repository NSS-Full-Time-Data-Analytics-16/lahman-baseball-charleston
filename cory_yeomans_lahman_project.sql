

-- Question 1 

SELECT MIN(yearid), MAX(yearid)
FROM teams;
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
			ROUND(SUM(so)::numeric / (SUM(g)/2), 2) AS avg_so_per_game,
			ROUND(SUM(hr)::numeric / (SUM(g)/2), 2) AS avg_hr_per_game


FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;
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
	),
	max_winning_teams AS (
		SELECT name, yearid
		FROM teams
		JOIN max_wins AS mw USING(yearid)
		WHERE w = highest_wins AND wswin = 'Y'
	)
SELECT COUNT(*) AS teams_total, COUNT(mwt.name) AS teams_with_max_wins, 
		(COUNT(mwt.name)::numeric)/(COUNT(*)::numeric) AS percentage_of_ws_max_wins
FROM max_wins
LEFT JOIN max_winning_teams AS mwt USING(yearid);
-- About 25.5% 



-- Question 8 

SELECT t.name, park_name, (SUM(hg.attendance::numeric)/SUM(hg.games::numeric)) AS avg_attendance_per_game
FROM homegames AS hg
JOIN parks AS p USING(park)
JOIN teams AS t ON hg.team = t.teamid
WHERE hg.year = 2016 AND hg.games >= 10 AND t.yearid = 2016
GROUP BY t.name, park_name
ORDER BY avg_attendance_per_game DESC;

SELECT t.name, park_name, (SUM(hg.attendance::numeric)/SUM(hg.games::numeric)) AS avg_attendance_per_game
FROM homegames AS hg
JOIN parks AS p USING(park)
JOIN teams AS t ON hg.team = t.teamid
WHERE hg.year = 2016 AND hg.games >= 10 AND t.yearid = 2016
GROUP BY t.name, park_name
ORDER BY avg_attendance_per_game;



-- Question 9 

WITH tsn_winners_ids AS (
		(SELECT playerid
		FROM awardsmanagers
		WHERE awardid = 'TSN Manager of the Year' AND lgid = 'NL')
	INTERSECT
		(SELECT playerid
		FROM awardsmanagers
		WHERE awardid = 'TSN Manager of the Year' AND lgid = 'AL')
		),
	manager_id_and_year AS (
		SELECT playerid, yearid, lgid
		FROM awardsmanagers
		JOIN tsn_winners_ids USING(playerid)
)
SELECT myi.playerid, myi.yearid, myi.lgid, namefirst, namelast, teamid, t.name
FROM manager_id_and_year AS myi
LEFT JOIN people USING(playerid)
JOIN managers AS m USING(playerid)
JOIN teams AS t USING(teamid)
WHERE myi.yearid = m.yearid AND myi.yearid = t.yearid
ORDER BY myi.lgid;
-- 2 people, Jim Leyland and Davey Johnson



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
JOIN career_highs ch ON h.playerid = ch.playerid
JOIN people p ON h.playerid = p.playerid
WHERE h.hr = ch.max_hr;



-- Question 11 

SELECT t.yearid, t.name, SUM(w) AS total_wins, (AVG(salary))
FROM teams AS t
JOIN salaries AS s USING(teamid)
WHERE t.yearid >= 2000
GROUP BY t.yearid, t.name
ORDER BY t.yearid, total_wins DESC;
-- There is a slight pattern of higher salaries going to more winning teams and vice versa 
-- but mostly there are a lot of outliers such as big names in the sport having high salaries regradless 
-- of wins such as New York Yankees and Boston Red Sox and there was a pattern of a very avg salary team 
-- (Oakland Athletics) having a high amount of wins even though their salaries were consistently low for a large span of time



-- Question 12 


-- Part A
SELECT t.name, park_name, (SUM(hg.attendance::numeric)/SUM(hg.games::numeric)) AS avg_attendance_per_game, SUM(t.w)
FROM homegames AS hg
JOIN parks AS p USING(park)
JOIN teams AS t ON hg.team = t.teamid
WHERE hg.year = 2012 AND hg.games >= 10 AND t.yearid = 2012
GROUP BY t.name, park_name
ORDER BY avg_attendance_per_game DESC;
-- There is a little evidence that could suggest the attendance correlates with the wins as it seems the top 50% of highest 
-- attendings gets wins in the low 80s to high 90s with one team even peaking 100 whereas then bottom 50% has mostly ranges 
-- in the high 60s to mid 80s although it is impportant this seems to fluxuate greatly throughout the years, especially in 
-- 2012 and 2013 where the pattern doesn't appear to be as true.

















