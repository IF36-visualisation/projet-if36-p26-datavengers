# Projet IF36

## Introduction

### Contexte et objectif

Dans le cadre de ce projet, nous avons exploité un jeu de données consolidé issu du fichier BAAC (Bulletin d’Analyse des Accidents Corporels). Les données sources proviennent du jeu de données officiel **[Bases de données annuelles des accidents corporels de la circulation routière - 2005 à 2024](https://www.data.gouv.fr/datasets/bases-de-donnees-annuelles-des-accidents-corporels-de-la-circulation-routiere-annees-de-2005-a-2024)**, disponible sur la plateforme data.gouv.fr.

Notre fichier principal `accidents_2020_2024.csv` a été construit pour l’analyse en fusionnant, pour chaque année de 2020 à 2024, les 4 tables BAAC suivantes :
- `usagers`
- `vehicules`
- `lieux`
- `caracteristiques`

L’objectif est de mener une exploration visuelle des accidents corporels en cherchant des relations entre la gravité, le contexte routier, les profils d’usagers, les véhicules et la temporalité. Nous voulons identifier ce qui semble augmenter le risque d’accident grave, tout en restant critiques sur les limites de la donnée.

### Structure et nature des données

#### Données 

Le fichier CSV contient **689 434 lignes** et **56 variables**.

**Variables temporelles :**

**Variables spatiales :**

**Variables de contexte routier :**

**Variables véhicule :**

**Variables usager :**

## Plan d’analyse

## Questions de recherche

| # | Question | Variables utilisées | Visualisation | Objectif |
| - | -------- | -------------------- | ------------- | -------- |
| 1 | Comment le nombre total d’accidents évolue-t-il entre 2020 et 2024 ? | an, Num_Acc | courbe (line chart) | Identifier l’évolution globale du nombre d’accidents |
| 2 | Y a-t-il des tendances saisonnières (plus d’accidents en hiver/été) ? | mois, an, Num_Acc | courbe + heatmap | Mettre en évidence des variations saisonnières |
| 3 | Où se produisent le plus d’accidents (région, département, ville) ? | dep, com, lat, long, Num_Acc | carte (choroplèthe / points) | Identifier les zones géographiques à risque |
| 4 | Quelle est la répartition des victimes par âge et par sexe ? | an_nais, sexe | histogrammes | Analyser les profils démographiques des victimes |
| 5 | À quelles heures de la journée les accidents sont-ils les plus fréquents ? | hrmn, Num_Acc | histogramme / courbe | Identifier les heures les plus accidentogènes |
| 6 | Quel est l’impact de la météo (pluie, neige, brouillard) sur les accidents ? | atm, Num_Acc, grav | diagramme en barres | Mesurer l’influence des conditions atmosphériques |
| 7 | Existe-t-il un seuil (âge, vitesse estimée, heure…) à partir duquel le risque explose ? | an_nais, hrmn, vma, grav | scatter plot + courbe de tendance | Détecter des effets de seuil sur la gravité |
| 8 | Les motos ont-elles un taux de gravité plus élevé ? | catv, grav | barres comparatives | Comparer la gravité selon le type de véhicule |
| 9 | Les accidents sont-ils plus graves la nuit que le jour ? | lum, grav | barres empilées | Évaluer l’impact de la luminosité |
| 10 | Les accidents en agglomération sont-ils différents de ceux hors agglomération ? | agg, grav, Num_Acc | barres comparatives | Comparer les contextes urbain vs rural |
| 11 | Le type de route influence-t-il la gravité des accidents ? | catr, grav | diagramme en barres | Identifier les routes les plus dangereuses |
| 12 | L’état de la chaussée influence-t-il les accidents ? | surf, grav, Num_Acc | barres empilées | Comprendre l’impact des conditions de route |
| 13 | Le nombre de voies influence-t-il la fréquence ou la gravité des accidents ? | nbv, grav, Num_Acc | boxplot / barres | Étudier l’effet de l’infrastructure |
| 14 | Les équipements de sécurité (ceinture, casque) réduisent-ils la gravité ? | secu1, secu2, secu3, grav | barres comparatives | Évaluer l’efficacité des dispositifs de sécurité |
| 15 | Certaines manœuvres ou collisions sont-elles plus dangereuses que d’autres ? | manv, col, grav | diagramme en barres | Identifier les situations les plus à risque |

## Membres du groupe

- Paul-Louis LEDOUX
- Oleksandr VSALOV
- Max DIECHTIAREFF--HUCK
- Marega TANDJIGORA 

## Organisation du projet

Le dépôt est organisé de la manière suivante :

```text
projet-if36-p26-datavengers/
├── data/
│   └── accidents_2020_2024.csv
├── peer-review/
├── shiny/
├── .gitignore
└── README.md
```

Description rapide des dossiers/fichiers :

- `data/` : contient le dataset principal utilisé dans l’analyse.
- `data/accidents_2020_2024.csv` : base fusionnée des accidents (2020–2024), obtenue à partir de `usagers`, `vehicules`, `lieux`, `caracteristiques`.
- `peer-review/` : éléments liés à l’évaluation/relecture par les pairs.
- `shiny/` : code de l’application Shiny (partie interactive du projet).
- `.gitignore` : règles d’exclusion Git.
- `README.md` : proposition du projet, questions de recherche et organisation.

## Conclusion
