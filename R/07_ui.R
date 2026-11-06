# =============================================================================
# 07_ui.R — paginile aplicației (respondent și administrare)
# -----------------------------------------------------------------------------
# Paginile respondentului: acasa (pagina de start) -> intro (informare și
# acord) -> s1–s4 -> revizuire -> final. Toate stau în același document
# (pagini ascunse), ca răspunsurile să rămână în formular la navigare.
# Din versiunea 3.1 nu există limită de vârstă (pagina „neeligibil” a fost scoasă).
# =============================================================================

tema <- function() {
  bslib::bs_theme(
    version = 5,
    bg = "#F3EBDB", fg = "#0D1F45",
    primary = "#0D1F45", secondary = "#2F5F86", success = "#2F5F86",
    danger = "#A3261E", info = "#2F5F86",
    base_font = bslib::font_collection("Atkinson Hyperlegible", "system-ui", "-apple-system",
                                       "Segoe UI", "Roboto", "sans-serif"),
    heading_font = bslib::font_collection("Bricolage Grotesque", "Atkinson Hyperlegible", "sans-serif"),
    "font-size-base" = "1.0625rem",
    "line-height-base" = "1.55",
    "border-radius" = ".75rem",
    "input-border-color" = "#6E7486",
    "input-bg" = "#FFFBF3"
  )
}

# --- informare și consimțământ --------------------------------------------------

citeste_informare <- function(fisier = FISIER_INFORMARE) {
  if (!file.exists(fisier)) stop("Lipsește fișierul de informare: ", fisier)
  paste(readLines(fisier, encoding = "UTF-8", warn = FALSE), collapse = "\n")
}

campuri_de_completat <- function(text) {
  m <- regmatches(text, gregexpr("\\[\\[[^]]+\\]\\]", text))[[1]]
  unique(gsub("^\\[\\[|\\]\\]$", "", m))
}

# Informarea trebuie să aibă o secțiune „## Păstrarea datelor…” (cât timp se
# păstrează datele, cine are acces, temeiul). Până atunci, zona de
# administrare și pornirea în producție o semnalează ca blocant.
informare_are_pastrare <- function(text = citeste_informare()) grepl("(^|\n)## Păstrarea datelor", text)

informare_html <- function(text) {
  h <- commonmark::markdown_html(text, extensions = FALSE)
  # titlurile ## din fișier devin h3, sub titlul paginii (h2)
  h <- gsub("<(/?)h2>", "<\\1h3>", h)
  h <- gsub("\\[\\[([^]]+)\\]\\]", '<mark class="de-completat">[de completat: \\1]</mark>', h)
  HTML(h)
}

# --- elemente comune ---------------------------------------------------------------

cap_html <- function(public = TRUE) {
  tags$head(
    tags$meta(name = "description", content = paste0("Chestionar de cercetare: ", TITLU_ACADEMIC, ".")),
    tags$meta(name = "theme-color", content = "#0D1F45"),
    tags$meta(name = "robots", content = "noindex"),
    tags$link(rel = "icon", type = "image/svg+xml", href = "img/favicon.svg"),
    if (public) tags$link(rel = "stylesheet", href = "lib/leaflet/leaflet.css"),
    tags$link(rel = "stylesheet", href = "styles.css"),
    if (public) tags$script(src = "lib/leaflet/leaflet.js"),
    tags$script(src = "app.js"),
    if (public) tags$script(src = "harta.js")
  )
}

# Bara de sus. Nu apare pe pagina de start, unde titlul lucrării este mare.
antet <- function(text = TITLU_SCURT, eticheta = "Lucrare de licență, Universitatea din București") {
  tags$header(class = "antet",
    div(class = "antet-interior",
        tags$img(src = "img/emblema.svg", alt = "", class = "emblema", width = "48", height = "48"),
        div(class = "antet-text",
            p(class = "antet-marca", text),
            p(class = "antet-eticheta", eticheta))))
}

nav_progres <- function() {
  tags$nav(class = "progres", id = "progres", `aria-label` = "Progresul completării",
    div(class = "progres-cap",
      p(class = "progres-stare", id = "progres-stare", `aria-live` = "polite", ""),
      p(class = "progres-procent", id = "progres-procent", `aria-hidden` = "true", "")),
    div(class = "progres-bara", role = "progressbar", `aria-valuemin` = "0", `aria-valuemax` = "100",
        `aria-valuenow` = "0", `aria-valuetext` = "", `aria-label` = "Progresul completării",
        div(class = "progres-umplere")),
    tags$ol(class = "progres-pasi",
      lapply(1:4, function(s) tags$li(class = "pas", `data-pas` = s,
        span(class = "pas-nr", `aria-hidden` = "true", s),
        span(class = "pas-text", SECTIUNI[[s]]$scurt))),
      tags$li(class = "pas", `data-pas` = 5,
        span(class = "pas-nr", `aria-hidden` = "true", "✓"),
        span(class = "pas-text", "Verificare"))))
}

# Ilustrația coastei, inclusă direct în pagină ca să poată fi animată din CSS.
grafica_coasta <- function() {
  f <- file.path("www", "img", "coasta.svg")
  if (!file.exists(f)) return(NULL)
  HTML(paste(readLines(f, encoding = "UTF-8", warn = FALSE), collapse = "\n"))
}

sclipire <- function(clasa) {
  HTML(sprintf('<svg class="sclipire %s" viewBox="0 0 40 40" aria-hidden="true" focusable="false"><path d="M20 0 C21.5 13 27 18.5 40 20 C27 21.5 21.5 27 20 40 C18.5 27 13 21.5 0 20 C13 18.5 18.5 13 20 0 Z"/></svg>', clasa))
}

durata_text <- function() {
  if (is.null(DURATA_ESTIMATA_MINUTE) || !nzchar(DURATA_ESTIMATA_MINUTE)) return(NULL)
  paste0("aproximativ ", DURATA_ESTIMATA_MINUTE, " minute")
}

# --- paginile respondentului ----------------------------------------------------------

pagina_acasa <- function(mod) {
  durata <- durata_text()
  tagList(
    tags$section(class = "start", `aria-labelledby` = "titlu-acasa",
      div(class = "start-text",
        p(class = "start-eticheta", "Chestionar de cercetare pentru o lucrare de licență"),
        h1(id = "titlu-acasa", class = "start-titlu", tabindex = "-1", TITLU_ACADEMIC),
        p(class = "start-lead",
          "Vă invităm să răspundeți la întrebări despre folosirea apei în gospodărie, despre ce ajunge în canalizare ",
          "și despre informațiile pe care le aveți privind apele uzate din Constanța. ",
          "La final veți vedea un profil construit din propriile răspunsuri."),
        tags$ul(class = "start-fapte",
          tags$li(span(class = "fapt-cifra", "27"), span(class = "fapt-text", "întrebări, în 4 secțiuni")),
          if (!is.null(durata)) tags$li(span(class = "fapt-cifra", DURATA_ESTIMATA_MINUTE),
                                        span(class = "fapt-text", "minute, estimat"))
          else if (identical(mod, "test")) tags$li(class = "fapt-lipsa",
                                        span(class = "fapt-cifra", "?"),
                                        span(class = "fapt-text", "durata nu este încă măsurată (vizibil doar în modul test)")),
          tags$li(span(class = "fapt-cifra fapt-cifra-text", "fără nume"), span(class = "fapt-text", "nu cerem nume, e-mail sau telefon")),
          tags$li(span(class = "fapt-cifra fapt-cifra-text", "voluntar"), span(class = "fapt-text", "participarea este voluntară"))),
        div(class = "start-actiuni",
          actionButton("incepe", "Începe: informare și acord", class = "btn-principal btn-mare")),
        div(class = "autoare", `aria-label` = "Autoarea",
          p(class = "autoare-nume", AUTOARE$nume),
          p(class = "autoare-inst", AUTOARE$institutie),
          p(class = "autoare-email", tags$a(href = paste0("mailto:", AUTOARE$email), AUTOARE$email)))),
      div(class = "start-grafica",
        sclipire("s1"), sclipire("s2"), sclipire("s3"),
        div(class = "orbita", `aria-hidden` = "true"),
        grafica_coasta())),
    div(class = "banda", `aria-hidden` = "true",
      div(class = "banda-pista",
        lapply(1:2, function(i) span(class = "banda-text",
          "apă ✦ canalizare ✦ epurare ✦ Constanța ✦ Marea Neagră ✦ gospodării ✦ apă ✦ canalizare ✦ epurare ✦ Constanța ✦ Marea Neagră ✦ gospodării ✦ "))))
  )
}

pagina_intro <- function(informare, mod) {
  lipsa <- campuri_de_completat(informare)
  tagList(
    div(class = "cap-sectiune",
        p(class = "sectiune-nr", "Înainte de întrebări"),
        h2(id = "titlu-intro", tabindex = "-1", "Informare și acord"),
        p(class = "sectiune-info", "Citiți informațiile de mai jos. Întrebările încep numai după ce bifați acordul.")),
    div(class = "intro",
        if (identical(mod, "test") && length(lipsa))
          div(class = "nota-autoare",
              span(class = "nota-autoare-et", "Notă pentru autoare, vizibilă doar în modul test"),
              paste0("Textul de informare mai are ", length(lipsa),
                     " câmpuri de completat (marcate cu galben). Se editează în config/informare_consimtamant.md.")),
        tags$article(class = "informare", `aria-labelledby` = "titlu-informare",
          h3(id = "titlu-informare", class = "visually-hidden", "Textul informării"),
          informare_html(informare)),
        div(class = "conditii",
          div(class = "consimtamant",
            checkboxInput("consimtamant", "Am citit informațiile de mai sus și sunt de acord să particip.", FALSE),
            div(class = "q-eroare", id = "eroare-consimtamant"))),
        div(class = "navigare navigare-intro",
            actionButton("inapoi_intro", "Înapoi", class = "btn-secundar"),
            actionButton("start", "Încep chestionarul", class = "btn-principal btn-inainte")))
  )
}

pagina_sectiune <- function(Q, s, mod) {
  qs <- intrebari_sectiune(Q, s)
  nr <- vapply(qs, `[[`, 0, "nr")
  are_optionale <- any(!vapply(qs, function(q) isTRUE(q$obligatorie), logical(1)))
  tagList(
    div(class = "cap-sectiune",
        p(class = "sectiune-nr", paste0("Secțiunea ", s, " din 4, întrebările ", min(nr), "–", max(nr), " din 27")),
        h2(id = paste0("titlu-s", s), tabindex = "-1", SECTIUNI[[s]]$titlu),
        p(class = "sectiune-info",
          if (are_optionale) "Toate întrebările sunt obligatorii, cu excepția celor marcate „opțional”."
          else "Toate întrebările din această secțiune sunt obligatorii.")),
    div(class = "sumar-erori", id = paste0("sumar-erori-s", s), role = "alert", tabindex = "-1", hidden = NA),
    div(class = "lista-intrebari", lapply(qs, bloc_intrebare, mod = mod)),
    div(class = "navigare",
        actionButton(paste0("inapoi_s", s), "Înapoi", class = "btn-secundar"),
        actionButton(paste0("inainte_s", s),
                     if (s < 4) "Continuă" else "Verifică răspunsurile",
                     class = "btn-principal btn-inainte",
                     `data-text-normal` = if (s < 4) "Continuă" else "Verifică răspunsurile",
                     `data-text-revizuire` = "Revino la verificare"))
  )
}

pagina_revizuire <- function() {
  tagList(
    div(class = "cap-sectiune",
        p(class = "sectiune-nr", "Ultimul pas"),
        h2(id = "titlu-revizuire", tabindex = "-1", "Verificați răspunsurile"),
        p(class = "sectiune-info",
          "Nimic nu a fost salvat încă. Pentru a schimba un răspuns, apăsați „Modifică” la secțiunea respectivă. ",
          "Când totul este în regulă, apăsați „Trimite răspunsurile”.")),
    uiOutput("rezumat_revizuire"),
    div(class = "eroare-trimitere", id = "eroare-trimitere", role = "alert", hidden = NA),
    div(class = "navigare",
        actionButton("inapoi_revizuire", "Înapoi", class = "btn-secundar"),
        actionButton("trimite", "Trimite răspunsurile", class = "btn-principal btn-trimite",
                     `data-text-normal` = "Trimite răspunsurile",
                     `data-text-incarcare` = "Se trimite…"))
  )
}

# Starea de final: picătura care cade, undele, mulțumirea, apoi profilul.
pagina_finala <- function(mod) {
  tagList(
    tags$section(class = "gata", `aria-labelledby` = "titlu-final",
      div(class = "gata-scena", `aria-hidden` = "true",
        HTML('<svg class="gata-svg" viewBox="0 0 400 300" focusable="false">
  <defs><linearGradient id="picatura-crom" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#FFFFFF"/><stop offset="0.4" stop-color="#C9D3E2"/>
    <stop offset="0.7" stop-color="#7F96BC"/><stop offset="1" stop-color="#1B3168"/></linearGradient></defs>
  <g class="gata-unde"><ellipse cx="200" cy="232" rx="40" ry="10"/><ellipse cx="200" cy="232" rx="40" ry="10"/><ellipse cx="200" cy="232" rx="40" ry="10"/></g>
  <path class="gata-picatura" d="M200 40 C200 40 168 88 168 112 a32 32 0 0 0 64 0 C232 88 200 40 200 40 Z" fill="url(#picatura-crom)"/>
  <g class="gata-stropi"><circle cx="170" cy="222" r="4"/><circle cx="232" cy="218" r="3"/><circle cx="188" cy="210" r="2.5"/><circle cx="214" cy="208" r="2.5"/></g>
</svg>'),
        sclipire("g1"), sclipire("g2")),
      div(class = "gata-text",
        h2(id = "titlu-final", tabindex = "-1", "Mulțumim! Răspunsurile au ajuns la destinație."),
        p("Ca apa care pleacă din locuință, răspunsurile dumneavoastră și-au făcut drumul până la capăt: au fost salvate. ",
          "Mai jos este profilul construit numai din ele; pagina nu se salvează separat."),
        div(class = "gata-actiuni",
          tags$a(class = "btn-principal btn-mare", href = "#f-profil", id = "spre-profil", "Vedeți profilul dumneavoastră"),
          if (identical(mod, "test"))
            actionButton("din_nou", "Completează din nou (mod test)", class = "btn-secundar")))),
    uiOutput("profil")
  )
}

ui_public <- function(Q, mod) {
  informare <- citeste_informare()
  fluidPage(
    theme = tema(), lang = "ro", title = TITLU_ACADEMIC,
    cap_html(public = TRUE),
    tags$a(class = "salt-continut", href = "#continut", "Salt la conținut"),
    if (identical(mod, "test"))
      div(class = "banda-test", role = "note",
          strong("Mod test."), " Răspunsurile se salvează în baza de date de test, separat de cele reale."),
    antet(),
    nav_progres(),
    tags$main(id = "continut", class = "continut", tabindex = "-1",
      tabsetPanel(id = "pagini", type = "hidden", selected = "acasa",
        tabPanelBody("acasa", pagina_acasa(mod)),
        tabPanelBody("intro", pagina_intro(informare, mod)),
        tabPanelBody("s1", pagina_sectiune(Q, 1, mod)),
        tabPanelBody("s2", pagina_sectiune(Q, 2, mod)),
        tabPanelBody("s3", pagina_sectiune(Q, 3, mod)),
        tabPanelBody("s4", pagina_sectiune(Q, 4, mod)),
        tabPanelBody("revizuire", pagina_revizuire()),
        tabPanelBody("final", pagina_finala(mod)))),
    # Tranziția dintre pagini: un val care trece peste ecran (decorativ; oprit
    # când sistemul cere mișcare redusă).
    div(id = "tranzitie", class = "tranzitie", `aria-hidden` = "true",
      HTML('<svg viewBox="0 0 1440 900" preserveAspectRatio="none" focusable="false"><path class="val-1" d="M0 120 C240 40 480 200 720 120 C960 40 1200 200 1440 120 V900 H0 Z"/><path class="val-2" d="M0 180 C260 100 520 260 780 170 C1040 80 1240 230 1440 160 V900 H0 Z"/></svg>'),
      sclipire("t1")),
    tags$footer(class = "subsol",
      p(class = "subsol-titlu", TITLU_ACADEMIC),
      p(paste0(AUTOARE$nume, ", ", AUTOARE$institutie, ". "),
        tags$a(href = paste0("mailto:", AUTOARE$email), AUTOARE$email)),
      p("Chestionar anonim: nu cere nume, e-mail sau adresă și nu folosește cookie-uri. ",
        "Răspunsurile se salvează numai după apăsarea butonului „Trimite răspunsurile”."),
      p("Hartă: limite administrative ANCPI (geoBoundaries, CC BY 4.0); cartiere și planuri: HCL nr. 79/2023 a Consiliului Local Constanța; ",
        "limitele cartierelor, desenate pe date, și fundalul opțional © ", tags$a(href = "https://www.openstreetmap.org/copyright", target = "_blank", rel = "noopener", "contribuitorii OpenStreetMap"), " (ODbL)."),
      p(class = "subsol-versiune", paste0("Versiunea aplicației ", VERSIUNE_APLICATIE)))
  )
}

# --- administrare -----------------------------------------------------------------------

ui_admin <- function(mod) {
  fluidPage(
    theme = tema(), lang = "ro", title = paste("Administrare –", TITLU_SCURT),
    cap_html(public = FALSE),
    tags$script(HTML("document.documentElement.classList.add('admin');")),
    if (identical(mod, "test"))
      div(class = "banda-test", role = "note", strong("Mod test."), " Zona de administrare arată baza de date de test."),
    antet(eticheta = "Zona de administrare. Nu distribuiți această adresă."),
    tags$main(id = "continut", class = "continut continut-admin",
      h1(class = "admin-titlu", paste("Administrare:", TITLU_SCURT)),
      uiOutput("admin_continut"))
  )
}
