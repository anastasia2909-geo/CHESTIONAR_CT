# Auditul datelor de identificare (versiunea 3.2.0, 01.11.2026)

Întrebarea auditului: ce date care ar putea identifica un respondent colectează sau păstrează aplicația, direct sau prin serverul pe care rulează. Concluzia este la final.

## Ce s-a verificat

1. **Codul aplicației** (`R/`, `www/app.js`, `www/harta.js`, `app.R`): căutare după `REMOTE_ADDR`, `HTTP_X_FORWARDED_FOR`, `session$request`, user-agent, `document.cookie`, `localStorage`, `sessionStorage`. Nicio apariție. Singura informare despre cerere folosită este partea `?admin` a adresei, pentru a alege între chestionar și zona de administrare; ea nu se salvează.
2. **Coloanele bazei de date** (`schema_date()` în `R/01_intrebari.R`): în afara răspunsurilor, se salvează doar `response_id` (32 de caractere hexazecimale aleatorii, generate de server), `submitted_at` (data trimiterii, UTC; din versiunea 3.2 fără oră), `mod`, `versiune_chestionar`, `versiune_aplicatie`, `consimtamant` și `varsta_minima_confirmata` (goală din versiunea 3.1). Nu se salvează adresa IP, browserul, sistemul de operare, rezoluția ecranului sau limba.
3. **Testul în browser** (`tests/browser/test_e2e.py`), pe parcursuri complete, pe telefon și pe desktop:
   - nicio cerere către alt server decât aplicația, de la deschiderea paginii până la pagina finală;
   - niciun cookie setat;
   - `localStorage` și `sessionStorage` goale.
4. **Jurnalul aplicației** (ieșirea consolei R) după testele în browser: conține doar mesajele de pornire, adresa de ascultare (`127.0.0.1`) și, la parolele de administrare greșite, ora încercării. Nicio adresă IP a unui vizitator.
5. **Întrebările:** chestionarul nu cere nume, prenume, e-mail, telefon sau adresă și nu are cont sau autentificare pentru respondenți.

## Ce poate identifica totuși un respondent

| Sursă | Ce conține | Unde | Ce se poate face |
|---|---|---|---|
| Jurnalele serverului de găzduire | De obicei adresa IP, ora, adresa paginii, browserul | La furnizorul de găzduire, în afara aplicației | De verificat după crearea contului Connect Cloud (varianta din `docs/GAZDUIRE.md`): ce jurnale păstrează platforma și cât timp. Aplicația nu le poate controla. |
| Cookie-uri ale găzduirii | Unele platforme (de exemplu, cele cu mai multe servere) pot seta cookie-uri tehnice de repartizare a sesiunii | La furnizor | De verificat pe serverul ales, cu instrumentele browserului (F12 > Application > Cookies). |
| `submitted_at` | Din 3.2 doar data trimiterii | În baza de răspunsuri | Rezolvat: fără oră, un răspuns nu poate fi legat după oră de jurnalele serverului. Într-o zi cu o singură trimitere, legătura rămâne posibilă pentru cine are acces atât la jurnale, cât și la baza de date; de aceea jurnalele se păstrează cât mai scurt (`docs/GAZDUIRE.md`). |
| Răspunsul liber Q25 | Ce scrie respondentul | În baza de răspunsuri | Chestionarul cere să nu se scrie date de identificare; textul trebuie citit înainte de citare și eliminat ce identifică. |
| Combinația Q1, Q2, Q4, Q5, Q6 | Cartier, grupă de vârstă, tip de locuință, numărul și vârstele membrilor gospodăriei | În baza de răspunsuri | Într-un cartier mic, combinația poate fi unică. De aceea rezultatele se publică agregat, iar harta ascunde valorile sub prag. Exporturile brute nu se distribuie. |
| Fundalul OpenStreetMap | Adresa IP a dispozitivului ajunge la serverele OpenStreetMap | Doar dacă respondentul apasă butonul | Butonul are lângă el această mențiune; se poate elimina cu `HARTA_FUNDAL_OSM_PERMIS <- FALSE`. |

## Concluzie

Aplicația nu cere și nu salvează date de identificare directă, adrese IP, ora trimiterii, cookie-uri sau identificatori de urmărire și nu trimite date către servicii externe fără o acțiune a respondentului. La găzduirea din `docs/GAZDUIRE.md`, aplicația scrie răspunsurile în baza Neon (PostgreSQL), iar copia zilnică ajunge într-un depozit GitHub privat; ambele conțin aceleași rânduri anonime ca baza locală. Pe această bază, textul de informare spune că chestionarul este anonim (decizia autoarei, versiunea 3.2). Riscurile rămase sunt cele din tabel: jurnalele serverului (de limitat la găzduire), textul liber de la Q25 (de citit înainte de citare) și combinațiile de răspunsuri dintr-un cartier mic (de aceea publicarea este doar agregată, iar exporturile brute nu se distribuie). Cadrul legal: `docs/CADRU_LEGAL.md`.
