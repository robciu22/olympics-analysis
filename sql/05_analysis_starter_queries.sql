-- 05_analysis_starter_queries.sql
-- Zweck: Starter-Queries für den Analyse-Teil (Antares ODER psql)

-- 1) Medaillenspiegel Top 10 (athlete-level, d.h. Teammedaillen können mehrfach gezählt werden)
SELECT
  n.country,
  COUNT(*) FILTER (WHERE r.medal = 'Gold')   AS gold,
  COUNT(*) FILTER (WHERE r.medal = 'Silver') AS silver,
  COUNT(*) FILTER (WHERE r.medal = 'Bronze') AS bronze,
  COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS total_medals
FROM results r
JOIN nocs n ON n.noc_code = r.noc_code
GROUP BY n.country
ORDER BY total_medals DESC
LIMIT 10;

-- 2) Medaillen-Trend pro Jahr
SELECT
  g.year,
  COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS medals
FROM results r
JOIN games g ON g.games_id = r.games_id
GROUP BY g.year
ORDER BY g.year;

-- 3) Sportarten mit den meisten Medaillen
SELECT
  s.sport_name,
  COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS medals
FROM results r
JOIN events e ON e.event_id = r.event_id
JOIN sports s ON s.sport_id = e.sport_id
GROUP BY s.sport_name
ORDER BY medals DESC
LIMIT 15;

-- (Optional) Event-level Medaillen (zählt je Jahr+Event+Medal nur einmal; fairer bei Team-Events)
-- SELECT
--   n.country,
--   COUNT(DISTINCT (g.year, r.event_id, r.medal)) FILTER (WHERE r.medal IS NOT NULL) AS medals_event_level
-- FROM results r
-- JOIN nocs n  ON n.noc_code = r.noc_code
-- JOIN games g ON g.games_id = r.games_id
-- GROUP BY n.country
-- ORDER BY medals_event_level DESC
-- LIMIT 10;
