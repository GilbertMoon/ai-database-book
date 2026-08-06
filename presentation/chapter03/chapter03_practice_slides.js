(() => {
  const sources = [
    'chapter03_practice_slides_raw.js',
    'chapter03_practice_script_expansion.js',
    '../common/screen_position_patch.js'
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
  })().catch((error) => console.error('Chapter 03 실습 슬라이드 로드 실패', error));
})();
