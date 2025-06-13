---1.
SELECT
  MIN(yearid) AS first_year,
  MAX(yearid) AS last_year
FROM teams;

---2.
SELECT * 
FROM people;

SELECT
  p.namefirst,  p.namelast, p.height, a.g_all AS games_played, t.name AS team_name
FROM people AS p
JOIN appearances AS a ON p.playerid = a.playerid
JOIN teams AS t ON a.yearid = t.yearid AND a.teamid = t.teamid
WHERE p.height = (
  SELECT MIN(height)
  FROM people
  WHERE height IS NOT NULL
)
ORDER BY a.g_all DESC
LIMIT 1;

---3. VANDERBILT is vandy
SELECT schoolid
FROM collegeplaying
WHERE schoolid = 'vandy'
ORDER BY schoolid DESC;


SELECT
  p.namefirst,
  p.namelast,
  SUM(s.salary) AS total_salary
FROM collegeplaying AS c
JOIN people AS p ON c.playerid = p.playerid
JOIN salaries AS s ON p.playerid = s.playerid
WHERE c.schoolid = 'vandy'
GROUP BY p.namefirst, p.namelast 
ORDER BY total_salary DESC;
---LIMIT 1

---4. 
SELECT
  CASE
    WHEN pos = 'OF' THEN 'Outfield'
    WHEN pos IN ('1B', '2B', '3B', 'SS') THEN 'Infield'
    WHEN pos IN ('P', 'C') THEN 'Battery'
  END AS position_group,
  SUM(po) AS total_putouts
FROM fielding
WHERE yearid = 2016
  AND pos IN ('OF', '1B', '2B', '3B', 'SS', 'P', 'C')
GROUP BY position_group;

---5.
SELECT
  (yearid / 10) * 10 AS decade,
  ROUND(SUM(so)::numeric / SUM(g/2), 2) AS avg_strikeouts_per_game,
  ROUND(SUM(hr)::numeric / SUM(g/2), 2) AS avg_home_runs_per_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;

---6.
SELECT playerid, yearid, cs, sb,
ROUND((sb::numeric/(cs::numeric+sb::numeric))*100, 2) AS sb_success_perc
FROM batting
WHERE sb > 20 AND yearid = 2016 AND cs IS NOT NULL
ORDER BY sb_success_perc DESC;

---SELECT *
---FROM batting 
---WHERE cs IS NULL;





---7.
-- Largest wins without WS title
SELECT MAX(w) AS max_wins_no_ws,
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
  AND wswin IS DISTINCT FROM 'Y';

-- Smallest wins with WS title
SELECT MIN(w) AS min_wins_with_ws,
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
  AND wswin = 'Y';
---Redo to remove outlier 
 SELECT MIN(w) AS min_wins_with_ws_excl_2006
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
  AND wswin = 'Y'
  AND yearid <> 2006;

---Times most wins won the WS and percentage
WITH max_wins_per_year AS (
  SELECT yearid, MAX(w) AS max_wins
  FROM teams
  WHERE yearid BETWEEN 1970 AND 2016
  GROUP BY yearid
),
top_teams AS (
  SELECT t.yearid, t.teamid, t.w, t.wswin
  FROM teams AS t
  JOIN max_wins_per_year AS m
    ON t.yearid = m.yearid AND t.w = m.max_wins
  WHERE t.yearid BETWEEN 1970 AND 2016
)
SELECT
  COUNT(DISTINCT yearid) AS total_years,
  COUNT(*) FILTER (WHERE wswin = 'Y') AS years_top_team_won_ws,
  ROUND(
    COUNT(*) FILTER (WHERE wswin = 'Y') * 100.0 / COUNT(*),
    2
  ) AS pct_top_team_won_ws
FROM top_teams;


  
---8.
---Top 5 average attendance parks
SELECT
  pk.park_name,
  tm.name AS team_name,
  ROUND(hg.attendance::numeric / hg.games, 2) AS avg_attendance
FROM homegames AS hg
JOIN parks AS pk ON hg.park = pk.park
JOIN teams AS tm ON hg.team = tm.teamid AND hg.year = tm.yearid
WHERE hg.year = 2016
  AND hg.games >= 10
ORDER BY avg_attendance DESC
LIMIT 5;




---Bottom 5 average attendance parks
SELECT
  pk.park_name,
  tm.name AS team_name,
  ROUND(hg.attendance::numeric / hg.games, 2) AS avg_attendance
FROM homegames AS hg
JOIN parks AS pk ON hg.park = pk.park
JOIN teams AS tm ON hg.team = tm.teamid AND hg.year = tm.yearid
WHERE hg.year = 2016
  AND hg.games >= 10
ORDER BY avg_attendance ASC
LIMIT 5;


---9.
WITH dual_league_winners AS (
  SELECT playerid
  FROM awardsmanagers
  WHERE awardid = 'TSN Manager of the Year'
  GROUP BY playerid
  HAVING COUNT(DISTINCT lgid) = 2
)

SELECT
  p.namefirst || ' ' || p.namelast AS manager_name,
  t.name AS team_name,
  am.lgid,
  am.yearid AS award_year
FROM awardsmanagers AS am
JOIN dual_league_winners AS dlw ON am.playerid = dlw.playerid
JOIN people AS p ON am.playerid = p.playerid
JOIN managers AS m ON am.playerid = m.playerid AND am.yearid = m.yearid
JOIN teams AS t ON m.teamid = t.teamid AND m.yearid = t.yearid
WHERE am.awardid = 'TSN Manager of the Year'
ORDER BY manager_name, am.yearid;



---10.
---Find all players who hit their career highest number of home runs in 2016. Consider only players who have played 
---in the league for at least 10 years, and who hit at least one home run in 2016. 
---Report the players' first and last names and the number of home runs they hit in 2016.

SELECT *
FROM people AS p
JOIN batting AS b ON p.playerid = b.playerid
WHERE b.yearid = 2016;

WITH player_season_counts AS (
  SELECT playerid, COUNT(DISTINCT yearid) AS seasons_played
  FROM batting
  GROUP BY playerid
),
player_max_hr AS (
  SELECT playerid, MAX(hr) AS career_high_hr
  FROM batting
  GROUP BY playerid
),
hr_2016 AS (
  SELECT playerid, hr AS hr_2016
  FROM batting
  WHERE yearid = 2016 AND hr > 0
)
SELECT
  p.namefirst,
  p.namelast,
  h.hr_2016
FROM hr_2016 AS h
JOIN player_max_hr AS m ON h.playerid = m.playerid AND h.hr_2016 = m.career_high_hr
JOIN player_season_counts AS sc ON h.playerid = sc.playerid AND sc.seasons_played >= 10
JOIN people AS p ON h.playerid = p.playerid
ORDER BY h.hr_2016 DESC;


























































