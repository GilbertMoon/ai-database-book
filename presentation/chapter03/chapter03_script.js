(() => {
  'use strict';

  const CHANNEL = 'chapter03-presentation-sync';
  const card = document.getElementById('card');
  const params = new URLSearchParams(location.search);
  let block = params.get('block') === 'practice' ? 'practice' : 'theory';
  let slides = [];
  let slideIndex = 0;
  let stepIndex = 0;
  let presentationWindow = window.opener && !window.opener.closed ? window.opener : null;

  const sources = {
    theory: ['chapter03_theory_slides_raw.js', 'chapter03_intro_patch.js', 'chapter03_theory_script_expansion.js', '../common/screen_position_patch.js'],
    practice: ['chapter03_practice_slides_raw.js', 'chapter03_practice_script_expansion.js', '../common/screen_position_patch.js']
  };

  const escapeHtml = (value) => String(value || '').replace(/[&<>"']/g, (character) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[character]);

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
    script.src = `${src}${src.includes('?') ? '&' : '?'}v=${Date.now()}`;
    script.onload = () => { script.remove(); resolve(); };
    script.onerror = reject;
    document.head.appendChild(script);
  });

  const steps = (index = slideIndex) => window.CH3Navigation?.buildSteps(slides[index]) || [{
    text: String(slides[index]?.s || ''), focusKeys: []
  }];
  const maxStep = (index = slideIndex) => steps(index).length;

  const loadBlock = async (targetBlock, { preserveState = false } = {}) => {
    block = targetBlock === 'practice' ? 'practice' : 'theory';
    window.CH3_SLIDES = undefined;
    window.CH3_TITLE = undefined;
    for (const src of sources[block]) await loadScript(src);
    slides = window.CH3Navigation?.prepareSlides(window.CH3_SLIDES || [], block) || window.CH3_SLIDES || [];
    if (!preserveState) { slideIndex = 0; stepIndex = 0; }
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
  const presentationFile = () => block === 'practice' ? 'chapter03_practice_presentation.html' : 'chapter03_theory_presentation.html';

  const updateBlockButtons = () => {
    document.getElementById('theoryBlock').classList.toggle('active', block === 'theory');
    document.getElementById('practiceBlock').classList.toggle('active', block === 'practice');
  };

  function render() {
    const slide = slides[slideIndex];
    if (!slide) {
      card.innerHTML = '<div class="loading">Chapter 03 스크립트를 불러오지 못했습니다.</div>';
      return;
    }
    const currentSteps = steps();
    const page = String(slideIndex + 1).padStart(2, '0');
    const total = String(slides.length).padStart(2, '0');
    document.getElementById('topCounter').textContent = `${page} / ${total}`;
    document.getElementById('counter').textContent = `${page} / ${total}`;
    document.getElementById('state').textContent = stepIndex === 0 ? '전체 보기' : `스크립트 단계 ${stepIndex} / ${maxStep()}`;
    document.getElementById('prevPage').disabled = slideIndex === 0;
    document.getElementById('nextPage').disabled = slideIndex === slides.length - 1;
    updateBlockButtons();

    card.innerHTML = `<h1>${escapeHtml(slide.t || slide.l || '핵심 내용')}</h1><p class="meta">${escapeHtml(slide.k || 'CHAPTER 03')} · ${block === 'practice' ? '실습 강의' : '이론 강의'} · 파란 버튼은 장표 창의 같은 단계로 이동합니다.</p>${currentSteps.map((step, index) => `<div class="script-text"><p>${escapeHtml(step.text)}</p></div><p class="focus-note">${step.focusKeys.length ? '이 설명과 관련된 화면 요소를 강조합니다.' : '장표 전체를 보며 설명하는 단계입니다.'}</p><div class="cue"><span class="line"></span><button class="cue-button" type="button" data-step="${index + 1}">${index + 1}단계 진행</button><span class="line"></span></div>`).join('')}<div class="hint">연결값과 오류표는 행 단위, 환경 확인 명령은 코드 줄 단위, 설치 과정은 작업과 완료 기준 단위로 연결됩니다.</div>`;

    card.querySelectorAll('.cue-button').forEach((button) => {
      const target = Number(button.dataset.step);
      button.classList.toggle('done', target < stepIndex);
      button.classList.toggle('current', target === stepIndex && stepIndex > 0);
      button.classList.toggle('next', target === stepIndex + 1);
      button.disabled = target !== stepIndex + 1;
      button.addEventListener('click', requestNext);
    });

    history.replaceState(null, '', `?block=${block}#${block}/${slideIndex + 1}/${stepIndex}`);
    document.title = `${block === 'practice' ? '실습' : '이론'} ${page}/${total} · Chapter 03 발표 스크립트`;
  }

  const showState = (newBlock, newSlide, newStep = 0, { notifyParent = true, scroll = true } = {}) => {
    if (newBlock && newBlock !== block) {
      loadBlock(newBlock).then(() => showState(newBlock, newSlide, newStep, { notifyParent, scroll }));
      return;
    }
    const oldSlide = slideIndex;
    slideIndex = Math.max(0, Math.min(slides.length - 1, Number(newSlide) || 0));
    stepIndex = Math.max(0, Math.min(maxStep(slideIndex), Number(newStep) || 0));
    render();
    if (notifyParent) sendState();
    if (scroll && oldSlide !== slideIndex) window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const localNext = () => {
    if (stepIndex < maxStep()) showState(block, slideIndex, stepIndex + 1);
    else if (slideIndex < slides.length - 1) showState(block, slideIndex + 1, 0);
  };
  const localPrevious = () => {
    if (stepIndex > 0) showState(block, slideIndex, stepIndex - 1);
    else if (slideIndex > 0) showState(block, slideIndex - 1, maxStep(slideIndex - 1));
  };

  function requestNext() {
    if (send('request-next')) return;
    try { if (presentationWindow?.chapter03NextFromScript) { presentationWindow.chapter03NextFromScript(); return; } } catch (_) {}
    localNext();
  }
  function requestPrevious() {
    if (send('request-prev')) return;
    try { if (presentationWindow?.chapter03PrevFromScript) { presentationWindow.chapter03PrevFromScript(); return; } } catch (_) {}
    localPrevious();
  }

  window.setScriptState = (newBlock, newSlide, newStep = 0) => showState(newBlock, newSlide, newStep, { notifyParent: false, scroll: false });

  addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.channel !== CHANNEL) return;
    if (event.source && !event.source.closed) presentationWindow = event.source;
    if (data.type === 'presentation-state') showState(data.block || block, data.slideIndex, data.stepIndex, { notifyParent: false, scroll: false });
  });

  document.getElementById('prevPage').onclick = () => showState(block, slideIndex - 1, 0);
  document.getElementById('nextPage').onclick = () => showState(block, slideIndex + 1, 0);
  document.getElementById('focusSlides').onclick = () => {
    if (presentationWindow && !presentationWindow.closed) { presentationWindow.focus(); sendState(); return; }
    presentationWindow = window.open(`${presentationFile()}#${block}/${slideIndex + 1}/${stepIndex}`, 'chapter03Presentation');
    if (presentationWindow) { presentationWindow.focus(); setTimeout(() => send('script-ready'), 350); }
  };

  const switchBlock = async (targetBlock) => {
    if (targetBlock === block) return;
    presentationWindow = window.open(`${targetBlock === 'practice' ? 'chapter03_practice_presentation.html' : 'chapter03_theory_presentation.html'}#${targetBlock}/1/0`, 'chapter03Presentation');
    await loadBlock(targetBlock);
    setTimeout(() => send('script-ready'), 400);
  };
  document.getElementById('theoryBlock').onclick = () => switchBlock('theory');
  document.getElementById('practiceBlock').onclick = () => switchBlock('practice');

  addEventListener('keydown', (event) => {
    if (['ArrowRight','ArrowDown','PageDown',' '].includes(event.key)) { event.preventDefault(); requestNext(); }
    else if (['ArrowLeft','ArrowUp','PageUp'].includes(event.key)) { event.preventDefault(); requestPrevious(); }
    else if (event.key === 'Home') showState(block, 0, 0);
    else if (event.key === 'End') showState(block, slides.length - 1, maxStep(slides.length - 1));
  });

  addEventListener('hashchange', () => {
    const parsed = parseHash();
    if (parsed.slideIndex !== slideIndex || parsed.stepIndex !== stepIndex) showState(block, parsed.slideIndex, parsed.stepIndex, { notifyParent: false });
  });

  const initial = parseHash();
  loadBlock(block).then(() => {
    showState(block, initial.slideIndex, initial.stepIndex, { notifyParent: false, scroll: false });
    if (presentationWindow && !presentationWindow.closed) {
      send('script-ready');
      setTimeout(() => send('script-ready'), 250);
    }
  }).catch(() => {
    card.innerHTML = '<div class="loading">스크립트 데이터를 불러오지 못했습니다.</div>';
  });
})();
