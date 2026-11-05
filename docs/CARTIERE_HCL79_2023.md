# Cartierele municipiului Constanța (HCL nr. 79/2023)

Lista din `config/zone_q1.csv` (întrebarea 1) și tabelul complet din `config/cartiere_hcl79_2023.csv` sunt extrase din documentul furnizat de autoare, `fisier (1).pdf`.

## Sursa

- **Actul:** Hotărârea Consiliului Local al municipiului Constanța nr. 79 din 28.02.2023 „privind atribuirea de denumiri cartierelor din municipiul Constanța”, adoptată în ședința ordinară din 28.02.2023 cu 27 de voturi pentru, din 27 de consilieri în funcție. Semnează președintele de ședință Mirela Garip și secretarul general Fulvia-Antonela Dinescu (contrasemnătură).
- **Temeiul citat în hotărâre:** OG nr. 63/2002 (art. 2, art. 3 alin. (1), art. 5 alin. (1) și (2)), avizul nr. 3/27.01.2023 al Comisiei de atribuire de denumiri a județului Constanța și OUG nr. 57/2019.
- **Art. 1:** „Se atribuie denumiri cartierelor din municipiul Constanța, conform tabelului din anexa nr. 1 și planurilor din anexa nr. 2, care fac parte integrantă din prezenta hotărâre.”
- **Anexa 1** (paginile 2–3 din PDF): tabelul „Lista cartierelor din municipiul Constanța”, cu 42 de rânduri și coloanele Nr. crt., Denumire cartier și Delimitare.
- **Anexa 2** (paginile 4–45): 42 de planuri, câte unul pentru fiecare cartier, numerotate 2.1–2.42.
- **Fișierul PDF:** scanat (ABBYY FineReader PDF 15, creat la 03.03.2023), 45 de pagini, numai imagini, fără strat de text și fără date vectoriale.

## Metoda

1. Am citit tabelul din imaginile paginilor 2 și 3, mărite.
2. Un al doilea cititor a transcris independent tabelul din propriile decupaje, fără să vadă prima transcriere.
3. Am comparat cele două transcrieri cuvânt cu cuvânt, după uniformizarea literelor ș/ț și a spațiilor din jurul cratimelor: **0 diferențe** la denumiri și la delimitări.
4. Am citit titlul fiecăruia dintre cele 42 de planuri din anexa 2. Toate sunt lizibile, iar numărul planului corespunde numărului cartierului din anexa 1 (planul 2.N este pe pagina N+3).

## Convenții

- Literele ş și ţ cu sedilă din scan sunt scrise cu ș și ț cu virgulă, forma corectă în limba română. Coloana `denumire_tiparita` păstrează forma cu sedilă.
- În rest, denumirile și delimitările sunt păstrate exact ca în original, inclusiv inconsecvențele (vezi „Observații”).
- Codurile (`cod`) sunt fără diacritice și rămân stabile în baza de date și în export.
- Coloana `categorie_dupa_denumire` arată numai ce reiese din denumire: 3 denumiri încep cu „Zona/Zonă” și una este „Stațiunea Mamaia”. Hotărârea le numește pe toate 42 „cartiere”.
- Hotărârea stabilește limitele prin text (anexa 1) și prin planuri scanate (anexa 2). Nu există coordonate, iar aplicația nu deduce limite din ele.

## Lista

Ordinea din HCL; în întrebarea 1 lista apare în ordine alfabetică.

| Nr. HCL | Denumire | Cod | Plan (anexa) | Pagina PDF |
|---|---|---|---|---|
| 1 | Zona industrială Sud | `zona_industriala_sud` | 2.1 | 4 |
| 2 | Km 5 | `km_5` | 2.2 | 5 |
| 3 | Faleză Sud | `faleza_sud` | 2.3 | 6 |
| 4 | Viile Noi | `viile_noi` | 2.4 | 7 |
| 5 | Veterani | `veterani` | 2.5 | 8 |
| 6 | Km 4-5 | `km_4_5` | 2.6 | 9 |
| 7 | Km 4 | `km_4` | 2.7 | 10 |
| 8 | Far - Abator | `far_abator` | 2.8 | 11 |
| 9 | Oil Terminal | `oil_terminal` | 2.9 | 12 |
| 10 | Cet | `cet` | 2.10 | 13 |
| 11 | Zonă industrială | `zona_industriala` | 2.11 | 14 |
| 12 | Palas | `palas` | 2.12 | 15 |
| 13 | Brătianu | `bratianu` | 2.13 | 16 |
| 14 | Gară | `gara` | 2.14 | 17 |
| 15 | Theodor Burada | `theodor_burada` | 2.15 | 18 |
| 16 | Topolog | `topolog` | 2.16 | 19 |
| 17 | Inel II | `inel_2` | 2.17 | 20 |
| 18 | Casa de Cultură | `casa_de_cultura` | 2.18 | 21 |
| 19 | Atelierelor | `atelierelor` | 2.19 | 22 |
| 20 | Peninsula | `peninsula` | 2.20 | 23 |
| 21 | Centru | `centru` | 2.21 | 24 |
| 22 | Spitalul Mare | `spitalul_mare` | 2.22 | 25 |
| 23 | Coiciu | `coiciu` | 2.23 | 26 |
| 24 | Compozitori - Energia | `compozitori_energia` | 2.24 | 27 |
| 25 | Zona Comercială N-V | `zona_comerciala_n_v` | 2.25 | 28 |
| 26 | Baba Novac | `baba_novac` | 2.26 | 29 |
| 27 | Inel I | `inel_1` | 2.27 | 30 |
| 28 | Anadalchioi | `anadalchioi` | 2.28 | 31 |
| 29 | Tomis I | `tomis_1` | 2.29 | 32 |
| 30 | Tomis II | `tomis_2` | 2.30 | 33 |
| 31 | Piața Chiliei | `piata_chiliei` | 2.31 | 34 |
| 32 | Universitate | `universitate` | 2.32 | 35 |
| 33 | Faleză Nord | `faleza_nord` | 2.33 | 36 |
| 34 | Parc Tăbăcărie | `parc_tabacarie` | 2.34 | 37 |
| 35 | Tomis Nord | `tomis_nord` | 2.35 | 38 |
| 36 | Badea Cârțan | `badea_cartan` | 2.36 | 39 |
| 37 | Tomis III | `tomis_3` | 2.37 | 40 |
| 38 | Stadion | `stadion` | 2.38 | 41 |
| 39 | Campus | `campus` | 2.39 | 42 |
| 40 | Palazu Mare | `palazu_mare` | 2.40 | 43 |
| 41 | Stațiunea Mamaia | `statiunea_mamaia` | 2.41 | 44 |
| 42 | Tomis Plus | `tomis_plus` | 2.42 | 45 |

## Delimitări (anexa 1)

1. **Zona industrială Sud**: șos. Mangaliei - cale ferată - str. Viorelor - str. Theodor Speranția - incintă Secția 5 de Poliție - șos. Mangaliei
2. **Km 5**: șos. Mangaliei - str. Fântânele - str. Comarnic - str. Meșterul Manole - str. Sergent Nicolae Grindeanu - șos. Mangaliei
3. **Faleză Sud**: șos. Mangaliei - incintă Secția 5 de Poliție - str. Theodor Speranția - str. Viorelelor - incintă Port Constanta - taluz - str. Pajurei - str. Viorelelor - șos. Mangaliei
4. **Viile Noi**: str. Comarnic - limită intravilan - str. Crângului - limită intravilan - str. Câmpul cu Flori - str. Vârful cu Dor - bd. Aurel Vlaicu - str. Câmpinei - incintă Brigada 9 Mecanizată "Mărășești" - str. Comarnic
5. **Veterani**: Str. Fântânele - str. Meșterul Manole - limită UAT - șos. Mangaliei - str. Fântânele
6. **Km 4-5**: șos. Mangaliei - str. Sergent Nicolae Grindeanu - str. Meșterul Manole - Brigada 9 Mecanizată "Mărășești" - str. Câmpinei - bd. Aurel Vlaicu - șos. Mangaliei
7. **Km 4**: str. Viorelelor - str. Pajurei - taluz - bd. 1 Mai Vechi - str. Slt. Furtună Cosmin - șos. Mangaliei - intr. Mangaliei - cale ferată - str. Viorelelor
8. **Far - Abator**: șos. Mangaliei - str. Slt. Furtună Cosmin - taluz - str. Sudului - str. Stadionului - bd. 1 Mai - str. Doctor Alexandru Simion Marcovici - șos. Mangaliei
9. **Oil Terminal**: bd. Aurel Vlaicu - str. Caraiman - cale ferată - str. Cumpenei - bd. I. C. Brătianu - cale ferată - bd. Aurel Vlaicu
10. **Cet**: bd. Aurel Vlaicu - str. Caraiman - cale ferată - pasajul Cumpenei - str. Ion Casian - str. Medeea - bd. Aurel Vlaicu
11. **Zonă industrială**: bd. Aurel Vlaicu - str. Vârful cu Dor - str. Câmpul cu Flori - limită intravilan - cale ferată - bd. Aurel Vlaicu
12. **Palas**: bd. Aurel Vlaicu - cale ferată - Autostrada Soarelui - bd. I. C. Brătianu - limită intravilan - incintă RAJA - str. Crișului - bd. Aurel Vlaicu
13. **Brătianu**: bd. Aurel Vlaicu - cale ferată - pasajul Cumpenei - str. Nicolae Filimon - bd. Aurel Vlaicu
14. **Gară**: bd. I. C. Brătianu - bd. Ferdinand - alee acces între bl. A2 și AR1 - str. Traian - valea Portului - str. Sudului - str. Stadionului - bd. 1 Mai - str. Doctor Alexandru Simion Marcovici - șos. Mangaliei - str. Maior Ion Porumbaru - cale ferată - bd. I.C. Brătianu
15. **Theodor Burada**: bd. I.C. Brătianu - str. Avram Iancu - str. București - str. Theodor Burada - str. I.L. Caragiale - incintă Cimitir Central - str. Corbului - bd. I.C. Brătianu
16. **Topolog**: bd. I.C. Brătianu - str. Dezrobirii - str. Dimitrie Anghel - str. I. L. Caragiale - incintă Cimitir Central - str. Corbului - bd. I.C. Brătianu
17. **Inel II**: str. I.L. Caragiale - str. Dezrobirii - str. Aron Vodă - str. Eliberării - str. Dezrobirii - str. Ion Roată - str. I.L. Caragiale
18. **Casa de Cultură**: bd. Alexandru Lăpușneanu - str. Avram Iancu - str. București - str. Theodor Burada - str. Ion Roată - bd. Alexandru Lăpușneanu
19. **Atelierelor**: str. I.Ghe. Duca - str. Valea Portului - incintă Port - str. Traian - bd. Ferdinand - bd. I. C. Brătianu - str. Avram Iancu - str. I.Gh. Duca
20. **Peninsula**: str. Negru Voda - limită Port turistic Tomis - incinta Port Constanța - str. Negru Vodă
21. **Centru**: bd. Mamaia - str. I. Gh. Duca - str. Valea Portului (incintă Port Constanta) - str. Negru Vodă - limită plajă - str. Unirii - bd. Mamaia
22. **Spitalul Mare**: str. Nicolae Iorga - bd. Mamaia - str. I. Gh. Duca - str. Avram Iancu - str. Nicolae Iorga
23. **Coiciu**: str. Dezrobirii - str. Soveja - str. Barbu Ștefănescu Delavrancea - bd. Alexandru Lăpușneanu - str. Ion Roată - str. Dezrobirii
24. **Compozitori - Energia**: str. Dezrobirii - str. Baba Novac - bd. Aurel Vlaicu - cale ferată - str. Eliberării - str. Dezrobirii
25. **Zona Comercială N-V**: Str. Nicole Filimon - bd. Aurel Vlaicu - str. Crișului - limită intravilan - str. Haga - bd. Tomis - bd. Aurel Vlaicu - str. Ștefăniță Vodă - incintă Unitate Militară 02049 - incintă Cimitir Municipal - str. Baba Novac - cale ferată - str. Eliberării - str. Nicolae Filimon
26. **Baba Novac**: str. Baba Novac - incintă Cimitir Municipal - incintă Unitate Militară 02049 - str. Ștefăniță Vodă - incintă Unitate Militară - str. Horia Grigorescu - str. Baba Novac
27. **Inel I**: str. Soveja - str. Baba Novac - str. Horia Grigorescu - incintă Unitate Militară 02049 - str. Ștefăniță Vodă - str. Soveja
28. **Anadalchioi**: str. Soveja - str. Barbu Ștefănescu Delavrancea - bd. Alexandru Lăpușneanu - bd. Tomis - str. Soveja
29. **Tomis I**: bd. Tomis - str. Nicolae Iorga - bd. Alexandru Lăpușeanu - bd. Tomis
30. **Tomis II**: bd. Tomis - str. Ion Rațiu - str. Maramureș - str. Nicolae Iorga - bd. Tomis
31. **Piața Chiliei**: bd. Mamaia - str. Ion Rațiu - str. Maramureș - str. Nicolae Iorga - bd. Mamaia
32. **Universitate**: bd. Mamaia - str. Unirii - limită plajă - str. Pescăruș - str. Ion Rațiu - bd. Mamaia
33. **Faleză Nord**: bd. Mamaia - str. Ion Rațiu - limită plajă - limită Stațiunea Mamaia - bd. Mamaia
34. **Parc Tăbăcărie**: bd. Alexandru Lăpușeanu - str. Soveja - bd. Mamaia - bd. Aurel Vlaicu - bd. Alexandru Lăpușeanu
35. **Tomis Nord**: bd. Aurel Vlaicu - bd. Tomis - str. Soveja - bd. Alexandru Lăpușeanu - bd. Aurel Vlaicu
36. **Badea Cârțan**: bd. Aurel Vlaicu - str. Ștefăniță Vodă - str. Soveja - bd. Tomis - bd. Aurel Vlaicu
37. **Tomis III**: bd. Tomis - str. Soveja - str. Primăverii - str. Ion Rațiu - bd. Tomis
38. **Stadion**: str. Primăverii - str. Ion Rațiu - bd. Mamaia - str. Soveja
39. **Campus**: bd. Aurel Vlaicu - incintă RAJA (inclusiv) - str. Emil Cioran - mal lac Siutghiol - canal lac Siutghiol - Tăbăcărie - bd. Aurel Vlaicu
40. **Palazu Mare**: bd. Tomis - incintă RAJA - mal lac Siutghiol - limită UAT - bd. Tomis
41. **Stațiunea Mamaia**: limită cartier Faleză Nord - limită Parc Tăbăcărie - limită cartier Campus - limită UAT
42. **Tomis Plus**: bd. Tomis - limită intravilan - str. Haga - bd. Tomis

## Observații de verificat

- 1. Zona industrială Sud: În delimitare: „str. Viorelor” (în rândurile 3 și 7: „Viorelelor”), ca în original.
- 10. Cet: În tabel: „Cet”; pe plan (anexa 2.10) eticheta hărții este „CET”.
- 19. Atelierelor: În delimitare: „I.Ghe. Duca” și „I.Gh. Duca” în același rând, ca în original.
- 20. Peninsula: În tabel: „Peninsula”; titlul planului 2.20: „Peninsulă”.
- 25. Zona Comercială N-V: Titlul planului 2.25: „Zona Comercială Nord-Vest”. Delimitarea începe cu „Nicole Filimon” și se încheie cu „Nicolae Filimon” (ca în original).
- 29. Tomis I: În delimitare: „Lăpușeanu” (ca în original; în alte rânduri „Lăpușneanu”).
- 30. Tomis II: Titlul planului 2.30 este „Plan cartier Tomis” (fără număr); eticheta de pe hartă este „Tomis 2”.
- 31. Piața Chiliei: Tipărit cu ş/ţ cu sedilă; scris aici cu ș/ț (virgulă dedesubt).
- 34. Parc Tăbăcărie: În delimitare: „Lăpușeanu” (ca în original).
- 35. Tomis Nord: În delimitare: „Lăpușeanu” (ca în original).
- 36. Badea Cârțan: Tipărit cu ş/ţ cu sedilă; scris aici cu ș/ț (virgulă dedesubt).
- 41. Stațiunea Mamaia: Tipărit cu ş/ţ cu sedilă; scris aici cu ș/ț (virgulă dedesubt).
- 42. Tomis Plus: Planul 2.42 conține și ștampila „Anexă la HCLM nr. 79/2023” și semnăturile.
- Toate cele 42 de denumiri și delimitări sunt lizibile; nu am găsit rânduri incerte.

## Ce nu conține lista

- Nu există variantă pentru persoanele care nu își cunosc cartierul și nici pentru cele din afara municipiului (vezi `docs/DECIZII_DE_CONFIRMAT.md`, punctul 3).
- Denumiri neoficiale, folosite curent în oraș, dar care nu apar în HCL, nu sunt incluse.
