# Harta: date, surse și limitări

## Ce arată harta

Harta din pagina finală, în secțiunea „Constanța pe hartă”, arată:

- limita administrativă a municipiului Constanța, colorată, cu eticheta „Constanța”;
- limitele celor 19 localități vecine, în culoarea nisipului, cu numele lor;
- Marea Neagră, ca fundal albastru: țărmul este marginea poligoanelor de uscat;
- legenda, butonul „Constanța” pentru recentrare, butoanele de zoom și atribuirea sursei.

Lângă hartă, fișa „Cartierul ales la întrebarea 1” arată:

- denumirea cartierului și numărul lui din anexa 1 la HCL nr. 79/2023;
- delimitarea textuală din anexa 1;
- planul scanat al cartierului din anexa 2, cu link către imaginea la dimensiune completă.

Harta nu arată răspunsuri individuale și nu poziționează respondentul. Din versiunea 3.2, harta desenează cele 42 de cartiere (limite orientative) și le colorează după indicatorii agregați descriși în `docs/INDICATORI_HARTA.md`, peste pragul minim de completări; cartierul respondentului are contur auriu.

## Tehnologie

- **Leaflet 1.9.4**, inclus local în `www/lib/leaflet/` (licență BSD-2-Clause). Nu se încarcă biblioteci de pe internet.
- **Desenarea:** codul din `www/harta.js`. Serverul Shiny trimite browserului datele hărții după trimiterea chestionarului (funcția `mesaj_harta()` din `R/11_harta.R`).
- **Pachetul R `leaflet`:** nu este folosit, deci nu trebuie instalat. Pachetul nu a putut fi descărcat în mediul de dezvoltare, iar varianta JavaScript a putut fi testată complet.
- **Pe telefon:** harta nu se mută cu degetul, ca să nu blocheze derularea paginii. Se folosesc butoanele + și −, iar rotița mouse-ului nu schimbă zoomul.

## Datele

### Limitele administrative (`www/harta/uat.geojson`)

| | |
|---|---|
| Conținut | 20 de unități administrativ-teritoriale: municipiul Constanța și localitățile din jur |
| Sursa primară | ANCPI, setul „Unități administrative”, data.gov.ro |
| Licență | CC BY 4.0 (atribuirea apare pe hartă) |
| Distribuitor | geoBoundaries, gbOpen, Romania ADM2, boundaryID `ROU-ADM2-2599482` |
| An de referință / actualizarea sursei | 2016 / 19.01.2023 (din metadatele geoBoundaries) |
| Identificatorul poligonului Constanța | `shapeID 2599482B843815366907` |
| Fișierul descărcat | `geoBoundaries-ROU-ADM2.geojson`, SHA-256 `19154c9d6fe49da9d76e84ef29761dad263df8da097b0ecd05505af084ef16ba`, descărcat la 27.10.2026 |
| Prelucrare | `scripts/pregateste_harta.R`: decupare la zona Constanței, simplificare cu toleranța de 10 m, coordonate rotunjite la 5 zecimale, nume cu diacritice pentru afișare |
| Mărime | aproximativ 100 KB |

Citare academică: Runfola D. et al. (2020), *geoBoundaries: A global database of political administrative boundaries*, PLoS ONE 15(4): e0231866, https://doi.org/10.1371/journal.pone.0231866.

### Planurile cartierelor (`www/harta/planuri/`)

Folderul conține cele 42 de planuri din anexa 2 la HCL nr. 79/2023, extrase din PDF, rotite ca să se citească (după conturul foii scanate) și comprimate. Au în total aproximativ 5 MB, iar un respondent încarcă doar planul cartierului său.

### Limitele cartierelor (`www/harta/cartiere.geojson`, din versiunea 3.2)

| | |
|---|---|
| Conținut | cele 42 de cartiere din HCL nr. 79/2023, câte un poligon, cu codul din Q1 |
| Sursa | pachetul npm `@nspot/geo-pack-romania-neighbourhoods`, versiunea 1.6.0, publicat la 19.10.2026 (https://www.npmjs.com/package/@nspot/geo-pack-romania-neighbourhoods) |
| Cum au fost desenate (după documentația pachetului) | fiecare cartier urmează perimetrul descris în anexa 1 (străzi, cale ferată, țărm, incinte, limita UAT), pe linii OpenStreetMap din extrasul Geofabrik al României din 08.10.2026; cartierele formează o partiție (vecinii au granițe comune, fără suprapuneri); portul și incinta Brigăzii 9 rămân în afara cartierelor, ca în text |
| Verificarea cu planurile | fiecare poligon a fost comparat de autorul pachetului cu planul din anexa 2: 17 „în regulă”, 22 „aproximativă”, 3 „incertă” (Atelierelor, Baba Novac, Tomis Plus) |
| Licență | ODbL 1.0, © contribuitorii OpenStreetMap; fișierul `www/harta/cartiere_LICENTA.txt` însoțește datele |
| Fișierul descărcat | `geo-pack-romania-neighbourhoods-1.6.0.tgz`, SHA-256 `0967f5904ce389a2f0f3aee0b18b5ac8b7dcf17f925a59d26f5394f30a142de6`, descărcat la 01.11.2026 |
| Conversie | `scripts/importa_cartiere_osm.R`: verifică pentru fiecare cartier că delimitarea din pachet este identică cu transcrierea din `config/cartiere_hcl79_2023.csv` (42 din 42), pune codurile din chestionar și rotunjește coordonatele la 6 zecimale |

**Verificări proprii (01.11.2026):** toate cele 42 de geometrii sunt valide; suprapunerile dintre cartiere au aria 0 (doar granițe comune); în afara limitei UAT a municipiului (cu toleranță de 20 m) rămân aproximativ 500 m², din cauza diferenței dintre versiunile limitei ANCPI. Comparația vizuală cu planurile scanate a confirmat Tomis Nord („în regulă”); la Tomis Plus și Baba Novac planul arată o suprafață diferită de poligon, cum notează și pachetul („incertă”).

**Cum sunt prezentate pe site:** sub hartă apare „Limitele cartierelor sunt orientative, nu oficiale: urmează delimitările aprobate, dar sunt desenate aproximativ”, cu sursa; fișa cartierului ales spune rezultatul comparației cu planul („în regulă”, „aproximativă” sau „incertă”), iar la „incertă” precizează că referința este planul, afișat imediat dedesubt. Atribuirea OpenStreetMap apare pe hartă și în subsol.

**De ce nu s-au folosit alte surse:** nu există un strat oficial public al cartierelor. Hărțile de pe constanteni.ro și harta.constanta.rou.ro nu își declară sursa limitelor, nu oferă date și au toate drepturile rezervate. Termenii Google Maps interzic extragerea de date din hartă, deci Google Maps nu poate fi sursa unor poligoane republicate.

**Actualizare:** când apare o versiune nouă a pachetului sau un fișier oficial de la Primărie, se rulează din nou scriptul (sau se înlocuiește fișierul, cu `"tip_limite": "oficiale"` pentru datele oficiale).

## Cum se pot adăuga limitele cartierelor

Codul este pregătit pentru un fișier vectorial. Dacă fișierul există, harta:

- desenează cele 42 de cartiere, colorate după indicatorul ales;
- hașurează cartierele cu date insuficiente;
- evidențiază cu contur auriu cartierul ales de respondent;
- arată la trecerea mouse-ului (sau la atingere) denumirea și valoarea;
- mută tabelele indicatorilor sub „Vedeți valorile ca tabel”.

Locul fișierului: `www/harta/cartiere.geojson` sau, pentru un fișier aflat în altă parte, variabila de mediu `CHESTIONAR_CARTIERE_GEOJSON` (calea completă). Un fișier din afara `www/` este trimis browserului în mesajul aplicației, fără a face public folderul în care se află.

Cerințele pentru fișier:

- GeoJSON de tip `FeatureCollection`, cu coordonate WGS84 (longitudine, latitudine; EPSG:4326);
- un poligon (sau multipoligon) pentru fiecare cartier, cu proprietatea `cod` egală cu codul din `config/zone_q1.csv` (de exemplu `"tomis_nord"`);
- opțional, proprietatea `denumire`;
- la nivelul colecției: `"tip_limite": "oficiale"` numai pentru limite primite de la o autoritate, plus `"sursa"` (de unde provin). Fără `"tip_limite": "oficiale"`, sub hartă apare „Limitele cartierelor sunt orientative, nu oficiale; nu reproduc o delimitare aprobată”, urmat de sursă.

Exemplu de început de fișier pentru limite desenate de autoare:

```json
{"type": "FeatureCollection",
 "tip_limite": "orientative",
 "sursa": "desenate de autoare în QGIS după delimitările din anexa 1 la HCL nr. 79/2023, pe fundal OpenStreetMap, 2026",
 "features": [ ... ]}
```

Fila „Stare” din zona de administrare arată câte cartiere are fișierul.

### Fișierul de test cu poligoane FALSE

`tests/fixtures/cartiere_test_FALS.geojson` conține 42 de pătrate sintetice, așezate în grilă peste Constanța, câte unul pentru fiecare cod. Nu sunt limitele cartierelor. Fișierul servește numai testelor automate (`tests/testthat/test-indicatori.R` și testul în browser, cu o a doua instanță a aplicației) și are în proprietatea `descriere` mențiunea „DATE FALSE PENTRU TESTE”. Nu se copiază în `www/harta/`.

Două căi pentru obținerea datelor:

1. **De la Primăria Constanța (recomandat).** Planurile din anexa 2 au fost realizate într-un program GIS: atribuirea Esri este tipărită pe ele. Este probabil ca Direcția Generală Urbanism și Patrimoniu să aibă fișierele vectoriale (shapefile sau GeoPackage). Se pot cere în baza Legii nr. 544/2001, menționând HCL nr. 79/2023 și scopul academic. Fișierul primit se transformă în GeoJSON WGS84 (de exemplu, în QGIS: Export > Save Features As > GeoJSON, CRS EPSG:4326) și se adaugă coloana `cod`.
2. **Georeferențiere manuală în QGIS**, ca metodă de rezervă. Pentru fiecare plan:
   - se folosește Georeferencer, cu cel puțin 4–6 puncte de control pe intersecții de străzi identificabile, pe un fundal OpenStreetMap;
   - se desenează poligonul urmând delimitarea textuală din anexa 1;
   - se verifică vecinătatea cu cartierele alăturate (fără goluri sau suprapuneri).

   Rezultatul este o aproximare a autoarei, nu o limită oficială. Dacă se folosește, trebuie descris ca atare în lucrare și pe hartă (se schimbă textul din `R/09_profil.R`, secțiunea „Constanța pe hartă”).

## Fundalul OpenStreetMap

Butonul „Afișează fundalul OpenStreetMap” adaugă plăcile de hartă de la `tile.openstreetmap.org`, cu atribuirea „© contribuitorii OpenStreetMap”. Ele se încarcă numai la cererea respondentului, pentru că serverele OpenStreetMap primesc atunci adresa IP a dispozitivului. Cu fundalul activ, poligoanele UAT devin transparente, iar cartierele colorate devin parțial transparente. Opțiunea se dezactivează cu `HARTA_FUNDAL_OSM_PERMIS <- FALSE` în `R/00_config.R`.

În mediul de testare, accesul la OpenStreetMap este blocat. Testul automat confirmă că butonul trimite cereri către `tile.openstreetmap.org` numai după apăsare și că nu există cereri înainte. Afișarea efectivă a plăcilor nu a putut fi verificată; verificați-o în RStudio, pe calculatorul dumneavoastră.

## Limitări

- Limitele UAT sunt cele din setul ANCPI (an de referință 2016). Lacul Siutghiol nu apare separat, pentru că face parte din teritoriul administrativ.
- Harta nu are străzi decât dacă respondentul încarcă fundalul OpenStreetMap.
- Delimitarea textuală reproduce documentul oficial, inclusiv inconsecvențele lui (vezi `docs/CARTIERE_HCL79_2023.md`).

## Limite oficiale

Dacă se dorește înlocuirea limitelor orientative cu cele oficiale, ele se pot cere Primăriei, în baza Legii nr. 544/2001 (modelul de mai jos), și se pun în `www/harta/cartiere.geojson` cu `"tip_limite": "oficiale"`.

### Model de cerere (Legea nr. 544/2001)

> Către Primăria Municipiului Constanța, Direcția Generală Urbanism și Patrimoniu
>
> Subsemnata Anastasia NICEA, studentă la Universitatea din București, Facultatea de Geografie, vă rog să îmi comunicați, în baza Legii nr. 544/2001 privind liberul acces la informațiile de interes public, limitele celor 42 de cartiere ale municipiului Constanța stabilite prin HCL nr. 79/28.02.2023, în format vectorial (de exemplu shapefile, GeoPackage sau GeoJSON), cu sistemul de coordonate folosit. Planurile din anexa 2 la hotărâre au fost realizate într-un program GIS, iar datele sunt necesare pentru o hartă dintr-o lucrare de licență, cu citarea sursei.
>
> Vă rog să îmi transmiteți răspunsul în format electronic la adresa anastasia.nicea@s.unibuc.ro.
>
> Data, semnătura
