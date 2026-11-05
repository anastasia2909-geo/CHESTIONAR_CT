# =============================================================================
# Chestionar: apă, canalizare și epurare în Constanța
# Aplicație R Shiny pentru lucrarea de licență.
#
# Pornire în RStudio: deschideți acest fișier și apăsați „Run App”.
# Zona de administrare: adăugați ?admin la adresa aplicației.
# Detalii: README.md
# =============================================================================

library(shiny)

# Încarcă, în ordine, fișierele din R/ (00_config.R, 01_intrebari.R, ...).
for (f in sort(list.files("R", pattern = "^[0-9].*\\.R$", full.names = TRUE))) {
  source(f, local = TRUE, encoding = "UTF-8")
}

pachete_necesare <- c("bslib", "DBI", "RSQLite", "DT", "writexl", "plotly", "ggplot2",
                      "jsonlite", "commonmark", "openssl")
if (nzchar(url_postgres())) pachete_necesare <- c(pachete_necesare, "RPostgres")
lipsa <- pachete_necesare[!vapply(pachete_necesare, requireNamespace, logical(1), quietly = TRUE)]
if (length(lipsa)) {
  stop("Lipsesc pachetele: ", paste(lipsa, collapse = ", "),
       ". Rulați în consolă: source(\"scripts/instaleaza_pachete.R\")", call. = FALSE)
}

MOD     <- mod_curent()
Q       <- construieste_intrebari()
SCHEMA  <- schema_date(Q)
CALE_DB <- cale_baza_date(MOD)
initializeaza_db(CALE_DB, SCHEMA)

message("Chestionar pornit în modul '", MOD, "'. Baza de date: ", descriere_stocare(CALE_DB),
        " (", numar_raspunsuri(CALE_DB), " răspunsuri).")
if (identical(MOD, "productie")) {
  if (zone_sunt_exemple(Q$q01$optiuni))
    warning("Lista de zone pentru Q1 conține încă exemple de înlocuit (config/zone_q1.csv).", call. = FALSE)
  if (length(campuri_de_completat(citeste_informare())))
    warning("Textul de informare are încă câmpuri [[de completat]] (config/informare_consimtamant.md).", call. = FALSE)
  if (!informare_are_pastrare())
    warning("Textul de informare nu are secțiunea „## Păstrarea datelor” (perioada de păstrare, accesul, temeiul). Vezi docs/DECIZII_DE_CONFIRMAT.md.", call. = FALSE)
  if (is.null(DURATA_ESTIMATA_MINUTE))
    warning("DURATA_ESTIMATA_MINUTE nu este setată: pagina de start nu afișează durata completării.", call. = FALSE)
  if (!nzchar(parola_admin()))
    warning("CHESTIONAR_ADMIN_PAROLA nu este setată: zona de administrare este dezactivată.", call. = FALSE)
}

este_admin <- function(query_string) "admin" %in% names(parseQueryString(query_string %||% ""))

ui <- function(request) {
  if (este_admin(request$QUERY_STRING)) ui_admin(MOD) else ui_public(Q, MOD)
}

server <- function(input, output, session) {
  if (este_admin(isolate(session$clientData$url_search))) {
    server_admin(input, output, session, Q, MOD)
  } else {
    server_public(input, output, session, Q, CALE_DB, MOD)
  }
}

shinyApp(ui, server)
