library(shiny)
library(bslib)
library(dplyr)

# Définition de l'interface utilisateur
page_navbar(
  title = "Projet DataVengers",
  theme = bs_theme(version = 5, preset = "zephyr"), # zephyr est un thème moderne
  
  # ONGLET 1
  nav_panel(
    title = "Agglomération & Gravité", 
    icon = icon("city"),
    
    layout_sidebar(
      sidebar = sidebar(
        title = "Filtres",
        radioButtons(
          inputId = "filtre_gravite",
          label = "Niveau de gravité :",
          choices = c("Toutes les gravités" = "toutes", 
                      "Uniquement accidents graves (Tués/Hosp.)" = "graves")
        ),
        checkboxGroupInput(
          inputId = "filtre_annee",
          label = "Année(s) :",
          choices = 2020:2024,
          selected = 2020:2024
        )
      ),
      card(
        full_screen = TRUE,
        card_header("Gravité des accidents : En agglomération vs hors agglomération"),
        card_body(plotly::plotlyOutput("plot1"))
      )
    )
  ),
  
  # ONGLET 2
  nav_panel(
    title = "Meteo & Accidents", 
    icon = icon("cloud-sun-rain"),
    
    layout_sidebar(
      sidebar = sidebar(
        title = "Filtres",
        
        checkboxGroupInput(
          inputId = "filtre_annee_meteo",
          label = "Année(s) :",
          choices = 2020:2024,
          selected = 2020:2024
        ),
        
        checkboxInput(
          inputId = "inclure_meteo_normale",
          label = "Inclure la météo normale",
          value = TRUE
        ),
        
        checkboxGroupInput(
          inputId = "filtre_agg_meteo",
          label = "Agglomération :",
          choices = c(
            "Hors agglomération" = 1,
            "En agglomération" = 2
          ),
          selected = c(1, 2)
        ), 
        
        radioButtons(
          inputId = "mode_meteo",
          label = "Mode d'affichage :",
          choices = c(
            "Nombre d'accidents" = "nombre",
            "Pourcentage" = "pourcentage"
          ),
          selected = "nombre"
        )
      ),
      card(
        full_screen = TRUE,
        card_header("Impact des conditions météorologiques sur les accidents"),
        card_body(plotly::plotlyOutput("plot2"))
      )
    )
  ),
  
  # ONGLET 3
  nav_panel(
    title = "Âge vs Vitesse", 
    icon = icon("gauge-high"),
    
    layout_sidebar(
      sidebar = sidebar(
        title = "Filtres Risque",
        checkboxGroupInput(
          inputId = "filtre_annee_heat",
          label = "Année(s) :",
          choices = 2020:2024,
          selected = 2020:2024
        ),
        selectInput(
          inputId = "filtre_sexe_heat",
          label = "Sexe du conducteur :",
          choices = c("Tous" = "all", "Masculin" = 1, "Féminin" = 2),
          selected = "all"
        ),
        selectInput(
          inputId = "filtre_veh_heat",
          label = "Type de véhicule :",
          choices = c("Tous" = "all", "Voiture" = "voiture", "Moto" = "moto"),
          selected = "all"
        ),
        sliderInput(
          inputId = "seuil_n",
          label = "Seuil de représentativité (n min) :",
          min = 5, max = 100, value = 30, step = 5
        )
      ),
      card(
        full_screen = TRUE,
        card_header("Heatmap du taux de gravité (Âge du conducteur vs Vitesse autorisée)"),
        card_body(plotly::plotlyOutput("plot3"))
      )
    )
  ),
  
  
  # ONGLET 4
  nav_panel(
    title = "Motos vs Voitures",
    icon = icon("motorcycle"),
    
    layout_sidebar(
      sidebar = sidebar(
        title = "Filtres",
        
        checkboxGroupInput(
          inputId = "filtre_annee_moto",
          label = "Année(s) :",
          choices = 2020:2024,
          selected = 2020:2024
        ),
        
        radioButtons(
          inputId = "mode_moto",
          label = "Mode d'affichage :",
          choices = c(
            "Proportions (% relatif)" = "fill",
            "Nombres absolus"         = "stack"
          ),
          selected = "fill"
        )
      ),
      
      card(
        full_screen = TRUE,
        card_header("Répartition de la gravité : Voiture vs Moto"),
        card_body(plotly::plotlyOutput("plot4"))
      )
    )
  )
)
