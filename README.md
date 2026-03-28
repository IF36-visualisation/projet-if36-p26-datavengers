# Projet IF36

## Introduction

### Contexte et objectif

Dans le cadre de ce projet, nous avons travaillé sur un jeu de données fusionné issu de la base BAAC (Bulletin d’Analyse des Accidents Corporels) en France.

Le fichier principal `accidents_2020_2024.csv` combine les informations de quatre tables (`caractéristiques`, `lieux`, `véhicules`, `usagers`) sur la période 2020–2024.

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
| 1 |          |                      |               |          |

## Membres du groupe

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
- `data/accidents_2020_2024.csv` : base fusionnée des accidents (2020–2024).
- `peer-review/` : éléments liés à l’évaluation/relecture par les pairs.
- `shiny/` : code de l’application Shiny (partie interactive du projet).
- `.gitignore` : règles d’exclusion Git.
- `README.md` : proposition du projet, questions de recherche et organisation.

## Conclusion
