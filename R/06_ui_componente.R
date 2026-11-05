# =============================================================================
# 06_ui_componente.R — elementele de interfață pentru fiecare tip de întrebare
# -----------------------------------------------------------------------------
# Controalele folosesc legăturile standard Shiny (radio, checkbox, number,
# select, textarea). Matricele sunt scrise ca HTML propriu, dar păstrează
# clasa `shiny-input-radiogroup`, deci Shiny le citește ca butoane radio
# obișnuite (un input per rând).
# =============================================================================

alegeri <- function(o) stats::setNames(names(o), unname(o))

# Câmp numeric cu unitate afișată în dreapta. inputmode controlează tastatura
# de pe telefon (numeric = doar cifre; decimal = cifre și virgulă).
camp_numar <- function(id, eticheta, unitate = NULL, min = 0, max = NULL,
                       step = "1", inputmode = "numeric", clasa = NULL) {
  div(class = paste("form-group shiny-input-container camp-numar", clasa),
      tags$label(class = "control-label", `for` = id, eticheta),
      div(class = "camp-cu-unitate",
          tags$input(id = id, type = "number", class = "form-control",
                     min = min, max = max, step = step, inputmode = inputmode,
                     autocomplete = "off",
                     `aria-describedby` = paste0("eroare-", sub("_.*$", "", id))),
          if (!is.null(unitate)) span(class = "unitate", `aria-hidden` = "true", unitate)))
}

matrice_radio <- function(prefix, randuri, coloane, antet_randuri = "", clasa = "") {
  antet <- div(class = "mx-antet", `aria-hidden` = "true",
               div(class = "mx-colt", antet_randuri),
               lapply(unname(coloane), function(cn) div(class = "mx-col", cn)))
  rows <- lapply(names(randuri), function(k) {
    id <- paste0(prefix, k)
    div(id = id, class = "shiny-input-radiogroup mx-rand", role = "radiogroup",
        `aria-labelledby` = paste0(id, "-et"),
        div(class = "mx-et", id = paste0(id, "-et"), randuri[[k]]),
        div(class = "mx-optiuni",
            lapply(names(coloane), function(cod) {
              tags$label(class = "mx-celula",
                         tags$input(type = "radio", name = id, value = cod),
                         span(class = "mx-text", coloane[[cod]]))
            })))
  })
  div(class = paste("mx", clasa), antet, rows)
}

control_intrebare <- function(q) {
  switch(q$tip,

    lista = selectInput(q$id, q$text,
                        choices = c("Alegeți din listă" = "", alegeri(q$optiuni)),
                        selected = "", selectize = FALSE, width = "100%"),

    unic = radioButtons(q$id, q$text, choices = alegeri(q$optiuni),
                        selected = character(0), width = "100%"),

    multiplu = {
      cb <- checkboxGroupInput(q$id, q$text, choices = alegeri(q$optiuni), width = "100%")
      if (length(q$exclusive)) {
        cb <- htmltools::tagAppendAttributes(
          cb, `data-exclusive` = jsonlite::toJSON(q$exclusive, auto_unbox = FALSE))
      }
      cb
    },

    numar = camp_numar(q$id, q$text, q$unitate, min = 1, max = LIMITA_PERSOANE_GOSPODARIE),

    numere_grup = tags$fieldset(class = "grup-campuri",
      tags$legend(class = "control-label", q$text),
      p(class = "camp-indiciu", id = "q06-indiciu", "Puteți lăsa goale categoriile în care nu este nicio persoană: un câmp gol se socotește 0."),
      div(class = "grila-numere",
          lapply(names(q$campuri), function(k)
            camp_numar(paste0("q06_", k), q$campuri[[k]], min = 0, max = LIMITA_PERSOANE_GOSPODARIE))),
      div(class = "total-live", id = "q06-total", `aria-live` = "polite",
          `data-tinta` = "q05", "Total: 0 persoane")),

    consum_apa = tags$fieldset(class = "grup-campuri",
      tags$legend(class = "control-label", q$text),
      div(class = "grila-apa",
          camp_numar("q08_rece", q$campuri[["rece"]], "m³/lună", min = 0, max = LIMITA_M3_PE_LUNA,
                     step = "any", inputmode = "decimal"),
          camp_numar("q08_calda", q$campuri[["calda"]], "m³/lună", min = 0, max = LIMITA_M3_PE_LUNA,
                     step = "any", inputmode = "decimal")),
      div(class = "optiune-nu-stiu", checkboxInput("q08_nu_stiu", q$eticheta_nu_stiu, FALSE))),

    procente = tags$fieldset(class = "grup-campuri",
      tags$legend(class = "control-label", q$text),
      p(class = "camp-indiciu", id = "q09-indiciu", "Completați doar activitățile care vă privesc: un câmp gol se socotește 0%."),
      div(class = "lista-procente",
          lapply(names(q$campuri), function(k)
            camp_numar(paste0("q09_", k), q$campuri[[k]], "%", min = 0, max = 100,
                       step = "any", inputmode = "decimal", clasa = "rand-procent"))),
      div(class = "total-live total-procente", id = "q09-total", `aria-live` = "polite",
          div(class = "bara-total", div(class = "bara-umplere")),
          span(class = "text-total", "Total: 0% din 100%"))),

    matrice = tags$div(
      p(class = "control-label", id = "q12-text", q$text),
      matrice_radio("q12_", q$randuri, q$coloane, q$antet_randuri, "mx-motive")),

    matrice_scala = tags$div(
      p(class = "control-label", q$text),
      if (!is.null(Q21_ANCORE)) div(class = "ancore-scala",
          span(paste0("1 = ", Q21_ANCORE[["min"]])), span(paste0("5 = ", Q21_ANCORE[["max"]]))),
      matrice_radio("q21_", q$randuri, q$coloane, q$antet_randuri, "mx-scala")),

    text = div(
      htmltools::tagAppendAttributes(
        textAreaInput(q$id, q$text, value = "", width = "100%", rows = 4,
                      placeholder = q$eticheta_camp, resize = "vertical"),
        .cssSelector = "textarea", maxlength = LUNGIME_MAXIMA_Q25),
      div(class = "contor", id = "q25-contor", `aria-live` = "polite",
          paste0("0 / ", LUNGIME_MAXIMA_Q25, " caractere"))),

    stop("Tip necunoscut: ", q$tip)
  )
}

bloc_intrebare <- function(q, mod) {
  ctrl <- control_intrebare(q)
  bloc <- tags$section(
    class = paste("q", paste0("q-", q$tip)), id = paste0("bloc-", q$id), `data-qid` = q$id,
    `aria-labelledby` = paste0(q$id, "-titlu"),
    div(class = "q-nr", `aria-hidden` = "true", q$nr),
    div(class = "q-corp",
        h3(class = "q-titlu", id = paste0(q$id, "-titlu"),
           span(class = "visually-hidden", paste0("Întrebarea ", q$nr, ": ")), q$titlu,
           if (!isTRUE(q$obligatorie)) span(class = "q-optional", "opțional")),
        ctrl,
        if (!is.null(q$note)) p(class = "q-nota", q$note),
        div(class = "q-eroare", id = paste0("eroare-", q$id)),
        if (identical(mod, "test") && !is.null(q$nota_autoare))
          div(class = "nota-autoare",
              span(class = "nota-autoare-et", "Notă pentru autoare, vizibilă doar în modul test"),
              q$nota_autoare)))
  if (!is.null(q$conditie)) {
    bloc <- conditionalPanel(sprintf("input.%s == '%s'", q$conditie$intrebare, q$conditie$valoare),
                             bloc, class = "q-conditionata")
  }
  bloc
}
