# ⚾ Baseball Batting Dashboard

**Dennie Truong · Baseball Analytics · R / Shiny**

[![Project](https://img.shields.io/badge/Project-Sports%20Analytics-2f6f8f)](https://dennietruong.github.io/BaseballBattingDashboard/)
[![Focus](https://img.shields.io/badge/Focus-Baseball%20Analytics-4c956c)](https://dennietruong.github.io/BaseballBattingDashboard/)
[![Data](https://img.shields.io/badge/Data-2025--2026-6c757d)](https://dennietruong.github.io/BaseballBattingDashboard/)

> **An interactive R Shiny dashboard for analyzing individual and team batting performance across the 2025 and 2026 baseball seasons.**
**Live Dashboard:** [Baseball Batting Dashboard](https://dennietruong.github.io/BaseballBattingDashboard/)

---

## 📌 Project Overview

This project was developed to explore how data collection, statistical analysis, and interactive visualization can be applied to baseball performance.

I recorded game-level batting data throughout the 2025 and 2026 seasons and developed an R Shiny application to transform those observations into player-level statistics and performance visualizations.

The dashboard allows users to:

* View batting statistics across the team
* Filter statistics by season
* Select individual players for detailed analysis
* Compare individual performance against the team average
* Examine hit distributions and plate-appearance outcomes
* Track cumulative batting average across games
* Analyze the distribution of balls and strikes seen by a player

---

## 🎯 Project Goals

The primary goals of the project were to:

1. **Develop a practical baseball analytics tool** for evaluating player performance.
2. **Apply statistical concepts** to real-world baseball data.
3. **Build an interactive data visualization dashboard** using R Shiny.
4. **Compare individual performance with team-level averages** to provide additional context for player statistics.
5. Develop experience working with manually collected, longitudinal sports data.

---

## 📊 Data

The dataset consists of manually recorded batting observations from the **2025 and 2026 seasons**.

Each observation represents a plate appearance and includes information used to calculate batting statistics and analyze plate-appearance outcomes.

### Data used to calculate:

* Plate Appearances (PA)
* At-Bats (AB)
* Hits
* Singles
* Doubles
* Triples
* Home Runs (HR)
* Total Bases (TB)
* Runs Batted In (RBI)
* Stolen Bases (SB)
* Strikeouts (SO)
* Walks (BB)
* Batting Average (BA)
* On-Base Percentage (OBP)
* Slugging Percentage (SLG)
* On-Base Plus Slugging (OPS)

The data were combined across seasons and filtered dynamically within the application.

---

## 📈 Statistical Analysis

The application calculates traditional baseball batting statistics from the underlying plate-appearance data.

### Core Metrics

| Metric  | Description           |
| ------- | --------------------- |
| **BA**  | Batting Average       |
| **OBP** | On-Base Percentage    |
| **SLG** | Slugging Percentage   |
| **OPS** | On-Base Plus Slugging |
| **PA**  | Plate Appearances     |
| **RBI** | Runs Batted In        |
| **SB**  | Stolen Bases          |
| **SO**  | Strikeouts            |
| **BB**  | Walks                 |

The dashboard also calculates **Total Bases** from the type of hit recorded, allowing SLG and OPS to be derived from the underlying data.

---

## 🖥️ Dashboard Features

### Player Stats

The **Player Stats** tab provides a team-wide statistical leaderboard.

Users can filter the table by:

* All seasons
* 2025
* 2026

Players are automatically ranked by **OPS**, while conditional formatting provides a visual indication of OPS levels.

---

### Player Analysis

The **Player Analysis** tab provides a more detailed view of an individual player's performance.

Users can select:

* A season
* An individual player

The dashboard then displays the selected player's statistics alongside the **team average**, providing context for evaluating individual performance relative to the rest of the team.

### Visualizations

The player analysis includes four visualizations:

**Pitches Seen**

A pie chart showing the number and proportion of **balls and strikes** seen by the selected player.

**Hit Distribution**

A bar chart displaying the number of:

* Singles
* Doubles
* Triples
* Home Runs

**Plate Appearance Outcomes**

A bar chart comparing:

* Hits
* Strikeouts
* Walks

**Batting Average by Game**

A longitudinal visualization showing the player's **cumulative batting average across games**, with a LOWESS trend line to highlight the overall trajectory.

---

## 🛠️ Technologies

The dashboard was developed using:

* **R**
* **R Shiny**
* **Shinythemes**
* **dplyr**
* **lubridate**
* **DT**
* **R Base Graphics**
* **CSV data**

The application uses reactive Shiny components to dynamically update statistics, tables, player selections, and visualizations based on the user's selected season and player.

---

## 🔄 Analytical Workflow

```text
Manual Data Collection
        ↓
Game-Level Batting Data
        ↓
Data Cleaning & Formatting
        ↓
Combine 2025 + 2026 Data
        ↓
Calculate Batting Statistics
        ↓
Filter by Season / Player
        ↓
Compare Player vs. Team Average
        ↓
Interactive Tables & Visualizations
```

## 📁 Repository

```text
├── BattingData2025.csv       # 2025 batting data
├── BattingData2026.csv       # 2026 batting data
├── app.R                     # Shiny application
├── README.md
└── Other supporting files
```

---

## 🌐 Dashboard

The completed dashboard is available online:

**Baseball Batting Dashboard:**
https://dennietruong.github.io/BaseballBattingDashboard/

## 📚 Resource

The dashboard was developed with reference to the R Shiny / Shinylive training materials from the Harvard Chan Bioinformatics Core:

https://hbctraining.github.io/Training-modules/RShiny/lessons/shinylive.html

---

## 👤 Author

**Dennie Truong**
Colby College '24
Environmental Science · Biology · Mathematics

### 🔑 Keywords

`Baseball Analytics` · `Sports Analytics` · `R` · `R Shiny` · `Data Analysis` · `Data Visualization` · `Baseball Statistics` · `Batting` · `OPS` · `Player Evaluation` · `Sports Data` · `Interactive Dashboard`
