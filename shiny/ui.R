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
    title = "Analyse 2", 
    icon = icon("chart-bar"),
    
    layout_sidebar(
      sidebar = sidebar(
        title = "Contrôles - Visu 2",
        # Exemple de curseur pour la deuxième visualisation
        sliderInput(
          inputId = "seuil_tab2", 
          label = "Sélectionner le seuil :", 
          min = 0, max = 100, value = 50
        )
      ),
      card(
        full_screen = TRUE,
        card_header("Deuxième Visualisation Interactive"),
        card_body(plotOutput("plot2"))
      )
    )
  ),
  
  # ONGLET 3
  nav_panel(
    title = "Analyse 3", 
    icon = icon("chart-pie"),
    
    layout_sidebar(
      sidebar = sidebar(
        title = "Contrôles - Visu 3",
        # Exemple de cases à cocher pour la troisième visualisation
        checkboxGroupInput(
          inputId = "choix_tab3", 
          label = "Variables à afficher :", 
          choices = c("Var X", "Var Y", "Var Z"),
          selected = "Var X"
        )
      ),
      card(
        full_screen = TRUE,
        card_header("Troisième Visualisation Interactive"),
        card_body(plotOutput("plot3"))
      )
    )
  ),
  

  # ONGLET 4
  nav_panel(
    title = "Analyse 4", 
    icon = icon("project-diagram"),
    
    layout_sidebar(
      sidebar = sidebar(
        title = "Contrôles - Visu 4",
        # Exemple d'entrée texte ou autre filtre pour le quatrième onglet
        radioButtons(
          inputId = "Vue_tab4", 
          label = "Type de vue :", 
          choices = c("Globale", "Détaillée")
        )
      ),
      card(
        full_screen = TRUE,
        card_header("Quatrième Visualisation Interactive"),
        card_body(plotOutput("plot4"))
      )
    )
  )
)
