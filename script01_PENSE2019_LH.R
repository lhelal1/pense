# ==============================================================================
# Title: Importacao Microdados PENSE2019-IBGE
# Author: Lucas Helal
# Date: 14MAR2024
# Version: V0 para Danico.
# ==============================================================================

# Description
# ------------------------------------------------------------------------------
# Importacao de microdados pelo site do IBGE com posteriorß
# aplicacao de fatores de correacao para efeito do desenho amostral
# como indicado pela instituicao (parametros). É importado um banco em .csv
# nao corrigido, mas passivel de uso para análise, e é gerado um banco corrigido.
# ------------------------------------------------------------------------------

# Dependencies
# ------------------------------------------------------------------------------
# library(tidyverse)
# library(lubridate)
# library(survey)
# library(readr)
# library(haven) OU
#
# caso nao tenha nada instalado, o pacote pacman instala e carrega as dependencias
# num só comando:
#
# pacman::p_load(
#    tidyverse,
#    lubridate,
#    survey,
#    readr,
#    haven)
# ------------------------------------------------------------------------------
# ==============================================================================
# INIT
# ==============================================================================

# Seu código começa aqui

pacman::p_load(
    tidyverse,
    lubridate,
    survey,
    readr,
    haven)


# primary survey unit error adjustment
options(survey.lonely.psu = "adjust")

# import dataset
pense <- read_csv("~/Downloads/firefox/Dados/CSV/PENSE2019_MICRODADOS.txt")

# applying survey design effect as IBGE instructs
pense_plano_amostral <- svydesign(
    ids = ~ESCOLA,
    strata = ~ESTRATO,
    weights = ~PESO_INICIAL,
    nest = TRUE,
    data = pense)

# applying post-stratification as IBGE instructs
pense_pos_estratificacao <- postStratify(pense_plano_amostral, strata = ~POSEST, population = pense[,c("POSEST","TOTAIS_POSEST")])

# applying domain as IBGE instructs (IND_EXPANSAO == 1)
pense_valida <- subset(pense_pos_estratificacao, IND_EXPANSAO == 1)


# ==============================================================================

# return to csv after processing

# data extraction of svydesign object pense_valida
dados_pense_valida <- model.frame(pense_valida)
# weights adjustment
pesos_pense_valida <- weights(pense_valida)
# adding weights to dataframe
dados_pense_valida$pesos_ajustados <- pesos_pense_valida

# renaming dataframe
pense_final <- dados_pense_valida

# print dataframe
# write.csv(pense_final, "~/Desktop/teu_caminho/arquivo.csv", row.names = FALSE) ou o equivalente pra Windows
