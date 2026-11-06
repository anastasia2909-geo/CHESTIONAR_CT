# =============================================================================
# 01_intrebari.R — definiția chestionarului
# -----------------------------------------------------------------------------
# Textul întrebărilor și al variantelor este preluat din documentul aprobat
# „Chestionar_ct_revizuit.docx”. Codurile (stânga) sunt fără diacritice și
# rămân stabile în baza de date și în export; etichetele (dreapta) sunt
# textul afișat respondentului.
#
# Abaterile față de document, toate semnalate în docs/DECIZII_DE_CONFIRMAT.md:
#   - Q4: „Prefer să nu răspund” apare de două ori în sursă; se afișează o dată.
#   - Q6: nota din sursă trimite la „întrebarea 6”; numărul total de persoane
#     este cerut la întrebarea 5, deci nota afișată trimite la întrebarea 5.
#   - Q2/Q6: virgulele rămase după unele variante („18–24 ani ,”) sunt
#     artefacte de formatare și nu sunt afișate.
#   - Q20: nota „Se afișează doar dacă la întrebarea 19 s-a răspuns «Da»” este
#     o instrucțiune pentru varianta tipărită; online, regula este aplicată
#     automat, iar nota nu se afișează.
#   - Q12: coloana „Era mai rapid/ din obișnuință” este scrisă fără spațiu
#     după bară: „Era mai rapid/din obișnuință”.
#   - Q25: s-a adăugat nota despre datele de identificare.
#   - Spațiile de la începutul/sfârșitul unor variante și „\” rămas după Q9
#     „Curățenie în locuință” nu sunt preluate. Rândul „TOTAL: 100%” (Q9) și
#     marcajul „1………….5” (Q21) sunt înlocuite de totalul afișat în timp real,
#     respectiv de coloanele 1–5.
# =============================================================================

SECTIUNI <- list(
  list(nr = 1, titlu = "Despre dumneavoastră și locuință",        scurt = "Gospodăria"),
  list(nr = 2, titlu = "Folosirea apei și obiceiuri casnice",     scurt = "Folosirea apei"),
  list(nr = 3, titlu = "Informații despre canalizare și epurare", scurt = "Canalizare și epurare"),
  list(nr = 4, titlu = "Probleme observate și soluții",           scurt = "Probleme și soluții")
)

citeste_zone_q1 <- function(fisier = FISIER_ZONE_Q1) {
  if (!file.exists(fisier)) stop("Lipsește fișierul cu zonele pentru Q1: ", fisier)
  z <- utils::read.csv(fisier, stringsAsFactors = FALSE, encoding = "UTF-8",
                       fileEncoding = "UTF-8", colClasses = "character")
  if (!all(c("cod", "eticheta") %in% names(z))) {
    stop("Fișierul ", fisier, " trebuie să aibă coloanele: cod, eticheta")
  }
  z$cod <- trimws(z$cod); z$eticheta <- trimws(z$eticheta)
  z <- z[nzchar(z$cod) & nzchar(z$eticheta), , drop = FALSE]
  if (anyDuplicated(z$cod)) stop("Coduri duplicate în ", fisier)
  if (any(!grepl("^[a-z0-9_]+$", z$cod))) {
    stop("Codurile din ", fisier, " pot conține doar litere mici fără diacritice, cifre și _")
  }
  stats::setNames(z$eticheta, z$cod)
}

zone_sunt_exemple <- function(zone) any(grepl("DE ÎNLOCUIT|de_inlocuit", c(names(zone), zone)))

# Construiește lista de întrebări. Q1 depinde de fișierul de zone, de aceea
# definiția este o funcție.
construieste_intrebari <- function(zone = citeste_zone_q1()) {
  Q <- list(

    # ---------------------------------------------------------------- Secțiunea 1
    list(id = "q01", nr = 1, sectiune = 1, tip = "lista",
         titlu = "Zona în care locuiți",
         text  = "În ce cartier/zonă din municipiul Constanța locuiți?",
         var   = "q01_zona",
         optiuni = zone,
         nota_autoare = paste("Lista conține cele 42 de cartiere din anexa 1 la HCL nr. 79/28.02.2023, în ordine alfabetică.",
                              "Fără variantă „Nu știu” (decizia autoarei).")),

    list(id = "q02", nr = 2, sectiune = 1, tip = "unic",
         titlu = "Vârsta",
         text  = "În ce categorie de vârstă vă încadrați?",
         var   = "q02_varsta",
         # „Sub 18 ani” (cod sub_18) a fost scoasă în versiunea 3.0 și repusă în
         # 3.1, când limita de vârstă a fost eliminată. Codul este același ca în 1–2.
         optiuni = c(sub_18   = "Sub 18 ani",
                     `18_24`  = "18–24 ani",
                     `25_34`  = "25–34 ani",
                     `35_44`  = "35–44 ani",
                     `45_54`  = "45–54 ani",
                     `55_64`  = "55–64 ani",
                     `65_plus`= "65 de ani sau peste",
                     prefer_nu = "Prefer să nu răspund"),
         nota_autoare = "Varianta „Sub 18 ani” este din nou disponibilă (fără limită de vârstă, versiunea 3.1). Cerințele etice pentru minori sunt de verificat cu coordonatorul."),

    list(id = "q03", nr = 3, sectiune = 1, tip = "unic",
         titlu = "Nivelul de studii",
         text  = "Care este ultimul nivel de studii absolvit?",
         var   = "q03_studii",
         optiuni = c(gimnazial = "Gimnazial sau mai puțin",
                     liceal = "Liceal",
                     profesional_postliceal = "Școală profesională/postliceală",
                     universitar = "Studii universitare",
                     postuniversitar = "Studii postuniversitare",
                     prefer_nu = "Prefer să nu răspund")),

    list(id = "q04", nr = 4, sectiune = 1, tip = "unic",
         titlu = "Locuința",
         text  = "Ce tip de locuință aveți?",
         var   = "q04_locuinta",
         optiuni = c(apartament_bloc = "Apartament la bloc",
                     casa = "Casă",
                     alt_tip = "Alt tip",
                     prefer_nu = "Prefer să nu răspund",
                     nu_stiu = "Nu știu"),
         nota_autoare = "În sursă, „Prefer să nu răspund” apare de două ori; aici apare o singură dată."),

    list(id = "q05", nr = 5, sectiune = 1, tip = "numar",
         titlu = "Numărul persoanelor din gospodărie",
         text  = "Câte persoane locuiesc în gospodăria dumneavoastră, inclusiv dumneavoastră?",
         var   = "q05_nr_persoane", unitate = "persoane"),

    list(id = "q06", nr = 6, sectiune = 1, tip = "numere_grup",
         titlu = "Vârsta membrilor gospodăriei",
         text  = "Câte persoane din gospodărie (inclusiv dumneavoastră) se încadrează în fiecare categorie de vârstă?",
         campuri = c(sub_18 = "Sub 18 ani", `18_24` = "18–24 ani", `25_34` = "25–34 ani",
                     `35_44` = "35–44 ani", `45_54` = "45–54 ani", `55_64` = "55–64 ani",
                     `65_plus` = "65 de ani sau peste"),
         note  = "Totalul trebuie să fie egal cu numărul de persoane de la întrebarea 5 (în platforma online, suma va fi verificată automat).",
         nota_autoare = "Nota din sursă trimite la „întrebarea 6”; aici trimite la întrebarea 5, unde se cere totalul."),

    list(id = "q07", nr = 7, sectiune = 1, tip = "unic",
         titlu = "Canalizarea",
         text  = "Din câte știți, locuința este racordată la rețeaua publică de canalizare?",
         var   = "q07_canalizare",
         optiuni = c(da = "Da", nu = "Nu"),
         nota_autoare = "Sursa nu are varianta „Nu știu”. Răspunsul este obligatoriu."),

    # ---------------------------------------------------------------- Secțiunea 2
    list(id = "q08", nr = 8, sectiune = 2, tip = "consum_apa",
         titlu = "Consumul lunar de apă",
         text  = "Aproximativ câți metri cubi (m³) de apă consumă lunar gospodăria dumneavoastră? Puteți folosi factura de apă sau indexul contoarelor.",
         campuri = c(rece = "Apă rece", calda = "Apă caldă"),
         eticheta_nu_stiu = "Nu știu",
         note  = "Dacă apa caldă este preparată în locuință (centrală proprie sau boiler), consumul ei este inclus în apa rece; în acest caz, completați doar rândul pentru apă rece."),

    list(id = "q09", nr = 9, sectiune = 2, tip = "procente",
         titlu = "Utilizarea apei",
         text  = "Aproximativ cum se împarte consumul de apă din gospodăria dumneavoastră între activitățile de mai jos? Repartizați în total 100%.",
         campuri = c(igiena = "Igienă personală (duș, baie, spălat pe mâini)",
                     rufe = "Spălat rufe",
                     vase = "Spălat vase",
                     alimente = "Prepararea alimentelor și băuturi",
                     curatenie = "Curățenie în locuință",
                     toaleta = "Toaletă/rezervor WC",
                     plante_altele = "Udarea plantelor/alte utilizări"),
         note  = "Nu este nevoie să cunoașteți consumul exact; puteți estima. Procentele introduse trebuie să însumeze 100% (în platforma online, suma va fi verificată automat)."),

    list(id = "q10", nr = 10, sectiune = 2, tip = "multiplu",
         titlu = "Reducerea consumului",
         text  = "În ultima lună, ce ați făcut pentru a reduce consumul de apă? (Puteți selecta mai multe.)",
         optiuni = c(dusuri_scurte = "Am făcut dușuri mai scurte",
                     robinet_inchis = "Am închis robinetul în timp ce mă spălam pe dinți sau pe mâini",
                     masina_plina = "Am folosit mașina de spălat doar când era plină",
                     reparat_scurgeri = "Am reparat robinete sau rezervoare WC care curgeau",
                     refolosit_apa = "Am refolosit apa (de exemplu, pentru udatul plantelor)",
                     altceva = "Altceva",
                     nimic = "Nu am făcut nimic pentru a reduce consumul",
                     nu_imi_amintesc = "Nu îmi amintesc"),
         exclusive = EXCLUSIVE$q10,
         nota_autoare = "„Altceva” nu are câmp de text în sursă. „Nu am făcut nimic” și „Nu îmi amintesc” debifează celelalte variante."),

    list(id = "q11", nr = 11, sectiune = 2, tip = "multiplu",
         titlu = "Echipamente cu consum redus de apă",
         text  = "Ce echipamente care consumă mai puțină apă folosiți în locuință? (Puteți selecta mai multe.)",
         optiuni = c(masina_rufe_eficienta = "Mașină de spălat rufe eficientă (de exemplu, clasa A)",
                     masina_vase_eficienta = "Mașină de spălat vase eficientă (de exemplu, clasa A)",
                     debit_redus = "Robinete sau capete de duș cu debit redus",
                     wc_doua_trepte = "Rezervor WC cu două trepte de spălare",
                     altele = "Altele",
                     niciunul = "Niciunul",
                     nu_stiu = "Nu știu"),
         exclusive = EXCLUSIVE$q11),

    list(id = "q12", nr = 12, sectiune = 2, tip = "matrice",
         titlu = "Obiecte aruncate în toaletă",
         text  = "În ultimele 30 de zile, ai aruncat vreunul dintre obiectele de mai jos în toaletă? Pentru fiecare obiect, alege motivul pentru care l-ai aruncat sau bifează „Nu am aruncat acest obiect”.",
         note  = "Bifează o singură variantă pentru fiecare obiect.",
         antet_randuri = "Obiect",
         randuri = c(servetele_umede = "Șervețele umede",
                     prosoape_hartie = "Prosoape/șervețele de hârtie",
                     betisoare_dischete = "Bețișoare/dischete demachiante",
                     ingrijire_personala = "Produse de igienă și îngrijire personală",
                     scutece = "Scutece/materiale similare",
                     ata_par_obiecte = "Ață dentară, păr sau obiecte mici",
                     resturi_alimentare = "Resturi alimentare",
                     medicamente = "Medicamente"),
         coloane = c(rapid_obisnuinta = "Era mai rapid/din obișnuință",
                     fara_cos = "Nu aveam coș",
                     credeam_permis = "Credeam că este permis",
                     eticheta_flushable = "Etichetă „flushable”",
                     nu_am_aruncat = "Nu l-am aruncat",
                     prefer_nu = "Prefer să nu răspund"),
         nota_autoare = "Textul cere „Nu am aruncat acest obiect”, dar coloana se numește „Nu l-am aruncat”. Întrebarea folosește „tu”, restul chestionarului „dumneavoastră”. Ambele sunt păstrate ca în sursă. Singura modificare: prima coloană este scrisă „Era mai rapid/din obișnuință”, fără spațiul de după bară din sursă."),

    list(id = "q13", nr = 13, sectiune = 2, tip = "unic",
         titlu = "Ulei alimentar uzat",
         text  = "Ce faceți de obicei cu uleiul alimentar uzat?",
         var   = "q13_ulei",
         optiuni = c(punct_colectare = "Îl predau la un punct de colectare",
                     gunoi_recipient = "Îl pun la gunoiul menajer într-un recipient închis",
                     chiuveta_toaleta = "Îl torn în chiuvetă/toaletă",
                     altceva = "Altceva",
                     nu_folosesc = "Nu folosesc ulei")),

    # ---------------------------------------------------------------- Secțiunea 3
    list(id = "q14", nr = 14, sectiune = 3, tip = "unic",
         titlu = "Traseul apei uzate",
         text  = "Ce credeți că se întâmplă, de regulă, cu apa uzată care pleacă din locuință prin canalizare?",
         var   = "q14_traseu_apa_uzata",
         optiuni = c(statie_epurare = "Este transportată la o stație de epurare și tratată înainte de evacuare",
                     direct_mare = "Este evacuată direct în mare în toate cazurile",
                     apa_potabila = "Este transformată integral în apă potabilă",
                     nu_stiu = "Nu știu",
                     alt_raspuns = "Alt răspuns")),

    list(id = "q15", nr = 15, sectiune = 3, tip = "unic",
         titlu = "Rolul epurării",
         text  = "Din câte știți, care este rolul principal al unei stații de epurare a apelor uzate?",
         var   = "q15_rol_epurare",
         optiuni = c(reducere_poluanti = "Reducerea poluanților și a impactului asupra mediului",
                     eliminare_totala = "Eliminarea absolut tuturor substanțelor din apă",
                     doar_miros = "Doar îndepărtarea mirosului",
                     nu_stiu = "Nu știu",
                     alt_raspuns = "Alt răspuns")),

    list(id = "q16", nr = 16, sectiune = 3, tip = "multiplu",
         titlu = "Ce poate ajunge în apele uzate?",
         text  = "Din câte știți, ce substanțe sau obiecte pot ajunge în canalizare dintr-o locuință? (Puteți alege mai multe variante.)",
         optiuni = c(uleiuri_grasimi = "Uleiuri și grăsimi",
                     detergenti = "Detergenți și produse de curățare",
                     resturi_alimentare = "Resturi alimentare",
                     medicamente = "Urme de medicamente",
                     servetele_plastic = "Șervețele, produse de igienă și materiale plastice",
                     alte = "Alte substanțe/materiale",
                     nu_stiu = "Nu știu"),
         exclusive = EXCLUSIVE$q16),

    list(id = "q17", nr = 17, sectiune = 3, tip = "unic",
         titlu = "Informare",
         text  = "Cât de ușor credeți că ați găsi informații oficiale despre canalizare și epurarea apelor uzate în Constanța?",
         var   = "q17_informare",
         optiuni = c(foarte_greu = "Foarte greu",
                     greu = "Greu",
                     nici_nici = "Nici greu, nici ușor",
                     usor = "Ușor",
                     foarte_usor = "Foarte ușor",
                     nu_am_cautat = "Nu am căutat astfel de informații",
                     nu_pot_aprecia = "Nu pot aprecia")),

    list(id = "q18", nr = 18, sectiune = 3, tip = "unic",
         titlu = "Interes",
         text  = "Cât de interesat(ă) ați fi să primiți informații simple despre ce se întâmplă cu apa uzată după ce pleacă din locuință?",
         var   = "q18_interes",
         optiuni = c(deloc = "Deloc interesat(ă)",
                     putin = "Puțin interesat(ă)",
                     moderat = "Moderat interesat(ă)",
                     foarte = "Foarte interesat(ă)",
                     extrem = "Extrem de interesat(ă)")),

    # ---------------------------------------------------------------- Secțiunea 4
    list(id = "q19", nr = 19, sectiune = 4, tip = "unic",
         titlu = "Probleme în zonă",
         text  = "În ultimele 12 luni, ați observat probleme legate de canalizare în zona în care locuiți sau pe care o frecventați?",
         var   = "q19_probleme",
         optiuni = c(da = "Da", nu = "Nu", nu_imi_amintesc = "Nu îmi amintesc")),

    list(id = "q20", nr = 20, sectiune = 4, tip = "multiplu",
         titlu = "Tipul problemei",
         text  = "Dacă ați răspuns „Da”, ce probleme ați observat? (Puteți selecta mai multe.)",
         optiuni = c(mirosuri = "Mirosuri puternice din gurile de canal",
                     refulare = "Refulare sau revărsare",
                     infundari = "Înfundări",
                     strazi_inundate = "Străzi inundate la ploi",
                     scurgeri_baltiri = "Scurgeri sau băltiri",
                     lucrari_intreruperi = "Lucrări ori întreruperi",
                     altceva = "Altceva",
                     nu_pot_aprecia_cauza = "Nu pot aprecia cauza",
                     nu_se_aplica = "Nu se aplică"),
         exclusive = EXCLUSIVE$q20,
         conditie = list(intrebare = "q19", valoare = "da"),
         nota_autoare = "Apare doar dacă Q19 = „Da”. Varianta „Nu se aplică” din sursă este păstrată și salvată separat de cazul în care întrebarea nu a fost afișată (q20_afisata = 0)."),

    list(id = "q21", nr = 21, sectiune = 4, tip = "matrice_scala",
         titlu = "Responsabilitate",
         text  = "Cine credeți că are responsabilitatea de a contribui la prevenirea poluării apelor uzate? Pentru fiecare, selectați 1–5",
         antet_randuri = "",
         randuri = c(cetateni = "Cetățenii și gospodăriile",
                     operator = "Operatorul de canalizare și epurare",
                     autoritati = "Autoritățile locale",
                     producatori = "Producătorii/importatorii produselor",
                     control = "Instituțiile de control"),
         coloane = c(`1` = "1", `2` = "2", `3` = "3", `4` = "4", `5` = "5"),
         eticheta_toti = "Toți au responsabilități",   # eliminată din formular în v3; păstrată pentru exporturile vechi
         nota_autoare = "Etichetele capetelor scalei (1 = responsabilitate foarte mică, 5 = responsabilitate foarte mare) sunt active, aprobate de autoare. Caseta „Toți au responsabilități” a fost eliminată."),

    list(id = "q22", nr = 22, sectiune = 4, tip = "unic",
         titlu = "Prioritate pentru Constanța",
         text  = "Ce măsură ar trebui prioritizată pentru îmbunătățirea gestionării apelor uzate în Constanța?",
         var   = "q22_prioritate",
         optiuni = c(informare = "Informarea populației",
                     puncte_colectare = "Puncte de colectare mai accesibile pentru deșeuri casnice",
                     retea = "Întreținerea și modernizarea rețelei",
                     investitii_epurare = "Investiții în tratarea apelor uzate",
                     publicare_date = "Publicarea mai clară a informațiilor și datelor",
                     controale = "Controale și sancțiuni",
                     reducere_consum = "Reducerea consumului de apă",
                     altceva = "Altceva",
                     nu_pot_aprecia = "Nu pot aprecia")),

    list(id = "q23", nr = 23, sectiune = 4, tip = "unic",
         titlu = "Responsabilitate după eliminare",
         text  = "După ce ați aruncat un produs în chiuvetă/toaletă, cât de mult vă mai gândiți la ce se întâmplă cu el ulterior?",
         var   = "q23_gandire_dupa_eliminare",
         optiuni = c(deloc = "Deloc", putin = "Puțin", moderat = "Moderat", mult = "Mult",
                     foarte_mult = "Foarte mult", depinde = "Depinde de produs")),

    list(id = "q24", nr = 24, sectiune = 4, tip = "unic",
         titlu = "Micropoluanți",
         text  = "Cât de familiarizat(ă) sunteți cu termenul «micropoluanți» în contextul apelor uzate?",
         var   = "q24_micropoluanti",
         optiuni = c(nu_am_auzit = "Nu am auzit termenul",
                     auzit_nu_stiu = "Am auzit termenul, dar nu știu exact ce înseamnă",
                     idee_generala = "Am o idee generală",
                     cunosc_exemple = "Cunosc exemple și posibile efecte",
                     nu_pot_aprecia = "Nu pot aprecia")),

    list(id = "q25", nr = 25, sectiune = 4, tip = "text",
         titlu = "Sugestie",
         text  = "Ce schimbare concretă v-ar ajuta să contribuiți la o gestionare mai bună a apelor uzate în Constanța?",
         var   = "q25_sugestie",
         eticheta_camp = "Răspuns liber (opțional)",
         note  = "Vă rugăm să nu scrieți nume, adrese sau alte date care v-ar putea identifica.",
         obligatorie = FALSE,
         nota_autoare = "Nota de sub câmp nu este în sursă; a fost adăugată pentru protecția datelor și poate fi ștearsă."),
    
    list(id = "q26", nr = 26, sectiune = 4, tip = "unic", stele = TRUE,
         titlu = "Părerea dumneavoastră despre chestionar",
         text = "Cât de mulțumit(ă) sunteți de acest chestionar?",
         var = "q26_satisfactie",
         optiuni = c("1" = "1 stea", "2" = "2 stele", "3" = "3 stele",
                     "4" = "4 stele", "5" = "5 stele"),
         note = "1 stea = foarte nemulțumit(ă), 5 stele = foarte mulțumit(ă).",
         obligatorie = FALSE),
    
    list(id = "q27", nr = 27, sectiune = 4, tip = "text",
         titlu = "Observații despre chestionar",
         text = paste("Aveți observații despre acest chestionar? De exemplu,",
                      "o întrebare neclară, durata completării sau altceva",
                      "ce ar putea fi îmbunătățit."),
         var = "q27_feedback",
         eticheta_camp = "Răspuns liber (opțional)",
         note = paste("Vă rugăm să nu scrieți nume, adrese sau alte date",
                      "care v-ar putea identifica."),
         obligatorie = FALSE)
         
  )

    
  # Valori implicite
  Q <- lapply(Q, function(q) {
    if (is.null(q$obligatorie)) q$obligatorie <- TRUE
    if (is.null(q$exclusive))   q$exclusive   <- character(0)
    if (q$id == "q21") q$obligatorie <- isTRUE(Q21_OBLIGATORIE)
    q
  })
  names(Q) <- vapply(Q, `[[`, "", "id")
  stopifnot(length(Q) == 27, identical(unname(vapply(Q, `[[`, 0, "nr")), as.numeric(1:27)))
  Q
}

intrebari_sectiune <- function(Q, s) Q[vapply(Q, function(q) q$sectiune == s, logical(1))]

# -----------------------------------------------------------------------------
# Schema datelor: o linie pe variabilă. Aceeași tabelă definește coloanele din
# SQLite, ordinea coloanelor din export și dicționarul de date.
# -----------------------------------------------------------------------------
schema_date <- function(Q) {
  r <- list()
  add <- function(var, qid, tip, sql, intrebare, valori, lipsa) {
    r[[length(r) + 1]] <<- data.frame(
      variabila = var, intrebare_nr = qid, tip_date = tip, tip_sqlite = sql,
      intrebare = intrebare, valori_permise = valori, valori_lipsa = lipsa,
      stringsAsFactors = FALSE)
  }
  coduri <- function(o) paste0(names(o), " = ", unname(o), collapse = "; ")
  lipsa_std <- "gol (NA) = fără răspuns; nu apare la răspunsurile trimise, întrebarea fiind obligatorie"

  add("response_id", "meta", "text", "TEXT", "Cod aleatoriu al completării (32 de caractere hexazecimale)", "unic", "nu lipsește")
  add("submitted_at", "meta", "data", "TEXT",
      "Data trimiterii (UTC). Din versiunea 3.2 doar data, fără oră (anonimat); răspunsurile mai vechi au data și ora",
      "ex. 2026-11-01; răspunsuri vechi: 2026-10-23T10:15:00Z", "nu lipsește")
  add("mod", "meta", "categorie", "TEXT", "Modul aplicației la trimitere", "test; productie", "nu lipsește")
  add("versiune_chestionar", "meta", "text", "TEXT", "Versiunea chestionarului", VERSIUNE_CHESTIONAR, "nu lipsește")
  add("versiune_aplicatie", "meta", "text", "TEXT", "Versiunea aplicației", VERSIUNE_APLICATIE, "nu lipsește")
  add("consimtamant", "meta", "boolean", "INTEGER", "Respondentul a bifat acordul de participare", "1 = da", "nu lipsește")
  add("varsta_minima_confirmata", "meta", "boolean", "INTEGER",
      "Respondentul a confirmat că are cel puțin 18 ani (doar versiunea 3.0; pasul a fost eliminat în 3.1)",
      "1 = da", "gol (NA) în răspunsurile din versiunile 1–2 și din 3.1 încolo, când confirmarea nu se cere")

  for (q in Q) {
    et <- paste0("Q", q$nr, ". ", q$titlu, " — ", q$text)
    switch(q$tip,
      lista = , unic = add(q$var, q$id, "categorie (răspuns unic)", "TEXT", et, coduri(q$optiuni), if (q$obligatorie) lipsa_std else "gol (NA) = fără răspuns (opțional)"),
      numar = add(q$var, q$id, "număr întreg", "INTEGER", et,
                  paste0("1–", LIMITA_PERSOANE_GOSPODARIE), lipsa_std),
      numere_grup = for (k in names(q$campuri)) {
        add(paste0("q06_", k), q$id, "număr întreg", "INTEGER",
            paste0(et, " [", q$campuri[[k]], "]"),
            "0 sau mai mult; suma celor 7 câmpuri = q05_nr_persoane",
            "din v3: un câmp lăsat gol de respondent este salvat ca 0 (0 persoane în categorie); NA nu apare la răspunsurile trimise")
      },
      consum_apa = {
        add("q08_apa_rece_m3", q$id, "număr zecimal", "REAL", paste0(et, " [Apă rece, m³/lună]"),
            paste0("0–", LIMITA_M3_PE_LUNA),
            "gol (NA) dacă q08_nu_stiu = 1")
        add("q08_apa_calda_m3", q$id, "număr zecimal", "REAL", paste0(et, " [Apă caldă, m³/lună]"),
            paste0("0–", LIMITA_M3_PE_LUNA),
            "gol (NA) dacă q08_nu_stiu = 1 sau dacă respondentul a completat doar apa rece (apa caldă preparată în locuință este inclusă în apa rece)")
        add("q08_nu_stiu", q$id, "boolean", "INTEGER", paste0(et, " [Nu știu]"), "1 = bifat; 0 = nebifat", "nu lipsește")
      },
      procente = for (k in names(q$campuri)) {
        add(paste0("q09_", k), q$id, "număr zecimal (%)", "REAL",
            paste0(et, " [", q$campuri[[k]], "]"),
            "0–100; suma celor 7 câmpuri = 100 (toleranță 0,01)",
            "din v3: un câmp lăsat gol de respondent este salvat ca 0 (0%); NA nu apare la răspunsurile trimise")
      },
      multiplu = {
        for (k in names(q$optiuni)) {
          lipsa <- if (!is.null(q$conditie)) {
            "gol (NA) = întrebarea nu a fost afișată (q19_probleme diferit de „da”); nu înseamnă „Nu se aplică”"
          } else "nu lipsește"
          add(paste0(q$id, "_", k), q$id, "boolean (selecție multiplă)", "INTEGER",
              paste0(et, " [", q$optiuni[[k]], "]"), "1 = bifat; 0 = nebifat", lipsa)
        }
        if (!is.null(q$conditie)) {
          add("q20_afisata", q$id, "boolean", "INTEGER", "Q20 a fost afișată (Q19 = „Da”)",
              "1 = afișată; 0 = neaplicabilă structural", "nu lipsește")
        }
      },
      matrice = for (k in names(q$randuri)) {
        add(paste0("q12_", k), q$id, "categorie (motiv)", "TEXT",
            paste0(et, " [", q$randuri[[k]], "]"), coduri(q$coloane), lipsa_std)
      },
      matrice_scala = {
        for (k in names(q$randuri)) {
          add(paste0("q21_", k), q$id, "număr întreg (scală 1–5)", "INTEGER",
              paste0(et, " [", q$randuri[[k]], "]"),
              if (is.null(Q21_ANCORE)) "1–5 (ancorele scalei nu sunt definite în chestionarul aprobat)"
              else paste0("1 = ", Q21_ANCORE[["min"]], "; 5 = ", Q21_ANCORE[["max"]]),
              if (isTRUE(Q21_OBLIGATORIE)) lipsa_std else "gol (NA) = fără răspuns")
        }
        add("q21_toti", q$id, "boolean (retras în v3)", "INTEGER", paste0(et, " [Toți au responsabilități] – casetă eliminată din chestionar în versiunea 3"),
            "1 = bifat; 0 = nebifat; nu este scor",
            "gol (NA) în toate răspunsurile din versiunea 3 (necolectat); valorile 0/1 apar doar în răspunsurile trimise cu versiunile 1–2")
      },
      text = add(q$var, q$id, "text liber", "TEXT", et,
                 paste0("maximum ", LUNGIME_MAXIMA_Q25, " de caractere"),
                 "gol (NA) = nu a răspuns (întrebare opțională)")
    )
  }
  out <- do.call(rbind, r)
  rownames(out) <- NULL
  stopifnot(!anyDuplicated(out$variabila))
  out
}

# Etichetele codurilor unei variabile categoriale (pentru export cu etichete
# și pentru pagina de revizuire).
etichete_variabila <- function(Q, var) {
  for (q in Q) {
    if (!is.null(q$var) && q$var == var && !is.null(q$optiuni)) return(q$optiuni)
    if (q$tip == "matrice" && var %in% paste0("q12_", names(q$randuri))) return(q$coloane)
  }
  NULL
}


