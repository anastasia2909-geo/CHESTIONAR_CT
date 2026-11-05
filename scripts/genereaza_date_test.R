# Adaugă răspunsuri sintetice în baza de date de TEST (data/raspunsuri_TEST.sqlite).
# Baza de date reală nu este atinsă.
# În RStudio: source("scripts/genereaza_date_test.R")
source("scripts/_incarca.R", encoding = "UTF-8")
cale <- cale_baza_date("test")
n <- 30
insereaza_date_test(Q, cale, n)
message("Au fost adăugate ", n, " răspunsuri sintetice în ", cale,
        ". Total în baza de test: ", numar_raspunsuri(cale), ".")
