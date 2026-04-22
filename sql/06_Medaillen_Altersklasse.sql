WITH age_bands AS (
  SELECT
    CASE
      WHEN age IS NULL THEN 'Unknown'
      WHEN age < 20 THEN '<20'
      WHEN age BETWEEN 20 AND 24 THEN '20-24'
      WHEN age BETWEEN 25 AND 29 THEN '25-29'
      WHEN age BETWEEN 30 AND 34 THEN '30-34'
      WHEN age BETWEEN 35 AND 39 THEN '35-39'
      ELSE '40+'
    END AS age_band,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS medals
  FROM results
  GROUP BY 1
),
tot AS (
  SELECT SUM(medals) AS total_medals FROM age_bands
)
SELECT
  a.age_band,
  a.medals,
  ROUND(100.0 * a.medals / NULLIF(t.total_medals,0), 2) AS pct
FROM age_bands a
CROSS JOIN tot t
ORDER BY
  CASE a.age_band
    WHEN '<20' THEN 1 WHEN '20-24' THEN 2 WHEN '25-29' THEN 3
    WHEN '30-34' THEN 4 WHEN '35-39' THEN 5 WHEN '40+' THEN 6
    ELSE 7
  END;
