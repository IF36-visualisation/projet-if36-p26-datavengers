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
  
}
