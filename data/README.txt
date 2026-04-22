
Normalisierte Olympia-Tabellen (basierend auf olympics.csv für ERD)

Umfang:
- Um die Größe zu reduzieren (wie in der Fallstudie vorgeschlagen), enthält dieser Export Zeilen mit Jahr >= 1960.
- Größe und Gewicht wurden um den Faktor 10 reduziert, da die Rohdaten beispielsweise für die Größe als 1800 (= 180,0 cm) und das Gewicht als 800 (= 80,0 kg) gespeichert sind.


Tabellen:
- athletes(athlete_id, name, sex)
- nocs(noc_code, country)
- games(games_id, year)
- sports(sport_id, sport_name)
- events(event_id, sport_id, event_name)
- results(result_id, athlete_id, games_id, noc_code, event_id, age, Height_cm, Weight_kg, medal)

Anzahl der Zeilen:
- athletes: 87,734
- nocs: 220
- games: 15
- sports: 36
- events: 375
- results: 165,978
