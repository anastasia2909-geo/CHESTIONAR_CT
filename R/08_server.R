# =============================================================================
# 08_server.R — logica pentru respondent
# -----------------------------------------------------------------------------
# Fluxul: pagina de start („acasa”) -> informare și acord („intro”) ->
# secțiunile 1–4 -> verificare -> pagina finală.
# Toate întrebările sunt în pagină de la început (pe pagini ascunse), deci
# valorile rămân în formular când respondentul merge înainte și înapoi.
# Nimic nu se salvează înainte de „Trimite răspunsurile”.
#
# Acordul de participare este verificat pe server la începere ȘI la trimitere;
# ascunderea butoanelor în browser nu este considerată o protecție. Din
# versiunea 3.1 nu există limită de vârstă.
# =============================================================================

PAGINI <- c("acasa", "intro", "s1", "s2", "s3", "s4", "revizuire", "final")

server_public <- function(input, output, session, Q, cale_db, mod) {

  session$allowReconnect(TRUE)

  pagina        <- reactiveVal("acasa")
  inceput       <- reactiveVal(FALSE)     # acordul confirmat pe server
  din_revizuire <- reactiveVal(FALSE)
  trimis        <- reactiveVal(FALSE)
  rec_trimis    <- reactiveVal(NULL)
  agregat       <- reactiveVal(NULL)
  tematic       <- reactiveVal(NULL)
  durata_test   <- reactiveVal(NULL)
  moment_start  <- NULL
  cartiere      <- citeste_cartiere()
  in_curs       <- FALSE
  # Un singur ID pe completare: un al doilea click sau o retrimitere a
  # aceleiași completări lovește cheia primară și nu creează un rând nou.
  response_id   <- genereaza_id()

  conditii_indeplinite <- function() {
    isTRUE(input$consimtamant)
  }

  mergi_la <- function(p) {
    pagina(p)
    updateTabsetPanel(session, "pagini", selected = p)
    nr_pas <- switch(p, s1 = 1, s2 = 2, s3 = 3, s4 = 4, revizuire = 5, 0)
    session$sendCustomMessage("pagina", list(
      nume = p,
      pas = nr_pas,
      titlu = switch(p, s1 = , s2 = , s3 = , s4 = SECTIUNI[[as.integer(sub("s", "", p))]]$titlu,
                     revizuire = "Verificare", ""),
      intrebari = if (nr_pas %in% 1:4) {
        nr <- vapply(intrebari_sectiune(Q, nr_pas), `[[`, 0, "nr"); c(min(nr), max(nr))
      } else NULL,
      din_revizuire = isTRUE(din_revizuire()),
      modificat = p %in% c("s1", "s2", "s3", "s4", "revizuire")
    ))
  }

  arata_erori <- function(s, err) {
    session$sendCustomMessage("erori", list(
      sumar = paste0("sumar-erori-s", s),
      erori = unname(lapply(names(err), function(id) list(
        id = id, nr = Q[[id]]$nr, titlu = Q[[id]]$titlu, mesaj = err[[id]])))))
  }
  curata_erori <- function(s) session$sendCustomMessage("erori", list(sumar = paste0("sumar-erori-s", s), erori = list()))
  eroare_simpla <- function(id, mesaj) session$sendCustomMessage("eroare-simpla", list(id = id, mesaj = mesaj))

  # --- pagina de start și informarea --------------------------------------------------
  observeEvent(input$incepe, {
    if (trimis()) return()
    mergi_la("intro")
  }, ignoreInit = TRUE)

  observeEvent(input$inapoi_intro, {
    if (trimis()) return()
    mergi_la("acasa")
  }, ignoreInit = TRUE)

  observeEvent(input$start, {
    if (trimis()) return()
    lipsa_acord  <- !isTRUE(input$consimtamant)
    eroare_simpla("eroare-consimtamant", if (lipsa_acord) "Pentru a începe, bifați caseta de acord." else "")
    if (lipsa_acord) return()
    inceput(TRUE)
    moment_start <<- Sys.time()
    mergi_la("s1")
  }, ignoreInit = TRUE)

  # --- navigare între secțiuni --------------------------------------------------------
  lapply(1:4, function(s) {
    observeEvent(input[[paste0("inainte_s", s)]], {
      if (trimis() || !inceput()) return()
      err <- valideaza_sectiune(Q, s, colecteaza_valori(Q, input))
      if (length(err)) {
        arata_erori(s, err)
        return()
      }
      curata_erori(s)
      if (s == 4 || isTRUE(din_revizuire())) {
        # Înainte de verificare, toate secțiunile trebuie să fie valide (de
        # exemplu, dacă Q5 a fost schimbat după completarea Q6).
        toate <- valideaza_tot(Q, colecteaza_valori(Q, input))
        if (length(toate)) {
          s_err <- Q[[names(toate)[1]]]$sectiune
          mergi_la(paste0("s", s_err))
          arata_erori(s_err, toate[vapply(names(toate), function(i) Q[[i]]$sectiune == s_err, logical(1))])
          return()
        }
        mergi_la("revizuire")
      } else {
        mergi_la(paste0("s", s + 1))
      }
    }, ignoreInit = TRUE)

    observeEvent(input[[paste0("inapoi_s", s)]], {
      if (trimis() || !inceput()) return()
      mergi_la(if (s == 1) "intro" else paste0("s", s - 1))
    }, ignoreInit = TRUE)

    observeEvent(input[[paste0("modifica_s", s)]], {
      if (trimis() || !inceput()) return()
      din_revizuire(TRUE)
      mergi_la(paste0("s", s))
    }, ignoreInit = TRUE)
  })

  observeEvent(input$inapoi_revizuire, {
    if (trimis() || !inceput()) return()
    din_revizuire(FALSE)
    mergi_la("s4")
  }, ignoreInit = TRUE)

  # --- pagina de verificare -----------------------------------------------------------
  output$rezumat_revizuire <- renderUI({
    req(pagina() == "revizuire", inceput())
    rec <- isolate(codifica_raspuns(Q, colecteaza_valori(Q, input), response_id, mod))
    tagList(lapply(1:4, function(s) {
      qs <- intrebari_sectiune(Q, s)
      tags$section(class = "rev-sectiune", `aria-labelledby` = paste0("rev-titlu-", s),
        div(class = "rev-cap",
            h3(id = paste0("rev-titlu-", s), paste0(s, ". ", SECTIUNI[[s]]$titlu)),
            actionLink(paste0("modifica_s", s), "Modifică",
                       class = "rev-modifica",
                       `aria-label` = paste0("Modifică secțiunea ", s, ": ", SECTIUNI[[s]]$titlu))),
        tags$dl(class = "rev-lista", lapply(qs, function(q) tagList(
          tags$dt(paste0(q$nr, ". ", q$titlu)),
          tags$dd(text_raspuns(q, rec))))))
    }))
  })

  # --- trimitere ----------------------------------------------------------------------
  observeEvent(input$trimite, {
    if (trimis() || in_curs) return()
    # Verificare pe server, independentă de interfață: fără acord sau fără
    # parcurgerea pasului de informare nu se salvează nimic.
    if (!inceput() || !conditii_indeplinite()) {
      mergi_la("intro")
      session$sendCustomMessage("trimitere", list(stare = "reactivare"))
      return()
    }
    in_curs <<- TRUE
    on.exit(in_curs <<- FALSE, add = TRUE)

    v <- colecteaza_valori(Q, input)
    err <- valideaza_tot(Q, v)
    if (length(err)) {
      s_err <- Q[[names(err)[1]]]$sectiune
      din_revizuire(TRUE)
      mergi_la(paste0("s", s_err))
      arata_erori(s_err, err[vapply(names(err), function(i) Q[[i]]$sectiune == s_err, logical(1))])
      session$sendCustomMessage("trimitere", list(stare = "reactivare"))
      return()
    }

    rec <- codifica_raspuns(Q, v, response_id, mod)
    rezultat <- tryCatch(salveaza_raspuns(cale_db, rec), error = function(e) {
      message("[", acum_utc(), "] EROARE la salvare: ", conditionMessage(e))
      "eroare"
    })

    if (rezultat %in% c("ok", "duplicat")) {
      # Comparația și indicatorii pe cartiere folosesc doar valori agregate,
      # peste praguri (R/00_config.R), din răspunsurile valide ale modului curent.
      toate_rasp <- tryCatch(filtreaza_valide(citeste_raspunsuri(cale_db), mod), error = function(e) {
        message("[", acum_utc(), "] Răspunsurile pentru agregare nu au putut fi citite: ", conditionMessage(e)); NULL })
      if (!is.null(toate_rasp)) {
        if (isTRUE(COMPARATIE_ACTIVA))
          agregat(tryCatch(agregat_comparatie(Q, toate_rasp), error = function(e) NULL))
        if (isTRUE(HARTA_TEMATICA_ACTIVA))
          tematic(tryCatch(calculeaza_indicatori(Q, toate_rasp, cartiere, mod = mod), error = function(e) {
            message("[", acum_utc(), "] Indicatorii nu au putut fi calculați: ", conditionMessage(e)); NULL }))
      }
      if (identical(mod, "test") && !is.null(moment_start))
        durata_test(as.numeric(difftime(Sys.time(), moment_start, units = "secs")))
      trimis(TRUE)
      rec_trimis(rec)
      mergi_la("final")
      session$sendCustomMessage("trimitere", list(stare = "gata"))
      m <- mesaj_harta(rec$q01_zona)
      m$tematic <- mesaj_indicatori(tematic())
      session$sendCustomMessage("harta", m)
    } else {
      session$sendCustomMessage("trimitere", list(
        stare = "eroare",
        mesaj = paste("Răspunsurile nu au putut fi salvate din cauza unei probleme tehnice.",
                      "Nu închideți pagina: răspunsurile sunt încă aici. Încercați din nou peste câteva secunde.")))
    }
  }, ignoreInit = TRUE)

  # --- pagina finală -----------------------------------------------------------------------
  output$profil <- renderUI({
    req(rec_trimis())
    profil_ui(Q, rec_trimis(), mod, agregat = agregat(), tematic = tematic(),
              cartier = date_cartier(rec_trimis()$q01_zona, cartiere),
              durata_test = durata_test())
  })
  output$grafic_q9 <- plotly::renderPlotly({
    req(rec_trimis())
    grafic_q9(Q, rec_trimis())
  })

  observeEvent(input$din_nou, {
    if (identical(mod, "test")) session$reload()
  }, ignoreInit = TRUE)
}
