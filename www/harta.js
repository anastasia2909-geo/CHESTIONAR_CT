/* =============================================================================
   harta.js — harta din pagina finală (Leaflet 1.9.4, inclus local în www/lib)
   Date: limitele UAT din www/harta/uat.geojson (ANCPI prin geoBoundaries).
   Fundalul OpenStreetMap se încarcă numai la cererea respondentului.

   Harta tematică: dacă există un fișier vectorial cu limitele cartierelor
   (proprietatea „cod”, aceleași coduri ca la Q1) și indicatorii sunt activi
   (peste pragul minim de completări), cartierele sunt colorate după
   indicatorul ales. Valorile vin calculate de pe server (R/12_indicatori.R);
   aici nu se calculează nimic. Cartierele sub prag sunt hașurate, fără valoare.

   Selectorul de indicator schimbă și tabelul, descrierea și legenda din
   pagină, chiar dacă harta pe cartiere lipsește.
   ========================================================================== */
(function () {
  'use strict';

  var CUL = {
    constanta: '#2F5F86', constantaContur: '#0D1F45',
    vecin: '#ECE3D2', vecinContur: '#B9AC94',
    cartier: '#C9D6E6', ales: '#B8892B', mare: '#CFDCE8'
  };
  var mesaj = null, harta = null, stratOsm = null, stratUat = null, stratCartiere = null;
  var limiteConstanta = null, cuFundal = false, indicatorCurent = null;

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text) e.textContent = text;
    return e;
  }

  function stilUat(f) {
    var c = f.properties.constanta === true;
    var tematic = !!stratCartiere;
    // Cu cartiere, restul teritoriului municipiului (lac, terenuri din afara
    // cartierelor) rămâne uscat deschis la culoare, nu albastru ca marea.
    if (c && tematic) return { color: CUL.constantaContur, weight: 2, fillColor: '#E4DCCB', fillOpacity: cuFundal ? 0 : 1 };
    if (c) return { color: CUL.constantaContur, weight: 2, fillColor: CUL.constanta,
                    fillOpacity: cuFundal ? 0.15 : 0.5 };
    return { color: CUL.vecinContur, weight: 1, fillColor: CUL.vecin, fillOpacity: cuFundal ? 0.08 : 1 };
  }

  /* ---------- indicatori ---------- */
  function datele(id) {
    if (!mesaj || !mesaj.tematic) return null;
    var ind = null;
    mesaj.tematic.indicatori.forEach(function (i) { if (i.id === id) ind = i; });
    if (!ind) return null;
    if (!ind._dupaCod) {
      ind._dupaCod = {};
      ind.valori.forEach(function (v) { ind._dupaCod[v.cod] = v; });
    }
    return ind;
  }

  function culoare(v) {
    var t = mesaj.tematic;
    if (!v || v.stare === 'zero' || v.stare === 'fara_date') return t.fara_date;
    if (v.stare === 'suprimat') return t.suprimat;
    return t.paleta[(v.clasa || 1) - 1];
  }

  function stilCartier(f) {
    var cod = f.properties.cod;
    var ales = mesaj.cod_ales && cod === mesaj.cod_ales;
    var ind = indicatorCurent && datele(indicatorCurent);
    if (!ind) {
      return ales ? { color: '#5E4410', weight: 3.5, fillColor: CUL.ales, fillOpacity: 0.55 }
                  : { color: CUL.constantaContur, weight: 1, fillColor: CUL.cartier, fillOpacity: cuFundal ? 0.2 : 0.6 };
    }
    var v = ind._dupaCod[cod];
    return {
      color: ales ? '#B8892B' : '#FFFBF3', weight: ales ? 4 : 1.2, opacity: 1,
      fillColor: culoare(v), fillOpacity: cuFundal ? 0.75 : 1
    };
  }

  // Hașura pentru „date insuficiente” (un model SVG adăugat în harta Leaflet).
  function asiguraHasura() {
    var svg = harta && harta.getPanes().overlayPane.querySelector('svg');
    if (!svg || svg.querySelector('#hasura-suprimat')) return;
    var ns = 'http://www.w3.org/2000/svg';
    var defs = document.createElementNS(ns, 'defs');
    var pat = document.createElementNS(ns, 'pattern');
    pat.setAttribute('id', 'hasura-suprimat');
    pat.setAttribute('patternUnits', 'userSpaceOnUse');
    pat.setAttribute('width', '8'); pat.setAttribute('height', '8');
    pat.setAttribute('patternTransform', 'rotate(45)');
    var r = document.createElementNS(ns, 'rect');
    r.setAttribute('width', '8'); r.setAttribute('height', '8');
    r.setAttribute('fill', mesaj.tematic ? mesaj.tematic.suprimat : '#D9D3C6');
    var l = document.createElementNS(ns, 'line');
    l.setAttribute('x1', '0'); l.setAttribute('y1', '0'); l.setAttribute('x2', '0'); l.setAttribute('y2', '8');
    l.setAttribute('stroke', '#8C8472'); l.setAttribute('stroke-width', '2');
    pat.appendChild(r); pat.appendChild(l); defs.appendChild(pat);
    svg.insertBefore(defs, svg.firstChild);
  }

  function aplicaHasura() {
    if (!stratCartiere) return;
    var ind = indicatorCurent && datele(indicatorCurent);
    asiguraHasura();
    stratCartiere.eachLayer(function (layer) {
      var v = ind && ind._dupaCod[layer.feature.properties.cod];
      if (layer._path && v && v.stare === 'suprimat') layer._path.setAttribute('fill', 'url(#hasura-suprimat)');
    });
  }

  function textCartier(f) {
    var cod = f.properties.cod;
    var ind = indicatorCurent && datele(indicatorCurent);
    var nume = f.properties.denumire || cod;
    var v = ind && ind._dupaCod[cod];
    if (v) nume = v.denumire || nume;
    var txt = nume + (ind && v ? ': ' + v.eticheta : '');
    if (mesaj.cod_ales && cod === mesaj.cod_ales) txt += ' (cartierul dvs.)';
    return txt;
  }

  function redeseneaza() {
    if (!stratCartiere) return;
    stratCartiere.setStyle(stilCartier);
    stratCartiere.eachLayer(function (layer) {
      layer.setTooltipContent(textCartier(layer.feature));
      if (mesaj.cod_ales && layer.feature.properties.cod === mesaj.cod_ales) layer.bringToFront();
    });
    aplicaHasura();
  }

  /* ---------- selectorul de indicator (hartă + tabel + legendă) */
  function alegeIndicator(id) {
    indicatorCurent = id;
    document.querySelectorAll('[data-indicator]').forEach(function (n) {
      if (n.closest('#selector-indicator') && n.tagName === 'P') { n.hidden = n.getAttribute('data-indicator') !== id; return; }
      if (n.classList.contains('tabel-tematic')) return;   // tabelul este în cutia lui
      n.hidden = n.getAttribute('data-indicator') !== id;
    });
    redeseneaza();
    var det = document.getElementById('harta-detalii');
    var ind = datele(id);
    if (det && ind) det.textContent = 'Indicator afișat: ' + ind.titlu + ' (' + ind.unitate + ').';
  }
  document.addEventListener('change', function (e) {
    if (e.target && e.target.name === 'indicator_harta') alegeIndicator(e.target.value);
  });

  function legenda(arataCartiere, arataAles) {
    var c = L.control({ position: 'topright' });
    c.onAdd = function () {
      var d = el('div', 'harta-legenda');
      d.setAttribute('aria-label', 'Legenda hărții');
      var rand = function (cls, text) {
        var r = el('div', 'leg-rand');
        r.appendChild(el('span', 'leg-mostra ' + cls));
        r.appendChild(el('span', '', text));
        d.appendChild(r);
      };
      if (!arataCartiere) rand('leg-constanta', 'Municipiul Constanța');
      rand('leg-vecin', 'Localități vecine');
      if (arataCartiere && !mesaj.tematic) rand('leg-cartier', 'Cartiere');
      if (arataCartiere && mesaj.tematic) rand('leg-tematic', 'Cartiere: culorile din legenda de sub hartă');
      if (arataCartiere) rand('leg-rest', 'Municipiul, în afara cartierelor (port, lacuri, terenuri)');
      if (arataAles) rand('leg-ales', 'Cartierul ales de dumneavoastră');
      rand('leg-mare', 'Marea Neagră');
      return d;
    };
    return c;
  }

  function eroare(container, text) {
    container.innerHTML = '';
    container.appendChild(el('p', 'harta-eroare', text));
  }

  function adaugaCartiere(cg) {
    if (!cg || cg.type !== 'FeatureCollection') { legenda(false, false).addTo(harta); return; }
    var ales = null;
    if (mesaj.tematic) {
      var r = document.querySelector('input[name="indicator_harta"]:checked');
      indicatorCurent = r ? r.value : mesaj.tematic.indicatori[0].id;
    }
    stratCartiere = L.geoJSON(cg, {
      filter: function (f) { return f.properties && f.properties.cod; },
      style: stilCartier,
      onEachFeature: function (f, layer) {
        layer.bindTooltip(textCartier(f), { sticky: true, className: 'eticheta-cartier' });
        layer.on('click', function () {
          var det = document.getElementById('harta-detalii');
          if (det) det.textContent = textCartier(layer.feature);
        });
        if (mesaj.cod_ales && f.properties.cod === mesaj.cod_ales) ales = layer;
      }
    }).addTo(harta);
    if (stratUat) stratUat.setStyle(stilUat);
    harta.attributionControl.addAttribution('Cartiere: HCL nr. 79/2023, desenate pe date <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noopener">© OpenStreetMap</a> (ODbL)');
    legenda(true, !!ales).addTo(harta);
    aplicaHasura();
    harta.on('zoomend moveend', aplicaHasura);
    if (ales) ales.bringToFront();
    harta.fitBounds(stratCartiere.getBounds(), { padding: [16, 16] });
    document.getElementById('harta-constanta').classList.add('cu-cartiere');
  }

  function initializeaza() {
    var container = document.getElementById('harta-constanta');
    if (!mesaj || !container || harta || typeof L === 'undefined') return;
    if (!container.offsetWidth) { setTimeout(initializeaza, 150); return; }
    container.innerHTML = '';

    harta = L.map(container, {
      zoomSnap: 0.25, minZoom: 9.5, maxZoom: 17,
      maxBounds: L.latLngBounds([43.98, 28.30], [44.42, 28.85]), maxBoundsViscosity: 1,
      scrollWheelZoom: false,                 // derularea paginii nu mută harta
      dragging: !L.Browser.mobile, tap: false, // pe telefon: butoanele +/−
      attributionControl: true
    });
    harta.attributionControl.setPrefix(false);
    container.style.background = CUL.mare;

    fetch(mesaj.uat).then(function (r) {
      if (!r.ok) throw new Error('HTTP ' + r.status);
      return r.json();
    }).then(function (geo) {
      var strat = stratUat = L.geoJSON(geo, {
        style: stilUat,
        onEachFeature: function (f, layer) {
          var c = f.properties.constanta === true;
          layer.bindTooltip(f.properties.nume, {
            permanent: !c || !(mesaj.cartiere || mesaj.cartiere_geo), direction: 'center',
            className: c ? 'eticheta-uat eticheta-constanta' : 'eticheta-uat'
          });
          if (c) limiteConstanta = layer.getBounds();
        }
      }).addTo(harta);
      harta.attributionControl.addAttribution(
        '<a href="' + mesaj.sursa_uat_url + '" target="_blank" rel="noopener">' + mesaj.sursa_uat + '</a>');
      harta.fitBounds(limiteConstanta || strat.getBounds(), { padding: [12, 12] });

      var butonReset = L.control({ position: 'topleft' });
      butonReset.onAdd = function () {
        var b = el('button', 'harta-reset', 'Constanța');
        b.type = 'button';
        b.title = 'Recentrează harta pe municipiul Constanța';
        b.setAttribute('aria-label', 'Recentrează harta pe municipiul Constanța');
        L.DomEvent.disableClickPropagation(b);
        b.addEventListener('click', function () { harta.fitBounds(limiteConstanta, { padding: [12, 12] }); });
        return b;
      };
      butonReset.addTo(harta);

      if (mesaj.cartiere_geo) {
        var cg = null;
        try { cg = JSON.parse(mesaj.cartiere_geo); } catch (err) { cg = null; }
        adaugaCartiere(cg);
        return;
      }
      if (!mesaj.cartiere) { legenda(false, false).addTo(harta); return; }
      return fetch(mesaj.cartiere).then(function (r) { return r.ok ? r.json() : null; }).then(adaugaCartiere);
    }).catch(function () {
      eroare(container, 'Harta nu a putut fi încărcată. Restul paginii nu este afectat.');
      harta = null;
    });
  }

  // fundal OpenStreetMap, la cerere
  document.addEventListener('click', function (e) {
    var b = e.target.closest && e.target.closest('#harta-fundal-osm');
    if (!b || !harta) return;
    if (!stratOsm) {
      stratOsm = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19, attribution: '&copy; <a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noopener">contribuitorii OpenStreetMap</a>'
      });
    }
    var activ = harta.hasLayer(stratOsm);
    if (activ) { harta.removeLayer(stratOsm); }
    else { stratOsm.addTo(harta); stratOsm.bringToBack(); }
    cuFundal = !activ;
    if (stratUat) stratUat.setStyle(stilUat);
    redeseneaza();
    b.setAttribute('aria-pressed', activ ? 'false' : 'true');
    b.textContent = activ ? 'Afișează fundalul OpenStreetMap' : 'Ascunde fundalul OpenStreetMap';
    document.getElementById('harta-constanta').classList.toggle('cu-fundal', !activ);
  });

  $(document).on('shiny:connected', function () {
    Shiny.addCustomMessageHandler('harta', function (m) { mesaj = m; setTimeout(initializeaza, 50); });
  });
  $(document).on('shiny:value', function (e) {
    if (e.name === 'profil') setTimeout(initializeaza, 120);
  });
  window.harta_constanta = function () { return harta; };   // pentru teste
  window.harta_cartiere = function () { return stratCartiere; };
})();
