SELECT
  s.sport_name,
  COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS medals
FROM results r
JOIN events e ON e.event_id = r.event_id
JOIN sports s ON s.sport_id = e.sport_id
GROUP BY s.sport_name
ORDER BY medals DESC
LIMIT 15;