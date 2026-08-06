(() => {
  const CHANNEL = 'chapter04-presentation-sync';
  const app = document.getElementById('app');
  if (!app) return;

  const block = document.body?.dataset?.chapter04Block === 'practice' ? 'practice' : 'theory';
  const blockLabel = block === 'practice' ? '실습' : '이론';
  const slides = window.CH4_SLIDES || [];
  const deckTitle = window.CH4_TITLE || `Chapter 04 ${blockLabel} 강의`;
  const icon = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3h9l3 3v15H6z"/><path d="M15 3v4h4M9 11h6M9 15h6"/></svg>';

  const parseHash = () => {
    const raw = location.hash.slice(1);
    if (!raw) return { slideIndex: 0, stepIndex: 0 };
    if (/^\d+$/.test(raw)) return { slideIndex: Math.max(0, Number(raw) - 1), stepIndex: 0 };
    const [hashBlock, slide, step] = raw.split('/');
    if (hashBlock && hashBlock !== block) return { slideIndex: 0, stepIndex: 0 };
    return { slideIndex: Math.max(0, (Number(slide) || 1) - 1), stepIndex: Math.max(0, Number(step) || 0) };
  };

  const scriptSegments = (slide) => {
    const raw = String(slide?.s || '').trim();
    let parts = raw.split(/\n\s*\n/).map((value) => value.replace(/\s+/g, ' ').trim()).filter(Boolean);
    if (parts.length === 1) {
      const sentences = (parts[0].match(/[^.!?。]+[.!?。]?/g) || []).map((value) => value.trim()).filter(Boolean);
      if (sentences.length > 1) parts = sentences;
    }
    return parts.length ? parts : ['핵심 내용을 설명합니다.'];
  };

  let { slideIndex, stepIndex } = parseHash();
  slideIndex = Math.max(0, Math.min(slides.length - 1, slideIndex));
  let scriptWindow = null;

  const maxStep = (index = slideIndex) => Number(slides[index]?.steps || scriptSegments(slides[index]).length || 1);
  stepIndex = Math.max(0, Math.min(maxStep(slideIndex), stepIndex));

  const unique = (items) => [...new Set(items)];
  const focusTargets = (root) => {
    const explicit = [...root.querySelectorAll('[data-focus-step]')];
    if (explicit.length) return explicit;
    const selectors = [
      '.card', '.flow-step', '.bullet-list li', '.table-wrap tbody tr', '.quote',
      '.prompt-box', 'pre', '.codebox', '.expect', '.pill', '.chip'
    ];
    let targets = unique(selectors.flatMap((selector) => [...root.querySelectorAll(selector)]));
    targets = targets.filter((element) => !targets.some((other) => other !== element && element.contains(other)));
    if (!targets.length) targets = [...root.children].filter((element) => !['H1', 'H2'].includes(element.tagName));
    return targets;
  };

  const prepareFocus = () => {
    const root = app.querySelector('.body');
    if (!root) return;
    const targets = focusTargets(root);
    const total = Math.max(1, maxStep());
    targets.forEach((element, index) => {
      element.classList.add('focus-target');
      if (!element.dataset.focusStep) {
        const from = Math.floor(index * total / Math.max(1, targets.length)) + 1;
        const to = Math.max(from, Math.floor((index + 1) * total / Math.max(1, targets.length)));
        element.dataset.focusFrom = String(Math.min(total, from));
        element.dataset.focusTo = String(Math.min(total, to));
      }
    });
  };

  const applyFocus = () => {
    const root = app.querySelector('.body');
    if (!root) return;
    root.querySelectorAll('[data-focus-step],[data-focus-from]').forEach((element) => {
      const exact = Number(element.dataset.focusStep || 0);
      const from = Number(element.dataset.focusFrom || exact);
      const to = Number(element.dataset.focusTo || exact);
      const active = stepIndex > 0 && stepIndex >= from && stepIndex <= to;
      element.classList.toggle('focus-active', active);
      element.classList.toggle('focus-muted', stepIndex > 0 && !active);
    });
    const state = document.getElementById('state');
    if (state) state.textContent = stepIndex === 0 ? '전체 보기' : `강조 ${stepIndex} / ${maxStep()}`;
  };

  const updateButtons = () => {
    const previousButton = document.getElementById('previousButton');
    const nextButton = document.getElementById('nextButton');
    if (previousButton) previousButton.disabled = slideIndex === 0 && stepIndex === 0;
    if (nextButton) nextButton.disabled = slideIndex === slides.length - 1 && stepIndex === maxStep();
  };

  const render = () => {
    const slide = slides[slideIndex];
    if (!slide) return;
    app.innerHTML = `<section class="slide"><div class="head"><span class="k">${slide.k || ''}</span><div class="head-actions"><span class="l">${slide.l || blockLabel}</span><span class="counter">${String(slideIndex + 1).padStart(2, '0')} / ${String(slides.length).padStart(2, '0')}</span><button class="script-icon" id="scriptButton" type="button" title="발표 스크립트 열기" aria-label="현재 슬라이드 발표 스크립트 창 열기">${icon}</button></div></div><div class="body">${slide.h || ''}</div></section><a class="home" href="index.html">목차</a><div class="num">Chapter 04 · ${blockLabel}</div><div class="step-state" id="state" aria-live="polite"></div><nav class="ctrl"><button class="btn" id="previousButton" aria-label="이전 강조 또는 슬라이드">←</button><button class="btn" id="nextButton" aria-label="다음 강조 또는 슬라이드">→</button></nav><div class="track"><div class="bar" style="width:${((slideIndex + 1) / slides.length) * 100}%"></div></div>`;
    document.getElementById('previousButton').onclick = previous;
    document.getElementById('nextButton').onclick = next;
    document.getElementById('scriptButton').onclick = (event) => { event.stopPropagation(); openScript(); };
    prepareFocus();
    applyFocus();
    updateButtons();
    history.replaceState(null, '', `#${block}/${slideIndex + 1}/${stepIndex}`);
    document.title = `${slideIndex + 1}/${slides.length} · ${deckTitle}`;
  };

  const sendStateToScript = () => {
    if (!scriptWindow || scriptWindow.closed) return;
    try {
      scriptWindow.postMessage({ channel: CHANNEL, type: 'presentation-state', block, slideIndex, stepIndex }, '*');
    } catch (error) {
      try { scriptWindow.setScriptState?.(block, slideIndex, stepIndex); } catch (ignore) {}
    }
  };

  const showState = (newSlide, newStep = 0, { notifyChild = true } = {}) => {
    slideIndex = Math.max(0, Math.min(slides.length - 1, Number(newSlide) || 0));
    stepIndex = Math.max(0, Math.min(maxStep(slideIndex), Number(newStep) || 0));
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

  const openScript = () => {
    const url = `chapter04_script.html?block=${block}#${block}/${slideIndex + 1}/${stepIndex}`;
    if (scriptWindow && !scriptWindow.closed) {
      scriptWindow.focus();
      sendStateToScript();
      return;
    }
    scriptWindow = window.open(url, 'chapter04Script', 'width=900,height=960,resizable=yes,scrollbars=yes');
    if (scriptWindow) {
      scriptWindow.focus();
      setTimeout(sendStateToScript, 250);
      setTimeout(sendStateToScript, 700);
    }
  };

  window.setSlideFromScript = (requestedBlock, newSlide, newStep = 0) => {
    if (requestedBlock && requestedBlock !== block) return;
    showState(newSlide, newStep, { notifyChild: false });
  };
  window.chapter04NextFromScript = next;
  window.chapter04PrevFromScript = previous;

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
    if (['ArrowRight', 'ArrowDown', 'PageDown', ' '].includes(event.key)) { event.preventDefault(); next(); }
    else if (['ArrowLeft', 'ArrowUp', 'PageUp'].includes(event.key)) { event.preventDefault(); previous(); }
    else if (event.key === 'Home') showState(0, 0);
    else if (event.key === 'End') showState(slides.length - 1, maxStep(slides.length - 1));
    else if (event.key.toLowerCase() === 's') openScript();
    else if (event.key.toLowerCase() === 'f') document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen?.();
  });

  app.addEventListener('click', (event) => {
    if (event.target.closest('button') || event.target.closest('a')) return;
    const rect = app.getBoundingClientRect();
    event.clientX - rect.left < rect.width * 0.32 ? previous() : next();
  });

  addEventListener('hashchange', () => {
    const parsed = parseHash();
    if (parsed.slideIndex !== slideIndex || parsed.stepIndex !== stepIndex) showState(parsed.slideIndex, parsed.stepIndex);
  });

  render();
})();
