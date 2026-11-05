# =============================================================================
# 10_admin.R — zona de administrare (adresa aplicației + ?admin)
# -----------------------------------------------------------------------------
# Nimic din această zonă nu este creat înainte de autentificare: tabelul,
# graficele și descărcările verifică fiecare starea de autentificare pe server.
# Parola vine numai din variabila de mediu CHESTIONAR_ADMIN_PAROLA; fără ea,
# zona este dezactivată (inclusiv pe calculatorul propriu, din versiunea 3).
# Încercările greșite sunt limitate pe sesiune și la nivelul procesului R
# (toate sesiunile), ca reîncărcarea paginii să nu ocolească blocarea.
# =============================================================================

# Starea comună tuturor sesiunilor din același proces R.
ADMIN_STARE <- new.env(parent = emptyenv())
ADMIN_STARE$esecuri <- as.POSIXct(character(0))

admin_blocat_global <- function(acum = Sys.time()) {
  fereastra <- ADMIN_BLOCARE_MINUTE * 60
  ADMIN_STARE$esecuri <- ADMIN_STARE$esecuri[as.numeric(difftime(acum, ADMIN_STARE$esecuri, units = "secs")) < fereastra]
  length(ADMIN_STARE$esecuri) >= 2 * ADMIN_INCERCARI_MAXIME
}
admin_inregistreaza_esec <- function(acum = Sys.time()) ADMIN_STARE$esecuri <- c(ADMIN_STARE$esecuri, acum)

parola_corecta <- function(introdusa, p = parola_admin()) {
  nzchar(p) && !is.null(introdusa) && length(introdusa) == 1 &&
    identical(openssl::sha256(enc2utf8(introdusa)), openssl::sha256(enc2utf8(p)))
}

# Verificările de configurare afișate în fila „Stare”. Fiecare rând:
# element, stare (ok / atentie / blocant), detalii.
verificari_configurare <- function(Q, mod, cale, df = NULL) {
  r <- list()
  add <- function(el, st, det) r[[length(r) + 1]] <<- data.frame(element = el, stare = st, detalii = det, stringsAsFactors = FALSE)
  add("Parola de administrare", if (nzchar(parola_admin())) "ok" else "blocant",
      if (nzchar(parola_admin())) "Setată prin CHESTIONAR_ADMIN_PAROLA." else "Nu este setată.")
  add("Durata estimată pe pagina de start", if (is.null(DURATA_ESTIMATA_MINUTE)) "atentie" else "ok",
      if (is.null(DURATA_ESTIMATA_MINUTE)) "DURATA_ESTIMATA_MINUTE nu este setată (R/00_config.R); pagina de start nu afișează o durată. Măsurați-o cu cronometrul din modul test."
      else paste0(DURATA_ESTIMATA_MINUTE, " minute: estimare din conținutul chestionarului (docs/DURATA_ESTIMATA.md), de validat cu completări reale."))
  add("Etichetele scalei Q21", if (isTRUE(Q21_ANCORE_ACTIVE)) "ok" else "atentie",
      if (isTRUE(Q21_ANCORE_ACTIVE)) paste(Q21_ANCORE_ETICHETE, collapse = " / ")
      else "Dezactivate (Q21_ANCORE_ACTIVE în R/00_config.R).")
  pol <- length(coduri_cartiere_vectoriale())
  add("Limitele vectoriale ale cartierelor", if (pol >= 42) "ok" else "atentie",
      if (pol) paste0(pol, " cartiere în ", FISIER_CARTIERE_GEOJSON, if (isTRUE(info_cartiere_vectoriale()$oficiale)) " (limite oficiale)." else " (limite orientative, desenate pe OpenStreetMap după HCL nr. 79/2023).")
      else "Lipsesc. Harta tematică afișează indicatorii ca tabel. Vezi docs/HARTA_DATE_SI_LIMITARI.md.")
  inf <- citeste_informare()
  lipsa_info <- !informare_are_pastrare(inf)
  add("Textul de informare: păstrarea datelor și accesul", if (lipsa_info) "blocant" else "ok",
      if (lipsa_info) "Informarea nu are secțiunea „## Păstrarea datelor” (config/informare_consimtamant.md)."
      else "Prezente: păstrare pe durată nedeterminată, acces numai pentru autoare.")
  add("Anonimat", if (identical(PRECIZIE_DATA_TRIMITERII, "zi")) "ok" else "atentie",
      if (identical(PRECIZIE_DATA_TRIMITERII, "zi")) "Se salvează doar data trimiterii; fără IP, cookie-uri sau date de identificare (docs/AUDIT_ANONIMAT.md)."
      else "Se salvează ora exactă a trimiterii (PRECIZIE_DATA_TRIMITERII); poate fi legată de jurnalele serverului.")
  add("Praguri", "ok", paste0("Comparație: ", COMPARATIE_MIN_RASPUNSURI, " completări; hartă: ", HARTA_PRAG_TOTAL,
                              " completări în total, ", HARTA_PRAG_CARTIER, " respondenți pe cartier pentru procente, ",
                              HARTA_PRAG_NUMAR, " pentru numărul de respondenți."))
  scriere <- verifica_scrierea(cale)
  add(if (este_postgres(cale)) "Baza de date PostgreSQL poate fi scrisă" else "Folderul bazei de date poate fi scris",
      if (isTRUE(scriere$ok)) "ok" else "blocant", scriere$detalii)
  if (!is.null(df)) {
    valide <- nrow(filtreaza_valide(df, mod))
    add("Răspunsuri", "ok", paste0(nrow(df), " rânduri, dintre care ", valide, " completări valide în modul ", mod, "."))
  }
  if (este_postgres(cale)) {
    add("Găzduirea", "ok", "Răspunsurile se salvează în baza PostgreSQL, în afara serverului aplicației; repornirea sau republicarea aplicației nu le afectează. Descărcați totuși o copie în fiecare săptămână (docs/GAZDUIRE.md).")
  } else {
    add("Găzduirea", "atentie", "Răspunsurile se salvează în fișierul SQLite de lângă aplicație. Pe Posit Connect Cloud și shinyapps.io fișierul se pierde la repornire sau republicare; acolo setați CHESTIONAR_DB_URL (docs/GAZDUIRE.md).")
  }
  do.call(rbind, r)
}

limba_dt <- list(
  search = "Caută:", lengthMenu = "Afișează _MENU_ rânduri",
  info = "Rândurile _START_–_END_ din _TOTAL_", infoEmpty = "Niciun rând",
  infoFiltered = "(filtrate din _MAX_)", zeroRecords = "Niciun rând găsit",
  emptyTable = "Nu există răspunsuri", paginate = list(previous = "Înapoi", `next` = "Înainte"))

# --- grafice agregate ---------------------------------------------------------------

tema_grafic <- function() {
  ggplot2::theme_minimal(base_size = 13) +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_line(colour = "#E2D6BF", linewidth = 0.4),
      plot.title = ggplot2::element_text(face = "bold", colour = "#0D1F45"),
      plot.subtitle = ggplot2::element_text(colour = "#474E66"),
      axis.text = ggplot2::element_text(colour = "#0D1F45"),
      plot.background = ggplot2::element_rect(fill = "#FFFBF3", colour = NA))
}

bare_orizontale <- function(et, n, total_valid, titlu, subtitlu) {
  d <- data.frame(et = factor(et, levels = rev(et)), n = n)
  d$p <- if (total_valid > 0) 100 * d$n / total_valid else 0
  d$lab <- paste0(d$n, " (", vapply(d$p, format_ro, "", zecimale = 1), "%)")
  ggplot2::ggplot(d, ggplot2::aes(x = n, y = et)) +
    ggplot2::geom_col(fill = "#1B3168", width = 0.55) +
    ggplot2::geom_text(ggplot2::aes(label = lab), hjust = -0.1, size = 3.8, colour = "#0D1F45") +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0, 0.25))) +
    ggplot2::scale_y_discrete(labels = function(x) vapply(x, function(s) paste(strwrap(s, 40), collapse = "\n"), "")) +
    ggplot2::labs(title = titlu, subtitle = subtitlu, x = "Număr de răspunsuri", y = NULL) +
    tema_grafic()
}

subtitlu_n <- function(valid, total, extra = "") {
  paste0("Răspunsuri valide: ", valid, " din ", total, extra)
}

alegeri_grafice_admin <- function(Q) {
  x <- c()
  for (q in Q) if (q$tip != "text") x[paste0("Q", q$nr, ". ", q$titlu)] <- q$id
  x
}

grafic_admin <- function(Q, df, qid) {
  q <- Q[[qid]]
  N <- nrow(df)
  titlu <- paste0("Q", q$nr, ". ", q$titlu)
  if (N == 0) {
    return(ggplot2::ggplot() + ggplot2::annotate("text", x = 0, y = 0, label = "Nu există răspunsuri.") +
             ggplot2::theme_void())
  }
  switch(q$tip,
    lista = , unic = {
      x <- df[[q$var]]; valid <- sum(!is.na(x))
      n <- vapply(names(q$optiuni), function(k) sum(x == k, na.rm = TRUE), 0)
      et <- unname(q$optiuni)
      alte <- sum(!is.na(x) & !x %in% names(q$optiuni))
      if (alte > 0) { et <- c(et, "Coduri din versiuni anterioare ale listei"); n <- c(n, alte) }
      bare_orizontale(et, n, valid, titlu,
                      subtitlu_n(valid, N, ". Procentele sunt calculate din răspunsurile valide."))
    },
    numar = {
      x <- df[[q$var]]; valid <- sum(!is.na(x)); t <- table(factor(x, levels = sort(unique(x[!is.na(x)]))))
      bare_orizontale(paste(names(t), "pers."), as.integer(t), valid, titlu, subtitlu_n(valid, N))
    },
    numere_grup = {
      tot <- vapply(names(q$campuri), function(k) sum(df[[paste0("q06_", k)]], na.rm = TRUE), 0)
      valid <- sum(stats::complete.cases(df[, paste0("q06_", names(q$campuri))]))
      bare_orizontale(unname(q$campuri), tot, sum(tot), titlu,
                      paste0(subtitlu_n(valid, N), ". Numărul total de persoane din gospodării, pe categorii."))
    },
    consum_apa = {
      ns <- sum(df$q08_nu_stiu == 1, na.rm = TRUE)
      d <- rbind(data.frame(tip = "Apă rece", m3 = df$q08_apa_rece_m3),
                 data.frame(tip = "Apă caldă", m3 = df$q08_apa_calda_m3))
      d <- d[!is.na(d$m3), ]
      if (!nrow(d)) d <- data.frame(tip = "Apă rece", m3 = NA_real_)
      ggplot2::ggplot(d, ggplot2::aes(x = m3)) +
        ggplot2::geom_histogram(bins = 20, fill = "#1B3168", colour = "#FFFBF3", na.rm = TRUE) +
        ggplot2::facet_wrap(~tip, ncol = 1) +
        ggplot2::labs(title = titlu,
                      subtitle = paste0("Valori numerice: apă rece ", sum(!is.na(df$q08_apa_rece_m3)),
                                        ", apă caldă ", sum(!is.na(df$q08_apa_calda_m3)),
                                        ". „Nu știu”: ", ns, " din ", N, ". Lipsurile nu sunt înlocuite cu 0."),
                      x = "m³ pe lună", y = "Număr de răspunsuri") +
        tema_grafic()
    },
    procente = {
      vars <- paste0("q09_", names(q$campuri))
      d <- data.frame(et = rep(unname(q$campuri), each = N), p = unlist(df[, vars], use.names = FALSE))
      d <- d[!is.na(d$p), ]
      d$et <- factor(d$et, levels = rev(unname(q$campuri)))
      valid <- sum(stats::complete.cases(df[, vars]))
      ggplot2::ggplot(d, ggplot2::aes(x = p, y = et)) +
        ggplot2::geom_boxplot(fill = "#D9E3EF", colour = "#1B3168", outlier.colour = "#0D1F45") +
        ggplot2::stat_summary(fun = mean, geom = "point", shape = 23, size = 2.6, fill = "#B8892B") +
        ggplot2::scale_y_discrete(labels = function(x) vapply(x, function(s) paste(strwrap(s, 40), collapse = "\n"), "")) +
        ggplot2::labs(title = titlu, subtitle = paste0(subtitlu_n(valid, N), ". Romb = media; linia din cutie = mediana."),
                      x = "Procent din consum", y = NULL) +
        tema_grafic()
    },
    multiplu = {
      vars <- paste0(q$id, "_", names(q$optiuni))
      raspuns <- stats::complete.cases(df[, vars, drop = FALSE])
      valid <- sum(raspuns)
      n <- vapply(vars, function(v) sum(df[[v]] == 1, na.rm = TRUE), 0)
      extra <- if (!is.null(q$conditie)) paste0(" (întrebarea a fost afișată doar celor care au răspuns „Da” la Q19)") else ""
      bare_orizontale(unname(q$optiuni), n, valid, titlu,
                      paste0(subtitlu_n(valid, N, extra), ". Selecție multiplă: procentele nu însumează 100%."))
    },
    matrice = {
      d <- do.call(rbind, lapply(names(q$randuri), function(k) {
        x <- df[[paste0("q12_", k)]]
        data.frame(obiect = q$randuri[[k]], motiv = unname(q$coloane),
                   n = vapply(names(q$coloane), function(c) sum(x == c, na.rm = TRUE), 0))
      }))
      d$obiect <- factor(d$obiect, levels = rev(unname(q$randuri)))
      d$motiv <- factor(d$motiv, levels = unname(q$coloane))
      ggplot2::ggplot(d, ggplot2::aes(x = motiv, y = obiect, fill = n)) +
        ggplot2::geom_tile(colour = "#FFFBF3", linewidth = 1.2) +
        ggplot2::geom_text(ggplot2::aes(label = n, colour = n > max(n) / 2), size = 4) +
        ggplot2::scale_colour_manual(values = c(`TRUE` = "#FFFBF3", `FALSE` = "#0D1F45"), guide = "none") +
        ggplot2::scale_fill_gradient(low = "#E3EAF3", high = "#0D1F45", name = "Răspunsuri") +
        ggplot2::scale_x_discrete(position = "top", labels = function(x) vapply(x, function(s) paste(strwrap(s, 14), collapse = "\n"), "")) +
        ggplot2::labs(title = titlu, subtitle = subtitlu_n(sum(stats::complete.cases(df[, paste0("q12_", names(q$randuri))])), N),
                      x = NULL, y = NULL) +
        tema_grafic() + ggplot2::theme(panel.grid = ggplot2::element_blank())
    },
    matrice_scala = {
      d <- do.call(rbind, lapply(names(q$randuri), function(k) {
        x <- df[[paste0("q21_", k)]]
        data.frame(actor = q$randuri[[k]], scor = as.character(1:5),
                   n = vapply(1:5, function(s) sum(x == s, na.rm = TRUE), 0))
      }))
      d$actor <- factor(d$actor, levels = rev(unname(q$randuri)))
      toti <- sum(df$q21_toti == 1, na.rm = TRUE)   # doar din versiunile 1–2
      ancore <- if (isTRUE(Q21_ANCORE_ACTIVE)) paste0(" 1 = ", Q21_ANCORE_ETICHETE[["min"]], ", 5 = ", Q21_ANCORE_ETICHETE[["max"]], ".")
                else " Etichetele capetelor scalei nu sunt încă confirmate."
      ggplot2::ggplot(d, ggplot2::aes(x = scor, y = actor, fill = n)) +
        ggplot2::geom_tile(colour = "#FFFBF3", linewidth = 1.2) +
        ggplot2::geom_text(ggplot2::aes(label = n, colour = n > max(n) / 2), size = 4) +
        ggplot2::scale_colour_manual(values = c(`TRUE` = "#FFFBF3", `FALSE` = "#0D1F45"), guide = "none") +
        ggplot2::scale_fill_gradient(low = "#E3EAF3", high = "#0D1F45", name = "Răspunsuri") +
        ggplot2::labs(title = titlu,
                      subtitle = paste0(subtitlu_n(sum(stats::complete.cases(df[, paste0("q21_", names(q$randuri))])), N), ".", ancore,
                                        if (toti > 0) paste0(" „Toți au responsabilități” (retras în v3) bifat în ", toti, " răspunsuri mai vechi.") else ""),
                      x = "Valoare pe scala 1–5", y = NULL) +
        tema_grafic() + ggplot2::theme(panel.grid = ggplot2::element_blank())
    }
  )
}

# --- server ---------------------------------------------------------------------------

server_admin <- function(input, output, session, Q, mod) {
  cale <- cale_baza_date(mod)
  schema <- schema_date(Q)
  autentificat <- reactiveVal(FALSE)
  esecuri <- 0L
  blocat_pana <- Sys.time() - 1
  ultima_activitate <- Sys.time()

  observeEvent(input$admin_login, {
    if (Sys.time() < blocat_pana || admin_blocat_global()) {
      showNotification("Prea multe încercări greșite. Încercați din nou mai târziu.", type = "error")
      updateTextInput(session, "admin_parola", value = "")
      return()
    }
    if (parola_corecta(input$admin_parola)) {
      esecuri <<- 0L
      ultima_activitate <<- Sys.time()
      autentificat(TRUE)
    } else {
      esecuri <<- esecuri + 1L
      admin_inregistreaza_esec()
      if (esecuri >= ADMIN_INCERCARI_MAXIME) {
        blocat_pana <<- Sys.time() + ADMIN_BLOCARE_MINUTE * 60
        esecuri <<- 0L
      }
      message("[", acum_utc(), "] Autentificare admin eșuată.")
      showNotification("Parolă greșită.", type = "error")
    }
    updateTextInput(session, "admin_parola", value = "")
  })

  # Ieșire automată după ADMIN_INACTIVITATE_MINUTE fără nicio acțiune.
  observe({
    reactiveValuesToList(input)
    ultima_activitate <<- Sys.time()
  })
  observe({
    invalidateLater(30000)
    if (isolate(autentificat()) &&
        as.numeric(difftime(Sys.time(), ultima_activitate, units = "mins")) > ADMIN_INACTIVITATE_MINUTE) {
      autentificat(FALSE)
      showNotification("Sesiunea de administrare s-a închis după o perioadă de inactivitate.", type = "warning", duration = NULL)
    }
  })

  observeEvent(input$admin_iesire, {
    autentificat(FALSE)
    session$reload()
  })

  # Verificarea rulează numai după autentificare (o bază PostgreSQL nu este
  # trezită de cineva care doar deschide pagina de administrare).
  date <- reactivePoll(if (este_postgres(cale)) 10000 else 4000, session,
    checkFunc = function() if (isTRUE(autentificat())) semnatura_baza(cale) else "neautentificat",
    valueFunc = function() citeste_raspunsuri(cale, schema))

  stare_config <- reactive({
    req(autentificat())
    verificari_configurare(Q, mod, cale, date())
  })
  avertismente <- reactive({
    v <- stare_config()
    v$element[v$stare == "blocant"]
  })

  output$admin_continut <- renderUI({
    if (!autentificat()) {
      if (!nzchar(parola_admin())) {
        return(div(class = "admin-card",
          h2("Zona de administrare este dezactivată"),
          p("Nu este setată o parolă. Adăugați în fișierul .Renviron din folderul aplicației linia:"),
          tags$pre("CHESTIONAR_ADMIN_PAROLA=o-parola-lunga-si-unica"),
          p("apoi reporniți R (Session > Restart R în RStudio) și aplicația. Detalii în README.md.")))
      }
      return(div(class = "admin-card admin-login",
        h2("Autentificare"),
        passwordInput("admin_parola", "Parola de administrare", width = "100%"),
        actionButton("admin_login", "Intră", class = "btn-principal")))
    }

    tagList(
      if (length(avertismente()))
        div(class = "admin-avertismente", role = "note",
            h2("De rezolvat înainte de lansare"),
            tags$ul(lapply(avertismente(), tags$li)),
            p("Detalii în fila „Stare”.")),
      uiOutput("admin_cifre"),
      tabsetPanel(id = "admin_tab",
        tabPanel("Răspunsuri", div(class = "admin-panou", DT::DTOutput("admin_tabel"))),
        tabPanel("Grafice", div(class = "admin-panou",
          selectInput("admin_grafic", "Întrebarea", choices = alegeri_grafice_admin(Q), selectize = FALSE, width = "100%"),
          plotOutput("admin_grafic_plot", height = "auto"))),
        tabPanel("Stare", div(class = "admin-panou", uiOutput("admin_stare"))),
        tabPanel("Export", div(class = "admin-panou",
          h2("Export brut"),
          p("Toate rândurile din baza de date, exact cum au fost salvate. Excel are patru foi: răspunsurile codificate, aceleași răspunsuri cu etichete, dicționarul de date și informații despre export. Celulele goale înseamnă valoare lipsă."),
          div(class = "admin-butoane",
              downloadButton("desc_xlsx", "Descarcă Excel (.xlsx)", class = "btn-principal", icon = NULL),
              downloadButton("desc_csv", "Descarcă CSV", class = "btn-secundar", icon = NULL),
              downloadButton("desc_dictionar", "Dicționarul de date (.xlsx)", class = "btn-secundar", icon = NULL),
              downloadButton("desc_sqlite", "Copie a bazei de date (.sqlite)", class = "btn-secundar", icon = NULL)),
          h2("Export pentru analiză"),
          p("Aceleași rânduri, plus variabile derivate: completare_valida, totalurile Q6 și Q9, litri pe persoană pe zi, numărul de obiecte de la Q12 și indicatorii folosiți pe hartă. Foaia „dictionar” descrie fiecare variabilă."),
          div(class = "admin-butoane",
              downloadButton("desc_analiza", "Descarcă exportul pentru analiză (.xlsx)", class = "btn-principal", icon = NULL)))),
        if (identical(mod, "test")) tabPanel("Date de test", div(class = "admin-panou",
          p("Aceste acțiuni lucrează numai cu baza de date de test (", tags$code(nume_stocare(cale)), "). Baza de date reală nu este atinsă."),
          numericInput("test_n", "Număr de răspunsuri sintetice", 25, min = 1, max = 500, width = "16rem"),
          div(class = "admin-butoane",
              actionButton("test_genereaza", "Generează răspunsuri sintetice", class = "btn-secundar"),
              actionButton("test_sterge", "Șterge toate datele de test", class = "btn-pericol"))))
      ),
      div(class = "navigare", actionButton("admin_iesire", "Ieșire", class = "btn-secundar"))
    )
  })

  output$admin_cifre <- renderUI({
    req(autentificat())
    df <- date()
    tagList(
      div(class = "admin-cifre",
          div(class = "admin-cifra", span(class = "cifra", nrow(df)), span(class = "cifra-et", "răspunsuri în baza de date")),
          div(class = "admin-cifra", span(class = "cifra cifra-text", if (nrow(df)) sub("T", " ", sub("Z$", " UTC", max(df$submitted_at))) else "—"),
              span(class = "cifra-et", "data ultimei trimiteri")),
          div(class = "admin-cifra", span(class = "cifra cifra-text", if (identical(mod, "test")) "test" else "producție"),
              span(class = "cifra-et", "modul aplicației"))),
      p(class = "admin-cale", if (este_postgres(cale)) "Baza de date: " else "Fișierul bazei de date: ", tags$code(descriere_stocare(cale)))
    )
  })

  output$admin_stare <- renderUI({
    req(autentificat())
    v <- stare_config()
    eticheta <- c(ok = "în regulă", atentie = "de verificat", blocant = "blochează lansarea")
    tags$table(class = "admin-stare",
      tags$caption("Verificări de configurare, calculate la deschiderea filei"),
      tags$thead(tags$tr(tags$th(scope = "col", "Element"), tags$th(scope = "col", "Stare"), tags$th(scope = "col", "Detalii"))),
      tags$tbody(lapply(seq_len(nrow(v)), function(i) tags$tr(
        tags$th(scope = "row", v$element[i]),
        tags$td(span(class = paste0("stare-eticheta stare-", v$stare[i]), eticheta[[v$stare[i]]])),
        tags$td(v$detalii[i])))))
  })

  output$admin_tabel <- DT::renderDT({
    req(autentificat())
    # Toate coloanele sunt afișate ca text, cu filtre text simple. Filtrele
    # numerice cu glisor depind de biblioteci JS suplimentare; exportul
    # păstrează tipurile originale.
    df <- date()
    df[] <- lapply(df, function(x) ifelse(is.na(x), "", as.character(x)))
    DT::datatable(df, rownames = FALSE, filter = list(position = "top", clear = FALSE),
                  class = "compact stripe nowrap",
                  options = list(scrollX = TRUE, pageLength = 25, language = limba_dt,
                                 columnDefs = list(list(targets = "_all", className = "dt-left"))))
  })

  output$admin_grafic_plot <- renderPlot(height = function() {
    q <- Q[[input$admin_grafic %||% "q02"]]
    n <- length(q$optiuni %||% q$randuri %||% q$campuri %||% 1:6)
    max(420, 140 + 26 * n)
  }, {
    req(autentificat(), input$admin_grafic)
    grafic_admin(Q, date(), input$admin_grafic)
  }, res = 96)

  nume_fisier <- function(ext) function() paste0("raspunsuri_", mod, "_", format(Sys.time(), "%Y%m%d_%H%M"), ".", ext)
  verifica <- function() if (!isTRUE(isolate(autentificat()))) stop("Acces neautorizat.")

  output$desc_xlsx <- downloadHandler(nume_fisier("xlsx"), function(file) {
    verifica(); scrie_xlsx(citeste_raspunsuri(cale, schema), Q, file, mod) })
  output$desc_csv <- downloadHandler(nume_fisier("csv"), function(file) {
    verifica(); scrie_csv(citeste_raspunsuri(cale, schema), file) })
  output$desc_dictionar <- downloadHandler(function() "dictionar_date.xlsx", function(file) {
    verifica(); writexl::write_xlsx(list(dictionar_date = dictionar_date(Q)), file) })
  output$desc_sqlite <- downloadHandler(nume_fisier("sqlite"), function(file) {
    verifica(); copie_de_siguranta(cale, file, schema) })
  output$desc_analiza <- downloadHandler(function() paste0("analiza_", mod, "_", format(Sys.time(), "%Y%m%d_%H%M"), ".xlsx"), function(file) {
    verifica(); scrie_xlsx_analiza(citeste_raspunsuri(cale, schema), Q, file, mod) })

  observeEvent(input$test_genereaza, {
    req(autentificat(), identical(mod, "test"))
    n <- suppressWarnings(as.integer(input$test_n))
    if (is.na(n) || n < 1 || n > 500) { showNotification("Alegeți un număr între 1 și 500.", type = "warning"); return() }
    insereaza_date_test(Q, cale, n)
    showNotification(paste0("Au fost adăugate ", n, " răspunsuri sintetice."), type = "message")
  })

  observeEvent(input$test_sterge, {
    req(autentificat(), identical(mod, "test"))
    showModal(modalDialog(
      title = "Ștergeți datele de test?",
      p("Se vor șterge toate rândurile din ", tags$code(nume_stocare(cale)), ". Baza de date reală nu este afectată."),
      footer = tagList(modalButton("Renunț"),
                       actionButton("test_sterge_confirm", "Șterge datele de test", class = "btn-pericol"))))
  })
  observeEvent(input$test_sterge_confirm, {
    req(autentificat(), identical(mod, "test"))
    n <- sterge_date_test(cale)
    removeModal()
    showNotification(paste0("Au fost șterse ", n, " răspunsuri de test."), type = "message")
  })
}
