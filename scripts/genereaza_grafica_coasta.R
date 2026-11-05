# =============================================================================
# genereaza_grafica_coasta.R — ilustrația de pe pagina de start (www/img/coasta.svg)
# -----------------------------------------------------------------------------
# NU este necesar pentru rularea aplicației; fișierul SVG este inclus. Scriptul
# arată cum a fost obținută ilustrația, ca să fie clar că forma coastei NU este
# desenată de mână: provine din limitele UAT (ANCPI prin geoBoundaries,
# www/harta/uat.geojson). Liniile din mare sunt decalaje ale țărmului real la
# distanțe fixe (300, 800, 1 500, 2 400, 3 600 m) — un element grafic, nu
# izobate (adâncimi) și nu date batimetrice.
# Cerințe: pachetul sf. Rulare: Rscript scripts/genereaza_grafica_coasta.R
# =============================================================================
suppressPackageStartupMessages(library(sf))
sf_use_s2(FALSE)
uat <- st_transform(st_read(file.path("www", "harta", "uat.geojson"), quiet = TRUE), 3844)
constanta <- uat[uat$constanta, ]
bb <- st_bbox(constanta)
cadru <- st_as_sfc(st_bbox(c(xmin = bb[["xmin"]] - 1500, ymin = bb[["ymin"]] - 1500,
                             xmax = bb[["xmax"]] + 6000, ymax = bb[["ymax"]] + 1500), crs = st_crs(uat)))
uscat <- st_union(st_make_valid(uat))
mare  <- st_difference(cadru, uscat)
distante <- c(300, 800, 1500, 2400, 3600)
unde <- lapply(distante, function(d) {
  b <- st_buffer(uscat, d)
  l <- st_intersection(st_cast(st_boundary(b), "MULTILINESTRING"), mare)
  st_simplify(l, dTolerance = 40)
})
vecini <- st_intersection(st_simplify(uat[!uat$constanta, ], dTolerance = 25), cadru)
contur <- st_simplify(constanta, dTolerance = 15)

# transformare în coordonate SVG (viewBox 0 0 W H, y inversat)
x0 <- bb[["xmin"]] - 1500; y1 <- bb[["ymax"]] + 1500
W <- 600; scala <- W / ((bb[["xmax"]] + 6000) - x0)
H <- round(((bb[["ymax"]] + 1500) - (bb[["ymin"]] - 1500)) * scala)
pt <- function(m) paste0(sprintf("%.1f,%.1f", (m[, 1] - x0) * scala, (y1 - m[, 2]) * scala), collapse = " ")
cale <- function(g, inchis = TRUE) {
  parts <- character(0)
  for (geom in st_geometry(g)) {
    if (inherits(geom, c("POLYGON", "MULTIPOLYGON"))) {
      polys <- if (inherits(geom, "POLYGON")) list(geom) else lapply(seq_along(geom), function(i) geom[[i]])
      for (pg in polys) for (ring in pg) parts <- c(parts, paste0("M", pt(ring), "Z"))
    } else {
      lines <- if (inherits(geom, "LINESTRING")) list(as.matrix(geom)) else lapply(geom, as.matrix)
      for (ln in lines) if (nrow(ln) > 1) parts <- c(parts, paste0("M", pt(ln)))
    }
  }
  paste(parts, collapse = " ")
}
cx <- function(lon, lat) {
  p <- st_transform(st_sfc(st_point(c(lon, lat)), crs = 4326), 3844)[[1]]
  c((p[1] - x0) * scala, (y1 - p[2]) * scala)
}
eticheta <- cx(28.66, 44.17)
svg <- c(
  sprintf('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d" class="coasta" role="img" aria-labelledby="coasta-titlu">', W, H),
  '<title id="coasta-titlu">Conturul municipiului Constanța și țărmul Mării Negre (după limitele administrative ANCPI)</title>',
  '<defs><linearGradient id="crom" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FFFFFF"/><stop offset="0.35" stop-color="#C9D3E2"/><stop offset="0.6" stop-color="#8FA4C4"/><stop offset="0.78" stop-color="#E8EDF5"/><stop offset="1" stop-color="#6F86AE"/></linearGradient></defs>',
  sprintf('<path class="coasta-vecini" d="%s"/>', cale(vecini)),
  paste0('<g class="coasta-unde">', paste(sprintf('<path class="unda unda-%d" d="%s"/>', seq_along(unde), vapply(unde, cale, "", inchis = FALSE)), collapse = ""), '</g>'),
  sprintf('<path class="coasta-constanta" d="%s"/>', cale(contur)),
  sprintf('<path class="coasta-contur" pathLength="1" d="%s"/>', cale(contur)),
  sprintf('<text class="coasta-mare" x="%.0f" y="%.0f">Marea Neagră</text>', W - 165, H * 0.52),
  sprintf('<text class="coasta-coord" x="%.0f" y="%.0f">44°10′N · 28°38′E</text>', W - 165, H * 0.52 + 22),
  '</svg>')
writeLines(svg, file.path("www", "img", "coasta.svg"), useBytes = TRUE)
message("Scris: www/img/coasta.svg (", round(file.size(file.path("www", "img", "coasta.svg")) / 1024), " KB, ", W, "×", H, ")")
