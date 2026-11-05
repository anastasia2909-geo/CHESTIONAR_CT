# Pregătește fișierul manifest.json, cerut de Posit Connect Cloud pentru
# aplicațiile R. Manifestul spune serverului ce versiune de R și ce pachete să
# instaleze. Rulați scriptul din nou după ce instalați sau actualizați pachete,
# apoi trimiteți manifest.json pe GitHub împreună cu restul modificărilor.
# În RStudio: source("scripts/pregateste_publicarea.R")
# Pașii compleți: docs/GAZDUIRE.md.

if (!file.exists("app.R") || !dir.exists("R")) {
  stop("Rulați scriptul din folderul proiectului (deschideți chestionar_constanta.Rproj).", call. = FALSE)
}

necesare <- c("shiny", "bslib", "DBI", "RSQLite", "RPostgres", "DT", "writexl", "plotly",
              "ggplot2", "jsonlite", "commonmark", "openssl", "rsconnect")
lipsa <- necesare[!vapply(necesare, requireNamespace, logical(1), quietly = TRUE)]
if (length(lipsa)) {
  stop("Lipsesc pachetele: ", paste(lipsa, collapse = ", "),
       ". Rulați întâi: source(\"scripts/instaleaza_pachete.R\")", call. = FALSE)
}

# Pe server ajung numai fișierele de care aplicația are nevoie: app.R, R/,
# config/, www/. Nu ajung: bazele de date, copiile, exporturile, .Renviron,
# testele, scripturile și documentația.
fisiere <- c("app.R",
             list.files("R", recursive = TRUE, full.names = TRUE),
             list.files("config", recursive = TRUE, full.names = TRUE),
             list.files("www", recursive = TRUE, full.names = TRUE))
fisiere <- fisiere[!grepl("\\.sqlite|\\.Renviron", fisiere)]

rsconnect::writeManifest(appDir = ".", appFiles = fisiere, quiet = TRUE)

m <- jsonlite::read_json("manifest.json")
pachete <- names(m$packages)
listate <- names(m$files)
probleme <- c(
  if (!"RPostgres" %in% pachete) "pachetul RPostgres nu apare în manifest",
  if (!"shiny" %in% pachete) "pachetul shiny nu apare în manifest",
  if (any(grepl("\\.sqlite|\\.Renviron|^data/", listate))) "manifestul conține fișiere cu date sau parole"
)
if (length(probleme)) stop("manifest.json nu este corect: ", paste(probleme, collapse = "; "), call. = FALSE)
message("manifest.json este gata: R ", m$platform, ", ", length(pachete), " pachete, ",
        length(listate), " fișiere. Trimiteți-l pe GitHub (Commit și Push).")
