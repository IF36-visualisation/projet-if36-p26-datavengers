library(tidyverse)
library(stringr)
library(arrow)

# ============================================================================
# Question : Quels Pokémons sont les plus utilisés, et lesquels sont 
# sous-représentés dans le métagame étudié ? (En utilisant le dataset Smogon)
# ============================================================================

# Lire le fichier parquet 
smogon_usage <- read_parquet("../data/smogon/gen1ou-smogon_usage.parquet")

# ============================================================================
# VISUALISATIONS GGPLOT2
# ============================================================================

# ============================================================================
# Premier graphique
# ============================================================================

top_15_all_time <- smogon_usage %>% 
  group_by(pokemon) %>% 
  summarize(all_time_usage = sum(raw_count)) %>% 
  arrange(desc(all_time_usage)) %>%
  head(15)

ggplot(top_15_all_time, aes(x = reorder(pokemon, all_time_usage), y = all_time_usage, fill = all_time_usage)) +
  geom_col() +
  scale_fill_gradient(low = "gray75", high = "black", labels = scales::label_number(suffix = "m", scale = 1e-6)) +
  scale_y_continuous(
    labels = scales::label_number(suffix = "m", scale = 1e-6)
  ) + 
  coord_flip() +
  labs(title = "Top 15 des Pokémon les plus utilisés all time",
       subtitle = "Basé sur le nombres d'utilisations",
       x = "Pokémon", 
       y = "Utilisations",
       fill = "Nombres d'utilisations") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold"),
        axis.text.y = element_text(size = 10))

# ============================================================================
# Second graphique
# ============================================================================

tail_15_all_time <- smogon_usage %>% 
  group_by(pokemon) %>% 
  summarize(all_time_usage = sum(raw_count)) %>% 
  arrange(desc(all_time_usage)) %>%
  tail(15)

ggplot(tail_15_all_time, aes(x = reorder(pokemon, all_time_usage), y = all_time_usage, fill = all_time_usage)) +
  geom_col() +
  scale_fill_gradient(low = "gray75", high = "black") +
  coord_flip() +
  labs(title = "Top 15 des Pokémon les moins utilisés",
       subtitle = "Pokémon sous-représenté dans le métagame",
       x = "Pokémon",
       y = "Utilisations",
       fill = "Nombres d'utilisations") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold"),
        axis.text.y = element_text(size = 10))

# ============================================================================
# Troisième graphique
# ============================================================================

avg_usage <- smogon_usage %>%
  group_by(pokemon) %>%
  summarise(avg_usage_per_pokemon = mean(raw_count, 2)) %>%
  # filter(avg_usage_per_pokemon <= 2000) %>%
  arrange(desc(avg_usage_per_pokemon))
  

ggplot(avg_usage, aes(x = "", y = avg_usage_per_pokemon)) +
  geom_boxplot(fill = "lightblue", width = 0.5) +
  geom_jitter(width = 0.1, alpha = 0.3, size = 2) +
  labs(title = "Distribution du nombres d'utilisations",
       subtitle = "Écart entre les Pokémon les plus et moins utilisés",
       x = "",
       y = "Raw Count") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold"),
        axis.text.x = element_blank())

# ============================================================================
# Quatrième graphique
# ============================================================================
test <- ggplot(avg_usage, aes(x = "", y = avg_usage_per_pokemon)) +
  geom_violin(fill = "lightblue", alpha = 0.6) +
  geom_boxplot(width = 0.2, fill = "white", alpha = 0.8) +
  geom_jitter(width = 0.1, alpha = 0.3, size = 2) +
  labs(title = "Distribution du nombres d'utilsiations",
       subtitle = "Visualisation de la diversité d'utilisation des Pokémon",
       x = "",
       y = "Raw Count") +
  theme_minimal() +
  theme(plot.title = element_text(size = 14, face = "bold"),
        axis.text.x = element_blank())

install.packages("plotly")
library(plotly)
ggplotly(test)

install.packages("ggiraph")
library(ggiraph)
library(ggplot2)

p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point_interactive(aes(tooltip = rownames(mtcars)))  # hover tooltip

girafe(ggobj = p)
