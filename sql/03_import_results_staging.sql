-- 03_import_results_staging.sql
-- Zweck: results.csv robust importieren (FK-Probleme + Medal-ENUM sauber behandeln)
-- Ausführung: NUR im Terminal via psql (wegen \copy)
-- Beispiel:
--   psql -d projekt_olympics -f 03_import_results_staging.sql
--
-- Idee:
-- 1) results_stage mit medal als TEXT anlegen
-- 2) results.csv in results_stage \copy'n
-- 3) fehlende NOCs automatisch in nocs ergänzen (country='Unknown')
-- 4) results leeren und aus stage in die echte results-Tabelle schreiben
--    dabei medal: '' -> NULL und dann Cast auf medal_enum
-- 5) stage wieder löschen

\set ON_ERROR_STOP on

-- >>> HIER DEINEN ORDNER EINTRAGEN (ABSOLUTER PFAD) <<<
\set data_dir '/ABSOLUTER/PFAD/ZU/Olympics_Normalisiert'

BEGIN;

-- 1) Stage neu erstellen
DROP TABLE IF EXISTS results_stage;

CREATE TABLE results_stage (
  result_id   INT,
  athlete_id  INT,
  games_id    INT,
  noc_code    CHAR(3),
  event_id    INT,
  age         INT,
  height_cm   NUMERIC(5,1),
  weight_kg   NUMERIC(5,1),
  medal       TEXT
);

-- 2) CSV in Stage importieren
\echo 'Import results.csv into results_stage...'
\copy results_stage
FROM :'data_dir'/results.csv
WITH (FORMAT csv, HEADER true);

-- 3) Fehlende NOCs ergänzen, damit FK später nicht scheitert
\echo 'Upsert missing NOC codes into nocs (country=Unknown)...'
INSERT INTO nocs (noc_code, country)
SELECT DISTINCT rs.noc_code, 'Unknown'
FROM results_stage rs
LEFT JOIN nocs n ON n.noc_code = rs.noc_code
WHERE n.noc_code IS NULL
  AND rs.noc_code IS NOT NULL
ON CONFLICT (noc_code) DO NOTHING;

-- 4) Finale results befüllen (medal: '' -> NULL -> medal_enum)
\echo 'Load final results from stage (casting medal to medal_enum)...'
TRUNCATE results;

INSERT INTO results (
  result_id, athlete_id, games_id, noc_code, event_id,
  age, height_cm, weight_kg, medal
)
SELECT
  result_id,
  athlete_id,
  games_id,
  noc_code,
  event_id,
  age,
  height_cm,
  weight_kg,
  NULLIF(medal, '')::medal_enum
FROM results_stage;

-- 5) Aufräumen
DROP TABLE results_stage;

COMMIT;

\echo 'Done importing results.'
