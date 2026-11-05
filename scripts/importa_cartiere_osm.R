# =============================================================================
# importa_cartiere_osm.R — limitele celor 42 de cartiere pentru hartă
# -----------------------------------------------------------------------------
# Sursa: pachetul npm @nspot/geo-pack-romania-neighbourhoods, versiunea 1.6.0
# (publicat la 19.10.2026), fișierul pack.json. Pachetul desenează cele 42 de
# cartiere din HCL nr. 79/2023 pe linii OpenStreetMap (extrasul Geofabrik din
# 08.10.2026), urmând delimitările din anexa 1, și verifică fiecare poligon cu
# planul din anexa 2 (plan_check: ok / approximate / doubtful). Licența
# datelor: ODbL 1.0, © contribuitorii OpenStreetMap.
#
# Descărcare (o singură dată):
#   curl -o pack.tgz https://registry.npmjs.org/@nspot/geo-pack-romania-neighbourhoods/-/geo-pack-romania-neighbourhoods-1.6.0.tgz
#   SHA-256 verificat: 0967f5904ce389a2f0f3aee0b18b5ac8b7dcf17f925a59d26f5394f30a142de6
#   tar -xzf pack.tgz        (rezultă package/pack.json)
#
# Rulare, din folderul proiectului:
#   Rscript scripts/importa_cartiere_osm.R cale/catre/package/pack.json
#
# Scriptul verifică faptul că fiecare delimitare din pachet este identică cu
# cea din config/cartiere_hcl79_2023.csv și scrie www/harta/cartiere.geojson.
# =============================================================================

`%||%` <- function(a, b) if (is.null(a)) b else a
args <- commandArgs(trailingOnly = TRUE)
if (!length(args)) stop("Indicați fișierul pack.json.")
if (!file.exists("config/cartiere_hcl79_2023.csv")) stop("Rulați scriptul din folderul proiectului.")

pack <- jsonlite::fromJSON(args[1], simplifyVector = FALSE)
cart <- utils::read.csv("config/cartiere_hcl79_2023.csv", encoding = "UTF-8", stringsAsFactors = FALSE)

norm <- function(s) {
  s <- enc2utf8(s)
  s <- chartr("şţŞŢ", "șțȘȚ", s)
  tolower(gsub("\\s+", "", s))
}

f <- Filter(function(x) identical(x$properties$properties$city, "Constanța"), pack$regions$features)
if (length(f) != 42) stop("Pachetul are ", length(f), " cartiere pentru Constanța, nu 42.")

stare_ro <- c(ok = "în regulă", approximate = "aproximativă", doubtful = "incertă")

features <- lapply(f, function(x) {
  p <- x$properties$properties
  r <- cart[as.integer(cart$nr_hcl) == p$annex_row, ]
  if (nrow(r) != 1) stop("Rândul ", p$annex_row, " lipsește din tabelul HCL.")
  if (norm(p$delimitation) != norm(r$delimitare))
    stop("Delimitarea diferă pentru rândul ", p$annex_row, ": ", p$delimitation)
  rotunjeste <- function(v) if (is.list(v)) lapply(v, rotunjeste) else round(as.numeric(v), 6)
  list(type = "Feature",
       properties = list(
         cod = r$cod, denumire = r$denumire, nr_hcl = as.integer(r$nr_hcl),
         verificare_plan = unname(stare_ro[[p$plan_check]]),
         nota_verificare = p$plan_note %||% "",
         segmente_aproximative = unlist(p$approximate_legs) %||% character(0),
         id_sursa = x$properties$slug),
       geometry = list(type = x$geometry$type, coordinates = rotunjeste(x$geometry$coordinates)))
})
features <- features[order(vapply(features, function(x) x$properties$nr_hcl, 0L))]

out <- list(
  type = "FeatureCollection",
  tip_limite = "orientative",
  sursa = paste0("delimitările din anexa 1 la HCL nr. 79/2023, desenate pe linii OpenStreetMap ",
                 "(@nspot/geo-pack-romania-neighbourhoods 1.6.0, date OSM din 08.10.2026) și verificate cu planurile din anexa 2; ",
                 "© contribuitorii OpenStreetMap, ODbL 1.0"),
  licenta = "Open Database License 1.0 (https://opendatacommons.org/licenses/odbl/1-0/); © contribuitorii OpenStreetMap (https://www.openstreetmap.org/copyright)",
  features = features)

jsonlite::write_json(out, "www/harta/cartiere.geojson", auto_unbox = TRUE, digits = NA, pretty = FALSE)
tab <- table(vapply(features, function(x) x$properties$verificare_plan, ""))
message("Scris www/harta/cartiere.geojson: ", length(features), " cartiere. Verificare cu planul: ",
        paste(names(tab), tab, sep = " = ", collapse = ", "), ".")
