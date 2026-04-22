SELECT
  n.country,
  COUNT(*) FILTER (WHERE r.medal='Gold')   AS gold,
  COUNT(*) FILTER (WHERE r.medal='Silver') AS silver,
  COUNT(*) FILTER (WHERE r.medal='Bronze') AS bronze,
  COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS total_medals
FROM results r
JOIN nocs n ON n.noc_code = r.noc_code
GROUP BY n.country
ORDER BY total_medals DESC
LIMIT 10;