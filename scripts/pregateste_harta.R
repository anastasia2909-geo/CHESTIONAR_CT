# =============================================================================
# pregateste_harta.R — pregătirea datelor pentru harta din pagina finală
# -----------------------------------------------------------------------------
# NU este necesar pentru rularea aplicației: rezultatul (www/harta/uat.geojson)
# este deja inclus. Scriptul documentează cum a fost obținut fișierul, ca
# datele să poată fi verificate și regenerate.
#
# Sursa: geoBoundaries, Romania ADM2 (municipalities), gbOpen,
#   boundaryID ROU-ADM2-2599482, sursa primară: Agenția Națională de Cadastru
#   și Publicitate Imobiliară (ANCPI), setul „Unități administrative” de pe
#   data.gov.ro; licență CC BY 4.0. Fișierul descărcat:
#   https://media.githubusercontent.com/media/wmgeolab/geoBoundaries/main/releaseData/gbOpen/ROU/ADM2/geoBoundaries-ROU-ADM2.geojson
#   (SHA-256 19154c9d6fe49da9d76e84ef29761dad263df8da097b0ecd05505af084ef16ba,
#   descărcat la 27.10.2026)
#
# Pași: se păstrează UAT-urile care intersectează un dreptunghi în jurul
# municipiului Constanța, se simplifică liniile cu toleranța de 10 m și se
# rotunjesc coordonatele la 5 zecimale (aprox. 1 m).
#
# Cerințe: pachetul sf (install.packages("sf")).
# Rulare: Rscript scripts/pregateste_harta.R cale/geoBoundaries-ROU-ADM2.geojson
# =============================================================================

args <- commandArgs(trailingOnly = TRUE)
sursa <- if (length(args)) args[1] else "geoBoundaries-ROU-ADM2.geojson"
stopifnot(file.exists(sursa))
suppressPackageStartupMessages(library(sf))
sf_use_s2(FALSE)

uat <- st_read(sursa, quiet = TRUE)
cadru <- st_as_sfc(st_bbox(c(xmin = 28.40, ymin = 43.98, xmax = 28.86, ymax = 44.40), crs = st_crs(4326)))
zona <- uat[lengths(st_intersects(uat, cadru)) > 0, ]

# Numele oficiale cu diacritice; în sursă sunt scrise cu majuscule, fără
# diacritice. Se adaugă doar pentru afișare; câmpul shapeName rămâne neschimbat.
nume <- c(CONSTANTA = "Constanța", OVIDIU = "Ovidiu", NAVODARI = "Năvodari",
          LUMINA = "Lumina", "VALU LUI TRAIAN" = "Valu lui Traian", AGIGEA = "Agigea",
          CUMPANA = "Cumpăna", MURFATLAR = "Murfatlar", "POARTA ALBA" = "Poarta Albă",
          "MIHAIL KOGALNICEANU" = "Mihail Kogălniceanu", TECHIRGHIOL = "Techirghiol",
          CORBU = "Corbu", EFORIE = "Eforie", "CASTELU" = "Castelu", "NICOLAE BALCESCU" = "Nicolae Bălcescu",
          "TUZLA" = "Tuzla", "SACELE" = "Săcele", "ISTRIA" = "Istria", "TOPRAISAR" = "Topraisar",
          "PECINEAGA" = "Pecineaga", "COBADIN" = "Cobadin", "SIBIOARA" = "Sibioara", "MIHAI VITEAZU" = "Mihai Viteazu", "BARAGANU" = "Băraganu")
zona$nume <- ifelse(zona$shapeName %in% names(nume), nume[zona$shapeName], tools::toTitleCase(tolower(zona$shapeName)))
zona$constanta <- zona$shapeName == "CONSTANTA"

zona <- st_transform(zona, 3844)                              # Stereo 70, în metri
zona <- st_simplify(zona, dTolerance = 10, preserveTopology = TRUE)
zona <- st_transform(zona, 4326)
zona <- zona[, c("nume", "shapeName", "shapeID", "constanta")]

dir.create(file.path("www", "harta"), showWarnings = FALSE, recursive = TRUE)
iesire <- file.path("www", "harta", "uat.geojson")
if (file.exists(iesire)) file.remove(iesire)
st_write(zona, iesire, driver = "GeoJSON", quiet = TRUE,
         layer_options = c("COORDINATE_PRECISION=5", "RFC7946=YES"))
message("Scris: ", iesire, " (", nrow(zona), " UAT-uri, ", round(file.size(iesire) / 1024), " KB)")
print(sf::st_drop_geometry(zona))
