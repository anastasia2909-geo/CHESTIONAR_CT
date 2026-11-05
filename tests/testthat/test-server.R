# Testează logica serverului (eligibilitate, navigare, validare, trimitere)
# fără browser, cu shiny::testServer, pe o bază de date temporară.

test_that("fluxul complet salvează exact un rând, iar clickurile repetate nu dublează", {
  cu_aplicatie(function(app, cale) shiny::testServer(app, {
    # primul ciclu reactiv (ca la conectarea browserului): observatorii pornesc
    # cu intrări goale; fără el, primul setInputs ar fi tratat ca „init”.
    session$setInputs(campuri_invalide = list())
    v <- raspuns_valid()

    # fără acord și fără confirmarea vârstei nu se poate trimite nimic
    session$setInputs(trimite = 1)
    expect_equal(numar_raspunsuri(cale), 0L)

    session$setInputs(incepe = 1, consimtamant = TRUE, start = 1)
    do.call(session$setInputs, v[setdiff(names(v), c("q06_25_34"))])
    session$setInputs(q06_25_34 = 1)                 # suma greșită: 2 în loc de 3
    session$setInputs(inainte_s1 = 1, inainte_s2 = 1, inainte_s3 = 1, inainte_s4 = 1)
    session$setInputs(trimite = 2)
    expect_equal(numar_raspunsuri(cale), 0L)         # validarea finală oprește trimiterea

    session$setInputs(q06_25_34 = 2)
    session$setInputs(inainte_s1 = 2, inainte_s2 = 2, inainte_s3 = 2, inainte_s4 = 2)
    expect_match(as.character(output$rezumat_revizuire$html), "Casă")
    session$setInputs(trimite = 3)
    session$setInputs(trimite = 4)
    session$setInputs(trimite = 5)
    expect_equal(numar_raspunsuri(cale), 1L)

    df <- citeste_raspunsuri(cale)
    expect_equal(df$q04_locuinta, "casa")
    expect_equal(df$q06_25_34, 2L)
    expect_equal(df$q20_afisata, 1L)
    expect_equal(df$q20_mirosuri, 1L)
    expect_true(is.na(df$varsta_minima_confirmata))
    expect_true(is.na(df$q21_toti))
    expect_equal(df$mod, "test")
    html <- as.character(output$profil$html)
    expect_match(html, "Profilul dumneavoastră")
    expect_match(html, "Consumul estimat")
    # secțiunile scoase din profil în versiunea 3
    expect_false(grepl("c-q12|c-obiceiuri|Obiectele de la întrebarea 12|tipareste", html))
  }))
})

test_that("fără limită de vârstă: „Sub 18 ani” la Q2 este salvat, fără întrebare separată despre vârstă", {
  cu_aplicatie(function(app, cale) shiny::testServer(app, {
    session$setInputs(campuri_invalide = list())
    session$setInputs(incepe = 1, consimtamant = TRUE, start = 1)
    v <- raspuns_valid(); v$q02 <- "sub_18"
    do.call(session$setInputs, v)
    session$setInputs(inainte_s1 = 1, inainte_s2 = 1, inainte_s3 = 1, inainte_s4 = 1, trimite = 1)
    expect_equal(numar_raspunsuri(cale), 1L)
    df <- citeste_raspunsuri(cale)
    expect_equal(df$q02_varsta, "sub_18")
    expect_true(is.na(df$varsta_minima_confirmata))
  }))
})

test_that("fără acord nu se începe și nu se salvează", {
  cu_aplicatie(function(app, cale) shiny::testServer(app, {
    # primul ciclu reactiv (ca la conectarea browserului): observatorii pornesc
    # cu intrări goale; fără el, primul setInputs ar fi tratat ca „init”.
    session$setInputs(campuri_invalide = list())
    v <- raspuns_valid()
    do.call(session$setInputs, v)
    session$setInputs(incepe = 1, consimtamant = FALSE, start = 2)  # acord lipsă
    session$setInputs(inainte_s1 = 2, inainte_s2 = 2, inainte_s3 = 2, inainte_s4 = 2, trimite = 2)
    expect_equal(numar_raspunsuri(cale), 0L)
    # acordul retras după începere: trimiterea este refuzată
    session$setInputs(consimtamant = TRUE, start = 3)
    session$setInputs(consimtamant = FALSE)
    session$setInputs(inainte_s1 = 3, inainte_s2 = 3, inainte_s3 = 3, inainte_s4 = 3, trimite = 3)
    expect_equal(numar_raspunsuri(cale), 0L)
  }))
})

test_that("Q20 se salvează ca neaplicabilă când Q19 nu este „Da”", {
  cu_aplicatie(function(app, cale) shiny::testServer(app, {
    # primul ciclu reactiv (ca la conectarea browserului): observatorii pornesc
    # cu intrări goale; fără el, primul setInputs ar fi tratat ca „init”.
    session$setInputs(campuri_invalide = list())
    v <- raspuns_valid(); v$q19 <- "nu_imi_amintesc"; v$q20 <- c("mirosuri", "infundari")
    session$setInputs(incepe = 1, consimtamant = TRUE, start = 1)
    do.call(session$setInputs, v)
    session$setInputs(inainte_s1 = 1, inainte_s2 = 1, inainte_s3 = 1, inainte_s4 = 1, trimite = 1)
    df <- citeste_raspunsuri(cale)
    expect_equal(nrow(df), 1)
    expect_equal(df$q20_afisata, 0L)
    expect_true(is.na(df$q20_mirosuri))
    expect_true(is.na(df$q20_nu_se_aplica))
  }))
})

test_that("câmpurile Q6 și Q9 goale se salvează ca 0; un câmp invalid oprește trimiterea", {
  cu_aplicatie(function(app, cale) shiny::testServer(app, {
    # primul ciclu reactiv (ca la conectarea browserului): observatorii pornesc
    # cu intrări goale; fără el, primul setInputs ar fi tratat ca „init”.
    session$setInputs(campuri_invalide = list())
    v <- raspuns_valid()
    for (k in c("q06_18_24", "q06_35_44", "q06_45_54", "q06_55_64", "q06_65_plus")) v[[k]] <- NA
    v$q09_plante_altele <- NA; v$q09_toaleta <- 25
    session$setInputs(incepe = 1, consimtamant = TRUE, start = 1)
    do.call(session$setInputs, v)
    session$setInputs(campuri_invalide = list("q06_65_plus"))
    session$setInputs(inainte_s1 = 1, inainte_s2 = 1, inainte_s3 = 1, inainte_s4 = 1, trimite = 1)
    expect_equal(numar_raspunsuri(cale), 0L)        # „12abc” nu devine 0
    session$setInputs(campuri_invalide = list())
    session$setInputs(inainte_s1 = 2, inainte_s2 = 2, inainte_s3 = 2, inainte_s4 = 2, trimite = 2)
    expect_equal(numar_raspunsuri(cale), 1L)
    df <- citeste_raspunsuri(cale)
    expect_equal(df$q06_65_plus, 0L)
    expect_equal(df$q09_plante_altele, 0)
  }))
})
