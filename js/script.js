/* moiova Digital — JS da página (carregado com defer no fim do index.html)
   Só o essencial: barra de progresso, voltar ao topo, menu hambúrguer e a
   luz que segue o mouse nos cards. Nada aqui bloqueia a primeira tela.

   Antipadrão corrigido (PageSpeed: "Reflow forçado"):
   antes, cada scroll rodava progresso() = LER layout -> ESCREVER style, e logo
   em seguida estadoTopo() = LER layout de novo -> ESCREVER. Ler depois de
   escrever no mesmo tick força o navegador a recalcular o layout na hora.
   Agora: TODAS as leituras vêm primeiro, TODAS as escritas depois, e o
   trabalho fica agendado em requestAnimationFrame (uma vez por frame, no
   máximo). */
(function(){
  'use strict';
  var doc = document.documentElement;

  /* --- barra de progresso + voltar ao topo (lê tudo, escreve tudo) --- */
  var barra = document.getElementById('progresso');
  var topo = document.getElementById('voltar-topo');
  var pendente = false;

  function atualizar(){
    var max = (doc.scrollHeight - doc.clientHeight) || 1;
    var y = window.pageYOffset || doc.scrollTop || 0;
    var frac = Math.min(1, Math.max(0, y / max));
    /* só a partir daqui a página é invalidada — nada é lido depois destas linhas */
    barra.style.transform = 'scaleX(' + frac + ')';
    topo.hidden = y <= 400;
  }

  function agendar(){
    if (pendente) return;
    pendente = true;
    requestAnimationFrame(function(){ pendente = false; atualizar(); });
  }

  topo.addEventListener('click', function(){
    window.scrollTo(0, 0);
    var marca = document.querySelector('.logo');
    if (marca && marca.focus) { try { marca.focus({ preventScroll: true }); } catch (e) {} }
  });

  window.addEventListener('scroll', agendar, { passive: true });
  window.addEventListener('resize', agendar);
  atualizar();

  /* --- hambúrguer (≤980px): aria-expanded, Esc fecha, fecha ao escolher um link,
         e fecha sozinho se a janela voltar para o desktop --- */
  var burger = document.querySelector('.burger');
  var menu = document.getElementById('menu-principal');
  if (burger && menu) {
    var fecharMenu = function (devolverFoco) {
      menu.classList.remove('aberto');
      burger.setAttribute('aria-expanded', 'false');
      burger.setAttribute('aria-label', 'Abrir menu');
      if (devolverFoco) burger.focus();
    };
    burger.addEventListener('click', function () {
      var aberto = menu.classList.toggle('aberto');
      burger.setAttribute('aria-expanded', aberto ? 'true' : 'false');
      burger.setAttribute('aria-label', aberto ? 'Fechar menu' : 'Abrir menu');
    });
    menu.addEventListener('click', function (e) {
      if (e.target && e.target.tagName === 'A') fecharMenu(false);
    });
    document.addEventListener('keydown', function (e) {
      if ((e.key === 'Escape' || e.keyCode === 27) && menu.classList.contains('aberto')) fecharMenu(true);
    });
    window.addEventListener('resize', function () {
      if (window.innerWidth > 980) fecharMenu(false);
    });
  }

  /* --- luz que segue o mouse nos cards ---
         getBoundingClientRect() a cada pointermove é leitura de layout em
         alta frequência (o outro foco do "Reflow forçado"). Mede uma vez ao
         entrar no card e reaproveita: pointermove só escreve variáveis. */
  var luz = document.querySelectorAll('.card-inner');
  for (var i = 0; i < luz.length; i++){
    (function(el){
      var ret = null;
      var luzPendente = false;
      var cx = 0, cy = 0;

      function medir(){ ret = el.getBoundingClientRect(); }

      function aplicar(){
        luzPendente = false;
        if (!ret) return;
        /* relativo ao card (não à viewport) — é o que o radial-gradient pede */
        el.style.setProperty('--mx', (cx - ret.left) + 'px');
        el.style.setProperty('--my', (cy - ret.top) + 'px');
      }

      el.addEventListener('pointerenter', medir);
      el.addEventListener('pointermove', function(e){
        cx = e.clientX; cy = e.clientY;
        if (!ret) medir();
        if (luzPendente) return;
        luzPendente = true;
        requestAnimationFrame(aplicar);
      });
      el.addEventListener('pointerleave', function(){
        ret = null;
        el.style.removeProperty('--mx');
        el.style.removeProperty('--my');
      });
      /* rolagem/janela mudam a posição do card na tela */
      window.addEventListener('scroll', function(){ if (ret) medir(); }, { passive: true });
      window.addEventListener('resize', function(){ if (ret) medir(); });
    })(luz[i]);
  }
})();
