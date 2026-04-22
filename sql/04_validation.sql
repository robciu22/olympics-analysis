-- 04_validation.sql
-- Zweck: Validierungs-Queries nach Import (Antares ODER psql)
-- Ausführung: Antares (SQL-Tab) ODER Terminal (psql)
--   psql -d projekt_olympics -f 04_validation.sql

-- A) Tabellegrößen (Sanity Check)
SELECT 'athletes' AS table, COUNT(*) FROM athletes
UNION ALL SELECT 'nocs', COUNT(*) FROM nocs
UNION ALL SELECT 'games', COUNT(*) FROM games
UNION ALL SELECT 'sports', COUNT(*) FROM sports
UNION ALL SELECT 'events', COUNT(*) FROM events
UNION ALL SELECT 'results', COUNT(*) FROM results;

-- B) Medal-Verteilung (ENUM/NULL)
SELECT medal, COUNT(*)
FROM results
GROUP BY medal
ORDER BY medal;

-- C) Duplikate in events? (sollte 0 Zeilen liefern)
SELECT sport_id, event_name, COUNT(*) AS cnt
FROM events
GROUP BY sport_id, event_name
HAVING COUNT(*) > 1
ORDER BY cnt DESC;

-- (Optional) Status-Ausgabe, die IMMER 1 Zeile liefert
SELECT
  CASE WHEN EXISTS (
    SELECT 1
    FROM events
    GROUP BY sport_id, event_name
    HAVING COUNT(*) > 1
  )
  THEN 'DUPLICATES FOUND'
  ELSE 'OK: no duplicates'
  END AS status;

-- D) Referentielle Integrität: fehlen Referenzen aus results?
SELECT COUNT(*) AS missing_athletes
FROM results r
LEFT JOIN athletes a ON a.athlete_id = r.athlete_id
WHERE a.athlete_id IS NULL;

SELECT COUNT(*) AS missing_games
FROM results r
LEFT JOIN games g ON g.games_id = r.games_id
WHERE g.games_id IS NULL;

SELECT COUNT(*) AS missing_events
FROM results r
LEFT JOIN events e ON e.event_id = r.event_id
WHERE e.event_id IS NULL;

SELECT COUNT(*) AS missing_nocs
FROM results r
LEFT JOIN nocs n ON n.noc_code = r.noc_code
WHERE n.noc_code IS NULL;
