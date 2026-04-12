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
BatData$Date <- as.Date(BatData$Date, format = "%m/%d/%y")

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
      OBP = round(Hits/PA,3),
      SLG = ifelse(AB==0, NA, round(TB/AB,3)),
      OPS = round(OBP + SLG,3)
    ) %>%
    select(Name,PA,BA,OBP,SLG,OPS,RBI,SB,SO,BB) %>%
    arrange(desc(OPS))
}

# ======================
# PIE CHART (BASE R)
# ======================
PieChart <- function(p) {
  balls <- sum(p$Ball, na.rm=TRUE)
  strikes <- sum(p$Strike, na.rm=TRUE)
  total <- balls + strikes
  
  if (total == 0) return(NULL)
  
  pct <- round(100*c(balls,strikes)/total,1)
  
  pie(
    c(balls,strikes),
    labels = paste0(pct,"%"),
    col = c("skyblue","tomato"),
    main = "Pitches Seen"
  )
  
  legend("topright",
         legend=c(paste("Ball:",balls),
                  paste("Strike:",strikes)),
         fill=c("skyblue","tomato"),
         bty="n")
}

# ======================
# UI
# ======================
ui <- fluidPage(
  theme = shinytheme("spacelab"),
  titlePanel("Batting Stats App"),
  
  tabsetPanel(
    
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
               column(6, plotOutput("pitch_pie_chart", height="300px")),
               column(6, plotOutput("hit_distribution_plot", height="300px"))
             ),
             
             fluidRow(
               column(6, plotOutput("pa_outcome_plot", height="300px")),
               column(6, plotOutput("batting_avg_trend", height="300px"))
             )
    ),
    
    tabPanel("Glossary",
             tags$ul(
               tags$li("BA: Batting Average"),
               tags$li("OBP: On-base Percentage"),
               tags$li("SLG: Slugging Percentage"),
               tags$li("OPS: On-base Plus Slugging")
             )
    )
  )
)

# ======================
# SERVER
# ======================
server <- function(input, output, session) {
  
  filtered_stats_data <- reactive({
    if (input$year_filter_stats=="All") BatData
    else BatData %>% filter(Year==input$year_filter_stats)
  })
  
  filtered_analysis_data <- reactive({
    if (input$year_filter_analysis=="All") BatData
    else BatData %>% filter(Year==input$year_filter_analysis)
  })
  
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
  
  # ======================
  # TABLES
  # ======================
  output$stats_table <- renderDT({
    datatable(
      BuildStatsTable(filtered_stats_data()),
      options = list(pageLength = 15, scrollX = TRUE),
      rownames = FALSE
    ) %>%
      formatRound(c("BA","OBP","SLG","OPS"), 3) %>%
      
      formatStyle(
        "OPS",
        backgroundColor = styleInterval(
          c(0.600, 0.800, 1.000),
          c("#f8d7da",  # low (red)
            "#fff3cd",  # below avg (yellow)
            "#d4edda",  # good (green)
            "#c3e6cb")  # great (dark green)
        )
      )
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
  # PIE CHART
  # ======================
  output$pitch_pie_chart <- renderPlot({
    PieChart(selected_player_data())
  })
  
  # ======================
  # HIT DISTRIBUTION (BASE R BARPLOT)
  # ======================
  output$hit_distribution_plot <- renderPlot({
    p <- selected_player_data()
    
    hits <- c(
      Single=sum(p$Result=="Single"),
      Double=sum(p$Result=="Double"),
      Triple=sum(p$Result=="Triple"),
      HR=sum(p$Result=="HR")
    )
    
    barplot(
      hits,
      col=c("#9ECAE1","#6BAED6","#4292C6","#2171B5"),
      main="Hit Distribution",
      ylab="Count",
      ylim=c(0,max(hits)+1)
    )
    
    text(seq_along(hits),hits,labels=hits,pos=3)
  })
  
  # ======================
  # PA OUTCOMES
  # ======================
  output$pa_outcome_plot <- renderPlot({
    p <- selected_player_data()
    
    outcomes <- c(
      Hit=sum(p$Result %in% HIT_RESULTS),
      SO=sum(p$Result=="SO"),
      BB=sum(p$Result=="BB")
    )
    
    barplot(
      outcomes,
      col=c("#74C476","#FB6A4A","#FDD0A2"),
      main="PA Outcomes",
      ylab="Count",
      ylim=c(0,max(outcomes)+1)
    )
    
    text(seq_along(outcomes),outcomes,labels=outcomes,pos=3)
  })
  
  # ======================
  # BA BY GAME (BASE R LINE PLOT)
  # ======================
  output$batting_avg_trend <- renderPlot({
    p <- selected_player_data()
    p <- p[order(p$Date),]
    
    p$AB <- p$Result %in% AB_RESULTS
    p$H <- p$Result %in% HIT_RESULTS
    
    game <- aggregate(cbind(H,AB) ~ Date, data=p, sum)
    game$Game <- seq_len(nrow(game))
    
    game$BA <- cumsum(game$H)/cumsum(game$AB)
    
    plot(
      game$Game,
      game$BA,
      type="o",
      pch=16,
      col="blue",
      lwd=2,
      ylim=c(0,1),
      main="BA by Game",
      xlab="Game",
      ylab="Batting Average"
    )
    
    lines(
      game$Game,
      stats::lowess(game$Game, game$BA)$y,
      col="red",
      lwd=2
    )
    
    grid()
  })
}

shinyApp(ui, server)