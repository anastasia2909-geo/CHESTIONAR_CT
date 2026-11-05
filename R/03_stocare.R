# =============================================================================
# 03_stocare.R — salvarea răspunsurilor (SQLite sau PostgreSQL)
# -----------------------------------------------------------------------------
# Fiecare trimitere adaugă un rând în tabela răspunsurilor. Cheia primară
# `response_id` face imposibilă salvarea de două ori a aceleiași completări
# (de exemplu, la dublu-click). Conexiunea se deschide și se închide la fiecare
# operație.
#
# „cale” este locul răspunsurilor, întors de cale_baza_date():
#   - calea unui fișier SQLite (implicit, pe calculatorul propriu);
#   - "postgres:<tabela>" când CHESTIONAR_DB_URL este setată (la găzduire).
#     Adresa și parola bazei nu apar niciodată în „cale”, în mesaje sau în
#     pagina de administrare.
# Nicio funcție de aici nu șterge sau rescrie răspunsuri reale. Singura
# ștergere este sterge_date_test(), care refuză orice altă bază decât cea de test.
# =============================================================================

TABELA <- "raspunsuri"   # numele tabelei în fișierele SQLite
PREFIX_PG <- "postgres:"

este_postgres <- function(cale) startsWith(cale, PREFIX_PG)

tabela_din <- function(cale) {
  if (este_postgres(cale)) substring(cale, nchar(PREFIX_PG) + 1) else TABELA
}

este_stocare_test <- function(cale) {
  if (este_postgres(cale)) identical(tabela_din(cale), TABELA_PG_TEST)
  else grepl("_TEST\\.sqlite$", basename(cale))
}

# Numele scurt, afișat în pagina de administrare.
nume_stocare <- function(cale) {
  if (este_postgres(cale)) paste0("tabela ", tabela_din(cale)) else basename(cale)
}

# Gazda și baza din adresa PostgreSQL, fără utilizator și parolă.
gazda_postgres <- function(url = url_postgres()) {
  p <- tryCatch(parametri_postgres(url), error = function(e) NULL)
  if (is.null(p$host)) return(NA_character_)
  paste0(p$host, if (!is.null(p$dbname)) paste0(", baza ", p$dbname) else "")
}

descriere_stocare <- function(cale) {
  if (!este_postgres(cale)) return(cale)
  g <- gazda_postgres()
  paste0("PostgreSQL, tabela ", tabela_din(cale), if (!is.na(g)) paste0(" (", g, ")") else "")
}

# Desface adresa postgresql://utilizator:parola@gazda:port/baza?param=val în
# parametrii ceruți de RPostgres (care nu acceptă adresa întreagă).
parametri_postgres <- function(url) {
  m <- regmatches(url, regexec("^postgres(?:ql)?://(?:([^:@/]*)(?::([^@/]*))?@)?([^/:?]*)(?::([0-9]+))?(?:/([^?]*))?(?:\\?(.*))?$", url, perl = TRUE))[[1]]
  if (!length(m)) stop("CHESTIONAR_DB_URL nu are forma postgresql://utilizator:parola@gazda/baza.", call. = FALSE)
  dec <- function(x) utils::URLdecode(x)
  p <- list(user = dec(m[2]), password = dec(m[3]), host = dec(m[4]), port = m[5], dbname = dec(m[6]))
  if (nzchar(m[7])) {
    for (kv in strsplit(m[7], "&", fixed = TRUE)[[1]]) {
      if (!nzchar(kv)) next
      i <- regexpr("=", kv, fixed = TRUE)
      if (i < 0) next
      p[[dec(substr(kv, 1, i - 1))]] <- dec(substring(kv, i + 1))
    }
  }
  p[vapply(p, function(v) length(v) == 1 && !is.na(v) && nzchar(v), logical(1))]
}

conecteaza_postgres <- function(incercari = 3) {
  if (!requireNamespace("RPostgres", quietly = TRUE)) {
    stop("CHESTIONAR_DB_URL este setată, dar pachetul RPostgres nu este instalat: install.packages(\"RPostgres\").", call. = FALSE)
  }
  url <- url_postgres()
  if (!nzchar(url)) stop("CHESTIONAR_DB_URL nu este setată.", call. = FALSE)
  # O bază care „doarme” (de exemplu, Neon după 5 minute fără activitate) se
  # trezește la prima conexiune; de aceea se mai încearcă de două ori.
  p <- parametri_postgres(url)
  if (is.null(p$connect_timeout)) p$connect_timeout <- "20"
  if (is.null(p$application_name)) p$application_name <- "chestionar"
  for (i in seq_len(incercari)) {
    con <- tryCatch(do.call(DBI::dbConnect, c(list(RPostgres::Postgres(), bigint = "integer"), p)),
                    error = function(e) e)
    if (!inherits(con, "error")) return(con)
    if (i < incercari) Sys.sleep(2 * i)
  }
  # Mesajul driverului nu conține parola; se păstrează doar prima lui linie.
  stop("Nu mă pot conecta la baza PostgreSQL: ", strsplit(conditionMessage(con), "\n")[[1]][1], call. = FALSE)
}

deschide_db <- function(cale) {
  if (este_postgres(cale)) return(conecteaza_postgres())
  con <- DBI::dbConnect(RSQLite::SQLite(), cale)
  DBI::dbExecute(con, "PRAGMA busy_timeout = 10000")
  DBI::dbExecute(con, "PRAGMA synchronous = FULL")
  con
}

tip_coloana <- function(tip_sqlite, pg) {
  if (!pg) return(tip_sqlite)
  unname(c(TEXT = "TEXT", INTEGER = "INTEGER", REAL = "DOUBLE PRECISION")[tip_sqlite])
}

initializeaza_db <- function(cale, schema) {
  pg <- este_postgres(cale)
  tab <- tabela_din(cale)
  con <- deschide_db(cale)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  tipuri <- tip_coloana(schema$tip_sqlite, pg)
  if (!DBI::dbExistsTable(con, tab)) {
    cols <- sprintf('"%s" %s', schema$variabila, tipuri)
    cols[schema$variabila == "response_id"] <- '"response_id" TEXT PRIMARY KEY NOT NULL'
    DBI::dbExecute(con, sprintf("CREATE TABLE %s%s (%s)", if (pg) "IF NOT EXISTS " else "",
                                tab, paste(cols, collapse = ", ")))
  } else {
    # Dacă s-au adăugat variabile noi în chestionar, se adaugă coloanele lipsă.
    # Coloanele vechi nu se șterg niciodată automat.
    existente <- DBI::dbListFields(con, tab)
    lipsa <- which(!schema$variabila %in% existente)
    for (i in lipsa) {
      DBI::dbExecute(con, sprintf('ALTER TABLE %s ADD COLUMN %s"%s" %s', tab, if (pg) "IF NOT EXISTS " else "",
                                  schema$variabila[i], tipuri[i]))
    }
  }
  invisible(cale)
}

este_eroare_duplicat <- function(e) {
  m <- conditionMessage(e)
  grepl("UNIQUE constraint failed", m, fixed = TRUE) ||          # SQLite
    grepl("duplicate key value violates unique constraint", m, fixed = TRUE)   # PostgreSQL
}

# Întoarce "ok" sau "duplicat"; alte erori sunt transmise mai departe.
salveaza_raspuns <- function(cale, rec) {
  stopifnot(is.data.frame(rec), nrow(rec) == 1, nzchar(rec$response_id))
  con <- deschide_db(cale)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  tryCatch({
    DBI::dbWithTransaction(con, DBI::dbAppendTable(con, tabela_din(cale), rec))
    "ok"
  }, error = function(e) {
    if (este_eroare_duplicat(e)) "duplicat" else stop(e)
  })
}

# TRUE dacă baza (fișierul sau tabela) există.
exista_baza <- function(cale) {
  if (!este_postgres(cale)) return(file.exists(cale))
  con <- deschide_db(cale)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  DBI::dbExistsTable(con, tabela_din(cale))
}

citeste_raspunsuri <- function(cale, schema = NULL) {
  if (!este_postgres(cale) && !file.exists(cale)) return(data.frame())
  con <- deschide_db(cale)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  tab <- tabela_din(cale)
  if (!DBI::dbExistsTable(con, tab)) return(data.frame())
  df <- DBI::dbGetQuery(con, sprintf("SELECT * FROM %s ORDER BY submitted_at", tab))
  if (!is.null(schema)) {
    ordine <- c(intersect(schema$variabila, names(df)), setdiff(names(df), schema$variabila))
    df <- df[, ordine, drop = FALSE]
  }
  df
}

numar_raspunsuri <- function(cale) {
  if (!este_postgres(cale) && !file.exists(cale)) return(0L)
  con <- deschide_db(cale)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  tab <- tabela_din(cale)
  if (!DBI::dbExistsTable(con, tab)) return(0L)
  as.integer(DBI::dbGetQuery(con, sprintf("SELECT COUNT(*) AS n FROM %s", tab))$n)
}

# Semnătura folosită de pagina de administrare ca să afle dacă s-a schimbat ceva:
# data modificării fișierului (SQLite) sau numărul de rânduri și ultima dată (PostgreSQL).
semnatura_baza <- function(cale) {
  if (!este_postgres(cale)) return(if (file.exists(cale)) file.info(cale)$mtime else 0)
  tryCatch({
    con <- deschide_db(cale)
    on.exit(DBI::dbDisconnect(con), add = TRUE)
    tab <- tabela_din(cale)
    if (!DBI::dbExistsTable(con, tab)) return("fara-tabela")
    r <- DBI::dbGetQuery(con, sprintf("SELECT COUNT(*) AS n, MAX(submitted_at) AS m FROM %s", tab))
    paste(r$n, r$m)
  }, error = function(e) paste("eroare", Sys.time()))
}

# Verifică dacă aplicația poate scrie răspunsuri. Întoarce list(ok, detalii).
verifica_scrierea <- function(cale) {
  if (!este_postgres(cale)) {
    ok <- tryCatch(file.access(dirname(cale), 2) == 0, error = function(e) FALSE)
    return(list(ok = isTRUE(ok), detalii = dirname(cale)))
  }
  tryCatch({
    con <- deschide_db(cale)
    on.exit(DBI::dbDisconnect(con), add = TRUE)
    tab <- tabela_din(cale)
    if (!DBI::dbExistsTable(con, tab)) return(list(ok = FALSE, detalii = paste0(descriere_stocare(cale), ": tabela nu există.")))
    drept <- DBI::dbGetQuery(con, "SELECT has_table_privilege($1, 'INSERT') AS d", params = list(tab))$d
    list(ok = isTRUE(drept), detalii = paste0(descriere_stocare(cale), if (isTRUE(drept)) ": conexiune reușită, scrierea este permisă." else ": utilizatorul nu are drept de scriere."))
  }, error = function(e) list(ok = FALSE, detalii = conditionMessage(e)))
}

# Șterge DOAR baza de date de test. Refuză orice altă bază.
sterge_date_test <- function(cale) {
  if (!este_stocare_test(cale)) {
    stop("Refuz: ștergerea este permisă numai pentru baza de date de test (*_TEST.sqlite sau tabela ", TABELA_PG_TEST, ").")
  }
  if (!este_postgres(cale) && !file.exists(cale)) return(0L)
  con <- deschide_db(cale)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  tab <- tabela_din(cale)
  if (!DBI::dbExistsTable(con, tab)) return(0L)
  n <- DBI::dbExecute(con, sprintf("DELETE FROM %s", tab))
  if (!este_postgres(cale)) DBI::dbExecute(con, "VACUUM")
  as.integer(n)
}

# Copie de siguranță într-un fișier SQLite.
#  - SQLite: API-ul de backup SQLite, sigur și cât timp aplicația rulează.
#  - PostgreSQL: toate rândurile tabelei sunt scrise într-un fișier SQLite nou,
#    cu tabela `raspunsuri` (aceeași structură ca baza locală). Fișierul se poate
#    deschide în aplicație pe calculatorul propriu (CHESTIONAR_DATA_DIR).
#    Copia se verifică: numărul de rânduri trebuie să fie același.
copie_de_siguranta <- function(cale, destinatie, schema = NULL) {
  dir.create(dirname(destinatie), recursive = TRUE, showWarnings = FALSE)
  if (!este_postgres(cale)) {
    if (!file.exists(cale)) stop("Baza de date nu există: ", cale)
    from <- deschide_db(cale)
    to <- DBI::dbConnect(RSQLite::SQLite(), destinatie)
    on.exit({ DBI::dbDisconnect(from); DBI::dbDisconnect(to) }, add = TRUE)
    RSQLite::sqliteCopyDatabase(from, to)
    return(invisible(destinatie))
  }
  if (file.exists(destinatie) && file.size(destinatie) > 0) stop("Fișierul de destinație există deja: ", destinatie)
  df <- citeste_raspunsuri(cale, schema)
  if (!is.null(schema)) initializeaza_db(destinatie, schema)
  to <- DBI::dbConnect(RSQLite::SQLite(), destinatie)
  on.exit(DBI::dbDisconnect(to), add = TRUE)
  if (DBI::dbExistsTable(to, TABELA)) {
    if (nrow(df)) DBI::dbWithTransaction(to, DBI::dbAppendTable(to, TABELA, df))
  } else {
    DBI::dbWriteTable(to, TABELA, df)
  }
  n <- as.integer(DBI::dbGetQuery(to, sprintf("SELECT COUNT(*) AS n FROM %s", TABELA))$n)
  if (n != nrow(df)) stop("Copia nu are același număr de rânduri (", n, " față de ", nrow(df), ").")
  invisible(destinatie)
}
