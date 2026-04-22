WITH participation AS (WITH participation A... #25
  SELECT
    n.country,
    COUNT(*) AS starts,
    COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS medals
  FROM results r
  JOIN nocs n ON n.noc_code = r.noc_code
  GROUP BY n.country
)
SELECT
  country,
  starts,
  medals,
  ROUND(medals::numeric / NULLIF(starts,0), 4) AS medals_per_start
FROM participation
WHERE starts >= 500
ORDER BY medals_per_start DESC
LIMIT 15;