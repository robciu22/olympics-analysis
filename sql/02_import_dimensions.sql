-- 02_import_dimensions.sql
-- Zweck: Import der Dimensionstabellen aus normalisierten CSV-Dateien
-- Ausführung: NUR im Terminal via psql, weil \copy ein psql-Metakommando ist.
-- Beispiel:
--   psql -d projekt_olympics -f 02_import_dimensions.sql
--
-- WICHTIG: Passe den data_dir Pfad unten an dein System an.

\set ON_ERROR_STOP on

-- >>> HIER DEINEN ORDNER EINTRAGEN (ABSOLUTER PFAD) <<<
-- Beispiel:
-- \set data_dir '/home/XXX/Schreibtisch/DSI/Fallstudie_OlympicGames/Olympics_Normalisiert'
\set data_dir '/ABSOLUTER/PFAD/ZU/Olympics_Normalisiert'

\echo 'Import athletes...'
\copy athletes (athlete_id, name, sex)
FROM :'data_dir'/athletes.csv
WITH (FORMAT csv, HEADER true);

\echo 'Import nocs...'
\copy nocs (noc_code, country)
FROM :'data_dir'/nocs.csv
WITH (FORMAT csv, HEADER true);

\echo 'Import games...'
\copy games (games_id, year)
FROM :'data_dir'/games.csv
WITH (FORMAT csv, HEADER true);

\echo 'Import sports...'
\copy sports (sport_id, sport_name)
FROM :'data_dir'/sports.csv
WITH (FORMAT csv, HEADER true);

\echo 'Import events...'
\copy events (event_id, sport_id, event_name)
FROM :'data_dir'/events.csv
WITH (FORMAT csv, HEADER true);

\echo 'Done importing dimensions.'
