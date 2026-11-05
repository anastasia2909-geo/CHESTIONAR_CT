test_that("chestionarul are 25 de întrebări în ordinea și secțiunile aprobate", {
  expect_length(Q, 25)
  expect_equal(unname(vapply(Q, `[[`, 0, "nr")), 1:25)
  sect <- vapply(Q, `[[`, 0, "sectiune")
  expect_equal(as.integer(table(sect)), c(7L, 6L, 5L, 7L))
})

test_that("textele verificate față de documentul aprobat", {
  expect_equal(Q$q01$text, "În ce cartier/zonă din municipiul Constanța locuiți?")
  expect_equal(Q$q12$text, paste0("În ultimele 30 de zile, ai aruncat vreunul dintre obiectele de mai jos în toaletă? ",
    "Pentru fiecare obiect, alege motivul pentru care l-ai aruncat sau bifează „Nu am aruncat acest obiect”."))
  expect_equal(Q$q24$text, "Cât de familiarizat(ă) sunteți cu termenul «micropoluanți» în contextul apelor uzate?")
  expect_equal(unname(Q$q12$coloane), c("Era mai rapid/din obișnuință", "Nu aveam coș", "Credeam că este permis",
                                        "Etichetă „flushable”", "Nu l-am aruncat", "Prefer să nu răspund"))
  expect_length(Q$q12$randuri, 8)
  expect_length(Q$q21$randuri, 5)
})

test_that("Q4 afișează „Prefer să nu răspund” o singură dată", {
  expect_equal(sum(Q$q04$optiuni == "Prefer să nu răspund"), 1)
  expect_equal(unname(Q$q04$optiuni), c("Apartament la bloc", "Casă", "Alt tip", "Prefer să nu răspund", "Nu știu"))
})

test_that("Q6 trimite la întrebarea 5 pentru total", {
  expect_match(Q$q06$note, "întrebarea 5", fixed = TRUE)
})

test_that("codurile sunt stabile, fără diacritice, și numele de coloane sunt unice", {
  s <- schema_date(Q)
  expect_false(anyDuplicated(s$variabila) > 0)
  expect_true(all(grepl("^[a-z0-9_]+$", s$variabila)))
  for (q in Q) if (!is.null(q$optiuni)) expect_true(all(grepl("^[a-z0-9_]+$", names(q$optiuni))), info = q$id)
  expect_true(all(c("q01_zona", "q02_varsta", "q12_medicamente", "q20_afisata", "q21_toti", "q25_sugestie") %in% s$variabila))
})

test_that("dicționarul de date descrie fiecare coloană", {
  d <- dictionar_date(Q)
  expect_equal(d$variabila, schema_date(Q)$variabila)
  expect_false(any(is.na(d$intrebare) | !nzchar(d$valori_permise)))
})

test_that("informarea numește doar autoarea, fără coordonator și fără secțiunea eliminată", {
  vechi <- setwd(RADACINA); on.exit(setwd(vechi))
  inf <- citeste_informare()
  expect_length(campuri_de_completat(inf), 0)
  expect_match(inf, TITLU_ACADEMIC, fixed = TRUE)
  expect_match(inf, "Anastasia NICEA", fixed = TRUE)
  expect_match(inf, "anastasia.nicea@s.unibuc.ro", fixed = TRUE)
  expect_match(inf, "Facultatea de Geografie", fixed = TRUE)
  expect_false(grepl("coordonat|Cum sunt folosite datele|GDPR|conform", inf, ignore.case = TRUE))
  # fără limită de vârstă (versiunea 3.1)
  expect_false(grepl("18 ani|adulț", inf))
  # păstrarea pe durată nedeterminată, accesul și prezentarea agregată
  expect_true(informare_are_pastrare(inf))
  expect_match(inf, "durată nedeterminată", fixed = TRUE)
  expect_match(inf, "nu se șterg automat", fixed = TRUE)
  expect_match(inf, "numai autoarea", fixed = TRUE)
  expect_match(inf, "agregat", fixed = TRUE)
  expect_match(inf, "nu salvează adresa IP", fixed = TRUE)
  # anonimat: ce se salvează și ce nu
  expect_match(inf, "Chestionarul este anonim", fixed = TRUE)
  expect_match(inf, "data trimiterii (fără oră)", fixed = TRUE)
  expect_match(inf, "nu folosește cookie-uri", fixed = TRUE)
  expect_false(grepl("temei|operator de date", inf, ignore.case = TRUE))
})

test_that("titlul academic exact, fără slogan", {
  expect_equal(TITLU_ACADEMIC, "Evaluarea comportamentelor populației și a nivelului de conștientizare privind gestionarea apelor uzate în municipiul Constanța")
  expect_false(exists("SLOGAN"))
  expect_equal(AUTOARE$nume, "Anastasia NICEA")
})

test_that("Q1 conține cele 42 de cartiere din HCL 79/2023, în ordine alfabetică, fără „Nu știu”", {
  expect_false(zone_sunt_exemple(Q$q01$optiuni))
  expect_length(Q$q01$optiuni, 42)
  expect_true(all(c("Tomis Nord", "Faleză Sud", "Piața Chiliei", "Badea Cârțan", "Stațiunea Mamaia", "Km 4-5") %in% Q$q01$optiuni))
  expect_false(any(grepl("[şţŞŢ]", Q$q01$optiuni)))      # fără sedile
  expect_false(any(grepl("nu.?stiu", names(Q$q01$optiuni))))
  # ordine alfabetică românească: a < ă < â, i < î, s < ș, t < ț
  cheie <- function(x) { x <- tolower(x)
    for (p in list(c("ă", "a{"), c("â", "a|"), c("î", "i{"), c("ș", "s{"), c("ț", "t{"))) x <- gsub(p[1], p[2], x, fixed = TRUE)
    x }
  et <- unname(Q$q01$optiuni)
  expect_equal(et, et[order(cheie(et), method = "radix")])
})

test_that("Q2 are din nou „Sub 18 ani”, cu același cod ca în versiunile 1–2", {
  expect_equal(names(Q$q02$optiuni), c("sub_18", "18_24", "25_34", "35_44", "45_54", "55_64", "65_plus", "prefer_nu"))
  expect_equal(unname(Q$q02$optiuni[["sub_18"]]), "Sub 18 ani")
  expect_true("sub_18" %in% names(Q$q06$campuri))
  v <- raspuns_valid(); v$q02 <- "sub_18"
  expect_null(valideaza_intrebare(Q$q02, v))
  expect_false(exists("VARSTA_MINIMA"))
})

test_that("durata estimată este setată și apare pe pagina de start", {
  expect_equal(DURATA_ESTIMATA_MINUTE, "10–15")
  h <- local({ v <- setwd(RADACINA); on.exit(setwd(v)); as.character(pagina_acasa("productie")) })
  expect_match(h, "10–15", fixed = TRUE)
  expect_false(grepl("18+", h, fixed = TRUE))
})

test_that("Q21: etichetele aprobate sunt active, scala și coloanele neschimbate", {
  expect_true("q21_toti" %in% schema_date(Q)$variabila)
  ui <- as.character(bloc_intrebare(Q$q21, mod = "productie"))
  expect_false(grepl("q21_toti", ui))
  expect_true(isTRUE(Q21_ANCORE_ACTIVE))
  expect_equal(unname(Q21_ANCORE), c("responsabilitate foarte mică", "responsabilitate foarte mare"))
  expect_match(ui, "1 = responsabilitate foarte mică", fixed = TRUE)
  expect_match(ui, "5 = responsabilitate foarte mare", fixed = TRUE)
  expect_equal(names(Q$q21$coloane), as.character(1:5))
  expect_true(all(paste0("q21_", names(Q$q21$randuri)) %in% schema_date(Q)$variabila))
  # nota pentru autoare nu mai spune că etichetele așteaptă confirmarea
  expect_false(grepl("dezactivat|confirmarea coordonatorului", Q$q21$nota_autoare))
})
