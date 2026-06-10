library(shiny)
library(bslib)
library(dplyr)
library(plotly)
library(tmap)

page_navbar(
  title = "Projet DataVengers",
  theme = bs_theme(version = 5, preset = "zephyr"),
  
  # ONGLET 1
  nav_panel(
    title = "Agglomération & Gravité", 
    icon = icon("city"),
    layout_sidebar(
      sidebar = sidebar(
        title = "Filtres",
        radioButtons("filtre_gravite", "Niveau de gravité :",
                     choices = c("Toutes les gravités" = "toutes", 
                                 "Uniquement accidents graves (Tués/Hosp.)" = "graves")),
        checkboxGroupInput("filtre_annee", "Année(s) :", choices = 2020:2024, selected = 2020:2024)
      ),
      card(full_screen = TRUE, card_header("Gravité des accidents : Agglomération vs Hors agglomération"),
           card_body(plotlyOutput("plot1")))
    )
  ),
  
  # ONGLET 2
  nav_panel(
    title = "Meteo & Accidents", 
    icon = icon("cloud-sun-rain"),
    layout_sidebar(
      sidebar = sidebar(
        title = "Filtres",
        checkboxGroupInput("filtre_annee_meteo", "Année(s) :", choices = 2020:2024, selected = 2020:2024),
        checkboxInput("inclure_meteo_normale", "Inclure la météo normale", value = TRUE),
        checkboxGroupInput("filtre_agg_meteo", "Agglomération :", 
                           choices = c("Hors agglomération" = 1, "En agglomération" = 2), selected = c(1, 2)),
        radioButtons("mode_meteo", "Mode d'affichage :", 
                     choices = c("Nombre d'accidents" = "nombre", "Pourcentage" = "pourcentage"))
      ),
      card(full_screen = TRUE, card_header("Impact de la météo sur les accidents"),
           card_body(plotlyOutput("plot2")))
    )
  ),
  
  # ONGLET 3
  nav_panel(
    title = "Âge vs Vitesse", 
    icon = icon("gauge-high"),
    layout_sidebar(
      sidebar = sidebar(
        title = "Filtres Risque",
        checkboxGroupInput("filtre_annee_heat", "Année(s) :", choices = 2020:2024, selected = 2020:2024),
        selectInput("filtre_sexe_heat", "Sexe du conducteur :", choices = c("Tous" = "all", "Masculin" = 1, "Féminin" = 2)),
        selectInput("filtre_veh_heat", "Type de véhicule :", choices = c("Tous" = "all", "Voiture" = "voiture", "Moto" = "moto")),
        sliderInput("seuil_n", "Seuil de représentativité (n min) :", min = 5, max = 100, value = 30)
      ),
      card(full_screen = TRUE, card_header("Heatmap Âge vs Vitesse"),
           card_body(plotlyOutput("plot3")))
    )
  ),
  
  # ONGLET 4
  nav_panel(
    title = "Motos vs Voitures",
    icon = icon("motorcycle"),
    layout_sidebar(
      sidebar = sidebar(
        title = "Filtres",
        checkboxGroupInput("filtre_annee_moto", "Année(s) :", choices = 2020:2024, selected = 2020:2024),
        radioButtons("mode_moto", "Mode d'affichage :", choices = c("Proportions" = "fill", "Nombres" = "stack"))
      ),
      card(full_screen = TRUE, card_header("Répartition de la gravité : Voiture vs Moto"),
           card_body(plotlyOutput("plot4")))
    )
  ),
  
  # ONGLET 5 - CARTE CHOROPLÈTHE (Mise à jour avec tes filtres)
  nav_panel(
    title = "Carte des Accidents",
    icon = icon("map-location-dot"),
    layout_sidebar(
      sidebar = sidebar(
        title = "Paramètres de la carte",
        checkboxGroupInput("filtre_annee_map", "Année(s) :", choices = 2020:2024, selected = 2023),
        selectInput("filtre_sexe_map", "Sexe :", choices = c("Tous" = "all", "Masculin" = 1, "Féminin" = 2)),
        hr(),
        radioButtons("variable_map", "Donnée à afficher :",
                     choices = c("Nombre total d'accidents" = "nb", 
                                 "Taux de gravité (%)" = "taux")),
        checkboxInput("show_dots", "Afficher les points (échantillon)", value = TRUE)
      ),
      card(full_screen = TRUE, card_header("Analyse géographique par département"),
           card_body(tmapOutput("plot5")))
    )
  )
)