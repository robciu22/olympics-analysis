SELECT
  s.sport_name,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY r.age) AS median_medal_age,
  COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS medals
FROM results r
JOIN events e ON e.event_id = r.event_id
JOIN sports s ON s.sport_id = e.sport_id
WHERE r.medal IS NOT NULL AND r.age IS NOT NULL
GROUP BY s.sport_name
HAVING COUNT(*) FILTER (WHERE r.medal IS NOT NULL) >= 50
ORDER BY medals DESC;