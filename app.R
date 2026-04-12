library(shiny)
library(shinythemes)
library(lubridate)
library(dplyr)
library(DT)

# ======================
# Load Data
# ======================
BatData2025 <- read.csv("BattingData2025.csv")
BatData2026 <- read.csv("BattingData2026.csv")

BatData2025$Year <- 2025
BatData2026$Year <- 2026

BatData <- bind_rows(BatData2025, BatData2026)
BatData$Date <- as.Date(BatData$Date, format = "%m/%d/%Y")

# ======================
# Constants
# ======================
HIT_RESULTS <- c("Single","Double","Triple","HR")
AB_RESULTS  <- c("Single","Double","Triple","HR","SO","FO","GO")

# ======================
# Stats Function
# ======================
BuildStatsTable <- function(data) {
  data %>%
    group_by(Name) %>%
    summarise(
      PA = n(),
      AB = sum(Result %in% AB_RESULTS),
      Hits = sum(Result %in% HIT_RESULTS),
      Singles = sum(Result=="Single"),
      Doubles = sum(Result=="Double"),
      Triples = sum(Result=="Triple"),
      HR = sum(Result=="HR"),
      TB = Singles + 2*Doubles + 3*Triples + 4*HR,
      RBI = sum(RBI, na.rm=TRUE),
      SB = sum(StolenBase, na.rm=TRUE),
      SO = sum(Result=="SO"),
      BB = sum(Result=="BB"),
      .groups="drop"
    ) %>%
    mutate(
      BA = ifelse(AB==0, NA, round(Hits/AB,3)),
      OBP = round((Hits+BB)/PA,3),
      SLG = ifelse(AB==0, NA, round(TB/AB,3)),
      OPS = round(OBP + SLG,3)
    ) %>%
    select(Name,PA,BA,OBP,SLG,OPS,RBI,SB,SO,BB) %>%
    arrange(desc(OPS))
}

# ======================
# PIE CHART FUNCTION
# ======================
PieChart <- function(p) {
  balls <- sum(p$Ball, na.rm=TRUE)
  strikes <- sum(p$Strike, na.rm=TRUE)
  total <- balls + strikes
  
  if (total == 0) return(NULL)
  
  pct <- round(100*c(balls,strikes)/total,1)
  
  pie(
    c(balls,strikes),
    labels = paste0(c("Ball","Strike"), ": ", pct, "%"),
    col = c("skyblue","tomato"),
    main = "Pitches Seen"
  )
}

# ======================
# UI
# ======================
ui <- fluidPage(
  theme = shinytheme("spacelab"),
  titlePanel("Batting Stats App"),
  
  tabsetPanel(
    
    # ------------------
    # PLAYER STATS TAB
    # ------------------
    tabPanel("Player Stats",
             fluidRow(
               column(3,
                      selectInput("year_filter_stats","Select Year:",
                                  choices=c("All",sort(unique(BatData$Year))),
                                  selected="All")
               )
             ),
             DTOutput("stats_table")
    ),
    
    # ------------------
    # PLAYER ANALYSIS TAB
    # ------------------
    tabPanel("Player Analysis",
             
             fluidRow(
               column(3,
                      selectInput("year_filter_analysis","Select Year:",
                                  choices=c("All",sort(unique(BatData$Year))),
                                  selected="All")
               ),
               column(3,
                      uiOutput("player_dropdown")
               )
             ),
             
             h3(textOutput("selected_player_title")),
             DTOutput("player_stats_table"),
             DTOutput("team_avg_table"),
             
             fluidRow(
               column(6, plotOutput("pitch_pie_chart")),
               column(6, plotOutput("hit_distribution_plot"))
             ),
             
             fluidRow(
               column(6, plotOutput("pa_outcome_plot")),
               column(6, plotOutput("batting_avg_trend"))
             )
    ),
    
    # ------------------
    # GAME BREAKDOWN TAB
    # ------------------
    tabPanel("Game Breakdown",
             
             fluidRow(
               column(3,
                      selectInput("year_game", "Select Year:",
                                  choices = c("All", sort(unique(BatData$Year))),
                                  selected = "All")
               ),
               column(3,
                      uiOutput("player_game_dropdown")
               ),
               column(3,
                      selectInput("game_date", "Select Game:", choices = NULL)
               )
             ),
             
             h3("Game Stats"),
             DTOutput("game_table"),
             
             h4("Game Visuals"),
             
             fluidRow(
               column(6, plotOutput("game_pitch_pie")),
               column(6, plotOutput("game_result_bar"))
             )
    ),
    
    # ------------------
    # GLOSSARY
    # ------------------
    tabPanel("Glossary",
             
             tags$div(style = "line-height: 1.7;",
                      
                      tags$p(
                        tags$strong("PA: "),
                        "Plate Appearances = Total times a player comes to the plate (all outcomes)."
                      ),
                      
                      tags$p(
                        tags$strong("AB: "),
                        "At Bats = PA minus BB (walks), HBP (hit by pitch). In this app: PA outcomes classified as hits or outs only."
                      ),
                      
                      tags$p(
                        tags$strong("BA: "),
                        "Batting Average = Hits ÷ At Bats (AB)."
                      ),
                      
                      tags$p(
                        tags$strong("OBP: "),
                        "On-Base Percentage = (Hits + Walk) ÷ Plate Appearances (PA)."
                      ),
                      
                      tags$p(
                        tags$strong("SLG: "),
                        "Slugging Percentage = Total Bases ÷ At Bats (AB)."
                      ),
                      
                      tags$p(
                        tags$strong("OPS: "),
                        "On-Base Plus Slugging = OBP + SLG."
                      ),
                      
                      tags$p(
                        tags$strong("RBI: "),
                        "Runs Batted In = Number of runs scored due to a batter’s action."
                      ),
                      
                      tags$p(
                        tags$strong("SB: "),
                        "Stolen Bases = Times a player successfully advances a base without a hit or error."
                      ),
                      
                      tags$p(
                        tags$strong("SO: "),
                        "Strikeout = Plate appearance ending in a strikeout."
                      ),
                      
                      tags$p(
                        tags$strong("BB: "),
                        "Walk (Base on Balls) = Batter reaches first base via four balls."
                      ),
                      
                      tags$p(
                        tags$strong("GO: "),
                        "Groundout = Batter is put out on a ground ball."
                      ),
                      
                      tags$p(
                        tags$strong("FO: "),
                        "Flyout = Batter is put out on a fly ball."
                      ),
                      
                      tags$p(
                        tags$strong("HR: "),
                        "Home Run = Hit that allows batter to circle all bases and score."
                      ),
                      
                      tags$p(
                        tags$strong("TB: "),
                        "Total Bases = (Singles × 1) + (Doubles × 2) + (Triples × 3) + (Home Runs × 4)."
                      )
                      
             )
    )
  )
)

# ======================
# SERVER
# ======================
server <- function(input, output, session) {
  
  # ------------------
  # FILTERS
  # ------------------
  filtered_stats_data <- reactive({
    if (input$year_filter_stats == "All") BatData
    else BatData %>% filter(Year == input$year_filter_stats)
  })
  
  filtered_analysis_data <- reactive({
    if (input$year_filter_analysis == "All") BatData
    else BatData %>% filter(Year == input$year_filter_analysis)
  })
  
  # ------------------
  # PLAYER DROPDOWN
  # ------------------
  output$player_dropdown <- renderUI({
    players <- filtered_analysis_data() %>%
      distinct(Name) %>% pull(Name)
    
    selectInput("selected_player","Select Player:",
                choices=players,
                selected=players[1])
  })
  
  selected_player_data <- reactive({
    req(input$selected_player)
    filtered_analysis_data() %>%
      filter(Name==input$selected_player)
  })
  
  # ------------------
  # GAME DROPDOWN PLAYER
  # ------------------
  output$player_game_dropdown <- renderUI({
    df <- if (input$year_game == "All") BatData else BatData %>% filter(Year == input$year_game)
    
    players <- df %>% distinct(Name) %>% pull(Name)
    
    selectInput("player_game","Select Player:",
                choices=players,
                selected=players[1])
  })
  
  # ------------------
  # GAME DATE UPDATE
  # ------------------
  observe({
    req(input$player_game)
    
    df <- if (input$year_game == "All") BatData else BatData %>% filter(Year == input$year_game)
    
    df <- df %>%
      filter(Name == input$player_game) %>%
      arrange(Date)
    
    updateSelectInput(session, "game_date",
                      choices = unique(df$Date),
                      selected = unique(df$Date)[1])
  })
  
  game_data <- reactive({
    req(input$player_game, input$game_date)
    
    df <- if (input$year_game == "All") BatData else BatData %>% filter(Year == input$year_game)
    
    df %>%
      filter(Name == input$player_game,
             Date == input$game_date)
  })
  
  # ======================
  # TABLES
  # ======================
  output$stats_table <- renderDT({
    datatable(BuildStatsTable(filtered_stats_data()),
              options=list(pageLength=15,scrollX=TRUE),
              rownames=FALSE)
  })
  
  output$player_stats_table <- renderDT({
    datatable(BuildStatsTable(selected_player_data()),
              options=list(dom="t"),
              rownames=FALSE)
  })
  
  output$team_avg_table <- renderDT({
    stats <- BuildStatsTable(filtered_analysis_data())
    nums <- sapply(stats,is.numeric)
    avg <- round(colMeans(stats[,nums]),3)
    
    datatable(data.frame(Name="Team Avg",t(avg)),
              options=list(dom="t"),
              rownames=FALSE)
  })
  
  # ======================
  # PLAYER ANALYSIS PLOTS
  # ======================
  output$pitch_pie_chart <- renderPlot({
    PieChart(selected_player_data())
  })
  
  output$hit_distribution_plot <- renderPlot({
    p <- selected_player_data()
    
    hits <- c(
      Single = sum(p$Result == "Single"),
      Double = sum(p$Result == "Double"),
      Triple = sum(p$Result == "Triple"),
      HR     = sum(p$Result == "HR")
    )
    
    bp <- barplot(hits,
                  col = c("#9ECAE1","#6BAED6","#4292C6","#2171B5"),
                  main = "Hit Distribution",
                  ylab = "Count",
                  ylim = c(0, max(hits) + 1),
                  yaxt = "n")   # remove default y-axis
    
    axis(2, at = seq(0, max(hits) + 1, by = 1))  # y-axis increments of 1
    
    text(bp, hits, labels = hits, pos = 3)
  })
  
  output$pa_outcome_plot <- renderPlot({
    p <- selected_player_data()
    
    outcomes <- c(
      Hit = sum(p$Result %in% HIT_RESULTS),
      SO  = sum(p$Result == "SO"),
      BB  = sum(p$Result == "BB")
    )
    
    bp <- barplot(outcomes,
                  col = c("#74C476","#FB6A4A","#FDD0A2"),
                  main = "Plate Appearance Outcomes",
                  ylab = "Count",
                  ylim = c(0, max(outcomes) + 1),
                  yaxt = "n")   # remove default y-axis
    
    axis(2, at = seq(0, max(outcomes) + 1, by = 1))  # y-axis step = 1
    
    text(bp, outcomes, labels = outcomes, pos = 3)
  })
  
  output$batting_avg_trend <- renderPlot({
    p <- selected_player_data()
    p <- p[order(p$Date),]
    
    p$AB <- p$Result %in% AB_RESULTS
    p$H <- p$Result %in% HIT_RESULTS
    
    game <- aggregate(cbind(H,AB) ~ Date, data=p, sum)
    game$Game <- seq_len(nrow(game))
    game$BA <- cumsum(game$H)/cumsum(game$AB)
    
    plot(game$Game, game$BA, 
         type="o",
         col="blue",
         main="Batting Average Trend",
         ylim=c(0,1),
         xlab = "Game",
         ylab = "Percentage",
         xaxt = "n")
    
    axis(1, at = seq(min(game$Game), max(game$Game), by = 1))
    grid()
    
    #lines(game$Game, stats::lowess(game$Game, game$BA)$y,col="red", lwd=2)
  })
  
  # ======================
  # GAME BREAKDOWN PLOTS
  # ======================
  output$game_table <- renderDT({
    datatable(BuildStatsTable(game_data()),
              options=list(dom="t"),
              rownames=FALSE)
  })
  
  output$game_pitch_pie <- renderPlot({
    df <- game_data()
    validate(need(nrow(df)>0,"No data"))
    PieChart(df)
  })
  
  output$game_result_bar <- renderPlot({
    df <- game_data()
    validate(need(nrow(df)>0,"No data"))
    
    results <- c(
      Single=sum(df$Result=="Single"),
      Double=sum(df$Result=="Double"),
      Triple=sum(df$Result=="Triple"),
      HR=sum(df$Result=="HR"),
      BB=sum(df$Result=="BB"),
      SO=sum(df$Result=="SO"),
      GO=sum(df$Result=="GO"),
      FO=sum(df$Result=="FO")
    )
    
    bp <- barplot(results,
                  col = c("#9ECAE1","#6BAED6","#4292C6","#2171B5",
                          "#74C476","#FB6A4A","#A1D99B","#31A354"),
                  main = "Plate Appearance Results",
                  ylim = c(0, max(results) + 1),
                  yaxt = "n")
    
    axis(2, at = seq(0, max(results) + 1, by = 1))
    
    text(bp, results, labels = results, pos = 3)
  })
}

shinyApp(ui, server)