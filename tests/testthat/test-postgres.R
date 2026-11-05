# Teste pentru stocarea în PostgreSQL. Rulează numai dacă CHESTIONAR_TEST_PG_URL
# are adresa unei baze de probă, de exemplu:
#   CHESTIONAR_TEST_PG_URL=postgresql://pg@127.0.0.1:5499/chestionar
# Fiecare rulare lucrează într-o schemă nouă (test_automat_...), ștearsă la final;
# tabelele din schema obișnuită (public) nu sunt atinse.

url_test_pg <- function() Sys.getenv("CHESTIONAR_TEST_PG_URL", "")

cu_postgres <- function(cod) {
  skip_if(!nzchar(url_test_pg()), "CHESTIONAR_TEST_PG_URL nu este setată")
  skip_if_not_installed("RPostgres")
  schema_pg <- paste0("test_automat_", format(Sys.time(), "%H%M%S"), sample(1000:9999, 1))
  admin <- do.call(DBI::dbConnect, c(list(RPostgres::Postgres()), parametri_postgres(url_test_pg())))
  DBI::dbExecute(admin, sprintf("CREATE SCHEMA %s", schema_pg))
  sep <- if (grepl("?", url_test_pg(), fixed = TRUE)) "&" else "?"
  Sys.setenv(CHESTIONAR_DB_URL = paste0(url_test_pg(), sep, "options=-csearch_path%3D", schema_pg))
  on.exit({
    Sys.unsetenv("CHESTIONAR_DB_URL")
    DBI::dbExecute(admin, sprintf("DROP SCHEMA %s CASCADE", schema_pg))
    DBI::dbDisconnect(admin)
  })
  cod(schema_pg, admin)
}

test_that("cu CHESTIONAR_DB_URL, locul răspunsurilor este o tabelă PostgreSQL, separată pe moduri", {
  cu_postgres(function(sch, admin) {
    expect_equal(cale_baza_date("productie"), "postgres:raspunsuri")
    expect_equal(cale_baza_date("test"), "postgres:raspunsuri_test")
    expect_true(este_stocare_test("postgres:raspunsuri_test"))
    expect_false(este_stocare_test("postgres:raspunsuri"))
    # Descrierea nu conține utilizatorul sau parola.
    Sys.setenv(CHESTIONAR_DB_URL = "postgresql://ana:secret123@ep-x.eu-central-1.aws.neon.tech/neondb?sslmode=require")
    d <- descriere_stocare("postgres:raspunsuri")
    expect_match(d, "ep-x.eu-central-1.aws.neon.tech, baza neondb", fixed = TRUE)
    expect_false(grepl("secret123|ana", d))
  })
  expect_match(cale_baza_date("test"), "_TEST\\.sqlite$")   # fără variabilă: SQLite
})

test_that("PostgreSQL: salvare, duplicat, citire, coloane noi, ca pe SQLite", {
  cu_postgres(function(sch, admin) {
    cale <- cale_baza_date("test"); s <- schema_date(Q)
    initializeaza_db(cale, s[s$variabila != "q25_sugestie", ])
    initializeaza_db(cale, s)                       # adaugă coloana lipsă
    initializeaza_db(cale, s)                       # a doua pornire nu schimbă nimic
    expect_true(DBI::dbExistsTable(admin, DBI::Id(schema = sch, table = "raspunsuri_test")))
    r <- codifica_raspuns(Q, raspuns_valid(), genereaza_id(), "test")
    expect_equal(salveaza_raspuns(cale, r), "ok")
    expect_equal(salveaza_raspuns(cale, r), "duplicat")
    expect_equal(numar_raspunsuri(cale), 1L)
    df <- citeste_raspunsuri(cale, s)
    expect_equal(names(df), s$variabila)
    expect_equal(df$q12_medicamente, "nu_am_aruncat")
    expect_true(is.na(df$q08_apa_calda_m3))
    expect_equal(df$q08_apa_rece_m3, 10.5)
    expect_type(df$q05_nr_persoane, "integer")
    # Valorile citite din PostgreSQL sunt aceleași cu cele salvate în SQLite.
    lite <- tempfile(fileext = "_TEST.sqlite"); on.exit(unlink(lite), add = TRUE)
    initializeaza_db(lite, s); salveaza_raspuns(lite, r)
    expect_equal(citeste_raspunsuri(lite, s), df, ignore_attr = TRUE)
  })
})

test_that("PostgreSQL: datele de test se șterg numai din tabela de test; copia SQLite e completă", {
  cu_postgres(function(sch, admin) {
    s <- schema_date(Q)
    reala <- cale_baza_date("productie"); test <- cale_baza_date("test")
    initializeaza_db(reala, s)
    salveaza_raspuns(reala, codifica_raspuns(Q, raspuns_valid(), genereaza_id(), "productie"))
    insereaza_date_test(Q, test, 7, seed = 3)
    expect_error(insereaza_date_test(Q, reala, 2), "baza de test")
    expect_error(sterge_date_test(reala), "Refuz")
    expect_equal(numar_raspunsuri(reala), 1L)
    dest <- tempfile(fileext = ".sqlite"); on.exit(unlink(dest), add = TRUE)
    copie_de_siguranta(test, dest, s)
    expect_equal(numar_raspunsuri(dest), 7L)
    expect_equal(citeste_raspunsuri(dest, s), citeste_raspunsuri(test, s), ignore_attr = TRUE)
    expect_error(copie_de_siguranta(test, dest, s), "există deja")
    expect_equal(sterge_date_test(test), 7L)
    expect_equal(numar_raspunsuri(test), 0L)
    expect_equal(numar_raspunsuri(reala), 1L)
  })
})

test_that("PostgreSQL: fila „Stare” arată baza și găzduirea în regulă", {
  cu_postgres(function(sch, admin) {
    cale <- cale_baza_date("productie"); initializeaza_db(cale, schema_date(Q))
    vechi <- setwd(RADACINA); on.exit(setwd(vechi), add = TRUE)
    v <- verificari_configurare(Q, "productie", cale)
    expect_equal(v$stare[v$element == "Baza de date PostgreSQL poate fi scrisă"], "ok")
    expect_equal(v$stare[v$element == "Găzduirea"], "ok")
    expect_match(semnatura_baza(cale), "^0 ")
  })
})

test_that("PostgreSQL: o adresă greșită dă un mesaj fără parolă", {
  skip_if_not_installed("RPostgres")
  Sys.setenv(CHESTIONAR_DB_URL = "postgresql://ana:secret123@127.0.0.1:1/nimic?connect_timeout=2")
  on.exit(Sys.unsetenv("CHESTIONAR_DB_URL"))
  expect_equal(parametri_postgres("postgresql://an%40a:p%26w@h.example:6543/db?sslmode=require&channel_binding=require"),
               list(user = "an@a", password = "p&w", host = "h.example", port = "6543", dbname = "db",
                    sslmode = "require", channel_binding = "require"))
  e <- tryCatch(numar_raspunsuri("postgres:raspunsuri"), error = function(e) conditionMessage(e))
  expect_match(e, "Nu mă pot conecta")
  expect_false(grepl("secret123", e))
  v <- verifica_scrierea("postgres:raspunsuri")
  expect_false(v$ok)
  expect_false(grepl("secret123", v$detalii))
})
