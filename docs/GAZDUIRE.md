# Găzduirea pas cu pas

Ghidul duce aplicația de pe calculator pe internet, gratuit, cu răspunsurile păstrate în afara serverului aplicației și copiate automat în fiecare noapte. Conturile le creați dumneavoastră; nimic din proiect nu creează conturi și nu se conectează singur la servicii externe. Informațiile despre planurile gratuite au fost verificate la 03.11.2026, în paginile de la sfârșitul documentului; prețurile și limitele se pot schimba, așa că merită o privire înainte de fiecare etapă.

## Cum arată soluția

Patru locuri, fiecare cu un rol:

- **Posit Connect Cloud** (plan gratuit) rulează aplicația. Adresa are forma `https://….share.connect.posit.cloud` și se deschide pe telefon, tabletă sau calculator, în orice browser. Serverele Connect Cloud sunt în AWS us-east-2 (SUA).
- **Neon** (plan gratuit) păstrează răspunsurile, într-o bază PostgreSQL din regiunea AWS Europe (Frankfurt). Aplicația scrie acolo la fiecare trimitere.
- **GitHub** păstrează codul aplicației, într-un depozit public (planul gratuit Connect Cloud publică numai din depozite publice), și copia zilnică a răspunsurilor, într-un al doilea depozit, privat.
- **Calculatorul dumneavoastră** păstrează copiile săptămânale descărcate din zona de administrare.

Un răspuns trimis ajunge din browser la aplicație și de acolo în Neon. Dacă aplicația repornește, se republică sau „adoarme” când nu o folosește nimeni, răspunsurile din Neon nu sunt atinse. În fiecare noapte, GitHub citește tabela și salvează o copie în depozitul privat; istoricul depozitului păstrează toate copiile anterioare.

## Ce oferă planurile gratuite

| Serviciu | Ce contează pentru chestionar |
|---|---|
| Neon Free | 1 GB pe proiect; 100 de ore-CU de calcul pe lună; baza se oprește după 5 minute fără activitate și pornește singură la următoarea conexiune; istoric de refacere de 6 ore și o copie manuală (snapshot). Peste limita de calcul, baza se suspendă până luna următoare; „None of these limits delete your data” (Neon). Nu cere card bancar. |
| Connect Cloud Free | Publicare din depozite GitHub publice, cu fișierul `manifest.json`; variabile secrete criptate; republicare automată la fiecare modificare pe GitHub. |
| GitHub Free | Depozite private și GitHub Actions. Programările automate se dezactivează după 60 de zile fără activitate numai în depozitele publice; copia zilnică stă într-un depozit privat. |

Ca ordin de mărime: un răspuns ocupă aproximativ 0,6 KB (exportul CSV cu 33 de răspunsuri de test are 18,9 KB), deci 1 GB ajunge pentru sute de mii de răspunsuri. Fiecare completare ține baza pornită câteva minute; 100 de ore-CU înseamnă, de exemplu, 400 de ore de funcționare la dimensiunea minimă de 0,25 CU.

Limita de utilizare a aplicației pe planul gratuit Connect Cloud (ore sau credite pe lună) nu s-a putut citi din mediul de lucru: pagina https://connect.posit.cloud/plans se încarcă doar într-un browser. Citiți-o la etapa 5. Dacă limita s-ar atinge, aplicația devine indisponibilă până luna următoare, dar răspunsurile din Neon rămân.

## Etapa 1. Pregătiți proiectul pe calculator

1. Dezarhivați `chestionar_constanta_v3.3.0.zip` într-un folder nou și deschideți `chestionar_constanta.Rproj` în RStudio.
2. Copiați în noul folder fișierul `.Renviron` din versiunea anterioară (sau creați-l din `.Renviron.exemplu`). Lăsați `CHESTIONAR_MOD=test`.
3. În consolă: `source("scripts/instaleaza_pachete.R")`. Se instalează, pe lângă pachetele de până acum, `RPostgres` (legătura cu baza PostgreSQL) și `rsconnect` (fișierul pentru publicare).
4. Porniți aplicația (Run App) și verificați că merge ca înainte.

Verificare: în consolă apare „Baza de date: …raspunsuri_TEST.sqlite”.

## Etapa 2. Creați baza de date în Neon

1. Pe https://neon.com, creați un cont (cu e-mail, Google sau GitHub).
2. Creați un proiect nou. Nume: `chestionar-constanta`. Versiunea Postgres: cea propusă. Furnizor: AWS. Regiunea: **Europe (Frankfurt)**.
3. În pagina proiectului, apăsați **Connect**. Dezactivați „Connection pooling”, afișați parola și copiați adresa care începe cu `postgresql://`. Are forma `postgresql://neondb_owner:PAROLA@ep-….eu-central-1.aws.neon.tech/neondb?sslmode=require`.

Adresa conține parola bazei. Nu o trimiteți nimănui, nu o puneți în cod și nu o scrieți în documente; ea merge doar în `.Renviron`, în Connect Cloud și în GitHub, ca secret.

## Etapa 3. Încercați baza Neon de pe calculator

1. Deschideți `.Renviron` și adăugați un rând cu adresa copiată:
   `CHESTIONAR_DB_URL=postgresql://neondb_owner:PAROLA@ep-….neon.tech/neondb?sslmode=require`
2. În RStudio: Session > Restart R. Porniți aplicația.
3. În consolă trebuie să apară: „Baza de date: PostgreSQL, tabela raspunsuri_test (ep-…, baza neondb) (0 răspunsuri)”.
4. Completați chestionarul o dată. Deschideți zona de administrare (adresa + `?admin`): în fila „Stare”, rândul „Baza de date PostgreSQL poate fi scrisă” este „în regulă”, iar „Găzduirea” este „în regulă”.
5. În Neon, la **Tables**, apare tabela `raspunsuri_test` cu un rând.

Pe calculator, lăsați `CHESTIONAR_MOD=test`. Cu adresa Neon în `.Renviron` și modul `productie`, o completare de probă făcută acasă ar ajunge printre răspunsurile reale. Fără rândul `CHESTIONAR_DB_URL`, aplicația revine la fișierele SQLite din `data/`.

## Etapa 4. Puneți codul pe GitHub

Depozitul este public: oricine poate vedea codul. Datele și parolele nu ajung acolo, pentru că fișierul `.gitignore` exclude `.Renviron`, fișierele `.sqlite`, `copii_siguranta/` și `export/`.

1. Creați un cont pe https://github.com și instalați GitHub Desktop (https://desktop.github.com).
2. În consola RStudio: `source("scripts/pregateste_publicarea.R")`. Scriptul creează `manifest.json` (versiunea de R și pachetele pe care serverul trebuie să le instaleze) și verifică să nu conțină date. La final scrie „manifest.json este gata”.
3. În GitHub Desktop: File > Add Local Repository, alegeți folderul proiectului; la mesajul că nu este încă un depozit, alegeți „create a repository”. Nume: `chestionar-constanta`. Apoi **Publish repository** și debifați „Keep this code private”.
4. Pe github.com, deschideți depozitul și verificați: folderul `data` are doar `CITESTE.txt`; nu există `.Renviron` și niciun fișier `.sqlite`.

De aici înainte, orice modificare în cod se trimite din GitHub Desktop: scrieți o descriere scurtă, **Commit to main**, apoi **Push origin**. După ce instalați sau actualizați pachete, rulați din nou `scripts/pregateste_publicarea.R` înainte de Commit.

## Etapa 5. Publicați aplicația pe Connect Cloud, în modul test

1. Pe https://connect.posit.cloud, creați un cont cu „Sign in with GitHub”. Citiți pagina **Plans** (limitele planului gratuit).
2. Apăsați **Publish**. La prima publicare, Connect Cloud cere instalarea aplicației sale GitHub; permiteți-i accesul la depozitul `chestionar-constanta`.
3. Alegeți **Shiny**, depozitul `chestionar-constanta`, ramura `main` și fișierul principal `app.R`. Lăsați bifat „Automatically publish on push”.
4. La setările avansate, cu **+ Add variable**, adăugați trei variabile:
   - `CHESTIONAR_DB_URL`: adresa Neon de la etapa 2;
   - `CHESTIONAR_ADMIN_PAROLA`: o parolă lungă, nouă, pe care nu o folosiți în altă parte (codul este public, deci adresa zonei de administrare se cunoaște; o protejează parola și blocarea după încercări greșite);
   - `CHESTIONAR_MOD`: `test`.
5. Apăsați **Publish**. Prima publicare durează câteva minute, cât se instalează pachetele.

Verificare: se deschide adresa aplicației, cu banda „MOD TEST”. Deschideți-o și pe telefon. În zona de administrare (adresa + `?admin`), fila „Stare” are „în regulă” la baza PostgreSQL și la găzduire; tabela `raspunsuri_test` are răspunsul de la etapa 3.

## Etapa 6. Pilotul, în modul test

1. Trimiteți adresa la 5–10 persoane, pe telefon și pe calculator. Rugați-le să spună dacă ceva nu a mers.
2. În modul test, pagina finală arată cât a durat completarea. Notați duratele; dacă diferă mult de „10–15 minute”, schimbați `DURATA_ESTIMATA_MINUTE` în `R/00_config.R`, apoi Commit și Push (aplicația se republică singură).
3. Testul de persistență: notați numărul de răspunsuri din administrare, apăsați **Republish** în Connect Cloud, așteptați să repornească și verificați același număr. Verificați din nou a doua zi, după ce aplicația a „dormit”.
4. Deschideți în browser, pe legislatie.just.ro și EUR-Lex, cele patru acte citate în recomandări (`docs/REGISTRU_SURSE.md`).

## Etapa 7. Treceți în producție

1. În Connect Cloud, la aplicație: Edit Settings > **Variables**. Schimbați `CHESTIONAR_MOD` din `test` în `productie` și salvați. Apăsați **Republish**.
2. Verificare: banda „MOD TEST” a dispărut; administrarea arată „modul aplicației: producție” și 0 răspunsuri; fila „Stare” nu are nimic „blochează lansarea”.

La prima pornire în producție, aplicația creează tabela `raspunsuri`, goală. Răspunsurile din pilot rămân în `raspunsuri_test` și nu se amestecă cu cele reale. Nu este nevoie de o completare de probă în producție: mecanismul a fost verificat în modul test, pe aceeași bază.

## Etapa 8. Porniți copia zilnică automată

1. Pe github.com: **New repository**, nume `chestionar-copii`, **Private**, Create repository.
2. În noul depozit: Settings > Secrets and variables > Actions > **New repository secret**. Nume: `CHESTIONAR_DB_URL`; valoare: adresa Neon. Add secret.
3. În depozit: Add file > Create new file. Numele fișierului: `.github/workflows/copie_zilnica.yml`. Conținutul: tot fișierul `docs/copie_automata/copie_zilnica.yml` din proiect. **Commit changes**.
4. Fila **Actions** > „Copie zilnică a răspunsurilor” > **Run workflow**. După un minut sau două, rularea are bifa verde.
5. În fila **Code** a apărut folderul `copii/`, cu `raspunsuri.csv` (se deschide în Excel), `raspunsuri.sql` (copia completă a tabelei, pentru un informatician) și `numar.txt`. Descărcați CSV-ul și deschideți-l, ca verificare.
6. În Settings > Notifications (ale contului), la Actions, verificați că primiți e-mail pentru rulările eșuate.

Rularea citește tabela în fiecare noapte la 02:23 UTC și face un commit numai când s-a schimbat ceva. Nu scrie și nu șterge nimic în Neon. Dacă numărul de răspunsuri scade față de copia precedentă, rularea afișează un avertisment; copiile vechi rămân în istoric (fila **Commits**).

## Etapa 9. Lansarea

1. Distribuiți adresa aplicației. În Connect Cloud, la Edit Settings > URL, puteți alege un nume mai ușor de citit, dacă planul o permite.
2. Pentru afișe sau prezentări, faceți un cod QR din adresă și încercați-l cu telefonul înainte de tipărire.

## Etapa 10. În timpul colectării, o dată pe săptămână

1. În administrare: descărcați „Copie a bazei de date (.sqlite)” și exportul Excel. Păstrați-le în două locuri (calculator și un stick sau un spațiu de stocare personal).
2. Pe GitHub, în `chestionar-copii`: ultima rulare are bifa verde.
3. În Neon, la **Usage** sau **Billing**: spațiul folosit și orele de calcul, față de limitele planului.

## Etapa 11. Închiderea și analiza

1. Când decideți închiderea, faceți o ultimă copie: butonul din administrare și **Run workflow** în `chestionar-copii`.
2. Opriți aplicația din Connect Cloud (sau ștergeți-o din lista de conținut). Răspunsurile rămân în Neon și în copii.
3. Pentru analiză: exportul pentru analiză din administrare (Excel cu variabilele derivate) sau fișierul `.sqlite` deschis în R.
4. Proiectul Neon și depozitul `chestionar-copii` le puteți păstra până după susținere.

## Dacă ceva nu merge

**Aplicația nu pornește pe Connect Cloud.** Deschideți jurnalul (Logs) aplicației. Cauze frecvente: un pachet lipsește din `manifest.json` (rulați `scripts/pregateste_publicarea.R`, apoi Commit și Push), numele unei variabile este scris greșit, adresa Neon este incompletă.

**Un respondent vede un mesaj de eroare la trimitere.** Aplicația nu a putut scrie în Neon. În pagina proiectului Neon verificați dacă baza este suspendată (limita lunară de calcul) sau dacă adresa s-a schimbat (de exemplu, după resetarea parolei: noua adresă trebuie pusă în Connect Cloud și în secretul din `chestionar-copii`). Răspunsurile deja salvate nu sunt afectate.

**Răspunsurile din Neon s-au pierdut sau proiectul a fost șters.** Dacă s-a întâmplat în ultimele 6 ore, Neon poate reface baza din istoric, din consola proiectului. Altfel:

1. Creați un proiect Neon nou și puneți noua adresă în `.Renviron` (cu `CHESTIONAR_MOD=productie` doar pentru acest pas), în Connect Cloud și în secretul din `chestionar-copii`.
2. Descărcați ultima copie (`copii/raspunsuri.csv` din `chestionar-copii` sau fișierul `.sqlite` săptămânal).
3. În RStudio, după Session > Restart R:
   `copia <- "C:/cale/catre/raspunsuri.csv"` și apoi `source("scripts/reface_din_copie.R")`.
   Scriptul adaugă numai răspunsurile care lipsesc (după codul răspunsului), nu șterge și nu modifică nimic și afișează câte a adăugat.
4. Readuceți `CHESTIONAR_MOD=test` în `.Renviron`.

Același script readuce o copie `.sqlite` în baza SQLite locală, dacă `.Renviron` nu are `CHESTIONAR_DB_URL`.

## Ce ajunge la fiecare furnizor

Aplicația salvează doar răspunsurile anonime, cu data trimiterii fără oră (`docs/AUDIT_ANONIMAT.md`). Neon și depozitul privat de copii conțin numai aceste rânduri. Depozitul public conține codul, textele și harta, fără răspunsuri. Connect Cloud primește cererile browserelor și poate păstra jurnale tehnice ale serverului (de exemplu, adresa IP), în afara aplicației; aplicația nu le citește, iar data fără oră împiedică legarea unui răspuns de o intrare din jurnal după oră. Cookie-urile setate de platforma Connect Cloud, dacă există, se verifică în browser după publicare (`docs/CADRU_LEGAL.md`, punctul 2).

## Rularea fără găzduire

Fără `CHESTIONAR_DB_URL`, aplicația folosește fișierele SQLite: `data/raspunsuri.sqlite` (producție) și `data/raspunsuri_TEST.sqlite` (test), sau folderul din `CHESTIONAR_DATA_DIR`. Pe un server cu disc permanent (de exemplu, unul al facultății), varianta aceasta merge fără schimbări; pe Connect Cloud și shinyapps.io, fișierele locale se pierd la repornire sau republicare (documentația shinyapps.io, capitolul „Storage”: „redeploying your application will reset the storage”). Copiile manuale: `scripts/copie_de_siguranta.R` sau butonul din administrare; refacerea: `scripts/reface_din_copie.R`, cu aplicația oprită.

## Surse (citite la 03.11.2026)

- Posit, „From GitHub”: https://docs.posit.co/connect-cloud/user/publish/github.html (depozite publice pe planul gratuit, `manifest.json` sau `renv.lock` pentru R, variabile secrete, republicare la push).
- Posit, „Deploy a Shiny for R app”: https://docs.posit.co/connect-cloud/how-to/r/shiny-r.html (`rsconnect::writeManifest()`, adresa `…share.connect.posit.cloud`).
- Posit, „From content settings page”: https://docs.posit.co/connect-cloud/user/manage/content_settings.html (secțiunile Variables, URL, Compute, Runtime).
- Neon, „Free plan limits and quotas”: https://neon.com/faqs/free-plan-limits-and-quotas (1 GB, 100 ore-CU, oprirea după 5 minute, istoric de 6 ore, „None of these limits delete your data”).
- GitHub Docs, „Disabling and enabling a workflow”: https://docs.github.com/actions/managing-workflow-runs/disabling-and-enabling-a-workflow (dezactivarea după 60 de zile, în depozitele publice).
- Posit, „shinyapps.io – Storage”: https://docs.posit.co/shinyapps.io/guide/storage/ (citit la 29.10.2026).
