(() => {
  const CHANNEL = 'chapter03-presentation-sync';
  const app = document.getElementById('app');
  if (!app) return;
  if (!app.parentElement?.classList.contains('deck')) {
    const deck = document.createElement('div');
    deck.className = 'deck';
    app.parentNode.insertBefore(deck, app);
    deck.appendChild(app);
  }
  app.classList.add('view');

  const blockFromPage = document.body?.dataset?.chapter03Block === 'practice' ? 'practice' : 'theory';
  const blockLabel = blockFromPage === 'practice' ? '실습' : '이론';
  const scriptIcon = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3h9l3 3v15H6z"/><path d="M15 3v4h4M9 11h6M9 15h6"/></svg>';

  const style = document.createElement('style');
  style.textContent = `
:root{--p:#155eef;--s:#e8f0ff;--t:#182230;--m:#5d6b7a;--b:#d9e1ea;--a:#f59e0b;--bg:#f6f8fb;--ok:#067647;--ok-soft:#ecfdf3}
*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#0f1720;color:var(--t);font-family:Pretendard,'Noto Sans KR','Malgun Gothic',sans-serif}button{font:inherit}.deck{position:fixed;inset:0;display:grid;place-items:center;background:radial-gradient(circle at top left,rgba(21,94,239,.18),transparent 34%),radial-gradient(circle at bottom right,rgba(245,158,11,.14),transparent 28%),#0f1720}.view{position:relative;width:min(100vw,calc(100vh*16/9));height:min(100vh,calc(100vw*9/16));background:var(--bg);overflow:hidden;box-shadow:0 18px 45px rgba(20,33,50,.18)}.slide{position:absolute;inset:0;display:flex;flex-direction:column;padding:54px 78px 72px;background:linear-gradient(180deg,#fff,#f6f8fb)}.slide:before{content:'';position:absolute;inset:0 0 auto;height:10px;background:linear-gradient(90deg,var(--p),#4f8cff 70%,var(--a))}.head{display:flex;justify-content:space-between;align-items:center;gap:22px;min-height:52px;margin-bottom:18px}.k{color:var(--p);font-weight:900;font-size:18px;letter-spacing:.02em}.head-actions{display:flex;align-items:center;gap:10px}.l{padding:8px 14px;border:1px solid var(--b);border-radius:999px;color:var(--m);font-size:15px;font-weight:850;background:#fff}.counter{color:var(--m);font-size:15px;font-weight:850}.script-icon{width:36px;height:36px;padding:8px;border:1px solid var(--b);border-radius:10px;background:#fff;color:var(--m);cursor:pointer;display:grid;place-items:center}.script-icon:hover{color:var(--p);border-color:#b9ccff;background:var(--s)}.script-icon svg{width:18px;height:18px;fill:none;stroke:currentColor;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round}.body{flex:1;display:flex;flex-direction:column;justify-content:center;max-width:1380px;width:100%;margin:auto;min-height:0}h1{font-size:70px;line-height:1.12;letter-spacing:-.045em;margin:0 0 22px}h2{font-size:50px;line-height:1.18;letter-spacing:-.035em;margin:0 0 22px}h3{font-size:29px;margin:0 0 10px}.lead,.body-text{color:var(--m);font-size:29px;line-height:1.55;margin:0 0 20px}.title-meta,.chips{display:flex;gap:12px;flex-wrap:wrap;margin-top:22px}.pill,.chip{padding:10px 16px;border-radius:999px;background:var(--s);color:var(--p);font-size:18px;font-weight:900}.chip{font-size:22px;background:#fff;border:1px solid var(--b)}.grid-2,.grid-3{display:grid;gap:22px}.grid-2{grid-template-columns:repeat(2,1fr)}.grid-3{grid-template-columns:repeat(3,1fr)}.card{min-height:150px;padding:22px 25px;border:1px solid var(--b);border-radius:26px;background:#fff;box-shadow:0 9px 24px rgba(33,50,73,.07);font-size:23px;line-height:1.45}.card p{margin:0;color:var(--m);font-size:23px;line-height:1.45}.emphasis,.current{background:var(--s)!important;border-color:rgba(21,94,239,.3)!important}.warn{background:#fff7ed!important;border-color:#fed7aa!important}.done{background:#e9f8ef!important;border-color:#b8e1c5!important}.number{display:inline-grid;place-items:center;min-width:46px;height:46px;padding:0 12px;margin-bottom:12px;border-radius:14px;background:var(--p);color:#fff;font-weight:900}.bullet-list{display:grid;gap:13px;list-style:none;padding:0;margin:0}.bullet-list li{position:relative;padding-left:32px;font-size:27px;line-height:1.46}.bullet-list li:before{content:'';position:absolute;left:3px;top:.62em;width:12px;height:12px;border-radius:50%;background:var(--p);box-shadow:0 0 0 6px var(--s)}.quote{padding:30px 38px;border-left:9px solid var(--p);background:var(--s);border-radius:0 26px 26px 0;font-size:37px;font-weight:900;line-height:1.5}.flow,.road-flow,.path-chain{display:flex;align-items:stretch;gap:12px}.flow-step,.road-step,.path-node{flex:1;display:grid;place-items:center;min-height:124px;padding:16px;border:1px solid var(--b);border-radius:22px;background:#fff;text-align:center;font-size:21px;font-weight:900;line-height:1.35}.flow-arrow,.road-arrow,.path-arrow{display:grid;place-items:center;color:var(--p);font-size:33px}.step-box{padding:26px 30px;border:1px solid var(--b);border-radius:26px;background:#fff}.step-box h3{color:var(--p)}.hierarchy{display:grid;gap:11px;max-width:980px;margin:0 auto;width:100%}.hierarchy>div{padding:15px 24px;border:1px solid var(--b);border-radius:17px;background:#fff;text-align:center;font-size:27px;font-weight:900}.hierarchy>div:nth-child(2n){background:var(--s)}pre,.prompt-box,.codebox{padding:24px 30px;border-radius:22px;background:#101820;color:#eef7ff;white-space:pre-wrap;overflow:auto;font:22px/1.55 Consolas,'D2Coding',monospace}.prompt-box{font-family:inherit;font-size:27px;font-weight:700;line-height:1.55}.smallcode{font-size:20px;margin-top:14px}.table-wrap{overflow:hidden;border:1px solid var(--b);border-radius:22px;background:#fff}table{width:100%;border-collapse:collapse}th,td{padding:13px 16px;border-bottom:1px solid var(--b);text-align:left;font-size:21px;line-height:1.4}th{background:#eef3f8;font-weight:900}tr:last-child td{border-bottom:0}.activity-box,.activity,.scenario,.relation-line,.media-frame,.legend,.band,.warning,.answer-band,.return-line,.small-note,.next-band{border:1px solid var(--b);border-radius:18px;background:#fff}.activity-box,.activity{padding:20px 24px}.scenario,.relation-line,.band,.warning,.answer-band,.return-line,.small-note,.next-band{padding:14px 18px}.object-row,.review-grid,.type-grid,.key-grid,.activity-grid,.media-grid{display:grid;gap:14px}.object-row{grid-template-columns:repeat(4,1fr)}.review-grid,.key-grid,.activity-grid{grid-template-columns:repeat(2,1fr)}.type-grid{grid-template-columns:repeat(4,1fr)}.media-grid{grid-template-columns:1.35fr .65fr}.object-row>span,.review-grid>span,.type-card,.key-card,.role-card,.id-card,.legend{padding:14px;border:1px solid var(--b);border-radius:15px;background:#fff}.focus-target{transition:opacity .25s ease,transform .25s ease,box-shadow .25s ease,border-color .25s ease,filter .25s ease}.focus-muted{opacity:.2;transform:scale(.986);filter:saturate(.55)}.focus-active{opacity:1;transform:scale(1.016);border-color:var(--p)!important;box-shadow:0 0 0 5px rgba(21,94,239,.12),0 15px 30px rgba(21,94,239,.15)!important;position:relative;z-index:4}.ctrl{position:absolute;right:24px;bottom:20px;display:flex;gap:9px;z-index:10}.btn{width:48px;height:48px;border:0;border-radius:14px;background:rgba(15,23,32,.82);color:#fff;font-size:23px;font-weight:900;cursor:pointer}.btn:disabled{opacity:.35;cursor:default}.home{position:absolute;left:138px;bottom:25px;height:34px;padding:0 14px;border:1px solid var(--b);border-radius:999px;background:#fff;color:var(--m);font-weight:800;text-decoration:none;display:grid;place-items:center}.num{position:absolute;left:26px;bottom:29px;min-width:100px;color:var(--m);font-size:16px;font-weight:850}.step-state{position:absolute;left:50%;bottom:23px;transform:translateX(-50%);padding:7px 12px;border:1px solid var(--b);border-radius:999px;background:rgba(255,255,255,.95);color:var(--m);font-size:13px;font-weight:850;z-index:10}.track{position:absolute;left:0;right:0;bottom:0;height:7px;background:rgba(24,34,48,.1)}.bar{height:100%;background:linear-gradient(90deg,var(--p),var(--a))}.loading{min-height:100vh;display:grid;place-items:center;color:#fff;font-size:22px;font-weight:800}@media(max-width:900px){.grid-2,.grid-3,.type-grid,.object-row,.media-grid{grid-template-columns:1fr}.flow,.road-flow,.path-chain{flex-direction:column}.flow-arrow,.road-arrow,.path-arrow{transform:rotate(90deg)}}@media print{html,body{overflow:visible;background:#fff}.deck{position:static;display:block;background:#fff}.view{width:auto;height:auto;overflow:visible;box-shadow:none}.slide{position:relative;width:1600px;height:900px;page-break-after:always}.ctrl,.script-icon,.num,.home,.step-state,.track{display:none!important}.focus-muted{opacity:1;transform:none;filter:none}}
`;
  document.head.appendChild(style);

  const parseHash = () => {
    const raw = location.hash.slice(1);
    if (!raw) return { slideIndex: 0, stepIndex: 0 };
    if (/^\d+$/.test(raw)) return { slideIndex: Math.max(0, Number(raw) - 1), stepIndex: 0 };
    const [hashBlock, slide, step] = raw.split('/');
    if (hashBlock && hashBlock !== blockFromPage) return { slideIndex: 0, stepIndex: 0 };
    return {
      slideIndex: Math.max(0, (Number(slide) || 1) - 1),
      stepIndex: Math.max(0, Number(step) || 0)
    };
  };

  let slides = [];
  let deckTitle = 'Chapter 03';
  let slideIndex = 0;
  let stepIndex = 0;
  let scriptWindow = null;

  const segments = (slide) => {
    const raw = String(slide?.s || '').trim();
    const parts = raw.split(/\n\s*\n/).map((value) => value.replace(/\s+/g, ' ').trim()).filter(Boolean);
    return parts;
  };

  const maxStep = (index = slideIndex) => Number(slides[index]?.steps || segments(slides[index]).length || 1);

  const unique = (items) => [...new Set(items)];
  const semanticTargets = (root) => {
    const explicit = [...root.querySelectorAll('[data-focus-step]')];
    if (explicit.length) return explicit;
    const selectors = [
      '.card', '.flow-step', '.road-step', '.path-node', '.bullet-list li',
      '.table-wrap tbody tr', '.step-box', '.hierarchy > div', '.quote', '.prompt-box',
      'pre', '.codebox', '.activity-box', '.activity', '.scenario', '.relation-line',
      '.media-frame', '.legend', '.object-row > span', '.review-grid > span', '.type-card',
      '.key-card', '.role-card', '.id-card', '.band', '.warning', '.answer-band',
      '.return-line', '.small-note', '.next-band', '.pill', '.chip'
    ];
    let candidates = unique(selectors.flatMap((selector) => [...root.querySelectorAll(selector)]));
    candidates = candidates.filter((element) => !candidates.some((other) => other !== element && element.contains(other)));
    if (!candidates.length) {
      candidates = [...root.children].filter((element) => !['H1', 'H2'].includes(element.tagName));
    }
    return candidates;
  };

  const prepareFocus = () => {
    const root = app.querySelector('.body');
    if (!root) return;
    const targets = semanticTargets(root);
    const total = Math.max(1, maxStep());
    targets.forEach((element, index) => {
      element.classList.add('focus-target');
      if (!element.dataset.focusStep) {
        const start = Math.floor(index * total / Math.max(1, targets.length)) + 1;
        const end = Math.max(start, Math.floor((index + 1) * total / Math.max(1, targets.length)));
        element.dataset.focusFrom = String(Math.min(total, start));
        element.dataset.focusTo = String(Math.min(total, end));
      }
    });
  };

  const applyFocus = () => {
    const root = app.querySelector('.body');
    if (!root) return;
    const targets = [...root.querySelectorAll('[data-focus-step],[data-focus-from]')];
    targets.forEach((element) => {
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

  const hashValue = () => `#${blockFromPage}/${slideIndex + 1}/${stepIndex}`;

  const render = () => {
    const slide = slides[slideIndex];
    if (!slide) return;
    app.innerHTML = `<section class="slide"><div class="head"><span class="k">${slide.k || ''}</span><div class="head-actions"><span class="l">${slide.l || blockLabel}</span><span class="counter">${String(slideIndex + 1).padStart(2, '0')} / ${String(slides.length).padStart(2, '0')}</span><button class="script-icon" id="scriptButton" type="button" title="발표 스크립트 열기" aria-label="현재 슬라이드 발표 스크립트 창 열기">${scriptIcon}</button></div></div><div class="body">${slide.h || ''}</div></section><a class="home" href="index.html">목차</a><div class="num">Chapter 03 · ${blockLabel}</div><div class="step-state" id="state" aria-live="polite"></div><nav class="ctrl"><button class="btn" id="previousButton" aria-label="이전 강조 또는 슬라이드">←</button><button class="btn" id="nextButton" aria-label="다음 강조 또는 슬라이드">→</button></nav><div class="track"><div class="bar" style="width:${((slideIndex + 1) / slides.length) * 100}%"></div></div>`;
    document.getElementById('previousButton').onclick = previous;
    document.getElementById('nextButton').onclick = next;
    document.getElementById('scriptButton').onclick = (event) => { event.stopPropagation(); openScript(); };
    prepareFocus();
    applyFocus();
    updateButtons();
    history.replaceState(null, '', hashValue());
    document.title = `${slideIndex + 1}/${slides.length} · ${deckTitle}`;
  };

  const sendStateToScript = () => {
    if (!scriptWindow || scriptWindow.closed) return;
    try {
      scriptWindow.postMessage({ channel: CHANNEL, type: 'presentation-state', block: blockFromPage, slideIndex, stepIndex }, '*');
    } catch (error) {
      try { scriptWindow.setScriptState?.(blockFromPage, slideIndex, stepIndex); } catch (ignore) {}
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
    const url = `chapter03_script.html?block=${blockFromPage}#${blockFromPage}/${slideIndex + 1}/${stepIndex}`;
    if (scriptWindow && !scriptWindow.closed) {
      scriptWindow.focus();
      sendStateToScript();
      return;
    }
    scriptWindow = window.open(url, 'chapter03Script', 'width=900,height=960,resizable=yes,scrollbars=yes');
    if (scriptWindow) {
      scriptWindow.focus();
      setTimeout(sendStateToScript, 250);
      setTimeout(sendStateToScript, 700);
    }
  };

  const initialize = () => {
    slides = window.CH3_SLIDES || [];
    deckTitle = window.CH3_TITLE || `Chapter 03 ${blockLabel} 강의`;
    if (!slides.length) {
      app.innerHTML = '<div class="loading">Chapter 03 슬라이드 데이터를 불러오는 중입니다.</div>';
      return false;
    }
    const initial = parseHash();
    slideIndex = Math.min(slides.length - 1, initial.slideIndex);
    stepIndex = Math.min(maxStep(slideIndex), initial.stepIndex);
    render();
    return true;
  };

  window.setSlideFromScript = (block, newSlide, newStep = 0) => {
    if (block && block !== blockFromPage) return;
    showState(newSlide, newStep, { notifyChild: false });
  };
  window.chapter03NextFromScript = next;
  window.chapter03PrevFromScript = previous;

  addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.channel !== CHANNEL) return;
    if (event.source && !event.source.closed) scriptWindow = event.source;
    if (data.block && data.block !== blockFromPage) return;
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
    else if (event.key.toLowerCase() === 'f') {
      document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen?.();
    }
  });

  app.addEventListener('click', (event) => {
    if (event.target.closest('button') || event.target.closest('a')) return;
    const rect = app.getBoundingClientRect();
    event.clientX - rect.left < rect.width * 0.32 ? previous() : next();
  });

  addEventListener('hashchange', () => {
    const parsed = parseHash();
    if (parsed.slideIndex !== slideIndex || parsed.stepIndex !== stepIndex) {
      showState(parsed.slideIndex, parsed.stepIndex);
    }
  });

  if (!initialize()) {
    addEventListener('chapter03-slides-ready', initialize, { once: true });
    setTimeout(initialize, 600);
  }
})();
