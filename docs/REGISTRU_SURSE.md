# Registrul surselor

Registrul acoperă fiecare afirmație din profilul de după trimitere care se sprijină pe o sursă externă. Fiecare sursă din aplicație (lista SURSE_PROFIL din R/13_recomandari.R) are aici o intrare cu același identificator, în câmpul „registru”. Data verificării este 2026-10-29 pentru toate intrările. Verificarea a fost făcută prin deschiderea paginii sau a documentului, nu din fragmente de căutare.

## Afirmațiile din aplicație și sursele lor

| Afirmația din aplicație (R/13_recomandari.R) | Sursa (identificator) | Tip | Stare |
|---|---|---|---|
| Rețelele de canalizare sunt proiectate pentru urină, fecale, apă uzată și hârtie igienică | INST-WATERUK-FACT | instituție (Regatul Unit) | VERIFICAT |
| Șervețelele umede, tampoanele, bețișoarele, discurile demachiante, scutecele și părul nu se aruncă în toaletă; mâncarea nu se aruncă în toaletă sau chiuvetă; uleiul nu se toarnă în chiuvetă | OP-VITAL-FAQ | ghid operator (Baia Mare) | VERIFICAT |
| Șervețelele umede, scutecele și articolele de igienă personală nu se aruncă în canalizare | OP-VITAL-CP2026 | ghid operator | VERIFICAT |
| Doar o parte dintre șervețelele „flushable” se dezintegrează în canalizare | PR-HADLEY2023 | articol peer-reviewed | VERIFICAT |
| În Regatul Unit, doar produsele cu marcajul „Fine to Flush” pot fi aruncate în siguranță în toaletă | INST-WATERUK-FACT | instituție | VERIFICAT |
| Uleiul și grăsimile formează depuneri care blochează canalizarea; locuințele sunt printre surse | PR-HUSAIN2014 | articol peer-reviewed | VERIFICAT |
| Depunerile de grăsimi duc la revărsări de ape uzate | PR-WALLACE2017 | articol peer-reviewed | VERIFICAT |
| NTPA-002 nu permite evacuarea în canalizare a uleiului și grăsimilor care pot forma depuneri (art. 5 pct. 1 lit. e) | RO-NTPA002 | act normativ RO (copie FAOLEX) | VERIFICAT pe copie; de reconfirmat pe legislatie.just.ro |
| Legea cere ca apele uzate evacuate în canalizare să nu degradeze rețeaua, să nu scadă capacitatea de transport și să nu perturbe stația de epurare | RO-L241 | act normativ RO (copie ANPC) | VERIFICAT pe copie |
| Medicamentele expirate se predau la farmacie, care le colectează gratuit și afișează un anunț | RO-OMS119 | act normativ RO (copie ANPC) | VERIFICAT pe copie; de reconfirmat pe legislatie.just.ro |
| Medicamentele aruncate în toaletă sau chiuvetă ajung în mediu | PR-ROGOWSKA2022 | articol peer-reviewed | VERIFICAT |
| Reziduurile de medicamente și cosmetice sunt principalele surse de micropoluanți; tratarea cuaternară pentru stațiile ≥ 150 000 l.e.: 20% până la 31.12.2033, 60% până la 31.12.2039, toate până la 31.12.2045 | UE-UWWTD (considerentul 20, art. 8 alin. 1) | act normativ UE | PARȚIAL: citit pe o reproducere a textului EUR-Lex; de reconfirmat pe EUR-Lex |
| Proporția de micropoluanți îndepărtată variază între 12,5% și 100%, în funcție de substanță | PR-LUO2014 | articol peer-reviewed | VERIFICAT pe rezumat |
| Blocarea colectorului din Năvodari, 2 august 2026; declarațiile RAJA | RO-RAJA | presă care citează RAJA S.A. | PARȚIAL: comunicatul original RAJA nu a fost găsit |
| Delimitarea și planurile celor 42 de cartiere | HCL79 | act local | VERIFICAT (PDF primit de la autoare) |
| Limitele administrative ale UAT-urilor de pe hartă | GEOB | date geografice | VERIFICAT |
| Limitele orientative ale celor 42 de cartiere | GEO-NSPOT | date geografice derivate din OpenStreetMap (ODbL) | VERIFICAT (delimitări identice cu anexa 1; comparație cu planurile) |

Sursa „Vital, Obiceiuri nesănătoase” folosită în versiunea 2 nu a putut fi deschisă la verificare și a fost înlocuită cu OP-VITAL-CP2026. Afirmația din versiunea 2 că 93% din materialul din blocaje este format din șervețele nu mai apare în aplicație: cifra provine dintr-un studiu britanic pe 54 de probe, în care șervețelele nu erau cele etichetate „flushable”.

Înainte de lansare, autoarea trebuie să reconfirme într-un browser textele de pe legislatie.just.ro (NTPA-002, Ordinul MS 119/2014) și de pe EUR-Lex (Directiva 2024/3019), pe care instrumentele de verificare nu le-au putut deschide.

## HCL79: HCL nr. 79/28.02.2023 a Consiliului Local al municipiului Constanța
- **Folosit pentru:** lista celor 42 de cartiere (Q1), delimitările (anexa 1) și planurile scanate (anexa 2).
- **Sursa:** PDF-ul primit de la autoare (fisier_1.pdf), 45 de pagini. Transcrierea este în docs/CARTIERE_HCL79_2023.md.
- **Stare:** VERIFICAT (fiecare rând confruntat cu pagina scanată).
- **Notă:** planurile nu au coordonate, deci nu sunt folosite ca limite pe hartă.

## GEOB: geoBoundaries, Romania ADM2
- **Folosit pentru:** limita municipiului Constanța și a celor 19 UAT-uri vecine (www/harta/uat.geojson).
- **Sursa:** geoBoundaries (https://www.geoboundaries.org), setul ROU ADM2, provenit de la ANCPI prin data.gov.ro, licență CC BY 4.0.
- **Stare:** VERIFICAT.

## Surse pentru cadrul legal al site-ului (verificate la 01.11.2026)

Folosite în `docs/CADRU_LEGAL.md` și în textul de informare.

#### LEG-GDPR-C26: Regulamentul (UE) 2016/679, considerentul 26
- **URL citit:** https://gdpr-text.com/ro/read/recital-26 (reproducerea textului în limba română)
- **Ce spune:** „Principiile protecției datelor ar trebui, prin urmare, să nu se aplice informațiilor anonime, adică informațiilor care nu sunt legate de o persoană fizică identificată sau identificabilă”; regulamentul „nu se aplică prelucrării unor astfel de informații anonime”; identificabilitatea se judecă după mijloacele care pot fi folosite „în mod rezonabil”.
- **Stare:** VERIFICAT pe reproducere; textul oficial este pe EUR-Lex (CELEX 32016R0679).

#### LEG-L506: Legea nr. 506/2004, art. 4 alin. (5) și (6)
- **URL citit:** https://sitevechi.ancom.ro/uploads/links_files/LEGE_nr_506_2004.pdf (copie ANCOM, formă cu modificări ulterioare, nedatată)
- **Ce spune:** stocarea de informații în echipamentul terminal sau accesul la ele „este permisă numai cu îndeplinirea în mod cumulativ” a acordului și a informării prealabile; excepții pentru operațiunile strict necesare transmisiei sau serviciului cerut expres.
- **Stare:** VERIFICAT pe copie. O modificare a art. 4 alin. (5) era pe ordinea de zi a Parlamentului la 28.10.2026 (https://www.cotidianul.ro/?p=1029038); rezultatul nu a fost verificat. Nu schimbă situația site-ului, care nu stochează nimic pe dispozitiv.

#### LEG-L8: Legea nr. 8/1996, art. 9 lit. b)
- **URL citit:** https://portal1.primariaarad.ro/download/Legea_8_1996.pdf (formă consolidată, în vigoare de la 25.11.2010)
- **Ce spune:** „Nu pot beneficia de protecția legală a dreptului de autor următoarele: […] b) textele oficiale de natură politică, legislativă, administrativă, judiciară și traducerile oficiale ale acestora”.
- **Stare:** VERIFICAT pe copie; legea a fost republicată ulterior (legislatie.just.ro, documentul 221527, neaccesibil din mediul de lucru).

#### LIC-OSM: OpenStreetMap Foundation, „Attribution”
- **URL citit:** https://osmfoundation.org/wiki/Attribution (editată la 10.09.2026)
- **Ce spune:** atribuirea se face către „OpenStreetMap”, cu legătură la openstreetmap.org/copyright; o bază de date derivată include atribuirea și textul sau legătura către ODbL.
- **Stare:** VERIFICAT.

#### GEO-NSPOT: @nspot/geo-pack-romania-neighbourhoods 1.6.0
- **Ce este:** pachet npm publicat la 19.10.2026 (https://www.npmjs.com/package/@nspot/geo-pack-romania-neighbourhoods; cod: https://github.com/NSpot-Games/geo-engine), cu cartierele unor orașe din România. Pentru Constanța: cele 42 de cartiere din HCL nr. 79/2023, desenate pe linii OpenStreetMap (extrasul Geofabrik din 08.10.2026) după perimetrele din anexa 1, verificate cu planurile din anexa 2.
- **Licență:** ODbL 1.0 pentru date (`LICENSE-DATA` din pachet), MIT pentru text.
- **Verificare:** delimitările din pachet sunt identice cu transcrierea proiectului pentru toate cele 42 de cartiere; geometriile sunt valide, fără suprapuneri; comparație vizuală cu planurile pentru Tomis Nord, Baba Novac și Tomis Plus (`docs/HARTA_DATE_SI_LIMITARI.md`).
- **Stare:** VERIFICAT; limite orientative, nu cadastrale.

## Intrările complete

Data verificării pentru toate intrările: **2026-10-29**

Statusuri:
- **VERIFICAT**: sursa a fost deschisă, iar textul susține afirmația.
- **PARȚIAL**: sursa a fost deschisă, dar susține doar o parte din afirmație, sau a fost citită doar dintr-o copie neoficială sau secundară.
- **NEVERIFICAT**: sursa nu a putut fi deschisă.

Limitări tehnice ale acestei sesiuni:
- **eur-lex.europa.eu**: textul integral nu a putut fi citit. Paginile ELI au întors doar metadate, iar HTML/PDF au fost blocate de lista de domenii permise.
- **legislatie.just.ro**: blocat prin robots.txt.
- **raja.ro**: blocat (domeniu nepermis).
- **doi.org**: blocat.

Pentru aceste texte am folosit copii publicate de autorități (ANPC, FAO-FAOLEX) sau reproduceri ale textului EUR-Lex (lexaris.de). **Înainte de publicare, verificați manual dispozițiile pe legislatie.just.ro și pe EUR-Lex.**

Citatele sunt redate exact, în limba originală. Unele sunt fragmentate, din cauza instrumentului de extragere a textului.

---

### A. Legislație România

#### RO-NTPA002: HG nr. 188/2002, Anexa 2 (NTPA-002)
- **Afirmații susținute:** C7 (și indirect C3, C1)
- **Act:** Hotărârea Guvernului nr. 188 din 28 februarie 2002 pentru aprobarea unor norme privind condițiile de descărcare în mediul acvatic a apelor uzate. Anexa nr. 2 este NTPA-002, „Normativ privind condițiile de evacuare a apelor uzate în rețelele de canalizare ale localităților și direct în stațiile de epurare”.
- **Publicare:** Monitorul Oficial nr. 187 din 20.03.2002. A fost modificată de HG nr. 352/2005 și HG nr. 210/2007.
- **Tip:** lege RO
- **URL citit:** https://faolex.fao.org/docs/pdf/rom216719.pdf (copie FAOLEX a formei actualizate la 19.03.2007)
- **URL oficial de citat:** legislatie.just.ro. Rezultatul de căutare indică https://legislatie.just.ro/Public/DetaliiDocumentAfis/98309, dar pagina nu a putut fi deschisă, deci corespondența nu este confirmată.
- **Ce spune:**
  - **Art. 4:** „Evacuarea apelor uzate în reţelele de canalizare ale localităţilor este permisă numai dacă prin aceasta:”
    - a) „nu se aduc prejudicii igienei şi sănătăţii publice sau personalului de exploatare;”
    - b) „nu se diminuează prin depuneri capacitatea de transport a canalelor colectoare;”
    - c) „nu se degradeaza construcţiile şi instalaţiile reţelelor de canalizare, ale statiilor de epurare şi ale echipamentelor asociate;”
    - d) „nu sunt perturbate procesele de epurare din staţiile de epurare sau nu se diminuează capacitatea de preluare a acestora;”
    - e) „nu se creează pericol de explozie.”
  - **Art. 5:** „Apele uzate care se evacueaza în reţelele de canalizare ale localităţilor şi direct în staţiile de epurare nu trebuie să conţină:”
    - **pct. 1:** „materii în suspensie, în cantităţi şi dimensiuni care pot constitui un factor activ de erodare a canalelor, care pot provoca depuneri sau care pot stanjeni curgerea normală, cum sunt:”
      - lit. b) „diferitele substanţe care se pot solidifică şi astfel pot obtura secţiunea canalelor;”
      - lit. c) „corpurile solide, plutitoare sau antrenate, care nu trec prin gratarul cu spaţiu liber de 20 mm între bare […]”
      - lit. e) „pacura, uleiul, grasimile sau alte materiale care prin forma, cantitate sau aderenta pot conduce la crearea de zone de acumulari de depuneri pe pereţii canalului colector;”
    - **pct. 8:** „substanţe inhibitoare ale procesului biologic de epurare a apelor uzate sau de tratare a namolului;”
- **Status:** **VERIFICAT** pe o copie FAOLEX. Forma oficială trebuie reconfirmată pe legislatie.just.ro.
- **Note:**
  - În copia citită, art. 4 și art. 5 nu poartă note de modificare prin HG 352/2005. Modificările din 2005 privesc alte articole (art. 1, 2, 3, 7, 8, 10, 13, 14 și Tabelul 1).
  - Numerotarea corectă este „NTPA-002, art. 5 pct. 1 lit. e)”, nu „HG 188/2002 art. 5”.
  - Normativul se adresează tuturor utilizatorilor racordați. Nu conține o listă explicită de obiecte casnice (șervețele etc.); acestea intră sub incidența art. 5 pct. 1 lit. b), c) și e).

#### RO-L241: Legea nr. 241/2006 a serviciului de alimentare cu apă și de canalizare, republicată
- **Afirmații susținute:** C7
- **Act:** Legea nr. 241/2006, republicată în Monitorul Oficial, Partea I, nr. 679 din 07.09.2015.
- **Versiune citită:** formă consolidată la 22.05.2025. Ultimele modificări listate: L 215/2018, OUG 114/2018, OUG 172/2020, OUG 144/2021, L 420/2023, OUG 23/2025 (ultima modificare la 10.04.2025).
- **Tip:** lege RO
- **URL citit:** https://anpc.ro/download/338/servicii-de-alimentare-cu-apa-si-canalizare/60434/legea-serviciului-de-alimentare-cu-apa-si-de-canalizare-nr-241-2006.pdf (copie ANPC)
- **Ce spune:**
  - **Art. 5 alin. (3):** „Apele uzate evacuate în sistemele de canalizare trebuie să respecte condiţiile precizate prin acordul de preluare în canalizarea publică, respectiv prin contractul de prestare a serviciului, precum şi pe cele impuse prin reglementările tehnice în vigoare, astfel încât prin natura, cantitatea ori calitatea lor să nu conducă la:”
    - a) „degradarea construcţiilor şi instalaţiilor componente ale sistemelor de canalizare;”
    - b) „diminuarea capacităţii de transport a reţelelor şi a canalelor colectoare;”
    - c) „perturbarea funcţionării normale a staţiei de epurare, prin depăşirea debitului şi a încărcării sau prin inhibarea proceselor de epurare;”
    - d) „apariţia unor pericole pentru igiena şi sănătatea populaţiei sau a personalului de exploatare a sistemului;”
    - e) „apariţia pericolelor de explozie.”
  - **Art. 31 alin. (13):** „Utilizatorii au obligaţia de a respecta clauzele contractului de furnizare/prestare a serviciului […]”
- **Status:** **VERIFICAT** pentru art. 5 alin. (3) și art. 31 alin. (13), pe copia ANPC.
- **Note:**
  - Copia ANPC se termină la art. 31 alin. (15). Articolele despre contravenții (după art. 31) **nu au fost verificate**.
  - Legea nu conține o listă de obiecte interzise. Lista concretă o dau NTPA-002 și regulamentul serviciului.
  - Verificați forma în vigoare pe legislatie.just.ro.

#### RO-ANRSC88: Ordinul ANRSC nr. 88/2007 (Regulamentul-cadru al serviciului de alimentare cu apă și de canalizare)
- **Afirmații susținute:** C7 (parțial)
- **Act:** Ordinul ANRSC nr. 88 din 20.03.2007, publicat în Monitorul Oficial nr. 324 din 15.05.2007. Anexa (regulamentul) a fost publicată în M.Of. nr. 324 bis.
- **Tip:** lege RO (act normativ secundar)
- **URL-uri citite:**
  - https://faolex.fao.org/docs/pdf/rom213195.pdf
  - https://acilfov.ro/wp-content/uploads/2019/05/regulamentul-cadru-al-serviciului-de-alimentare-cu-apa-si-de-canalizare-din-20032007.pdf
- **Ce spune:**
  - **Art. 6 alin. (3)** reia condițiile din Legea 241/2006 art. 5 alin. (3): „Apele uzate evacuate în sistemele de canalizare trebuie să respecte condițiile precizate prin acordul de preluare în canalizare […]”, astfel încât să nu ducă la a) „degradarea construcțiilor și instalațiilor componente ale sistemelor de canalizare” și b) „diminuarea capacității de transport a rețelelor și a canalelor colectoare” etc.
  - **Art. 8 alin. (7)** privește „obturări ale canalizării din vina dovedită a utilizatorului”, caz în care „cheltuielile vor fi suportate de către acesta”.
- **Status:** **PARȚIAL**. Ambele copii sunt trunchiate (se opresc la art. 82, respectiv art. 88). Articolul cu „obligațiile utilizatorilor” **nu a fost găsit și nu a fost verificat**. Nu citați o literă anume din acel articol fără verificare pe legislatie.just.ro.
- **Note:** Ordinul este încă invocat ca bază în referatele locale din 2025 (de exemplu Primăria Secuieni, referat din 11.11.2025). Nu am găsit un regulament-cadru mai nou.

#### RO-OMS119: Ordinul ministrului sănătății nr. 119/2014 (Norme de igienă și sănătate publică privind mediul de viață al populației)
- **Afirmații susținute:** C4(b)
- **Act:** Ordinul MS nr. 119 din 04.02.2014, publicat în Monitorul Oficial, Partea I, nr. 127 din 21.02.2014.
- **Versiune citită:** formă consolidată la 26.05.2025. Modificări listate: HG 741/2016, OMS 994/2018, 1378/2018, 562/2023, 1257/2023, 78/2025; Sentința civilă 138/2020.
- **Tip:** lege RO (act normativ secundar)
- **URL citit:** https://anpc.ro/download/334/stranduri-bazine-piscine/60407/ordinul-nr-119-2014-pentru-aprobarea-normelor-de-igiena-si-sanatate-publica-privind-mediul-de-viata-al-populatiei.pdf (copie ANPC)
- **Ce spune (Art. 38 lit. c):**
  - „Medicamentele expirate provenite de la populaţie vor fi depuse la farmacii, oficine locale de distribuţie sau drogherii […] în vederea eliminării finale, prin incinerare.”
  - „Unităţile farmaceutice vor afişa la loc vizibil anunţul privind colectarea gratuită a medicamentelor expirate.”
- **Status:** **VERIFICAT** pe copia ANPC. Reconfirmați pe legislatie.just.ro, unde pagina actului ar fi https://legislatie.just.ro/Public/DetaliiDocument/293318 (nu a putut fi deschisă, robots).
- **Note:**
  - Textul vorbește despre medicamente **expirate**, nu explicit despre cele „neutilizate”.
  - Implementarea este considerată deficitară: vezi PR-ROGOWSKA2022 (date despre România) și avizul Consiliului Legislativ nr. 610/26.07.2021 privind propunerea legislativă B279/2021 (https://senat.ro/Legis/PDF%5C2021%5C21L353LG.pdf), care citează același art. 38 lit. c). Nu am verificat dacă propunerea a devenit lege.

#### RO-RAJA: RAJA S.A. Constanța (operator regional)
- **Afirmații susținute:** C8, C1, C3 (context local)
- **Ce am încercat:** raja.ro nu a putut fi deschis (domeniu blocat în această sesiune). Căutările nu au găsit pe raja.ro o pagină de ghidare pentru consumatori și nici regulamentul serviciului.
- **Ce am găsit:** sursă secundară care reproduce poziția RAJA.
  - **Titlu:** Cristi Hagi, „RAJA, intervenție complexă pentru deblocarea colectorului principal de canalizare din orașul Năvodari”, *Constanța Financiară*, 03.08.2026.
  - **URL:** https://constantafinanciara.ro/raja-interventie-complexa-pentru-deblocarea-colectorului-principal-de-canalizare-din-orasul-navodari/
  - Același eveniment este relatat de Radio România Constanța, 03.08.2026: https://www.radioconstanta.ro/2026/08/03/navodari-echipele-raja-au-intervenit-pentru-deblocarea-colectorului-principal-de-canalizare/
- **Tip:** presă (citează Biroul de Comunicare RAJA S.A.)
- **Ce spune:**
  - „Deversarea în canalizare a deșeurilor solide, materialelor textile, șervețelelor umede, produselor de igienă, uleiurilor și grăsimilor alimentare, resturilor provenite din lucrări de construcții, materialelor plastice, anvelopelor sau a altor obiecte voluminoase reprezintă una dintre principalele cauze ale colmatării conductelor și ale blocării stațiilor de pompare.”
  - Despre șervețelele din fibre sintetice: „nu se degradează în apă, reduc capacitatea de transport a conductelor”.
  - „Facem apel către toți utilizatorii să utilizeze în mod responsabil sistemul public de canalizare și să respecte regulile de exploatare a acestuia.”
  - Au fost extrase „sute de kilograme de deșeuri”, predominant materiale textile, în special șervețele din fibre sintetice. Blocajul a avut loc pe 2 august 2026.
- **Status:** **PARȚIAL**. Pagina de presă a fost deschisă și conținutul confirmat. Comunicatul original RAJA și regulamentul RAJA **nu au fost găsite sau accesibile**.
- **Note:** Este singura dovadă locală (județul Constanța). Poate fi citată ca exemplu local, cu mențiunea „conform RAJA, citat de presă”.

---

### B. Legislație UE

#### UE-UWWTD: Directiva (UE) 2024/3019 privind tratarea apelor urbane uzate (reformare)
- **Afirmații susținute:** C6
- **Act:** Directive (EU) 2024/3019 of the European Parliament and of the Council of 27 November 2024 concerning urban wastewater treatment (recast) (Text with EEA relevance).
- **Date:**
  - Adoptare: 27.11.2024 (confirmat din titlu și metadatele EUR-Lex `date_document 2024-11-27`).
  - Jurnalul Oficial: OJ L, 2024/3019, **12.12.2024**. Data apare în antetul reproducerii lexaris; EUR-Lex nu a putut fi citit integral.
  - Intrare în vigoare: 01.01.2025.
  - Termen de transpunere: 31.07.2027. Ambele date provin din fișa oficială a Parlamentului European (OEIL).
- **Tip:** lege UE
- **URL oficial (de citat):** https://eur-lex.europa.eu/eli/dir/2024/3019/oj. A fost deschis, dar a întors doar metadatele. Textul integral a fost citit pe https://lexaris.de/book/version/documentflat/head/7088535, o reproducere a CELEX 32024L3019. Fișa OEIL: https://oeil.europarl.europa.eu/oeil/en/document-summary?id=1799240
- **Ce spune:**
  - **Considerentul (18):** „While the primary, secondary and tertiary treatment already remove some micropollutants […] an additional treatment, i.e. quaternary treatment, should be introduced […] in order to ensure that a large spectrum of the remaining micropollutants are removed”.
  - **Considerentul (20):** „Pharmaceuticals and cosmetic residues currently represent the main sources of micropollutants found in urban wastewater requiring quaternary treatment.”
  - **Art. 8 („Quaternary treatment”) alin. (1):** „Member States shall ensure that discharges from urban wastewater treatment plants treating urban wastewater with a load of 150 000 p.e. and above satisfy, before being discharged into receiving waters, the relevant requirements of quaternary treatment set out in Part B and Table 3 of Annex I […] by:”
    - (a) „31 December 2033 for discharges from 20 % of those urban wastewater treatment plants;”
    - (b) „31 December 2039 for discharges from 60 % of those urban wastewater treatment plants;”
    - (c) „31 December 2045 for all discharges from those urban wastewater treatment plants.”
  - **Art. 8 alin. (2):** statele membre întocmesc până la 31.12.2030 lista zonelor în care micropoluanții din stațiile de epurare prezintă un risc. Lista se revizuiește în 2033 și apoi la fiecare 6 ani.
  - **Art. 8 alin. (4):** stațiile care deservesc aglomerări de 10 000 p.e. sau mai mult și care descarcă în zonele de risc trebuie să aplice tratarea cuaternară eșalonat: 10 % până în 2033, 30 % până în 2036, 60 % până în 2039, 100 % până în 2045. Această informație provine din rezumatul instrumentului de extragere, nu dintr-un citat integral.
  - **Art. 9 („Extended producer responsibility”) alin. (1):** „Member States shall take measures to ensure that by 31 December 2028, producers who place any of the products listed in Annex III on the market have extended producer responsibility.” Producătorii acoperă „at least 80 % of the full costs for complying with the requirements set out in Article 8”.
  - **Anexa III**, conținut indicat de surse secundare: medicamente de uz uman și produse cosmetice. Fișa OEIL vorbește de „pharmaceutical and cosmetic products”; McCann FitzGerald (27.05.2026) de „medicines and cosmetics”.
- **Status:** **PARȚIAL**.
  - Art. 8 alin. (1), art. 9 alin. (1), considerentele (18) și (20) au fost verificate pe reproducerea lexaris și pe fișa OEIL.
  - Textul exact al **Anexei III** (inclusiv formularea „medicinal products for human use” / trimiterea la Directiva 2001/83/CE și la Regulamentul (CE) nr. 1223/2009) **nu a fost verificat** din textul primar.
  - Textul EUR-Lex nu a putut fi citit direct.
- **Note de actualitate (importante):**
  - Răspunderea extinsă a producătorilor (EPR) este contestată. Înalta Curte din Irlanda a trimis pe 20.05.2026 o întrebare preliminară la CJUE privind valabilitatea art. 9, art. 10 și a Anexei III (McCann FitzGerald, 27.05.2026: https://www.mccannfitzgerald.com/knowledge/healthcare/is-the-polluter-paying-european-challenges-to-the-revised-urban-waste-water-treatment-directive).
  - Nota Consiliului ST 14204/26 din 08.10.2026, propusă de Polonia și sprijinită de alte 6 state, cere reevaluarea EPR și un posibil „stop-the-clock” (https://data.consilium.europa.eu/doc/document/ST-14204-2026-INIT/en/pdf).
  - La 29.10.2026 directiva este **în vigoare, dar netranspusă** în România (termen: 31.07.2027). Formulați în chestionar „directiva prevede”, nu „se aplică deja”.
  - Nu am verificat dacă aglomerarea Constanța depășește 150 000 p.e. și nici ce stații RAJA ar fi vizate.

#### UE-2001/83-127b: Directiva 2001/83/CE, art. 127b
- **Afirmații susținute:** C4(a)
- **Act:** Directiva 2001/83/CE a Parlamentului European și a Consiliului din 6 noiembrie 2001 de instituire a unui cod comunitar cu privire la medicamentele de uz uman. Art. 127b a fost introdus prin Directiva 2004/27/CE din 31.03.2004.
- **Tip:** lege UE
- **URL citit:** https://www.legislation.gov.uk/eudr/2001/83/article/127b/data.html (reproducere legislation.gov.uk a textului UE; EUR-Lex a fost blocat)
- **Ce spune:** „Member States shall ensure that appropriate collection systems are in place for medicinal products that are unused or have expired.”
- **Status:** **VERIFICAT** pe legislation.gov.uk, copie a textului UE. Pentru citare oficială, folosiți EUR-Lex CELEX 02001L0083 (versiunea consolidată).
- **Note:**
  - Pachetul farmaceutic UE (procedura 2023/0132(COD)) are texte finale aprobate în 2026, care **abrogă și înlocuiesc** Directiva 2001/83/CE. Sursa: GMP-Compliance, 11.03.2026, https://www.gmp-compliance.org/gmp-news/eu-pharma-package-final-texts-officially-published.
  - **Neverificat:** dacă noua directivă a fost publicată în JO, de când se aplică și ce articol preia obligația din art. 127b. Până la aplicarea noului act, art. 127b rămâne baza în vigoare.

---

### C. Articole peer-reviewed

#### PR-ROGOWSKA2022
- **Afirmații susținute:** C4(c) (și context România)
- **Referință:** Rogowska J., Zimmermann A. (2022). Household Pharmaceutical Waste Disposal as a Global Problem—A Review. *International Journal of Environmental Research and Public Health*, 19(23), 15798.
- **Identificatori:** DOI 10.3390/ijerph192315798 (verificat pe PMC); PMID 36497873; PMCID PMC9737308.
- **URL:** https://pmc.ncbi.nlm.nih.gov/articles/PMC9737308
- **Tip:** articol peer-reviewed (review)
- **Ce spune:**
  - Eliminarea incorectă a medicamentelor în toaletă sau chiuvetă este o sursă de produse farmaceutice în mediu.
  - Stațiile de epurare din bazinul Mării Baltice sunt „not designed to remove micro-pollutants”.
  - Sistemele de returnare (take-back) și conștientizarea publicului reduc eliminarea incorectă.
  - **Despre România:** medicamentele expirate de la populație trebuie predate la farmacie, regulă introdusă abia în 2014. Un studiu din județul Bihor (771 clienți, 2014–2015) a găsit că doar 0,7 % returnau medicamentele la farmacie și 95,3 % le aruncau la gunoi.
- **Status:** **VERIFICAT**
- **Note:** Este o sinteză internațională. Datele din România sunt din Bihor, nu din Constanța.

#### PR-TONG2011
- **Afirmații susținute:** C4(c)
- **Referință propusă:** Tong A.Y.C., Peake B.M., Braund R. (2011). Disposal practices for unused medications around the world. *Environment International*.
- **Status:** **NEVERIFICAT**. Nu am putut deschide pagina editorului sau PubMed, iar DOI-ul nu a fost confirmat. Folosiți PR-ROGOWSKA2022 în locul ei.

#### PR-WALLACE2017
- **Afirmații susținute:** C3
- **Referință:** Wallace T., Gibbons D., O'Dwyer M., Curran T.P. (2017). International evolution of fat, oil and grease (FOG) waste management – A review. *Journal of Environmental Management*, 187, 424–435.
- **DOI:** 10.1016/j.jenvman.2016.11.003 (din metadatele depozitului UCD)
- **URL:** https://researchrepository.ucd.ie/handle/10197/8257 (manuscris acceptat, CC BY-NC-ND 3.0 IE)
- **Tip:** articol peer-reviewed (review)
- **Ce spune:**
  - „sewer blockages caused by FOG waste deposits, commonly referred to as 'fatbergs'”
  - „These FOG blockages lead to sanitary sewer overflows, property flooding and contamination of water bodies with sewage.”
  - „The idea of toilets and sinks as disposal units for all types of waste is common”
  - „further development of domestic campaigns is essential to disrupt the discharge of FOG into the sewer network”
- **Status:** **VERIFICAT**
- **Note:** Studiul nu cuantifică contribuția gospodăriilor. Sursele FOG sunt mai ales restaurantele, dar și locuințele (vezi PR-HUSAIN2014).

#### PR-HUSAIN2014
- **Afirmații susținute:** C3
- **Referință:** Husain I.A.F., Alkhatib M.F., Jammi M.S., Mirghani M.E.S., Zainudin Z.B., Hoda A. (2014). Problems, Control, and Treatment of Fat, Oil, and Grease (FOG): A Review. *Journal of Oleo Science*, 63(8), 747–752.
- **DOI:** 10.5650/jos.ess13182
- **URL:** https://www.jstage.jst.go.jp/article/jos/63/8/63_ess13182/_article
- **Tip:** articol peer-reviewed (review)
- **Ce spune:**
  - FOG „enters the sewer system from restaurants, residences, and industrial food facilities”
  - Eliberarea lor „results in a continuous build-up that causes eventual blockage of sewer pipes.”
- **Status:** **VERIFICAT**
- **Note:** Menționează explicit locuințele („residences”) ca sursă.

#### PR-HADLEY2023
- **Afirmații susținute:** C2 (și C1, C3: fatbergs)
- **Referință:** Hadley T., Hickey K., Lix K., Sharma S., Berretta T., Navessin T. (2023). Flushed but not forgotten: The rising costs and opportunities of disposable wet wipes. *BioResources*, 18(1), 2271–2287.
- **DOI:** 10.15376/biores.18.1.Hadley
- **URL:** https://bioresources.cnr.ncsu.edu/wp-content/uploads/2023/01/BioRes_18_1_2271_Hadley_Review_Flushed_Not_Forgotten_Rising_Costs_Disposable_Wipes_18606.pdf
- **Tip:** articol peer-reviewed (marcat „PEER-REVIEWED REVIEW ARTICLE”)
- **Ce spune:**
  - „Only some flushable wipes disintegrate in sewer systems, where insufficient disintegration can lead to clogs.”
  - „fatbergs […] are caused by an accretion of porous nonwoven materials with foreign materials and FOGs (fat, oil, and grease).”
- **Status:** **VERIFICAT**
- **Note:** Context canadian (costuri în Canada). Este cea mai directă sursă peer-reviewed găsită pentru C2.

#### PR-PANTOJA2018
- **Afirmații susținute:** C2 (parțial)
- **Referință:** Pantoja Munoz L., Gonzalez Baez A., McKinney D., Garelick H. (2018). Characterisation of "flushable" and "non-flushable" commercial wet wipes using microRaman, FTIR spectroscopy and fluorescence microscopy: to flush or not to flush. *Environmental Science and Pollution Research*, 25(20), 20268–20279.
- **DOI:** 10.1007/s11356-018-2400-9 (din înregistrarea depozitului Middlesex University)
- **URL:** https://mdx-repository.prod-uk.cayuse.com/item/87qwz (manuscris acceptat)
- **Tip:** articol peer-reviewed
- **Ce spune:** „wet wipes labelled as flushable could also be considered as a possible source of microplastic fibres”. În unele șervețele „flushable” au fost găsite PET, HDPE, PEVA/EVA.
- **Status:** **PARȚIAL**
- **Note:** Studiul analizează **compoziția** (plastic sau microplastic), **nu testează dezintegrarea în canalizare**. Nu îl citați ca dovadă că șervețelele „flushable” nu se dezintegrează. Citați-l pentru „pot conține fibre de plastic”.

#### PR-LUO2014
- **Afirmații susținute:** C6
- **Referință:** Luo Y., Guo W., Ngo H.H., Nghiem L.D., Hai F.I., Zhang J., Liang S., Wang X.C. (2014). A review on the occurrence of micropollutants in the aquatic environment and their fate and removal during wastewater treatment. *Science of the Total Environment*, 473–474, 619–641.
- **DOI:** 10.1016/j.scitotenv.2013.12.065
- **URL:** https://hero.epa.gov/hero/index.cfm/reference/details/reference_id/2219790 (fișa US EPA HERO)
- **Tip:** articol peer-reviewed (review)
- **Ce spune:**
  - Stațiile de epurare au o eficiență de îndepărtare „compound-specific […] ranging from 12.5 to 100%”.
  - Tratarea avansată „can achieve higher and more consistent micropollutant removal”.
- **Status:** **VERIFICAT** (pe baza rezumatului)

---

### D. Operatori și instituții

#### OP-VITAL-FAQ: VITAL S.A. Baia Mare, „Cum protejăm rețelele de canalizare?”
- **Afirmații susținute:** C1, C3, C5, C9
- **Instituție:** S.C. VITAL S.A. Baia Mare (operator regional apă-canal, județul Maramureș)
- **URL:** https://www.vitalmm.ro/ro/intrebari-frecvente/cum-protejam-retelele-de-canalizare
- **Tip:** ghid operator
- **Ce spune:**
  - „nu aruncați servețele umede/ parfumate în toaletă”
  - „nu aruncați obiecte de igienă personală (tampoane, bețișoare pentru urechi, discuri demachiante) în toaletă”
  - „nu aruncați scutecele în toalete sau în gurile de canalizare”
  - „nu aruncați ulei folosit în scurgerea de la chiuvetă sau toaletă”
  - „nu aruncați mâncare în toaletă sau chiuvetă”
  - „nu aruncați păr în gurile de scurgere – obturează și blochează conductele”
  - Scopul este „a preveni înfundarea rețelelor de canalizare” și „a vă feri de pericolul refulării canalizării în beciuri sau chiar în locuințe”.
- **Status:** **VERIFICAT**. Pagina este accesibilă, dar nedatată (subsol „Copyright © 2015”).
- **Note:**
  - Nu spune explicit „doar urină, fecale și hârtie igienică” (pentru asta, vezi INST-WATERUK-FACT).
  - Nu menționează medicamentele și nici absorbantele pe nume (doar „tampoane”).
  - Nu este operatorul din Constanța.
  - **Recomandare:** păstrați-o ca sursă românească de operator. Este cea mai completă listă găsită.

#### OP-VITAL-CP2026: VITAL S.A., comunicat de presă (24.07.2026)
- **Afirmații susținute:** C1, C3, C9
- **Titlu:** „SEMNAL DE ALARMĂ! - Servețelele umede crează cele mai mari probleme la sistemul de canalizare!”, 24.07.2026
- **URL:** https://vitalmm.ro/ro/media/comunicate-de-presa/semnal-de-alarma-servetelele-umede-creaza-cele-mai-mari-probleme-la-sistemul-de-canalizare
- **Tip:** ghid operator
- **Ce spune:**
  - „NU aruncați în canalizare șervețele umede, pamperși, articole de igienă personală, lenjerie intimă, ambalaje din carton sau plastic, uleiuri, grăsimi sau substanțe chimice!”
  - Grăsimile „formează dopuri de grăsime pe conducte sau blochează pompele stațiilor de pompare, provocând avarii.”
- **Status:** **VERIFICAT**
- **Note:** Același text apare în comunicatul VITAL „Atenție la rețeaua de canalizare!” din 25.09.2025: https://www.vitalmm.ro/ro/media/comunicate-de-presa/atentie-la-reteaua-de-canalizare. Ambele sunt alternative mai noi la pagina „obiceiuri-nesanatoase”.

#### OP-VITAL-OBICEIURI: VITAL S.A., „Obiceiuri nesănătoase: ce aruncăm în rețeaua de canalizare”
- **Afirmații susținute:** C9
- **URL:** https://www.vitalmm.ro/ro/media/comunicate-de-presa/obiceiuri-nesanatoase-ce-aruncam-in-reteaua-de-canalizare
- **Status:** **NEVERIFICAT**. URL-ul nu a putut fi deschis (lista de domenii permise a instrumentului), iar căutarea nu l-a găsit.
- **Recomandare:** testați manual în browser. Dacă nu se deschide, înlocuiți-l cu OP-VITAL-CP2026.

#### INST-WATERUK-FACT: Water UK, factsheet „Unflushables”
- **Afirmații susținute:** C1, C2, C3, C9
- **Instituție:** Water UK (asociația companiilor de apă din Regatul Unit)
- **Titlu:** factsheet „Unflushables” (fișier `Factsheet_UnflushablesNEW.pdf`, încărcat în 2023-05, nedatat în text)
- **URL:** https://www.water.org.uk/sites/default/files/2023-05/Factsheet_UnflushablesNEW.pdf
- **Tip:** instituție
- **Ce spune:**
  - Rețelele sunt proiectate pentru „human waste, wastewater and loo roll from toilets”.
  - „93%” cu mențiunea „OF SEWER BLOCKAGE MATERIAL IS MADE UP OF WIPES”. Nota de subsol 3 trimite la „Wipes in Sewers Blockage Study, Water UK, 12 December 2017”.
  - „Other products labelled as 'flushable' do not break down in UK sewer conditions and can contribute to blockages.”
  - „Only products that carry the 'Fine to Flush' logo can be safely flushed.”
  - Blocajele sunt cauzate și de „leftover cooking fats and oils poured down the kitchen sink”.
  - 300 000 de blocaje pe an, cu un cost de £100M.
- **Status:** **VERIFICAT**
- **Recomandare:** păstrați, cu precizarea „date din Regatul Unit”.

#### INST-WATERUK-STUDY: Studiul WRc pentru Water UK (2017)
- **Afirmații susținute:** C9 (sursa cifrei de 93 %)
- **Referință:** Drinkwater A., Moy F. (WRc plc) (2017). *Wipes in Sewer Blockage Study – Final Report*, ref. 21CDP.WS. Water UK, 21st Century Drainage Programme.
- **URL:** https://www.water.org.uk/sites/default/files/wp/2018/11/Wipes-in-sewer-blockage-study.pdf
- **Comunicatul Water UK:** https://www.water.org.uk/news-item/new-proof-that-flushing-wipes-is-a-major-cause-of-sewer-blockages/
- **Tip:** instituție (raport tehnic, nu peer-reviewed)
- **Ce spune:**
  - Au fost analizate 54 de probe: 44 de blocaje, 7 pompe colmatate și 3 probe de la intrarea în stații de epurare.
  - Pe greutate, în probele din blocaje: 45,52 % șervețele neidentificabile și 41,41 % șervețele pentru bebeluși.
  - „The majority of material recovered comprised of wipes that were not designed to be flushed.”
  - Produsele concepute pentru a fi aruncate în toaletă reprezentau aproximativ 0,88 % din greutatea totală.
  - Comunicatul Water UK: „wipes made up around 93% of the material causing the sewer blockages which the study investigated” și „These wipes – which included a high proportion of baby wipes - are not designed to be flushed.”
- **Status:** **VERIFICAT** pentru raport și comunicat.
- **Note:**
  - Instrumentul de extragere nu a găsit cifra „93 %” formulată ca atare în raport; ea provine din comunicatul Water UK. Totalul exact al categoriilor de șervețele din raport nu a fost recalculat.
  - Eșantionul este mic, din Regatul Unit, iar procentul este pe greutate.
  - Wipes-urile găsite **nu erau** cele etichetate „flushable”. Din acest motiv, cifra de 93 % **nu susține** afirmația C2.

---

### E. Găzduire (H1)

#### H1-POSIT: Documentația shinyapps.io, capitolul „Storage”
- **Instituție:** Posit PBC, „shinyapps.io Documentation – Storage”
- **URL:** https://docs.posit.co/shinyapps.io/guide/storage/
- **Tip:** documentație oficială
- **Ce spune:**
  - „Applications can read and write to the local file system, but the storage should be considered ephemeral”
  - „The storage will be persistent while the application is in the Running state.” Totuși, spațiul „is not guaranteed to be available between application restarts, and is never available to other application instances”.
  - „Redeploying your application will reset the storage for your application to only what is included in the upload bundle.”
  - Când aplicația intră în starea de repaus (sleep), „any changes to the file system will be lost.”
  - **Recomandarea Posit:** „you will need to write the data to a persistent data store (e.g., databases, Dropbox, Google Sheets, S3 etc.)”
- **Status:** **VERIFICAT**
- **Note:**
  - Răspunsurile la chestionar **nu trebuie salvate în fișiere locale** pe shinyapps.io. Folosiți o bază de date la distanță sau stocare în cloud.
  - Dacă stocarea este în afara UE (S3 sau Google), aveți în vedere GDPR.
