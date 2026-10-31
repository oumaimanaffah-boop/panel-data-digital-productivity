# Internet, haut débit et productivité du travail dans l'UE (2010–2023)

Analyse économétrique sur données de panel réalisée en R.

## Objectif
Mesurer l'effet d'Internet et du haut débit sur la productivité du travail (PIB par personne employée) dans 15 pays de l'Union européenne, de 2010 à 2023.

## Données
World Bank, World Development Indicators (WDI).

## Méthode
- Estimation et comparaison de trois modèles : MCO poolés, effets fixes, effets aléatoires
- Choix du modèle par les tests de Chow, Breusch-Pagan et Hausman (effets aléatoires retenus)
- Diagnostics : hétéroscédasticité, autocorrélation, multicolinéarité (VIF) et normalité des résidus (Shapiro-Wilk)
- Correction par des erreurs standards robustes HAC (Arellano)

## Résultat
L'effet d'Internet sur la productivité est positif et significatif à 5 % avant correction, mais il n'est plus significatif après la correction HAC.

## Contenu du dépôt
- `panel_econometrie.R` : script R de l'analyse (estimation, tests, diagnostics)
- `panel_digital_productivity.csv` : données du panel (source : World Bank WDI)
- Rapport complet de l'analyse, avec les résultats et leur interprétation

## Outils
R (plm, ggplot2)

## Auteure
Oumaima Naffah, Master Économie Appliquée et Data Science, FSJES Meknès (Université Moulay Ismail)
