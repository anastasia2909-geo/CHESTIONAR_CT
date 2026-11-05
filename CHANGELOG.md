# Istoricul modificărilor

## 3.3.0 (04.11.2026)

- **Stocare PostgreSQL pentru găzduire:** cu variabila de mediu `CHESTIONAR_DB_URL`, răspunsurile se salvează într-o bază PostgreSQL (tabelele `raspunsuri` și `raspunsuri_test`), în afara serverului aplicației. Fără variabilă, aplicația folosește SQLite, ca până acum. Aceleași reguli: cheia primară `response_id`, duplicatele recunoscute, coloanele noi adăugate fără pierderi, ștergerea permisă numai în tabela de test. Conexiunea se reîncearcă de două ori (o bază Neon oprită pornește la prima conexiune). Adresa și parola bazei nu apar în mesaje sau în administrare.
- **Administrare:** fila „Stare” verifică scrierea în baza PostgreSQL; rândul „Găzduirea” este „în regulă” când răspunsurile sunt în PostgreSQL. Tabelul se reîmprospătează numai după autentificare. Butonul „Copie a bazei de date (.sqlite)” copiază și din PostgreSQL, cu verificarea numărului de rânduri.
- **Scripturi noi:** `scripts/pregateste_publicarea.R` (creează și verifică `manifest.json` pentru Connect Cloud, fără date sau parole), `scripts/reface_din_copie.R` (readuce răspunsurile dintr-o copie `.sqlite` sau `.csv`, adăugând numai ce lipsește). `scripts/copie_de_siguranta.R` lucrează și cu PostgreSQL. `scripts/instaleaza_pachete.R` instalează și RPostgres și rsconnect.
- **Copie zilnică automată:** `docs/copie_automata/copie_zilnica.yml`, pentru GitHub Actions într-un depozit privat (CSV, copie SQL, număr de răspunsuri; commit numai la schimbări).
- **Documente:** `docs/GAZDUIRE.md` rescris ca ghid pas cu pas (Neon, GitHub, Connect Cloud, pilot, producție, copii, lansare, refacere). `.gitignore` exclude parolele, bazele de date, copiile și exporturile. `.Renviron.exemplu` are `CHESTIONAR_DB_URL`.
- **Teste:** `tests/testthat/test-postgres.R` (rulează cu `CHESTIONAR_TEST_PG_URL`, într-o schemă temporară); testul în browser lucrează și pe PostgreSQL. Testele scot `CHESTIONAR_DB_URL` din mediu, ca să nu atingă baza reală.

## 3.2.0 (01.11.2026)

- **Anonimat:** data trimiterii se salvează fără oră (`PRECIZIE_DATA_TRIMITERII <- "zi"`); răspunsurile deja salvate nu se modifică. Textul de informare spune că chestionarul este anonim și exact ce se salvează; subsolul are mențiunea „Chestionar anonim” și atribuirile hărții.
- **Cadrul legal:** document nou `docs/CADRU_LEGAL.md` (GDPR, considerentul 26; Legea nr. 506/2004, art. 4; Legea nr. 8/1996, art. 9; licențele ANCPI/geoBoundaries și OpenStreetMap; accesibilitate). Surse noi în `docs/REGISTRU_SURSE.md`.
- **Recomandări:** recomandare nouă „Ce prevede legea”, din Legea nr. 241/2006 (art. 5 alin. 3) și NTPA-002 (art. 5 pct. 1).
- **Administrare:** fila „Stare” are rândul „Anonimat” în locul rândului „Confirmări instituționale”.
- **Harta cartierelor:** cele 42 de cartiere sunt desenate pe hartă (`www/harta/cartiere.geojson`), din pachetul @nspot/geo-pack-romania-neighbourhoods 1.6.0: delimitările din anexa 1 la HCL nr. 79/2023 trasate pe linii OpenStreetMap (08.10.2026), ODbL. Delimitările sunt identice cu transcrierea proiectului pentru toate cele 42 de cartiere. Limitele sunt prezentate ca orientative; fișa cartierului arată verificarea cu planul (17 în regulă, 22 aproximative, 3 incerte). Script nou `scripts/importa_cartiere_osm.R`, fișier de licență `www/harta/cartiere_LICENTA.txt`, atribuire OpenStreetMap pe hartă și în subsol; teritoriul municipiului din afara cartierelor are o culoare și o intrare proprie în legendă.
- **Decizii:** scoase punctele privind minorii, avizele de etică, temeiul prelucrării și planurile scanate (confirmate de autoare). Găzduirea rămâne ultima etapă.

## 3.1.0 (01.11.2026)

Clarificări tehnice cerute de autoare. Designul, paginile și interacțiunile nu s-au schimbat, în afara elementelor legate de vârstă enumerate mai jos. Baza de date nu se modifică (nicio coloană nouă, niciun rând atins).

### Chestionar

- Fără limită de vârstă: s-au eliminat întrebarea „Aveți cel puțin 18 ani?” de pe pagina de informare, pagina de respingere și verificarea pe server. Acordul rămâne singura condiție, verificată pe server.
- Q2: varianta „Sub 18 ani” este din nou disponibilă (cod `sub_18`, ca în versiunile 1–2).
- Q21: etichetele „1 = responsabilitate foarte mică” și „5 = responsabilitate foarte mare” sunt active. Scala și datele nu s-au schimbat.
- Pagina de start: plăcuța „18+ / doar persoane adulte” a fost înlocuită cu „fără nume / nu cerem nume, e-mail sau telefon”; plăcuța duratei arată „10–15 minute, estimat”.

### Informare și date

- Textul de informare: secțiunea „Participarea” fără limită de vârstă; „Ce date se salvează” spune că aplicația nu salvează adresa IP și nu folosește cookie-uri proprii și că serverul poate înregistra adresa IP în jurnale; secțiune nouă „Păstrarea datelor și accesul la ele” (durată nedeterminată, fără ștergere automată, fără dată de închidere stabilită, acces numai pentru autoare, rezultate doar agregat). Temeiul juridic și operatorul de date nu sunt menționate, pentru că nu sunt confirmate.
- `varsta_minima_confirmata` rămâne goală pentru răspunsurile noi.

### Hartă

- Un fișier de limite ale cartierelor fără `"tip_limite": "oficiale"` este prezentat sub hartă ca „orientativ, nu oficial”, cu sursa din fișier.

### Administrare

- Fila „Stare”: durata și Q21 în regulă; rând nou „Confirmări instituționale” (temeiul prelucrării, avizul de etică, minorii); găzduirea rămâne „de verificat”.

### Documentație și teste

- Documente noi: `docs/AUDIT_ANONIMAT.md`, `docs/DURATA_ESTIMATA.md`. Rescrise: `docs/GAZDUIRE.md` (comparația variantelor și recomandarea), `docs/DECIZII_DE_CONFIRMAT.md`. Completat: `docs/HARTA_DATE_SI_LIMITARI.md` (verificarea datelor de limite, modelul de cerere către Primărie).
- Teste noi sau schimbate: fără limită de vârstă, Q2 cu „Sub 18 ani”, etichetele Q21, durata, parola citită din `.Renviron` (ghilimele, diacritice, spații, CRLF), limitele orientative; în browser: nicio cerere externă, niciun cookie, nimic în stocarea browserului.

## 3.0.0 (29.10.2026)

Versiunea 2.0.0 este păstrată ca arhivă separată: `chestionar_constanta_v2.0.0.zip`. Numele coloanelor existente, codurile răspunsurilor și textul întrebărilor nu s-au schimbat, în afara celor două variante eliminate la cerere (Q2 „Sub 18 ani”, Q21 „Toți au responsabilități”). Baza de date se actualizează la pornire doar prin adăugarea unei coloane; nimic nu se șterge.

### Identitate și design

- Titlul principal al site-ului este titlul exact al lucrării: „Evaluarea comportamentelor populației și a nivelului de conștientizare privind gestionarea apelor uzate în municipiul Constanța”. Sloganul și titlul separat al chestionarului au fost eliminate.
- Singura persoană numită este autoarea: Anastasia NICEA, anastasia.nicea@s.unibuc.ro, Universitatea din București, Facultatea de Geografie (pagina de start, informarea, subsolul). Coordonatorul nu mai apare.
- Design nou pe toate paginile, inclusiv administrarea: crem, bleumarin și auriu, crom lichid, stele cu patru colțuri, orbită, bandă derulantă; titluri Bricolage Grotesque, accente Cormorant Garamond italic, text Atkinson Hyperlegible (toate locale, licență OFL). Emblema și favicon-ul au fost redesenate; `arcada.svg` și șase fișiere de font nefolosite au fost șterse.
- Pagina de start nouă: titlul, ilustrația coastei Constanței (`www/img/coasta.svg`, generată din limitele ANCPI cu `scripts/genereaza_grafica_coasta.R`; undele sunt decalaje ale țărmului, nu batimetrie), paragraful introductiv, numărul de întrebări, „18+”, „voluntar”, autoarea și butonul „Începe: informare și acord”. Durata nu este afișată până nu este măsurată.
- Animații: conturul coastei se desenează, undele pulsează, stelele sclipesc, banda se derulează; între pagini trece un val; sumarul de erori tremură. Toate se opresc la „prefers-reduced-motion”.

### Chestionar

- Pas separat de informare și acord înaintea întrebărilor, cu întrebarea „Aveți cel puțin 18 ani?”. „Nu” duce la o pagină de încheiere; sesiunea rămâne blocată și nu se salvează nimic. Vârsta și acordul sunt verificate pe server la începere și la trimitere. Coloană nouă: `varsta_minima_confirmata`.
- Q2: varianta „Sub 18 ani” a fost eliminată (Q6 o păstrează, pentru membrii gospodăriei).
- Q1: fără „Nu știu”; cele 42 de cartiere, alfabetic.
- Q21: caseta „Toți au responsabilități” a fost eliminată din formular; `q21_toti` rămâne în baza de date, goală pentru răspunsurile noi. Etichetele „1 = responsabilitate foarte mică” și „5 = responsabilitate foarte mare” sunt pregătite, dezactivate (`Q21_ANCORE_ACTIVE`).
- Q6 și Q9: un câmp gol se socotește 0 în total și se salvează 0. Un text care nu este număr (de exemplu „12abc”) este semnalat de browser și respins, nu socotit 0. Valorile negative și cele peste limită sunt respinse ca înainte.
- Progresul arată secțiunea, intervalul de întrebări („întrebările 8–13 din 25”) și procentul parcurs.

### Pagina finală

- Mesaj de final animat: o picătură cade, apar undele, apoi „Mulțumim! Răspunsurile au ajuns la destinație.” și butonul către profil.
- Profil reorganizat în carduri: pe scurt, consumul estimat (cu explicația calculului), repartiția Q9, apa uzată (Q13–Q16), informare și interes (Q17, Q18, Q23, Q24).
- Eliminate din profil: cardurile pentru obiectele de la Q12 și cele pentru obiceiurile și echipamentele de la Q10–Q11 (întrebările rămân în chestionar și în exporturi); butonul „Tipărește sau salvează ca PDF”.
- Recomandări rescrise pe baza unui registru de surse verificate (`docs/REGISTRU_SURSE.md`, `R/13_recomandari.R`): Water UK, Vital Baia Mare, Hadley et al. 2023, Husain et al. 2014, Wallace et al. 2017, NTPA-002, Ordinul MS 119/2014, Rogowska și Zimmermann 2022, Directiva (UE) 2024/3019, Luo et al. 2014 și un exemplu local (RAJA, Năvodari, 2026). Scoase: cifra de 93% de la Water UK, comunicatul Vital din 2020 (nu a mai putut fi deschis) și rezumatul Baker McKenzie.

### Harta tematică

- Patru indicatori pe cartiere: numărul de respondenți, uleiul turnat în chiuvetă (Q13), cel puțin un obiect aruncat în toaletă (Q12), șervețele umede aruncate în toaletă (Q12). Numitori, praguri și stări în `docs/INDICATORI_HARTA.md`; cod în `R/12_indicatori.R`.
- Praguri: 30 de completări valide în total, 10 respondenți pe cartier pentru procente, 5 pentru numărul de respondenți. Sub prag: „date insuficiente”, hașurat, fără valoare.
- Cu fișier vectorial al cartierelor: hartă colorată (paletă bleumarin cu o singură nuanță), legendă, valoare la trecerea mouse-ului, contur pentru cartierul respondentului. Fără fișier (situația actuală): tabele cu aceleași culori. Fișierul poate fi indicat și prin `CHESTIONAR_CARTIERE_GEOJSON`.
- Harta UAT, planurile scanate și butonul OpenStreetMap la cerere au rămas.

### Administrare

- Eliminată excepția „localhost fără parolă” (numele gazdei vine din browser și poate fi falsificat). Fără `CHESTIONAR_ADMIN_PAROLA`, zona este dezactivată.
- Blocare la nivelul procesului R: după 10 parole greșite în 10 minute, în orice sesiune, autentificarea este blocată pentru toți. Ieșire automată după 30 de minute de inactivitate.
- Filă nouă „Stare”: parola, durata, etichetele Q21, limitele cartierelor, informarea, pragurile, scrierea în folderul datelor, numărul de răspunsuri, găzduirea.
- Export nou pentru analiză (`.xlsx`): coduri și etichete, plus variabile derivate (`completare_valida`, totalurile Q6 și Q9, litri pe persoană pe zi, numărul de obiecte la Q12, indicatorii hărții) și dicționarul lor. Și în `scripts/exporta_raspunsuri.R`.
- Graficul Q21 nu mai prezintă „Toți au responsabilități” ca element curent; contorizează doar răspunsurile vechi.

### Date și documentație

- Migrare aditivă: coloana `varsta_minima_confirmata` se adaugă la pornire; rândurile vechi rămân (cu valoarea goală).
- Documente noi: `docs/REGISTRU_SURSE.md`, `docs/INDICATORI_HARTA.md`, `docs/GAZDUIRE.md`. Actualizate: `DECIZII_DE_CONFIRMAT.md`, `HARTA_DATE_SI_LIMITARI.md`, `TESTARE.md`, dicționarul de date (86 de coloane).
- Teste noi: indicatori, migrare, export pentru analiză, acces administrativ, eligibilitate, câmpuri goale și invalide; test în browser rescris (265 de verificări, inclusiv accesibilitate cu axe-core și harta tematică cu poligoane FALSE din `tests/fixtures/`).

## 2.0.0 (27.10.2026)

Versiunea 1.0.0 este păstrată ca arhivă separată: `chestionar_constanta_v1.0.0_original.zip`. Structura bazei de date, numele coloanelor din export, validările, zona de administrare și textul întrebărilor Q2–Q25 nu s-au schimbat.

### Titluri și identitate

- Trei texte separate, configurate în `R/00_config.R`:
  - titlul academic propus, „Evaluarea comportamentelor populației și a nivelului de conștientizare privind gestionarea apelor uzate în municipiul Constanța”, marcat „titlu propus”;
  - sloganul „Apa înseamnă viitorul orașului nostru.”;
  - titlul chestionarului, „Consumul de apă și comportamentele populației în contextul gestionării apelor uzate din municipiul Constanța”.
- Titlul chestionarului apare în fila browserului, în metadate și pe pagina de start; titlul academic apare în subsol și în textul de informare.
- A fost eliminat titlul vechi („Evaluarea sistemului de colectare și epurare...”), care sugera o evaluare tehnică a rețelei. Textul de informare spune acum explicit că chestionarul nu evaluează funcționarea tehnică a rețelei sau a stațiilor.

### Întrebarea 1 și cartierele

- Cele 5 zone de exemplu au fost înlocuite cu cele 42 de cartiere din anexa 1 la HCL nr. 79/28.02.2023, în ordine alfabetică. Schema fișierului `config/zone_q1.csv` (`cod`, `eticheta`) a rămas aceeași.
- Fișier nou, `config/cartiere_hcl79_2023.csv`, cu pentru fiecare cartier:
  - numărul din HCL și forma tipărită a denumirii;
  - delimitarea;
  - planul din anexa 2 și pagina din PDF;
  - observațiile de verificat.

  Aceleași date sunt în `docs/cartiere_hcl79_2023.xlsx`.
- Transcrierea a fost verificată prin a doua transcriere, independentă: 0 diferențe (`docs/CARTIERE_HCL79_2023.md`).
- Opțiune nouă, dezactivată: varianta „Nu știu cum se numește cartierul meu” (`Q1_VARIANTA_NU_STIU`).

### Pagina finală (refăcută)

- Mesaj de mulțumire, cu butonul „Tipărește sau salvează ca PDF” (dialogul browserului; serverul nu creează fișiere). La tipărire, fiecare secțiune începe pe o pagină nouă.
- Cuprins cu legături către secțiuni.
- **Profilul dumneavoastră:**
  - gospodăria;
  - informarea și interesul (Q17, Q18, Q23);
  - treptele de familiaritate cu termenul „micropoluanți” (Q24).
- **Cum folosiți apa:**
  - graficul Q9, cu tabel;
  - consumul pe persoană, ca estimare;
  - acțiunile și echipamentele (Q10, Q11), plus celelalte acțiuni din listă.
- **Ce ajunge în canalizare:**
  - Q12, ca tigle;
  - Q13–Q15, cu o explicație sursată;
  - Q16.
- **Constanța pe hartă:** hartă Leaflet, fișa cartierului ales, cu delimitarea oficială, și planul scanat din anexa 2.
- **Recomandări practice:** cele legate de răspunsuri sunt marcate cu întrebarea la care se referă, iar fiecare are o sursă (operatorul Vital Baia Mare, Water UK).
- **Comparație cu ceilalți respondenți:**
  - arată procente agregate pentru Q13, Q14 și Q24, cu răspunsul respondentului marcat;
  - apare numai după cel puțin 30 de completări;
  - sub prag, afișează un mesaj fără cifre.
- **Ce reprezintă aceste rezultate:** limitările.
- Lista surselor.

### Harta

- Leaflet 1.9.4, inclus local (`www/lib/leaflet/`); nu este nevoie de un pachet R nou.
- Limitele UAT provin de la ANCPI (data.gov.ro), prin geoBoundaries, sub licența CC BY 4.0 (`www/harta/uat.geojson`). Pregătirea lor este reproductibilă cu `scripts/pregateste_harta.R`.
- Harta are legendă, etichete, atribuirea sursei, buton de recentrare și un fundal OpenStreetMap opțional, încărcat doar la cerere.
- Suport pentru limitele vectoriale ale cartierelor (`www/harta/cartiere.geojson`): când fișierul există, cartierul ales este evidențiat. Fișierul nu este inclus, pentru că nu există date verificate (`docs/HARTA_DATE_SI_LIMITARI.md`).

### Design (după moodboard)

- Paletă preluată din moodboard: bleumarin #093951, albastru marin #367581, turcoaz stins #80A7AA, nisip #D4C4B0, salvie #8E9F8D, fond fildeș. Culorile de text au contrastul verificat (minimum 4,5:1).
- Titlurile folosesc Cormorant Garamond, inclus local sub licența OFL; înlocuiește Josefin Sans. Textul folosește în continuare Atkinson Hyperlegible.
- Pagina de start are o secțiune de deschidere cu sloganul, titlul chestionarului, trei repere și o ilustrație Art Deco (`www/img/arcada.svg`). Aceasta poate fi înlocuită cu o fotografie proprie, `www/img/start.jpg`.
- Antet compact, aceleași controale și aceeași structură a întrebărilor, cu tipografia nouă.

### Corecturi găsite la audit

- Pagina finală se oprea cu eroare dacă răspunsul conținea un cod care nu mai există în lista de opțiuni (de exemplu, o zonă din lista de exemplu din v1). Acum codul este afișat ca atare.
- Exportul cu etichete transforma codurile necunoscute în celule goale. Acum le păstrează.
- Graficul pentru Q1 din zona de administrare are înălțimea adaptată la 42 de cartiere și numără separat codurile din versiunile anterioare ale listei.
- Spațiul dinaintea punctului de după legături a fost eliminat.
- În textul de informare a apărut secțiunea „După trimitere” (comparația agregată, fundalul hărții).

### Teste

- **R:** 321 de verificări (în v1: 140), inclusiv tabelul cartierelor, datele hărții, recomandările, pragul comparației, fișierul vectorial opțional și codurile vechi.
- **Browser:** 192 de verificări (în v1: 92), în 3 parcursuri complete (telefon, desktop, desktop cu comparație), plus zona de administrare. Detalii în `docs/TESTARE.md`.

## 1.0.0 (23.10.2026)

Prima versiune: cele 25 de întrebări, validare, salvare SQLite, zonă de administrare, export, pagina finală, dicționar de date și teste.
