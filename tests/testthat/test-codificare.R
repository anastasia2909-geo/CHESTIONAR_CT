test_that("rândul codificat are exact coloanele din schemă", {
  r <- codifica_raspuns(Q, raspuns_valid(), "abc", "test")
  expect_equal(names(r), schema_date(Q)$variabila)
  expect_equal(nrow(r), 1)
})

test_that("valorile lipsă rămân NA și nu devin 0", {
  v <- raspuns_valid(); v$q08_calda <- NA
  r <- codifica_raspuns(Q, v, "abc", "test")
  expect_true(is.na(r$q08_apa_calda_m3))
  expect_equal(r$q08_apa_rece_m3, 10.5)
  expect_true(is.na(r$q25_sugestie))
  v$q08_nu_stiu <- TRUE; v$q08_rece <- 12
  r <- codifica_raspuns(Q, v, "abc", "test")
  expect_equal(r$q08_nu_stiu, 1L)
  expect_true(is.na(r$q08_apa_rece_m3))
})

test_that("Q20 neaplicabilă structural este NA, distinct de „Nu se aplică”", {
  v <- raspuns_valid(); v$q19 <- "nu"; v$q20 <- c("mirosuri")
  r <- codifica_raspuns(Q, v, "abc", "test")
  expect_equal(r$q20_afisata, 0L)
  expect_true(all(is.na(unlist(r[paste0("q20_", names(Q$q20$optiuni))]))))
  v$q19 <- "da"; v$q20 <- "nu_se_aplica"
  r <- codifica_raspuns(Q, v, "abc", "test")
  expect_equal(r$q20_afisata, 1L)
  expect_equal(r$q20_nu_se_aplica, 1L)
  expect_equal(r$q20_mirosuri, 0L)
})

test_that("selecțiile multiple devin coloane 0/1; Q12 păstrează codul motivului", {
  v <- raspuns_valid(); v$q12_servetele_umede <- "eticheta_flushable"
  r <- codifica_raspuns(Q, v, "abc", "test")
  expect_equal(r$q10_dusuri_scurte, 1L); expect_equal(r$q10_nimic, 0L)
  expect_equal(r$q12_servetele_umede, "eticheta_flushable")
  expect_equal(r$q12_medicamente, "nu_am_aruncat")
  expect_equal(r$q21_cetateni, 5L); expect_true(is.na(r$q21_toti))
  expect_true(is.na(r$varsta_minima_confirmata))   # nu se mai cere din 3.1
})

test_that("textul liber este curățat de caractere de control", {
  v <- raspuns_valid(); v$q25 <- "  Linia 1\r\nLinia 2\x01  "
  r <- codifica_raspuns(Q, v, "abc", "test")
  expect_equal(r$q25_sugestie, "Linia 1\nLinia 2")
})

test_that("ID-ul generat are 32 de caractere hexazecimale și diferă la fiecare apel", {
  a <- genereaza_id(); b <- genereaza_id()
  expect_match(a, "^[0-9a-f]{32}$"); expect_false(identical(a, b))
})

test_that("numerele sunt afișate cu virgulă zecimală, fără a pierde zerourile întregi", {
  expect_equal(format_ro(150, 0), "150")
  expect_equal(format_ro(100), "100")
  expect_equal(format_ro(10.5), "10,5")
  expect_equal(format_ro(99.995), "100")
  expect_equal(format_ro(0), "0")
  expect_equal(format_ro(0.25), "0,25")
  expect_equal(format_ro(NA), "—")
})

test_that("calculul de litri pe persoană pe zi", {
  r <- codifica_raspuns(Q, modifyList(raspuns_valid(), list(q05 = 2, q06_25_34 = 1, q06_sub_18 = 1, q08_rece = 9)), "x", "test")
  expect_equal(litri_pe_persoana_zi(r), 150)
  r$q08_nu_stiu <- 1L; r$q08_apa_rece_m3 <- NA
  expect_true(is.na(litri_pe_persoana_zi(r)))
})
