SELECT
  g.year,
  s.sport_name,
  COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS medals
FROM results r
JOIN games  g ON g.games_id = r.games_id
JOIN events e ON e.event_id = r.event_id
JOIN sports s ON s.sport_id = e.sport_id
GROUP BY g.year, s.sport_name
ORDER BY g.year, medals DESC;