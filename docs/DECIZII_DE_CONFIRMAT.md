# Decizii și puncte deschise (versiunea 3.3.0)

Pentru fiecare punct: ce lipsește, ce face acum aplicația și unde se schimbă. Fila „Stare” din zona de administrare arată la zi o parte din aceste verificări.

## Confirmate de autoare

- **Etichetele scalei Q21** („1 = responsabilitate foarte mică”, „5 = responsabilitate foarte mare”) sunt active (3.1).
- **Fără limită de vârstă** (3.1). Q2 are varianta „Sub 18 ani”. Nu se aplică avize de etică sau proceduri pentru minori (3.2).
- **Chestionarul rămâne deschis** fără dată de închidere și fără număr maxim de respondenți; nu există ștergere automată (3.1).
- **Păstrarea pe durată nedeterminată**, acces la răspunsurile individuale numai pentru autoare, rezultate doar agregat (3.1).
- **Chestionar anonim** (3.2). Data trimiterii se salvează fără oră; aplicația nu salvează IP-uri și nu folosește cookie-uri. Pentru date anonime, GDPR nu se aplică (considerentul 26); temeiul și operatorul de date nu mai trebuie menționate. Analiza: `docs/CADRU_LEGAL.md`, `docs/AUDIT_ANONIMAT.md`.
- **Planurile scanate** din anexa 2 la HCL nr. 79/2023 pot fi afișate public (3.2).
- **Durata afișată:** 10–15 minute, estimare din conținut, de validat cu completări reale (`docs/DURATA_ESTIMATA.md`).

## Puncte deschise

### 1. Găzduirea (ultima etapă)

Varianta pregătită în 3.3.0: aplicația pe Posit Connect Cloud (plan gratuit, din depozit GitHub public), răspunsurile în Neon (PostgreSQL, plan gratuit, regiunea Frankfurt), copie zilnică automată într-un depozit GitHub privat, plus copii săptămânale descărcate de autoare. Codul suportă varianta; conturile nu sunt create, iar aplicația nu este publicată. Pașii: `docs/GAZDUIRE.md`. Rămân de verificat de autoare, la crearea conturilor: limita de utilizare a planului gratuit Connect Cloud (pagina Plans) și jurnalele sau cookie-urile platformei.

### 2. Limitele celor 42 de cartiere (rezolvat în 3.2, cu o precizare)

Harta are acum cele 42 de cartiere, desenate pe OpenStreetMap după delimitările din anexa 1 (pachetul @nspot/geo-pack-romania-neighbourhoods 1.6.0, ODbL). Sunt prezentate ca limite orientative. Trei cartiere (Atelierelor, Baba Novac, Tomis Plus) au verificarea cu planul „incertă”; pe site, fișa lor trimite la planul scanat ca referință. Limitele oficiale se pot cere oricând Primăriei (`docs/HARTA_DATE_SI_LIMITARI.md`).

### 3. Ultima confruntare a textelor legislative

NTPA-002, Legea nr. 241/2006, Ordinul MS nr. 119/2014 și Directiva (UE) 2024/3019 au fost citite pe copii publicate de autorități (ANPC, ANCOM) sau de FAO. O deschidere în browser pe legislatie.just.ro și EUR-Lex înainte de lansare este recomandată (`docs/REGISTRU_SURSE.md`).

### 4. Pragul pentru indicatorii pe cartiere

30 de completări valide în total, 10 respondenți pe cartier pentru procente, 5 pentru numărul de respondenți (`HARTA_PRAG_*` în `R/00_config.R`; `docs/INDICATORI_HARTA.md`).

### 5. Comparația și estimarea consumului

Comparația pentru Q13, Q14 și Q24 apare peste 30 de completări (`COMPARATIE_*`). Estimarea „litri pe persoană pe zi” este un calcul din Q5 și Q8, cu explicația lângă cifră.

### 6. Parola de administrare

Proiectul nu conține un `.Renviron`; parola se setează în `CHESTIONAR_ADMIN_PAROLA`, iar la găzduire, ca variabilă de mediu pe server, cu HTTPS.

## C. Decizii din versiunile 1–2, încă valabile

- **Q1:** lista are cele 42 de cartiere din anexa 1 la HCL nr. 79/28.02.2023, în ordine alfabetică, fără „Nu știu” și fără variantă pentru persoanele din afara municipiului. „Cet” este scris ca în tabelul din HCL (pe planul 2.10 apare „CET”).
- **Q4:** „Prefer să nu răspund” apare o dată (în sursă apare de două ori).
- **Q6:** nota trimite la întrebarea 5, iar validarea verifică suma Q6 = Q5. Din versiunea 3, un câmp lăsat gol se socotește 0 și se salvează 0.
- **Q8:** câmpul „Apă caldă” gol înseamnă „inclusă în apa rece”; nu se socotește 0 în baza de date (rămâne gol).
- **Q9:** un câmp gol se socotește 0% și se salvează 0. Totalul trebuie să fie 100 ± 0,01.
- **Q12:** textul cere „Nu am aruncat acest obiect”, coloana se numește „Nu l-am aruncat”; Q12 folosește „tu”. Ambele ca în sursă.
- **Q20:** „Nu se aplică” este păstrată și salvată separat de cazul în care Q20 nu a fost afișată (`q20_afisata = 0`).
- **Opțiunile exclusive** din Q10, Q11, Q16 se dezactivează din lista `EXCLUSIVE`.
- **„Altceva”, „Altele”** nu au câmp de text, ca în sursă.
- **Nota de la Q25** (fără date de identificare) nu este în sursă; poate fi ștearsă din `R/01_intrebari.R`.
- **Metadate salvate:** codul aleatoriu, data trimiterii (din 3.2 fără oră), modul, versiunile și acordul. Confirmarea vârstei s-a salvat doar în versiunea 3.0.

## Modificări față de documentul sursă

| Unde | Sursa | Aplicația |
|---|---|---|
| Q1 | „Listă de selecție cu zonele municipiului Constanța” | cele 42 de cartiere din HCL nr. 79/2023 |
| Q4 | „Prefer să nu răspund” de două ori | o singură dată |
| Q6, nota | „...de la întrebarea 6” | „...de la întrebarea 5” |
| Q2, Q6 | „18–24 ani ,” | „18–24 ani” |
| Q12, coloana 1 | „Era mai rapid/ din obișnuință” | „Era mai rapid/din obișnuință” |
| Q20 | nota „Se afișează doar dacă...” | nu se afișează; regula se aplică automat |
| Q21 | „Toți au responsabilități” în listă | eliminată în versiunea 3 |
| Q25 | — | notă despre datele de identificare |
| Q9, Q21 | „TOTAL: 100%”; „1………….5” | total afișat în timp real; coloanele 1–5 |

Textul întrebărilor este cel din sursă, cu o excepție cerută de autoare: caseta „Toți au responsabilități” de la Q21 a fost eliminată. Varianta „Sub 18 ani” de la Q2, scoasă în versiunea 3.0, a fost repusă în 3.1.
