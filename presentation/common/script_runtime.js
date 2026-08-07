(() => {
  const data = window.CHAPTER_DATA;
  const root = document.getElementById('script-app');
  if (!data || !root) throw new Error('CHAPTER_DATA와 #script-app이 필요합니다.');
  let state = { slideIndex: 0, stepIndex: 0 };

  function navigate(slideIndex, stepIndex) {
    state = { slideIndex, stepIndex };
    window.opener?.postMessage({ type: 'script-navigate', ...state }, '*');
    render(false);
  }

  function render(scroll = true) {
    const slide = data.slides[state.slideIndex];
    const steps = slide.steps || [];
    root.innerHTML = `<header class="script-header"><div><strong>${slide.part === 0 ? '시작' : `Part ${slide.part}`}</strong><span>${state.slideIndex + 1} / ${data.slides.length} · 단계 ${state.stepIndex + 1}/${Math.max(steps.length, 1)}</span></div><h1>${slide.title}</h1></header>
      <main class="script-content"><section><h2>발표 스크립트</h2><p>${slide.script}</p></section>
      <section><h2>강조 큐</h2>${steps.map((step, index) => `<article class="script-step ${index === state.stepIndex ? 'active' : ''}"><button class="cue-button" data-step="${index}" aria-label="${step.label} 강조" data-tts-skip="true">▶</button><div><strong>${step.label}</strong><p>${step.script}</p>${step.pointerNote ? `<small>포인터: ${step.pointerNote}</small>` : ''}</div></article>`).join('')}</section></main>
      <footer><button id="script-prev" aria-label="이전 슬라이드">이전</button><button id="script-next" aria-label="다음 슬라이드">다음</button></footer>`;
    root.querySelectorAll('.cue-button').forEach((button) => button.onclick = () => navigate(state.slideIndex, Number(button.dataset.step)));
    document.getElementById('script-prev').onclick = () => navigate(Math.max(0, state.slideIndex - 1), 0);
    document.getElementById('script-next').onclick = () => navigate(Math.min(data.slides.length - 1, state.slideIndex + 1), 0);
    if (scroll) root.querySelector('.script-step.active')?.scrollIntoView({ block: 'nearest' });
  }

  window.addEventListener('message', (event) => {
    if (event.data?.type !== 'presentation-state') return;
    const slideChanged = state.slideIndex !== event.data.slideIndex;
    state = { slideIndex: event.data.slideIndex, stepIndex: event.data.stepIndex };
    render(slideChanged);
  });
  document.addEventListener('keydown', (event) => {
    if (['ArrowRight', 'PageDown'].includes(event.key)) document.getElementById('script-next').click();
    if (['ArrowLeft', 'PageUp'].includes(event.key)) document.getElementById('script-prev').click();
  });
  render(false);
  window.opener?.postMessage({ type: 'script-ready' }, '*');
})();
