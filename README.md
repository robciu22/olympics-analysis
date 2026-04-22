# Olympic Games Data Analysis

> SQL · PostgreSQL · Python · Plotly · Streamlit · SQLAlchemy

An end-to-end data analysis project on Olympic Games data (1960–2016): database design, SQL analytics, and an interactive Streamlit dashboard.

---

## Project Overview

| Item | Detail |
|---|---|
| Dataset | Olympic Games results 1960–2016 |
| Records | 165,978 results · 87,734 athletes · 220 NOCs · 36 sports |
| Stack | PostgreSQL · Python · Plotly Express · Streamlit · SQLAlchemy |
| Focus | Star schema design, complex SQL analytics, interactive visualization |

---

## Architecture

```
olympics.csv (raw)
      ↓
Normalization → 5 dimension tables + 1 fact table (Star Schema)
      ↓
PostgreSQL DB: projekt_olympics
      ↓
SQL Analysis (8 analytical queries)
      ↓
Streamlit Dashboard (Plotly Express, SQLAlchemy)
```

---

## Repository Structure

```
olympics-analysis/
├── sql/
│   ├── 01_schema.sql                    # Star schema DDL (ENUM, FK, constraints)
│   ├── 02_import_dimensions.sql         # Dimension table imports
│   ├── 03_import_results_staging.sql    # Fact table staging import
│   ├── 04_validation.sql                # Data quality checks
│   ├── 05_analysis_starter_queries.sql  # Entry-point queries
│   ├── 01_Sanity_Check.sql
│   ├── 02_Top10_Länder.sql              # Top 10 countries by medals
│   ├── 03_Top3_Länder_jeOlympiajahr.sql # Top 3 per Olympic year
│   ├── 04_Anzahl_Medaillen_Sportarten.sql
│   ├── 05_Medaillen_Ranking_Sportart_Jahr.sql
│   ├── 06_Medaillen_Altersklasse.sql
│   ├── 07_avgAge_Sportart.sql
│   ├── 08_Körpermaße_Sportart_Medaillen.sql
│   └── 09_Länder_Effizienz.sql          # Country efficiency metric
│
├── data/
│   ├── athletes.csv
│   ├── events.csv
│   ├── games.csv
│   ├── nocs.csv
│   ├── results.csv
│   ├── sports.csv
│   └── README.txt                       # Data dictionary
│
├── streamlit_app/
│   └── olympics_streamlit_app.py        # Interactive dashboard
│
├── .env.template                        # DB credentials template
├── .gitignore
└── README.md
```

---

## Database Schema (Star Schema)

```
athletes ──┐
nocs ───────┤
games ──────┼──► results (fact table)
sports ─────┤
events ─────┘
```

**Fact table:** `results` (result_id, athlete_id, games_id, noc_code, event_id, age, height_cm, weight_kg, medal)

---

## SQL Analytics

| Query | Description |
|---|---|
| Top 10 countries | Total medals with gold/silver/bronze breakdown |
| Top 3 per year | Best countries per Olympic year |
| Medal by sport | Distribution across 36 sports |
| Medal ranking | Sport × Year cross-analysis |
| Age groups | Medal performance by athlete age |
| Avg age by sport | Which sports favor which age? |
| Body metrics | Height/weight correlation with medals |
| Country efficiency | Medals per athlete ratio |

---

## Setup

```bash
# 1. Clone and configure
cp .env.template .env
# Fill in your PostgreSQL credentials

# 2. Create DB and run schema
psql -d projekt_olympics -f sql/01_schema.sql
psql -d projekt_olympics -f sql/02_import_dimensions.sql
psql -d projekt_olympics -f sql/03_import_results_staging.sql

# 3. Run dashboard
pip install streamlit plotly sqlalchemy psycopg2-binary python-dotenv pandas
streamlit run streamlit_app/olympics_streamlit_app.py
```

---

## Author

**Robert Legatzki** — Diplom-Ingenieur | Data Scientist | KI-Automatisierer  
[github.com/robciu22](https://github.com/robciu22) · [linkedin.com/in/robert-legatzki-19648b13](https://www.linkedin.com/in/robert-legatzki-19648b13/)
