# =============================================================================
# 02_validare.R — colectarea, validarea și codificarea răspunsurilor
# -----------------------------------------------------------------------------
# Funcțiile de aici nu depind de Shiny: primesc o listă simplă de valori
# („vals”), așa cum vin din formular, și pot fi testate separat
# (tests/testthat/test-validare.R).
# =============================================================================

este_gol <- function(x) {
  is.null(x) || length(x) == 0 || all(is.na(x)) || (is.character(x) && all(!nzchar(trimws(x))))
}

# Numere afișate în stil românesc: virgulă zecimală.
format_ro <- function(x, zecimale = 2) {
  if (length(x) == 0 || is.na(x)) return("—")
  s <- formatC(round(x, zecimale), format = "f", digits = zecimale, decimal.mark = ",")
  if (grepl(",", s, fixed = TRUE)) s <- sub(",$", "", sub("0+$", "", s))
  s
}

ca_numar <- function(x) {
  if (este_gol(x)) return(NA_real_)
  if (is.character(x)) x <- gsub(",", ".", trimws(x), fixed = TRUE)
  suppressWarnings(as.numeric(x[1]))
}

este_intreg <- function(x) !is.na(x) && abs(x - round(x)) < 1e-9

# Q6 și Q9: un câmp lăsat gol înseamnă 0 (0 persoane în categorie, 0% din
# consum). Textul care nu este număr NU devine 0: rămâne NA și este respins.
CAMPURI_GOL_ESTE_ZERO <- "^q0[69]_"
numar_sau_zero <- function(x) if (este_gol(x)) 0 else ca_numar(x)

# Câmpurile numerice semnalate de browser ca invalide (validity.badInput, de
# exemplu „12abc”), trimise de www/app.js în input$campuri_invalide.
campuri_invalide <- function(v, ids) intersect(as.character(unlist(v[[".invalide"]])), ids)

# ID-urile câmpurilor de formular pentru fiecare întrebare.
id_campuri <- function(q) {
  switch(q$tip,
    numere_grup   = paste0("q06_", names(q$campuri)),
    consum_apa    = c("q08_rece", "q08_calda", "q08_nu_stiu"),
    procente      = paste0("q09_", names(q$campuri)),
    matrice       = paste0("q12_", names(q$randuri)),
    matrice_scala = paste0("q21_", names(q$randuri)),
    q$id)
}

# Citește valorile din `input` (Shiny) într-o listă simplă.
colecteaza_valori <- function(Q, input) {
  ids <- unlist(lapply(Q, id_campuri), use.names = FALSE)
  v <- stats::setNames(lapply(ids, function(i) input[[i]]), ids)
  v[[".invalide"]] <- input$campuri_invalide
  v
}

# --- validare -----------------------------------------------------------------

lista_etichete <- function(x) paste0("„", x, "”", collapse = ", ")

valideaza_intrebare <- function(q, v) {
  if (!is.null(q$conditie)) {
    if (!identical(as.character(v[[q$conditie$intrebare]]), q$conditie$valoare)) return(NULL)
  }

  switch(q$tip,

    lista = {
      x <- v[[q$id]]
      if (este_gol(x)) return("Alegeți zona din listă.")
      if (!x %in% names(q$optiuni)) return("Alegeți o zonă din listă.")
      NULL
    },

    unic = {
      x <- v[[q$id]]
      if (este_gol(x)) return(if (q$obligatorie) "Alegeți un răspuns." else NULL)
      if (!x %in% names(q$optiuni)) return("Răspunsul nu este unul dintre variantele afișate.")
      NULL
    },

    numar = {
      if (length(campuri_invalide(v, q$id))) return("Valoarea scrisă nu este un număr. Scrieți numărul de persoane, de exemplu 3.")
      x <- ca_numar(v[[q$id]])
      if (is.na(x)) return("Scrieți numărul de persoane.")
      if (!este_intreg(x)) return("Scrieți un număr întreg, de exemplu 3.")
      if (x < 1) return("Numărul trebuie să fie cel puțin 1, pentru că vă includeți și pe dumneavoastră.")
      if (x > LIMITA_PERSOANE_GOSPODARIE)
        return(paste0("Valoarea depășește ", LIMITA_PERSOANE_GOSPODARIE, " de persoane. Verificați numărul scris."))
      NULL
    },

    numere_grup = {
      ids <- paste0("q06_", names(q$campuri))
      inv <- campuri_invalide(v, ids)
      x <- vapply(ids, function(i) numar_sau_zero(v[[i]]), numeric(1))
      if (length(inv) || any(is.na(x)))
        return(paste0("Valoarea de la „", q$campuri[[sub("^q06_", "", c(inv, ids[is.na(x)])[1])]],
                      "” nu este un număr. Scrieți un număr întreg sau lăsați câmpul gol (gol = 0)."))
      if (any(x < 0) || !all(vapply(x, este_intreg, logical(1))))
        return("Folosiți numere întregi, de la 0 în sus.")
      total <- ca_numar(v[["q05"]])
      if (is.na(total) || !este_intreg(total) || total < 1)
        return("Completați mai întâi întrebarea 5 (numărul persoanelor din gospodărie).")
      if (sum(x) != total)
        return(paste0("Suma pe categorii este ", sum(x), ", iar la întrebarea 5 ați scris ", total,
                      ". Cele două numere trebuie să fie egale (câmpurile goale se socotesc 0)."))
      NULL
    },

    consum_apa = {
      if (isTRUE(v[["q08_nu_stiu"]])) return(NULL)
      if (length(campuri_invalide(v, c("q08_rece", "q08_calda"))))
        return("Una dintre valori nu este un număr. Folosiți cifre, de exemplu 12 sau 12,5.")
      rece  <- ca_numar(v[["q08_rece"]])
      calda <- ca_numar(v[["q08_calda"]])
      if (is.na(rece)) return("Scrieți consumul de apă rece sau bifați „Nu știu”.")
      if (rece < 0 || (!is.na(calda) && calda < 0)) return("Valorile nu pot fi negative.")
      if (rece > LIMITA_M3_PE_LUNA || (!is.na(calda) && calda > LIMITA_M3_PE_LUNA))
        return(paste0("Valoarea depășește ", LIMITA_M3_PE_LUNA,
                      " m³ pe lună. Verificați dacă ați scris consumul lunar, nu indexul contorului."))
      NULL
    },

    procente = {
      ids <- paste0("q09_", names(q$campuri))
      inv <- campuri_invalide(v, ids)
      x <- vapply(ids, function(i) numar_sau_zero(v[[i]]), numeric(1))
      if (length(inv) || any(is.na(x)))
        return(paste0("Valoarea de la „", q$campuri[[sub("^q09_", "", c(inv, ids[is.na(x)])[1])]],
                      "” nu este un număr. Scrieți un procent sau lăsați câmpul gol (gol = 0%)."))
      if (any(x < 0 | x > 100)) return("Fiecare procent trebuie să fie între 0 și 100.")
      if (abs(sum(x) - 100) > TOLERANTA_PROCENTE)
        return(paste0("Totalul este ", format_ro(sum(x)), "%. Procentele trebuie să însumeze 100% (câmpurile goale se socotesc 0%)."))
      NULL
    },

    multiplu = {
      x <- as.character(v[[q$id]])
      if (este_gol(x)) return("Bifați cel puțin o variantă.")
      if (!all(x %in% names(q$optiuni))) return("Una dintre variante nu este recunoscută.")
      excl <- intersect(x, q$exclusive)
      if (length(excl) > 0 && length(x) > 1)
        return(paste0("Varianta ", lista_etichete(q$optiuni[excl[1]]),
                      " nu poate fi bifată împreună cu alte variante."))
      NULL
    },

    matrice = {
      ids <- paste0("q12_", names(q$randuri))
      lipsa <- names(q$randuri)[vapply(ids, function(i) este_gol(v[[i]]), logical(1))]
      if (length(lipsa)) return(paste0("Alegeți câte o variantă pentru fiecare obiect. Lipsesc: ",
                                       paste(q$randuri[lipsa], collapse = ", "), "."))
      ok <- vapply(ids, function(i) v[[i]] %in% names(q$coloane), logical(1))
      if (!all(ok)) return("Una dintre variante nu este recunoscută.")
      NULL
    },

    matrice_scala = {
      ids <- paste0("q21_", names(q$randuri))
      gol <- vapply(ids, function(i) este_gol(v[[i]]), logical(1))
      if (q$obligatorie && any(gol))
        return(paste0("Alegeți o valoare de la 1 la 5 pentru fiecare rând. Lipsesc: ",
                      paste(q$randuri[gol], collapse = ", "), "."))
      ok <- vapply(ids[!gol], function(i) as.character(v[[i]]) %in% names(q$coloane), logical(1))
      if (!all(ok)) return("Valorile trebuie să fie între 1 și 5.")
      NULL
    },

    text = {
      x <- v[[q$id]]
      if (!este_gol(x) && nchar(x) > LUNGIME_MAXIMA_Q25)
        return(paste0("Răspunsul are ", nchar(x), " de caractere; limita este ", LUNGIME_MAXIMA_Q25, "."))
      NULL
    },

    stop("Tip de întrebare necunoscut: ", q$tip)
  )
}

# Întoarce o listă numită qid -> mesaj, doar pentru întrebările cu probleme.
valideaza_sectiune <- function(Q, s, v) {
  err <- lapply(intrebari_sectiune(Q, s), valideaza_intrebare, v = v)
  err[!vapply(err, is.null, logical(1))]
}

valideaza_tot <- function(Q, v) {
  err <- lapply(Q, valideaza_intrebare, v = v)
  err[!vapply(err, is.null, logical(1))]
}

# --- codificare ---------------------------------------------------------------

curata_text <- function(x) {
  if (este_gol(x)) return(NA_character_)
  x <- gsub("\r\n?", "\n", x, perl = TRUE)
  x <- gsub("[\\x{01}-\\x{09}\\x{0B}-\\x{1F}\\x{7F}]", " ", x, perl = TRUE)
  x <- trimws(x)
  if (!nzchar(x)) NA_character_ else substr(x, 1, LUNGIME_MAXIMA_Q25)
}

genereaza_id <- function() {
  if (requireNamespace("openssl", quietly = TRUE)) {
    paste(as.character(openssl::rand_bytes(16)), collapse = "")
  } else {
    paste(sample(c(0:9, letters[1:6]), 32, replace = TRUE), collapse = "")
  }
}

acum_utc <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

# Transformă valorile din formular într-un singur rând, cu coloanele în ordinea
# din schema_date(). Valorile lipsă rămân NA; nimic nu este transformat în 0.
# Data trimiterii salvată în baza de date (vezi PRECIZIE_DATA_TRIMITERII).
moment_trimitere <- function(t = Sys.time()) {
  if (identical(PRECIZIE_DATA_TRIMITERII, "secunda")) format(t, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  else format(t, "%Y-%m-%d", tz = "UTC")
}

codifica_raspuns <- function(Q, v, response_id, mod, submitted_at = moment_trimitere()) {
  s <- schema_date(Q)
  r <- stats::setNames(vector("list", nrow(s)), s$variabila)

  r$response_id <- response_id
  r$submitted_at <- submitted_at
  r$mod <- mod
  r$versiune_chestionar <- VERSIUNE_CHESTIONAR
  r$versiune_aplicatie <- VERSIUNE_APLICATIE
  r$consimtamant <- 1L
  r$varsta_minima_confirmata <- NA_integer_   # confirmarea vârstei nu se mai cere din versiunea 3.1

  val_cod <- function(x, permise) if (este_gol(x) || !x %in% permise) NA_character_ else as.character(x)

  for (q in Q) {
    switch(q$tip,
      lista = , unic = { r[[q$var]] <- val_cod(v[[q$id]], names(q$optiuni)) },
      numar = { x <- ca_numar(v[[q$id]]); r[[q$var]] <- if (is.na(x)) NA_integer_ else as.integer(round(x)) },
      numere_grup = for (k in names(q$campuri)) {
        x <- numar_sau_zero(v[[paste0("q06_", k)]])     # gol = 0 persoane
        r[[paste0("q06_", k)]] <- if (is.na(x)) NA_integer_ else as.integer(round(x))
      },
      consum_apa = {
        nu_stiu <- isTRUE(v[["q08_nu_stiu"]])
        r$q08_nu_stiu <- as.integer(nu_stiu)
        r$q08_apa_rece_m3  <- if (nu_stiu) NA_real_ else ca_numar(v[["q08_rece"]])
        r$q08_apa_calda_m3 <- if (nu_stiu) NA_real_ else ca_numar(v[["q08_calda"]])
      },
      procente = for (k in names(q$campuri)) r[[paste0("q09_", k)]] <- numar_sau_zero(v[[paste0("q09_", k)]]),  # gol = 0%
      multiplu = {
        afisata <- is.null(q$conditie) ||
          identical(as.character(v[[q$conditie$intrebare]]), q$conditie$valoare)
        sel <- as.character(v[[q$id]])
        for (k in names(q$optiuni)) {
          r[[paste0(q$id, "_", k)]] <- if (afisata) as.integer(k %in% sel) else NA_integer_
        }
        if (!is.null(q$conditie)) r$q20_afisata <- as.integer(afisata)
      },
      matrice = for (k in names(q$randuri)) {
        r[[paste0("q12_", k)]] <- val_cod(v[[paste0("q12_", k)]], names(q$coloane))
      },
      matrice_scala = {
        for (k in names(q$randuri)) {
          x <- val_cod(v[[paste0("q21_", k)]], names(q$coloane))
          r[[paste0("q21_", k)]] <- if (is.na(x)) NA_integer_ else as.integer(x)
        }
        r$q21_toti <- NA_integer_   # caseta a fost eliminată în v3; coloana rămâne pentru răspunsurile vechi
      },
      text = { r[[q$var]] <- curata_text(v[[q$id]]) }
    )
  }

  # tipuri corecte pentru fiecare coloană
  for (i in seq_len(nrow(s))) {
    nm <- s$variabila[i]; x <- r[[nm]]
    r[[nm]] <- switch(s$tip_sqlite[i],
      INTEGER = if (is.null(x)) NA_integer_ else as.integer(x),
      REAL    = if (is.null(x)) NA_real_ else as.numeric(x),
      TEXT    = if (is.null(x)) NA_character_ else as.character(x))
  }
  as.data.frame(r, stringsAsFactors = FALSE, check.names = FALSE)
}

# Răspunsul codificat, ca text lizibil, pentru pagina de revizuire.
text_raspuns <- function(q, rec) {
  da <- function(x) !is.na(x) && x == 1
  switch(q$tip,
    lista = , unic = { x <- rec[[q$var]]; if (is.na(x)) "—" else unname(q$optiuni[[x]]) },
    numar = { x <- rec[[q$var]]; if (is.na(x)) "—" else paste(x, q$unitate) },
    numere_grup = paste0(q$campuri, ": ", vapply(names(q$campuri), function(k) {
      x <- rec[[paste0("q06_", k)]]; if (is.na(x)) "—" else as.character(x) }, ""), collapse = "\n"),
    consum_apa = {
      if (da(rec$q08_nu_stiu)) "Nu știu" else paste0(
        "Apă rece: ", format_ro(rec$q08_apa_rece_m3), " m³/lună\n",
        "Apă caldă: ", if (is.na(rec$q08_apa_calda_m3)) "necompletat" else paste0(format_ro(rec$q08_apa_calda_m3), " m³/lună"))
    },
    procente = paste0(q$campuri, ": ", vapply(names(q$campuri), function(k)
      paste0(format_ro(rec[[paste0("q09_", k)]]), "%"), ""), collapse = "\n"),
    multiplu = {
      if (!is.null(q$conditie) && !da(rec$q20_afisata)) return("Nu este cazul (la întrebarea 19 nu ați răspuns „Da”).")
      sel <- names(q$optiuni)[vapply(names(q$optiuni), function(k) da(rec[[paste0(q$id, "_", k)]]), logical(1))]
      if (!length(sel)) "—" else paste(q$optiuni[sel], collapse = "\n")
    },
    matrice = paste0(q$randuri, ": ", vapply(names(q$randuri), function(k) {
      x <- rec[[paste0("q12_", k)]]; if (is.na(x)) "—" else unname(q$coloane[[x]]) }, ""), collapse = "\n"),
    matrice_scala = {
      t <- paste0(q$randuri, ": ", vapply(names(q$randuri), function(k) {
        x <- rec[[paste0("q21_", k)]]; if (is.na(x)) "—" else as.character(x) }, ""), collapse = "\n")
      t
    },
    text = { x <- rec[[q$var]]; if (is.na(x)) "Fără răspuns (opțional)" else x }
  )
}
