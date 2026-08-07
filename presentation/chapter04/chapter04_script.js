(() => {
  'use strict';

  const CHANNEL = 'chapter04-presentation-sync';
  const CACHE_VERSION = '20260807b';
  const card = document.getElementById('card');
  const navigation = window.CH4Navigation;
  const params = new URLSearchParams(location.search);
  let block = params.get('block') === 'practice' ? 'practice' : 'theory';
  let slides = [];
  let slideIndex = 0;
  let stepIndex = 0;
  let presentationWindow = window.opener && !window.opener.closed ? window.opener : null;

  const sources = {
    theory: ['chapter04_theory_slides_raw.js', 'chapter04_intro_patch.js', '../common/screen_position_patch.js'],
    practice: ['chapter04_practice_slides_raw.js', '../common/screen_position_patch.js']
  };

  const escapeHtml = (value) => String(value || '').replace(/[&<>"']/g, (char) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[char]);

  const parseHash = () => {
    const raw = location.hash.slice(1);
    if (!raw) return { slideIndex: 0, stepIndex: 0 };
    if (/^\d+$/.test(raw)) return { slideIndex: Math.max(0, Number(raw) - 1), stepIndex: 0 };
    const [hashBlock, slide, step] = raw.split('/');
    if (hashBlock === 'theory' || hashBlock === 'practice') block = hashBlock;
    return {
      slideIndex: Math.max(0, (Number(slide) || 1) - 1),
      stepIndex: Math.max(0, Number(step) || 0)
    };
  };

  const loadScript = (src) => new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = `${src}${src.includes('?') ? '&' : '?'}v=${CACHE_VERSION}`;
    script.onload = () => { script.remove(); resolve(); };
    script.onerror = reject;
    document.head.appendChild(script);
  });

  const steps = (index = slideIndex) => navigation?.buildSteps(slides[index]) || [{
    text: String(slides[index]?.s || '핵심 내용을 설명합니다.'),
    focusKeys: []
  }];
  const maxStep = (index = slideIndex) => steps(index).length;

  const loadBlock = async (target, { preserve = false } = {}) => {
    block = target === 'practice' ? 'practice' : 'theory';
    window.CH4_SLIDES = undefined;
    window.CH4_TITLE = undefined;
    for (const src of sources[block]) await loadScript(src);
    slides = window.CH4_SLIDES || [];
    navigation?.clearCache(slides);
    if (!preserve) { slideIndex = 0; stepIndex = 0; }
    slideIndex = Math.max(0, Math.min(slides.length - 1, slideIndex));
    stepIndex = Math.max(0, Math.min(maxStep(slideIndex), stepIndex));
    render();
  };

  const send = (type, extra = {}) => {
    if (!presentationWindow || presentationWindow.closed) return false;
    try {
      presentationWindow.postMessage({ channel: CHANNEL, type, block, ...extra }, '*');
      return true;
    } catch (_) { return false; }
  };
  const sendState = () => send('navigate-presentation', { slideIndex, stepIndex });
  const presentationFile = () => block === 'practice' ? 'chapter04_practice_presentation.html' : 'chapter04_theory_presentation.html';

  const render = () => {
    const slide = slides[slideIndex];
    if (!slide) return;
    const currentSteps = steps();
    const page = String(slideIndex + 1).padStart(2, '0');
    const total = String(slides.length).padStart(2, '0');

    document.getElementById('topCounter').textContent = `${page} / ${total}`;
    document.getElementById('counter').textContent = `${page} / ${total}`;
    document.getElementById('state').textContent = stepIndex === 0 ? '전체 보기' : `스크립트 단계 ${stepIndex} / ${maxStep()}`;
    document.getElementById('prevPage').disabled = slideIndex === 0;
    document.getElementById('nextPage').disabled = slideIndex === slides.length - 1;
    document.getElementById('theoryBlock').classList.toggle('active', block === 'theory');
    document.getElementById('practiceBlock').classList.toggle('active', block === 'practice');

    card.innerHTML = `<h1>${escapeHtml(slide.t || slide.l || '핵심 내용')}</h1><p class="meta">${escapeHtml(slide.k || 'CHAPTER 04')} · ${block === 'practice' ? '실습 강의' : '이론 강의'} · 파란 버튼은 장표 창의 다음 스크립트 단계와 같습니다.</p>${currentSteps.map((step, index) => `<div class="script-text"><p>${escapeHtml(step.text)}</p></div><p class="focus-note">${step.focusKeys.length ? '이 설명과 관련된 화면 요소를 강조합니다.' : '이 설명은 장표 전체를 보며 진행합니다.'}</p><div class="cue"><span class="line"></span><button class="cue-button" type="button" data-step="${index + 1}">${index + 1}단계 진행</button><span class="line"></span></div>`).join('')}<div class="hint">도입·전환·정리 문장은 관련 단계에 합치고, 표는 행 단위, SQL은 코드 줄 단위, 예상·완료 기준은 별도 요소로 연결합니다.</div>`;

    card.querySelectorAll('.cue-button').forEach((button) => {
      const target = Number(button.dataset.step);
      button.classList.toggle('done', target < stepIndex);
      button.classList.toggle('current', target === stepIndex && stepIndex > 0);
      button.classList.toggle('next', target === stepIndex + 1);
      button.disabled = target !== stepIndex + 1;
      button.onclick = requestNext;
    });

    history.replaceState(null, '', `?block=${block}#${block}/${slideIndex + 1}/${stepIndex}`);
  };

  const showState = (newBlock, newSlide, newStep = 0, { notify = true, scroll = true } = {}) => {
    if (newBlock && newBlock !== block) {
      loadBlock(newBlock).then(() => showState(newBlock, newSlide, newStep, { notify, scroll }));
      return;
    }
    const oldSlide = slideIndex;
    slideIndex = Math.max(0, Math.min(slides.length - 1, Number(newSlide) || 0));
    stepIndex = Math.max(0, Math.min(maxStep(slideIndex), Number(newStep) || 0));
    render();
    if (notify) sendState();
    if (scroll && oldSlide !== slideIndex) scrollTo({ top: 0, behavior: 'smooth' });
  };

  const localNext = () => {
    if (stepIndex < maxStep()) showState(block, slideIndex, stepIndex + 1);
    else if (slideIndex < slides.length - 1) showState(block, slideIndex + 1, 0);
  };
  const localPrev = () => {
    if (stepIndex > 0) showState(block, slideIndex, stepIndex - 1);
    else if (slideIndex > 0) showState(block, slideIndex - 1, maxStep(slideIndex - 1));
  };

  function requestNext() {
    if (send('request-next')) return;
    try {
      if (presentationWindow?.chapter04NextFromScript) {
        presentationWindow.chapter04NextFromScript();
        return;
      }
    } catch (_) {}
    localNext();
  }

  function requestPrev() {
    if (send('request-prev')) return;
    try {
      if (presentationWindow?.chapter04PrevFromScript) {
        presentationWindow.chapter04PrevFromScript();
        return;
      }
    } catch (_) {}
    localPrev();
  }

  window.setScriptState = (newBlock, newSlide, newStep = 0) => showState(newBlock, newSlide, newStep, { notify: false, scroll: false });

  addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.channel !== CHANNEL) return;
    if (event.source && !event.source.closed) presentationWindow = event.source;
    if (data.type === 'presentation-state') showState(data.block || block, data.slideIndex, data.stepIndex, { notify: false, scroll: false });
  });

  document.getElementById('prevPage').onclick = () => showState(block, slideIndex - 1, 0);
  document.getElementById('nextPage').onclick = () => showState(block, slideIndex + 1, 0);
  document.getElementById('focusSlides').onclick = () => {
    if (presentationWindow && !presentationWindow.closed) {
      presentationWindow.focus();
      sendState();
      return;
    }
    presentationWindow = window.open(`${presentationFile()}#${block}/${slideIndex + 1}/${stepIndex}`, 'chapter04Presentation');
    if (presentationWindow) {
      presentationWindow.focus();
      setTimeout(() => send('script-ready'), 300);
    }
  };

  const switchBlock = async (target) => {
    if (target === block) return;
    if (presentationWindow && !presentationWindow.closed) {
      presentationWindow = window.open(`${target === 'practice' ? 'chapter04_practice_presentation.html' : 'chapter04_theory_presentation.html'}#${target}/1/0`, 'chapter04Presentation');
    }
    await loadBlock(target);
    setTimeout(() => send('script-ready'), 350);
  };

  document.getElementById('theoryBlock').onclick = () => switchBlock('theory');
  document.getElementById('practiceBlock').onclick = () => switchBlock('practice');

  addEventListener('keydown', (event) => {
    if (['ArrowRight', 'ArrowDown', 'PageDown', ' '].includes(event.key)) { event.preventDefault(); requestNext(); }
    else if (['ArrowLeft', 'ArrowUp', 'PageUp'].includes(event.key)) { event.preventDefault(); requestPrev(); }
    else if (event.key === 'Home') showState(block, 0, 0);
    else if (event.key === 'End') showState(block, slides.length - 1, maxStep(slides.length - 1));
  });

  addEventListener('hashchange', () => {
    const parsed = parseHash();
    if (parsed.slideIndex !== slideIndex || parsed.stepIndex !== stepIndex) showState(block, parsed.slideIndex, parsed.stepIndex);
  });

  const initial = parseHash();
  slideIndex = initial.slideIndex;
  stepIndex = initial.stepIndex;
  loadBlock(block, { preserve: true }).then(() => {
    if (presentationWindow && !presentationWindow.closed) {
      send('script-ready');
      setTimeout(() => send('script-ready'), 250);
    }
  }).catch((error) => {
    console.error(error);
    card.innerHTML = '<div class="loading">Chapter 04 스크립트를 불러오지 못했습니다.</div>';
  });
})();
