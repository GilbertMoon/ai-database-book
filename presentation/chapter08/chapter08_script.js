(() => {
  'use strict';

  const CHANNEL = 'chapter08-presentation-sync';
  const ASSET_VERSION = '20260809a';
  const card = document.getElementById('card');
  const navigation = window.CH8Navigation;
  let block = document.body.dataset.chapter08Block === 'practice' ? 'practice' : 'theory';
  let slides = [];
  let slideIndex = 0;
  let stepIndex = 0;
  let presentationWindow = window.opener && !window.opener.closed ? window.opener : null;

  if (!card || !navigation) throw new Error('Chapter 08 script dependencies are missing.');

  const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (character) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[character]);
  const ttsText = (value) => window.PresentationTTS?.normalize
    ? window.PresentationTTS.normalize(String(value ?? ''))
    : String(value ?? '');

  const stepsFor = (index = slideIndex) => navigation.buildSteps(slides[index]);
  const maxStep = (index = slideIndex) => Math.max(1, stepsFor(index).length);

  function parseHash() {
    const raw = location.hash.slice(1);
    if (!raw) return { block, slideIndex: 0, stepIndex: 0 };
    if (/^\d+$/.test(raw)) return { block, slideIndex: Math.max(0, Number(raw) - 1), stepIndex: 0 };
    const [hashBlock, slide, step] = raw.split('/');
    return {
      block: hashBlock === 'practice' ? 'practice' : hashBlock === 'theory' ? 'theory' : block,
      slideIndex: Math.max(0, (Number(slide) || 1) - 1),
      stepIndex: Math.max(0, Number(step) || 0)
    };
  }

  function send(type, extra = {}) {
    if (!presentationWindow || presentationWindow.closed) return false;
    try {
      presentationWindow.postMessage({ channel: CHANNEL, type, block, ...extra }, '*');
      return true;
    } catch (_) { return false; }
  }

  const sendState = () => send('navigate-presentation', { slideIndex, stepIndex });
  const presentationFile = () => block === 'practice' ? 'chapter08_practice_presentation.html' : 'chapter08_theory_presentation.html';

  async function loadBlock(target, { preserve = false } = {}) {
    block = target === 'practice' ? 'practice' : 'theory';
    document.body.dataset.chapter08Block = block;
    slides = navigation.prepareSlides(await window.loadChapter08Slides(block));
    if (!preserve) { slideIndex = 0; stepIndex = 0; }
    slideIndex = Math.max(0, Math.min(slides.length - 1, slideIndex));
    stepIndex = Math.max(0, Math.min(maxStep(slideIndex), stepIndex));
    render();
  }

  function render() {
    const slide = slides[slideIndex];
    if (!slide) return;
    const parts = stepsFor();
    const page = String(slideIndex + 1).padStart(2, '0');
    const total = String(slides.length).padStart(2, '0');
    document.getElementById('topCounter').textContent = `${page} / ${total}`;
    document.getElementById('counter').textContent = `${page} / ${total}`;
    document.getElementById('state').textContent = stepIndex === 0 ? '전체 보기' : `스크립트 단계 ${stepIndex} / ${maxStep()}`;
    document.getElementById('prevPage').disabled = slideIndex === 0;
    document.getElementById('nextPage').disabled = slideIndex === slides.length - 1;
    document.getElementById('theoryBlock').classList.toggle('active', block === 'theory');
    document.getElementById('practiceBlock').classList.toggle('active', block === 'practice');

    card.innerHTML = `<h1>${escapeHtml(slide.t || slide.l || '핵심 내용')}</h1><p class="meta">${escapeHtml(slide.k || 'CHAPTER 08')} · ${block === 'practice' ? '실습 강의' : '이론 강의'} · 파란 버튼은 부모 장표의 다음 단계와 동일하게 동작합니다.</p>${parts.map((step, index) => `<div class="script-text"><p>${escapeHtml(ttsText(step.text))}</p></div><div class="cue"><span class="line"></span><button class="cue-button" type="button" data-step="${index + 1}">${index + 1}단계 진행</button><span class="line"></span></div>`).join('')}<div class="hint">Chapter 03~15와 동일하게 전체 보기에서 시작하고, 표·목록·코드·화면 설명을 의미 단위로 순차 이동합니다.</div>`;

    card.querySelectorAll('.cue-button').forEach((button) => {
      const target = Number(button.dataset.step);
      button.classList.toggle('done', target < stepIndex);
      button.classList.toggle('current', target === stepIndex && stepIndex > 0);
      button.classList.toggle('next', target === stepIndex + 1);
      button.disabled = target !== stepIndex + 1;
      button.onclick = requestNext;
    });

    history.replaceState(null, '', `?block=${block}#${block}/${slideIndex + 1}/${stepIndex}`);
    document.title = `${page}/${total} · Chapter 08 ${block === 'practice' ? '실습' : '이론'} 스크립트`;
  }

  function showState(newBlock, newSlide, newStep = 0, { notify = true } = {}) {
    if (newBlock && newBlock !== block) {
      loadBlock(newBlock).then(() => showState(newBlock, newSlide, newStep, { notify }));
      return;
    }
    slideIndex = Math.max(0, Math.min(slides.length - 1, Number(newSlide) || 0));
    stepIndex = Math.max(0, Math.min(maxStep(slideIndex), Number(newStep) || 0));
    render();
    if (notify) sendState();
    scrollTo({ top: 0, behavior: 'smooth' });
  }

  function localNext() {
    if (stepIndex < maxStep()) showState(block, slideIndex, stepIndex + 1);
    else if (slideIndex < slides.length - 1) showState(block, slideIndex + 1, 0);
  }

  function localPrevious() {
    if (stepIndex > 0) showState(block, slideIndex, stepIndex - 1);
    else if (slideIndex > 0) showState(block, slideIndex - 1, maxStep(slideIndex - 1));
  }

  function requestNext() { if (!send('request-next')) localNext(); }
  function requestPrevious() { if (!send('request-prev')) localPrevious(); }

  window.setScriptState = (newBlock, newSlide, newStep = 0) => showState(newBlock, newSlide, newStep, { notify: false });

  addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.channel !== CHANNEL) return;
    if (event.source && !event.source.closed) presentationWindow = event.source;
    if (data.type === 'presentation-state') showState(data.block || block, data.slideIndex, data.stepIndex, { notify: false });
  });

  document.getElementById('prevPage').onclick = () => showState(block, slideIndex - 1, 0);
  document.getElementById('nextPage').onclick = () => showState(block, slideIndex + 1, 0);
  document.getElementById('focusSlides').onclick = () => {
    if (presentationWindow && !presentationWindow.closed) { presentationWindow.focus(); sendState(); return; }
    presentationWindow = window.open(`${presentationFile()}?v=${ASSET_VERSION}#${block}/${slideIndex + 1}/${stepIndex}`, 'chapter08Presentation');
    if (presentationWindow) { presentationWindow.focus(); setTimeout(sendState, 400); }
  };

  async function switchBlock(target) {
    if (target === block) return;
    presentationWindow = window.open(`${target === 'practice' ? 'chapter08_practice_presentation.html' : 'chapter08_theory_presentation.html'}?v=${ASSET_VERSION}#${target}/1/0`, 'chapter08Presentation');
    await loadBlock(target);
    setTimeout(sendState, 450);
  }

  document.getElementById('theoryBlock').onclick = () => switchBlock('theory');
  document.getElementById('practiceBlock').onclick = () => switchBlock('practice');

  addEventListener('keydown', (event) => {
    if (['ArrowRight', 'ArrowDown', 'PageDown', ' '].includes(event.key)) { event.preventDefault(); requestNext(); }
    else if (['ArrowLeft', 'ArrowUp', 'PageUp'].includes(event.key)) { event.preventDefault(); requestPrevious(); }
    else if (event.key === 'Home') showState(block, 0, 0);
    else if (event.key === 'End') showState(block, slides.length - 1, maxStep(slides.length - 1));
  });

  const initial = parseHash();
  block = initial.block;
  slideIndex = initial.slideIndex;
  stepIndex = initial.stepIndex;
  loadBlock(block, { preserve: true }).then(() => {
    showState(block, slideIndex, stepIndex, { notify: false });
    send('script-ready');
  }).catch((error) => {
    console.error(error);
    card.innerHTML = '<div class="loading">Chapter 08 스크립트 데이터를 불러오지 못했습니다.</div>';
  });
})();
