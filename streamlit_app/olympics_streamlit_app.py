import os
from pathlib import Path

import pandas as pd
import streamlit as st
from sqlalchemy import create_engine
from dotenv import load_dotenv
import plotly.express as px

# -----------------------------
# App Config
# -----------------------------
st.set_page_config(page_title="Olympics Dashboard", layout="wide")
st.title("Olympics – Datenanalyse Dashboard")
st.caption("Quelle: PostgreSQL DB `projekt_olympics` (lokal). Visualisierung: Plotly.")

# -----------------------------
# ENV / DB Connection
# -----------------------------
# Passe den Dateinamen bei Bedarf an:
ENV_FILE = Path("Password_Antares_Python.env")

if ENV_FILE.exists():
    load_dotenv(dotenv_path=ENV_FILE, override=True)
else:
    st.warning(
        f"ENV-Datei nicht gefunden: {ENV_FILE.resolve()}.\n"
        "Lege sie in den gleichen Ordner wie dieses Script oder setze ENV-Variablen direkt im System."
    )

pg_user = os.getenv("PGUSER", "postgres")
pg_pw = os.getenv("PGPASSWORD")
pg_host = os.getenv("PGHOST", "localhost")
pg_port = os.getenv("PGPORT", "5432")
pg_db = os.getenv("PGDATABASE", "projekt_olympics")

if not pg_pw:
    st.error("PGPASSWORD ist leer. Bitte in der ENV-Datei setzen (PGPASSWORD=...).")
    st.stop()

engine = create_engine(
    f"postgresql+psycopg2://{pg_user}:{pg_pw}@{pg_host}:{pg_port}/{pg_db}"
)


@st.cache_data(ttl=600, show_spinner=False)
def read_sql_df(query: str) -> pd.DataFrame:
    return pd.read_sql(query, engine)


# -----------------------------
# Sidebar Filters
# -----------------------------
with st.sidebar:
    st.header("Filter")
    years_df = read_sql_df("SELECT DISTINCT year FROM games ORDER BY year;")
    years = years_df["year"].tolist()
    year_min, year_max = (min(years), max(years)) if years else (None, None)

    selected_years = st.slider(
        "Jahresbereich",
        min_value=year_min,
        max_value=year_max,
        value=(year_min, year_max),
        step=1,
    )

    top_n = st.slider("Top-N", min_value=5, max_value=30, value=10, step=1)
    min_medals = st.slider(
        "Mindestanzahl Medaillen (Filter)", min_value=0, max_value=500, value=0, step=10
    )

    st.divider()
    st.caption("Hinweis: Team-Events können mehrfach gezählt werden (athlete-level).")

year_from, year_to = selected_years

# -----------------------------
# Queries (parametrisiert)
# -----------------------------
Q_TOP_COUNTRIES = f"""
SELECT
  n.country,
  COUNT(*) FILTER (WHERE r.medal = 'Gold')   AS gold,
  COUNT(*) FILTER (WHERE r.medal = 'Silver') AS silver,
  COUNT(*) FILTER (WHERE r.medal = 'Bronze') AS bronze,
  COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS total_medals
FROM results r
JOIN nocs n  ON n.noc_code = r.noc_code
JOIN games g ON g.games_id = r.games_id
WHERE g.year BETWEEN {year_from} AND {year_to}
GROUP BY n.country
HAVING COUNT(*) FILTER (WHERE r.medal IS NOT NULL) >= {min_medals}
ORDER BY total_medals DESC
LIMIT {top_n};
"""

Q_MEDALS_BY_YEAR = f"""
SELECT
  g.year,
  COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS medals
FROM results r
JOIN games g ON g.games_id = r.games_id
WHERE g.year BETWEEN {year_from} AND {year_to}
GROUP BY g.year
ORDER BY g.year;
"""

Q_TOP_SPORTS = f"""
SELECT
  s.sport_name,
  COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS medals
FROM results r
JOIN games g  ON g.games_id = r.games_id
JOIN events e ON e.event_id = r.event_id
JOIN sports s ON s.sport_id = e.sport_id
WHERE g.year BETWEEN {year_from} AND {year_to}
GROUP BY s.sport_name
HAVING COUNT(*) FILTER (WHERE r.medal IS NOT NULL) >= {min_medals}
ORDER BY medals DESC
LIMIT {top_n};
"""

Q_MEDIAN_AGE = f"""
SELECT
  s.sport_name,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY r.age) AS median_medal_age,
  COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS medals
FROM results r
JOIN games g  ON g.games_id = r.games_id
JOIN events e ON e.event_id = r.event_id
JOIN sports s ON s.sport_id = e.sport_id
WHERE r.medal IS NOT NULL
  AND r.age IS NOT NULL
  AND g.year BETWEEN {year_from} AND {year_to}
GROUP BY s.sport_name
HAVING COUNT(*) FILTER (WHERE r.medal IS NOT NULL) >= GREATEST(50, {min_medals})
ORDER BY medals DESC
LIMIT {top_n};
"""

Q_BODY = f"""
SELECT
  s.sport_name,
  ROUND(AVG(r.height_cm) FILTER (WHERE r.medal IS NOT NULL AND r.height_cm IS NOT NULL), 2) AS avg_height_medal_cm,
  ROUND(AVG(r.weight_kg) FILTER (WHERE r.medal IS NOT NULL AND r.weight_kg IS NOT NULL), 2) AS avg_weight_medal_kg,
  COUNT(*) FILTER (WHERE r.medal IS NOT NULL) AS medals
FROM results r
JOIN games g  ON g.games_id = r.games_id
JOIN events e ON e.event_id = r.event_id
JOIN sports s ON s.sport_id = e.sport_id
WHERE g.year BETWEEN {year_from} AND {year_to}
GROUP BY s.sport_name
HAVING COUNT(*) FILTER (WHERE r.medal IS NOT NULL) >= GREATEST(100, {min_medals})
ORDER BY medals DESC
LIMIT {top_n};
"""

# -----------------------------
# Layout (Tabs)
# -----------------------------
tab1, tab2, tab3, tab4, tab5 = st.tabs(
    ["Länder", "Zeit", "Sportarten", "Alter", "Body-Metrics"]
)

with tab1:
    df = read_sql_df(Q_TOP_COUNTRIES)
    st.subheader("Top Länder – Medaillen nach Typ")
    if df.empty:
        st.info("Keine Daten für die gewählten Filter.")
    else:
        df_long = df.melt(
            id_vars="country",
            value_vars=["gold", "silver", "bronze"],
            var_name="medal",
            value_name="count",
        )
        fig = px.bar(
            df_long,
            x="country",
            y="count",
            color="medal",
            barmode="stack",
            title="Top Länder – Medaillen nach Typ",
        )
        fig.update_layout(xaxis_title="Land", yaxis_title="Medaillen")
        st.plotly_chart(fig, use_container_width=True)
        with st.expander("Daten (Tabelle)"):
            st.dataframe(df, use_container_width=True)

with tab2:
    df = read_sql_df(Q_MEDALS_BY_YEAR)
    st.subheader("Medaillen im Zeitverlauf")
    if df.empty:
        st.info("Keine Daten für die gewählten Filter.")
    else:
        fig = px.line(
            df, x="year", y="medals", markers=True, title="Medaillen pro Jahr"
        )
        fig.update_layout(xaxis_title="Jahr", yaxis_title="Medaillen")
        st.plotly_chart(fig, use_container_width=True)
        with st.expander("Daten (Tabelle)"):
            st.dataframe(df, use_container_width=True)

with tab3:
    df = read_sql_df(Q_TOP_SPORTS)
    st.subheader("Top Sportarten nach Medaillen")
    if df.empty:
        st.info("Keine Daten für die gewählten Filter.")
    else:
        df_plot = df.sort_values("medals", ascending=True)
        fig = px.bar(
            df_plot,
            x="medals",
            y="sport_name",
            orientation="h",
            title="Top Sportarten nach Medaillen",
        )
        fig.update_layout(xaxis_title="Medaillen", yaxis_title="Sportart")
        st.plotly_chart(fig, use_container_width=True)
        with st.expander("Daten (Tabelle)"):
            st.dataframe(
                df.sort_values("medals", ascending=False), use_container_width=True
            )

with tab4:
    df = read_sql_df(Q_MEDIAN_AGE)
    st.subheader("Median-Medaillenalter je Sportart")
    if df.empty:
        st.info("Keine Daten für die gewählten Filter (oder zu wenige Medaillen).")
    else:
        df_plot = df.sort_values("median_medal_age", ascending=True)
        fig = px.bar(
            df_plot,
            x="median_medal_age",
            y="sport_name",
            orientation="h",
            hover_data=["medals"],
            title="Median-Medaillenalter je Sportart",
        )
        fig.update_layout(xaxis_title="Median Alter", yaxis_title="Sportart")
        st.plotly_chart(fig, use_container_width=True)
        with st.expander("Daten (Tabelle)"):
            st.dataframe(df_plot, use_container_width=True)

with tab5:
    df = read_sql_df(Q_BODY)
    st.subheader("Körperprofil je Sportart (Ø Gewicht vs Ø Größe)")
    if df.empty:
        st.info("Keine Daten für die gewählten Filter (oder zu wenige Medaillen).")
    else:
        fig = px.scatter(
            df,
            x="avg_weight_medal_kg",
            y="avg_height_medal_cm",
            size="medals",
            hover_name="sport_name",
            title="Body-Metrics (Bubble = Medaillen)",
        )
        fig.update_layout(
            xaxis_title="Ø Gewicht (kg)", yaxis_title="Ø Körpergröße (cm)"
        )
        st.plotly_chart(fig, use_container_width=True)
        with st.expander("Daten (Tabelle)"):
            st.dataframe(df, use_container_width=True)

st.divider()
st.caption(
    "Tipp: Wenn dieses Dashboard als Bonus abgegeben wird, dann wegen der besseren Lesbarkeit einen"
    "Screenshot pro Tab verwenden."
)
