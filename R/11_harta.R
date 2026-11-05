# =============================================================================
# 11_harta.R — datele pentru harta și pentru fișa cartierului
# -----------------------------------------------------------------------------
# Harta este desenată în browser cu Leaflet (www/lib/leaflet, inclus local) de
# codul din www/harta.js. Aici se pregătesc datele trimise browserului:
#  - limitele UAT (www/harta/uat.geojson, sursă ANCPI prin geoBoundaries);
#  - delimitarea textuală și planul scanat ale cartierului ales, din anexele
#    HCL nr. 79/28.02.2023 (config/cartiere_hcl79_2023.csv);
#  - opțional, limitele vectoriale ale cartierelor (www/harta/cartiere.geojson),
#    numai dacă fișierul există. Aplicația nu desenează limite inventate.
# =============================================================================

SURSA_UAT <- list(
  text = "Limite UAT: ANCPI (data.gov.ro), prin geoBoundaries, CC BY 4.0",
  url = "https://www.geoboundaries.org")

SURSA_HCL <- "HCL nr. 79/28.02.2023 a Consiliului Local al municipiului Constanța"

citeste_cartiere <- function(fisier = FISIER_CARTIERE) {
  if (!file.exists(fisier)) return(NULL)
  d <- utils::read.csv(fisier, stringsAsFactors = FALSE, encoding = "UTF-8",
                       fileEncoding = "UTF-8", colClasses = "character")
  necesare <- c("cod", "nr_hcl", "denumire", "delimitare", "anexa_plan", "fisier_plan")
  lipsa <- setdiff(necesare, names(d))
  if (length(lipsa)) stop("Lipsesc coloanele ", paste(lipsa, collapse = ", "), " din ", fisier)
  d
}

# Verifică dacă există un fișier vectorial valid cu limitele cartierelor și
# întoarce codurile disponibile în el (sau character(0)).
coduri_cartiere_vectoriale <- function(fisier = FISIER_CARTIERE_GEOJSON) {
  if (!file.exists(fisier)) return(character(0))
  g <- tryCatch(jsonlite::fromJSON(fisier, simplifyVector = FALSE), error = function(e) NULL)
  if (is.null(g) || !identical(g$type, "FeatureCollection")) {
    warning("www/harta/cartiere.geojson nu este un FeatureCollection GeoJSON valid; harta îl ignoră.", call. = FALSE)
    return(character(0))
  }
  coduri <- vapply(g$features, function(f) as.character(f$properties$cod %||% NA), "")
  coduri[!is.na(coduri) & nzchar(coduri)]
}

# Ce fel de limite conține fișierul vectorial. Câmpuri la nivelul colecției:
#   "tip_limite": "oficiale" (numai pentru date primite de la o autoritate)
#                 sau "orientative" (implicit, dacă lipsește);
#   "sursa" sau "descriere": de unde provin limitele / cum au fost desenate.
# Orice fișier fără "tip_limite": "oficiale" este prezentat ca orientativ.
info_cartiere_vectoriale <- function(fisier = FISIER_CARTIERE_GEOJSON) {
  if (!file.exists(fisier)) return(NULL)
  g <- tryCatch(jsonlite::fromJSON(fisier, simplifyVector = FALSE), error = function(e) NULL)
  if (is.null(g)) return(NULL)
  verif <- list()
  for (f in g$features) if (!is.null(f$properties$cod) && !is.null(f$properties$verificare_plan))
    verif[[f$properties$cod]] <- as.character(f$properties$verificare_plan)
  list(oficiale = identical(g$tip_limite, "oficiale"),
       sursa = as.character(g$sursa %||% g$descriere %||% ""),
       verificare = verif)
}

# Datele pentru fișa cartierului ales la Q1 (sau NULL dacă nu există).
date_cartier <- function(cod, cartiere = citeste_cartiere()) {
  if (is.null(cartiere) || is.na(cod) || !nzchar(cod)) return(NULL)
  r <- cartiere[cartiere$cod == cod, , drop = FALSE]
  if (!nrow(r)) return(NULL)
  r <- as.list(r[1, ])
  r$plan_exista <- file.exists(file.path("www", r$fisier_plan))
  r
}

# Mesajul trimis browserului pentru desenarea hărții.
# Adresa fișierului cu cartiere, dacă este în www/ (servit static). Un fișier
# din afara www/ (variabila CHESTIONAR_CARTIERE_GEOJSON) este trimis direct în
# mesaj, ca să nu fie expus un întreg director prin addResourcePath.
url_cartiere <- function(fisier = FISIER_CARTIERE_GEOJSON) {
  www <- normalizePath("www", winslash = "/", mustWork = FALSE)
  f <- normalizePath(fisier, winslash = "/", mustWork = FALSE)
  if (startsWith(f, paste0(www, "/"))) substring(f, nchar(www) + 2) else NULL
}

mesaj_harta <- function(cod_ales) {
  vectoriale <- coduri_cartiere_vectoriale()
  list(
    uat = "harta/uat.geojson",
    sursa_uat = SURSA_UAT$text,
    sursa_uat_url = SURSA_UAT$url,
    cartiere = if (length(vectoriale)) url_cartiere() else NULL,
    cartiere_geo = if (length(vectoriale) && is.null(url_cartiere())) paste(readLines(FISIER_CARTIERE_GEOJSON, warn = FALSE, encoding = "UTF-8"), collapse = "\n") else NULL,
    cod_ales = if (!is.na(cod_ales) && cod_ales %in% vectoriale) cod_ales else NULL,
    fundal_osm = isTRUE(HARTA_FUNDAL_OSM_PERMIS)
  )
}
