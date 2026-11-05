# Șterge toate răspunsurile din baza de date de TEST.
# Funcția refuză orice fișier care nu se termină în _TEST.sqlite, deci baza
# de date reală (data/raspunsuri.sqlite) nu poate fi ștearsă de acest script.
# În RStudio: source("scripts/reseteaza_date_test.R")
source("scripts/_incarca.R", encoding = "UTF-8")
cale <- cale_baza_date("test")
n <- sterge_date_test(cale)
message("Au fost șterse ", n, " răspunsuri din ", cale, ".")
