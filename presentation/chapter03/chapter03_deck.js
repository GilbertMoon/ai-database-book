(() => {
  const slides = window.CH3_SLIDES || [];
  const deckTitle = window.CH3_TITLE || 'Chapter 03';
  const app = document.getElementById('app');
  if (!app || !slides.length) return;

  const style = document.createElement('style');
  style.textContent = `
:root{--p:#155eef;--s:#e8f0ff;--t:#182230;--m:#5d6b7a;--b:#d9e1ea;--a:#f59e0b;--bg:#f6f8fb}*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#0f1720;color:var(--t);font-family:Pretendard,'Noto Sans KR','Malgun Gothic',sans-serif}body{cursor:none}.native{cursor:auto}.deck{position:fixed;inset:0;display:grid;place-items:center;background:radial-gradient(circle at top left,rgba(21,94,239,.18),transparent 34%),radial-gradient(circle at bottom right,rgba(245,158,11,.14),transparent 28%),#0f1720}.view{position:relative;width:min(100vw,calc(100vh*16/9));height:min(100vh,calc(100vw*9/16));background:var(--bg);overflow:hidden;box-shadow:0 18px 45px rgba(20,33,50,.18)}.slide{position:absolute;inset:0;display:flex;flex-direction:column;padding:60px 84px 74px;background:linear-gradient(180deg,#fff,#f6f8fb)}.slide:before{content:'';position:absolute;inset:0 0 auto;height:10px;background:linear-gradient(90deg,var(--p),#4f8cff 70%,var(--a))}.head{display:flex;justify-content:space-between;align-items:center;gap:22px;min-height:58px;margin-bottom:24px}.k{color:var(--p);font-weight:900;font-size:20px;letter-spacing:.02em}.l{padding:10px 18px;border:1px solid var(--b);border-radius:999px;color:var(--m);font-size:18px;font-weight:800;background:#fff}.body{flex:1;display:flex;flex-direction:column;justify-content:center;max-width:1380px;width:100%;margin:auto}h1{font-size:76px;line-height:1.12;letter-spacing:-.045em;margin:0 0 24px}h2{font-size:54px;line-height:1.18;letter-spacing:-.035em;margin:0 0 24px}h3{font-size:32px;margin:0 0 10px}.lead,.body-text{color:var(--m);font-size:32px;line-height:1.55;margin:0 0 22px}.title-meta,.chips{display:flex;gap:14px;flex-wrap:wrap;margin-top:24px}.pill,.chip{padding:12px 18px;border-radius:999px;background:var(--s);color:var(--p);font-size:21px;font-weight:900}.chip{font-size:25px;background:#fff;border:1px solid var(--b)}.grid-2,.grid-3{display:grid;gap:24px}.grid-2{grid-template-columns:repeat(2,1fr)}.grid-3{grid-template-columns:repeat(3,1fr)}.card{min-height:160px;padding:24px 27px;border:1px solid var(--b);border-radius:28px;background:#fff;box-shadow:0 9px 24px rgba(33,50,73,.07);font-size:25px;line-height:1.45}.card p{margin:0;color:var(--m);font-size:25px;line-height:1.45}.emphasis,.current{background:var(--s)!important;border-color:rgba(21,94,239,.3)!important}.warn{background:#fff7ed!important;border-color:#fed7aa!important}.done{background:#e9f8ef!important;border-color:#b8e1c5!important}.number{display:inline-grid;place-items:center;min-width:48px;height:48px;padding:0 12px;margin-bottom:14px;border-radius:15px;background:var(--p);color:#fff;font-weight:900}.bullet-list{display:grid;gap:14px;list-style:none;padding:0;margin:0}.bullet-list li{position:relative;padding-left:34px;font-size:29px;line-height:1.48}.bullet-list li:before{content:'';position:absolute;left:3px;top:.62em;width:13px;height:13px;border-radius:50%;background:var(--p);box-shadow:0 0 0 7px var(--s)}.quote{padding:34px 42px;border-left:10px solid var(--p);background:var(--s);border-radius:0 28px 28px 0;font-size:40px;font-weight:900;line-height:1.52}.flow{display:flex;align-items:stretch;gap:14px}.flow-step{flex:1;display:grid;place-items:center;min-height:135px;padding:18px;border:1px solid var(--b);border-radius:24px;background:#fff;text-align:center;font-size:23px;font-weight:900;line-height:1.35}.flow-arrow{display:grid;place-items:center;color:var(--p);font-size:36px}.step-box{padding:28px 34px;border:1px solid var(--b);border-radius:28px;background:#fff}.step-box h3{color:var(--p)}.hierarchy{display:grid;gap:12px;max-width:980px;margin:0 auto;width:100%}.hierarchy div{padding:17px 26px;border:1px solid var(--b);border-radius:18px;background:#fff;text-align:center;font-size:29px;font-weight:900}.hierarchy div:nth-child(2n){background:var(--s)}pre,.prompt-box,.codebox{padding:26px 32px;border-radius:24px;background:#101820;color:#eef7ff;white-space:pre-wrap;overflow:auto;font:24px/1.55 Consolas,'D2Coding',monospace}.prompt-box{font-family:inherit;font-size:30px;font-weight:700;line-height:1.55}.smallcode{font-size:22px;margin-top:16px}.table-wrap{overflow:hidden;border:1px solid var(--b);border-radius:24px;background:#fff}table{width:100%;border-collapse:collapse}th,td{padding:15px 18px;border-bottom:1px solid var(--b);text-align:left;font-size:23px;line-height:1.42}th{background:#eef3f8;font-weight:900}tr:last-child td{border-bottom:0}.btn{width:48px;height:48px;border:0;border-radius:15px;background:rgba(15,23,32,.78);color:#fff;font-size:23px;font-weight:900;cursor:pointer}.ctrl{position:absolute;right:24px;bottom:22px;display:flex;gap:10px;z-index:10}.sbtn{position:absolute;left:28px;bottom:24px;width:34px;height:34px;border:1px solid rgba(21,94,239,.35);border-radius:50%;background:#fff;color:var(--p);font-weight:900;z-index:10;cursor:pointer}.home{position:absolute;left:112px;bottom:24px;height:34px;padding:0 14px;border:1px solid var(--b);border-radius:999px;background:#fff;color:var(--m);font-weight:800;text-decoration:none;display:grid;place-items:center}.num{position:absolute;left:74px;bottom:29px;color:var(--m);font-size:18px;font-weight:800}.track{position:absolute;left:0;right:0;bottom:0;height:7px;background:rgba(24,34,48,.1)}.bar{height:100%;background:linear-gradient(90deg,var(--p),var(--a))}.ov{position:absolute;inset:0;display:none;place-items:center;padding:40px;background:rgba(8,13,20,.78);z-index:100}.ov.open{display:grid}.panel{width:min(1040px,92%);max-height:84%;overflow:auto;padding:38px 42px;border-radius:28px;background:#fff}.panel h2{font-size:38px;margin:0 0 20px}.script p{font-size:27px;line-height:1.75;color:#263445;margin:0 0 18px}.cursor,.halo{position:fixed;z-index:9999;pointer-events:none;transform:translate(-50%,-50%);border-radius:50%;opacity:0}.cursor{width:15px;height:15px;background:#ff2f2f;box-shadow:0 0 0 4px #fff,0 0 18px rgba(255,47,47,.8)}.halo{width:62px;height:62px;border:3px solid rgba(255,47,47,.88);background:rgba(255,47,47,.08)}body.ready:not(.native) .cursor,body.ready:not(.native) .halo{opacity:1}@media(max-width:900px){.grid-2,.grid-3{grid-template-columns:1fr}.flow{flex-direction:column}.flow-arrow{transform:rotate(90deg)}}`;
  document.head.appendChild(style);

  document.body.innerHTML = `<div class="deck"><main class="view" id="view"></main></div><div class="halo" id="halo"></div><div class="cursor" id="cursor"></div>`;
  const view = document.getElementById('view');
  const cursor = document.getElementById('cursor');
  const halo = document.getElementById('halo');
  let index = Math.max(0, Math.min((parseInt(location.hash.slice(1)) || 1) - 1, slides.length - 1));

  const paragraphs = (value) => String(value || '').split(/\n\s*\n/).map((p) => `<p>${p.trim()}</p>`).join('');
  const render = () => {
    const slide = slides[index];
    view.innerHTML = `<section class="slide"><div class="head"><span class="k">${slide.k}</span><span class="l">${slide.l}</span></div><div class="body">${slide.h}</div></section><button class="sbtn" id="scriptButton">s</button><a class="home" href="index.html">목차</a><div class="num">${index + 1} / ${slides.length}</div><nav class="ctrl"><button class="btn" id="prevButton">←</button><button class="btn" id="nextButton">→</button></nav><div class="track"><div class="bar" style="width:${((index + 1) / slides.length) * 100}%"></div></div><div class="ov" id="scriptOverlay"><div class="panel"><h2>${deckTitle} · 스크립트 ${index + 1}장</h2><div class="script">${paragraphs(slide.s)}</div></div></div>`;
    location.hash = index + 1;
    document.title = `${index + 1}/${slides.length} · ${deckTitle}`;
    document.getElementById('prevButton').onclick = previous;
    document.getElementById('nextButton').onclick = next;
    document.getElementById('scriptButton').onclick = (event) => { event.stopPropagation(); document.getElementById('scriptOverlay').classList.add('open'); };
    document.getElementById('scriptOverlay').onclick = (event) => { if (event.target.id === 'scriptOverlay') event.target.classList.remove('open'); };
  };
  const next = () => { if (index < slides.length - 1) { index += 1; render(); } };
  const previous = () => { if (index > 0) { index -= 1; render(); } };

  document.addEventListener('keydown', (event) => {
    const key = event.key.toLowerCase();
    if (key === 'escape') { document.getElementById('scriptOverlay')?.classList.remove('open'); return; }
    if (['arrowright', 'arrowdown', 'pagedown', ' '].includes(key)) { event.preventDefault(); next(); }
    else if (['arrowleft', 'arrowup', 'pageup'].includes(key)) { event.preventDefault(); previous(); }
    else if (key === 'home') { index = 0; render(); }
    else if (key === 'end') { index = slides.length - 1; render(); }
    else if (key === 's') document.getElementById('scriptButton')?.click();
    else if (key === 'f') { document.fullscreenElement ? document.exitFullscreen() : view.requestFullscreen?.(); }
    else if (key === 'c') document.body.classList.toggle('native');
  });
  view.addEventListener('click', (event) => {
    if (event.target.closest('button') || event.target.closest('a') || event.target.closest('.panel')) return;
    const rect = view.getBoundingClientRect();
    event.clientX - rect.left < rect.width * 0.32 ? previous() : next();
  });
  document.addEventListener('mousemove', (event) => {
    document.body.classList.add('ready');
    cursor.style.left = event.clientX + 'px'; cursor.style.top = event.clientY + 'px';
    halo.style.left = event.clientX + 'px'; halo.style.top = event.clientY + 'px';
  });
  window.addEventListener('hashchange', () => {
    const n = parseInt(location.hash.slice(1));
    if (n && n - 1 !== index) { index = Math.max(0, Math.min(n - 1, slides.length - 1)); render(); }
  });
  render();
})();