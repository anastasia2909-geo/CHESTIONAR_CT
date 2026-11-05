# Durata estimată a completării

Pagina de start afișează „10–15 minute, estimat” (`DURATA_ESTIMATA_MINUTE` în `R/00_config.R`). Valoarea este o estimare inițială, calculată din conținutul chestionarului. Nu a fost măsurată cu respondenți reali și trebuie validată prin completări de probă.

## Metoda

**Citire.** Textul întrebărilor, al variantelor și al notelor are 1 072 de cuvinte, iar textul de informare încă aproximativ 250. La o viteză de citire de 200–250 de cuvinte pe minut, citirea durează 5–6,5 minute. Lista de 42 de cartiere de la Q1 este parcursă, nu citită integral.

**Răspunsuri.** Timpii sunt presupuși pentru fiecare tip de întrebare, nu măsurați:

| Întrebări | Ce face respondentul | Timp presupus |
|---|---|---|
| 15 întrebări cu un singur răspuns | alege o variantă | 3–5 s fiecare, aproximativ 1 minut |
| Q10, Q11, Q16, Q20 | bifează mai multe variante | 8–12 s fiecare, aproximativ 40 s |
| Q1 | caută cartierul în listă | 10–20 s |
| Q5, Q6 | scrie numărul de persoane și împărțirea pe vârste | 30–45 s |
| Q8 | estimează consumul lunar de apă (m³) | 30 s – 2 minute (capătul de sus, dacă respondentul caută factura) |
| Q9 | împarte consumul în procente care însumează 100% | 1–2 minute |
| Q12 | 8 rânduri, câte un răspuns | 30–45 s |
| Q21 | 5 rânduri pe scala 1–5 | 15–25 s |
| Q25 | răspuns liber, opțional | 0–1 minut |
| Verificare, eventuale corecturi | parcurge pagina de verificare | 30 s – 1 minut |

Însumate, răspunsurile durează 5–10 minute (capătul de sus presupune căutarea facturii la Q8 și un răspuns lung la Q25). Cu citirea, rezultă 10–16 minute. Pagina afișează 10–15 minute, intervalul în care se încadrează o completare fără căutarea facturii.

## Validare

Estimarea trebuie verificată cu completări reale, de preferat 5–10 persoane diferite, pe telefon și pe calculator:

1. Porniți aplicația în modul test.
2. Fiecare persoană completează chestionarul de la „Începe” până la trimitere.
3. Pagina finală arată, doar în modul test, cronometrul de la „Încep chestionarul” până la trimitere (nu se salvează). Notați valoarea.
4. Dacă valorile ies din interval, schimbați `DURATA_ESTIMATA_MINUTE` (de exemplu `"8–12"`) și reporniți aplicația.

Cronometrul nu include timpul de citire a informării, deci la durata măsurată se adaugă 1–2 minute.
