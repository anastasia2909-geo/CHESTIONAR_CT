# =============================================================================
# 05_date_test.R — răspunsuri sintetice pentru modul test
# -----------------------------------------------------------------------------
# Datele sunt generate aleatoriu și respectă regulile de validare. Nu provin de
# la persoane reale și nu trebuie folosite în analiză.
# =============================================================================

genereaza_valori_sintetice <- function(Q, n = 30, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  alege <- function(o, k = 1) sample(names(o), k)
  lapply(seq_len(n), function(i) {
    v <- list()
    for (q in Q) {
      switch(q$tip,
        lista = , unic = { v[[q$id]] <- alege(q$optiuni) },
        numar = { v$q05 <- sample(1:6, 1, prob = c(.15, .3, .25, .2, .07, .03)) },
        numere_grup = {
          k <- names(q$campuri)
          cnt <- tabulate(sample(seq_along(k), v$q05, replace = TRUE), nbins = length(k))
          # unele categorii cu 0 persoane sunt lăsate goale (gol = 0 din v3)
          for (j in seq_along(k)) v[[paste0("q06_", k[j])]] <- if (cnt[j] == 0 && stats::runif(1) < 0.5) NA else cnt[j]
        },
        consum_apa = {
          if (stats::runif(1) < 0.25) {
            v$q08_nu_stiu <- TRUE; v$q08_rece <- NA; v$q08_calda <- NA
          } else {
            v$q08_nu_stiu <- FALSE
            v$q08_rece <- round(stats::runif(1, 2, 6) * v$q05, 1)
            v$q08_calda <- if (stats::runif(1) < 0.5) round(stats::runif(1, 0.5, 2) * v$q05, 1) else NA
          }
        },
        procente = {
          k <- names(q$campuri)
          w <- stats::rgamma(length(k), shape = c(4, 2, 1.5, 1, 1, 3, 0.6))
          p <- round(100 * w / sum(w))
          p[which.max(p)] <- p[which.max(p)] + (100 - sum(p))
          for (j in seq_along(k)) v[[paste0("q09_", k[j])]] <- if (p[j] == 0 && stats::runif(1) < 0.5) NA else p[j]
        },
        multiplu = {
          if (!is.null(q$conditie) && !identical(v[[q$conditie$intrebare]], q$conditie$valoare)) {
            v[[q$id]] <- NULL
          } else {
            normale <- setdiff(names(q$optiuni), q$exclusive)
            if (length(q$exclusive) && stats::runif(1) < 0.15) v[[q$id]] <- sample(q$exclusive, 1)
            else v[[q$id]] <- sample(normale, sample(1:min(3, length(normale)), 1))
          }
        },
        matrice = for (k in names(q$randuri)) {
          v[[paste0("q12_", k)]] <- sample(names(q$coloane), 1,
                                           prob = c(.08, .05, .07, .05, .7, .05))
        },
        matrice_scala = {
          for (k in names(q$randuri)) v[[paste0("q21_", k)]] <- as.character(sample(1:5, 1, prob = c(.05, .1, .2, .3, .35)))
        },
        text = {
          v$q25 <- sample(c("", "", "", "Text de test generat automat.",
                            "Exemplu sintetic: mai multe puncte de colectare."), 1)
        }
      )
    }
    v
  })
}

# Generează și salvează n răspunsuri sintetice în baza de date de TEST.
insereaza_date_test <- function(Q, cale, n = 30, seed = NULL) {
  if (!este_stocare_test(cale)) stop("Datele sintetice se scriu numai în baza de test.")
  initializeaza_db(cale, schema_date(Q))
  vals <- genereaza_valori_sintetice(Q, n, seed)
  momente <- Sys.time() - sort(stats::runif(n, 0, 14 * 86400), decreasing = TRUE)
  for (i in seq_along(vals)) {
    err <- valideaza_tot(Q, vals[[i]])
    if (length(err)) stop("Date sintetice invalide (", names(err)[1], "): ", err[[1]])
    rec <- codifica_raspuns(Q, vals[[i]], genereaza_id(), "test",
                            moment_trimitere(momente[i]))
    salveaza_raspuns(cale, rec)
  }
  invisible(length(vals))
}
