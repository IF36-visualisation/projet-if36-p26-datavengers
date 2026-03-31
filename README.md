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

## Structure et nature des données

Le fichier CSV contient **689 434 lignes** et **56 variables**. 

Les correspondances complètes se trouvent dans le pdf 'Descriptions_des_bases_de_données_annuelles.pdf'. Nous avons décider de ne pas toutes les mettre pour ne surcharger les tableaux déjà conséquents.

---

### 1. Identifiants (7 variables)
| Variable | Note (Libellé) | Type | Description |
| :--- | :--- | :--- | :--- |
| **Num_Acc** | Identifiant Accident | VARCHAR | Identifiant unique de l'accident. |
| **id_vehicule** | Identifiant Véhicule | VARCHAR | Identifiant unique du véhicule. |
| **num_veh** | Numéro Véhicule | VARCHAR | Identifiant relatif (A01, B01...). |
| **num_veh_veh** | Numéro Véhicule (Lien) | VARCHAR | Doublon technique de `num_veh`. |
| **id_usager** | Identifiant Usager | VARCHAR | Identifiant unique de l'usager. |
| **annee_dataset** | Année Source | INTEGER | Année du fichier d'origine. |
| **adr** | Adresse | VARCHAR | Adresse postale simplifiée. |

*Note : Ces variables peuvent être surpprimer car inutiles dans l'annalyse*

---

### 2. Variables temporelles (5 variables)
| Variable | Note (Libellé) | Type | Format / Valeurs |
| :--- | :--- | :--- | :--- |
| **an** | Année | INTEGER | Format YYYY. |
| **mois** | Mois | INTEGER | 1 à 12. |
| **jour** | Jour | INTEGER | 1 à 31. |
| **hrmn** | Heure et Minute | VARCHAR | Format HH:MM. |
| **an_nais** | Année naissance | INTEGER | Année de naissance de l'usager. |

---

### 3. Profil et état de l'usager (12 variables)
| Variable | Note (Libellé) | Type | Valeurs |
| :--- | :--- | :--- | :--- |
| **place** | Place occupée | INTEGER | 1:Conducteur, 2:Passager AV, 10:Piéton... |
| **catu** | Catégorie usager | INTEGER | 1:Conducteur, 2:Passager, 3:Piéton. |
| **grav** | Gravité | INTEGER | 1:Indemne, 2:Tué, 3:Hospit, 4:Léger. |
| **sexe** | Sexe | INTEGER | 1:Masculin, 2:Féminin. |
| **trajet** | Motif déplacement | INTEGER | 1:Travail, 5:Loisirs, 9:Autre. |
| **secu1** | Équipement 1 | INTEGER | 1:Ceinture, 2:Casque, 9:Non utilisé. |
| **secu2** | Équipement 2 | INTEGER | Idem secu1. |
| **secu3** | Équipement 3 | INTEGER | Idem secu1. |
| **locp** | Localis. piéton | INTEGER | 1:Sur chaussée, 5:Trottoir... |
| **actp** | Action piéton | INTEGER | 3:Traversant, 6:Statique... |
| **etatp** | État piéton | INTEGER | 1:Seul, 2:Accompagné, 3:En groupe. |
| **occutc** | Occupants TC | INTEGER | Nb d'occupants dans les transports en commun. |

---

### 4. Caractéristiques du véhicule (7 variables)
| Variable | Note (Libellé) | Type | Valeurs |
| :--- | :--- | :--- | :--- |
| **senc** | Sens circulation | INTEGER | 1:Sens croissant, 2:Sens inverse. |
| **catv** | Catégorie véhicule | INTEGER | 07:VL, 01:Vélo, 33:Moto... |
| **obs** | Obstacle fixe | INTEGER | 1:Véh. stationné, 2:Arbre, 10:Mur... |
| **obsm** | Obstacle mobile | INTEGER | 1:Piéton, 2:Véhicule, 6:Animal. |
| **choc** | Point de choc | INTEGER | 1:Avant, 2:Arrière, 3:Droit, 4:Gauche. |
| **manv** | Manœuvre | INTEGER | 1:Sans changement, 15:Tourne G... |
| **motor** | Motorisation | INTEGER | 1:Hydrocarbures, 3:Élec, 4:Hydrogène. |

*Note : Là aussi des variables sont inutiles et peuvent donc être surpprimées*

---

### 5. Localisation et contexte (10 variables)
| Variable | Note (Libellé) | Type | Valeurs |
| :--- | :--- | :--- | :--- |
| **dep** | Département | VARCHAR | Code (ex: 75, 2A). |
| **com** | Commune | VARCHAR | Code INSEE commune. |
| **agg** | Agglomération | INTEGER | 1:Hors agglo, 2:En agglo. |
| **int** | Intersection | INTEGER | 1:Hors int., 6:Giratoire... |
| **lum** | Lumière | INTEGER | 1:Jour, 5:Nuit avec écl. |
| **atm** | Météo | INTEGER | 1:Normale, 2:Pluie, 4:Neige... |
| **col** | Type collision | INTEGER | 1:Frontale, 3:Côté, 6:Autre. |
| **lat** | Latitude | FLOAT | Coordonnée |
| **long** | Longitude | FLOAT | Coordonnée |
| **situ** | Situation | INTEGER | 1:Sur chaussée, 3:Accotement, 4:Trottoir. |

---

### 6. Infrastructure et voie (16 variables)
| Variable | Note (Libellé) | Type | Valeurs |
| :--- | :--- | :--- | :--- |
| **catr** | Catégorie route | INTEGER | 1:Autoroute, 3:Départementale... |
| **voie** | Nom de la voie | VARCHAR | Nom de la rue ou route. |
| **v1** | Numéro route | VARCHAR | Numéro de la voie. |
| **v2** | Indice route | VARCHAR | Indice alphanumérique de la voie. |
| **circ** | Régime circulation | INTEGER | 1:Sens unique, 2:Bidirectionnel. |
| **nbv** | Nb de voies | INTEGER | Nombre total de voies. |
| **vosp** | Voie réservée | INTEGER | 1:Piste cyclable, 2:Voie bus. |
| **prof** | Profil route | INTEGER | 1:Plat, 2:Pente, 3:Sommet. |
| **pr** | Point de repère | VARCHAR | Numéro du PR. |
| **pr1** | Distance au PR | VARCHAR | Distance en mètres au PR. |
| **plan** | Tracé en plan | INTEGER | 1:Rectiligne, 2:Courbe. |
| **lartpc** | Largeur TPC | FLOAT | Largeur du terre-plein central. |
| **larrout** | Largeur chaussée | FLOAT | Largeur de la route (hors accotements). |
| **surf** | État surface | INTEGER | 1:Normale, 2:Mouillée, 7:Verglacée. |
| **infra** | Aménagement | INTEGER | 1:Souterrain, 3:Échangeur, 5:Pont. |
| **vma** | Vitesse autorisée | INTEGER | Vitesse max en km/h. |
---
*Note : Les valeurs `-1` ou `0` indiquent une donnée non renseignée ou non applicable.*


## Plan d’analyse

## Questions de recherche

| # | Question | Variables utilisées | Visualisation | Objectif | Hypothèse | 
| - | -------- | -------------------- | ------------- | ----------- | -------------|
| 1 | Comment le nombre total d’accidents évolue-t-il entre 2020 et 2024 ? | an, Num_Acc | courbe (line chart) | Identifier l’évolution globale du nombre d’accidents | Plus de voiture donc plus d'accidents |
| 2 | Y a-t-il des tendances saisonnières (plus d’accidents en hiver/été) ? | mois, an, Num_Acc | courbe + heatmap | Mettre en évidence des variations saisonnières | Plus d'accident en hiver fin d'automne (neige, verglas, pas de pneus neige) |
| 3 | Où se produisent le plus d’accidents (région, département, ville) ? | dep, com, lat, long, Num_Acc | carte (choroplèthe / points) | Identifier les zones géographiques à risque | Dans les grandes villes car plus de circulation et de risques (petits accidents) |
| 4 | Quelle est la répartition des victimes par âge et par sexe ? | an_nais, sexe | histogrammes | Analyser les profils démographiques des victimes | Personnes agées et plus d'hommes (dépend des accidents). |
| 5 | À quelles heures de la journée les accidents sont-ils les plus fréquents ? | hrmn, Num_Acc | histogramme / courbe | Identifier les heures les plus accidentogènes | La nuit car la visibilitée est réduite |
| 6 | Quel est l’impact de la météo (pluie, neige, brouillard) sur les accidents ? | atm, Num_Acc, grav | diagramme en barres | Mesurer l’influence des conditions atmosphériques | Beaucoup d'influence, augmentent le nombre d'accidents lorsque les conditions sont mauvaises. |
| 7 | Existe-t-il un seuil (âge, vitesse estimée, heure…) à partir duquel le risque explose ? | an_nais, hrmn, vma, grav | scatter plot + courbe de tendance | Détecter des effets de seuil sur la gravité | Avant 20 et après 70 ans, la nuit, après midi, limite de vitesse autorisée. |
| 8 | Les motos ont-elles un taux de gravité plus élevé ? | catv, grav | barres comparatives | Comparer la gravité selon le type de véhicule | Oui car peu de protections. |
| 9 | Les accidents sont-ils plus graves la nuit que le jour ? | lum, grav | barres empilées | Évaluer l’impact de la luminosité | Oui, fatigue visibilité. |
| 10 | Les accidents en agglomération sont-ils différents de ceux hors agglomération ? | agg, grav, Num_Acc | barres comparatives | Comparer les contextes urbain vs rural | Oui, plus grave. |
| 11 | Le type de route influence-t-il la gravité des accidents ? | catr, grav | diagramme en barres | Identifier les routes les plus dangereuses | Oui, National et départementale car route en mauvaise état et sérrées. |
| 12 | L’état de la chaussée influence-t-il les accidents ? | surf, grav, Num_Acc | barres empilées | Comprendre l’impact des conditions de route | Oui. |
| 13 | Le nombre de voies influence-t-il la fréquence ou la gravité des accidents ? | nbv, grav, Num_Acc | boxplot / barres | Étudier l’effet de l’infrastructure | On ne sait pas (avis divergents) |
| 14 | Les équipements de sécurité (ceinture, casque) réduisent-ils la gravité ? | secu1, secu2, secu3, grav | barres comparatives | Évaluer l’efficacité des dispositifs de sécurité | Oui, évidemment. |
| 15 | Certaines manœuvres ou collisions sont-elles plus dangereuses que d’autres ? | manv, col, grav | diagramme en barres | Identifier les situations les plus à risque | On ne sait pas. |

## Membres du groupe

- Paul-Louis LEDOUX
- Oleksandr VLASOV
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

