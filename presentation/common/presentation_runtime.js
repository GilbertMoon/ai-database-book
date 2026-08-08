(() => {
  const data = window.CHAPTER_DATA;
  const app = document.getElementById('app');
  if (!data || !app) throw new Error('CHAPTER_DATA와 #app이 필요합니다.');

  const clamp = (value, min, max) => Math.max(min, Math.min(value, max));
  const scriptIcon = '<svg class="script-button-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M6 3h9l3 3v15H6z"/><path d="M15 3v4h4M9 11h6M9 15h6"/></svg>';
  let scriptWindow = null;
  let scriptReady = false;
  let scriptReadyTimer = null;
  let state = readHash();

  function readHash() {
    const match = location.hash.match(/^#(\d+)(?:\/(\d+))?$/);
    const slideIndex = clamp(Number(match?.[1] || 1) - 1, 0, data.slides.length - 1);
    const maxStep = Math.max(0, (data.slides[slideIndex].steps?.length || 1) - 1);
    return { slideIndex, stepIndex: clamp(Number(match?.[2] || 1) - 1, 0, maxStep) };
  }

  function writeHash() {
    const next = `#${state.slideIndex + 1}/${state.stepIndex + 1}`;
    if (location.hash !== next) history.replaceState(null, '', next);
  }

  function render() {
    const slide = data.slides[state.slideIndex];
    const steps = slide.steps || [];
    app.innerHTML = `<section class="slide ${steps.length ? 'has-steps' : ''}" aria-labelledby="slide-title">
      <header class="slide-header"><span class="eyebrow">${slide.eyebrow}</span><span class="chapter-label">${slide.label}</span></header>
      <div class="slide-body"><h2 id="slide-title">${slide.title}</h2>${slide.body}<div class="detail-panel" aria-live="polite">${steps[state.stepIndex]?.label || slide.summary || ''}</div></div>
    </section>
    <button class="script-button" id="script-button" type="button" title="발표 스크립트 열기" aria-label="현재 슬라이드 발표 스크립트 창 열기">${scriptIcon}</button>
    <div class="slide-counter">${state.slideIndex + 1} / ${data.slides.length}</div>
    <div class="part-counter">${slide.part === 0 ? '시작' : `Part ${slide.part}`} · 단계 ${state.stepIndex + 1}/${Math.max(steps.length, 1)}</div>
    <nav class="controls" aria-label="슬라이드 이동"><button class="control-button" id="prev" aria-label="이전 단계">←</button><button class="control-button" id="next" aria-label="다음 단계">→</button></nav>
    <div class="progress" aria-hidden="true"><div style="width:${((state.slideIndex + 1) / data.slides.length) * 100}%"></div></div>
    <div class="notes-overlay" id="notes"><div class="notes-panel"><h3>${slide.title}</h3><p>${slide.script}</p></div></div>`;
    app.querySelectorAll('[data-cue]').forEach((element) => {
      const index = steps.findIndex((step) => step.target === element.dataset.cue);
      element.classList.toggle('is-active', index === state.stepIndex);
      element.classList.toggle('is-past', index >= 0 && index < state.stepIndex);
    });
    document.getElementById('prev').onclick = previous;
    document.getElementById('next').onclick = next;
    document.getElementById('script-button').onclick = openScript;
    writeHash();
    syncScript();
  }

  function next() {
    const stepCount = data.slides[state.slideIndex].steps?.length || 1;
    if (state.stepIndex < stepCount - 1) state.stepIndex += 1;
    else if (state.slideIndex < data.slides.length - 1) { state.slideIndex += 1; state.stepIndex = 0; }
    render();
  }

  function previous() {
    if (state.stepIndex > 0) state.stepIndex -= 1;
    else if (state.slideIndex > 0) {
      state.slideIndex -= 1;
      state.stepIndex = Math.max(0, (data.slides[state.slideIndex].steps?.length || 1) - 1);
    }
    render();
  }

  function goTo(nextState) {
    state.slideIndex = clamp(Number(nextState.slideIndex), 0, data.slides.length - 1);
    state.stepIndex = clamp(Number(nextState.stepIndex), 0, Math.max(0, (data.slides[state.slideIndex].steps?.length || 1) - 1));
    render();
  }

  function syncScript() {
    if (scriptWindow && !scriptWindow.closed) scriptWindow.postMessage({ type: 'presentation-state', ...state }, '*');
  }

  function openScript() {
    scriptReady = false;
    window.clearTimeout(scriptReadyTimer);
    scriptWindow = window.open(data.scriptFile, `${data.chapterId}-script`, 'popup,width=1120,height=820');
    if (!scriptWindow) document.getElementById('notes').classList.add('open');
    else {
      window.setTimeout(syncScript, 250);
      scriptReadyTimer = window.setTimeout(() => {
        if (!scriptReady) document.getElementById('notes')?.classList.add('open');
      }, 700);
    }
  }

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') { document.getElementById('notes')?.classList.remove('open'); return; }
    if (['ArrowRight', 'ArrowDown', 'PageDown', ' '].includes(event.key)) { event.preventDefault(); next(); }
    else if (['ArrowLeft', 'ArrowUp', 'PageUp'].includes(event.key)) { event.preventDefault(); previous(); }
    else if (event.key === 'Home') goTo({ slideIndex: 0, stepIndex: 0 });
    else if (event.key === 'End') goTo({ slideIndex: data.slides.length - 1, stepIndex: 0 });
    else if (event.key.toLowerCase() === 's') openScript();
    else if (event.key.toLowerCase() === 'f') document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen?.();
  });

  app.addEventListener('click', (event) => {
    if (event.target.closest('button,.notes-panel')) return;
    const rect = app.getBoundingClientRect();
    event.clientX - rect.left < rect.width * .32 ? previous() : next();
  });
  window.addEventListener('hashchange', () => { state = readHash(); render(); });
  window.addEventListener('message', (event) => {
    if (event.data?.type === 'script-ready') {
      scriptReady = true;
      window.clearTimeout(scriptReadyTimer);
      document.getElementById('notes')?.classList.remove('open');
      syncScript();
    }
    if (event.data?.type === 'script-navigate') goTo(event.data);
  });
  render();
})();
