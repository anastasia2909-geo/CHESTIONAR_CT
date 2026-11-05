test_that("un răspuns complet trece validarea", {
  expect_length(valideaza_tot(Q, raspuns_valid()), 0)
})

test_that("Q5 și Q8: un câmp marcat invalid de browser nu trece", {
  v <- raspuns_valid(); v[[".invalide"]] <- "q05"
  expect_false(is.null(valideaza_intrebare(Q$q05, v)))
  v <- raspuns_valid(); v[[".invalide"]] <- "q08_calda"; v$q08_calda <- NA
  expect_false(is.null(valideaza_intrebare(Q$q08, v)))
})

test_that("Q5: număr întreg pozitiv", {
  v <- raspuns_valid()
  for (bad in list(NA, 0, -1, 2.5, LIMITA_PERSOANE_GOSPODARIE + 1)) {
    v$q05 <- bad
    expect_false(is.null(valideaza_intrebare(Q$q05, v)), info = paste("q05 =", bad))
  }
})

test_that("Q6: suma pe categorii trebuie să fie egală cu Q5", {
  v <- raspuns_valid()
  v$q06_25_34 <- 1
  expect_match(valideaza_intrebare(Q$q06, v), "Suma pe categorii este 2")
  v$q06_25_34 <- 2
  expect_null(valideaza_intrebare(Q$q06, v))
  v$q06_65_plus <- NA                                  # gol = 0 (din versiunea 3)
  expect_null(valideaza_intrebare(Q$q06, v))
  v$q06_65_plus <- 0; v[[".invalide"]] <- "q06_65_plus"  # text nevalid: nu devine 0
  expect_match(valideaza_intrebare(Q$q06, v), "nu este un număr|număr")
  v[[".invalide"]] <- NULL
  v$q06_65_plus <- -1; v$q06_25_34 <- 3
  expect_match(valideaza_intrebare(Q$q06, v), "întregi")
})

test_that("Q8: „Nu știu” sau apă rece; apa caldă poate lipsi", {
  v <- raspuns_valid()
  v$q08_rece <- NA
  expect_match(valideaza_intrebare(Q$q08, v), "Nu știu")
  v$q08_nu_stiu <- TRUE
  expect_null(valideaza_intrebare(Q$q08, v))
  v$q08_nu_stiu <- FALSE; v$q08_rece <- 8; v$q08_calda <- NA
  expect_null(valideaza_intrebare(Q$q08, v))
  v$q08_calda <- -2
  expect_match(valideaza_intrebare(Q$q08, v), "negative")
  v$q08_calda <- LIMITA_M3_PE_LUNA + 1
  expect_match(valideaza_intrebare(Q$q08, v), "indexul")
})

test_that("Q9: total 100 cu toleranță 0,01", {
  v <- raspuns_valid()
  v$q09_plante_altele <- 4.995
  expect_null(valideaza_intrebare(Q$q09, v))
  v$q09_plante_altele <- 4.9
  expect_match(valideaza_intrebare(Q$q09, v), "99,9%")
  v$q09_plante_altele <- 15
  expect_match(valideaza_intrebare(Q$q09, v), "110%")
  v$q09_plante_altele <- NA                            # gol = 0%: totalul devine 95%
  expect_match(valideaza_intrebare(Q$q09, v), "95%")
  v$q09_plante_altele <- 5; v[[".invalide"]] <- "q09_rufe"
  expect_false(is.null(valideaza_intrebare(Q$q09, v)))
  v[[".invalide"]] <- NULL
  v$q09_plante_altele <- 5; v$q09_igiena <- 140; v$q09_rufe <- -85
  expect_match(valideaza_intrebare(Q$q09, v), "între 0 și 100")
})

test_that("Q10, Q11, Q16: opțiunile exclusive nu pot fi combinate", {
  v <- raspuns_valid()
  v$q10 <- c("dusuri_scurte", "nimic")
  expect_match(valideaza_intrebare(Q$q10, v), "Nu am făcut nimic")
  v$q10 <- c("nimic", "nu_imi_amintesc")
  expect_false(is.null(valideaza_intrebare(Q$q10, v)))
  v$q10 <- "nu_imi_amintesc"
  expect_null(valideaza_intrebare(Q$q10, v))
  v$q11 <- c("niciunul", "nu_stiu")
  expect_false(is.null(valideaza_intrebare(Q$q11, v)))
  v$q16 <- c("nu_stiu", "detergenti")
  expect_false(is.null(valideaza_intrebare(Q$q16, v)))
  v$q10 <- NULL
  expect_match(valideaza_intrebare(Q$q10, v), "cel puțin o variantă")
})

test_that("Q12: câte un răspuns pentru fiecare obiect", {
  v <- raspuns_valid()
  v$q12_medicamente <- NULL; v$q12_scutece <- NULL
  m <- valideaza_intrebare(Q$q12, v)
  expect_match(m, "Medicamente"); expect_match(m, "Scutece")
})

test_that("Q20 este validată doar când Q19 = Da", {
  v <- raspuns_valid()
  v$q20 <- NULL
  expect_match(valideaza_intrebare(Q$q20, v), "cel puțin o variantă")
  for (r in c("nu", "nu_imi_amintesc")) { v$q19 <- r; expect_null(valideaza_intrebare(Q$q20, v)) }
})

test_that("Q21: fiecare rând are o valoare 1–5; Q25 este opțională", {
  v <- raspuns_valid()
  v$q21_control <- NULL
  expect_match(valideaza_intrebare(Q$q21, v), "Instituțiile de control")
  v <- raspuns_valid(); v$q25 <- ""
  expect_null(valideaza_intrebare(Q$q25, v))
  v$q25 <- strrep("a", LUNGIME_MAXIMA_Q25 + 1)
  expect_match(valideaza_intrebare(Q$q25, v), "limita")
})

test_that("valori din afara listei sunt respinse", {
  v <- raspuns_valid()
  v$q02 <- "valoare_inventata"
  expect_false(is.null(valideaza_intrebare(Q$q02, v)))
  v$q01 <- "zona_inexistenta"
  expect_false(is.null(valideaza_intrebare(Q$q01, v)))
})

test_that("datele sintetice respectă toate regulile", {
  vals <- genereaza_valori_sintetice(Q, 300, seed = 42)
  expect_true(all(vapply(vals, function(v) length(valideaza_tot(Q, v)) == 0, logical(1))))
})
