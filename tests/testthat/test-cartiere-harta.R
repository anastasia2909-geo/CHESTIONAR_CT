# Tabelul cartierelor din HCL 79/2023, datele hărții și pagina finală.

cartiere_test <- function() local({ v <- setwd(RADACINA); on.exit(setwd(v)); citeste_cartiere() })

test_that("tabelul cartierelor are 42 de rânduri, aceleași coduri ca Q1 și planurile există", {
  d <- cartiere_test()
  expect_equal(nrow(d), 42)
  expect_setequal(d$cod, names(Q$q01$optiuni))
  expect_equal(as.integer(d$nr_hcl), 1:42)
  expect_equal(d$anexa_plan, paste0("2.", 1:42))
  expect_equal(as.integer(d$pagina_pdf), 4:45)
  expect_true(all(nzchar(d$delimitare)))
  expect_true(all(file.exists(file.path(RADACINA, "www", d$fisier_plan))))
  # denumirile din tabel = etichetele din Q1
  expect_equal(unname(Q$q01$optiuni[d$cod]), d$denumire)
  expect_false(any(grepl("[şţŞŢ]", c(d$denumire, d$delimitare))))
})

test_that("date_cartier întoarce fișa cartierului sau NULL", {
  d <- cartiere_test()
  f <- local({ v <- setwd(RADACINA); on.exit(setwd(v)); date_cartier("tomis_nord", d) })
  expect_equal(f$denumire, "Tomis Nord")
  expect_equal(f$nr_hcl, "35")
  expect_true(f$plan_exista)
  expect_match(f$delimitare, "^bd. Aurel Vlaicu - bd. Tomis - str. Soveja")
  expect_null(date_cartier("de_inlocuit_1", d))
  expect_null(date_cartier(NA_character_, d))
})

test_that("limitele UAT: 20 de poligoane, unul singur este Constanța", {
  g <- jsonlite::fromJSON(file.path(RADACINA, "www", "harta", "uat.geojson"), simplifyVector = FALSE)
  expect_equal(g$type, "FeatureCollection")
  expect_length(g$features, 20)
  c <- vapply(g$features, function(f) isTRUE(f$properties$constanta), logical(1))
  expect_equal(sum(c), 1)
  expect_equal(g$features[[which(c)]]$properties$nume, "Constanța")
  expect_equal(g$features[[which(c)]]$properties$shapeID, "2599482B843815366907")
})

test_that("limitele celor 42 de cartiere: aceleași coduri ca Q1, sursă, licență, verificare cu planul", {
  f <- file.path(RADACINA, "www", "harta", "cartiere.geojson")
  g <- jsonlite::fromJSON(f, simplifyVector = FALSE)
  expect_equal(g$type, "FeatureCollection")
  expect_equal(g$tip_limite, "orientative")
  expect_match(g$sursa, "HCL nr. 79/2023", fixed = TRUE)
  expect_match(g$licenta, "Open Database License", fixed = TRUE)
  coduri <- vapply(g$features, function(x) x$properties$cod, "")
  expect_setequal(coduri, names(Q$q01$optiuni))
  expect_true(all(vapply(g$features, function(x) x$properties$verificare_plan, "") %in% c("în regulă", "aproximativă", "incertă")))
  expect_true(all(vapply(g$features, function(x) x$geometry$type, "") %in% c("Polygon", "MultiPolygon")))
  # toate coordonatele în zona Constanței
  xy <- unlist(lapply(g$features, function(x) x$geometry$coordinates))
  lon <- xy[c(TRUE, FALSE)]; lat <- xy[c(FALSE, TRUE)]
  expect_true(all(lon > 28.5 & lon < 28.75 & lat > 44.08 & lat < 44.32))
  expect_true(file.exists(file.path(RADACINA, "www", "harta", "cartiere_LICENTA.txt")))
  m <- local({ v <- setwd(RADACINA); on.exit(setwd(v)); mesaj_harta("tomis_nord") })
  expect_equal(m$uat, "harta/uat.geojson")
  expect_equal(m$cartiere, "harta/cartiere.geojson"); expect_equal(m$cod_ales, "tomis_nord")
  expect_match(m$sursa_uat, "ANCPI")
})

test_that("un fișier vectorial valid al cartierelor este folosit doar pentru codurile pe care le conține", {
  tmp <- tempfile(fileext = ".geojson"); on.exit(unlink(tmp))
  writeLines('{"type":"FeatureCollection","features":[{"type":"Feature","properties":{"cod":"tomis_nord"},"geometry":{"type":"Polygon","coordinates":[[[28.6,44.2],[28.61,44.2],[28.61,44.21],[28.6,44.2]]]}}]}', tmp)
  expect_equal(coduri_cartiere_vectoriale(tmp), "tomis_nord")
  vechi <- FISIER_CARTIERE_GEOJSON
  on.exit(assign("FISIER_CARTIERE_GEOJSON", vechi, envir = globalenv()), add = TRUE)
  assign("FISIER_CARTIERE_GEOJSON", tmp, envir = globalenv())
  expect_equal(mesaj_harta("tomis_nord")$cod_ales, "tomis_nord")
  expect_null(mesaj_harta("palas")$cod_ales)
  writeLines("nu este json", tmp)
  expect_warning(expect_equal(coduri_cartiere_vectoriale(tmp), character(0)))
})

test_that("recomandările depind de răspunsuri și au toate o sursă cunoscută", {
  r0 <- codifica_raspuns(Q, raspuns_valid(), "x", "test")
  rr0 <- recomandari(Q, r0)
  expect_true(all(vapply(rr0, function(x) is.null(x$legata), logical(1))))      # nimic legat
  expect_setequal(vapply(rr0, `[[`, "", "id"), c("igiena", "ulei", "medicamente", "lege", "raja"))
  v <- raspuns_valid(); v$q12_servetele_umede <- "eticheta_flushable"; v$q12_medicamente <- "fara_cos"; v$q13 <- "chiuveta_toaleta"
  rr <- recomandari(Q, codifica_raspuns(Q, v, "x", "test"))
  ids <- vapply(rr, `[[`, "", "id")
  expect_true(all(c("igiena", "cos", "flushable", "ulei", "medicamente") %in% ids))
  expect_equal(sum(ids == "ulei"), 1)                       # fără dubluri
  expect_true(all(unlist(lapply(rr, `[[`, "surse")) %in% names(SURSE_PROFIL)))
  legate <- Filter(function(x) !is.null(x$legata), rr)
  expect_true(all(grepl("întrebarea 1[23]", vapply(legate, `[[`, "", "legata"))))
})

test_that("fiecare sursă are titlu, tip și trimitere în registrul de surse", {
  reg <- paste(readLines(file.path(RADACINA, "docs", "REGISTRU_SURSE.md"), encoding = "UTF-8"), collapse = "\n")
  for (k in names(SURSE_PROFIL)) {
    s <- SURSE_PROFIL[[k]]
    expect_true(nzchar(s$titlu) && nzchar(s$tip), info = k)
    expect_match(reg, s$registru, fixed = TRUE, info = k)
    if (!is.null(s$url)) expect_match(s$url, "^https://", info = k)
  }
})

test_that("comparația apare numai peste prag și procentele însumează 100", {
  vals <- genereaza_valori_sintetice(Q, COMPARATIE_MIN_RASPUNSURI + 5, seed = 3)
  df <- do.call(rbind, lapply(vals, function(v) codifica_raspuns(Q, v, genereaza_id(), "test")))
  sub <- agregat_comparatie(Q, df[seq_len(COMPARATIE_MIN_RASPUNSURI - 1), ])
  expect_equal(sub$n, COMPARATIE_MIN_RASPUNSURI - 1)
  expect_length(sub$indicatori, 0)
  peste <- agregat_comparatie(Q, df)
  expect_setequal(names(peste$indicatori), INTREBARI_COMPARATIE)
  for (i in peste$indicatori) expect_equal(sum(i$procente), 100, tolerance = 1e-9)
})

test_that("pagina finală se construiește pentru orice cartier și pentru un cod vechi", {
  d <- cartiere_test()
  vechi <- setwd(RADACINA); on.exit(setwd(vechi))
  for (cod in c(d$cod, "de_inlocuit_1")) {
    v <- raspuns_valid(); v$q01 <- cod
    rec <- codifica_raspuns(Q, v, "x", "test")
    rec$q01_zona <- cod
    h <- as.character(profil_ui(Q, rec, "test", agregat = list(n = 3), cartier = date_cartier(cod, d),
                                tematic = calculeaza_indicatori(Q, rec, d, mod = "test")))
    expect_match(h, "Constanța pe hartă", fixed = TRUE)
    if (cod %in% d$cod) expect_match(h, d$denumire[d$cod == cod], fixed = TRUE)
    else expect_match(h, "nu există date", fixed = TRUE)
    expect_match(h, "Comparația nu este încă disponibilă", fixed = TRUE)
    expect_match(h, "Indicatorii pe cartiere nu sunt încă disponibili", fixed = TRUE)
    expect_false(grepl("tipareste|Tipărește", h))
  }
})

test_that("exportul cu etichete păstrează codurile necunoscute în loc să le golească", {
  r <- codifica_raspuns(Q, raspuns_valid(), "x", "test")
  r$q01_zona <- "de_inlocuit_2"
  e <- date_cu_etichete(r, Q)
  expect_equal(e$q01_zona, "de_inlocuit_2")
  r$q01_zona <- "tomis_nord"
  expect_equal(date_cu_etichete(r, Q)$q01_zona, "Tomis Nord")
})
