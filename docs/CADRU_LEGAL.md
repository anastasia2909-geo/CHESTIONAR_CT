# Cadrul legal al chestionarului

Documentul enumeră actele normative și licențele care privesc site-ul, ce cer ele și cum le respectă aplicația. Textele au fost citite la 01.11.2026, pe copiile indicate; legislatie.just.ro și EUR-Lex nu au putut fi deschise din mediul de lucru (blocate pentru instrumentele automate). Documentul descrie situația aplicației, nu este o consultație juridică.

## 1. Protecția datelor: Regulamentul (UE) 2016/679 (GDPR)

**Ce spune.** Considerentul 26: „Principiile protecției datelor ar trebui, prin urmare, să nu se aplice informațiilor anonime, adică informațiilor care nu sunt legate de o persoană fizică identificată sau identificabilă”, iar regulamentul „nu se aplică prelucrării unor astfel de informații anonime”, inclusiv în scopuri statistice sau de cercetare. Pentru a stabili dacă o persoană este identificabilă se iau în considerare mijloacele care pot fi folosite „în mod rezonabil”, ținând seama de costuri, timp și tehnologie. (Text citit pe gdpr-text.com, versiunea în limba română a regulamentului.)

**Decizia autoarei.** Chestionarul este anonim.

**Cum este susținută tehnic** (detalii în `docs/AUDIT_ANONIMAT.md`):

- nu se cer nume, e-mail, telefon sau adresă; nu există cont;
- nu se salvează adresa IP, browserul sau alte date tehnice;
- data trimiterii se salvează fără oră (`PRECIZIE_DATA_TRIMITERII <- "zi"`), ca un răspuns să nu poată fi legat după oră de jurnalele serverului;
- codul răspunsului este aleatoriu și nu este arătat respondentului;
- la răspunsul liber (Q25) respondentul este rugat să nu scrie date de identificare;
- rezultatele se publică doar agregat, iar valorile pe cartiere apar numai peste praguri minime;
- la răspunsurile individuale are acces numai autoarea.

**Ce rămâne în grija autoarei.** Textele de la Q25 se citesc înainte de citare, iar ce ar putea identifica pe cineva se scoate. Exporturile brute nu se distribuie. La găzduire, jurnalele serverului se păstrează cât mai scurt (`docs/GAZDUIRE.md`).

## 2. Cookie-uri și stocarea pe dispozitiv: Legea nr. 506/2004, art. 4 alin. (5)

**Ce spune.** „Stocarea de informații sau obținerea accesului la informația stocată în echipamentul terminal al unui abonat ori utilizator este permisă numai cu îndeplinirea în mod cumulativ” a două condiții: acordul utilizatorului și informarea lui prealabilă. Alin. (6) exceptează operațiunile strict necesare transmisiei sau serviciului cerut expres. (Copie ANCOM a legii.) La 28.10.2026, Parlamentul avea pe ordinea de zi o modificare a acestui articol privind bannerele de consimțământ (Cotidianul, 28.10.2026); rezultatul votului nu a fost verificat.

**Cum se aplică.** Aplicația nu setează cookie-uri și nu scrie nimic în `localStorage` sau `sessionStorage` (verificat în testul în browser, pe parcursuri complete). Condițiile din alin. (5) nu sunt declanșate, deci nu este nevoie de un banner de cookie-uri. Dacă o versiune viitoare sau serverul de găzduire ar seta cookie-uri, trebuie reverificat.

## 3. Drept de autor: Legea nr. 8/1996, art. 9 lit. b)

**Ce spune.** „Nu pot beneficia de protecția legală a dreptului de autor următoarele: […] b) textele oficiale de natură politică, legislativă, administrativă, judiciară și traducerile oficiale ale acestora”. (Copie consolidată publicată de Primăria Arad, în vigoare de la 25.11.2010.)

**Cum se aplică.** HCL nr. 79/2023 și anexele ei sunt texte oficiale administrative. Autoarea a decis afișarea publică a planurilor scanate. Planurile au tipărit fundalul cartografic Esri, a cărui atribuire apare pe fiecare plan și rămâne vizibilă; sursa (HCL nr. 79/2023) este menționată sub fiecare plan și în subsolul site-ului.

## 4. Licențele datelor geografice

| Date | Licență | Ce cere | Cum se respectă |
|---|---|---|---|
| Limitele UAT (ANCPI, prin geoBoundaries) | CC BY 4.0 | Atribuire | Atribuirea apare pe hartă și în subsol |
| Fundalul OpenStreetMap (la cerere) | ODbL | Atribuirea „OpenStreetMap”, cu legătură la openstreetmap.org/copyright (OpenStreetMap Foundation, pagina „Attribution”, editată la 10.09.2026) | „© contribuitorii OpenStreetMap” pe hartă și în subsol, cu legătura |
| Limitele celor 42 de cartiere (`www/harta/cartiere.geojson`, derivate din OpenStreetMap prin pachetul @nspot/geo-pack-romania-neighbourhoods) | ODbL 1.0 (bază de date derivată) | Atribuire și licența ODbL incluse în date sau într-un fișier însoțitor; baza derivată, folosită public, se oferă tot sub ODbL | Fișierul GeoJSON conține câmpurile `sursa` și `licenta`; alături este `cartiere_LICENTA.txt`; fișierul este public (în `www/`), deci disponibil în aceleași condiții; atribuirea apare pe hartă, sub hartă și în subsol |

## 5. Accesibilitate

Obligațiile legale de accesibilitate pentru site-uri (OUG nr. 112/2018, care transpune Directiva (UE) 2016/2102) privesc organismele din sectorul public. Site-ul nu este publicat de universitate, deci nu intră sub incidența lor; aplicația respectă totuși criteriile WCAG 2.1 nivel AA verificate automat (axe-core, 0 încălcări).

## 6. Conținutul recomandărilor

Recomandările se sprijină pe actele normative și pe articolele din `docs/REGISTRU_SURSE.md`:

| Recomandare | Prevederea |
|---|---|
| „Ce prevede legea” | Legea nr. 241/2006, republicată, art. 5 alin. (3): apele uzate evacuate în canalizare nu trebuie să conducă la „degradarea construcțiilor și instalațiilor”, la „diminuarea capacității de transport a rețelelor”, la „perturbarea funcționării normale a stației de epurare”. NTPA-002 (anexa 2 la HG nr. 188/2002), art. 5 pct. 1 lit. b), c), e): substanțele care se pot solidifica, corpurile solide care nu trec prin grătarul cu spațiu liber de 20 mm, uleiul și grăsimile care formează depuneri |
| Uleiul folosit | NTPA-002, art. 5 pct. 1 lit. e) |
| Medicamentele | Ordinul MS nr. 119/2014, art. 38 lit. c): medicamentele expirate de la populație se depun la farmacii, care afișează anunțul privind colectarea gratuită |
| Micropoluanții | Directiva (UE) 2024/3019, art. 8 alin. (1) și considerentul 20; în vigoare din 01.01.2025, termenul de transpunere în România este 31.07.2027 |

Textele legislative au fost citite pe copii publicate de autorități (ANPC, ANCOM) sau de FAO. Recomandarea rămâne ca, înainte de lansare, cele patru acte să fie deschise o dată în browser, pe legislatie.just.ro și EUR-Lex, pentru o ultimă confruntare.

## 7. Ce nu se aplică

- **Avize de etică și procedura pentru minori:** decizia autoarei este că nu sunt necesare (date anonime).
- **Legea nr. 365/2002 (comerț electronic):** privește serviciile furnizate, de regulă, contra cost; site-ul nu este un serviciu comercial.
