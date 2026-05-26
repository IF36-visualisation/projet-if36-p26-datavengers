library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)

function(input, output, session) {

  df <- read.csv("../data/accidents_2020_2024_PROPRE.csv", sep = ";") 

  # LOGIQUE ONGLET 1
  data_filtree_tab1 <- reactive({
    data_preparee <- df %>% 
      filter(an %in% input$filtre_annee)

    if (input$filtre_gravite == "graves") {
      data_preparee <- data_preparee %>% filter(grav %in% c(2, 3))
    } else {
      data_preparee <- data_preparee %>% filter(grav %in% c(1, 2, 3, 4))
    }

    data_preparee %>%
      filter(agg %in% c(1, 2)) %>%
      mutate(
        Agglomeration = factor(agg, 
                               levels = c(1, 2), 
                               labels = c("Hors agglomération", "En agglomération")),
        Gravite = factor(grav, 
                         levels = if (input$filtre_gravite == "graves") c(3, 2) else c(1, 4, 3, 2), 
                         labels = if (input$filtre_gravite == "graves") c("Blessé hospitalisé", "Tué") else c("Indemne", "Blessé léger", "Blessé hospitalisé", "Tué"))
      )
  })

  output$plot1 <- renderPlotly({
    df_plot <- data_filtree_tab1()

    p <- ggplot(df_plot, aes(x = Agglomeration, fill = Gravite)) +
      geom_bar(position = "stack") +
      theme_minimal() +
      labs(
        title = if (input$filtre_gravite == "graves") "Accidents graves" else "Gravité des accidents",
        x = "",
        y = "Nombre d'usagers impliqués",
        fill = "Niveau de gravité"
      )

    if (input$filtre_gravite == "graves") {
      p <- p + scale_fill_manual(values = c("Blessé hospitalisé" = "#d7191c", "Tué" = "#000000"))
    } else {
      p <- p + scale_fill_manual(values = c("Indemne" = "#1a9641", "Blessé léger" = "#fdae61", "Blessé hospitalisé" = "#d7191c", "Tué" = "#000000"))
    }

    ggplotly(p)
  })
  
  # LOGIQUE ONGLET 2
  data_filtree_tab2 <- reactive({
    data_preparee <- df %>%
      filter(an %in% input$filtre_annee_meteo) %>%
      filter(atm %in% c(1, 2, 3, 4, 5, 6, 7, 8, 9)) %>%
      filter(grav %in% c(1, 2, 3, 4)) %>%
      filter(agg %in% input$filtre_agg_meteo) %>%
      mutate(
        Meteo = factor(
        atm,
        levels = c(1, 2, 3, 4, 5, 6, 7, 8, 9),
        labels = c(
          "Normale",
          "Pluie légère",
          "Pluie forte",
          "Neige / grêle",
          "Brouillard",
          "Vent fort / tempête",
          "Temps éblouissant",
          "Temps couvert",
          "Autre"
          )
        ),
        
        Gravite = factor(
          grav,
          levels = c(1, 4, 3, 2),
          labels = c(
            "Indemne",
            "Blessé léger",
            "Blessé hospitalisé",
            "Tué"
          )
        ),
        
        Agglomeration = factor(
          agg,
          levels = c(1, 2),
          labels = c(
            "Hors agglomération",
            "En agglomération"
          )
        ),
        
        # Score pour trouver la gravité maximale par accident
        gravite_score = case_when(
          grav == 1 ~ 1, # Indemne
          grav == 4 ~ 2, # Blessé léger
          grav == 3 ~ 3, # Blessé hospitalisé
          grav == 2 ~ 4, # Tué
          TRUE ~ NA_real_
        )
      )
    if (!input$inclure_meteo_normale) {
      data_preparee <- data_preparee %>%
        filter(atm != 1)
    }
  
  data_preparee %>%
    group_by(an, Num_Acc, Meteo, Agglomeration) %>%
    summarise(
      gravite_max_score = max(gravite_score, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      Gravite = factor(
        gravite_max_score,
        levels = c(1, 2, 3, 4),
        labels = c(
          "Indemne",
          "Blessé léger",
          "Blessé hospitalisé",
          "Tué"
        )
      )
    ) %>%
    group_by(an, Meteo, Gravite, Agglomeration) %>%
    summarise(
      nb_accidents = n(),
      .groups = "drop"
    ) %>%
    group_by(an, Meteo) %>%
    mutate(
      pourcentage = nb_accidents / sum(nb_accidents) * 100
    ) %>%
    ungroup()
  })
output$plot2 <- renderPlotly({
  
  df_plot <- data_filtree_tab2()
  
  if (length(input$filtre_agg_meteo) == 2){
    title_agg = "toutes zones"
  } else if (length(input$filtre_agg_meteo) == 1 && input$filtre_agg_meteo == 1){
    title_agg <- "hors agglomération"
  } else if(length(input$filtre_agg_meteo) == 1 && input$filtre_agg_meteo == 2){
    title_agg <- "en agglomération"
  } else {
    title_agg <- "aucune zone sélectionnée"
  }
  
  if (input$mode_meteo == "nombre"){
    y_value <- ~nb_accidents
    y_title <- "Nombre d'accidents"
    hover_value <- ~paste(
      "Année :", an,
      "<br>Météo :", Meteo,
      "<br>Gravité :", Gravite,
      "<br>Nombre d'accidents :", nb_accidents
    )
    graph_title <- paste("Impact de la météo sur le nombre d'accidents - ",
    title_agg)
  } else {
    y_value <- ~pourcentage
    y_title <- "Pourcentage d'accidents (%)"
    hover_value <- ~paste(
      "Année :", an,
      "<br>Météo :", Meteo,
      "<br>Gravité :", Gravite,
      "<br>Pourcentage :", round(pourcentage, 1), "%"
    )
    graph_title <- paste("Répartition des accidents par météo en pourcentage -",
    title_agg)
  }
  
  
  
  plot_ly(
    data = df_plot,
    x = ~Meteo,
    y = y_value,
    color = ~Gravite,
    type = "bar",
    frame = ~an,
    text = hover_value,
    hoverinfo = "text"
  ) %>%
    layout(
      title = graph_title,
      xaxis = list(title = "Condition météorologique"),
      yaxis = list(
        title = y_title,
        range = if (input$mode_meteo == "pourcentage") c(0, 100) else NULL
        ),
      barmode = "stack",
      legend = list(title = list(text = "Gravité"))
    ) %>%
    animation_opts(
      frame = 1000,
      transition = 500,
      redraw = TRUE
    ) %>%
    animation_slider(
      currentvalue = list(prefix = "Année : ")
    ) %>%
    animation_button(
      x = 1,
      xanchor = "right",
      y = 0,
      yanchor = "bottom"
    )
})
}
