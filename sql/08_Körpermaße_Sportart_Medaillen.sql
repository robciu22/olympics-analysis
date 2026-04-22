SELECT
  s.sport_name,
  ROUND(AVG(r.height_cm) FILTER (WHERE r.medal IS NOT NULL AND r.height_cm IS NOT NULL), 2) AS avg_height_medal_cm,
  ROUND(AVG(r.weight_kg) FILTER (WHERE r.medal IS NOT NULL AND r.weight_kg IS NOT NULL), 2) AS avg_weight_medal_kg,
  COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS medals,
  COUNT(r.height_cm) FILTER (WHERE r.medal IS NOT NULL) AS n_height,
  COUNT(r.weight_kg) FILTER (WHERE r.medal IS NOT NULL) AS n_weight
FROM results r
JOIN events e ON e.event_id = r.event_id
JOIN sports s ON s.sport_id = e.sport_id
GROUP BY s.sport_name
HAVING COUNT(*) FILTER (WHERE r.medal IS NOT NULL) >= 100
ORDER BY medals DESC;
