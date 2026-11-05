# Exportă răspunsurile fără a porni aplicația (alternativă la zona admin).
# Fișierele apar în folderul export/.
# În RStudio: source("scripts/exporta_raspunsuri.R")
source("scripts/_incarca.R", encoding = "UTF-8")
mod <- "productie"   # schimbați în "test" pentru datele de test
cale <- cale_baza_date(mod)
df <- citeste_raspunsuri(cale, schema_date(Q))
dir.create("export", showWarnings = FALSE)
baza <- file.path("export", paste0("raspunsuri_", mod, "_", format(Sys.time(), "%Y%m%d_%H%M")))
scrie_xlsx(df, Q, paste0(baza, ".xlsx"), mod)
scrie_csv(df, paste0(baza, ".csv"))
scrie_xlsx_analiza(df, Q, paste0(baza, "_analiza.xlsx"), mod)
message(nrow(df), " răspunsuri exportate în ", baza, ".xlsx, .csv și _analiza.xlsx")
