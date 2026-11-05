# Încarcă codul aplicației pentru teste. testthat rulează din tests/testthat.

# Testele nu ating niciodată baza PostgreSQL reală: dacă .Renviron are
# CHESTIONAR_DB_URL, variabila este scoasă pe durata testelor. Testele pentru
# PostgreSQL (test-postgres.R) folosesc doar CHESTIONAR_TEST_PG_URL, într-o
# schemă temporară.
Sys.unsetenv("CHESTIONAR_DB_URL")
suppressPackageStartupMessages(library(shiny))   # ca în app.R: tags, div, p etc.
RADACINA <- normalizePath(file.path(getwd(), "..", ".."), winslash = "/")
local({
  vechi <- setwd(RADACINA)
  on.exit(setwd(vechi))
  for (f in sort(list.files("R", pattern = "^[0-9].*\\.R$", full.names = TRUE))) {
    sys.source(f, envir = globalenv(), keep.source = FALSE, toplevel.env = globalenv())
  }
  assign("Q", construieste_intrebari(), envir = globalenv())
})

# Răspuns complet și valid, folosit ca punct de plecare în teste.
raspuns_valid <- function() {
  v <- list(
    q01 = names(Q$q01$optiuni)[1], q02 = "25_34", q03 = "liceal", q04 = "casa",
    q05 = 3, q06_sub_18 = 1, q06_18_24 = 0, q06_25_34 = 2, q06_35_44 = 0,
    q06_45_54 = 0, q06_55_64 = 0, q06_65_plus = 0, q07 = "da",
    q08_rece = 10.5, q08_calda = NA, q08_nu_stiu = FALSE,
    q09_igiena = 40, q09_rufe = 15, q09_vase = 10, q09_alimente = 5,
    q09_curatenie = 5, q09_toaleta = 20, q09_plante_altele = 5,
    q10 = c("dusuri_scurte", "masina_plina"), q11 = "debit_redus",
    q13 = "punct_colectare", q14 = "statie_epurare", q15 = "reducere_poluanti",
    q16 = c("uleiuri_grasimi", "detergenti"), q17 = "greu", q18 = "moderat",
    q19 = "da", q20 = c("mirosuri"), q21_cetateni = "5", q21_operator = "4",
    q21_autoritati = "4", q21_producatori = "3", q21_control = "3",
    q22 = "informare", q23 = "putin", q24 = "idee_generala", q25 = "")
  for (k in names(Q$q12$randuri)) v[[paste0("q12_", k)]] <- "nu_am_aruncat"
  v
}

# Pornește aplicația pe o bază de date temporară, în modul test.
cu_aplicatie <- function(cod, env = parent.frame()) {
  dir <- tempfile("date_"); dir.create(dir)
  vechi <- Sys.getenv(c("CHESTIONAR_DATA_DIR", "CHESTIONAR_MOD"), unset = NA)
  Sys.setenv(CHESTIONAR_DATA_DIR = dir, CHESTIONAR_MOD = "test")
  on.exit({
    for (n in names(vechi)) if (is.na(vechi[[n]])) Sys.unsetenv(n) else do.call(Sys.setenv, as.list(vechi[n]))
    unlink(dir, recursive = TRUE)
  })
  # shinyAppDir() păstrează în cache aplicația deja încărcată (cu baza de date
  # din testul anterior); de aceea app.R este rulat din nou pentru fiecare test.
  vechi_wd <- setwd(RADACINA); on.exit(setwd(vechi_wd), add = TRUE)
  app <- source("app.R", local = new.env(parent = globalenv()), encoding = "UTF-8")$value
  cale <- file.path(normalizePath(dir, winslash = "/"), "raspunsuri_TEST.sqlite")
  cod(app, cale)
}
