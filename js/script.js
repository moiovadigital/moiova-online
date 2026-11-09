/* moiova Digital — JS da página (carregado com defer no fim do index.html)
   Só o essencial: barra de progresso, voltar ao topo, menu hambúrguer e a
   luz que segue o mouse nos cards. Nada aqui bloqueia a primeira tela. */
(function(){
  'use strict';
  var doc = document.documentElement;

  /* --- barra de progresso (síncrono, sem requestAnimationFrame) --- */
  var barra = document.getElementById('progresso');
  function progresso(){
    var max = (doc.scrollHeight - doc.clientHeight) || 1;
    var y = window.pageYOffset || doc.scrollTop || 0;
    barra.style.transform = 'scaleX(' + Math.min(1, Math.max(0, y / max)) + ')';
  }

  /* --- voltar ao topo: aparece depois de 400px --- */
  var topo = document.getElementById('voltar-topo');
  function estadoTopo(){
    var y = window.pageYOffset || doc.scrollTop || 0;
    topo.hidden = y <= 400;
  }
  topo.addEventListener('click', function(){
    window.scrollTo(0, 0);
    var marca = document.querySelector('.logo');
    if (marca && marca.focus) { try { marca.focus({ preventScroll: true }); } catch (e) {} }
  });

  window.addEventListener('scroll', function(){ progresso(); estadoTopo(); }, { passive: true });
  window.addEventListener('resize', progresso);
  progresso(); estadoTopo();

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

  /* --- luz que segue o mouse nos cards --- */
  var luz = document.querySelectorAll('.card-inner');
  for (var i = 0; i < luz.length; i++){
    (function(el){
      el.addEventListener('pointermove', function(e){
        var r = el.getBoundingClientRect();
        el.style.setProperty('--mx', (e.clientX - r.left) + 'px');
        el.style.setProperty('--my', (e.clientY - r.top) + 'px');
      });
      el.addEventListener('pointerleave', function(){
        el.style.removeProperty('--mx');
        el.style.removeProperty('--my');
      });
    })(luz[i]);
  }
})();
