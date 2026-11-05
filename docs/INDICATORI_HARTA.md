# Indicatorii pe cartiere

Indicatorii descriu persoanele care au completat chestionarul și comportamentele pe care le-au declarat. Nu măsoară poluarea, nu evaluează rețeaua de canalizare și nu clasifică cartierele. Eșantionul nu este reprezentativ pentru locuitorii unui cartier. Codul este în `R/12_indicatori.R`; testele, în `tests/testthat/test-indicatori.R`.

## Ce răspunsuri intră în calcul

Un răspuns intră în calcul dacă:

- are acordul de participare (`consimtamant = 1`);
- are un cartier la Q1 (`q01_zona` completat) și codul este unul dintre cele 42;
- este din modul curent (în modul test se folosesc numai răspunsurile de test, în producție numai cele reale).

Răspunsurile salvate au trecut toate validarea, deci nu există completări parțiale în baza de date. Funcția este `filtreaza_valide()`. Același filtru este folosit pentru comparația cu ceilalți respondenți și pentru variabila `completare_valida` din exportul pentru analiză.

Calculul se face pe server, la fiecare trimitere, din baza de date. Browserul primește numai rezultatele pe cartiere, fără numărători pentru cartierele sub prag.

## Indicatorii

| Indicator | Întrebare | Numărător | Numitor | Unitate |
|---|---|---|---|---|
| Numărul de respondenți | Q1 | — | răspunsurile valide cu acel cartier | respondenți |
| Uleiul uzat turnat în chiuvetă sau toaletă | Q13 | `q13_ulei = chiuveta_toaleta` | Q13 completat și diferit de „Nu folosesc ulei” | % din respondenți |
| Cel puțin un obiect aruncat în toaletă | Q12 | cel puțin unul din cele 8 obiecte are un motiv de aruncare (`rapid_obisnuinta`, `fara_cos`, `credeam_permis`, `eticheta_flushable`) | cei din numărător plus cei care au ales „Nu l-am aruncat” la toate cele 8 obiecte | % din respondenți |
| Șervețele umede aruncate în toaletă | Q12, rândul „Șervețele umede” | un motiv de aruncare la acest rând | un motiv de aruncare sau „Nu l-am aruncat” la acest rând | % din respondenți |

Răspunsurile „Prefer să nu răspund” scot respondentul din numitor: la indicatorul „cel puțin un obiect”, un respondent care nu are niciun motiv de aruncare, dar a ales „Prefer să nu răspund” la cel puțin un obiect, este exclus, pentru că nu se știe dacă a aruncat sau nu acel obiect.

Procentul unui cartier = numărător ÷ numitor × 100, calculat numai din respondenții acelui cartier.

## Pragurile

| Prag | Valoare | Setare în `R/00_config.R` | Efect |
|---|---|---|---|
| Completări valide în total | 30 | `HARTA_PRAG_TOTAL` | Sub prag, secțiunea afișează „Indicatorii pe cartiere nu sunt încă disponibili” și numărul de completări, fără valori pe cartiere. |
| Numitorul unui procent | 10 | `HARTA_PRAG_CARTIER` | Sub prag, cartierul apare „date insuficiente (sub 10 respondenți)”, hașurat, fără procent. |
| Numărul de respondenți | 5 | `HARTA_PRAG_NUMAR` | Între 1 și 4 respondenți, cartierul apare „sub 5 respondenți”, hașurat, fără cifra exactă. |

Pragurile sunt propuse pentru a evita procente calculate din foarte puține răspunsuri și pentru a nu permite deducerea răspunsului unei persoane dintr-un cartier mic. Nu sunt derivate statistic; trebuie confirmate de coordonator (`docs/DECIZII_DE_CONFIRMAT.md`, punctul 9). Cu 10 respondenți, un procent are o marjă de eroare mare; textul de pe pagină spune că valorile descriu doar respondenții.

Întreaga hartă tematică se dezactivează cu `HARTA_TEMATICA_ACTIVA <- FALSE`.

## Stările unui cartier

| Stare | Când | Afișare |
|---|---|---|
| `valoare` | numitor peste prag | culoarea clasei, valoarea și numitorul (de exemplu „44% din 16 respondenți”) |
| `suprimat` | 1 ≤ numitor < prag | gri hașurat, „date insuficiente” sau „sub 5 respondenți” |
| `fara_date` (procente) | numitor 0 | gri deschis, „fără răspunsuri pentru acest indicator” |
| `zero` (număr) | niciun respondent | gri deschis, „0 respondenți” |

## Clasele de culoare

Clasele sunt fixe, ca o culoare să aibă același sens pentru toți indicatorii procentuali și să nu se schimbe de la o zi la alta:

- procente: 0–9%, 10–19%, 20–34%, 35–49%, 50–100%;
- număr de respondenți: 1–4 (afișat doar ca „sub 5”), 5–9, 10–24, 25–49, 50 sau mai mulți.

Paleta are o singură nuanță de bleumarin, de la deschis la închis (`#9FB7D3`, `#7596BD`, `#4F74A3`, `#2D5486`, `#11305C`); mai închis înseamnă valoare mai mare. A fost verificată cu un validator de palete: luminozitatea scade monoton, iar capătul deschis are contrast de cel puțin 2:1 față de fundal. Datele lipsă și cele suprimate au culori gri separate, iar cele suprimate au și hașură, ca diferența să nu depindă doar de culoare.

## Diferența dintre număr și procent

Numărul de respondenți arată unde au răspuns mai multe persoane. Un cartier cu mai mulți respondenți nu are „mai multă” poluare; diferențele pot reflecta doar felul în care s-a distribuit chestionarul. Procentele arată ce parte din respondenții unui cartier au declarat un comportament și nu depind de mărimea cartierului. Legenda fiecărui indicator are unitatea scrisă explicit („respondenți” sau „% din respondenți”).

## Unde apar indicatorii

Pe hartă, peste limitele orientative ale celor 42 de cartiere (`www/harta/cartiere.geojson`): cartierele colorate după indicatorul ales, legenda sub hartă, valoarea la trecerea mouse-ului sau la atingere, contur auriu pentru cartierul respondentului și, sub „Vedeți valorile ca tabel”, câte un tabel pentru fiecare indicator. Dacă fișierul cu limite lipsește, apar doar tabelele.

Selectorul „Indicator afișat” schimbă harta, tabelul, descrierea și legenda.

## Limitări

- Eșantion de voluntari, nereprezentativ.
- Comportamente declarate, nu observate.
- Cartierul este cel declarat la Q1; respondenții care nu știu denumirea oficială pot alege un cartier vecin.
- Limitele de pe hartă sunt orientative (desenate pe OpenStreetMap după HCL nr. 79/2023); valorile nu depind de ele, pentru că se calculează după cartierul declarat, nu după poziție.
- Pragurile reduc, dar nu elimină, riscul de a deduce răspunsuri dintr-un cartier mic (de exemplu, prin compararea paginii înainte și după o trimitere). Nu se afișează niciodată valori sub prag.
