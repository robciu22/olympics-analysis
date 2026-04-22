-- Rowcounts
SELECT 'athletes' t, COUNT(*) c FROM athletes
UNION ALL SELECT 'nocs', COUNT(*) FROM nocs
UNION ALL SELECT 'games', COUNT(*) FROM games
UNION ALL SELECT 'sports', COUNT(*) FROM sports
UNION ALL SELECT 'events', COUNT(*) FROM events
UNION ALL SELECT 'results', COUNT(*) FROM results;

-- Medaillenverteilung
SELECT medal, COUNT(*) 
FROM results
GROUP BY medal
ORDER BY COUNT(*) DESC;