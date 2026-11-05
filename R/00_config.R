# =============================================================================
# 00_config.R — setări ale aplicației
# -----------------------------------------------------------------------------
# Aici se schimbă comportamentul aplicației fără a modifica restul codului.
# Setările marcate „DECIZIE” trebuie confirmate de autoare/coordonator înainte
# de lansarea publică (vezi docs/DECIZII_DE_CONFIRMAT.md).
# =============================================================================

`%||%` <- function(a, b) if (is.null(a)) b else a

VERSIUNE_APLICATIE   <- "3.3.0"
VERSIUNE_CHESTIONAR  <- "Chestionar_ct_revizuit (2026)"

# --- Modul de lucru -----------------------------------------------------------
# "test"      -> răspunsurile merg în data/raspunsuri_TEST.sqlite, apare banda
#                „MOD TEST” și notele pentru autoare. Implicit, ca o rulare
#                locală de probă să nu amestece date fictive cu cele reale.
# "productie" -> răspunsurile merg în data/raspunsuri.sqlite.
# Variabila de mediu CHESTIONAR_MOD are prioritate față de valoarea de mai jos.
MOD_IMPLICIT <- "test"

mod_curent <- function() {
  m <- tolower(trimws(Sys.getenv("CHESTIONAR_MOD", MOD_IMPLICIT)))
  if (!m %in% c("test", "productie")) {
    warning("CHESTIONAR_MOD are o valoare necunoscută ('", m, "'); se folosește 'test'.")
    m <- "test"
  }
  m
}

# --- Locația datelor -----------------------------------------------------------
# Folderul în care se păstrează bazele SQLite. Relativ la folderul aplicației,
# sau o cale absolută prin variabila de mediu CHESTIONAR_DATA_DIR.
folder_date <- function() {
  d <- Sys.getenv("CHESTIONAR_DATA_DIR", "data")
  if (!dir.exists(d)) dir.create(d, recursive = TRUE, showWarnings = FALSE)
  normalizePath(d, winslash = "/", mustWork = TRUE)
}

# Baza PostgreSQL (pentru găzduire). Dacă variabila de mediu CHESTIONAR_DB_URL
# are o adresă de forma postgresql://utilizator:parola@gazda/baza?sslmode=require,
# răspunsurile se salvează acolo, în tabela `raspunsuri` (producție) sau
# `raspunsuri_test` (test), și nu în fișierele SQLite. Adresa conține parola
# bazei de date: se pune doar în .Renviron sau în variabilele secrete ale
# serverului, niciodată în cod. Fără variabilă, aplicația folosește SQLite.
url_postgres <- function() trimws(Sys.getenv("CHESTIONAR_DB_URL", ""))
TABELA_PG_PRODUCTIE <- "raspunsuri"
TABELA_PG_TEST      <- "raspunsuri_test"

# Întoarce locul în care se salvează răspunsurile: calea fișierului SQLite sau,
# pentru PostgreSQL, "postgres:<tabela>" (fără adresă și fără parolă).
cale_baza_date <- function(mod = mod_curent()) {
  if (nzchar(url_postgres())) {
    return(paste0("postgres:", if (identical(mod, "test")) TABELA_PG_TEST else TABELA_PG_PRODUCTIE))
  }
  fisier <- if (identical(mod, "test")) "raspunsuri_TEST.sqlite" else "raspunsuri.sqlite"
  file.path(folder_date(), fisier)
}

# --- Acces administrativ -------------------------------------------------------
# Parola NU se scrie în cod. Se setează în fișierul .Renviron (vezi
# .Renviron.exemplu) sau în setările serverului:
#   CHESTIONAR_ADMIN_PAROLA=o-parola-lunga
# Zona de administrare se deschide adăugând ?admin la adresă.
# Fără parolă setată, zona de administrare este dezactivată (inclusiv în modul
# test și pe calculatorul propriu). Excepția „localhost fără parolă” din
# versiunile 1–2 a fost eliminată: numele gazdei vine din browser și poate fi
# falsificat.
ADMIN_INCERCARI_MAXIME <- 5      # încercări greșite într-o sesiune înainte de blocarea sesiunii;
                                 # de 2 ori acest număr, în toate sesiunile, blochează autentificarea pentru toți
ADMIN_BLOCARE_MINUTE   <- 10

parola_admin <- function() Sys.getenv("CHESTIONAR_ADMIN_PAROLA", "")

# --- Limite de plauzibilitate pentru câmpurile numerice -------------------------
# Valori peste aceste limite sunt respinse cu un mesaj lângă câmp.
LIMITA_PERSOANE_GOSPODARIE <- 30
LIMITA_M3_PE_LUNA          <- 500   # pentru fiecare câmp (apă rece / apă caldă)
TOLERANTA_PROCENTE         <- 0.01  # Q9: suma acceptată 100 ± 0,01
LUNGIME_MAXIMA_Q25         <- 2000  # caractere

# --- Q1, lista cartierelor -------------------------------------------------------
# Lista se citește din config/zone_q1.csv (coloanele: cod, eticheta). Conține
# cele 42 de cartiere din anexa 1 la HCL nr. 79/28.02.2023 a Consiliului Local
# Constanța, în ordine alfabetică. Detaliile (delimitare, plan, observații) sunt
# în config/cartiere_hcl79_2023.csv; vezi docs/CARTIERE_HCL79_2023.md.
FISIER_ZONE_Q1  <- file.path("config", "zone_q1.csv")
FISIER_CARTIERE <- file.path("config", "cartiere_hcl79_2023.csv")

# Q1 nu are variantă „Nu știu” (decizia autoarei, versiunea 3).

# --- Participare -----------------------------------------------------------------
# Din versiunea 3.1 nu există o limită de vârstă (decizia autoarei): pasul de
# informare cere doar acordul de participare, verificat pe server la începere
# și la trimitere. Q2 are din nou varianta „Sub 18 ani”, ca în chestionarul
# aprobat. Cerințele etice pentru minori sunt în docs/DECIZII_DE_CONFIRMAT.md.
# Chestionarul nu are dată de închidere și nici număr maxim de respondenți;
# autoarea îl închide manual (de exemplu, oprind aplicația). Răspunsurile nu
# se șterg automat.

# --- Harta din pagina finală ------------------------------------------------------
# Limitele UAT (ANCPI prin geoBoundaries) sunt incluse în www/harta/uat.geojson.
# Limitele cartierelor NU sunt incluse: nu există încă un fișier vectorial
# verificat. Când se adaugă (GeoJSON, WGS84, proprietatea „cod” egală cu
# codurile din zone_q1.csv), harta tematică pe cartiere se activează singură.
# Vezi docs/HARTA_DATE_SI_LIMITARI.md și docs/INDICATORI_HARTA.md.
# Variabila de mediu CHESTIONAR_CARTIERE_GEOJSON poate indica alt fișier (de
# exemplu, fișierul de test din tests/fixtures/; NU pentru producție).
FISIER_CARTIERE_GEOJSON <- Sys.getenv("CHESTIONAR_CARTIERE_GEOJSON",
                                      file.path("www", "harta", "cartiere.geojson"))

# DECIZIE: butonul care încarcă fundalul OpenStreetMap. Fundalul se încarcă
# numai la cererea respondentului; atunci browserul contactează serverele
# OpenStreetMap (care primesc adresa IP). FALSE ascunde butonul.
HARTA_FUNDAL_OSM_PERMIS <- TRUE

# --- DECIZIE: indicatorii hărții tematice -------------------------------------------
# HARTA_TEMATICA_ACTIVA: FALSE elimină complet secțiunea.
# HARTA_PRAG_TOTAL: indicatorii apar doar după atâtea completări valide în total.
# HARTA_PRAG_CARTIER: un procent pentru un cartier se afișează doar dacă
#   numitorul (respondenții eligibili pentru acel indicator) este cel puțin
#   această valoare. Sub prag se afișează „date insuficiente”, fără cifră.
#   Valoarea 10 este o propunere de lucru, de revizuit metodologic (vezi
#   docs/INDICATORI_HARTA.md); nu este un prag „statistic valid” universal.
# HARTA_PRAG_NUMAR: numărul de respondenți dintr-un cartier se afișează exact
#   doar de la această valoare în sus; între 1 și prag-1 apare „sub N”.
HARTA_TEMATICA_ACTIVA <- TRUE
HARTA_PRAG_TOTAL      <- 30
HARTA_PRAG_CARTIER    <- 10
HARTA_PRAG_NUMAR      <- 5

# --- DECIZIE: comparația cu ceilalți respondenți -----------------------------------
# Pe pagina finală se pot afișa procente agregate (nu răspunsuri individuale)
# pentru câteva întrebări, calculate din baza de date a modului curent, numai
# după ce există cel puțin COMPARATIE_MIN_RASPUNSURI completări. Sub prag se
# afișează un mesaj, nu cifre. FALSE elimină secțiunea.
COMPARATIE_ACTIVA         <- TRUE
COMPARATIE_MIN_RASPUNSURI <- 30

# --- DECIZIE: opțiuni exclusive -------------------------------------------------
# Opțiunile de mai jos debifează automat celelalte bife din aceeași întrebare
# (și invers). Pentru a renunța la exclusivitate, puneți character(0).
EXCLUSIVE <- list(
  q10 = c("nimic", "nu_imi_amintesc"),
  q11 = c("niciunul", "nu_stiu"),
  q16 = c("nu_stiu"),
  q20 = character(0)      # nespecificat în sursă; vezi DECIZII_DE_CONFIRMAT.md
)

# --- Anonimat -----------------------------------------------------------------
# Momentul trimiterii se salvează doar ca dată ("zi", de exemplu 2026-11-01),
# ca un răspuns să nu poată fi pus în legătură, după oră, cu jurnalele tehnice
# ale serverului (care pot conține adrese IP). "secunda" păstrează ora exactă,
# ca în versiunile 1–3.1. Răspunsurile deja salvate nu se modifică.
PRECIZIE_DATA_TRIMITERII <- "zi"

# --- Q21: etichetele capetelor scalei -------------------------------------------
# Aprobate de autoare (versiunea 3.1): 1 = responsabilitate foarte mică,
# 5 = responsabilitate foarte mare. Scala, codurile (1–5) și datele salvate
# nu se schimbă; etichetele apar doar deasupra coloanelor 1 și 5.
Q21_ANCORE_ACTIVE   <- TRUE
Q21_ANCORE_ETICHETE <- c(min = "responsabilitate foarte mică",
                         max = "responsabilitate foarte mare")
Q21_ANCORE <- if (isTRUE(Q21_ANCORE_ACTIVE)) Q21_ANCORE_ETICHETE else NULL

# Caseta „Toți au responsabilități” a fost eliminată în versiunea 3. Coloana
# q21_toti rămâne în baza de date pentru compatibilitate: răspunsurile vechi își
# păstrează valoarea, cele noi au NA (necolectat).
Q21_TOTI_MOD <- "eliminat"

# Dacă fiecare rând din Q21 este obligatoriu. Sursa nu oferă „Nu pot aprecia”.
Q21_OBLIGATORIE <- TRUE

# --- Titlu și autoare ---------------------------------------------------------------
# Titlul lucrării este titlul principal al site-ului (pagina de start, fila
# browserului, metadate). Site-ul nu are slogan.
TITLU_ACADEMIC <- "Evaluarea comportamentelor populației și a nivelului de conștientizare privind gestionarea apelor uzate în municipiul Constanța"
TITLU_SCURT    <- "Chestionar despre apele uzate în Constanța"   # zona de administrare

AUTOARE <- list(
  nume       = "Anastasia NICEA",
  email      = "anastasia.nicea@s.unibuc.ro",
  institutie = "Universitatea din București, Facultatea de Geografie"
)

# Durata estimată a completării, în minute, afișată pe pagina de start.
# Estimare inițială din conținutul chestionarului (metoda: docs/DURATA_ESTIMATA.md),
# de validat cu completări reale; cronometrul din modul test ajută la validare.
DURATA_ESTIMATA_MINUTE <- "10–15"

# Compatibilitate cu numele din versiunile anterioare
TITLU_CHESTIONAR <- TITLU_ACADEMIC
TITLU_SITE       <- TITLU_ACADEMIC
SUBTITLU_SITE    <- TITLU_ACADEMIC

# --- Administrare: sesiune ------------------------------------------------------------
# După atâtea minute fără activitate în zona de administrare, autentificarea expiră.
ADMIN_INACTIVITATE_MINUTE <- 30

# --- DECIZIE: informare și consimțământ -----------------------------------------
# Textul se citește din config/informare_consimtamant.md. Câmpurile scrise
# între [[ și ]] sunt de completat. În modul producție, aplicația afișează în
# consolă și în zona admin un avertisment cât timp mai există astfel de câmpuri.
FISIER_INFORMARE <- file.path("config", "informare_consimtamant.md")
