WITH per_year AS (
  SELECT
    g.year,
    n.country,
    COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS medals
  FROM results r
  JOIN games g ON g.games_id = r.games_id
  JOIN nocs  n ON n.noc_code = r.noc_code
  GROUP BY g.year, n.country
),
ranked AS (
  SELECT *,
         DENSE_RANK() OVER (PARTITION BY year ORDER BY medals DESC) AS rk
  FROM per_year
)
SELECT year, country, medals
FROM ranked
WHERE rk <= 3
ORDER BY year, medals DESC;