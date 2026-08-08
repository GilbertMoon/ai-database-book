(() => {
  const sources = [
    'chapter03_theory_slides_raw.js?v=20260808f',
    'chapter03_intro_patch.js?v=20260808f',
    'chapter03_theory_script_expansion.js?v=20260808f',
    '../common/screen_position_patch.js?v=20260808f',
    'chapter03_semantic_plan.js?v=20260808f'
  ];
  const load = (src) => new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = src;
    script.onload = resolve;
    script.onerror = reject;
    document.head.appendChild(script);
  });
  (async () => {
    for (const src of sources) await load(src);
    dispatchEvent(new Event('chapter03-slides-ready'));
  })().catch((error) => console.error('Chapter 03 이론 슬라이드 로드 실패', error));
})();