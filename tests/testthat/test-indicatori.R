# Indicatorii pe cartiere (R/12_indicatori.R): numărători, numitori, praguri.

df_indicatori <- function() {
  # 12 respondenți în Tomis Nord, 3 în Palas, 0 în rest
  mk <- function(cod, q13, serv, alte = "nu_am_aruncat") {
    v <- raspuns_valid(); v$q01 <- cod; v$q13 <- q13
    for (k in names(Q$q12$randuri)) v[[paste0("q12_", k)]] <- alte
    v$q12_servetele_umede <- serv
    codifica_raspuns(Q, v, genereaza_id(), "test")
  }
  rows <- c(
    lapply(1:4, function(i) mk("tomis_nord", "chiuveta_toaleta", "rapid_obisnuinta")),
    lapply(1:4, function(i) mk("tomis_nord", "punct_colectare", "nu_am_aruncat")),
    lapply(1:2, function(i) mk("tomis_nord", "nu_folosesc", "prefer_nu")),
    lapply(1:2, function(i) mk("tomis_nord", "gunoi_recipient", "nu_am_aruncat", alte = "prefer_nu")),
    lapply(1:3, function(i) mk("palas", "chiuveta_toaleta", "rapid_obisnuinta")))
  do.call(rbind, rows)
}
cart <- function() local({ v <- setwd(RADACINA); on.exit(setwd(v)); citeste_cartiere() })

test_that("sub pragul total indicatorii nu sunt activi", {
  ind <- calculeaza_indicatori(Q, df_indicatori(), cart(), mod = "test", prag_total = 30)
  expect_false(ind$activ); expect_equal(ind$total, 15); expect_length(ind$indicatori, 0)
  expect_null(mesaj_indicatori(ind))
})

test_that("numărători și numitori corecți, suprimare sub prag", {
  ind <- calculeaza_indicatori(Q, df_indicatori(), cart(), mod = "test", prag_total = 10, prag_cartier = 10, prag_numar = 5)
  expect_true(ind$activ)
  n <- ind$indicatori$nr_respondenti
  expect_equal(n$stare[n$cod == "tomis_nord"], "valoare"); expect_equal(n$numitor[n$cod == "tomis_nord"], 12)
  expect_equal(n$stare[n$cod == "palas"], "suprimat");    expect_true(is.na(n$numitor[n$cod == "palas"]))
  expect_equal(sum(n$stare == "zero"), 40)
  u <- ind$indicatori$ulei_chiuveta
  tn <- u[u$cod == "tomis_nord", ]
  expect_equal(tn$numitor, 10)                 # fără cei 2 „Nu folosesc ulei”
  expect_equal(tn$numarator, 4); expect_equal(tn$valoare, 40)
  expect_equal(tn$clasa, 4L)                   # 35–49%
  expect_equal(u$stare[u$cod == "palas"], "suprimat"); expect_true(is.na(u$valoare[u$cod == "palas"]))
  q <- ind$indicatori$q12_oricare
  tq <- q[q$cod == "tomis_nord", ]
  # numitor: 4 cu motiv + 4 cu toate „nu” ; exclus: 2 fără motiv dar cu „prefer” (serv) și 2 cu „prefer” la restul
  expect_equal(tq$stare, "suprimat"); expect_true(is.na(tq$numitor))
  d <- df_indicatori(); ct <- contributii(Q, d)
  expect_equal(sum(ct$q12_oricare$den[d$q01_zona == "tomis_nord"]), 8)
  expect_equal(sum(ct$q12_oricare$num[d$q01_zona == "tomis_nord"]), 4)
  s <- ind$indicatori$q12_servetele
  ts <- s[s$cod == "tomis_nord", ]
  expect_equal(ts$stare, "valoare"); expect_equal(ts$numitor, 10); expect_equal(ts$numarator, 4)
  # nicio valoare publicată sub prag
  for (d in ind$indicatori) expect_true(all(is.na(d$valoare[d$stare != "valoare"])))
})

test_that("clasele de valori au limitele documentate", {
  expect_equal(clasa_valoare(c(0, 9.99, 10, 19.9, 20, 34.9, 35, 49.9, 50, 100), CLASE_PROCENT), c(1L,1L,2L,2L,3L,3L,4L,4L,5L,5L))
  expect_equal(clasa_valoare(c(1, 4, 5, 9, 10, 24, 25, 49, 50, 500), CLASE_NUMAR), c(1L,1L,2L,2L,3L,3L,4L,4L,5L,5L))
  expect_true(is.na(clasa_valoare(NA, CLASE_PROCENT)))
})

test_that("răspunsurile fără acord, fără cartier sau din alt mod nu intră în calcul", {
  df <- df_indicatori()
  df$consimtamant[1] <- 0L; df$q01_zona[2] <- NA; df$mod[3] <- "productie"
  expect_equal(nrow(filtreaza_valide(df, "test")), 12)
})

test_that("mesajul către browser nu conține numărătorii cartierelor suprimate", {
  ind <- calculeaza_indicatori(Q, df_indicatori(), cart(), mod = "test", prag_total = 10)
  m <- mesaj_indicatori(ind)
  pal <- Filter(function(v) v$cod == "palas", m$indicatori[[2]]$valori)[[1]]
  expect_equal(pal$stare, "suprimat"); expect_null(pal$clasa)
  expect_false(grepl("3", pal$eticheta))
})

test_that("cu poligoane false, harta folosește fișierul din afara www/ fără a expune folderul", {
  f <- file.path(RADACINA, "tests", "fixtures", "cartiere_test_FALS.geojson")
  vechi <- FISIER_CARTIERE_GEOJSON
  on.exit(assign("FISIER_CARTIERE_GEOJSON", vechi, envir = globalenv()))
  assign("FISIER_CARTIERE_GEOJSON", f, envir = globalenv())
  expect_length(coduri_cartiere_vectoriale(), 42)
  m <- local({ v <- setwd(RADACINA); on.exit(setwd(v)); mesaj_harta("tomis_nord") })
  expect_null(m$cartiere)
  expect_match(m$cartiere_geo, "DATE FALSE PENTRU TESTE", fixed = TRUE)
  expect_equal(m$cod_ales, "tomis_nord")
})
