#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinydashboard)

dashboardPage(
  
  dashboardHeader(
    title = "Projet - La Vague"
  ),
  
  dashboardSidebar(
    
    sidebarMenu(
      menuItem(
        "Ventes",
        tabName = "ventes",
        icon = icon("chart-column")
      ),
      
      menuItem(
        "Speedruns",
        tabName = "speedruns",
        icon = icon("stopwatch")
      )
    ),
    
    hr(),
    
    h4("Filtres ventes"),
    
    selectInput(
      "region",
      "Région des ventes :",
      choices = c(
        "Global" = "Global_Sales",
        "Amérique du Nord" = "NA_Sales",
        "Europe" = "EU_Sales",
        "Japon" = "JP_Sales",
        "Autres régions" = "Other_Sales"
      ),
      selected = "Global_Sales"
    ),
    
    selectInput(
      "sales_genre",
      "Genre :",
      choices = NULL,
      multiple = TRUE
    ),
    
    selectInput(
      "sales_platform",
      "Plateforme :",
      choices = NULL,
      multiple = TRUE
    ),
    
    hr(),
    
    h4("Filtres speedrun"),
    
    selectInput(
      "speedrun_genre",
      "Genre speedrun :",
      choices = NULL,
      multiple = TRUE
    ),
    
    selectInput(
      "speedrun_platform",
      "Plateforme speedrun :",
      choices = NULL,
      multiple = TRUE
    ),
    
    hr(),
    
    sliderInput(
      "top_n",
      "Nombre d'éléments à afficher :",
      min = 5,
      max = 25,
      value = 10
    ),
    
    actionButton(
      "reset_filters",
      "Réinitialiser les filtres",
      icon = icon("rotate-left")
    )
  ),
  
  dashboardBody(
    
    tabItems(
      
      # Page Ventes
      tabItem(
        tabName = "ventes",
        
        fluidRow(
          valueBoxOutput("total_sales_box"),
          valueBoxOutput("nb_games_box"),
          valueBoxOutput("best_genre_box")
        ),
        
        fluidRow(
          box(
            title = "Les Plateformes qui vendent le plus de jeux",
            width = 6,
            status = "primary",
            solidHeader = TRUE,
            plotOutput("sales_platform_plot")
          ),
          
          box(
            title = "Ventes globales par genre de jeu vidéo",
            width = 6,
            status = "primary",
            solidHeader = TRUE,
            plotOutput("sales_genre_plot")
          )
        ),
        
        fluidRow(
          box(
            title = "Jeux les plus vendus",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            plotOutput("top_games_plot")
          )
        )
      ),
      
      
      # Page Speedrun SPEEDRUNS
      tabItem(
        tabName = "speedruns",
        
        fluidRow(
          valueBoxOutput("nb_runs_box"),
          valueBoxOutput("nb_speedrun_games_box"),
          valueBoxOutput("best_speedrun_platform_box")
        ),
        
        fluidRow(
          box(
            title = "Plateformes les plus populaires en speedrun",
            width = 6,
            status = "warning",
            solidHeader = TRUE,
            plotOutput("runs_platform_plot")
          ),
          box(
            title = "Genres les plus représentés en speedrun",
            width = 6,
            status = "warning",
            solidHeader = TRUE,
            plotOutput("runs_genre_plot")
          )
        ),
        
        fluidRow(
          box(
            title = "Jeux avec le plus de runs",
            width = 12,
            status = "warning",
            solidHeader = TRUE,
            plotOutput("runs_games_plot")
          )
        )
      )
    )
  )
)


