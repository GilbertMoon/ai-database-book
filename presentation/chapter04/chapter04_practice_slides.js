(() => {
  const sources = [
    'chapter04_practice_slides_raw.js',
    'chapter04_content_patch.js',
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
    dispatchEvent(new Event('chapter04-slides-ready'));
  })().catch((error) => console.error('Chapter 04 실습 슬라이드 로드 실패', error));
})();
