(() => {
  'use strict';

  const CHANNEL = 'chapter02-presentation-sync';
  const data = window.CHAPTER_DATA;
  const slides = data?.slides || [];
  const navigation = window.CH2Navigation;
  const app = document.getElementById('app');
  if (!data || !slides.length || !navigation || !app) throw new Error('Chapter 02 data, navigation, and #app are required.');

  let scriptWindow = null;

  const clamp = (value, min, max) => Math.max(min, Math.min(value, max));
  const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (char) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[char]);

  const parseHash = () => {
    const match = location.hash.match(/^#(\d+)(?:\/(\d+))?$/);
    if (!match) return { slideIndex: 0, stepIndex: 0 };
    return { slideIndex: Number(match[1]) - 1, stepIndex: Number(match[2] || 0) };
  };

  const initial = parseHash();
  let slideIndex = clamp(initial.slideIndex, 0, slides.length - 1);
  let stepIndex = 0;

  const steps = (index = slideIndex) => navigation.buildSteps(slides[index], index);
  const maxStep = (index = slideIndex) => steps(index).length;

  const sendStateToScript = () => {
    if (!scriptWindow || scriptWindow.closed) return;
    try {
      scriptWindow.postMessage({ channel: CHANNEL, type: 'presentation-state', slideIndex, stepIndex }, '*');
    } catch (_) {}
  };

  const updateHash = () => {
    const nextHash = `#${slideIndex + 1}/${stepIndex}`;
    if (location.hash !== nextHash) history.replaceState(null, '', nextHash);
  };

  const render = () => {
    const slide = slides[slideIndex];
    if (!slide) {
      app.innerHTML = '<div class="loading">Chapter 02 장표를 찾을 수 없습니다.</div>';
      return;
    }

    app.innerHTML = `<section class="slide" aria-labelledby="slide-title">
      <header class="slide-header">
        <span class="eyebrow">${escapeHtml(slide.eyebrow)}</span>
        <span class="chapter-label">${escapeHtml(slide.label)}</span>
      </header>
      <div class="slide-body"><h2 id="slide-title">${escapeHtml(slide.title)}</h2>${slide.body}</div>
    </section>
    <button class="script-button" id="script-button" type="button" title="발표 스크립트 열기" aria-label="현재 슬라이드 발표 스크립트 창 열기">
      <svg class="script-button-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3h9l3 3v15H6z"/><path d="M15 3v4h4M9 11h6M9 15h6"/></svg>
    </button>
    <div class="slide-counter">${slideIndex + 1} / ${slides.length}</div>
    <div class="part-counter" id="step-state">${stepIndex === 0 ? '전체 보기' : `스크립트 단계 ${stepIndex} / ${maxStep()}`}</div>
    <nav class="controls" aria-label="슬라이드 이동">
      <button class="control-button" id="prev" aria-label="이전 단계 또는 장표">←</button>
      <button class="control-button" id="next" aria-label="다음 단계 또는 장표">→</button>
    </nav>
    <div class="progress" aria-hidden="true"><div style="width:${((slideIndex + 1) / slides.length) * 100}%"></div></div>
    <div class="notes-overlay" id="notes"><div class="notes-panel"><h3>${escapeHtml(slide.title)}</h3><p>${escapeHtml(slide.script)}</p></div></div>`;

    navigation.applyFocus(app.querySelector('.slide-body'), slide, slideIndex, stepIndex);
    document.getElementById('prev').disabled = slideIndex === 0 && stepIndex === 0;
    document.getElementById('next').disabled = slideIndex === slides.length - 1 && stepIndex === maxStep();
    document.getElementById('prev').addEventListener('click', previous);
    document.getElementById('next').addEventListener('click', next);
    document.getElementById('script-button').addEventListener('click', (event) => {
      event.stopPropagation();
      openScript();
    });
    updateHash();
  };

  const showState = (newSlide, newStep = 0, { notifyChild = true } = {}) => {
    slideIndex = clamp(Number(newSlide) || 0, 0, slides.length - 1);
    stepIndex = clamp(Number(newStep) || 0, 0, maxStep(slideIndex));
    render();
    if (notifyChild) sendStateToScript();
  };

  function next() {
    if (stepIndex < maxStep()) showState(slideIndex, stepIndex + 1);
    else if (slideIndex < slides.length - 1) showState(slideIndex + 1, 0);
  }

  function previous() {
    if (stepIndex > 0) showState(slideIndex, stepIndex - 1);
    else if (slideIndex > 0) showState(slideIndex - 1, maxStep(slideIndex - 1));
  }

  function openScript() {
    const target = `chapter02_script.html?v=20260808c#${slideIndex + 1}/${stepIndex}`;
    if (scriptWindow && !scriptWindow.closed) {
      scriptWindow.focus();
      sendStateToScript();
      return;
    }
    scriptWindow = window.open(target, 'chapter02Script', 'popup,width=900,height=960');
    if (!scriptWindow) document.getElementById('notes')?.classList.add('open');
  }

  window.chapter02NextFromScript = next;
  window.chapter02PrevFromScript = previous;

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
      document.getElementById('notes')?.classList.remove('open');
      return;
    }
    if (['ArrowRight', 'ArrowDown', 'PageDown', ' '].includes(event.key)) {
      event.preventDefault();
      next();
    } else if (['ArrowLeft', 'ArrowUp', 'PageUp'].includes(event.key)) {
      event.preventDefault();
      previous();
    } else if (event.key === 'Home') showState(0, 0);
    else if (event.key === 'End') showState(slides.length - 1, maxStep(slides.length - 1));
    else if (event.key.toLowerCase() === 's') openScript();
    else if (event.key.toLowerCase() === 'f') document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen?.();
  });

  app.addEventListener('click', (event) => {
    if (event.target.closest('button,.notes-panel')) return;
    const rect = app.getBoundingClientRect();
    event.clientX - rect.left < rect.width * .32 ? previous() : next();
  });

  window.addEventListener('hashchange', () => {
    const parsed = parseHash();
    if (parsed.slideIndex !== slideIndex || parsed.stepIndex !== stepIndex) showState(parsed.slideIndex, parsed.stepIndex);
  });

  window.addEventListener('message', (event) => {
    const message = event.data || {};
    if (message.channel !== CHANNEL) return;
    if (message.type === 'script-ready') {
      if (event.source && !event.source.closed) scriptWindow = event.source;
      sendStateToScript();
    } else if (message.type === 'navigate-presentation') {
      showState(message.slideIndex, message.stepIndex, { notifyChild: false });
    } else if (message.type === 'request-next') {
      next();
    } else if (message.type === 'request-prev') {
      previous();
    }
  });

  stepIndex = clamp(initial.stepIndex, 0, maxStep(slideIndex));
  render();
})();
