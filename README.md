# Evaluarea comportamentelor populației și a nivelului de conștientizare privind gestionarea apelor uzate în municipiul Constanța

Aplicația R Shiny a chestionarului pentru lucrarea de licență a Anastasiei NICEA (Universitatea din București, Facultatea de Geografie). Funcționalitatea:

- pagina de start și un pas separat de informare și acord, fără limită de vârstă;
- cele 25 de întrebări din documentul aprobat `Chestionar_ct_revizuit.docx`, în 4 secțiuni, cu validare și pagină de verificare;
- salvare în SQLite pe calculatorul propriu sau, la găzduire, într-o bază PostgreSQL (de exemplu, Neon);
- zonă de administrare cu export brut, export pentru analiză și verificări de configurare;
- pagina finală: profilul respondentului, hartă, indicatori pe cartiere, comparație agregată (peste un prag), recomandări cu surse verificate.

Versiunea 3.3.0. Modificările sunt în `CHANGELOG.md`. Aplicația a fost testată local, pe SQLite și pe PostgreSQL, și nu este publicată. Pașii pentru publicarea gratuită (Posit Connect Cloud pentru aplicație, Neon pentru răspunsuri, copie zilnică pe GitHub) sunt în `docs/GAZDUIRE.md`; celelalte puncte deschise sunt în `docs/DECIZII_DE_CONFIRMAT.md`.

## Conținutul proiectului

```
chestionar_constanta/
├── app.R                         pornirea aplicației (Run App)
├── chestionar_constanta.Rproj    proiectul RStudio
├── CHANGELOG.md                  istoricul modificărilor
├── .Renviron.exemplu             model pentru parolă, mod, folderul datelor
├── R/
│   ├── 00_config.R               setări: titlu, autoare, mod, praguri, Q21, hartă
│   ├── 01_intrebari.R            textul întrebărilor, coduri, schema datelor
│   ├── 02_validare.R             validare și codificarea răspunsurilor
│   ├── 03_stocare.R              SQLite sau PostgreSQL: creare, migrare aditivă, salvare, citire, copii
│   ├── 04_export.R               export brut, export pentru analiză, dicționar
│   ├── 05_date_test.R            răspunsuri sintetice
│   ├── 06_ui_componente.R        controalele pentru fiecare tip de întrebare
│   ├── 07_ui.R                   paginile (start, informare, secțiuni, final, administrare)
│   ├── 08_server.R               eligibilitate, navigare, verificare, trimitere
│   ├── 09_profil.R               profilul, harta și comparația de pe pagina finală
│   ├── 10_admin.R                zona de administrare
│   ├── 11_harta.R                datele hărții și fișa cartierului
│   ├── 12_indicatori.R           indicatorii pe cartiere
│   └── 13_recomandari.R          sursele și recomandările
├── config/
│   ├── zone_q1.csv               cele 42 de cartiere pentru Q1 (HCL nr. 79/2023)
│   ├── cartiere_hcl79_2023.csv   cartierele: delimitare, plan, observații
│   └── informare_consimtamant.md textul de informare
├── www/                          stiluri, scripturi, fonturi, imagini, Leaflet, hartă, planuri
├── data/                         bazele de date (create la prima pornire; nu sunt servite public)
├── docs/
│   ├── DECIZII_DE_CONFIRMAT.md   blocanți și decizii deschise
│   ├── REGISTRU_SURSE.md         sursele verificate ale recomandărilor
│   ├── INDICATORI_HARTA.md       formulele indicatorilor pe cartiere
│   ├── HARTA_DATE_SI_LIMITARI.md datele hărții și cum se adaugă limitele cartierelor
│   ├── GAZDUIRE.md               găzduirea pas cu pas: Neon, GitHub, Connect Cloud, copii
│   ├── copie_automata/           copia zilnică a răspunsurilor (GitHub Actions)
│   ├── AUDIT_ANONIMAT.md         ce date ar putea identifica un respondent
│   ├── CADRU_LEGAL.md            actele normative și licențele care privesc site-ul
│   ├── DURATA_ESTIMATA.md        cum s-a estimat durata completării
│   ├── TESTARE.md                rezultatele testelor
│   ├── CARTIERE_HCL79_2023.md    lista verificată a cartierelor
│   └── dictionar_date.csv/.xlsx  dicționarul de date
├── scripts/                      instalare, date de test, copii, export, teste, grafică
└── tests/                        teste automate (testthat), test în browser, fișiere de test
```

## Cerințe

- R 4.2 sau mai nou (pe Windows, R 4.2+ folosește UTF-8, necesar pentru diacritice).
- RStudio, orice versiune recentă.
- Pachetele: shiny, bslib, DBI, RSQLite, DT, writexl, openxlsx, plotly, ggplot2, jsonlite, commonmark, openssl, testthat; pentru găzduire, RPostgres și rsconnect.

Testat cu R 4.3.3, shiny 1.8.0, bslib 0.6.1, plotly 4.10.4, DT 0.31, RSQLite 2.3.4, RPostgres 1.4.8 și PostgreSQL 16. Harta folosește Leaflet 1.9.4 inclus în proiect.

## Pornire locală

1. Dezarhivați `chestionar_constanta_v3.3.0.zip` într-un folder fără caractere speciale în cale.
2. Deschideți `chestionar_constanta.Rproj`.
3. O singură dată, în consolă: `source("scripts/instaleaza_pachete.R")`.
4. Copiați `.Renviron.exemplu` cu numele `.Renviron` și completați `CHESTIONAR_ADMIN_PAROLA=` cu o parolă lungă. Apoi **Session > Restart R**.
5. Deschideți `app.R` și apăsați **Run App** (sau, în consolă, `shiny::runApp()`).

Din terminal, fără RStudio:

```
Rscript -e 'shiny::runApp(port = 7788, launch.browser = TRUE)'
```

La pornire, consola afișează modul și baza de date, de exemplu `Chestionar pornit în modul 'test'. Baza de date: .../data/raspunsuri_TEST.sqlite (0 răspunsuri).` În modul producție, consola avertizează dacă parola lipsește.

### Actualizarea de la versiunea 2

1. Faceți o copie a folderului `data/` din versiunea 2 (sau rulați `source("scripts/copie_de_siguranta.R")` în proiectul vechi).
2. Dezarhivați versiunea 3 într-un folder nou.
3. Copiați fișierele `.sqlite` din `data/` al versiunii 2 în `data/` al versiunii 3 și fișierul `.Renviron`, dacă există.
4. Porniți aplicația. La pornire se adaugă coloana `varsta_minima_confirmata` (dacă lipsește); rândurile existente rămân neschimbate. De la 3.0 la 3.1 nu se schimbă nimic în baza de date.

## Modul test și modul producție

| Mod | Baza de date | Ce vede respondentul |
|---|---|---|
| `test` (implicit) | `data/raspunsuri_TEST.sqlite` | bandă „Mod test”, note galbene pentru autoare, cronometrul de pe pagina finală |
| `productie` | `data/raspunsuri.sqlite` | chestionarul fără benzi, note sau cronometru |

Modul se schimbă în `R/00_config.R` (`MOD_IMPLICIT`) sau în `.Renviron` (`CHESTIONAR_MOD=productie`, cu prioritate).

## Zona de administrare

Se deschide adăugând `?admin` la adresă. Nu există link din chestionar.

Filele: „Răspunsuri” (tabel cu filtre), „Grafice” (pe fiecare întrebare), „Stare” (verificări de configurare), „Export” și, în modul test, „Date de test”.

Parola vine numai din variabila de mediu `CHESTIONAR_ADMIN_PAROLA`. Fără ea, zona este dezactivată, inclusiv pe calculatorul propriu. După 5 parole greșite, sesiunea este blocată 10 minute; după 10 greșeli în 10 minute, în orice sesiune, autentificarea este blocată pentru toți. După 30 de minute de inactivitate, sesiunea de administrare se închide.

## Unde se salvează datele

Fiecare trimitere adaugă un rând în tabela `raspunsuri` a bazei modului curent. Nimic nu se salvează în timpul completării. Răspunsurile nu se șterg automat, iar chestionarul nu are dată de închidere sau număr maxim de respondenți; autoarea îl închide oprind aplicația.

Fiecare completare are un cod aleatoriu de 32 de caractere (`response_id`), cheia primară a tabelei; un dublu-click sau o retrimitere nu poate crea un al doilea rând.

Folderul datelor se schimbă cu `CHESTIONAR_DATA_DIR`.

Dacă variabila de mediu `CHESTIONAR_DB_URL` are adresa unei baze PostgreSQL, răspunsurile se salvează acolo, în tabela `raspunsuri` (producție) sau `raspunsuri_test` (test), iar fișierele SQLite nu se folosesc. Adresa conține parola bazei și stă numai în `.Renviron` sau în variabilele secrete ale serverului; aplicația nu o afișează. Pe Connect Cloud și shinyapps.io fișierele locale se pierd la repornire și la republicare, deci acolo este nevoie de PostgreSQL (`docs/GAZDUIRE.md`).

## Copii de siguranță

`source("scripts/copie_de_siguranta.R")` copiază bazele de date în `copii_siguranta/`, cu data și ora în nume (de pe PostgreSQL, într-un fișier SQLite). Din zona de administrare, butonul „Copie a bazei de date (.sqlite)” descarcă același lucru. La găzduire, copia zilnică automată este descrisă în `docs/GAZDUIRE.md`, etapa 8. `scripts/reface_din_copie.R` readuce răspunsurile dintr-o copie `.sqlite` sau `.csv`, adăugând numai ce lipsește.

## Exporturi

Din fila „Export”:

| Export | Format | Conținut |
|---|---|---|
| Brut | `.xlsx` (4 foi), `.csv`, `.sqlite` | toate rândurile exact cum au fost salvate: `raspunsuri` (coduri), `raspunsuri_etichete`, `dictionar_date`, `informatii` |
| Pentru analiză | `.xlsx` (4 foi) | aceleași rânduri plus variabilele derivate: `analiza_coduri`, `analiza_etichete`, `dictionar` (toate variabilele, inclusiv cele derivate, cu definiția și fișierul în care sunt calculate), `informatii` |

Variabilele derivate: `completare_valida`, `q06_total_persoane`, `q09_total_procente`, `litri_pe_persoana_zi`, `q12_nr_obiecte_aruncate`, `ind_ulei_chiuveta`, `ind_q12_oricare`, `ind_q12_servetele`. Fără a porni aplicația: `source("scripts/exporta_raspunsuri.R")` scrie cele trei fișiere în `export/`.

CSV-ul este UTF-8 cu BOM, separator virgulă, punct zecimal. Celulele goale înseamnă valoare lipsă (NA). Exporturile nu conțin parole sau setări interne.

## Dicționarul de date

`docs/dictionar_date.csv` și `.xlsx` descriu cele 86 de coloane ale bazei de date. Se regenerează cu `source("scripts/genereaza_dictionar.R")`.

Convenții:

- Răspuns unic: codul variantei (de exemplu `q02_varsta = 25_34`; `sub_18` = „Sub 18 ani”).
- Selecție multiplă (Q10, Q11, Q16, Q20): o coloană 0/1 pentru fiecare variantă.
- Q6 și Q9: din versiunea 3, un câmp lăsat gol se salvează 0.
- Q8: `q08_nu_stiu = 1` și ambele volume goale la „Nu știu”; `q08_apa_calda_m3` gol cu `q08_nu_stiu = 0` = doar apă rece.
- Q12: o coloană pentru fiecare obiect, cu codul motivului.
- Q20: dacă Q19 nu este „Da”, coloanele `q20_*` sunt goale și `q20_afisata = 0`.
- Q21: `q21_*` de la 1 la 5. `q21_toti` (0/1) există doar în răspunsurile din versiunile 1–2.
- `varsta_minima_confirmata = 1` doar la răspunsurile din versiunea 3.0 (confirmarea vârstei nu se mai cere din 3.1).
- `submitted_at`: din versiunea 3.2 doar data trimiterii (UTC), fără oră; răspunsurile mai vechi au data și ora.

## Configurare

| Ce | Unde |
|---|---|
| Etichetele scalei Q21 (1 și 5) | `R/00_config.R`: `Q21_ANCORE_ACTIVE` (activ, aprobat de autoare); textele în `Q21_ANCORE_ETICHETE` |
| Pragul comparației (30) și dezactivarea ei | `R/00_config.R`: `COMPARATIE_MIN_RASPUNSURI`, `COMPARATIE_ACTIVA` |
| Harta tematică: pragurile și dezactivarea | `R/00_config.R`: `HARTA_PRAG_TOTAL` (30), `HARTA_PRAG_CARTIER` (10), `HARTA_PRAG_NUMAR` (5), `HARTA_TEMATICA_ACTIVA` |
| Limitele celor 42 de cartiere | `www/harta/cartiere.geojson` (orientative, OpenStreetMap, ODbL; refacere cu `scripts/importa_cartiere_osm.R`) sau `CHESTIONAR_CARTIERE_GEOJSON`; câmpul `tip_limite` (`oficiale` / `orientative`); detalii în `docs/HARTA_DATE_SI_LIMITARI.md` |
| Butonul pentru fundalul OpenStreetMap | `R/00_config.R`: `HARTA_FUNDAL_OSM_PERMIS` |
| Durata estimată pe pagina de start | `R/00_config.R`: `DURATA_ESTIMATA_MINUTE` (acum `"10–15"`; metoda și validarea în `docs/DURATA_ESTIMATA.md`) |
| Textul de informare | `config/informare_consimtamant.md`; secțiunea despre păstrare începe cu `## Păstrarea datelor` (verificată în fila „Stare”) |
| Titlul, autoarea | `R/00_config.R`: `TITLU_ACADEMIC`, `AUTOARE` |
| Lista cartierelor | `config/zone_q1.csv` și `config/cartiere_hcl79_2023.csv` |
| Opțiunile exclusive, limitele numerice | `R/00_config.R`: `EXCLUSIVE`, `LIMITA_*` |
| Parola, modul, folderul datelor | `.Renviron` |

După orice modificare, reporniți aplicația.

## Păstrarea și ștergerea datelor

Răspunsurile se păstrează pe durată nedeterminată (decizia autoarei, trecută în textul de informare). Aplicația nu șterge nimic automat.

Un singur răspuns se șterge astfel:

```r
source("scripts/_incarca.R")
con <- deschide_db(cale_baza_date("productie"))
DBI::dbExecute(con, "DELETE FROM raspunsuri WHERE response_id = ?", params = list("codul-raspunsului"))
DBI::dbDisconnect(con)
```

Datele de test se șterg cu `source("scripts/reseteaza_date_test.R")`; funcția refuză orice fișier care nu se termină în `_TEST.sqlite`.

## Teste

```r
source("scripts/ruleaza_teste.R")
```

595 de verificări automate pe baze de date temporare. Testul în browser (291 de verificări) și rezultatele verificărilor cerute sunt în `docs/TESTARE.md`.

## Securitate

Ce face aplicația:

- verifică parola pe server (comparație de hash SHA-256); tabelul, graficele și descărcările nu există pentru o sesiune neautentificată, iar fiecare descărcare verifică din nou autentificarea;
- limitează încercările pe sesiune și pe proces; închide sesiunea după inactivitate;
- ține bazele de date, configurația și codul în afara folderului public `www/` (verificat: 404);
- nu salvează adresa IP, nu setează cookie-uri și nu folosește servicii de analiză; fonturile, scripturile și harta sunt locale; fundalul OpenStreetMap se încarcă doar la cerere (auditul complet: `docs/AUDIT_ANONIMAT.md`).

Slăbiciuni cunoscute:

- o singură parolă comună, fără conturi și fără autentificare în doi pași;
- blocarea încercărilor este în memorie și se resetează la repornirea aplicației; pe mai multe procese, fiecare are propriul contor;
- nu există jurnal al accesărilor zonei de administrare (doar mesaje în consolă la parolele greșite);
- parola circulă necriptată dacă serverul nu folosește HTTPS;
- oricine are acces la fișierele serverului are acces la baza de date.

Pentru publicare, o protecție suplimentară la nivelul serverului (de exemplu, autentificarea din Posit Connect) este mai sigură. Aplicația nu a trecut printr-o evaluare de securitate și nu este garantată conformitatea cu GDPR sau cu procedurile universității.

## Probleme frecvente

**„Lipsesc pachetele: ...”** la pornire. Rulați `source("scripts/instaleaza_pachete.R")`.

**Diacriticele apar greșit.** Verificați versiunea R (4.2+) și, în RStudio, Tools > Global Options > Code > Saving > Default text encoding: UTF-8.

**Zona de administrare spune că este dezactivată.** Parola nu este setată sau R nu a fost repornit după modificarea `.Renviron`. Verificați cu `Sys.getenv("CHESTIONAR_ADMIN_PAROLA")`.

**„Prea multe încercări greșite”.** Așteptați 10 minute sau reporniți aplicația.

**„database is locked”.** Baza de date este deschisă în alt program. Închideți programul; pentru citire folosiți exportul sau o copie.

**Harta nu apare.** Verificați că există `www/lib/leaflet/` și `www/harta/uat.geojson`.

## Surse

Sursele recomandărilor, cu datele verificării și citatele exacte, sunt în `docs/REGISTRU_SURSE.md`. Datele hărții: HCL nr. 79/28.02.2023 (anexele 1 și 2); geoBoundaries, Romania ADM2 (sursa ANCPI, data.gov.ro, CC BY 4.0, https://www.geoboundaries.org); limitele cartierelor, © contribuitorii OpenStreetMap (ODbL 1.0), prin @nspot/geo-pack-romania-neighbourhoods 1.6.0.

Componente incluse: fonturile Bricolage Grotesque, Cormorant Garamond și Atkinson Hyperlegible (SIL Open Font License, `www/fonts/`); Leaflet 1.9.4 (BSD 2-Clause, `www/lib/leaflet/LICENSE`).
