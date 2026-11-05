# =============================================================================
# 12_indicatori.R — indicatorii tematici pe cartiere (harta tematică)
# -----------------------------------------------------------------------------
# Indicatorii descriu EȘANTIONUL de respondenți și comportamentele DECLARATE de
# aceștia. Nu măsoară poluarea reală și nu clasifică cartierele. Definițiile
# complete (numărător, numitor, valori lipsă, prag) sunt în
# docs/INDICATORI_HARTA.md; orice modificare aici trebuie reflectată acolo.
#
# Funcțiile sunt pure (primesc un data.frame cu răspunsuri) și sunt testate în
# tests/testthat/test-indicatori.R.
# =============================================================================

# Paletă secvențială: mai închis = valoare mai mare (crem -> bleumarin).
PALETA_TEMATICA <- c("#9FB7D3", "#7596BD", "#4F74A3", "#2D5486", "#11305C")   # validată: o singură nuanță, luminozitate monotonă, capătul deschis ≥ 2:1 față de fundal
CULOARE_FARA_DATE <- "#E7E2D8"     # 0 respondenți / fără numitor
CULOARE_SUPRIMAT  <- "#D9D3C6"     # date insuficiente (sub prag); hașurat în hartă

# Clase fixe pentru procente (aceleași pentru toți indicatorii, ca o culoare
# să aibă mereu același sens). De revizuit metodologic.
CLASE_PROCENT <- list(limite = c(0, 10, 20, 35, 50, 100.0001),
                      etichete = c("0–9%", "10–19%", "20–34%", "35–49%", "50–100%"))
# Clase pentru numărul de respondenți (prima clasă, 1–4, nu arată valoarea exactă).
CLASE_NUMAR <- list(limite = c(1, 5, 10, 25, 50, Inf),
                    etichete = c("1–4", "5–9", "10–24", "25–49", "50 sau mai mulți"))

INDICATORI_HARTA <- list(
  nr_respondenti = list(
    titlu = "Numărul de respondenți",
    unitate = "respondenți",
    tip = "numar",
    intrebare = "Q1",
    descriere = paste("Câte completări valide indică acest cartier la întrebarea 1.",
                      "Arată participarea la chestionar, nu poluarea sau comportamentul locuitorilor.")),
  ulei_chiuveta = list(
    titlu = "Uleiul uzat turnat în chiuvetă sau toaletă",
    unitate = "% din respondenți",
    tip = "procent",
    intrebare = "Q13",
    descriere = paste("Procentul respondenților care au ales „Îl torn în chiuvetă/toaletă” la întrebarea 13,",
                      "din respondenții care folosesc ulei (fără „Nu folosesc ulei”).")),
  q12_oricare = list(
    titlu = "Cel puțin un obiect aruncat în toaletă (Q12)",
    unitate = "% din respondenți",
    tip = "procent",
    intrebare = "Q12",
    descriere = paste("Procentul respondenților care au indicat un motiv pentru cel puțin unul dintre cele 8 obiecte",
                      "de la întrebarea 12 (ultimele 30 de zile). Nu este numărul de obiecte ajunse în canalizare.")),
  q12_servetele = list(
    titlu = "Șervețele umede aruncate în toaletă (Q12)",
    unitate = "% din respondenți",
    tip = "procent",
    intrebare = "Q12",
    descriere = paste("Procentul respondenților care au indicat un motiv pentru „Șervețele umede” la întrebarea 12,",
                      "din cei care au răspuns pentru acest obiect (fără „Prefer să nu răspund”)."))
)

# Răspunsurile folosite: modul curent, cu acord, cu cartier valid.
filtreaza_valide <- function(df, mod = NULL) {
  if (!nrow(df)) return(df)
  ok <- !is.na(df$q01_zona) & !is.na(df$consimtamant) & df$consimtamant == 1
  if (!is.null(mod) && "mod" %in% names(df)) ok <- ok & df$mod == mod
  df[ok, , drop = FALSE]
}

# Numărătorul și numitorul pentru fiecare respondent și indicator (vectori
# logici; NA în numitor = exclus).
contributii <- function(Q, df) {
  q12 <- as.matrix(df[, paste0("q12_", names(Q$q12$randuri)), drop = FALSE])
  are_motiv   <- rowSums(matrix(q12 %in% MOTIVE_ARUNCAT, nrow = nrow(q12))) > 0
  toate_nu    <- rowSums(matrix(q12 == "nu_am_aruncat", nrow = nrow(q12)), na.rm = TRUE) == ncol(q12)
  serv <- df$q12_servetele_umede
  list(
    nr_respondenti = list(num = rep(TRUE, nrow(df)), den = rep(TRUE, nrow(df))),
    ulei_chiuveta  = list(num = df$q13_ulei %in% "chiuveta_toaleta",
                          den = !is.na(df$q13_ulei) & df$q13_ulei != "nu_folosesc"),
    q12_oricare    = list(num = are_motiv,
                          den = are_motiv | toate_nu),          # exclus: fără motiv, dar cu „Prefer să nu răspund”
    q12_servetele  = list(num = serv %in% MOTIVE_ARUNCAT,
                          den = serv %in% c(MOTIVE_ARUNCAT, "nu_am_aruncat"))
  )
}

clasa_valoare <- function(x, clase) {
  i <- findInterval(x, clase$limite, left.open = FALSE, rightmost.closed = TRUE)
  ifelse(is.na(x) | i < 1 | i > length(clase$etichete), NA_integer_, as.integer(i))
}

# Calculează toți indicatorii pe cartiere.
#   cartiere: data.frame cu cod și denumire (cele 42 de cartiere)
# Întoarce o listă: total, nealocate, activ, indicatori (câte un data.frame).
calculeaza_indicatori <- function(Q, df, cartiere, mod = NULL,
                                  prag_total = HARTA_PRAG_TOTAL,
                                  prag_cartier = HARTA_PRAG_CARTIER,
                                  prag_numar = HARTA_PRAG_NUMAR) {
  df <- filtreaza_valide(df, mod)
  cunoscute <- df$q01_zona %in% cartiere$cod
  out <- list(total = nrow(df), nealocate = sum(!cunoscute),
              activ = nrow(df) >= prag_total, indicatori = list(),
              prag_cartier = prag_cartier, prag_numar = prag_numar, prag_total = prag_total)
  df <- df[cunoscute, , drop = FALSE]
  if (!out$activ) return(out)
  ctr <- if (nrow(df)) contributii(Q, df) else NULL

  for (id in names(INDICATORI_HARTA)) {
    ind <- INDICATORI_HARTA[[id]]
    rows <- lapply(seq_len(nrow(cartiere)), function(i) {
      cod <- cartiere$cod[i]
      in_c <- if (nrow(df)) df$q01_zona == cod else logical(0)
      den <- if (nrow(df)) sum(ctr[[id]]$den[in_c], na.rm = TRUE) else 0L
      num <- if (nrow(df)) sum(ctr[[id]]$num[in_c] & ctr[[id]]$den[in_c], na.rm = TRUE) else 0L
      if (identical(ind$tip, "numar")) {
        n <- den
        stare <- if (n == 0) "zero" else if (n < prag_numar) "suprimat" else "valoare"
        valoare <- if (stare == "valoare") n else NA_real_
        clasa <- if (n == 0) NA_integer_ else clasa_valoare(n, CLASE_NUMAR)
        eticheta <- switch(stare, zero = "0 respondenți",
                           suprimat = paste0("sub ", prag_numar, " respondenți"),
                           valoare = paste(n, "respondenți"))
        data.frame(cod = cod, numarator = NA_integer_, numitor = if (stare == "valoare") n else NA_integer_,
                   valoare = valoare, stare = stare, clasa = clasa, eticheta = eticheta, stringsAsFactors = FALSE)
      } else {
        stare <- if (den == 0) "fara_date" else if (den < prag_cartier) "suprimat" else "valoare"
        valoare <- if (stare == "valoare") 100 * num / den else NA_real_
        eticheta <- switch(stare,
                           fara_date = "fără răspunsuri pentru acest indicator",
                           suprimat = paste0("date insuficiente (sub ", prag_cartier, " respondenți)"),
                           valoare = paste0(format_ro(round(valoare)), "% din ", den, " respondenți"))
        data.frame(cod = cod,
                   numarator = if (stare == "valoare") num else NA_integer_,
                   numitor = if (stare == "valoare") den else NA_integer_,
                   valoare = valoare, stare = stare,
                   clasa = if (stare == "valoare") clasa_valoare(valoare, CLASE_PROCENT) else NA_integer_,
                   eticheta = eticheta, stringsAsFactors = FALSE)
      }
    })
    d <- do.call(rbind, rows)
    d$denumire <- cartiere$denumire[match(d$cod, cartiere$cod)]
    out$indicatori[[id]] <- d
  }
  out
}

# Datele trimise browserului (fără numărători pentru cartierele suprimate).
mesaj_indicatori <- function(ind) {
  if (is.null(ind) || !isTRUE(ind$activ)) return(NULL)
  list(
    paleta = PALETA_TEMATICA, fara_date = CULOARE_FARA_DATE, suprimat = CULOARE_SUPRIMAT,
    prag_cartier = ind$prag_cartier, prag_numar = ind$prag_numar,
    indicatori = lapply(names(ind$indicatori), function(id) {
      m <- INDICATORI_HARTA[[id]]
      d <- ind$indicatori[[id]]
      list(id = id, titlu = m$titlu, unitate = m$unitate, tip = m$tip, descriere = m$descriere,
           clase = if (identical(m$tip, "numar")) CLASE_NUMAR$etichete else CLASE_PROCENT$etichete,
           valori = lapply(seq_len(nrow(d)), function(i) list(
             cod = d$cod[i], denumire = d$denumire[i], stare = d$stare[i],
             clasa = if (is.na(d$clasa[i])) NULL else d$clasa[i], eticheta = d$eticheta[i])))
    }))
}
