# Face o copie a bazelor de date în folderul copii_siguranta/, cu data și ora
# în nume. Copia se poate face și cât timp aplicația rulează.
# Dacă CHESTIONAR_DB_URL este setată (în .Renviron), se copiază tabelele din
# baza PostgreSQL într-un fișier SQLite; altfel, fișierele SQLite din data/.
# În RStudio: source("scripts/copie_de_siguranta.R")
source("scripts/_incarca.R", encoding = "UTF-8")
moment <- format(Sys.time(), "%Y%m%d_%H%M%S")
for (m in c("productie", "test")) {
  cale <- cale_baza_date(m)
  if (!exista_baza(cale)) next
  nume <- if (este_postgres(cale)) paste0(tabela_din(cale), ".sqlite") else basename(cale)
  dest <- file.path("copii_siguranta", sub("\\.sqlite$", paste0("_", moment, ".sqlite"), nume))
  copie_de_siguranta(cale, dest, schema_date(Q))
  message("Copie: ", dest, " (", numar_raspunsuri(dest), " răspunsuri)")
}
