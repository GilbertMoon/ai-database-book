(() => {
  'use strict';

  const CHANNEL = 'chapter10-presentation-sync';
  const ASSET_VERSION = '20260808a';
  const app = document.getElementById('app');
  if (!app) return;

  const block = document.body?.dataset?.chapter10Block === 'practice' ? 'practice' : 'theory';
  const blockLabel = block === 'practice' ? '실습' : '이론';
  const navigation = window.CH10Navigation;
  const icon = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3h9l3 3v15H6z"/><path d="M15 3v4h4M9 11h6M9 15h6"/></svg>';
  let slides = [];
  let slideIndex = 0;
  let stepIndex = 0;
  let scriptWindow = null;
  let booted = false;

  function parseHash() {
    const raw = location.hash.slice(1);
    if (!raw) return { slideIndex: 0, stepIndex: 0 };
    if (/^\d+$/.test(raw)) return { slideIndex: Math.max(0, Number(raw) - 1), stepIndex: 0 };
    const [hashBlock, slide, step] = raw.split('/');
    if (hashBlock && hashBlock !== block) return { slideIndex: 0, stepIndex: 0 };
    return { slideIndex: Math.max(0, (Number(slide) || 1) - 1), stepIndex: Math.max(0, Number(step) || 0) };
  }

  const stepsFor = (index = slideIndex) => navigation
    ? navigation.buildSteps(slides[index], index, block)
    : [{ text: String(slides[index]?.s || ''), focusKeys: [] }];
  const maxStep = (index = slideIndex) => Math.max(1, stepsFor(index).length);

  function applyFocus() {
    const root = app.querySelector('.body');
    if (!root) return;
    if (navigation) navigation.applyFocus(root, slides[slideIndex], slideIndex, stepIndex, block);
    const state = document.getElementById('state');
    if (state) state.textContent = stepIndex === 0 ? '전체 보기' : `강조 ${stepIndex} / ${maxStep()}`;
  }

  function updateButtons() {
    const previousButton = document.getElementById('previousButton');
    const nextButton = document.getElementById('nextButton');
    if (previousButton) previousButton.disabled = slideIndex === 0 && stepIndex === 0;
    if (nextButton) nextButton.disabled = slideIndex === slides.length - 1 && stepIndex === maxStep();
  }

  function render() {
    const slide = slides[slideIndex];
    if (!slide) return;
    app.innerHTML = `<section class="slide"><div class="head"><span class="k">${slide.k || ''}</span><div class="head-actions"><span class="l">${slide.l || blockLabel}</span><span class="counter">${String(slideIndex + 1).padStart(2, '0')} / ${String(slides.length).padStart(2, '0')}</span><button class="script-icon" id="scriptButton" type="button" title="발표 스크립트 열기" aria-label="현재 슬라이드 발표 스크립트 창 열기">${icon}</button></div></div><div class="body">${slide.h || ''}</div></section><a class="home" href="index.html">목차</a><div class="num">Chapter 10 · ${blockLabel}</div><div class="step-state" id="state" aria-live="polite"></div><nav class="ctrl"><button class="btn" id="previousButton" aria-label="이전 강조 또는 슬라이드">←</button><button class="btn" id="nextButton" aria-label="다음 강조 또는 슬라이드">→</button></nav><div class="track"><div class="bar" style="width:${((slideIndex + 1) / slides.length) * 100}%"></div></div>`;
    document.getElementById('previousButton').onclick = previous;
    document.getElementById('nextButton').onclick = next;
    document.getElementById('scriptButton').onclick = (event) => { event.stopPropagation(); openScript(); };
    applyFocus();
    updateButtons();
    history.replaceState(null, '', `#${block}/${slideIndex + 1}/${stepIndex}`);
    document.title = `${slideIndex + 1}/${slides.length} · ${window.CH10_TITLE || `Chapter 10 ${blockLabel} 강의`}`;
  }

  function sendStateToScript() {
    if (!scriptWindow || scriptWindow.closed) return;
    try {
      scriptWindow.postMessage({ channel: CHANNEL, type: 'presentation-state', block, slideIndex, stepIndex }, '*');
    } catch (error) {
      try { scriptWindow.setScriptState?.(block, slideIndex, stepIndex); } catch (ignore) {}
    }
  }

  function showState(newSlide, newStep = 0, { notifyChild = true } = {}) {
    if (!slides.length) return;
    slideIndex = Math.max(0, Math.min(slides.length - 1, Number(newSlide) || 0));
    stepIndex = Math.max(0, Math.min(maxStep(slideIndex), Number(newStep) || 0));
    render();
    if (notifyChild) sendStateToScript();
  }

  function next() {
    if (!booted) return;
    if (stepIndex < maxStep()) showState(slideIndex, stepIndex + 1);
    else if (slideIndex < slides.length - 1) showState(slideIndex + 1, 0);
  }

  function previous() {
    if (!booted) return;
    if (stepIndex > 0) showState(slideIndex, stepIndex - 1);
    else if (slideIndex > 0) showState(slideIndex - 1, maxStep(slideIndex - 1));
  }

  function openScript() {
    const url = `chapter10_script.html?block=${block}&v=${ASSET_VERSION}#${block}/${slideIndex + 1}/${stepIndex}`;
    if (scriptWindow && !scriptWindow.closed) {
      scriptWindow.focus();
      sendStateToScript();
      return;
    }
    scriptWindow = window.open(url, 'chapter10Script', 'width=900,height=960,resizable=yes,scrollbars=yes');
    if (scriptWindow) {
      scriptWindow.focus();
      setTimeout(sendStateToScript, 250);
      setTimeout(sendStateToScript, 700);
    }
  }

  function boot() {
    if (booted || !window.CH10_SLIDES?.length) return;
    slides = window.CH10_SLIDES;
    if (navigation) {
      navigation.prepareSlides(slides, block);
      const issues = navigation.audit(slides, block);
      if (issues.length) console.warn('[Chapter10] navigation audit', issues);
    }
    booted = true;
    const initial = parseHash();
    slideIndex = Math.max(0, Math.min(slides.length - 1, initial.slideIndex));
    stepIndex = Math.max(0, Math.min(maxStep(slideIndex), initial.stepIndex));
    render();
  }

  window.setSlideFromScript = (targetBlock, newSlide, newStep = 0) => {
    if (targetBlock && targetBlock !== block) return;
    showState(newSlide, newStep, { notifyChild: false });
  };
  window.chapter10NextFromScript = next;
  window.chapter10PrevFromScript = previous;

  addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.channel !== CHANNEL) return;
    if (event.source && !event.source.closed) scriptWindow = event.source;
    if (data.block && data.block !== block) return;
    if (data.type === 'navigate-presentation') showState(data.slideIndex, data.stepIndex, { notifyChild: false });
    if (data.type === 'request-next') next();
    if (data.type === 'request-prev') previous();
    if (data.type === 'script-ready') sendStateToScript();
  });

  addEventListener('keydown', (event) => {
    if (!booted) return;
    if (['ArrowRight', 'ArrowDown', 'PageDown', ' '].includes(event.key)) { event.preventDefault(); next(); }
    else if (['ArrowLeft', 'ArrowUp', 'PageUp'].includes(event.key)) { event.preventDefault(); previous(); }
    else if (event.key === 'Home') showState(0, 0);
    else if (event.key === 'End') showState(slides.length - 1, maxStep(slides.length - 1));
    else if (event.key.toLowerCase() === 's') openScript();
    else if (event.key.toLowerCase() === 'f') document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen?.();
  });

  app.addEventListener('click', (event) => {
    if (!booted || event.target.closest('button') || event.target.closest('a')) return;
    const rect = app.getBoundingClientRect();
    event.clientX - rect.left < rect.width * 0.32 ? previous() : next();
  });

  addEventListener('hashchange', () => {
    if (!booted) return;
    const state = parseHash();
    if (state.slideIndex !== slideIndex || state.stepIndex !== stepIndex) showState(state.slideIndex, state.stepIndex);
  });

  addEventListener('chapter10-slides-ready', boot, { once: true });
  addEventListener('chapter10-slides-error', () => {
    app.innerHTML = '<div class="loading-slide error-slide">Chapter 10 강의 계획서를 불러오지 못했습니다.</div>';
  }, { once: true });
  app.innerHTML = '<div class="loading-slide">Chapter 10 발표자료를 구성하는 중입니다.</div>';
  boot();
})();
