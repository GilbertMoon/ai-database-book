(() => {
  'use strict';

  const CHANNEL = 'chapter02-presentation-sync';
  const data = window.CHAPTER_DATA;
  const slides = data?.slides || [];
  const enrichment = window.CH2ScriptEnrichment;
  const navigation = window.CH2Navigation;
  const card = document.getElementById('card');
  if (!data || !slides.length || !enrichment || !navigation || !card) throw new Error('Chapter 02 script dependencies are missing.');

  let presentationWindow = window.opener && !window.opener.closed ? window.opener : null;

  const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (char) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[char]);
  const normalizeTts = (value) => window.PresentationTTS?.normalize ? window.PresentationTTS.normalize(value) : String(value ?? '');

  const parseHash = () => {
    const match = location.hash.match(/^#(\d+)(?:\/(\d+))?$/);
    return match ? { slideIndex: Number(match[1]) - 1, stepIndex: Number(match[2] || 0) } : { slideIndex: 0, stepIndex: 0 };
  };

  const initial = parseHash();
  let slideIndex = Math.max(0, Math.min(slides.length - 1, initial.slideIndex));
  let stepIndex = 0;

  const steps = (index = slideIndex) => navigation.buildSteps(slides[index], index);
  const maxStep = (index = slideIndex) => steps(index).length;

  const send = (type, extra = {}) => {
    if (!presentationWindow || presentationWindow.closed) return false;
    try {
      presentationWindow.postMessage({ channel: CHANNEL, type, ...extra }, '*');
      return true;
    } catch (_) {
      return false;
    }
  };

  const sendState = () => send('navigate-presentation', { slideIndex, stepIndex });

  const render = () => {
    const slide = slides[slideIndex];
    const currentSteps = steps();
    const page = String(slideIndex + 1).padStart(2, '0');
    const total = String(slides.length).padStart(2, '0');

    document.getElementById('topCounter').textContent = `${page} / ${total}`;
    document.getElementById('counter').textContent = `${page} / ${total}`;
    document.getElementById('state').textContent = stepIndex === 0 ? '전체 보기' : `스크립트 단계 ${stepIndex} / ${maxStep()}`;
    document.getElementById('prevPage').disabled = slideIndex === 0;
    document.getElementById('nextPage').disabled = slideIndex === slides.length - 1;

    const overview = escapeHtml(normalizeTts(enrichment.overviewText(slide)));
    card.innerHTML = `<h1>${escapeHtml(slide.title)}</h1>
      <p class="meta">${escapeHtml(slide.eyebrow)} · 파란 버튼은 부모 장표의 다음 단계와 동일하게 동작합니다.</p>
      <div class="script-text overview"><p>${overview}</p></div>
      <p class="focus-note">상단은 장표 전체를 여는 1~2문장 도입입니다. 아래 단계에서는 개념·의미·예시와 주의점을 더 자세히 설명합니다.</p>
      ${currentSteps.map((step, index) => `<div class="script-text"><p>${escapeHtml(normalizeTts(step.text))}</p></div><p class="focus-note">${step.target ? '이 문단과 관련된 화면 요소를 강조합니다.' : '이 문단은 장표 전체를 보며 설명합니다.'}</p><div class="cue"><span class="line"></span><button class="cue-button" type="button" data-step="${index + 1}">${index + 1}단계 진행</button><span class="line"></span></div>`).join('')}
      <div class="hint">Chapter 01과 동일하게 전체 보기에서 시작합니다. 각 단계 설명은 보통 2~4문장으로 구성하고, 단계 버튼·키보드·부모 장표의 다음 동작은 모두 같은 순서로 이동합니다.</div>`;

    card.querySelectorAll('.cue-button').forEach((button) => {
      const target = Number(button.dataset.step);
      button.classList.toggle('done', target < stepIndex);
      button.classList.toggle('current', target === stepIndex && stepIndex > 0);
      button.classList.toggle('next', target === stepIndex + 1);
      button.disabled = target !== stepIndex + 1;
      button.addEventListener('click', requestNext);
    });

    history.replaceState(null, '', `#${slideIndex + 1}/${stepIndex}`);
  };

  const showState = (newSlide, newStep = 0, { notifyParent = true, scroll = true } = {}) => {
    const oldSlide = slideIndex;
    slideIndex = Math.max(0, Math.min(slides.length - 1, Number(newSlide) || 0));
    stepIndex = Math.max(0, Math.min(maxStep(slideIndex), Number(newStep) || 0));
    render();
    if (notifyParent) sendState();
    if (scroll && oldSlide !== slideIndex) window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const localNext = () => {
    if (stepIndex < maxStep()) showState(slideIndex, stepIndex + 1);
    else if (slideIndex < slides.length - 1) showState(slideIndex + 1, 0);
  };

  const localPrevious = () => {
    if (stepIndex > 0) showState(slideIndex, stepIndex - 1);
    else if (slideIndex > 0) showState(slideIndex - 1, maxStep(slideIndex - 1));
  };

  function requestNext() {
    if (send('request-next')) return;
    try {
      if (presentationWindow?.chapter02NextFromScript) {
        presentationWindow.chapter02NextFromScript();
        return;
      }
    } catch (_) {}
    localNext();
  }

  function requestPrevious() {
    if (send('request-prev')) return;
    try {
      if (presentationWindow?.chapter02PrevFromScript) {
        presentationWindow.chapter02PrevFromScript();
        return;
      }
    } catch (_) {}
    localPrevious();
  }

  window.setScriptState = (newSlide, newStep = 0) => showState(newSlide, newStep, { notifyParent: false });

  document.getElementById('prevPage').addEventListener('click', () => showState(slideIndex - 1, 0));
  document.getElementById('nextPage').addEventListener('click', () => showState(slideIndex + 1, 0));
  document.getElementById('focusSlides').addEventListener('click', () => {
    if (presentationWindow && !presentationWindow.closed) {
      presentationWindow.focus();
      sendState();
      return;
    }
    presentationWindow = window.open(`chapter02_presentation.html?v=20260808d#${slideIndex + 1}/${stepIndex}`, 'chapter02Presentation');
    if (presentationWindow) {
      presentationWindow.focus();
      setTimeout(() => send('script-ready'), 300);
    }
  });

  window.addEventListener('message', (event) => {
    const message = event.data || {};
    if (message.channel !== CHANNEL) return;
    if (event.source && !event.source.closed) presentationWindow = event.source;
    if (message.type === 'presentation-state') showState(message.slideIndex, message.stepIndex, { notifyParent: false, scroll: false });
  });

  window.addEventListener('keydown', (event) => {
    if (['ArrowRight', 'ArrowDown', ' ', 'PageDown'].includes(event.key)) {
      event.preventDefault();
      requestNext();
    } else if (['ArrowLeft', 'ArrowUp', 'PageUp'].includes(event.key)) {
      event.preventDefault();
      requestPrevious();
    } else if (event.key === 'Home') showState(0, 0);
    else if (event.key === 'End') showState(slides.length - 1, maxStep(slides.length - 1));
  });

  window.addEventListener('hashchange', () => {
    const parsed = parseHash();
    if (parsed.slideIndex !== slideIndex || parsed.stepIndex !== stepIndex) showState(parsed.slideIndex, parsed.stepIndex);
  });

  stepIndex = Math.max(0, Math.min(maxStep(slideIndex), initial.stepIndex));
  render();
  if (presentationWindow && !presentationWindow.closed) {
    send('script-ready');
    setTimeout(() => send('script-ready'), 250);
  }
})();
