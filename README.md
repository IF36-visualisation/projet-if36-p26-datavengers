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
- `data/accidents_2020_2024.csv` : base fusionnée des accidents (2020–2024), obtenue à partir de `usagers`, `vehicules`, `lieux`, `caracteristiques`.
- `peer-review/` : éléments liés à l’évaluation/relecture par les pairs.
- `shiny/` : code de l’application Shiny (partie interactive du projet).
- `.gitignore` : règles d’exclusion Git.
- `README.md` : proposition du projet, questions de recherche et organisation.

## Conclusion
