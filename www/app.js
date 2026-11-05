/* =============================================================================
   app.js — comportamente în browser
   - opțiuni exclusive la selecțiile multiple (Q10, Q11, Q16)
   - „Nu știu” la Q8 golește și dezactivează câmpurile numerice
   - totaluri în timp real la Q6 și Q9 (câmpurile goale se socotesc 0)
   - câmpurile numerice invalide (de exemplu „12abc”) sunt raportate serverului,
     ca să nu fie confundate cu un câmp gol
   - mesaje de eroare lângă întrebări și sumar cu legături
   - progres (secțiune, întrebări, procent), tranziții între pagini,
     focalizarea titlului la schimbarea paginii
   - blocarea butonului de trimitere după primul click
   Validarea din R rămâne sursa de adevăr; aici este doar ajutor în interfață.
   ========================================================================== */
(function () {
  'use strict';

  var fmt = function (n) {
    return Number(n).toLocaleString('ro-RO', { maximumFractionDigits: 2 });
  };
  var num = function (el) {
    if (!el || el.value === '' || el.value === null) return NaN;
    return parseFloat(String(el.value).replace(',', '.'));
  };
  var faraMiscare = function () {
    return window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  };
  var modificat = false;
  var paginaCurenta = null;

  /* ---------- opțiuni exclusive (faza de captură: înainte ca Shiny să citească) */
  document.addEventListener('change', function (e) {
    var t = e.target;
    if (!t || t.type !== 'checkbox') return;
    var grp = t.closest('.shiny-input-checkboxgroup[data-exclusive]');
    if (!grp || !t.checked) return;
    var excl = [];
    try { excl = JSON.parse(grp.getAttribute('data-exclusive')) || []; } catch (err) { excl = []; }
    if (!excl.length) return;
    var boxes = grp.querySelectorAll('input[type=checkbox]');
    var debifate = [];
    boxes.forEach(function (b) {
      if (b === t) return;
      var trebuie = excl.indexOf(t.value) >= 0 ? true : excl.indexOf(b.value) >= 0;
      if (trebuie && b.checked) { b.checked = false; debifate.push(b.parentNode.textContent.trim()); }
    });
    if (debifate.length) {
      var st = grp.parentNode.querySelector('.anunt-exclusiv');
      if (!st) {
        st = document.createElement('p');
        st.className = 'anunt-exclusiv visually-hidden';
        st.setAttribute('aria-live', 'polite');
        grp.parentNode.insertBefore(st, grp.nextSibling);
      }
      st.textContent = 'Am debifat: ' + debifate.join(', ') + '.';
    }
  }, true);

  /* ---------- Q8: „Nu știu” */
  function sincronizeazaQ8() {
    var cb = document.getElementById('q08_nu_stiu');
    if (!cb) return;
    ['q08_rece', 'q08_calda'].forEach(function (id) {
      var el = document.getElementById(id);
      if (!el) return;
      if (cb.checked && el.value !== '') { el.value = ''; $(el).trigger('change'); }
      el.disabled = cb.checked;
      el.closest('.camp-numar').classList.toggle('dezactivat', cb.checked);
    });
    raporteazaInvalide();
  }
  $(document).on('change', '#q08_nu_stiu', sincronizeazaQ8);

  /* ---------- câmpuri numerice invalide
     Un <input type="number"> cu text nevalid are value === '' (ca un câmp gol),
     dar validity.badInput === true. Serverul primește lista acestor câmpuri și
     nu le tratează ca 0. */
  var ultimeleInvalide = '';
  function raporteazaInvalide() {
    var ids = [];
    document.querySelectorAll('.camp-numar input[type=number]').forEach(function (el) {
      if (!el.disabled && el.validity && el.validity.badInput) ids.push(el.id);
    });
    var cheie = ids.join('|');
    if (cheie === ultimeleInvalide) return;
    ultimeleInvalide = cheie;
    if (window.Shiny && Shiny.setInputValue) Shiny.setInputValue('campuri_invalide', ids);
  }
  $(document).on('input change blur', '.camp-numar input[type=number]', raporteazaInvalide);

  /* ---------- totaluri în timp real */
  function totalQ6() {
    var box = document.getElementById('q06-total');
    if (!box) return;
    var campuri = document.querySelectorAll('[id^="q06_"]');
    var invalid = false;
    var suma = 0;
    campuri.forEach(function (el) {
      if (el.validity && el.validity.badInput) { invalid = true; return; }
      var v = num(el);
      if (!isNaN(v)) suma += v;
    });
    var tinta = num(document.getElementById('q05'));
    var txt = 'Total: ' + fmt(suma) + (suma === 1 ? ' persoană' : ' persoane');
    var stare = '';
    if (invalid) {
      txt += '. Un câmp conține o valoare care nu este număr.';
      stare = 'peste';
    } else if (!isNaN(tinta)) {
      txt += ' din ' + fmt(tinta) + ' (întrebarea 5)';
      stare = suma === tinta ? 'ok' : (suma > tinta ? 'peste' : '');
    } else {
      txt += '. Completați întrebarea 5 pentru comparație.';
    }
    box.textContent = txt;
    box.setAttribute('data-stare', stare);
  }
  function totalQ9() {
    var box = document.getElementById('q09-total');
    if (!box) return;
    var vals = Array.prototype.map.call(document.querySelectorAll('[id^="q09_"]'), num);
    var suma = vals.filter(function (v) { return !isNaN(v); }).reduce(function (a, b) { return a + b; }, 0);
    suma = Math.round(suma * 100) / 100;
    var stare = Math.abs(suma - 100) <= 0.01 ? 'ok' : (suma > 100 ? 'peste' : '');
    box.querySelector('.text-total').textContent = 'Total: ' + fmt(suma) + '% din 100%' +
      (stare === 'ok' ? '' : (suma > 100 ? ' (cu ' + fmt(suma - 100) + ' peste)' : ' (mai sunt ' + fmt(100 - suma) + ')'));
    box.querySelector('.bara-umplere').style.width = Math.min(suma, 100) + '%';
    box.setAttribute('data-stare', stare);
  }
  $(document).on('input change', '#q05, [id^="q06_"]', totalQ6);
  $(document).on('input change', '[id^="q09_"]', totalQ9);

  /* ---------- Q25: contor de caractere */
  $(document).on('input', '#q25', function () {
    var c = document.getElementById('q25-contor');
    if (c) c.textContent = this.value.length + ' / ' + this.getAttribute('maxlength') + ' caractere';
  });

  /* ---------- rotița mouse-ului nu schimbă valorile numerice */
  document.addEventListener('wheel', function (e) {
    var a = document.activeElement;
    if (a && a.type === 'number' && e.target === a) a.blur();
  }, { passive: true });

  /* ---------- erori */
  function curataBloc(bloc) {
    bloc.classList.remove('q-cu-eroare');
    var e = bloc.querySelector('.q-eroare');
    if (e) e.textContent = '';
    bloc.querySelectorAll('[aria-invalid]').forEach(function (i) { i.removeAttribute('aria-invalid'); });
  }
  $(document).on('input change', '.q', function () {
    if (this.classList.contains('q-cu-eroare')) curataBloc(this);
  });

  function afiseazaErori(msg) {
    var sumar = document.getElementById(msg.sumar);
    if (!sumar) return;
    var pagina = sumar.closest('.tab-pane') || document;
    pagina.querySelectorAll('.q.q-cu-eroare').forEach(curataBloc);
    if (!msg.erori || !msg.erori.length) { sumar.hidden = true; sumar.innerHTML = ''; return; }

    var lista = document.createElement('ul');
    msg.erori.forEach(function (er) {
      var bloc = document.getElementById('bloc-' + er.id);
      if (bloc) {
        bloc.classList.add('q-cu-eroare');
        var box = document.getElementById('eroare-' + er.id);
        if (box) box.textContent = er.mesaj;
        bloc.querySelectorAll('input, select, textarea').forEach(function (i) {
          if (i.type !== 'hidden') i.setAttribute('aria-invalid', 'true');
        });
      }
      var li = document.createElement('li');
      var a = document.createElement('a');
      a.href = '#bloc-' + er.id;
      a.textContent = 'Întrebarea ' + er.nr + ' (' + er.titlu + '): ' + er.mesaj;
      a.addEventListener('click', function (ev) {
        ev.preventDefault();
        var b = document.getElementById('bloc-' + er.id);
        if (!b) return;
        b.scrollIntoView({ behavior: faraMiscare() ? 'auto' : 'smooth', block: 'start' });
        var primul = b.querySelector('input:not([type=hidden]):not(:disabled), select, textarea');
        if (primul) setTimeout(function () { primul.focus({ preventScroll: true }); }, 250);
      });
      li.appendChild(a);
      lista.appendChild(li);
    });
    sumar.innerHTML = '';
    var h = document.createElement('p');
    h.className = 'sumar-titlu';
    h.textContent = msg.erori.length === 1
      ? 'O întrebare are nevoie de atenție:'
      : msg.erori.length + ' întrebări au nevoie de atenție:';
    sumar.appendChild(h);
    sumar.appendChild(lista);
    sumar.hidden = false;
    if (!faraMiscare()) { sumar.classList.remove('tremur'); void sumar.offsetWidth; sumar.classList.add('tremur'); }
    sumar.scrollIntoView({ behavior: faraMiscare() ? 'auto' : 'smooth', block: 'start' });
    setTimeout(function () { sumar.focus({ preventScroll: true }); }, 200);
  }

  /* ---------- erorile de pe pagina de informare (vârstă, acord) */
  var focusConditii = null;
  function eroareSimpla(msg) {
    var el = document.getElementById(msg.id);
    if (!el) return;
    el.textContent = msg.mesaj;
    var bloc = el.closest('.eligibilitate, .consimtamant');
    if (bloc) bloc.classList.toggle('q-cu-eroare', !!msg.mesaj);
    // Mesajele vin unul după altul; focalizăm primul câmp cu eroare.
    clearTimeout(focusConditii);
    focusConditii = setTimeout(function () {
      var primul = document.querySelector('.conditii .q-cu-eroare');
      if (!primul) return;
      var tinta = primul.querySelector('input:checked') || primul.querySelector('input');
      if (tinta) tinta.focus();
    }, 30);
  }

  /* ---------- tranziția dintre pagini (doar decorativă) */
  function tranzitie(dinspre, spre) {
    var t = document.getElementById('tranzitie');
    if (!t || faraMiscare() || !dinspre || dinspre === spre) return;
    t.setAttribute('data-spre', spre === 'final' ? 'final' : 'pagina');
    t.classList.remove('activ');
    void t.offsetWidth;
    t.classList.add('activ');
  }

  /* ---------- navigare și progres */
  function schimbaPagina(msg) {
    var anterioara = paginaCurenta;
    paginaCurenta = msg.nume;
    document.body.setAttribute('data-pagina', msg.nume);
    modificat = !!msg.modificat;
    tranzitie(anterioara, msg.nume);

    var nav = document.getElementById('progres');
    if (nav) {
      var pas = msg.pas || 0;
      nav.querySelectorAll('.pas').forEach(function (li) {
        var p = parseInt(li.getAttribute('data-pas'), 10);
        li.classList.toggle('gata', p < pas);
        li.classList.toggle('curent', p === pas);
        if (p === pas) li.setAttribute('aria-current', 'step'); else li.removeAttribute('aria-current');
      });
      // Procentul = întrebările din secțiunile deja parcurse (din 25).
      var procent = 0, stare = '';
      if (pas >= 1 && pas <= 4 && msg.intrebari) {
        procent = Math.round((msg.intrebari[0] - 1) / 25 * 100);
        stare = 'Secțiunea ' + pas + ' din 4: ' + msg.titlu + '. Întrebările ' + msg.intrebari[0] +
          '–' + msg.intrebari[1] + ' din 25.';
      } else if (pas === 5) {
        procent = 100;
        stare = 'Verificarea răspunsurilor. Toate cele 25 de întrebări au fost parcurse.';
      }
      var bara = nav.querySelector('.progres-bara');
      bara.setAttribute('aria-valuemin', '0');
      bara.setAttribute('aria-valuemax', '100');
      bara.setAttribute('aria-valuenow', String(procent));
      bara.setAttribute('aria-valuetext', procent + '% parcurs. ' + stare);
      nav.querySelector('.progres-umplere').style.width = procent + '%';
      var st = document.getElementById('progres-stare');
      if (st) st.textContent = stare;
      var pr = document.getElementById('progres-procent');
      if (pr) pr.textContent = pas > 0 ? procent + '%' : '';
    }

    document.querySelectorAll('.btn-inainte').forEach(function (b) {
      var t = msg.din_revizuire ? b.getAttribute('data-text-revizuire') : b.getAttribute('data-text-normal');
      if (t) b.textContent = t;
    });

    setTimeout(function () {
      window.scrollTo({ top: 0, behavior: 'auto' });
      var h = document.getElementById('titlu-' + msg.nume);
      if (h) h.focus({ preventScroll: true });
      totalQ6(); totalQ9(); sincronizeazaQ8();
    }, 60);
  }

  /* ---------- trimitere */
  $(document).on('click', '#trimite', function () {
    var b = this;
    setTimeout(function () {
      b.disabled = true;
      b.setAttribute('aria-busy', 'true');
      b.textContent = b.getAttribute('data-text-incarcare');
    }, 0);
    var er = document.getElementById('eroare-trimitere');
    if (er) { er.hidden = true; er.textContent = ''; }
  });

  function stareTrimitere(msg) {
    var b = document.getElementById('trimite');
    if (msg.stare === 'gata') { modificat = false; return; }
    if (b) {
      b.disabled = false;
      b.removeAttribute('aria-busy');
      b.textContent = b.getAttribute('data-text-normal');
    }
    if (msg.stare === 'eroare') {
      var er = document.getElementById('eroare-trimitere');
      if (er) { er.textContent = msg.mesaj; er.hidden = false; er.focus && er.focus(); }
    }
  }

  /* ---------- pagina finală: legăturile interne (cuprins, „Vedeți profilul”) */
  $(document).on('click', 'a[href^="#f-"]', function (e) {
    var tinta = document.getElementById(this.getAttribute('href').slice(1));
    if (!tinta) return;
    e.preventDefault();
    tinta.scrollIntoView({ behavior: faraMiscare() ? 'auto' : 'smooth', block: 'start' });
    var h = tinta.querySelector('h2');
    if (h) {
      if (!h.hasAttribute('tabindex')) h.setAttribute('tabindex', '-1');
      setTimeout(function () { h.focus({ preventScroll: true }); }, faraMiscare() ? 0 : 450);
    }
  });

  window.addEventListener('beforeunload', function (e) {
    if (!modificat) return;
    e.preventDefault();
    e.returnValue = '';
  });

  $(document).on('shiny:connected', function () {
    Shiny.addCustomMessageHandler('pagina', schimbaPagina);
    Shiny.addCustomMessageHandler('erori', afiseazaErori);
    Shiny.addCustomMessageHandler('trimitere', stareTrimitere);
    Shiny.addCustomMessageHandler('eroare-simpla', eroareSimpla);
    Shiny.setInputValue('campuri_invalide', []);
    if (!paginaCurenta) paginaCurenta = document.body.getAttribute('data-pagina') || 'acasa';
  });

  document.addEventListener('DOMContentLoaded', function () {
    if (!document.body.getAttribute('data-pagina')) document.body.setAttribute('data-pagina', 'acasa');
  });
})();
