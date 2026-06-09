#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(readr)
library(tidyr)
library(lubridate)

function(input, output, session) {
  
  videoGameSales <- read_csv("../data/Video_Games_Sales_as_at_22_Dec_2016.csv")
  
  speedrun1 <- read_csv("../data/speedrun/leaderboards-data_part001.csv")
  speedrun2 <- read_csv("../data/speedrun/leaderboards-data_part002.csv")
  speedrun3 <- read_csv("../data/speedrun/leaderboards-data_part003.csv")
  speedrun4 <- read_csv("../data/speedrun/leaderboards-data_part004.csv")
  
  speedrun0 <- bind_rows(speedrun1,speedrun2,speedrun3,speedrun4)
  
  games_data0 <- read_csv2("../data/speedrun/games-data.csv")
  genres_data0 <- read_csv2("../data/speedrun/genres-data.csv")
  platforms_data0 <- read_csv("../data/speedrun/platforms-data.csv")
  
  games_data <- games_data0
  genres_data <- genres_data0
  platforms_data <- platforms_data0
  speedrun <- speedrun0
  
  speedrun <- speedrun %>% mutate(verifiedDate = as.Date(verifiedDate)) %>%
    filter(!is.na(verifiedDate), verifiedDate <= as.Date("2016-12-22"))
  
  games_data <- games_data %>% select(gameId,gameName,platforms,genres,releaseDate)
  
  platforms_data <- platforms_data %>% rename(platformName = name)
  
  genres_data <- genres_data %>% rename(genreName = name)
  
  speedrun <- speedrun %>%
    left_join(games_data, by = "gameId") %>%
    rename(
      platformId = platforms,
      genreId = genres,
      releaseDateGame = releaseDate
    ) %>%
    separate_rows(platformId, sep = ",") %>%
    separate_rows(genreId, sep = ",") %>%
    left_join(platforms_data, by = "platformId") %>%
    left_join(genres_data, by = "genreId") %>%
    mutate(dateJeu = dmy(releaseDateGame)) %>%
    select(
      gameName,
      genreName,
      platformName,
      platform,
      categoryId,
      runId,
      players,
      verifiedDate,
      dateJeu
    ) %>%
    mutate(
      genreName = na_if(genreName, ""),
      platformName = na_if(platformName, "")
    )
  
  # Filtres
  
  updateSelectInput(
    session,
    "sales_genre",
    choices = sort(unique(na.omit(videoGameSales$Genre)))
  )
  
  updateSelectInput(
    session,
    "sales_platform",
    choices = sort(unique(na.omit(videoGameSales$Platform)))
  )
  
  updateSelectInput(
    session,
    "speedrun_genre",
    choices = sort(unique(na.omit(speedrun$genreName)))
  )
  
  updateSelectInput(
    session,
    "speedrun_platform",
    choices = sort(unique(na.omit(speedrun$platformName)))
  )
  
  # Données filtrées ventes

  sales_filtered <- reactive({
    
    data <- videoGameSales
    
    if (length(input$sales_genre) > 0) {
      data <- data %>%
        filter(Genre %in% input$sales_genre)
    }
    
    if (length(input$sales_platform) > 0) {
      data <- data %>%
        filter(Platform %in% input$sales_platform)
    }
    
    data
  })
  
  # Données filtrées speedrun

  speedrun_filtered <- reactive({
    
    data <- speedrun
    
    if (length(input$speedrun_genre) > 0) {
      data <- data %>%
        filter(genreName %in% input$speedrun_genre)
    }
    
    if (length(input$speedrun_platform) > 0) {
      data <- data %>%
        filter(platformName %in% input$speedrun_platform)
    }
    
    data
  })
  
  # Value Box Ventes

  output$total_sales_box <- renderValueBox({
    
    total_sales <- sum(
      sales_filtered()[[input$region]],
      na.rm = TRUE
    )
    
    valueBox(
      value = round(total_sales, 2),
      subtitle = "Ventes totales (millions)",
      icon = icon("chart-line"),
      color = "blue"
    )
  })
  
  output$nb_games_box <- renderValueBox({
    
    valueBox(
      value = n_distinct(sales_filtered()$Name),
      subtitle = "Nombre de jeux",
      icon = icon("gamepad"),
      color = "green"
    )
  })
  
  output$best_genre_box <- renderValueBox({
    
    best_genre <- sales_filtered() %>%
      filter(!is.na(Genre)) %>%
      group_by(Genre) %>%
      summarise(
        total = sum(.data[[input$region]], na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(total)) %>%
      slice_head(n = 1)
    
    valueBox(
      value = best_genre$Genre,
      subtitle = "Genre dominant",
      icon = icon("trophy"),
      color = "purple"
    )
  })
  

  # Graphiques des ventes 

  output$sales_platform_plot <- renderPlot({
    
    sales_filtered() %>%
      group_by(Platform) %>%
      summarise(
        total = sum(.data[[input$region]], na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(total)) %>%
      slice_head(n = input$top_n) %>%
      ggplot(
        aes(
          x = reorder(Platform, total),
          y = total
        )
      ) +
      geom_col(fill = "#4C78A8") +
      coord_flip() +
      labs(
        x = "Plateforme",
        y = "Ventes globale (en millions)"
      ) +
      theme_minimal()
  })
  
  output$sales_genre_plot <- renderPlot({
    
    sales_filtered() %>%
      filter(!is.na(Genre)) %>%
      group_by(Genre) %>%
      summarise(
        total = sum(.data[[input$region]], na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(total)) %>%
      slice_head(n = input$top_n) %>%
      ggplot(
        aes(
          x = reorder(Genre, total),
          y = total
        )
      ) +
      geom_col(fill = "#59A14F") +
      coord_flip() +
      labs(
        x = "Genre",
        y = "Ventes globale (en millions)"
      ) +
      theme_minimal()
  })
  
  output$top_games_plot <- renderPlot({
    
    sales_filtered() %>%
      group_by(Name) %>%
      summarise(
        total = sum(.data[[input$region]], na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(total)) %>%
      slice_head(n = input$top_n) %>%
      ggplot(
        aes(
          x = reorder(Name, total),
          y = total
        )
      ) +
      geom_col(fill = "#F28E2B") +
      coord_flip() +
      labs(
        x = "Jeu",
        y = "Ventes globale (en millions)"
      ) +
      theme_minimal()
  })

  # Value Box Speedrun
  
  output$nb_runs_box <- renderValueBox({
    
    valueBox(
      value = nrow(speedrun_filtered()),
      subtitle = "Nombre total de runs",
      icon = icon("stopwatch"),
      color = "yellow"
    )
  })
  
  output$nb_speedrun_games_box <- renderValueBox({
    
    valueBox(
      value = n_distinct(speedrun_filtered()$gameName),
      subtitle = "Jeux speedrunnés",
      icon = icon("gamepad"),
      color = "orange"
    )
  })
  
  output$best_speedrun_platform_box <- renderValueBox({
    
    best_platform <- speedrun_filtered() %>%
      filter(!is.na(platformName)) %>%
      count(platformName, name = "nb_runs") %>%
      arrange(desc(nb_runs)) %>%
      slice_head(n = 1)
    
    valueBox(
      value = best_platform$platformName,
      subtitle = "Plateforme dominante",
      icon = icon("desktop"),
      color = "red"
    )
  })
  
  # Graphiques speedrun SPEEDRUN

  output$runs_games_plot <- renderPlot({
    
    speedrun_filtered() %>%
      count(gameName, name = "nb_runs") %>%
      arrange(desc(nb_runs)) %>%
      slice_head(n = input$top_n) %>%
      ggplot(
        aes(
          x = nb_runs,
          y = reorder(gameName, nb_runs)
        )
      ) +
      geom_col(fill = "steelblue") +
      labs(
        x = "Nombre de runs",
        y = "Jeu"
      ) +
      theme_minimal()
  })
  
  output$runs_platform_plot <- renderPlot({
    
    speedrun_filtered() %>%
      filter(!is.na(platformName)) %>%
      count(platformName, name = "nb_runs") %>%
      arrange(desc(nb_runs)) %>%
      slice_head(n = input$top_n) %>%
      ggplot(
        aes(
          x = nb_runs,
          y = reorder(platformName, nb_runs)
        )
      ) +
      geom_col(fill = "darkorange") +
      labs(
        x = "Nombre de runs",
        y = "Plateforme"
      ) +
      theme_minimal()
  })
  
  output$runs_genre_plot <- renderPlot({
    
    speedrun_filtered() %>%
      filter(!is.na(genreName)) %>%
      count(genreName, name = "nb_runs") %>%
      arrange(desc(nb_runs)) %>%
      slice_head(n = input$top_n) %>%
      ggplot(
        aes(
          x = nb_runs,
          y = reorder(genreName, nb_runs)
        )
      ) +
      geom_col(fill = "darkgreen") +
      labs(
        x = "Nombre de runs",
        y = "Genre"
      ) +
      theme_minimal()
  })
  
  # Gestion du reset des filtres

  observeEvent(input$reset_filters, {
    
    updateSelectInput(
      session,
      "sales_genre",
      selected = character(0)
    )
    
    updateSelectInput(
      session,
      "sales_platform",
      selected = character(0)
    )
    
    updateSelectInput(
      session,
      "speedrun_genre",
      selected = character(0)
    )
    
    updateSelectInput(
      session,
      "speedrun_platform",
      selected = character(0)
    )
    
    updateSelectInput(
      session,
      "region",
      selected = "Global_Sales"
    )
    
    updateSliderInput(
      session,
      "top_n",
      value = 10
    )
  })
  
}



