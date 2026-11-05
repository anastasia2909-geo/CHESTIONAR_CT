# Raportul testelor (versiunea 3.3.0, 04.11.2026)

Testele au rulat în mediul de dezvoltare: Linux, R 4.3.3, shiny 1.8.0, bslib 0.6.1, plotly 4.10.4, DT 0.31, RSQLite 2.3.4, RPostgres 1.4.8, un server PostgreSQL 16 local, Chromium (Playwright) și axe-core 4.14.0. Toate rulările au folosit foldere de date temporare (`CHESTIONAR_DATA_DIR`), nu folderul `data/` al proiectului.

## Rezumat

| Ce | Rezultat |
|---|---|
| Teste automate în R (`scripts/ruleaza_teste.R`) | 629 trecute, 0 eșuate, 0 erori, cu `CHESTIONAR_TEST_PG_URL` setată; fără ea, 600 trecute și 4 teste PostgreSQL sărite |
| Test în browser (`tests/browser/test_e2e.py`), SQLite | 291 din 291 verificări trecute (inclusiv: data trimiterii fără oră, informarea cu anonimatul, harta cu 42 de cartiere) |
| Test în browser, PostgreSQL | 269 din 269 verificări trecute (aceleași parcursuri, fără harta cu poligoane de test, care nu depinde de stocare) |
| Accesibilitate (axe-core, WCAG 2.0/2.1 A și AA) | 0 încălcări pe pagina de start, informare (și cu eroare), secțiunile 1, 2 și 4, verificare, pagina finală, harta tematică (desktop și telefon), autentificarea și exportul din administrare |
| Repornirea aplicației | 33 de răspunsuri înainte și după |
| Folderul `data/` al proiectului | neatins: amprentele SHA-256 ale celor două fișiere sunt identice înainte și după lucru; o copie a fost făcută înainte de orice modificare |

## Verificările din versiunea 3.3 (PostgreSQL și găzduire)

| Verificare | Rezultat | Cum s-a verificat |
|---|---|---|
| Salvare, duplicat, citire, coloane noi | PASS | testthat pe PostgreSQL 16, într-o schemă temporară ștearsă la final; valorile citite sunt identice cu cele din SQLite pentru același răspuns |
| Moduri separate | PASS | test → tabela `raspunsuri_test`, producție → `raspunsuri`; ștergerea și datele sintetice refuză tabela de producție |
| Parola bazei nu apare | PASS | testthat: descrierea din administrare și mesajul la o adresă greșită nu conțin utilizatorul sau parola |
| Parcurs complet în browser pe PostgreSQL | PASS | 269 de verificări: trimiteri pe telefon și desktop, refuzul trimiterii fără acord, comparația, administrarea, exporturile, fila „Stare” |
| Persistența la repornire | PASS | aplicația pe PostgreSQL oprită și repornită: 33 → 33 răspunsuri; fișierele SQLite nu au fost create |
| Copia SQLite din PostgreSQL | PASS | testthat: același număr de rânduri și aceleași valori; refuză suprascrierea unui fișier existent |
| Copia zilnică (`docs/copie_automata/copie_zilnica.yml`) | PASS (local) | pașii rulați local, cu pg_dump 16 în loc de imaginea Docker: prima rulare face commit cu 3 răspunsuri, a doua nu face nimic; `raspunsuri.sql` refăcut într-o bază nouă: 3 rânduri; CSV cu BOM UTF-8. Rularea pe GitHub: NOT TESTED (contul nu există) |
| Refacerea din copie (`scripts/reface_din_copie.R`) | PASS | din `raspunsuri.csv` într-o bază SQLite goală: 3 adăugate, a doua rulare 0 adăugate și 3 existente; conținutul identic cu tabela PostgreSQL |
| `manifest.json` (`scripts/pregateste_publicarea.R`) | PASS (cu o precizare) | 89 de pachete, inclusiv RPostgres, 92 de fișiere, fără `data/`, `.Renviron` sau `.sqlite`. RPostgres a fost instalat din sursă în mediul de test, iar renv refuză pachetele fără sursă cunoscută; pentru test, copia pachetului a fost marcată „Repository: CRAN”. Pe un calculator cu pachetele instalate din CRAN, pasul acesta nu este necesar |
| Neon, Connect Cloud, GitHub Actions | NOT TESTED | conturile nu au fost create (le creează autoarea, `docs/GAZDUIRE.md`) |

## Verificările din versiunea 3.1

| Nr. | Verificare | Rezultat | Cum s-a verificat |
|---|---|---|---|
| 1 | Testele aplicației | PASS | 595 de verificări în R și 291 în browser, toate trecute |
| 2 | Chestionarul funcționează | PASS | Parcursuri complete pe telefon și desktop, cu validare, navigare, verificare, trimitere și pagina finală |
| 3 | Răspunsurile se păstrează | PASS | 33 de răspunsuri înainte și după repornire (SQLite local); migrarea unei baze v2 fără pierderi; `data/` neatins. Pe un server de găzduire: NOT TESTED (neales) |
| 4 | Autentificarea administratorului | PASS | e2e: fără parolă și cu parola greșită, refuz; cu parola corectă, acces; `?admin` funcționează. testthat: parola citită din `.Renviron` cu ghilimele, diacritice, spații finale și CRLF este acceptată. Parola reală a autoarei nu a fost testată: proiectul nu conține `.Renviron` |
| 5 | Etichetele Q21 active | PASS | testthat și e2e: „1 = responsabilitate foarte mică”, „5 = responsabilitate foarte mare”; coloanele 1–5 și variabilele neschimbate |
| 6 | Durata estimată | PASS | `DURATA_ESTIMATA_MINUTE = "10–15"`, afișată pe pagina de start (testthat și e2e). Validarea cu persoane reale: NOT TESTED |
| 7 | Nicio restricție de vârstă | PASS | testServer: un răspuns cu Q2 = „Sub 18 ani” se salvează; e2e: fără întrebare despre vârstă, fără pagină de respingere, acordul e singura condiție; ocolirea fără acord nu salvează nimic |
| 8 | Datele de identificare | PASS | Cod: nicio citire de IP, user-agent, cookie sau stocare în browser; e2e: nicio cerere externă, niciun cookie, `localStorage` și `sessionStorage` goale; jurnalul aplicației fără IP-uri. Jurnalele serverului de găzduire: NOT TESTED (neales). Detalii în `docs/AUDIT_ANONIMAT.md` |
| 9 | Persistența și copiile | PASS (local) | Persistență locală verificată; limitele pe shinyapps.io verificate în documentația Posit; copiile sunt manuale (`docs/GAZDUIRE.md`) |
| 10 | Harta pe cartiere | PASS | Cele 42 de cartiere reale (orientative, OpenStreetMap după HCL nr. 79/2023): coduri identice cu Q1, geometrii valide, fără suprapuneri; e2e: 42 de poligoane desenate, nota „orientative, nu oficiale”, verificarea cu planul în fișă, atribuirea OpenStreetMap. Colorarea pe indicatori: testată și cu poligoanele FALSE |

## Cele 42 de verificări cerute în versiunea 3.0 (rezultatele actuale)

PASS = rulat și confirmat. FAIL = rulat și eșuat. NOT TESTED = nu a putut fi rulat.

| Nr. | Verificare | Rezultat | Cum s-a verificat |
|---|---|---|---|
| 1 | Aplicația pornește prin procedura documentată | PASS | `shiny::runApp()` din folderul proiectului (echivalentul butonului Run App). RStudio nu este instalat în mediul de test. |
| 2 | Pagina de start: titlul exact și datele autoarei | PASS | e2e: `h1` = titlul exact; numele, e-mailul și facultatea în pagină |
| 3 | Sloganul lipsește | PASS | e2e și testthat (`SLOGAN` nu mai există) |
| 4 | Secțiunea „Cum sunt folosite datele” lipsește | PASS | e2e (textul paginii) și testthat (fișierul de informare) |
| 5 | Informarea și acordul apar înaintea întrebărilor | PASS | e2e: start → informare; fără vârstă și acord nu se începe |
| 6 | Persoanele sub 18 ani nu pot continua sau trimite | ÎNLOCUIT | Cerința a fost inversată în 3.1: nu există limită de vârstă (verificarea 7 din tabelul de mai sus) |
| 7 | Utilizabil pe telefon și desktop | PASS | e2e la 390 × 844 și 1280 × 900: parcurs complet, fără derulare orizontală, axe fără încălcări. Telefoane fizice: netestat. |
| 8 | Diacriticele se afișează corect | PASS | e2e compară titlul, informarea, etichetele Q1 și exporturile (UTF-8, CSV cu BOM) |
| 9 | Progresul și navigarea | PASS | e2e: „Secțiunea 1 din 4 … întrebările 1–7 din 25”, 0%, apoi 28%; „Înapoi”, „Continuă”, „Modifică” |
| 10 | Răspunsurile rămân la navigarea înapoi | PASS | e2e: Q5, Q8, Q9, Q10 după „Înapoi” |
| 11 | Q1: 42 de cartiere, alfabetic, fără „Nu știu” | PASS | testthat (ordine alfabetică românească) și e2e |
| 12 | Q21 fără caseta „Toți au responsabilități” | PASS | e2e (elementul lipsește); testthat (`q21_toti` gol la răspunsurile noi) |
| 13 | Etichetele Q21 dezactivate până la confirmare | ÎNLOCUIT | Confirmate de autoare în 3.1 și active (verificarea 5 de mai sus) |
| 14 | Logica condiționată și întrebările obligatorii | PASS | testthat și e2e: Q20 apare doar la „Da”, 7 erori pe secțiunea 1 goală |
| 15 | Limitele numerice | PASS | testthat (Q5, Q6, Q8, Q9, Q25) |
| 16 | Q9: totalul cu câmpuri goale | PASS | e2e: 6 câmpuri completate, 1 gol → „Total: 95%” |
| 17 | Câmpurile goale = 0 doar unde are sens | PASS | testthat și e2e: Q6 și Q9 goale → 0 salvat; Q5 și Q8 goale rămân lipsă și sunt cerute |
| 18 | Text nevalid, valori negative sau prea mari | PASS | testthat (negative, peste limită, `.invalide`) și e2e (caracter nevalid în Q6 respins, nu socotit 0) |
| 19 | Q9 respinge totalul greșit și acceptă 100% | PASS | testthat și e2e |
| 20 | Fără trimiteri duble | PASS | testServer (3 trimiteri → 1 rând) și e2e (3 clickuri → 1 rând) |
| 21 | Cardurile Q12 lipsesc din profil | PASS | testServer și e2e (conținutul `#profil`) |
| 22 | Cardurile Q10–Q11 lipsesc din profil | PASS | aceleași verificări |
| 23 | Q10, Q11, Q12 rămân în chestionar și în exporturi | PASS | e2e (completate în secțiunea 2); testthat (schema și exporturile) |
| 24 | Profilul folosește răspunsurile reale | PASS | e2e: cartier, locuință, Q9, Q13–Q16, Q24 din completare |
| 25 | Estimarea consumului, aceeași formulă | PASS | e2e: 14 m³, 4 persoane → 117 l; testthat: 9 m³, 2 persoane → 150 l |
| 26 | Comparația ascunsă sub 30 de completări valide | PASS | testthat și e2e (mesaj fără procente) |
| 27 | Procentele și numitorii comparației | PASS | testthat (sume 100%) și e2e (3 carduri, sume 100%, numitorul afișat) |
| 28 | Harta tematică: limite verificate și coduri corecte | PASS (limite orientative) | Limitele celor 42 de cartiere din OpenStreetMap după HCL nr. 79/2023; delimitări identice cu anexa 1 (42/42); coduri identice cu Q1; 3 cartiere cu verificare „incertă” față de plan, marcate pe site. Nu sunt limite cadastrale oficiale. |
| 29 | Hartă: număr de respondenți separat de procente | PASS | testthat și e2e (unități diferite, clase diferite, descrieri) |
| 30 | Legende, unități, numitori, date lipsă | PASS | testthat (stări) și e2e (legendă, „date insuficiente”, etichete cu numitor) |
| 31 | Fără răspunsuri individuale sau statistici înșelătoare | PASS | testthat: sub prag nu se trimite nicio valoare; numărul 1–4 nu se afișează exact |
| 32 | OpenStreetMap doar după apăsarea butonului | PASS | e2e: 0 cereri înainte, cereri doar către `tile.openstreetmap.org` după. Afișarea plăcilor: netestată (rețea blocată). |
| 33 | Planul cartierului corespunde Q1 | PASS | testthat (42 de cartiere) și e2e (Tomis Nord, nr. 35, `anexa_2_35.jpg`) |
| 34 | Butonul de tipărire/PDF lipsește | PASS | e2e și testthat |
| 35 | Recomandările și sursele documentate | PASS | testthat: fiecare sursă are intrare în `docs/REGISTRU_SURSE.md`; e2e: sursele apar lângă recomandări. Trei acte normative citite pe copii: de reconfirmat (blocant 7). |
| 36 | Zona admin cere autorizare | PASS | e2e: fără parolă nu se deschide (nici pe localhost); parola greșită refuzată; login forțat din consolă refuzat; testthat: blocare globală, comparația parolei |
| 37 | Exporturile brut și pentru analiză | PASS | e2e: descărcare după autentificare; 33 de rânduri, 86 și 94 de coloane; testthat: foi, variabile derivate, dicționar |
| 38 | Codificarea răspunsurilor păstrată | PASS | testthat: coduri, etichete, coduri vechi păstrate |
| 39 | Nicio parolă sau dată brută publică | PASS | e2e: 10 adrese (bază de date, config, `app.R`, `.Renviron`, încercări cu `../`) → 404; 4 descărcări directe fără autentificare → fără date; testthat: niciun fișier sensibil în `www/`, nicio parolă în exporturi |
| 40 | Răspunsurile existente păstrate | PASS | Folderul `data/` al proiectului nu a fost atins (fișierele au data 27.10.2026, dinaintea versiunii 3). El conține doar baze create la testele versiunii 2, nu date de cercetare. |
| 41 | Baza de date rămâne după repornire | PASS | local, SQLite: 33 → 33 răspunsuri. Pe un server de găzduire: netestat (nu este ales). |
| 42 | Schimbările de schemă sunt compatibile | PASS | testthat: o bază cu schema v2 (cu `q21_toti = 1`, `q02 = sub_18`) este migrată prin adăugarea coloanei `varsta_minima_confirmata`, fără pierderi; valorile vechi rămân în exporturi |

## Teste automate în R

```r
source("scripts/ruleaza_teste.R")
```

| Fișier | Ce verifică |
|---|---|
| `test-intrebari.R` | 25 de întrebări; textele față de sursă; Q1 (42, alfabetic, fără „Nu știu”); Q2 cu „Sub 18 ani”; Q21 fără casetă, cu etichete active; durata pe pagina de start; informarea (autoarea, păstrarea, fără limită de vârstă, fără afirmații juridice nesusținute) |
| `test-validare.R` | limitele; Q6 și Q9 cu câmpuri goale = 0; câmpurile marcate invalide de browser; exclusivitate; Q12; Q20; Q21; 300 de răspunsuri sintetice valide |
| `test-codificare.R` | NA păstrat unde trebuie; `q21_toti` gol; vârsta confirmată; textul liber curățat; litri pe persoană pe zi |
| `test-stocare-export.R` | salvare, duplicat refuzat, ștergerea datelor de test refuză baza reală, coloane noi, export Excel/CSV |
| `test-server.R` | fluxul complet; „Sub 18 ani” la Q2 se salvează; fără acord nu se salvează; acordul retras după începere; Q20 neaplicabilă; Q6/Q9 goale și câmp invalid |
| `test-cartiere-harta.R` | tabelul HCL; limitele UAT; fișierul vectorial; recomandările și sursele; comparația; pagina finală pentru toate cartierele |
| `test-indicatori.R` | numărători, numitori, praguri, stări, clase; filtrul de răspunsuri valide; mesajul către browser fără valori suprimate; fișierul de poligoane FALSE din afara `www/` |
| `test-v3-date-export-acces.R` | migrarea unei baze v2; exportul pentru analiză; parola; blocarea globală; fila „Stare”; nimic sensibil în `www/` |

## Test în browser

Opțional, pentru dezvoltator. Necesită Python cu Playwright și R în PATH. Aplicația se pornește cu un folder de date separat și o parolă de test:

```
CHESTIONAR_MOD=test CHESTIONAR_DATA_DIR=/tmp/date_e2e CHESTIONAR_ADMIN_PAROLA=parola-de-test \
  Rscript -e 'shiny::runApp(port = 7788)'
python3 tests/browser/test_e2e.py http://127.0.0.1:7788/ /tmp/date_e2e/raspunsuri_TEST.sqlite capturi parola-de-test
```

Pentru harta tematică, o a doua instanță, cu poligoanele FALSE și cel puțin 30 de răspunsuri de test, al cărei URL se dă ca al cincilea argument:

```
CHESTIONAR_DATA_DIR=/tmp/date_harta CHESTIONAR_CARTIERE_GEOJSON=$PWD/tests/fixtures/cartiere_test_FALS.geojson \
  CHESTIONAR_ADMIN_PAROLA=x Rscript -e 'shiny::runApp(port = 7790)'
```

Variabila `AXE_PATH` (calea către `axe.min.js`) activează verificarea accesibilității.

Parcursuri: acord (fără limită de vârstă), telefon, desktop, mișcare redusă, desktop cu comparație (după 30 de răspunsuri sintetice), securitate (adrese statice, descărcări fără autentificare), zona de administrare (Stare, grafice, trei exporturi), harta tematică pe desktop și pe telefon.

În zona de administrare apare în consola browserului eroarea „c.define is not a function”. Vine din fișierul `selectize.min.js` pe care pachetul Ubuntu `r-cran-dt` îl ia din `/usr/share/javascript`, nu din codul aplicației, și nu afectează tabelul. Testul o ignoră explicit. Cu pachetul DT instalat de pe CRAN (fișierele proprii ale pachetului) nu a putut fi verificat, pentru că CRAN nu este accesibil din mediul de test.

## Verificare manuală în RStudio

1. **Pornire.** Run App deschide pagina de start: titlul lucrării, coasta Constanței, faptele (25 de întrebări, 10–15 minute, fără nume, voluntar), autoarea.
2. **Mișcare.** Conturul coastei se desenează, undele pulsează, banda de jos se derulează. Cu „Reduce motion” activ în sistem, nimic nu se mișcă.
3. **Informare.** „Începe: informare și acord” → textul informării și caseta de acord. Fără bifă, chestionarul nu începe.
4. **Chestionar.** Q1 are 42 de cartiere alfabetic; Q2 începe cu „Sub 18 ani”; Q21 are etichetele 1 și 5; la Q6 și Q9 câmpurile goale se socotesc 0; Q21 nu are caseta „Toți au responsabilități”.
5. **Tranziții.** La „Continuă”, un val bleumarin trece peste ecran.
6. **Pagina finală.** Picătura cade, apar undele, apoi mulțumirea. „Vedeți profilul dumneavoastră” duce la profil. Nu există buton de tipărire.
7. **Cronometrul (modul test).** Notați durata afișată la mai multe completări făcute de persoane diferite și setați `DURATA_ESTIMATA_MINUTE`.
8. **Fundalul hărții.** Apăsați „Afișează fundalul OpenStreetMap”: apar străzile (netestat în mediul de dezvoltare).
9. **Zona de administrare.** Cu parola setată în `.Renviron`: fila „Stare”, exportul brut și exportul pentru analiză. Deschideți exporturile în Excel.
10. **Telefon fizic.** Deschideți aplicația de pe telefon în aceeași rețea (`shiny::runApp(host = "0.0.0.0", port = 7788)` și adresa IP a calculatorului).

## Ce nu a fost testat și de ce

- **Afișarea plăcilor OpenStreetMap:** rețeaua mediului de test blochează OpenStreetMap.
- **Găzduirea:** varianta este pregătită (`docs/GAZDUIRE.md`), dar conturile nu există; codul a fost testat pe un PostgreSQL local, nu pe Neon, și nu pe Connect Cloud.
- **RStudio, Safari, Firefox, telefoane fizice, cititoare de ecran reale:** indisponibile în mediul de test. Accesibilitatea a fost verificată automat cu axe-core și prin navigare din tastatură în testul în browser (focalizarea primei erori).
- **Durata reală de completare:** cere persoane reale (metoda de validare în `docs/DURATA_ESTIMATA.md`).
- **Jurnalele și cookie-urile platformei Connect Cloud:** de verificat după publicare.
- **Microsoft Excel:** fișierele au fost citite înapoi cu `openxlsx`.
- **Versiunile cele mai noi de pe CRAN:** CRAN nu a fost accesibil.

## Arhiva

Arhiva `chestionar_constanta_v3.3.0.zip` a fost extrasă într-un folder nou. Acolo, `scripts/ruleaza_teste.R` a trecut 600 de verificări fără PostgreSQL (4 sărite) și 629 cu `CHESTIONAR_TEST_PG_URL`; testul în browser a trecut 291 din 291 verificări; pagina a răspuns cu 200, iar `/data/raspunsuri_TEST.sqlite` cu 404. Un `git add` de probă în folderul extras, cu un `.Renviron`, fișiere `.sqlite`, `export/` și `copii_siguranta/` create intenționat, nu a adăugat niciunul dintre ele. Arhiva nu conține baze de date, `.Renviron`, `manifest.json` sau fișiere temporare.
