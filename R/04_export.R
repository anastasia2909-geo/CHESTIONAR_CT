# =============================================================================
# 04_export.R — export Excel/CSV și dicționarul de date
# =============================================================================

# Același tabel, cu etichete în loc de coduri. Coloanele multiple (0/1) devin
# „Selectat”/„Neselectat”; NA rămâne gol.
date_cu_etichete <- function(df, Q, schema = schema_date(Q)) {
  if (!nrow(df)) return(df)
  out <- df
  for (nm in names(df)) {
    tip <- schema$tip_date[match(nm, schema$variabila)]
    if (is.na(tip)) next
    et <- etichete_variabila(Q, nm)
    if (!is.null(et)) {
      x <- as.character(df[[nm]])
      # Un cod care nu mai există în chestionar (de exemplu, o zonă dintr-o
      # versiune anterioară a listei) rămâne vizibil, nu devine celulă goală.
      out[[nm]] <- ifelse(is.na(x), NA_character_, ifelse(x %in% names(et), unname(et[x]), x))
    } else if (startsWith(tip, "boolean")) {
      x <- df[[nm]]
      out[[nm]] <- ifelse(is.na(x), NA_character_, ifelse(x == 1, "Selectat", "Neselectat"))
    }
  }
  out
}

dictionar_date <- function(Q) {
  s <- schema_date(Q)
  s[, c("variabila", "intrebare_nr", "intrebare", "tip_date", "valori_permise", "valori_lipsa")]
}

scrie_xlsx <- function(df, Q, cale, mod) {
  info <- data.frame(
    camp = c("Exportat la (UTC)", "Mod", "Număr de răspunsuri", "Versiune chestionar",
             "Versiune aplicație", "Valori lipsă"),
    valoare = c(acum_utc(), mod, nrow(df), VERSIUNE_CHESTIONAR, VERSIUNE_APLICATIE,
                "Celulele goale înseamnă valoare lipsă (NA). Vezi foaia dictionar_date."),
    stringsAsFactors = FALSE)
  foi <- list(
    raspunsuri = df,
    raspunsuri_etichete = date_cu_etichete(df, Q),
    dictionar_date = dictionar_date(Q),
    informatii = info)
  writexl::write_xlsx(foi, cale)
  invisible(cale)
}

# CSV UTF-8 cu BOM (Excel recunoaște astfel diacriticele), separator virgulă,
# punct zecimal, NA scris ca celulă goală.
scrie_csv <- function(df, cale) {
  con <- file(cale, open = "wb")
  on.exit(close(con), add = TRUE)
  writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con)
  txt <- utils::capture.output(utils::write.csv(df, row.names = FALSE, na = ""))
  writeBin(charToRaw(enc2utf8(paste0(paste(txt, collapse = "\n"), "\n"))), con)
  invisible(cale)
}

scrie_dictionar <- function(Q, folder = "docs") {
  d <- dictionar_date(Q)
  dir.create(folder, showWarnings = FALSE, recursive = TRUE)
  scrie_csv(d, file.path(folder, "dictionar_date.csv"))
  writexl::write_xlsx(list(dictionar_date = d), file.path(folder, "dictionar_date.xlsx"))
  invisible(d)
}

# --- export pentru analiză ---------------------------------------------------------
# Exportul brut (scrie_xlsx / scrie_csv) păstrează toate rândurile exact cum
# sunt în baza de date. Exportul pentru analiză adaugă variabile derivate,
# calculate cu aceleași funcții ca profilul și harta (R/09_profil.R,
# R/12_indicatori.R), și marchează completările valide. Nu șterge și nu
# modifică niciun răspuns.

DICTIONAR_DERIVATE <- data.frame(
  variabila = c("completare_valida", "q06_total_persoane", "q09_total_procente", "litri_pe_persoana_zi",
                "q12_nr_obiecte_aruncate", "ind_ulei_chiuveta", "ind_q12_oricare", "ind_q12_servetele"),
  descriere = c(
    "1 = rând folosit în comparații și indicatori (acord dat, cartier completat, același mod ca exportul); 0 = exclus.",
    "Suma valorilor de la Q6 (categorii de vârstă). Trebuie să fie egală cu Q5 la răspunsurile validate de aplicație.",
    "Suma procentelor de la Q9. Trebuie să fie 100 la răspunsurile validate de aplicație.",
    "Estimare: (Q8 apă rece + Q8 apă caldă, m³/lună) × 1000 ÷ 30 ÷ Q5. Apa caldă lipsă = 0 (inclusă în apa rece). Gol dacă Q8 = „Nu știu”.",
    "Câte dintre cele 8 obiecte de la Q12 au un motiv de aruncare în toaletă (0–8). Gol dacă rândul nu are niciun răspuns la Q12.",
    "Indicatorul „Uleiul uzat turnat în chiuvetă sau toaletă”: 1 = da, 0 = altă variantă; gol = în afara numitorului (Q13 lipsă sau „Nu folosesc ulei”).",
    "Indicatorul „Cel puțin un obiect aruncat în toaletă”: 1 = cel puțin un motiv la Q12, 0 = toate cele 8 „Nu am aruncat”; gol = în afara numitorului.",
    "Indicatorul „Șervețele umede aruncate în toaletă”: 1 = motiv, 0 = „Nu am aruncat”; gol = „Prefer să nu răspund” sau lipsă."),
  tip_date = c("întreg 0/1", "număr", "număr", "număr (litri)", "întreg 0–8", "întreg 0/1", "întreg 0/1", "întreg 0/1"),
  definit_in = c("R/12_indicatori.R: filtreaza_valide()", "R/04_export.R", "R/04_export.R", "R/09_profil.R: litri_pe_persoana_zi()",
                 "R/04_export.R", "R/12_indicatori.R: contributii()", "R/12_indicatori.R: contributii()", "R/12_indicatori.R: contributii()"),
  stringsAsFactors = FALSE)

date_analiza <- function(df, Q, mod = NULL) {
  if (!nrow(df)) {
    for (v in DICTIONAR_DERIVATE$variabila) df[[v]] <- numeric(0)
    return(df)
  }
  valide <- filtreaza_valide(df, mod)
  df$completare_valida <- as.integer(df$response_id %in% valide$response_id)
  v6 <- paste0("q06_", names(Q$q06$campuri)); v9 <- paste0("q09_", names(Q$q09$campuri))
  df$q06_total_persoane <- ifelse(stats::complete.cases(df[, v6]), rowSums(df[, v6, drop = FALSE]), NA_real_)
  df$q09_total_procente <- ifelse(stats::complete.cases(df[, v9]), rowSums(df[, v9, drop = FALSE]), NA_real_)
  df$litri_pe_persoana_zi <- vapply(seq_len(nrow(df)), function(i) round(litri_pe_persoana_zi(as.list(df[i, ])), 1), 0)
  v12 <- paste0("q12_", names(Q$q12$randuri))
  m12 <- as.matrix(df[, v12, drop = FALSE])
  are12 <- rowSums(!is.na(m12)) > 0
  df$q12_nr_obiecte_aruncate <- ifelse(are12, rowSums(matrix(m12 %in% MOTIVE_ARUNCAT, nrow = nrow(m12))), NA_integer_)
  ctr <- contributii(Q, df)
  flag <- function(id) ifelse(ctr[[id]]$den, as.integer(ctr[[id]]$num), NA_integer_)
  df$ind_ulei_chiuveta <- flag("ulei_chiuveta")
  df$ind_q12_oricare <- flag("q12_oricare")
  df$ind_q12_servetele <- flag("q12_servetele")
  df
}

scrie_xlsx_analiza <- function(df, Q, cale, mod) {
  d <- date_analiza(df, Q, mod)
  et <- date_cu_etichete(d, Q)
  dict <- rbind(
    data.frame(variabila = dictionar_date(Q)$variabila, descriere = dictionar_date(Q)$intrebare,
               tip_date = dictionar_date(Q)$tip_date, definit_in = "R/01_intrebari.R: schema_date()", stringsAsFactors = FALSE),
    DICTIONAR_DERIVATE)
  info <- data.frame(
    camp = c("Exportat la (UTC)", "Mod", "Rânduri", "Completări valide (completare_valida = 1)",
             "Versiune chestionar", "Versiune aplicație", "Valori lipsă"),
    valoare = c(acum_utc(), mod, nrow(d), sum(d$completare_valida == 1, na.rm = TRUE),
                VERSIUNE_CHESTIONAR, VERSIUNE_APLICATIE,
                "Celulele goale înseamnă valoare lipsă (NA). Variabilele derivate sunt descrise în foaia dictionar."),
    stringsAsFactors = FALSE)
  writexl::write_xlsx(list(analiza_coduri = d, analiza_etichete = et, dictionar = dict, informatii = info), cale)
  invisible(cale)
}
