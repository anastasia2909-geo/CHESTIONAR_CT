# =============================================================================
# 13_recomandari.R — surse și recomandări afișate în profil
# -----------------------------------------------------------------------------
# Fiecare sursă de aici are o intrare în docs/REGISTRU_SURSE.md, cu data
# verificării, starea verificării și textul exact care susține afirmația.
# Nu adăugați o afirmație fără o intrare verificată în registru.
# Cheia `registru` trimite la identificatorul din registru.
# =============================================================================

SURSE_PROFIL <- list(
  water_uk = list(registru = "INST-WATERUK-FACT", tip = "instituție",
    titlu = "Water UK, fișa „Unflushables” (Regatul Unit)",
    url = "https://www.water.org.uk/sites/default/files/2023-05/Factsheet_UnflushablesNEW.pdf"),
  vital_faq = list(registru = "OP-VITAL-FAQ", tip = "ghid operator",
    titlu = "VITAL S.A. Baia Mare, „Cum protejăm rețelele de canalizare?”",
    url = "https://www.vitalmm.ro/ro/intrebari-frecvente/cum-protejam-retelele-de-canalizare"),
  vital_2026 = list(registru = "OP-VITAL-CP2026", tip = "ghid operator",
    titlu = "VITAL S.A. Baia Mare, comunicatul „Semnal de alarmă! Servețelele umede crează cele mai mari probleme la sistemul de canalizare!”, 24.07.2026",
    url = "https://vitalmm.ro/ro/media/comunicate-de-presa/semnal-de-alarma-servetelele-umede-creaza-cele-mai-mari-probleme-la-sistemul-de-canalizare"),
  raja_navodari = list(registru = "RO-RAJA", tip = "presă (citează RAJA S.A.)",
    titlu = "Cristi Hagi, „RAJA, intervenție complexă pentru deblocarea colectorului principal de canalizare din orașul Năvodari”, Constanța Financiară, 03.08.2026",
    url = "https://constantafinanciara.ro/raja-interventie-complexa-pentru-deblocarea-colectorului-principal-de-canalizare-din-orasul-navodari/"),
  hadley2023 = list(registru = "PR-HADLEY2023", tip = "articol peer-reviewed",
    titlu = "Hadley T. et al. (2023), „Flushed but not forgotten: The rising costs and opportunities of disposable wet wipes”, BioResources 18(1): 2271–2287, doi:10.15376/biores.18.1.Hadley",
    url = "https://bioresources.cnr.ncsu.edu/wp-content/uploads/2023/01/BioRes_18_1_2271_Hadley_Review_Flushed_Not_Forgotten_Rising_Costs_Disposable_Wipes_18606.pdf"),
  husain2014 = list(registru = "PR-HUSAIN2014", tip = "articol peer-reviewed",
    titlu = "Husain I.A.F. et al. (2014), „Problems, Control, and Treatment of Fat, Oil, and Grease (FOG): A Review”, Journal of Oleo Science 63(8): 747–752, doi:10.5650/jos.ess13182",
    url = "https://www.jstage.jst.go.jp/article/jos/63/8/63_ess13182/_article"),
  wallace2017 = list(registru = "PR-WALLACE2017", tip = "articol peer-reviewed",
    titlu = "Wallace T. et al. (2017), „International evolution of fat, oil and grease (FOG) waste management – A review”, Journal of Environmental Management 187: 424–435, doi:10.1016/j.jenvman.2016.11.003",
    url = "https://researchrepository.ucd.ie/handle/10197/8257"),
  ntpa002 = list(registru = "RO-NTPA002", tip = "act normativ RO",
    titlu = "HG nr. 188/2002, anexa 2 (NTPA-002), art. 5 pct. 1, forma actualizată la 19.03.2007 (copie FAOLEX)",
    url = "https://faolex.fao.org/docs/pdf/rom216719.pdf"),
  legea241 = list(registru = "RO-L241", tip = "act normativ RO",
    titlu = "Legea nr. 241/2006 a serviciului de alimentare cu apă și de canalizare, republicată, art. 5 alin. (3), formă consolidată la 22.05.2025 (copie ANPC)",
    url = "https://anpc.ro/download/338/servicii-de-alimentare-cu-apa-si-canalizare/60434/legea-serviciului-de-alimentare-cu-apa-si-de-canalizare-nr-241-2006.pdf"),
  oms119 = list(registru = "RO-OMS119", tip = "act normativ RO",
    titlu = "Ordinul ministrului sănătății nr. 119/2014, art. 38 lit. c), formă consolidată la 26.05.2025 (copie ANPC)",
    url = "https://anpc.ro/download/334/stranduri-bazine-piscine/60407/ordinul-nr-119-2014-pentru-aprobarea-normelor-de-igiena-si-sanatate-publica-privind-mediul-de-viata-al-populatiei.pdf"),
  rogowska2022 = list(registru = "PR-ROGOWSKA2022", tip = "articol peer-reviewed",
    titlu = "Rogowska J., Zimmermann A. (2022), „Household Pharmaceutical Waste Disposal as a Global Problem—A Review”, IJERPH 19(23): 15798, doi:10.3390/ijerph192315798",
    url = "https://pmc.ncbi.nlm.nih.gov/articles/PMC9737308"),
  directiva = list(registru = "UE-UWWTD", tip = "act normativ UE",
    titlu = "Directiva (UE) 2024/3019 a Parlamentului European și a Consiliului din 27 noiembrie 2024 privind tratarea apelor urbane uzate (reformare), art. 8 și considerentul 20",
    url = "https://eur-lex.europa.eu/eli/dir/2024/3019/oj"),
  luo2014 = list(registru = "PR-LUO2014", tip = "articol peer-reviewed",
    titlu = "Luo Y. et al. (2014), „A review on the occurrence of micropollutants in the aquatic environment and their fate and removal during wastewater treatment”, Science of the Total Environment 473–474: 619–641, doi:10.1016/j.scitotenv.2013.12.065",
    url = "https://doi.org/10.1016/j.scitotenv.2013.12.065"),
  hcl79 = list(registru = "HCL79", tip = "act local",
    titlu = "HCL nr. 79/28.02.2023 a Consiliului Local al municipiului Constanța, anexele 1 și 2",
    url = NULL),
  geoboundaries = list(registru = "GEOB", tip = "date geografice",
    titlu = "geoBoundaries, Romania ADM2 (sursa: ANCPI, data.gov.ro), CC BY 4.0",
    url = "https://www.geoboundaries.org")
)

link_sursa <- function(cheie) {
  s <- SURSE_PROFIL[[cheie]]
  if (is.null(s)) return(NULL)
  if (is.null(s$url)) span(class = "sursa", s$titlu, .noWS = "outside")
  else tags$a(class = "sursa", href = s$url, target = "_blank", rel = "noopener noreferrer", s$titlu, .noWS = "outside")
}

text_micropoluanti <- function() tagList(
  "Micropoluanții sunt substanțe care ajung în apele uzate în concentrații mici. Directiva europeană din 2024 numește reziduurile de medicamente și de produse cosmetice drept principalele lor surse în apa uzată urbană. ",
  "Directiva prevede ca stațiile de epurare care tratează cel puțin 150 000 de locuitori echivalenți să aibă o treaptă suplimentară de tratare (cuaternară), eșalonat: 20% dintre ele până la sfârșitul lui 2033, 60% până în 2039 și toate până în 2045. ",
  "Sursă: ", link_sursa("directiva"), ".")

text_epurare <- function() tagList(
  "O stație de epurare reduce poluanții din apa uzată înainte ca apa să fie evacuată, dar nu îi reține pe toți în aceeași măsură. ",
  "Într-o sinteză a studiilor publicate, Luo et al. (2014) au găsit că proporția de micropoluanți îndepărtată depinde de substanță și variază între 12,5% și 100%. ",
  "Sursă: ", link_sursa("luo2014"), ".")

# --- recomandări ---------------------------------------------------------------------
# Fiecare recomandare are cel puțin o sursă. Cele legate de răspunsuri apar
# primele, marcate cu numărul întrebării; cele generale completează lista.

recomandari <- function(Q, rec) {
  q12 <- coduri_q12(Q, rec)
  aruncat <- function(k) isTRUE(q12[[k]] %in% MOTIVE_ARUNCAT)
  obiecte_igiena <- c("servetele_umede", "prosoape_hartie", "betisoare_dischete",
                      "ingrijire_personala", "scutece", "ata_par_obiecte")
  r <- list()
  add <- function(id, titlu, text, surse, legata = NULL) {
    r[[length(r) + 1]] <<- list(id = id, titlu = titlu, text = text, surse = surse, legata = legata)
  }
  if (any(vapply(obiecte_igiena, aruncat, logical(1))))
    add("igiena", "Toaleta nu este coș de gunoi",
        paste("Rețelele de canalizare sunt proiectate pentru urină, fecale, apă uzată și hârtie igienică (Water UK).",
              "Șervețelele umede, tampoanele, bețișoarele pentru urechi, discurile demachiante, scutecele și părul se pun la coșul de gunoi;",
              "operatorul de apă din Baia Mare le enumeră printre lucrurile care nu se aruncă în toaletă."),
        c("water_uk", "vital_faq"), "întrebarea 12")
  if (any(q12 == "fara_cos", na.rm = TRUE))
    add("cos", "Un coș în baie",
        paste("Ați indicat că, pentru unele obiecte, nu aveați un coș la îndemână.",
              "Șervețelele umede, scutecele și articolele de igienă personală nu se aruncă în canalizare, iar un coș în baie le dă un loc acolo unde sunt folosite."),
        "vital_2026", "întrebarea 12")
  if (any(q12 == "eticheta_flushable", na.rm = TRUE))
    add("flushable", "Eticheta „flushable”",
        paste("Potrivit unei sinteze publicate în 2023 (Hadley et al.), doar o parte dintre șervețelele vândute ca „flushable” se dezintegrează în canalizare.",
              "Water UK scrie că, în Regatul Unit, doar produsele cu marcajul „Fine to Flush” pot fi aruncate în siguranță în toaletă."),
        c("hadley2023", "water_uk"), "întrebarea 12")
  if (aruncat("resturi_alimentare"))
    add("mancare", "Resturile alimentare",
        "Resturile alimentare se pun la gunoi. Operatorul de apă din Baia Mare: „nu aruncați mâncare în toaletă sau chiuvetă”.",
        "vital_faq", "întrebarea 12")
  if (identical(rec$q13_ulei, "chiuveta_toaleta"))
    add("ulei", "Uleiul folosit",
        paste("Uleiul și grăsimile turnate în chiuvetă se depun pe pereții conductelor și le pot bloca; o sinteză din 2014 numește locuințele printre sursele acestor depuneri.",
              "Normativul NTPA-002 nu permite evacuarea în canalizare a uleiului și grăsimilor care pot forma depuneri pe pereții canalului (art. 5 pct. 1 lit. e).",
              "Variantele din chestionar sunt predarea la un punct de colectare sau gunoiul menajer, într-un recipient închis."),
        c("husain2014", "ntpa002"), "întrebarea 13")
  if (aruncat("medicamente"))
    add("medicamente", "Medicamentele",
        paste("Medicamentele expirate se predau la farmacie: potrivit Ordinului MS nr. 119/2014, farmaciile le colectează gratuit și trebuie să afișeze un anunț în acest sens.",
              "O sinteză din 2022 (Rogowska și Zimmermann) arată că medicamentele aruncate în toaletă sau în chiuvetă sunt una dintre căile prin care ajung în mediu."),
        c("oms119", "rogowska2022"), "întrebarea 12")
  generale <- list(
    list(id = "igiena", titlu = "Doar hârtie igienică", surse = c("water_uk", "vital_faq"),
         text = "Rețelele de canalizare sunt proiectate pentru urină, fecale, apă uzată și hârtie igienică (Water UK). Șervețelele umede, produsele de igienă, scutecele și părul se pun la coșul de gunoi (Vital)."),
    list(id = "ulei", titlu = "Uleiul folosit", surse = c("wallace2017", "vital_faq"),
         text = "Uleiul și grăsimile turnate în chiuvetă sau în toaletă formează depuneri care blochează canalizarea și pot duce la revărsări de ape uzate (Wallace et al., 2017). Vital: „nu aruncați ulei folosit în scurgerea de la chiuvetă sau toaletă”."),
    list(id = "medicamente", titlu = "Medicamentele", surse = "oms119",
         text = "Medicamentele expirate nu se aruncă în toaletă sau în chiuvetă; potrivit Ordinului MS nr. 119/2014, se predau la farmacie, care le colectează gratuit."),
    list(id = "lege", titlu = "Ce prevede legea", surse = c("legea241", "ntpa002"),
         text = paste("Legea nr. 241/2006 (art. 5 alin. 3) cere ca apele uzate evacuate în canalizare să nu ducă la degradarea rețelei, la scăderea capacității de transport a conductelor sau la perturbarea stației de epurare.",
                      "Normativul NTPA-002 (art. 5 pct. 1) enumeră ce nu are voie să ajungă în canalizare, între altele substanțele care se pot solidifica și obtura canalele, corpurile solide care nu trec printr-un grătar cu spații de 20 mm și uleiul și grăsimile care formează depuneri pe pereții canalului.")),
    list(id = "raja", titlu = "Un exemplu din județul Constanța", surse = "raja_navodari",
         text = "Pe 2 august 2026, colectorul principal de canalizare din Năvodari s-a blocat. Biroul de comunicare al RAJA, citat de Constanța Financiară, a spus că din colector au fost scoase sute de kilograme de deșeuri, mai ales șervețele din fibre sintetice, și că șervețelele umede, produsele de igienă, uleiurile și grăsimile sunt printre principalele cauze ale colmatării conductelor."))
  existente <- vapply(r, `[[`, "", "id")
  for (g in generale) if (!g$id %in% existente) add(g$id, g$titlu, g$text, g$surse)
  r
}

sectiune_recomandari <- function(Q, rec) {
  rr <- recomandari(Q, rec)
  sectiune_finala("f-recomandari", "Recomandări practice",
    "Fiecare recomandare are sursa alături. Cele marcate sunt legate de răspunsurile dumneavoastră.",
    tags$ul(class = "lista-recomandari", lapply(seq_along(rr), function(i) {
      x <- rr[[i]]
      tags$li(class = paste("rec", if (!is.null(x$legata)) "rec-legata"),
        span(class = "rec-nr", `aria-hidden` = "true", sprintf("%02d", i)),
        h3(class = "rec-titlu", x$titlu),
        if (!is.null(x$legata)) span(class = "rec-eticheta", paste0("Legat de răspunsul dvs. la ", x$legata)),
        p(x$text),
        p(class = "rec-sursa", if (length(x$surse) > 1) "Surse: " else "Sursă: ",
          lapply(seq_along(x$surse), function(j) tagList(if (j > 1) "; ", link_sursa(x$surse[j])))))
    })))
}

lista_surse <- function() {
  div(class = "surse", h2(class = "surse-titlu", "Surse"),
    p(class = "nota-mica", "Datele de verificare și citatele exacte sunt în registrul de surse al proiectului (docs/REGISTRU_SURSE.md)."),
    tags$ol(lapply(names(SURSE_PROFIL), function(k) tags$li(link_sursa(k),
      span(class = "sursa-tip", paste0(" (", SURSE_PROFIL[[k]]$tip, ")"))))))
}
