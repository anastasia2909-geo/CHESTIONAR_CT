# Instalează pachetele necesare aplicației (o singură dată).
# În RStudio: source("scripts/instaleaza_pachete.R")
pachete <- c("shiny", "bslib", "DBI", "RSQLite", "DT", "writexl", "openxlsx", "plotly",
             "ggplot2", "jsonlite", "commonmark", "openssl", "testthat",
             "RPostgres",   # baza PostgreSQL, pentru găzduire (docs/GAZDUIRE.md)
             "rsconnect")   # fișierul manifest.json, pentru publicare
lipsa <- pachete[!vapply(pachete, requireNamespace, logical(1), quietly = TRUE)]
if (length(lipsa)) {
  message("Se instalează: ", paste(lipsa, collapse = ", "))
  install.packages(lipsa)
} else {
  message("Toate pachetele sunt deja instalate.")
}
