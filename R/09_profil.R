# =============================================================================
# 09_profil.R — profilul de după trimitere
# -----------------------------------------------------------------------------
# Profilul folosește rândul tocmai trimis de respondentul curent (`rec`).
# Excepțiile sunt secțiunile cu valori AGREGATE (comparația și indicatorii pe
# cartiere), calculate din răspunsurile valide ale modului curent și afișate
# numai peste pragurile din R/00_config.R. Nu se dau scoruri și nu se fac
# clasificări de tip „bine/rău”. Nimic de aici nu se salvează.
#
# Detaliile Q10–Q12 (obiceiuri, echipamente, obiectele de la Q12) nu mai apar
# în profil din versiunea 3; ele rămân în chestionar, în baza de date și în
# exporturi. Sursele și recomandările sunt în R/13_recomandari.R.
# =============================================================================

MOTIVE_ARUNCAT <- c("rapid_obisnuinta", "fara_cos", "credeam_permis", "eticheta_flushable")

# Paleta graficelor (aceleași valori ca în www/styles.css)
CULOARE_GRAFIC <- list(bara = "#1B3168", text = "#0D1F45", grila = "#E2D6BF", axa = "#6E7486",
                       fundal_eticheta = "#0D1F45", text_eticheta = "#F3EBDB")

# --- calcule ---------------------------------------------------------------------

date_q9 <- function(Q, rec) {
  q <- Q$q09
  d <- data.frame(cod = names(q$campuri), eticheta = unname(q$campuri),
                  procent = vapply(names(q$campuri), function(k) rec[[paste0("q09_", k)]] %||% NA_real_, 0),
                  stringsAsFactors = FALSE)
  d[order(-d$procent, seq_len(nrow(d))), ]
}

# Litri pe persoană pe zi (estimare), din Q5 și Q8:
#   (apă rece + apă caldă, m³/lună) × 1000 / 30 / persoane.
# Apa caldă lipsă = inclusă în apa rece (nota din Q8). Fără valoare la „Nu știu”.
litri_pe_persoana_zi <- function(rec) {
  if (isTRUE(rec$q08_nu_stiu == 1) || is.na(rec$q08_apa_rece_m3) || is.na(rec$q05_nr_persoane) ||
      rec$q05_nr_persoane < 1) return(NA_real_)
  total <- rec$q08_apa_rece_m3 + ifelse(is.na(rec$q08_apa_calda_m3), 0, rec$q08_apa_calda_m3)
  total * 1000 / 30 / rec$q05_nr_persoane
}

selectate <- function(q, rec) {
  k <- names(q$optiuni)
  k[vapply(k, function(x) isTRUE(rec[[paste0(q$id, "_", x)]] == 1), logical(1))]
}

coduri_q12 <- function(Q, rec) vapply(names(Q$q12$randuri), function(k) rec[[paste0("q12_", k)]] %||% NA_character_, "")

# --- grafic Q9 ---------------------------------------------------------------------

grafic_q9 <- function(Q, rec) {
  d <- date_q9(Q, rec)
  d$y <- factor(d$eticheta, levels = rev(d$eticheta))
  d$text <- paste0(vapply(d$procent, format_ro, ""), "%")
  # Eticheta fiecărei activități stă deasupra barei, ca graficul să rămână
  # lizibil pe telefon (etichetele sunt lungi).
  etichete <- lapply(seq_len(nrow(d)), function(i) list(
    x = 0, y = d$eticheta[i], xref = "x", yref = "y", xanchor = "left", yanchor = "bottom",
    yshift = 11, showarrow = FALSE, align = "left", text = d$eticheta[i],
    font = list(size = 13, color = CULOARE_GRAFIC$text)))
  p <- plotly::plot_ly(
    d, x = ~procent, y = ~y, type = "bar", orientation = "h",
    marker = list(color = CULOARE_GRAFIC$bara),
    text = ~text, textposition = "outside", cliponaxis = FALSE,
    textfont = list(color = CULOARE_GRAFIC$text, size = 13),
    hovertext = ~paste0(eticheta, ": ", text), hoverinfo = "text"
  )
  plotly::layout(p,
      font = list(family = "Atkinson Hyperlegible, system-ui, sans-serif", color = CULOARE_GRAFIC$text, size = 13),
      separators = ", ",
      paper_bgcolor = "rgba(0,0,0,0)", plot_bgcolor = "rgba(0,0,0,0)",
      margin = list(l = 4, r = 40, t = 6, b = 30), bargap = 0.62,
      annotations = etichete,
      xaxis = list(range = c(0, max(100, max(d$procent, na.rm = TRUE) * 1.1)), ticksuffix = "%",
                   gridcolor = CULOARE_GRAFIC$grila, zeroline = TRUE, zerolinecolor = CULOARE_GRAFIC$axa,
                   fixedrange = TRUE, title = list(text = ""), dtick = 25),
      yaxis = list(showticklabels = FALSE, fixedrange = TRUE, title = list(text = "")),
      hoverlabel = list(bgcolor = CULOARE_GRAFIC$fundal_eticheta, font = list(color = CULOARE_GRAFIC$text_eticheta)),
      showlegend = FALSE
    ) |>
    plotly::config(displayModeBar = FALSE, responsive = TRUE) |>
    fara_polyfill()
}

# Polyfill-ul „typedarray” inclus de plotly este pentru browsere foarte vechi
# și produce o eroare în consolă în browserele actuale; nu este necesar.
fara_polyfill <- function(p) {
  p <- plotly::plotly_build(p)
  p$dependencies <- Filter(function(d) !identical(d$name, "typedarray"), p$dependencies)
  p
}

# --- comparație agregată -------------------------------------------------------------
# Numitorul fiecărei întrebări = răspunsurile valide (non-NA) la acea întrebare
# din completările valide (filtreaza_valide în R/12_indicatori.R). Procentele
# includ și răspunsul respondentului curent.

INTREBARI_COMPARATIE <- c("q13", "q14", "q24")

agregat_comparatie <- function(Q, df) {
  n <- nrow(df)
  out <- list(n = n, indicatori = list())
  if (n < COMPARATIE_MIN_RASPUNSURI) return(out)
  for (qid in INTREBARI_COMPARATIE) {
    q <- Q[[qid]]
    x <- df[[q$var]]
    valid <- sum(!is.na(x))
    if (valid < COMPARATIE_MIN_RASPUNSURI) next
    out$indicatori[[qid]] <- list(
      valid = valid,
      procente = vapply(names(q$optiuni), function(k) 100 * sum(x == k, na.rm = TRUE) / valid, 0))
  }
  out
}

# --- componente ----------------------------------------------------------------------

card <- function(titlu, ..., clasa = NULL, id = NULL, nivel = 3) {
  h <- if (nivel == 3) h3 else h4
  tags$section(class = paste("card-profil", clasa), id = id,
               `aria-labelledby` = if (!is.null(id)) paste0(id, "-t"),
               h(id = if (!is.null(id)) paste0(id, "-t"), titlu), ...)
}

sectiune_finala <- function(id, titlu, intro = NULL, ..., clasa = NULL) {
  tags$section(class = paste("f-sectiune", clasa), id = id, `aria-labelledby` = paste0(id, "-t"),
    div(class = "f-cap", h2(id = paste0(id, "-t"), titlu), if (!is.null(intro)) p(class = "f-intro", intro)),
    ...)
}

eticheta_sigura <- function(optiuni, x) {
  if (length(x) == 0 || is.na(x)) "—" else if (x %in% names(optiuni)) unname(optiuni[[x]]) else x
}

# Tabelul tematic al unui indicator (alternativa accesibilă la hartă).
tabel_tematic <- function(ind_id, d, cod_ales) {
  m <- INDICATORI_HARTA[[ind_id]]
  culoare <- function(i) {
    if (d$stare[i] %in% c("zero", "fara_date")) CULOARE_FARA_DATE
    else if (is.na(d$clasa[i])) CULOARE_SUPRIMAT else PALETA_TEMATICA[d$clasa[i]]
  }
  d <- d[order(d$denumire), ]
  tags$table(class = "tabel-tematic", `data-indicator` = ind_id,
    tags$caption(paste0(m$titlu, " (", m$unitate, "), pe cartiere")),
    tags$thead(tags$tr(tags$th(scope = "col", "Cartier"), tags$th(scope = "col", "Valoare"))),
    tags$tbody(lapply(seq_len(nrow(d)), function(i) tags$tr(
      class = paste(if (identical(d$cod[i], cod_ales)) "rand-ales", paste0("st-", d$stare[i])),
      tags$th(scope = "row", d$denumire[i],
              if (identical(d$cod[i], cod_ales)) span(class = "eticheta-aleasa", "cartierul dvs.")),
      tags$td(span(class = paste("mostra-tematica", if (d$stare[i] == "suprimat") "hasurat"),
                   style = paste0("background-color:", culoare(i)), `aria-hidden` = "true"),
              d$eticheta[i])))))
}

sectiune_harta <- function(rec, cartier, tematic) {
  cod <- rec$q01_zona
  are_poligoane <- length(coduri_cartiere_vectoriale()) > 0
  activ <- isTRUE(HARTA_TEMATICA_ACTIVA) && isTRUE(tematic$activ)

  selector <- if (activ) tags$fieldset(class = "selector-indicator", id = "selector-indicator",
    tags$legend("Indicator afișat"),
    div(class = "selector-optiuni",
      lapply(seq_along(INDICATORI_HARTA), function(i) {
        id <- names(INDICATORI_HARTA)[i]
        tags$label(class = "chip-indicator",
          tags$input(type = "radio", name = "indicator_harta", value = id, checked = if (i == 1) NA),
          span(INDICATORI_HARTA[[id]]$titlu))
      })),
    lapply(names(INDICATORI_HARTA), function(id)
      p(class = "descriere-indicator", `data-indicator` = id, hidden = if (id != names(INDICATORI_HARTA)[1]) NA,
        INDICATORI_HARTA[[id]]$descriere)))

  stare_tematic <- if (!isTRUE(HARTA_TEMATICA_ACTIVA)) NULL
    else if (!activ) div(class = "stare-goala",
      p(class = "stare-goala-titlu", "Indicatorii pe cartiere nu sunt încă disponibili"),
      p(paste0("Valorile pe cartiere apar după ce chestionarul are cel puțin ", HARTA_PRAG_TOTAL,
               " de completări valide. Până acum: ", tematic$total %||% 0, ".")))
    else if (!are_poligoane) div(class = "aviz-harta", role = "note",
      p(class = "aviz-titlu", "Harta pe cartiere nu este încă disponibilă"),
      p("Limitele oficiale ale celor 42 de cartiere există doar ca planuri scanate, fără coordonate. ",
        "Până la obținerea fișierului vectorial oficial, aceiași indicatori sunt afișați mai jos sub formă de tabel. ",
        "Culorile din tabel urmează aceeași scală pe care o va folosi harta."))

  tabele <- if (activ) {
    t <- div(class = "tabele-tematice",
      lapply(names(INDICATORI_HARTA), function(id) div(class = "tabel-tematic-cutie", `data-indicator` = id,
        hidden = if (id != names(INDICATORI_HARTA)[1]) NA,
        tabindex = "0", role = "region", `aria-label` = paste0("Tabel: ", INDICATORI_HARTA[[id]]$titlu),
        tabel_tematic(id, tematic$indicatori[[id]], cod))))
    if (are_poligoane) tags$details(class = "detalii", tags$summary("Vedeți valorile ca tabel"), t) else t
  }

  legenda_tabel <- if (activ) div(class = "legenda-tematica", `aria-label` = "Legenda culorilor",
    lapply(names(INDICATORI_HARTA), function(id) {
      cl <- if (identical(INDICATORI_HARTA[[id]]$tip, "numar")) CLASE_NUMAR$etichete else CLASE_PROCENT$etichete
      div(class = "legenda-indicator", `data-indicator` = id, hidden = if (id != names(INDICATORI_HARTA)[1]) NA,
        span(class = "legenda-titlu", paste0(INDICATORI_HARTA[[id]]$unitate, ": mai închis = valoare mai mare")),
        tags$ul(lapply(seq_along(cl), function(i) tags$li(
          span(class = "mostra-tematica", style = paste0("background-color:", PALETA_TEMATICA[i]), `aria-hidden` = "true"), cl[i])),
          tags$li(span(class = "mostra-tematica hasurat", style = paste0("background-color:", CULOARE_SUPRIMAT), `aria-hidden` = "true"),
                  if (identical(INDICATORI_HARTA[[id]]$tip, "numar")) paste0("sub ", HARTA_PRAG_NUMAR, " (valoare ascunsă)")
                  else paste0("date insuficiente (sub ", HARTA_PRAG_CARTIER, " respondenți)")),
          tags$li(span(class = "mostra-tematica", style = paste0("background-color:", CULOARE_FARA_DATE), `aria-hidden` = "true"),
                  if (identical(INDICATORI_HARTA[[id]]$tip, "numar")) "0 respondenți" else "fără răspunsuri")))
    }))

  fisa <- if (is.null(cartier)) {
    p("Pentru zona aleasă nu există date în tabelul HCL nr. 79/2023.")
  } else {
    tagList(
      p(class = "fisa-nume", cartier$denumire),
      p(class = "nota-mica", paste0("Cartierul nr. ", cartier$nr_hcl, " din anexa 1 la ", SURSA_HCL, ".")),
      local({
        v <- if (are_poligoane) info_cartiere_vectoriale()$verificare[[cod]]
        if (!is.null(v)) p(class = "nota-mica", id = "verificare-limita",
          paste0("Limita de pe hartă, comparată cu planul oficial de mai jos: ", v, "."),
          if (v == "incertă") " Pentru acest cartier, planul este referința.")
      }),
      h4("Delimitare, conform anexei 1"),
      p(class = "delimitare", gsub(" - ", " – ", cartier$delimitare, fixed = TRUE)),
      if (isTRUE(cartier$plan_exista)) tags$figure(class = "plan-oficial",
        tags$a(href = cartier$fisier_plan, target = "_blank", rel = "noopener",
               tags$img(src = cartier$fisier_plan, loading = "lazy", width = "1500", height = "1060",
                        alt = paste0("Planul scanat al cartierului ", cartier$denumire, " din anexa ", cartier$anexa_plan, " la HCL nr. 79/2023"))),
        tags$figcaption(paste0("Anexa ", cartier$anexa_plan, " la HCL nr. 79/2023: planul cartierului, scanat (fundal cartografic Esri, tipărit pe plan). ",
                               "Planul nu are coordonate, de aceea nu este suprapus pe hartă."))))
  }

  sectiune_finala("f-harta", "Constanța pe hartă",
    paste0(if (are_poligoane) "Harta arată limita municipiului și cele 42 de cartiere din HCL nr. 79/2023, cu limite orientative. " else "Harta arată limita administrativă a municipiului. ", "Valorile pe cartiere descriu doar participarea și comportamentele declarate în chestionar; nu măsoară poluarea și nu arată răspunsuri individuale."),
    stare_tematic, selector,
    div(class = "grila-harta",
      div(class = "card-profil c-harta",
        div(id = "harta-constanta", class = "harta", role = "region",
            `aria-label` = "Harta municipiului Constanța și a localităților vecine",
            p(class = "harta-incarcare", "Se încarcă harta…")),
        div(id = "harta-detalii", class = "harta-detalii", `aria-live` = "polite"),
        if (isTRUE(HARTA_FUNDAL_OSM_PERMIS)) div(class = "harta-fundal",
          tags$button(type = "button", id = "harta-fundal-osm", class = "btn-secundar btn-mic",
                      `aria-pressed` = "false", "Afișează fundalul OpenStreetMap"),
          p(class = "nota-mica", "Fundalul se încarcă de pe serverele OpenStreetMap numai dacă apăsați butonul; acestea primesc atunci adresa IP a dispozitivului.")),
        p(class = "nota-mica harta-sursa", "Limite administrative: ", link_sursa("geoboundaries"), "."),
        if (are_poligoane) {
          info <- info_cartiere_vectoriale()
          p(class = "nota-mica harta-sursa", id = "nota-limite-cartiere",
            if (isTRUE(info$oficiale)) "Limitele cartierelor: date oficiale. "
            else "Limitele cartierelor sunt orientative, nu oficiale: urmează delimitările aprobate, dar sunt desenate aproximativ. ",
            if (nzchar(info$sursa %||% "")) paste0("Sursa: ", info$sursa))
        }),
      card("Cartierul ales la întrebarea 1", id = "c-cartier", clasa = "c-cartier", fisa)),
    if (activ) div(class = "tematic-jos", legenda_tabel, tabele))
}

profil_ui <- function(Q, rec, mod, agregat = NULL, tematic = NULL, cartier = NULL, durata_test = NULL) {
  et <- function(q, x) eticheta_sigura(q$optiuni, x)

  cuprins <- tags$nav(class = "f-cuprins", `aria-label` = "Secțiunile profilului",
    tags$ul(
      tags$li(tags$a(href = "#f-profil", "Profil")),
      tags$li(tags$a(href = "#f-harta", "Harta")),
      if (isTRUE(COMPARATIE_ACTIVA)) tags$li(tags$a(href = "#f-comparatie", "Comparație")),
      tags$li(tags$a(href = "#f-recomandari", "Recomandări")),
      tags$li(tags$a(href = "#f-limite", "Ce reprezintă rezultatele"))))

  # 1. Profil ---------------------------------------------------------------------------
  lppz <- litri_pe_persoana_zi(rec)
  pe_scurt <- card("Pe scurt", id = "c-pe-scurt", clasa = "c-pe-scurt",
    tags$dl(class = "date-scurte",
      tags$dt("Cartierul"), tags$dd(et(Q$q01, rec$q01_zona)),
      tags$dt("Locuința"), tags$dd(et(Q$q04, rec$q04_locuinta)),
      tags$dt("Persoane în gospodărie"), tags$dd(rec$q05_nr_persoane),
      tags$dt("Racordată la canalizare"), tags$dd(et(Q$q07, rec$q07_canalizare))))

  consum <- card("Consumul estimat", id = "c-consum", clasa = "c-consum",
    if (!is.na(lppz)) tagList(
      div(class = "cifra-mare", span(class = "cifra", format_ro(lppz, 0)),
          span(class = "cifra-et", "litri pe persoană pe zi")),
      div(class = "nivel-apa", `aria-hidden` = "true", span(class = "nivel-val")),
      p(class = "nota-mica",
        paste0("Estimare aritmetică din răspunsurile la întrebările 5 și 8: (", format_ro(rec$q08_apa_rece_m3), " m³ apă rece",
               if (!is.na(rec$q08_apa_calda_m3)) paste0(" + ", format_ro(rec$q08_apa_calda_m3), " m³ apă caldă") else "",
               ") × 1 000 ÷ 30 de zile ÷ ", rec$q05_nr_persoane, if (rec$q05_nr_persoane == 1) " persoană." else " persoane.")),
      p(class = "nota-mica",
        "Nu este o măsurătoare: depinde de cât de exact a fost estimat consumul lunar și presupune o lună de 30 de zile. ",
        "Nu o comparăm cu o normă sau cu alte gospodării."))
    else p("La întrebarea 8 ați ales „Nu știu”, deci nu calculăm un consum pe persoană."))

  d9 <- date_q9(Q, rec)
  tabel9 <- tags$table(class = "tabel-simplu",
    tags$caption("Valorile din grafic"),
    tags$thead(tags$tr(tags$th(scope = "col", "Activitate"), tags$th(scope = "col", "Procent"))),
    tags$tbody(lapply(seq_len(nrow(d9)), function(i) tags$tr(
      tags$th(scope = "row", d9$eticheta[i]), tags$td(paste0(format_ro(d9$procent[i]), "%"))))))
  q9 <- card("Cum ați împărțit consumul", id = "c-q9", clasa = "c-q9",
    p(class = "nota-mica", "Estimările de la întrebarea 9, de la cea mai mare la cea mai mică pondere. Treceți cu mouse-ul (sau atingeți) o bară pentru valoare."),
    plotly::plotlyOutput("grafic_q9", height = "400px"),
    tags$details(class = "detalii", tags$summary("Vedeți valorile ca tabel"), tabel9))

  trepte <- c("nu_am_auzit", "auzit_nu_stiu", "idee_generala", "cunosc_exemple")
  r24 <- rec$q24_micropoluanti
  informare <- card("Informare și interes", id = "c-informare", clasa = "c-informare",
    div(class = "chips-raspuns",
      div(class = "chip-raspuns", span(class = "chip-et", "Informații oficiale (întrebarea 17)"), span(class = "chip-val", et(Q$q17, rec$q17_informare))),
      div(class = "chip-raspuns", span(class = "chip-et", "Interes (întrebarea 18)"), span(class = "chip-val", et(Q$q18, rec$q18_interes))),
      div(class = "chip-raspuns", span(class = "chip-et", "După eliminare (întrebarea 23)"), span(class = "chip-val", et(Q$q23, rec$q23_gandire_dupa_eliminare)))),
    h4("Termenul „micropoluanți” (întrebarea 24)"),
    if (identical(r24, "nu_pot_aprecia")) p("Ați ales „Nu pot aprecia”."),
    tags$ol(class = "trepte", `aria-label` = "Variantele de la întrebarea 24, în ordine",
      lapply(seq_along(trepte), function(i) tags$li(
        class = paste("treapta", if (identical(trepte[i], r24)) "treapta-aleasa"),
        `aria-current` = if (identical(trepte[i], r24)) "true",
        span(class = "treapta-nr", `aria-hidden` = "true", i),
        span(class = "treapta-text", Q$q24$optiuni[[trepte[i]]]),
        if (identical(trepte[i], r24)) span(class = "eticheta-aleasa", "răspunsul dvs.")))),
    p(class = "explicatie", text_micropoluanti()))

  sel16 <- selectate(Q$q16, rec)
  apa_uzata <- card("Apa uzată", id = "c-apa-uzata", clasa = "c-apa-uzata",
    tags$dl(class = "date-scurte date-scurte-deschise",
      tags$dt("Uleiul alimentar uzat (întrebarea 13)"), tags$dd(et(Q$q13, rec$q13_ulei)),
      tags$dt("Unde credeți că ajunge apa uzată (întrebarea 14)"), tags$dd(et(Q$q14, rec$q14_traseu_apa_uzata)),
      tags$dt("Rolul stației de epurare (întrebarea 15)"), tags$dd(et(Q$q15, rec$q15_rol_epurare)),
      tags$dt("Ce poate ajunge în canalizare (întrebarea 16)"),
      tags$dd(if (!length(sel16)) "—" else if (all(sel16 %in% Q$q16$exclusive)) "Nu știu"
              else div(class = "chips-mici", lapply(sel16, function(k) span(class = "chip-mic", Q$q16$optiuni[[k]]))))),
    p(class = "explicatie", text_epurare()))

  s_profil <- sectiune_finala("f-profil", "Profilul dumneavoastră",
    "Construit din răspunsurile pe care tocmai le-ați trimis.",
    div(class = "bento",
      pe_scurt, consum, q9, apa_uzata, informare),
    if (identical(mod, "test") && !is.null(durata_test))
      div(class = "nota-autoare", span(class = "nota-autoare-et", "Cronometru, doar în modul test (nu se salvează)"),
          sprintf("De la „Încep chestionarul” până la trimitere: %d min %02d s. Folosiți mai multe completări de probă, făcute de persoane diferite, pentru a stabili durata estimată (DURATA_ESTIMATA_MINUTE).",
                  floor(durata_test / 60), round(durata_test %% 60))))

  # 2. Harta -------------------------------------------------------------------------------
  s_harta <- sectiune_harta(rec, cartier, tematic)

  # 3. Comparație ----------------------------------------------------------------------------
  s_comparatie <- if (isTRUE(COMPARATIE_ACTIVA)) {
    n <- agregat$n %||% 0L
    continut <- if (n < COMPARATIE_MIN_RASPUNSURI || !length(agregat$indicatori)) {
      div(class = "stare-goala",
        p(class = "stare-goala-titlu", "Comparația nu este încă disponibilă"),
        p(paste0("Procentele apar după ce chestionarul are cel puțin ", COMPARATIE_MIN_RASPUNSURI,
                 " de completări valide, ca să nu fie calculate din prea puține răspunsuri. ",
                 "Până acum: ", n, " ", if (n == 1) "completare" else "completări", ".")))
    } else {
      tagList(
        if (identical(mod, "test")) p(class = "nota-autoare", span(class = "nota-autoare-et", "Mod test"),
                                      "Procentele sunt calculate din baza de date de test, care poate conține răspunsuri sintetice."),
        div(class = "grila-comparatie", lapply(names(agregat$indicatori), function(qid) {
          q <- Q[[qid]]; ind <- agregat$indicatori[[qid]]; ales <- rec[[q$var]]
          card(paste0("Întrebarea ", q$nr, ". ", q$titlu), clasa = "c-comparatie", nivel = 4,
            p(class = "nota-mica", paste0("Din ", ind$valid, " răspunsuri valide, inclusiv al dumneavoastră.")),
            tags$ul(class = "bare", lapply(names(q$optiuni), function(k) {
              pr <- ind$procente[[k]]
              tags$li(class = paste("bara-rand", if (identical(k, ales)) "bara-aleasa"),
                span(class = "bara-et", q$optiuni[[k]],
                     if (identical(k, ales)) span(class = "eticheta-aleasa", "răspunsul dvs.")),
                span(class = "bara-pista", `aria-hidden` = "true",
                     span(class = "bara-umplere2", style = sprintf("width:%.1f%%", pr))),
                span(class = "bara-val", paste0(format_ro(round(pr)), "%")))
            })))
        })))
    }
    sectiune_finala("f-comparatie", "Comparație cu ceilalți respondenți",
      "Procente agregate pentru trei întrebări. Eșantionul este format din persoanele care au completat chestionarul și nu este reprezentativ pentru toți locuitorii Constanței.",
      continut)
  }

  # 4. Recomandări (R/13_recomandari.R) ---------------------------------------------------------
  s_recomandari <- sectiune_recomandari(Q, rec)

  # 5. Limite ---------------------------------------------------------------------------------------
  s_limite <- sectiune_finala("f-limite", "Ce reprezintă aceste rezultate", NULL,
    div(class = "card-profil c-limite",
      tags$ul(class = "lista-simpla",
        tags$li("Profilul arată răspunsurile dumneavoastră. Nu este o evaluare tehnică a locuinței, a rețelei de canalizare sau a stației de epurare."),
        tags$li("Consumul pe persoană și repartiția pe activități sunt estimări din valorile introduse, nu măsurători."),
        tags$li("Nu calculăm scoruri și nu clasificăm răspunsurile sau cartierele ca bune sau rele."),
        tags$li("Valorile pe cartiere descriu doar respondenții: un cartier cu mai mulți respondenți nu este „mai poluat”, iar procentele se bazează pe comportamente declarate."),
        tags$li("Sursele internaționale descriu alte țări; nu sunt măsurători din Constanța."),
        tags$li("Pagina nu se salvează separat; după ce o închideți, nu o mai puteți redeschide."))))

  tagList(cuprins, s_profil, s_harta, s_comparatie, s_recomandari, s_limite, lista_surse())
}
