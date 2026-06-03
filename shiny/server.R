library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(sf)
library(tmap)
library(here)
library(stringr)
library(tidyr)

function(input, output, session) {
  
  df <- read.csv("../data/accidents_2020_2024_PROPRE.csv", sep = ";")
  sf_use_s2(FALSE)
  
  message("Chargement du fond de carte fluide...")
  url_cartes <- "https://github.com/gregoiredavid/france-geojson/raw/master/departements-version-simplifiee.geojson"
  
  # Lecture directe du GeoJSON allégé (contours lisses, fichier ultra-léger)
  dep_map_propre <- st_read(url_cartes, quiet = TRUE) %>%
    # On renomme la colonne du code département pour correspondre à ton code ("code" -> "DDEP_C_COD")
    rename(DDEP_C_COD = code) %>%
    st_transform(crs = 4326) %>%
    st_make_valid()
  message("Fond de carte chargé avec succès ! Size minimal, fluidité maximale.")
  
  # CONFIGURATION GLOBALE TMAP
  tmap_mode("view")
  
  # --- LOGIQUE ONGLET 1 ---
  data_filtree_tab1 <- reactive({
    data_preparee <- df %>% filter(an %in% input$filtre_annee)
    if (input$filtre_gravite == "graves") {
      data_preparee <- data_preparee %>% filter(grav %in% c(2, 3))
    }
    data_preparee %>%
      filter(agg %in% c(1, 2)) %>%
      mutate(
        Agglomeration = factor(agg, levels = c(1, 2), labels = c("Hors agglomération", "En agglomération")),
        Gravite = factor(grav, levels = if (input$filtre_gravite == "graves") c(3, 2) else c(1, 4, 3, 2), 
                         labels = if (input$filtre_gravite == "graves") c("Blessé hospitalisé", "Tué") else c("Indemne", "Blessé léger", "Blessé hospitalisé", "Tué"))
      )
  })
  
  output$plot1 <- renderPlotly({
    df_plot <- data_filtree_tab1()
    p <- ggplot(df_plot, aes(x = Agglomeration, fill = Gravite)) +
      geom_bar(position = "stack") + theme_minimal() +
      labs(x = "", y = "Nombre d'usagers", fill = "Gravité")
    if (input$filtre_gravite == "graves") {
      p <- p + scale_fill_manual(values = c("Blessé hospitalisé" = "#d7191c", "Tué" = "#000000"))
    } else {
      p <- p + scale_fill_manual(values = c("Indemne" = "#1a9641", "Blessé léger" = "#fdae61", "Blessé hospitalisé" = "#d7191c", "Tué" = "#000000"))
    }
    ggplotly(p)
  })
  
  # --- LOGIQUE ONGLET 2 ---
  data_filtree_tab2 <- reactive({
    data_preparee <- df %>%
      filter(an %in% input$filtre_annee_meteo, atm %in% 1:9, grav %in% 1:4, agg %in% input$filtre_agg_meteo) %>%
      mutate(
        Meteo = factor(atm, levels = 1:9, labels = c("Normale", "Pluie légère", "Pluie forte", "Neige", "Brouillard", "Vent fort", "Éblouissant", "Temps couvert", "Autre")),
        gravite_score = case_when(grav == 1 ~ 1, grav == 4 ~ 2, grav == 3 ~ 3, grav == 2 ~ 4, TRUE ~ NA_real_)
      )
    if (!input$inclure_meteo_normale) data_preparee <- data_preparee %>% filter(atm != 1)
    
    data_preparee %>%
      group_by(an, Num_Acc, Meteo) %>%
      summarise(gravite_max_score = max(gravite_score, na.rm = TRUE), .groups = "drop") %>%
      mutate(Gravite = factor(gravite_max_score, levels = 1:4, labels = c("Indemne", "Blessé léger", "Blessé hospitalisé", "Tué"))) %>%
      group_by(an, Meteo, Gravite) %>%
      summarise(nb_accidents = n(), .groups = "drop") %>%
      group_by(an, Meteo) %>%
      mutate(pourcentage = nb_accidents / sum(nb_accidents) * 100) %>% ungroup()
  })
  
  output$plot2 <- renderPlotly({
    df_plot <- data_filtree_tab2()
    y_val <- if(input$mode_meteo == "nombre") ~nb_accidents else ~pourcentage
    plot_ly(data = df_plot, x = ~Meteo, y = y_val, color = ~Gravite, type = "bar", frame = ~an) %>%
      layout(barmode = "stack", yaxis = list(title = if(input$mode_meteo == "nombre") "Nombre" else "Pourcentage (%)"))
  })
  
  # --- LOGIQUE ONGLET 3 ---
  output$plot3 <- renderPlotly({
    req(df)
    df_heat <- df %>%
      filter(place == 1, an %in% input$filtre_annee_heat, an_nais > 1900, vma > 0, vma <= 130, !vma %in% c(20, 25, 40, 60)) %>%
      mutate(age = an - an_nais) %>% filter(age >= 18, age < 90)
    
    if (input$filtre_sexe_heat != "all") df_heat <- df_heat %>% filter(sexe == as.numeric(input$filtre_sexe_heat))
    if (input$filtre_veh_heat == "voiture") df_heat <- df_heat %>% filter(catv == 7)
    if (input$filtre_veh_heat == "moto") df_heat <- df_heat %>% filter(catv %in% c(30:34))
    
    df_plot <- df_heat %>%
      mutate(age_bin = cut(age, breaks = seq(15, 90, by = 5), right = FALSE), vma_grp = factor(vma)) %>%
      group_by(age_bin, vma_grp) %>%
      summarise(total = n(), taux_grave = mean(grav %in% c(2, 3)) * 100, .groups = "drop") %>%
      filter(total >= input$seuil_n)
    
    p <- ggplot(df_plot, aes(x = age_bin, y = vma_grp, fill = taux_grave)) +
      geom_tile(color = "white") + scale_fill_gradient(low = "#fee0d2", high = "#a50026") +
      theme_minimal() + labs(x = "Âge", y = "Vitesse", fill = "% Grave")
    ggplotly(p)
  })
  
  # --- LOGIQUE ONGLET 4 ---
  output$plot4 <- renderPlotly({
    df_plot <- df %>%
      filter(catv %in% c(7, 30:34), an %in% input$filtre_annee_moto, grav %in% 1:4) %>%
      mutate(Type_Vehicule = ifelse(catv == 7, "Voiture", "Moto"),
             Gravite_Label = factor(case_when(grav == 1 ~ "Indemne", grav == 2 ~ "Tué", grav == 3 ~ "Blessé Hosp.", grav == 4 ~ "Blessé Léger"),
                                    levels = c("Indemne", "Blessé Léger", "Blessé Hosp.", "Tué")))
    
    p <- ggplot(df_plot, aes(x = Type_Vehicule, fill = Gravite_Label)) +
      geom_bar(position = input$mode_moto) +
      scale_fill_manual(values = c("Indemne" = "#1a9641", "Blessé Léger" = "#fdae61", "Blessé Hosp." = "#d7191c", "Tué" = "#000000")) +
      theme_minimal()
    ggplotly(p)
  })
  
  # --- LOGIQUE ONGLET 5 - CARTE ---
  carte_data <- reactive({
    req(input$filtre_annee_map)
    liste_metro <- c(sprintf("%02d", 1:95), "2A", "2B")
    
    df_map <- df %>%
      mutate(
        dep = as.character(dep),
        dep = ifelse(grepl("^[0-9]$", dep), paste0("0", dep), dep)
      ) %>%
      filter(an %in% input$filtre_annee_map, dep %in% liste_metro)
    
    if (input$filtre_sexe_map != "all") {
      df_map <- df_map %>% filter(sexe == as.numeric(input$filtre_sexe_map))
    }
    
    acc_dep <- df_map %>%
      group_by(dep) %>%
      summarise(
        nb_accidents = n(),
        nb_graves = sum(grav %in% c(2, 3)),
        taux_gravite = (nb_graves / n()) * 100,
        .groups = "drop"
      )
    
    dep_map_metro <- dep_map_propre %>% 
      filter(DDEP_C_COD %in% liste_metro) %>%
      left_join(acc_dep, by = c("DDEP_C_COD" = "dep")) %>%
      mutate(
        nb_accidents = ifelse(is.na(nb_accidents), 0, nb_accidents),
        taux_gravite = ifelse(is.na(taux_gravite), 0, taux_gravite)
      )
    
    df_sf_metro <- df_map %>%
      mutate(
        long = as.numeric(gsub(",", ".", long)),
        lat = as.numeric(gsub(",", ".", lat))
      ) %>%
      filter(!is.na(long), !is.na(lat)) %>%
      slice_sample(n = min(45000, nrow(.))) %>% 
      st_as_sf(coords = c("long", "lat"), crs = 4326)
    
    df_sf_metro <- df_sf_metro[, "geometry"]
    
    list(polygones = dep_map_metro, points = df_sf_metro)
  })
  
  output$plot5 <- renderTmap({
    res <- carte_data()
    
    var_to_show <- if(input$variable_map == "nb") "nb_accidents" else "taux_gravite"
    titre_legende <- if(input$variable_map == "nb") "Densité accidents" else "Taux gravité (%)"
    
    m <- tm_shape(res$polygones, bbox = st_bbox(res$polygones)) +
      tm_polygons(
        col = var_to_show,
        palette = "YlOrRd",
        alpha = 0.5,
        title = titre_legende,
        id = "nom"
      )
    
    if(input$show_dots && nrow(res$points) > 0) {
      m <- m + tm_shape(res$points) +
        tm_dots(
          col = "red",
          size = 0.005,
          alpha = 0.35,
          interactive = FALSE,
          legend.show = FALSE
        )
    }
    
    m + tm_view(
      basemaps = "CartoDB.Positron",
      view.legend.position = c("right", "bottom"),
      set.view = c(2.21, 46.22, 6),
      leaflet.options = list(preferCanvas = TRUE)
    )
  })
}