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

  # LOGIQUE ONGLET 3
  output$plot3 <- renderPlotly({
    req(df)
    
    # Filtrage des données de base pour les conducteurs
    df_heat <- df %>%
      filter(place == 1, 
             an %in% input$filtre_annee_heat,
             !is.na(an_nais), an_nais > 1900,
             !is.na(vma), vma > 0, vma <= 130,
             !vma %in% c(20, 25, 40, 60)) %>%
      mutate(age = an - an_nais) %>%
      filter(age >= 18, age < 90)
    
    # Filtre Sexe
    if (input$filtre_sexe_heat != "all") {
      df_heat <- df_heat %>% filter(sexe == as.numeric(input$filtre_sexe_heat))
    }
    
    # Filtre Véhicule
    if (input$filtre_veh_heat == "voiture") {
      df_heat <- df_heat %>% filter(catv == 7)
    } else if (input$filtre_veh_heat == "moto") {
      df_heat <- df_heat %>% filter(catv %in% c(30, 31, 32, 33, 34))
    }
    
    # Agrégation
    df_plot <- df_heat %>%
      mutate(
        age_bin = cut(age, breaks = seq(15, 90, by = 5), right = FALSE, 
                      labels = paste(seq(15, 85, by = 5), seq(19, 89, by = 5), sep="-")),
        vma_grp = factor(vma)
      ) %>%
      group_by(age_bin, vma_grp) %>%
      summarise(
        total = n(),
        taux_grave = mean(grav %in% c(2, 3)) * 100,
        .groups = "drop"
      ) %>%
      filter(total >= input$seuil_n)
    
    # Création du ggplot
    p <- ggplot(df_plot, aes(x = age_bin, y = vma_grp, fill = taux_grave,
                            text = paste("Tranche d'âge :", age_bin,
                                         "<br>Vitesse :", vma_grp, "km/h",
                                         "<br>Taux de gravité :", round(taux_grave, 1), "%",
                                         "<br>Nombre de cas (n) :", total))) +
      geom_tile(color = "white") +
      scale_fill_gradient(low = "#fee0d2", high = "#a50026", name = "% Grave") +
      labs(x = "Tranches d'âge du conducteur",
           y = "Vitesse autorisée (km/h)") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p, tooltip = "text")
  })
}

