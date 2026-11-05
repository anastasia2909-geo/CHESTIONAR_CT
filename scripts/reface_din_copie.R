# Readuce răspunsurile dintr-o copie de siguranță în baza de date curentă.
# Copia poate fi:
#   - un fișier .sqlite (butonul „Copie a bazei de date” din administrare sau
#     scripts/copie_de_siguranta.R);
#   - fișierul raspunsuri.csv din copia zilnică de pe GitHub (docs/GAZDUIRE.md).
# Baza de date curentă este cea din .Renviron: PostgreSQL dacă
# CHESTIONAR_DB_URL este setată, altfel fișierul SQLite din data/; modul
# (test sau productie) vine din CHESTIONAR_MOD.
#
# Scriptul NU șterge și NU modifică nimic: adaugă numai răspunsurile care lipsesc
# (după codul response_id). Un răspuns care există deja rămâne cum este.
#
# În RStudio:
#   copia <- "C:/Users/.../raspunsuri.csv"     # sau un fișier .sqlite
#   source("scripts/reface_din_copie.R")

source("scripts/_incarca.R", encoding = "UTF-8")
if (!exists("copia") || !file.exists(copia)) {
  stop("Setați întâi calea copiei, de exemplu: copia <- \"C:/Users/ana/Documents/raspunsuri.csv\"", call. = FALSE)
}

schema <- schema_date(Q)

citeste_copia <- function(f) {
  if (grepl("\\.sqlite$", f, ignore.case = TRUE)) return(citeste_raspunsuri(f, schema))
  df <- utils::read.csv(f, fileEncoding = "UTF-8-BOM", colClasses = "character",
                        na.strings = "", check.names = FALSE)
  for (i in seq_len(nrow(schema))) {
    v <- schema$variabila[i]
    if (!v %in% names(df)) next
    if (schema$tip_sqlite[i] == "INTEGER") df[[v]] <- as.integer(df[[v]])
    if (schema$tip_sqlite[i] == "REAL") df[[v]] <- as.numeric(df[[v]])
  }
  df
}

df <- citeste_copia(copia)
if (!nrow(df) || !"response_id" %in% names(df)) stop("Copia nu conține răspunsuri.", call. = FALSE)

mod <- mod_curent()
cale <- cale_baza_date(mod)
initializeaza_db(cale, schema)
con <- deschide_db(cale)
coloane <- DBI::dbListFields(con, tabela_din(cale))
DBI::dbDisconnect(con)
df <- df[, intersect(names(df), coloane), drop = FALSE]

inainte <- numar_raspunsuri(cale)
rez <- vapply(seq_len(nrow(df)), function(i) salveaza_raspuns(cale, df[i, , drop = FALSE]), character(1))
message("Copia are ", nrow(df), " răspunsuri. Adăugate: ", sum(rez == "ok"),
        "; existau deja: ", sum(rez == "duplicat"), ".")
message("Baza ", descriere_stocare(cale), ": ", inainte, " răspunsuri înainte, ",
        numar_raspunsuri(cale), " acum.")
