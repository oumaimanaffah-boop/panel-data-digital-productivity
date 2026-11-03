<div align="center">
  <img src="panel_data.png" alt="Infographie du projet de panel_digital_productivity — Oumaima Naffah" width="100%" />

# 🌐 Internet, haut débit & productivité du travail dans l'Union européenne

### Analyse économétrique sur données de panel · 2010--2023

**Projet de Master --- Économie appliquée & Data Science**

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![Économétrie](https://img.shields.io/badge/Économétrie-Données%20de%20panel-7A1F50?style=for-the-badge)
![Période](https://img.shields.io/badge/Période-2010--2023-E6A6B8?style=for-the-badge)
![Source](https://img.shields.io/badge/Données-World%20Bank-2E6D5A?style=for-the-badge)

*Dans quelle mesure le développement d'Internet et du haut débit
contribue-t-il à la productivité du travail dans les pays de l'Union
européenne ?*
:::

------------------------------------------------------------------------

## 📌 À propos du projet

Ce projet étudie la relation entre le développement des infrastructures
et des usages numériques et la **productivité du travail** dans **15
pays de l'Union européenne**, sur la période **2010--2023**.

L'objectif est d'évaluer économétriquement l'effet d'Internet et du haut
débit sur le **PIB par personne employée**, à partir de données de panel
issues des *World Development Indicators (WDI)* de la Banque mondiale.

L'analyse est réalisée avec **R** et compare plusieurs spécifications de
panel afin d'identifier le modèle le plus approprié, puis d'examiner la
robustesse des résultats.

## 🎯 Question de recherche

> Le développement d'Internet et du haut débit est-il associé à une
> amélioration significative de la productivité du travail dans les pays
> étudiés ?

### Objectifs spécifiques

-   Étudier le lien entre connectivité numérique et productivité du
    travail.
-   Comparer les modèles MCO poolés, à effets fixes et à effets
    aléatoires.
-   Sélectionner la spécification économétrique à l'aide de tests
    statistiques.
-   Vérifier les principaux problèmes affectant les estimations.
-   Évaluer la robustesse de l'inférence à l'aide d'erreurs standards
    robustes HAC (Arellano).

## 🗂️ Données et périmètre

  -----------------------------------------------------------------------
  Élément                             Description
  ----------------------------------- -----------------------------------
  Source                              World Bank --- World Development
                                      Indicators (WDI)

  Zone géographique                   15 pays de l'Union européenne

  Période                             2010--2023

  Nature des données                  Données de panel pays--année

  Variable expliquée                  Productivité du travail : PIB par
                                      personne employée

  Thématique                          Internet, haut débit et économie
                                      numérique
  -----------------------------------------------------------------------

Les indicateurs proviennent de la base WDI. Pour connaître les codes
exacts, les unités et les éventuelles transformations des variables, se
référer au fichier de données et au rapport d'analyse.

## 🧪 Démarche économétrique

L'analyse suit les étapes ci-dessous :

1.  **Préparation des données** --- importation, vérification et
    organisation du panel.
2.  **Estimation des modèles** --- MCO poolés (*Pooled OLS*), effets
    fixes (*Fixed Effects*) et effets aléatoires (*Random Effects*).
3.  **Sélection du modèle** --- tests de Chow, de Breusch--Pagan et de
    Hausman.
4.  **Diagnostics** --- examen de l'hétéroscédasticité, de
    l'autocorrélation, de la multicolinéarité (VIF) et de la normalité
    des résidus (Shapiro--Wilk).
5.  **Inférence robuste** --- correction des erreurs standards avec une
    covariance robuste de type Arellano/HAC.
6.  **Interprétation** --- comparaison des résultats avant et après
    correction robuste.

### Modèle retenu

Les tests de spécification conduisent à retenir le **modèle à effets
aléatoires**.

## 📊 Résultat principal

L'estimation initiale met en évidence un **effet positif et
statistiquement significatif à 5 %** d'Internet sur la productivité du
travail.

Cependant, après l'application de la correction des erreurs standards
robustes HAC (Arellano), cet effet **n'est plus statistiquement
significatif**.

### Comment interpréter ce résultat ?

Le signe positif de l'estimation initiale suggère une association
favorable entre Internet et la productivité. Toutefois, la perte de
significativité après correction robuste invite à interpréter ce
résultat avec prudence : **les données analysées ne permettent pas de
confirmer un effet statistiquement robuste au seuil de 5 %**.

Cette distinction entre significativité initiale et robustesse
statistique constitue un résultat important du projet. Elle évite de
conclure trop rapidement à un effet établi.

## 🛠️ Technologies et outils

-   **R** --- traitement des données et estimation économétrique.
-   **`plm`** --- modèles de données de panel.
-   **`ggplot2`** --- visualisation des données et des résultats.
-   **World Development Indicators** --- source des données.

## 📁 Structure du dépôt

``` text
.
├── panel_econometrie.R
│   └── Script R : préparation, estimations, tests et diagnostics
│
├── panel_digital_productivity.csv
│   └── Données de panel issues des World Development Indicators
│
├── README.md
│   └── Présentation du projet et guide de reproduction
│
└── Rapport/
    └── Rapport complet : résultats, tableaux et interprétations
```

*Adapter le nom ou l'emplacement du dossier `Rapport/` à la structure
réelle du dépôt si nécessaire.*

## 🚀 Installation et exécution

### 1. Prérequis

Installer R depuis [r-project.org](https://www.r-project.org/). Les
packages utilisés dans le projet peuvent être installés avec :

``` r
install.packages(c("plm", "ggplot2"))
```

Si le script mobilise d'autres packages, les installer également avant
l'exécution.

### 2. Récupérer le projet

``` bash
git clone <URL_DU_DEPOT>
cd <NOM_DU_DEPOT>
```

### 3. Lancer l'analyse

Ouvrir `panel_econometrie.R` dans RStudio, vérifier que le fichier CSV
est placé au chemin attendu par le script, puis exécuter le script.

``` r
source("panel_econometrie.R")
```

> **Reproductibilité :** les chemins d'accès aux fichiers doivent
> correspondre à l'organisation locale du projet. Les résultats
> dépendent également de la version des données et des packages
> utilisés.

## 🔎 Points d'attention

-   Une association statistique ne suffit pas, à elle seule, à établir
    une relation de causalité.
-   La non-significativité après correction HAC signifie que l'effet
    n'est pas confirmé statistiquement par cette spécification robuste ;
    elle ne prouve pas que l'effet réel est nul.
-   Les conclusions doivent être interprétées dans le périmètre des 15
    pays et de la période 2010--2023.
-   Les choix de variables, leurs définitions, les transformations et
    les spécifications détaillées sont à consulter dans le script et le
    rapport complet.

## 👩‍💻 Auteure

**Oumaima Naffah**\
Master Économie Appliquée et Data Science\
FSJES Meknès --- Université Moulay Ismail

------------------------------------------------------------------------


**Merci pour votre intérêt !** 💗

*Économie numérique · Économétrie des données de panel · Data Science*

