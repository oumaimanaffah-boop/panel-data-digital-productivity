# =============================================================================
#  PROJET ÉCONOMÉTRIE APPLIQUÉE — PANEL DATA
#  Thème : Impact de la digitalisation sur la productivité en Europe
#  Données : World Development Indicators (2010–2023), 15 pays de l'UE
# =============================================================================


# =============================================================================
# ÉTAPE 1 : INSTALLATION ET CHARGEMENT DES PACKAGES
# =============================================================================

# Installer les packages si nécessaire (décommenter la première fois)
# install.packages(c("plm", "lmtest", "car", "ggplot2", "dplyr",
# =============================================================================
#  PROJET ÉCONOMÉTRIE APPLIQUÉE — PANEL DATA
#  Thème : Impact de la digitalisation sur la productivité en Europe
#  Données : World Development Indicators (2010–2023), 15 pays de l'UE
# =============================================================================


# =============================================================================
# ÉTAPE 1 : INSTALLATION ET CHARGEMENT DES PACKAGES
# =============================================================================

# Installer les packages si nécessaire (décommenter la première fois)
install.packages(c("plm", "lmtest", "car", "ggplot2", "dplyr","tidyr", "stargazer", "sandwich", "tseries","readr", "corrplot", "gridExtra"))

library(plm)        # Modèles de panel (OLS, FE, RE)
library(lmtest)     # Tests économétriques (Breusch-Pagan, etc.)
library(car)        # Test de variance (Variance Inflation Factor)
library(ggplot2)    # Graphiques
library(dplyr)      # Manipulation des données
library(tidyr)      # Transformation wide → long
library(stargazer)  # Tableaux de résultats comparatifs
library(sandwich)   # Erreurs standards robustes
library(tseries)    # Tests de stationnarité
library(readr)      # Lecture CSV
library(corrplot)   # Matrice de corrélation visuelle
library(gridExtra)  # Mise en page de plusieurs graphiques


# =============================================================================
# ÉTAPE 2 : LECTURE ET PREMIER APERÇU DES DONNÉES
# =============================================================================

raw_data <- read_csv("C:/Users/oumai/Documents/panel_digital_productivity.csv")

# Premier aperçu
cat("=== APERÇU GÉNÉRAL ===\n")
glimpse(raw_data)

cat("\n=== PREMIÈRES LIGNES ===\n")
print(head(raw_data, 10))

cat("\n=== DIMENSIONS ===\n")
cat("Lignes :", nrow(raw_data), "| Colonnes :", ncol(raw_data), "\n")

cat("\n=== VARIABLES (Series) DISPONIBLES ===\n")
print(unique(raw_data$`Series Name`))

cat("\n=== PAYS DISPONIBLES ===\n")
print(unique(raw_data$`Country Name`))


# =============================================================================
# ÉTAPE 3 : NETTOYAGE DES DONNÉES
# =============================================================================

# Supprimer les lignes parasites (métadonnées en bas du CSV World Bank)
df_clean <- raw_data %>%
  filter(
    !is.na(`Country Name`),
    !is.na(`Series Name`),
    !(`Country Name` %in% c(
      "Data from database: World Development Indicators",
      "Last Updated: 04/08/2026"
    ))
  )

# Vérifier les pays valides
cat("\n=== PAYS APRÈS NETTOYAGE ===\n")
print(unique(df_clean$`Country Name`))
cat("Nombre de séries :", nrow(df_clean), "\n")


# =============================================================================
# ÉTAPE 4 : TRANSFORMATION EN FORMAT LONG PUIS PANEL
# =============================================================================

# Colonnes des années (format "YYYY [YRYYYY]")
year_cols <- names(df_clean)[grepl("\\[YR", names(df_clean))]

# Passage au format long : une ligne par (pays × série × année)
df_long <- df_clean %>%
  select(`Country Name`, `Country Code`, `Series Name`, all_of(year_cols)) %>%
  pivot_longer(
    cols      = all_of(year_cols),
    names_to  = "year_raw",
    values_to = "value"
  ) %>%
  # Extraire l'année (4 premiers chiffres)
  mutate(year = as.integer(substr(year_raw, 1, 4))) %>%
  select(-year_raw)

# Passage au format large : une colonne par variable
df_wide <- df_long %>%
  pivot_wider(
    id_cols    = c(`Country Name`, `Country Code`, year),
    names_from = `Series Name`,
    values_from = value
  )

# Renommer les colonnes pour faciliter la manipulation
df_panel <- df_wide %>%
  rename(
    country    = `Country Name`,
    code       = `Country Code`,
    gdp_prod   = `GDP per person employed (constant 2021 PPP $)`,
    internet   = `Individuals using the Internet (% of population)`,
    mobile     = `Mobile cellular subscriptions (per 100 people)`,
    broadband  = `Fixed broadband subscriptions (per 100 people)`,
    capital    = `Gross fixed capital formation (annual % growth)`,
    edu        = `Pupil-teacher ratio, secondary`
  )

cat("\n=== STRUCTURE DU PANEL ===\n")
glimpse(df_panel)
cat("\nPériode :", min(df_panel$year), "à", max(df_panel$year), "\n")
cat("Pays    :", length(unique(df_panel$country)), "\n")
cat("Années  :", length(unique(df_panel$year)), "\n")


# =============================================================================
# ÉTAPE 5 : VALEURS MANQUANTES ET STATISTIQUES DESCRIPTIVES
# =============================================================================

cat("\n=== VALEURS MANQUANTES PAR VARIABLE ===\n")
print(colSums(is.na(df_panel)))

cat("\n=== STATISTIQUES DESCRIPTIVES ===\n")
summary(df_panel[, c("gdp_prod", "internet", "mobile",
                     "broadband", "capital", "edu")])

# Visualiser les valeurs manquantes
missing_pct <- df_panel %>%
  summarise(across(where(is.numeric), ~mean(is.na(.)) * 100)) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Pct_Missing")

ggplot(missing_pct, aes(x = reorder(Variable, Pct_Missing), y = Pct_Missing)) +
  geom_bar(stat = "identity", fill = "#2196F3") +
  coord_flip() +
  labs(title = "Pourcentage de valeurs manquantes par variable",
       x = NULL, y = "% manquant") +
  theme_minimal()

# Interpolation linéaire par pays pour les valeurs manquantes
df_panel <- df_panel %>%
  arrange(country, year) %>%
  group_by(country) %>%
  mutate(across(where(is.numeric),
                ~zoo::na.approx(., na.rm = FALSE))) %>%
  ungroup()

# Supprimer les lignes encore incomplètes après interpolation
df_panel <- df_panel %>% drop_na()

cat("\nObservations finales après nettoyage :", nrow(df_panel), "\n")


# =============================================================================
# ÉTAPE 6 : EXPLORATION VISUELLE
# =============================================================================

# Évolution de la productivité par pays
ggplot(df_panel, aes(x = year, y = gdp_prod, color = country)) +
  geom_line(size = 0.8) +
  labs(title = "Évolution de la productivité (PIB par emploi)",
       x = "Année", y = "PIB par personne employée (PPP $)",
       color = "Pays") +
  theme_minimal()

# Évolution de l'usage Internet
ggplot(df_panel, aes(x = year, y = internet, color = country)) +
  geom_line(size = 0.8) +
  labs(title = "Utilisation d'Internet (% de la population)",
       x = "Année", y = "%", color = "Pays") +
  theme_minimal()

# Relation productivité ~ Internet (nuage de points)
ggplot(df_panel, aes(x = internet, y = gdp_prod, color = country)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dashed") +
  labs(title = "Productivité vs Internet",
       x = "Utilisateurs Internet (%)", y = "PIB par emploi") +
  theme_minimal()

# Matrice de corrélation
df_panel[, c("gdp_prod", "internet", "mobile", "broadband", "capital", "edu")] <- 
  lapply(df_panel[, c("gdp_prod", "internet", "mobile", "broadband", "capital", "edu")], 
         as.numeric)

cor_matrix <- cor(df_panel[, c("gdp_prod", "internet", "mobile", 
                               "broadband", "capital", "edu")], 
                  use = "complete.obs")

print(cor_matrix)  # must show a matrix, not an error
corrplot(cor_matrix,
         method      = "color",
         type        = "upper",
         addCoef.col = "black",
         tl.col      = "black",
         title       = "Matrice de corrélation",
         mar         = c(0, 0, 1, 0))

# =============================================================================
# ÉTAPE 7 : DÉFINITION DES VARIABLES ET FORMULE DU MODÈLE
# =============================================================================

# Variable dépendante (Y) :
#   gdp_prod → Productivité du travail (PIB par personne employée, en PPP $)
#
# Variables explicatives (X) :
#   internet   → Pénétration d'Internet (proxy de digitalisation)
#   broadband  → Abonnements haut débit fixe (infrastructure numérique)
#   capital    → Formation brute de capital fixe (investissement)
#   edu        → Ratio élèves/enseignant dans le secondaire (capital humain)
#
# Variable exclue :
#   mobile → fortement corrélé avec internet (risque de multicolinéarité)
#
# Formule économétrique :
#   gdp_prod(it) = α + β1·internet(it) + β2·broadband(it) +
#                      β3·capital(it) + β4·edu(it) + μ(i) + ε(it)
#
#   i = pays, t = année
#   μ(i) = effet individuel (fixe ou aléatoire selon le test de Hausman)

formule <- gdp_prod ~ internet + broadband + capital + edu

cat("\n=== FORMULE DU MODÈLE ===\n")
print(formule)


# =============================================================================
# ÉTAPE 8 : CONVERSION EN OBJET PANEL (pdata.frame)
# =============================================================================

pdata <- pdata.frame(df_panel, index = c("country", "year"))

cat("\n=== VÉRIFICATION DU PANEL ===\n")
print(pdim(pdata))        # Dimensions (N individus × T périodes)
print(is.pbalanced(pdata))  # Vérifie si le panel est cylindré (balanced)


# =============================================================================
# ÉTAPE 9 : ESTIMATION DES MODÈLES
# =============================================================================

# --- Modèle 1 : MCO poolés (Pooled OLS) ---
# Hypothèse : pas d'effet individuel (α identique pour tous les pays)
model_ols <- plm(formule,
                 data   = pdata,
                 model  = "pooling")

cat("\n=== RÉSULTATS MCO POOLÉS ===\n")
summary(model_ols)


# --- Modèle 2 : Effets Fixes (Within / FE) ---
# Hypothèse : chaque pays a un effet fixe constant dans le temps
# Élimine l'hétérogénéité individuelle non observée
model_fe <- plm(formule,
                data   = pdata,
                model  = "within",
                effect = "individual")

cat("\n=== RÉSULTATS EFFETS FIXES ===\n")
summary(model_fe)

# Afficher les effets fixes par pays
cat("\n=== EFFETS FIXES PAR PAYS ===\n")
print(fixef(model_fe))


# --- Modèle 3 : Effets Aléatoires (RE) ---
# Hypothèse : l'effet individuel est aléatoire et non corrélé avec X
model_re <- plm(formule,
                data   = pdata,
                model  = "random",
                random.method = "swar")   # Méthode de Swamy-Arora

cat("\n=== RÉSULTATS EFFETS ALÉATOIRES ===\n")
summary(model_re)


# =============================================================================
# ÉTAPE 10 : TABLEAU COMPARATIF DES TROIS MODÈLES
# =============================================================================

stargazer(model_ols, model_fe, model_re,
          type          = "text",
          title         = "Comparaison des modèles de panel",
          column.labels = c("MCO Poolés", "Effets Fixes", "Effets Aléatoires"),
          dep.var.labels = "Productivité (PIB/emploi)",
          covariate.labels = c("Internet (%)", "Haut débit",
                               "Formation capital", "Ratio élèves/prof"),
          digits        = 3,
          omit.stat     = c("f", "ser"))


# =============================================================================
# ÉTAPE 11 : TESTS DE SPÉCIFICATION — CHOIX DU MODÈLE
# =============================================================================

cat("\n", paste(rep("=", 60), collapse=""), "\n")
cat("          TESTS POUR CHOISIR LE BON MODÈLE\n")
cat(paste(rep("=", 60), collapse=""), "\n")

# ---- Test F de Chow : OLS poolé vs Effets Fixes ----
# H0 : pas d'effet fixe → OLS poolé suffisant
# H1 : présence d'effets fixes → FE préféré
test_chow <- pFtest(model_fe, model_ols)
cat("\n--- Test de Chow (OLS vs Effets Fixes) ---\n")
print(test_chow)
cat("Interprétation : p-value <0.05 → rejeter H0 → Effets Fixes préférés\n")


# ---- Test de Breusch-Pagan (LM) : OLS poolé vs Effets Aléatoires ----
# H0 : variance des effets aléatoires = 0 → OLS poolé suffisant
# H1 : effets aléatoires significatifs → RE préféré
test_bp_re <- plmtest(model_ols, type = "bp")
cat("\n--- Test de Breusch-Pagan (OLS vs Effets Aléatoires) ---\n")
print(test_bp_re)
cat("Interprétation : p-value <0.05 → rejeter H0 → Effets Aléatoires préférés\n")


# ---- Test de Hausman : Effets Fixes vs Effets Aléatoires ----
# H0 : effets individuels non corrélés avec X → Effets Aléatoires (RE) cohérents
# H1 : corrélation → Effets Aléatoires biaisés → Effets Fixes (FE) préférés
test_hausman <- phtest(model_fe, model_re)
cat("\n--- Test de Hausman (Effets Fixes vs Effets Aléatoires) ---\n")
print(test_hausman)
cat("Interprétation : p-value <0.05 → rejeter H0 → Effets Fixes préférés\n")
cat("                p-value >0.05 → ne pas rejeter H0 → Effets Aléatoires préférés\n")


# ---- Résumé de la décision ----
cat("\n=== DÉCISION FINALE ===\n")
p_chow    <- test_chow$p.value
p_bp      <- test_bp_re$p.value
p_hausman <- test_hausman$p.value

if (p_chow < 0.05 & p_hausman < 0.05) {
  cat("→ MODÈLE RETENU : Effets Fixes (FE)\n")
  model_final <- model_fe
} else if (p_chow < 0.05 & p_hausman >= 0.05) {
  cat("→ MODÈLE RETENU : Effets Aléatoires (RE)\n")
  model_final <- model_re
} else {
  cat("→ MODÈLE RETENU : MCO Poolés\n")
  model_final <- model_ols
}


# =============================================================================
# ÉTAPE 12 : TESTS DE ROBUSTESSE DU MODÈLE FINAL
# =============================================================================

cat("\n", paste(rep("=", 60), collapse=""), "\n")
cat("          TESTS DE ROBUSTESSE\n")
cat(paste(rep("=", 60), collapse=""), "\n")

# ---- Test d'hétéroscédasticité ----
# Breusch-Pagan sur les résidus du modèle final
test_hetero <- bptest(model_final)
cat("\n--- Test d'hétéroscédasticité (Breusch-Pagan) ---\n")
print(test_hetero)
cat("H0 : homoscédasticité | H1 : hétéroscédasticité\n")
cat("p-value <0.05 → hétéroscédasticité détectée → utiliser erreurs robustes\n")


# ---- Test d'autocorrélation sérielle ----
# Wooldridge (2002) : test le plus adapté aux panels
test_serial <- pbgtest(model_final)
cat("\n--- Test d'autocorrélation (Breusch-Godfrey pour panel) ---\n")
print(test_serial)
cat("H0 : pas d'autocorrélation | H1 : autocorrélation sérielle\n")
cat("p-value <0.05 → autocorrélation présente → corriger les erreurs standards\n")


# ---- Test de multicolinéarité (VIF) via modèle OLS auxiliaire ----
cat("\n--- Test de multicolinéarité (VIF) ---\n")
model_vif <- lm(gdp_prod ~ internet + broadband + capital + edu,
                data = df_panel)
vif_values <- vif(model_vif)
print(vif_values)
cat("Règle : VIF > 10 → multicolinéarité sévère\n")
cat("        VIF > 5  → multicolinéarité modérée (à surveiller)\n")


# ---- Estimation avec erreurs standards robustes ----
# Corrige simultanément hétéroscédasticité ET autocorrélation (erreurs HAC)
cat("\n--- Modèle final avec erreurs standards robustes (HAC) ---\n")
coeftest(model_final, vcov = vcovHC(model_final, method = "arellano"))


# =============================================================================
# ÉTAPE 13 : DIAGNOSTIC VISUEL DES RÉSIDUS
# =============================================================================

residus <- residuals(model_final)

# Graphique 1 : Résidus vs valeurs ajustées
df_resid <- data.frame(
  fitted  = as.numeric(fitted(model_final)),
  residus = as.numeric(residus)
)

p1 <- ggplot(df_resid, aes(x = fitted, y = residus)) +
  geom_point(alpha = 0.5, color = "#1565C0") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  geom_smooth(se = FALSE, color = "orange", size = 0.8) +
  labs(title = "Résidus vs valeurs ajustées",
       x = "Valeurs ajustées", y = "Résidus") +
  theme_minimal()

# Graphique 2 : Distribution des résidus (normalité)
p2 <- ggplot(df_resid, aes(x = residus)) +
  geom_histogram(aes(y = after_stat(density)),
                 bins = 20, fill = "#42A5F5", color = "white") +
  geom_density(color = "red", size = 1) +
  labs(title = "Distribution des résidus",
       x = "Résidus", y = "Densité") +
  theme_minimal()

grid.arrange(p1, p2, ncol = 2)


# ---- Test de normalité des résidus ----
test_normal <- shapiro.test(residus[1:5000])  # Shapiro-Wilk limité à 5000 obs
cat("\n--- Test de normalité des résidus (Shapiro-Wilk) ---\n")
print(test_normal)
cat("H0 : résidus normalement distribués\n")
cat("p-value >0.05 → normalité acceptée\n")


# =============================================================================
# ÉTAPE 14 : SYNTHÈSE FINALE
# =============================================================================

cat("\n", paste(rep("=", 60), collapse=""), "\n")
cat("                  SYNTHÈSE FINALE\n")
cat(paste(rep("=", 60), collapse=""), "\n")

cat("\nModèle retenu :", deparse(formule))
cat("\n\nRésultats avec erreurs standards robustes (HAC) :\n")
print(coeftest(model_final, vcov = vcovHC(model_final, method = "arellano")))

cat("\n=== FIN DE L'ANALYSE ===\n")