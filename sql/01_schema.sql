-- 01_schema.sql
-- Zweck: Datenbank-Schema (Tabellen, Constraints, ENUM) für projekt_olympics erstellen
-- Ausführung: In Antares (SQL-Tab) ODER im Terminal via: psql -d projekt_olympics -f 01_schema.sql
-- Hinweis: Dieser Block enthält KEIN \copy, also funktioniert er auch in Antares.

BEGIN;

-- 1) ENUM für Medaillen (idempotent)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'medal_enum') THEN
    CREATE TYPE medal_enum AS ENUM ('Gold', 'Silver', 'Bronze');
  END IF;
END $$;

-- 2) Dimensionstabellen
CREATE TABLE IF NOT EXISTS athletes (
  athlete_id  INT PRIMARY KEY,
  name        VARCHAR(255) NOT NULL,
  sex         CHAR(1) NOT NULL CHECK (sex IN ('M','F'))
);

CREATE TABLE IF NOT EXISTS nocs (
  noc_code  CHAR(3) PRIMARY KEY,
  country   VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS games (
  games_id  INT PRIMARY KEY,
  year      INT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS sports (
  sport_id    INT PRIMARY KEY,
  sport_name  VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS events (
  event_id    INT PRIMARY KEY,
  sport_id    INT NOT NULL REFERENCES sports(sport_id),
  event_name  VARCHAR(255) NOT NULL,
  CONSTRAINT uq_events_sport_event UNIQUE (sport_id, event_name)
);

-- 3) Faktentabelle
CREATE TABLE IF NOT EXISTS results (
  result_id   INT PRIMARY KEY,
  athlete_id  INT NOT NULL REFERENCES athletes(athlete_id),
  games_id    INT NOT NULL REFERENCES games(games_id),
  noc_code    CHAR(3) NOT NULL REFERENCES nocs(noc_code),
  event_id    INT NOT NULL REFERENCES events(event_id),
  age         INT,
  height_cm   NUMERIC(5,1),
  weight_kg   NUMERIC(5,1),
  medal       medal_enum
);

-- Optional: sinnvolle Indizes für Analyse
CREATE INDEX IF NOT EXISTS idx_results_games   ON results(games_id);
CREATE INDEX IF NOT EXISTS idx_results_noc     ON results(noc_code);
CREATE INDEX IF NOT EXISTS idx_results_event   ON results(event_id);
CREATE INDEX IF NOT EXISTS idx_results_athlete ON results(athlete_id);

COMMIT;
