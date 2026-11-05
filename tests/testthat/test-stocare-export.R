cale_temp <- function(sufix = "_TEST.sqlite") tempfile("raspunsuri", fileext = sufix)

test_that("un răspuns se salvează, rămâne după redeschidere și nu se dublează", {
  cale <- cale_temp(); on.exit(unlink(cale))
  initializeaza_db(cale, schema_date(Q))
  r <- codifica_raspuns(Q, raspuns_valid(), genereaza_id(), "test")
  expect_equal(salveaza_raspuns(cale, r), "ok")
  expect_equal(salveaza_raspuns(cale, r), "duplicat")
  expect_equal(numar_raspunsuri(cale), 1L)
  initializeaza_db(cale, schema_date(Q))       # ca la o repornire a aplicației
  df <- citeste_raspunsuri(cale, schema_date(Q))
  expect_equal(nrow(df), 1)
  expect_equal(df$q12_medicamente, "nu_am_aruncat")
  expect_true(is.na(df$q08_apa_calda_m3))
  expect_equal(names(df), schema_date(Q)$variabila)
})

test_that("ștergerea datelor de test refuză baza de date reală", {
  reala <- cale_temp(".sqlite"); test <- cale_temp(); on.exit(unlink(c(reala, test)))
  for (c in c(reala, test)) {
    initializeaza_db(c, schema_date(Q))
    salveaza_raspuns(c, codifica_raspuns(Q, raspuns_valid(), genereaza_id(), "test"))
  }
  expect_error(sterge_date_test(reala), "Refuz")
  expect_equal(sterge_date_test(test), 1L)
  expect_equal(numar_raspunsuri(test), 0L)
  expect_equal(numar_raspunsuri(reala), 1L)
  expect_error(insereaza_date_test(Q, reala, 2), "baza de test")
})

test_that("o coloană nouă în chestionar este adăugată fără a pierde datele", {
  cale <- cale_temp(); on.exit(unlink(cale))
  s <- schema_date(Q)
  initializeaza_db(cale, s[s$variabila != "q25_sugestie", ])
  con <- deschide_db(cale); n1 <- DBI::dbListFields(con, TABELA); DBI::dbDisconnect(con)
  expect_false("q25_sugestie" %in% n1)
  initializeaza_db(cale, s)
  con <- deschide_db(cale); n2 <- DBI::dbListFields(con, TABELA); DBI::dbDisconnect(con)
  expect_true("q25_sugestie" %in% n2)
})

test_that("exportul Excel și CSV are coloane stabile și NA ca celulă goală", {
  cale <- cale_temp(); on.exit(unlink(cale))
  insereaza_date_test(Q, cale, 12, seed = 7)
  df <- citeste_raspunsuri(cale, schema_date(Q))
  x <- tempfile(fileext = ".xlsx"); c <- tempfile(fileext = ".csv")
  scrie_xlsx(df, Q, x, "test"); scrie_csv(df, c)
  foi <- openxlsx::getSheetNames(x)
  expect_equal(foi, c("raspunsuri", "raspunsuri_etichete", "dictionar_date", "informatii"))
  citit <- openxlsx::read.xlsx(x, sheet = "raspunsuri")
  expect_equal(names(citit), schema_date(Q)$variabila)
  expect_equal(nrow(citit), 12)
  et <- openxlsx::read.xlsx(x, sheet = "raspunsuri_etichete")
  expect_true(all(et$q02_varsta %in% unname(Q$q02$optiuni)))
  bytes <- readBin(c, "raw", 3)
  expect_equal(bytes, as.raw(c(0xEF, 0xBB, 0xBF)))
  csv <- utils::read.csv(c, fileEncoding = "UTF-8-BOM", stringsAsFactors = FALSE, na.strings = "")
  expect_equal(names(csv), schema_date(Q)$variabila)
  expect_equal(sum(is.na(csv$q20_mirosuri)), sum(df$q20_afisata == 0))
})

test_that("copia de siguranță conține aceleași răspunsuri", {
  cale <- cale_temp(); dest <- tempfile(fileext = ".sqlite"); on.exit(unlink(c(cale, dest)))
  insereaza_date_test(Q, cale, 5, seed = 1)
  copie_de_siguranta(cale, dest)
  expect_equal(numar_raspunsuri(dest), 5L)
})
