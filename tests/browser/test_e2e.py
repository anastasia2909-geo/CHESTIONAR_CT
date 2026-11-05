"""
Test end-to-end în browser (versiunea 3), pentru dezvoltator.
Necesită Python 3 + Playwright (pip install playwright; playwright install chromium)
și aplicația pornită în modul test, cu un folder de date SEPARAT și o parolă:

  CHESTIONAR_MOD=test CHESTIONAR_DATA_DIR=/tmp/date_e2e CHESTIONAR_ADMIN_PAROLA=parola-de-test \\
    Rscript -e 'shiny::runApp(port = 7788)'

Rulare:
  python3 tests/browser/test_e2e.py URL BAZA_TEST.sqlite FOLDER_CAPTURI PAROLA [URL_HARTA]

  URL_HARTA (opțional): o a doua instanță pornită cu
  CHESTIONAR_CARTIERE_GEOJSON=tests/fixtures/cartiere_test_FALS.geojson și cel puțin
  30 de răspunsuri de test, pentru harta tematică (poligoane FALSE, doar pentru test).
  Variabila AXE_PATH (opțional) indică fișierul axe.min.js pentru verificarea accesibilității.

Testul golește la început baza de date de TEST (numai un fișier *_TEST.sqlite)
și, pentru scenariul cu comparație, adaugă 30 de răspunsuri sintetice.
"""
import asyncio, os, sqlite3, subprocess, sys, json, urllib.request, urllib.error
from playwright.async_api import async_playwright

URL = sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:7788/"
DB = sys.argv[2] if len(sys.argv) > 2 else "data/raspunsuri_TEST.sqlite"
OUT = sys.argv[3] if len(sys.argv) > 3 else "."
PAROLA = sys.argv[4] if len(sys.argv) > 4 else ""
URL_HARTA = sys.argv[5] if len(sys.argv) > 5 else None
AXE = os.environ.get("AXE_PATH")
CHROME = os.environ.get("CHROME_PATH")
TITLU = "Evaluarea comportamentelor populației și a nivelului de conștientizare privind gestionarea apelor uzate în municipiul Constanța"

rezultate = []
def verifica(cond, nume):
    rezultate.append((bool(cond), nume))
    print(("OK   " if cond else "EȘEC ") + nume, flush=True)

# DB este calea bazei SQLite de test sau, pentru PostgreSQL, adresa
# postgresql://... a unei baze de probă (aplicația pornită cu CHESTIONAR_DB_URL;
# se folosește tabela raspunsuri_test, prin psql).
PG = DB.startswith("postgres")

def psql(sql):
    r = subprocess.run(["psql", DB, "-X", "-At", "-v", "ON_ERROR_STOP=1", "-c", sql],
                       capture_output=True, text=True, check=True)
    return r.stdout.strip()

def nr_randuri():
    if PG:
        if psql("SELECT to_regclass('raspunsuri_test') IS NOT NULL") != "t": return 0
        return int(psql("SELECT COUNT(*) FROM raspunsuri_test"))
    if not os.path.exists(DB): return 0
    con = sqlite3.connect(DB)
    try: return con.execute("SELECT COUNT(*) FROM raspunsuri").fetchone()[0]
    finally: con.close()

def ultimul_rand():
    if PG:
        return json.loads(psql("SELECT row_to_json(t) FROM (SELECT * FROM raspunsuri_test ORDER BY xmin::text::bigint DESC LIMIT 1) t"))
    con = sqlite3.connect(DB); con.row_factory = sqlite3.Row
    try: return dict(con.execute("SELECT * FROM raspunsuri ORDER BY submitted_at DESC, rowid DESC LIMIT 1").fetchone())
    finally: con.close()

async def asteapta(pg, ms=500): await pg.wait_for_timeout(ms)

def goleste_baza_test():
    if PG:
        if psql("SELECT to_regclass('raspunsuri_test') IS NOT NULL") == "t": psql("DELETE FROM raspunsuri_test")
        return
    assert DB.endswith("_TEST.sqlite"), "Testul golește numai baza de date de test"
    if not os.path.exists(DB): return
    con = sqlite3.connect(DB)
    try:
        if con.execute("SELECT name FROM sqlite_master WHERE name='raspunsuri'").fetchone():
            con.execute("DELETE FROM raspunsuri"); con.commit()
    finally: con.close()

async def fara_derulare_orizontala(pg, eticheta, unde):
    r = await pg.evaluate("""() => { const W = document.documentElement.clientWidth; const out = [];
      document.querySelectorAll('body *').forEach(e => { const b = e.getBoundingClientRect();
        if (b.width > 0 && b.right > W + 1 && !e.closest('.banda, .f-cuprins, .tranzitie, .leaflet-container')) out.push(e.tagName + '#' + e.id + '.' + String(e.className).slice(0, 30) + ' ' + Math.round(b.right)); });
      return [W, document.documentElement.scrollWidth, out.slice(0, 5)]; }""")
    verifica(r[1] <= r[0], f"[{eticheta}] fără derulare orizontală pe {unde} {r}")

async def axe(pg, eticheta, unde):
    if not AXE: return
    await pg.add_script_tag(path=AXE)
    r = await pg.evaluate("""async () => { const r = await axe.run(document, {runOnly: ['wcag2a','wcag2aa','wcag21a','wcag21aa'],
        rules: {'region': {enabled: false}}});
        return r.violations.map(v => v.id + ' (' + v.nodes.length + '): ' + v.nodes.slice(0,2).map(n => n.target.join(' ')).join(' | ')); }""")
    verifica(not r, f"[{eticheta}] axe WCAG 2.1 AA pe {unde}: {r}")

async def pagina_activa(pg):
    return await pg.evaluate("document.body.getAttribute('data-pagina')")

async def erori_vizibile(pg):
    return await pg.evaluate("""Array.from(document.querySelectorAll('.tab-pane.active .q.q-cu-eroare')).map(e=>e.dataset.qid)""")

async def bife(pg, nume):
    return await pg.evaluate(f"""Array.from(document.querySelectorAll('input[name="{nume}"]:checked')).map(e=>e.value)""")

async def deschide(p, latime, inaltime, **kw):
    b = await p.chromium.launch(**({"executable_path": CHROME} if CHROME else {}))
    ctx = await b.new_context(viewport={"width": latime, "height": inaltime}, **kw)
    pg = await ctx.new_page()
    pg.erori_js = []
    pg.on("pageerror", lambda e: pg.erori_js.append(str(e)))
    pg.cereri_osm = []
    pg.on("request", lambda r: pg.cereri_osm.append(r.url) if "openstreetmap.org" in r.url else None)
    pg.cereri_externe = []
    pg.on("request", lambda r: pg.cereri_externe.append(r.url) if not r.url.startswith(("http://127.0.0.1", "data:", "blob:", "about:")) else None)
    pg.ctx = ctx
    return b, pg

async def pana_la_intrebari(pg):
    await pg.goto(URL); await pg.wait_for_selector("#incepe"); await asteapta(pg, 800)
    await pg.click("#incepe"); await asteapta(pg, 900)
    await pg.check("#consimtamant")
    await pg.click("#start"); await asteapta(pg, 900)

# ---------------------------------------------------------------------------------------
async def acord():
    """Fără limită de vârstă; acordul este singura condiție, verificată pe server."""
    async with async_playwright() as p:
        b, pg = await deschide(p, 390, 844)
        inainte = nr_randuri()
        await pg.goto(URL); await pg.wait_for_selector("#incepe"); await asteapta(pg, 800)
        await pg.click("#incepe"); await asteapta(pg, 900)
        verifica(await pagina_activa(pg) == "intro", "[acord] butonul de start duce la informare și acord")
        verifica(not await pg.query_selector('input[name="varsta_minima"]') and not await pg.query_selector("#titlu-neeligibil"),
                 "[acord] nu există întrebare despre vârstă și nici pagină de respingere")
        await pg.click("#start"); await asteapta(pg)
        e2 = await pg.text_content("#eroare-consimtamant")
        verifica(await pagina_activa(pg) == "intro" and "acord" in e2, f"[acord] fără acord nu se începe ({e2!r})")
        focus = await pg.evaluate("document.activeElement && document.activeElement.id")
        verifica(focus == "consimtamant", f"[acord] focalizarea merge la caseta de acord ({focus})")
        # încercare de ocolire din consolă, fără acord
        await pg.evaluate("""() => { Shiny.setInputValue('start', 99, {priority:'event'});
                                     Shiny.setInputValue('inainte_s1', 99, {priority:'event'}); Shiny.setInputValue('trimite', 99, {priority:'event'}); }""")
        await asteapta(pg, 1200)
        verifica(await pagina_activa(pg) == "intro" and nr_randuri() == inainte,
                 f"[acord] ocolirea din consolă fără acord nu salvează nimic ({inainte} -> {nr_randuri()})")
        await pg.check("#consimtamant"); await pg.click("#start"); await asteapta(pg, 900)
        verifica(await pagina_activa(pg) == "s1", "[acord] cu acordul bifat se trece la întrebări, fără altă condiție")
        q2 = await pg.evaluate("""Array.from(document.querySelectorAll('input[name="q02"]')).map(o => o.value)""")
        verifica(q2[0] == "sub_18" and len(q2) == 8, f"[acord] Q2 are „Sub 18 ani” ({q2})")
        await axe(pg, "acord", "informare cu eroare")
        verifica(not pg.erori_js, f"[acord] fără erori JavaScript {pg.erori_js}")
        await b.close()

# ---------------------------------------------------------------------------------------
async def ruleaza(latime, inaltime, eticheta, q19="da", comparatie="goala"):
    async with async_playwright() as p:
        b, pg = await deschide(p, latime, inaltime)
        await pg.goto(URL); await pg.wait_for_selector("#incepe"); await asteapta(pg, 1500)

        # --- pagina de start
        verifica((await pg.title()) == TITLU, f"[{eticheta}] titlul filei este titlul lucrării")
        h1 = (await pg.text_content("#titlu-acasa")).strip()
        verifica(h1 == TITLU, f"[{eticheta}] titlul principal al paginii de start este titlul exact")
        html = await pg.content()
        verifica("Apa înseamnă viitorul" not in html, f"[{eticheta}] sloganul a fost eliminat")
        verifica("Anastasia NICEA" in html and "anastasia.nicea@s.unibuc.ro" in html and "Facultatea de Geografie" in html,
                 f"[{eticheta}] autoarea, e-mailul și facultatea apar pe pagină")
        verifica("sub coordonarea" not in html and "Coordonator:" not in html, f"[{eticheta}] coordonatorul nu este numit public")
        verifica("Cum sunt folosite datele" not in html, f"[{eticheta}] secțiunea „Cum sunt folosite datele” a fost eliminată")
        verifica("tipareste" not in html and "Tipărește" not in html, f"[{eticheta}] nu există buton de tipărire/PDF")
        verifica(await pg.is_visible(".start-grafica svg.coasta"), f"[{eticheta}] ilustrația coastei este vizibilă")
        fapte = await pg.text_content(".start-fapte")
        verifica("voluntar" in fapte and "10–15" in fapte and "fără nume" in fapte and "18+" not in fapte,
                 f"[{eticheta}] pagina de start: durata 10–15 minute, voluntar, fără nume, fără „18+”")
        opt = await pg.evaluate("Array.from(document.querySelectorAll('#q01 option')).map(o => o.value)")
        verifica(len(opt) == 43 and opt[0] == "" and not any("nu_stiu" in o for o in opt), f"[{eticheta}] Q1: 42 de cartiere + „Alegeți din listă”, fără „Nu știu” ({len(opt)})")
        q2 = await pg.evaluate("""Array.from(document.querySelectorAll('input[name="q02"]')).map(o => o.value)""")
        verifica("sub_18" in q2 and len(q2) == 8, f"[{eticheta}] Q2 are „Sub 18 ani” ({q2})")
        anc = await pg.text_content("#bloc-q21 .ancore-scala")
        verifica("1 = responsabilitate foarte mică" in anc and "5 = responsabilitate foarte mare" in anc, f"[{eticheta}] Q21 afișează etichetele scalei")
        verifica(not await pg.query_selector("#q21_toti"), f"[{eticheta}] Q21 nu mai are caseta „Toți au responsabilități”")
        verifica(len(pg.cereri_osm) == 0, f"[{eticheta}] nicio cerere către OpenStreetMap la încărcare")
        await fara_derulare_orizontala(pg, eticheta, "pagina de start")
        await pg.screenshot(path=os.path.join(OUT, f"{eticheta}_acasa.png"))
        await axe(pg, eticheta, "pagina de start")

        # --- informare
        await pg.click("#incepe"); await asteapta(pg, 1000)
        inf = await pg.text_content(".informare")
        verifica("Anastasia NICEA" in inf and "18 ani" not in inf and "durată nedeterminată" in inf and "nu salvează adresa IP" in inf
                 and "Chestionarul este anonim" in inf, f"[{eticheta}] informarea: autoarea, anonimatul, păstrarea, fără limită de vârstă")
        await axe(pg, eticheta, "informare")
        await pg.screenshot(path=os.path.join(OUT, f"{eticheta}_intro.png"), full_page=True)
        await pg.click("#inapoi_intro"); await asteapta(pg, 800)
        verifica(await pagina_activa(pg) == "acasa", f"[{eticheta}] „Înapoi” revine la pagina de start")
        await pg.click("#incepe"); await asteapta(pg, 900)
        await pg.check("#consimtamant")
        await pg.click("#start"); await asteapta(pg, 1000)
        verifica(await pagina_activa(pg) == "s1", f"[{eticheta}] cu acordul bifat se trece la secțiunea 1")
        stare = await pg.text_content("#progres-stare"); procent = await pg.text_content("#progres-procent")
        verifica("Secțiunea 1 din 4" in stare and "1–7 din 25" in stare and procent.strip() == "0%",
                 f"[{eticheta}] progres: secțiune, întrebări și procent ({stare!r}, {procent!r})")

        # --- secțiunea 1
        await pg.click("#inainte_s1"); await asteapta(pg)
        err = await erori_vizibile(pg)
        verifica(set(err) == {"q01","q02","q03","q04","q05","q06","q07"}, f"[{eticheta}] secțiunea 1 goală: 7 erori ({err})")
        await axe(pg, eticheta, "secțiunea 1 cu erori")
        await pg.select_option("#q01", "tomis_nord")
        await pg.check('input[name="q02"][value="25_34"]')
        await pg.check('input[name="q03"][value="universitar"]')
        await pg.check('input[name="q04"][value="apartament_bloc"]')
        await pg.fill("#q05", "4")
        await pg.fill("#q06_sub_18", "1"); await pg.fill("#q06_25_34", "2")     # restul goale = 0
        await pg.check('input[name="q07"][value="da"]')
        await asteapta(pg)
        total6 = await pg.text_content("#q06-total")
        verifica("Total: 3" in total6 and "din 4" in total6, f"[{eticheta}] totalul Q6 socotește câmpurile goale ca 0: {total6!r}")
        await pg.click("#inainte_s1"); await asteapta(pg)
        verifica(await erori_vizibile(pg) == ["q06"], f"[{eticheta}] Q6 respinge suma diferită de Q5")
        await pg.fill("#q06_45_54", "1"); await asteapta(pg)
        verifica(await pg.get_attribute("#q06-total", "data-stare") == "ok", f"[{eticheta}] totalul Q6 devine „ok” când suma = Q5")
        # text nevalid într-un câmp numeric: nu devine 0
        await pg.click("#q06_65_plus"); await pg.keyboard.type("e"); await asteapta(pg, 400)
        bad = await pg.evaluate("document.getElementById('q06_65_plus').validity.badInput")
        await pg.click("#inainte_s1"); await asteapta(pg)
        verifica(bad and await erori_vizibile(pg) == ["q06"], f"[{eticheta}] o valoare care nu este număr este respinsă, nu socotită 0 ({bad})")
        await pg.fill("#q06_65_plus", ""); await asteapta(pg, 400)
        await pg.click("#inainte_s1"); await asteapta(pg, 900)
        verifica(await pagina_activa(pg) == "s2", f"[{eticheta}] Q6 cu câmpuri goale acceptat când suma = Q5")
        procent = await pg.text_content("#progres-procent")
        verifica(procent.strip() == "28%", f"[{eticheta}] procentul de progres crește ({procent!r})")

        # --- secțiunea 2
        await pg.fill("#q08_rece", "12.5"); await pg.fill("#q08_calda", "3")
        await pg.check("#q08_nu_stiu"); await asteapta(pg, 300)
        dis = await pg.evaluate("[document.getElementById('q08_rece').disabled, document.getElementById('q08_rece').value, document.getElementById('q08_calda').value]")
        verifica(dis == [True, "", ""], f"[{eticheta}] „Nu știu” la Q8 golește și dezactivează câmpurile: {dis}")
        await pg.uncheck("#q08_nu_stiu"); await asteapta(pg, 300)
        await pg.fill("#q08_rece", "14")
        procente = {"igiena":"40","rufe":"15","vase":"10","alimente":"5","curatenie":"5","toaleta":"20"}   # plante gol = 0
        for k, v in procente.items(): await pg.fill(f"#q09_{k}", v)
        await asteapta(pg)
        t9 = await pg.text_content("#q09-total .text-total")
        verifica("95" in t9, f"[{eticheta}] totalul Q9 în timp real, gol = 0: {t9!r}")
        await pg.check('input[name="q10"][value="dusuri_scurte"]')
        await pg.check('input[name="q10"][value="nimic"]'); await asteapta(pg, 200)
        verifica(await bife(pg, "q10") == ["nimic"], f"[{eticheta}] Q10: „Nu am făcut nimic” debifează restul")
        await pg.check('input[name="q10"][value="robinet_inchis"]'); await pg.check('input[name="q10"][value="refolosit_apa"]')
        await pg.check('input[name="q11"][value="wc_doua_trepte"]')
        await pg.click('input[name="q12_servetele_umede"][value="eticheta_flushable"]')
        await pg.check('input[name="q13"][value="chiuveta_toaleta"]')
        await asteapta(pg)
        await pg.click("#inainte_s2"); await asteapta(pg)
        err = await erori_vizibile(pg)
        verifica(set(err) == {"q09", "q12"}, f"[{eticheta}] Q9 (95%) și Q12 incomplet sunt respinse ({err})")
        await pg.fill("#q09_plante_altele", "5")
        for k in ["prosoape_hartie","betisoare_dischete","igiena_menstruala","scutece","ata_par_obiecte","resturi_alimentare","medicamente"]:
            await pg.click(f'input[name="q12_{k}"][value="nu_am_aruncat"]')
        await asteapta(pg)
        await fara_derulare_orizontala(pg, eticheta, "secțiunea 2")
        await axe(pg, eticheta, "secțiunea 2")
        await pg.screenshot(path=os.path.join(OUT, f"{eticheta}_s2.png"), full_page=True)
        await pg.click("#inainte_s2"); await asteapta(pg, 900)
        verifica(await pagina_activa(pg) == "s3", f"[{eticheta}] secțiunea 2 completă trece mai departe")

        # --- înapoi păstrează răspunsurile
        await pg.click("#inapoi_s3"); await asteapta(pg, 900)
        val = await pg.evaluate("[document.getElementById('q08_rece').value, document.getElementById('q09_igiena').value]")
        verifica(val == ["14", "40"] and await bife(pg, "q10") == ["robinet_inchis","refolosit_apa"], f"[{eticheta}] înapoi: răspunsurile din secțiunea 2 sunt păstrate {val}")
        await pg.click("#inapoi_s2"); await asteapta(pg, 900)
        verifica(await pg.input_value("#q05") == "4", f"[{eticheta}] înapoi: Q5 păstrat")
        await pg.click("#inainte_s1"); await asteapta(pg, 900); await pg.click("#inainte_s2"); await asteapta(pg, 900)

        # --- secțiunea 3
        await pg.check('input[name="q14"][value="statie_epurare"]')
        await pg.check('input[name="q15"][value="nu_stiu"]')
        await pg.check('input[name="q16"][value="uleiuri_grasimi"]')
        await pg.check('input[name="q17"][value="greu"]')
        await pg.check('input[name="q18"][value="foarte"]')
        await asteapta(pg)
        await pg.click("#inainte_s3"); await asteapta(pg, 900)
        verifica(await pagina_activa(pg) == "s4", f"[{eticheta}] secțiunea 3 completă trece mai departe")

        # --- secțiunea 4
        vis = lambda: pg.is_visible("#bloc-q20")
        verifica(not await vis(), f"[{eticheta}] Q20 ascunsă înainte de răspunsul la Q19")
        await pg.check('input[name="q19"][value="da"]'); await asteapta(pg, 400)
        verifica(await vis(), f"[{eticheta}] Q20 apare când Q19 = Da")
        await pg.check('input[name="q20"][value="mirosuri"]')
        if q19 != "da":
            await pg.check(f'input[name="q19"][value="{q19}"]'); await asteapta(pg, 300)
            verifica(not await vis(), f"[{eticheta}] Q20 dispare când Q19 ≠ Da")
        for k, v in [("cetateni","5"),("operator","5"),("autoritati","4"),("producatori","3"),("control","4")]:
            await pg.click(f'input[name="q21_{k}"][value="{v}"]')
        await pg.check('input[name="q22"][value="informare"]')
        await pg.check('input[name="q23"][value="putin"]')
        await pg.check('input[name="q24"][value="auzit_nu_stiu"]')
        await pg.fill("#q25", "Mai multe puncte de colectare pentru ulei.")
        await asteapta(pg)
        await fara_derulare_orizontala(pg, eticheta, "secțiunea 4")
        await axe(pg, eticheta, "secțiunea 4")
        await pg.click("#inainte_s4"); await asteapta(pg, 1000)
        verifica(await pagina_activa(pg) == "revizuire", f"[{eticheta}] se ajunge la pagina de verificare")
        rev = await pg.text_content("#rezumat_revizuire")
        verifica("Apartament la bloc" in rev and "Etichetă „flushable”" in rev and "Toți au" not in rev, f"[{eticheta}] verificarea arată răspunsurile")
        await axe(pg, eticheta, "verificare")

        # --- Modifică din verificare
        await pg.click("#modifica_s1"); await asteapta(pg, 900)
        txt = (await pg.text_content("#inainte_s1")).strip()
        verifica(await pagina_activa(pg) == "s1" and txt == "Revino la verificare", f"[{eticheta}] „Modifică” deschide secțiunea 1, cu „Revino la verificare”")
        await pg.check('input[name="q04"][value="casa"]'); await asteapta(pg)
        await pg.click("#inainte_s1"); await asteapta(pg, 1000)
        verifica("Casă" in await pg.text_content("#rezumat_revizuire"), f"[{eticheta}] modificarea apare în verificare")

        # --- trimitere cu clickuri repetate
        inainte = nr_randuri()
        await pg.evaluate("""() => { const b = document.getElementById('trimite'); b.click(); b.click(); b.click(); }""")
        await asteapta(pg, 2000)
        dupa = nr_randuri()
        verifica(dupa - inainte == 1, f"[{eticheta}] trei clickuri pe „Trimite” salvează un singur rând ({inainte} -> {dupa})")
        r = ultimul_rand()
        verifica(len(r["submitted_at"]) == 10, f"[{eticheta}] data trimiterii fără oră ({r['submitted_at']})")
        verifica(r["varsta_minima_confirmata"] is None and r["q21_toti"] is None and r["q06_65_plus"] == 0 and r["q09_plante_altele"] == 5,
                 f"[{eticheta}] rândul salvat: vârstă confirmată, q21_toti gol, Q6 gol = 0")
        verifica(await pagina_activa(pg) == "final", f"[{eticheta}] se afișează pagina finală")
        await asteapta(pg, 1300)
        await pg.screenshot(path=os.path.join(OUT, f"{eticheta}_gata.png"))
        await pg.wait_for_selector("#grafic_q9 .main-svg", timeout=10000)
        prof = await pg.text_content("#profil")
        verifica("117" in prof and "litri pe persoană pe zi" in prof, f"[{eticheta}] estimarea litri/persoană/zi (14 m³, 4 pers. = 117)")
        verifica("Estimare aritmetică" in prof, f"[{eticheta}] estimarea are explicația de interpretare")
        html = await pg.content()
        prof_html = await pg.inner_html("#profil")
        verifica('id="c-q12"' not in prof_html and "c-obiceiuri" not in prof_html and "Pentru 1 din cele 8 obiecte" not in prof_html,
                 f"[{eticheta}] profilul nu mai are cardurile Q12 și Q10–Q11")
        verifica("tipareste" not in html, f"[{eticheta}] pagina finală nu are buton de tipărire/PDF")
        await pg.click("#spre-profil"); await asteapta(pg, 1200)
        y = await pg.evaluate("document.getElementById('f-profil').getBoundingClientRect().top")
        verifica(y < 250, f"[{eticheta}] „Vedeți profilul” duce la profil ({y:.0f}px)")
        await asteapta(pg, 600)
        await fara_derulare_orizontala(pg, eticheta, "pagina finală")
        await pg.screenshot(path=os.path.join(OUT, f"{eticheta}_final.png"), full_page=True)

        # --- harta
        await pg.wait_for_selector("#harta-constanta .leaflet-overlay-pane path", timeout=15000)
        await asteapta(pg, 600)
        await pg.wait_for_function("window.harta_cartiere && window.harta_cartiere()", timeout=15000)
        nr = await pg.evaluate("document.querySelectorAll('#harta-constanta .leaflet-overlay-pane path').length")
        nc = await pg.evaluate("(() => { let n = 0; window.harta_cartiere().eachLayer(() => n++); return n; })()")
        verifica(nr == 62 and nc == 42, f"[{eticheta}] harta desenează 20 de UAT-uri și cele 42 de cartiere ({nr}, {nc})")
        nota = await pg.text_content("#nota-limite-cartiere")
        verifica("orientative, nu oficiale" in nota and "HCL nr. 79/2023" in nota and "OpenStreetMap" in nota, f"[{eticheta}] sub hartă: limite orientative, sursa și OpenStreetMap")
        vl = await pg.text_content("#verificare-limita")
        verifica("în regulă" in vl, f"[{eticheta}] fișa arată verificarea limitei cu planul ({vl!r})")
        sub = await pg.text_content(".subsol")
        verifica("OpenStreetMap" in sub and "ODbL" in sub and "Chestionar anonim" in sub, f"[{eticheta}] subsolul are atribuirile și mențiunea de anonimat")
        atr = await pg.text_content("#harta-constanta .leaflet-control-attribution")
        verifica("ANCPI" in atr and "geoBoundaries" in atr, f"[{eticheta}] harta are atribuirea sursei")
        fisa = await pg.text_content("#c-cartier")
        verifica("Tomis Nord" in fisa and "nr. 35" in fisa, f"[{eticheta}] fișa cartierului din HCL 79/2023")
        harta_txt = await pg.text_content("#f-harta")
        verifica("Indicatorii pe cartiere nu sunt încă disponibili" in harta_txt if comparatie == "goala" else ("Vedeți valorile ca tabel" in harta_txt and "nu este încă disponibilă" not in harta_txt),
                 f"[{eticheta}] starea hărții tematice este explicată")
        verifica(len(pg.cereri_osm) == 0, f"[{eticheta}] fără cereri OpenStreetMap înainte de apăsarea butonului")
        # audit de anonimat: până aici (completare + trimitere + pagina finală)
        verifica(not pg.cereri_externe, f"[{eticheta}] nicio cerere către alt server decât aplicația {pg.cereri_externe[:3]}")
        cookies = await pg.ctx.cookies()
        verifica(not cookies, f"[{eticheta}] aplicația nu setează cookie-uri {cookies}")
        stocare = await pg.evaluate("[localStorage.length, sessionStorage.length]")
        verifica(stocare == [0, 0], f"[{eticheta}] nimic în localStorage/sessionStorage {stocare}")
        await pg.click("#harta-fundal-osm"); await asteapta(pg, 1500)
        verifica(len(pg.cereri_osm) > 0 and all("tile.openstreetmap.org" in u for u in pg.cereri_osm),
                 f"[{eticheta}] butonul cere plăcile OpenStreetMap ({len(pg.cereri_osm)} cereri)")
        await pg.click("#harta-fundal-osm"); await asteapta(pg, 300)

        # --- recomandări și comparație
        rec = await pg.text_content("#f-recomandari")
        verifica("Legat de răspunsul dvs." in rec and "Sursă" in rec and "Hadley" in rec, f"[{eticheta}] recomandările legate de răspunsuri au sursă")
        comp = await pg.text_content("#f-comparatie")
        if comparatie == "goala":
            verifica("Comparația nu este încă disponibilă" in comp and "%" not in comp, f"[{eticheta}] sub prag, comparația arată un mesaj, nu procente")
        else:
            carduri = await pg.evaluate("document.querySelectorAll('#f-comparatie .c-comparatie').length")
            verifica(carduri == 3, f"[{eticheta}] peste prag apar 3 comparații ({carduri})")
            sume = await pg.evaluate("""Array.from(document.querySelectorAll('#f-comparatie .c-comparatie')).map(c =>
                 Array.from(c.querySelectorAll('.bara-umplere2')).reduce((a, e) => a + parseFloat(e.style.width), 0))""")
            verifica(all(abs(x - 100) < 0.6 for x in sume), f"[{eticheta}] procentele fiecărei comparații însumează 100% ({sume})")
            tab = await pg.evaluate("document.querySelectorAll('#f-harta table.tabel-tematic').length")
            verifica(tab == 4, f"[{eticheta}] indicatorii au și 4 tabele, sub „Vedeți valorile ca tabel” ({tab})")
            await pg.click('label:has(input[value="q12_servetele"])'); await asteapta(pg, 300)
            vizibil = await pg.evaluate("""Array.from(document.querySelectorAll('.tabel-tematic-cutie')).filter(e => !e.hidden).map(e => e.dataset.indicator)""")
            verifica(vizibil == ["q12_servetele"], f"[{eticheta}] selectorul de indicator schimbă tabelul ({vizibil})")
        await axe(pg, eticheta, "pagina finală")

        # după trimitere, o nouă trimitere nu adaugă rânduri
        await pg.evaluate("Shiny.setInputValue('trimite', 999, {priority: 'event'})")
        await asteapta(pg, 800)
        verifica(nr_randuri() == dupa, f"[{eticheta}] o nouă trimitere în aceeași sesiune nu adaugă rânduri")
        verifica("desc_xlsx" not in html and "admin_tabel" not in html, f"[{eticheta}] pagina publică nu conține exporturi")
        verifica(not pg.erori_js, f"[{eticheta}] fără erori JavaScript {pg.erori_js}")
        await b.close()

# ---------------------------------------------------------------------------------------
async def miscare_redusa():
    async with async_playwright() as p:
        b, pg = await deschide(p, 1280, 900, reduced_motion="reduce")
        await pana_la_intrebari(pg)
        r = await pg.evaluate("""() => [getComputedStyle(document.getElementById('tranzitie')).display,
                                         getComputedStyle(document.querySelector('.tab-pane.active')).animationName,
                                         getComputedStyle(document.querySelector('.progres-umplere')).animationName]""")
        verifica(r == ["none", "none", "none"], f"[mișcare redusă] tranzițiile și animațiile sunt oprite {r}")
        await b.close()

# ---------------------------------------------------------------------------------------
def http_status(url):
    try:
        with urllib.request.urlopen(url, timeout=10) as r: return r.status, r.read()[:200]
    except urllib.error.HTTPError as e: return e.code, b""

async def securitate():
    for cale in ["data/raspunsuri_TEST.sqlite", "data/raspunsuri.sqlite", "config/informare_consimtamant.md", "app.R",
                 "R/00_config.R", ".Renviron", "tests/fixtures/cartiere_test_FALS.geojson", "../data/raspunsuri_TEST.sqlite",
                 "%2e%2e/app.R", "harta/../../app.R"]:
        st, _ = http_status(URL + cale)
        verifica(st == 404, f"[securitate] /{cale} nu este servit public ({st})")
    async with async_playwright() as p:
        b, pg = await deschide(p, 1280, 900)
        await pg.goto(URL + "?admin"); await asteapta(pg, 2000)
        html = await pg.content()
        verifica("Autentificare" in html and "admin_tabel" not in html, "[securitate] zona admin cere parola (fără ocolire pe localhost)")
        # descărcare directă fără autentificare
        for out in ["desc_xlsx", "desc_csv", "desc_sqlite", "desc_analiza"]:
            r = await pg.evaluate(f"""async () => {{ const id = Shiny.shinyapp.config.sessionId;
                 const r = await fetch('session/' + id + '/download/{out}?w='); const t = await r.text(); return [r.status, t.length, t.slice(0, 60)]; }}""")
            verifica(r[0] != 200 or r[1] < 100, f"[securitate] descărcarea {out} fără parolă nu întoarce date ({r[0]}, {r[1]} octeți)")
        # încercarea de a seta intrări din consolă nu deschide nimic
        await pg.evaluate("Shiny.setInputValue('admin_login', 1, {priority:'event'})"); await asteapta(pg, 800)
        verifica("admin_tabel" not in await pg.content(), "[securitate] login fără parolă din consolă este refuzat")
        await axe(pg, "admin", "autentificare")
        await b.close()

async def admin():
    async with async_playwright() as p:
        b, pg = await deschide(p, 1280, 900, accept_downloads=True)
        await pg.goto(URL + "?admin"); await asteapta(pg, 2000)
        await pg.fill("#admin_parola", "parola-gresita"); await pg.click("#admin_login"); await asteapta(pg, 800)
        verifica("admin_tabel" not in await pg.content(), "[admin] parola greșită este refuzată")
        await pg.fill("#admin_parola", PAROLA); await pg.click("#admin_login"); await asteapta(pg, 2500)
        html = await pg.content()
        verifica("răspunsuri în baza de date" in html, "[admin] parola corectă deschide zona admin")
        verifica("De rezolvat înainte de lansare" not in html, "[admin] niciun element blocant de configurare (parola setată, informarea completă)")
        await pg.screenshot(path=os.path.join(OUT, "admin.png"), full_page=True)
        await pg.click("a[data-value='Stare']"); await asteapta(pg, 1200)
        st = await pg.text_content("#admin_stare")
        # Pe SQLite, rândul „Găzduirea” rămâne „de verificat”; pe PostgreSQL, baza trebuie să fie scriibilă.
        verifica("Anonimat" in st and "Găzduirea" in st and "blochează lansarea" not in st and
                 (("Baza de date PostgreSQL poate fi scrisă" in st) if PG else ("de verificat" in st)),
                 "[admin] fila „Stare” arată verificările de configurare")
        await pg.screenshot(path=os.path.join(OUT, "admin_stare.png"), full_page=True)
        await pg.click("a[data-value='Grafice']"); await asteapta(pg, 1500)
        await pg.select_option("#admin_grafic", "q21"); await asteapta(pg, 2000)
        await pg.screenshot(path=os.path.join(OUT, "admin_grafic_q21.png"), full_page=True)
        await pg.click("a[data-value='Export']"); await asteapta(pg, 800)
        for idb, nume in [("desc_xlsx", "export_brut.xlsx"), ("desc_csv", "export_brut.csv"), ("desc_analiza", "export_analiza.xlsx")]:
            async with pg.expect_download() as d:
                await pg.click(f"#{idb}")
            dl = await d.value
            cale = os.path.join(OUT, nume); await dl.save_as(cale)
            verifica(os.path.getsize(cale) > 3000, f"[admin] {nume} se descarcă ({os.path.getsize(cale)} octeți)")
        verifica(open(os.path.join(OUT, "export_brut.csv"), encoding="utf-8-sig").readline().startswith('"response_id","submitted_at"'),
                 "[admin] exportul CSV are coloanele stabile")
        await axe(pg, "admin", "export")
        # selectize.min.js din pachetul Ubuntu r-cran-dt (legat din /usr/share/javascript) aruncă
        # „c.define is not a function” la încărcarea dinamică; eroarea nu vine din codul aplicației.
        alte = [e for e in pg.erori_js if "define is not a function" not in e]
        verifica(not alte, f"[admin] fără erori JavaScript din codul aplicației {alte} (ignorate: {len(pg.erori_js) - len(alte)} din selectize/Ubuntu)")
        await b.close()

# ---------------------------------------------------------------------------------------
async def harta_tematica():
    """Instanța cu poligoane FALSE (tests/fixtures) și ≥ 30 de răspunsuri."""
    global URL
    async with async_playwright() as p:
        for latime, inaltime, et in [(1280, 900, "hartă-desktop"), (390, 844, "hartă-telefon")]:
            b, pg = await deschide(p, latime, inaltime)
            vechi = URL; URL = URL_HARTA
            await pana_la_intrebari(pg)
            URL = vechi
            await pg.select_option("#q01", "tomis_nord")
            await pg.check('input[name="q02"][value="25_34"]'); await pg.check('input[name="q03"][value="universitar"]')
            await pg.check('input[name="q04"][value="casa"]'); await pg.fill("#q05", "1"); await pg.fill("#q06_25_34", "1")
            await pg.check('input[name="q07"][value="da"]'); await pg.click("#inainte_s1"); await asteapta(pg, 900)
            await pg.check("#q08_nu_stiu")
            await pg.fill("#q09_igiena", "100")
            await pg.check('input[name="q10"][value="nimic"]'); await pg.check('input[name="q11"][value="nu_stiu"]')
            for k in ["servetele_umede","prosoape_hartie","betisoare_dischete","igiena_menstruala","scutece","ata_par_obiecte","resturi_alimentare","medicamente"]:
                await pg.click(f'input[name="q12_{k}"][value="nu_am_aruncat"]')
            await pg.check('input[name="q13"][value="punct_colectare"]'); await pg.click("#inainte_s2"); await asteapta(pg, 900)
            for n, v in [("q14","statie_epurare"),("q15","nu_stiu"),("q17","greu"),("q18","foarte")]: await pg.check(f'input[name="{n}"][value="{v}"]')
            await pg.check('input[name="q16"][value="nu_stiu"]'); await pg.click("#inainte_s3"); await asteapta(pg, 900)
            await pg.check('input[name="q19"][value="nu"]')
            for k in ["cetateni","operator","autoritati","producatori","control"]: await pg.click(f'input[name="q21_{k}"][value="3"]')
            for n, v in [("q22","informare"),("q23","putin"),("q24","nu_am_auzit")]: await pg.check(f'input[name="{n}"][value="{v}"]')
            await pg.click("#inainte_s4"); await asteapta(pg, 1000); await pg.click("#trimite"); await asteapta(pg, 2500)
            await pg.wait_for_function("window.harta_cartiere && window.harta_cartiere()", timeout=15000)
            await asteapta(pg, 800)
            info = await pg.evaluate("""() => { const s = window.harta_cartiere(); const out = []; s.eachLayer(l => out.push([l.feature.properties.cod, l.options.fillColor, l._path.getAttribute('fill')])); return out; }""")
            verifica(len(info) == 42, f"[{et}] harta desenează 42 de poligoane (FALSE, de test) ({len(info)})")
            culori1 = sorted(set(c for _, c, _ in info))
            verifica(len(culori1) >= 2, f"[{et}] indicatorul „număr de respondenți” colorează cartierele ({culori1})")
            hasurate = sum(1 for _, _, f in info if f == "url(#hasura-suprimat)")
            verifica(hasurate > 0, f"[{et}] cartierele sub prag sunt hașurate ({hasurate})")
            ales = await pg.evaluate("""() => { let w = null; window.harta_cartiere().eachLayer(l => { if (l.feature.properties.cod === 'tomis_nord') w = l.options.weight; }); return w; }""")
            verifica(ales == 4, f"[{et}] cartierul respondentului are contur evidențiat ({ales})")
            await pg.evaluate("document.getElementById('f-harta').scrollIntoView()"); await asteapta(pg, 600)
            await pg.click('label:has(input[value="ulei_chiuveta"])'); await asteapta(pg, 600)
            info2 = await pg.evaluate("""() => { const out = []; window.harta_cartiere().eachLayer(l => out.push(l.options.fillColor)); return out; }""")
            verifica(info2 != [c for _, c, _ in info], f"[{et}] schimbarea indicatorului recolorează harta")
            tt = await pg.evaluate("""() => { let t = ''; window.harta_cartiere().eachLayer(l => { if (l.feature.properties.cod === 'tomis_nord') t = l.getTooltip().getContent(); }); return t; }""")
            verifica("Tomis Nord" in tt and ("%" in tt or "date insuficiente" in tt) and "cartierul dvs." in tt, f"[{et}] eticheta cartierului arată valoarea ({tt!r})")
            nota = await pg.text_content("#nota-limite-cartiere")
            verifica("orientative, nu oficiale" in nota and "DATE FALSE" in nota, f"[{et}] limitele sunt etichetate ca orientative ({nota!r})")
            leg = await pg.text_content(".legenda-indicator:not([hidden])")
            verifica("date insuficiente" in leg and "50–100%" in leg, f"[{et}] legenda arată clasele și „date insuficiente”")
            await pg.screenshot(path=os.path.join(OUT, f"{et}.png"))
            await fara_derulare_orizontala(pg, et, "harta tematică")
            await axe(pg, et, "harta tematică")
            verifica(not pg.erori_js, f"[{et}] fără erori JavaScript {pg.erori_js}")
            await b.close()

goleste_baza_test()
asyncio.run(acord())
asyncio.run(ruleaza(390, 844, "telefon"))
asyncio.run(ruleaza(1280, 900, "desktop", q19="nu_imi_amintesc"))
asyncio.run(miscare_redusa())
radacina = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
env = dict(os.environ, CHESTIONAR_DATA_DIR=os.path.dirname(os.path.abspath(DB)), CHESTIONAR_MOD="test")
subprocess.run(["Rscript", "scripts/genereaza_date_test.R"], cwd=radacina, check=True, env=env,
               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
asyncio.run(ruleaza(1280, 900, "desktop-comparatie", comparatie="plina"))
asyncio.run(securitate())
if PAROLA: asyncio.run(admin())
if URL_HARTA: asyncio.run(harta_tematica())
esec = [n for ok, n in rezultate if not ok]
print(f"\n{len(rezultate) - len(esec)} din {len(rezultate)} verificări trecute.")
for n in esec: print("EȘEC: " + n)
sys.exit(1 if esec else 0)
