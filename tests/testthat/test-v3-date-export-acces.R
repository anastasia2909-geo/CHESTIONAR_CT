# Versiunea 3: migrarea bazelor vechi, exportul pentru analiză, accesul admin.

test_that("o bază de date cu schema din versiunea 2 este migrată fără pierderi", {
  cale <- tempfile("v2_", fileext = "_TEST.sqlite"); on.exit(unlink(cale))
  s <- schema_date(Q)
  s2 <- s[s$variabila != "varsta_minima_confirmata", ]      # schema v2
  initializeaza_db(cale, s2)
  r <- codifica_raspuns(Q, raspuns_valid(), genereaza_id(), "test")
  r$q21_toti <- 1L; r$q02_varsta <- "sub_18"                # valori posibile în v2
  r$varsta_minima_confirmata <- NULL
  con <- deschide_db(cale); DBI::dbAppendTable(con, TABELA, r); DBI::dbDisconnect(con)
  initializeaza_db(cale, s)                                  # pornirea v3
  df <- citeste_raspunsuri(cale, s)
  expect_equal(nrow(df), 1)
  expect_true(is.na(df$varsta_minima_confirmata))
  expect_equal(df$q21_toti, 1L)
  expect_equal(df$q02_varsta, "sub_18")
  e <- date_cu_etichete(df, Q)
  expect_equal(e$q02_varsta, "Sub 18 ani")                   # codul din v2 este din nou o variantă validă
  expect_equal(nrow(date_analiza(df, Q, "test")), 1)
})

test_that("exportul pentru analiză adaugă variabilele derivate documentate", {
  cale <- tempfile("a_", fileext = "_TEST.sqlite"); on.exit(unlink(cale))
  insereaza_date_test(Q, cale, 40, seed = 11)
  df <- citeste_raspunsuri(cale)
  a <- date_analiza(df, Q, "test")
  expect_true(all(DICTIONAR_DERIVATE$variabila %in% names(a)))
  expect_equal(nrow(a), 40)
  expect_true(all(a$completare_valida == 1))
  expect_true(all(a$q09_total_procente > 99.98 & a$q09_total_procente < 100.02))
  expect_equal(a$q06_total_persoane, a$q05_nr_persoane)
  i <- which(df$q08_nu_stiu == 0)[1]
  if (!is.na(i)) expect_equal(a$litri_pe_persoana_zi[i], round(litri_pe_persoana_zi(as.list(df[i, ])), 1))
  expect_true(all(is.na(a$ind_ulei_chiuveta[df$q13_ulei == "nu_folosesc"])))
  x <- tempfile(fileext = ".xlsx"); on.exit(unlink(x), add = TRUE)
  scrie_xlsx_analiza(df, Q, x, "test")
  expect_equal(openxlsx::getSheetNames(x), c("analiza_coduri", "analiza_etichete", "dictionar", "informatii"))
  d <- openxlsx::read.xlsx(x, "dictionar")
  expect_true(all(names(a) %in% d$variabila))
  txt <- paste(unlist(lapply(openxlsx::getSheetNames(x), function(f) unlist(openxlsx::read.xlsx(x, f)))), collapse = " ")
  expect_false(grepl("CHESTIONAR_ADMIN_PAROLA|parola", txt, ignore.case = TRUE))
})

test_that("parola se verifică numai față de variabila de mediu; fără parolă, accesul este refuzat", {
  expect_false(parola_corecta("orice", p = ""))
  expect_false(parola_corecta(NULL, p = "abc"))
  expect_false(parola_corecta(c("abc", "abc"), p = "abc"))
  expect_false(parola_corecta("ABC", p = "abc"))
  expect_true(parola_corecta("abc", p = "abc"))
  cod <- paste(readLines(file.path(RADACINA, "R", "10_admin.R"), encoding = "UTF-8"), collapse = "\n")
  expect_false(grepl("url_hostname|fara_parola_local", cod))
})

test_that("blocarea globală oprește încercările după 2 × ADMIN_INCERCARI_MAXIME eșecuri, din orice sesiune", {
  vechi <- ADMIN_STARE$esecuri; on.exit(ADMIN_STARE$esecuri <- vechi)
  ADMIN_STARE$esecuri <- as.POSIXct(character(0))
  t0 <- Sys.time()
  for (i in seq_len(2 * ADMIN_INCERCARI_MAXIME - 1)) admin_inregistreaza_esec(t0)
  expect_false(admin_blocat_global(t0))
  admin_inregistreaza_esec(t0)
  expect_true(admin_blocat_global(t0))
  expect_false(admin_blocat_global(t0 + ADMIN_BLOCARE_MINUTE * 60 + 1))
})

test_that("fila „Stare”: informarea și Q21 în regulă; confirmările instituționale și poligoanele semnalate", {
  vechi <- setwd(RADACINA); on.exit(setwd(vechi))
  v <- verificari_configurare(Q, "test", tempfile())
  expect_equal(v$stare[grepl("păstrarea", v$element)], "ok")
  expect_equal(v$stare[grepl("Q21", v$element)], "ok")
  expect_equal(v$stare[grepl("Durata", v$element)], "ok")
  expect_match(v$detalii[grepl("Durata", v$element)], "de validat")
  expect_equal(v$stare[grepl("Anonimat", v$element)], "ok")
  expect_false(any(grepl("instituționale", v$element)))
  expect_equal(v$stare[grepl("cartierelor", v$element)], "ok")
})

test_that("data trimiterii se salvează fără oră; răspunsurile vechi rămân neschimbate", {
  r <- codifica_raspuns(Q, raspuns_valid(), genereaza_id(), "test")
  expect_match(r$submitted_at, "^[0-9]{4}-[0-9]{2}-[0-9]{2}$")
  cale <- tempfile("t_", fileext = "_TEST.sqlite"); on.exit(unlink(cale))
  initializeaza_db(cale, schema_date(Q))
  vechi <- codifica_raspuns(Q, raspuns_valid(), genereaza_id(), "test", "2026-10-23T10:15:00Z")
  salveaza_raspuns(cale, vechi); salveaza_raspuns(cale, r)
  df <- citeste_raspunsuri(cale)
  expect_setequal(df$submitted_at, c("2026-10-23T10:15:00Z", r$submitted_at))
  vechi_p <- PRECIZIE_DATA_TRIMITERII
  on.exit(assign("PRECIZIE_DATA_TRIMITERII", vechi_p, envir = globalenv()), add = TRUE)
  assign("PRECIZIE_DATA_TRIMITERII", "secunda", envir = globalenv())
  expect_match(moment_trimitere(), "T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$")
})

test_that("parola din .Renviron este acceptată (ghilimele, diacritice, spații, CRLF)", {
  f <- tempfile(fileext = ".Renviron"); on.exit(unlink(f))
  vechi <- Sys.getenv("CHESTIONAR_ADMIN_PAROLA", unset = NA)
  on.exit(if (is.na(vechi)) Sys.unsetenv("CHESTIONAR_ADMIN_PAROLA") else Sys.setenv(CHESTIONAR_ADMIN_PAROLA = vechi), add = TRUE)
  for (linie in c('CHESTIONAR_ADMIN_PAROLA=Parolă-Lungă-2026', 'CHESTIONAR_ADMIN_PAROLA="Parolă-Lungă-2026"',
                  'CHESTIONAR_ADMIN_PAROLA=Parolă-Lungă-2026   ', 'CHESTIONAR_ADMIN_PAROLA=Parolă-Lungă-2026\r')) {
    writeBin(charToRaw(enc2utf8(paste0(linie, "\n"))), f)
    readRenviron(f)
    expect_true(parola_corecta("Parolă-Lungă-2026"), info = linie)
    expect_false(parola_corecta("parolă-lungă-2026"), info = linie)
  }
})

test_that("limitele cartierelor fără „tip_limite: oficiale” sunt prezentate ca orientative", {
  f <- file.path(RADACINA, "tests", "fixtures", "cartiere_test_FALS.geojson")
  i <- info_cartiere_vectoriale(f)
  expect_false(i$oficiale)
  expect_match(i$sursa, "DATE FALSE", fixed = TRUE)
  vechi <- FISIER_CARTIERE_GEOJSON
  on.exit(assign("FISIER_CARTIERE_GEOJSON", vechi, envir = globalenv()))
  assign("FISIER_CARTIERE_GEOJSON", f, envir = globalenv())
  h <- local({ v <- setwd(RADACINA); on.exit(setwd(v))
    rec <- codifica_raspuns(Q, raspuns_valid(), "x", "test")
    as.character(profil_ui(Q, rec, "test", cartier = date_cartier(rec$q01_zona))) })
  expect_match(h, "orientative, nu oficiale", fixed = TRUE)
})

test_that("niciun fișier sensibil nu stă în www/ (servit public)", {
  f <- list.files(file.path(RADACINA, "www"), recursive = TRUE, all.files = TRUE)
  expect_false(any(grepl("\\.(sqlite|db|Renviron|R|rds|csv|md)$", f, ignore.case = TRUE)))
})
