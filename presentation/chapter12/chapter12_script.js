(() => {
  const CHANNEL = 'chapter12-presentation-sync';
  const card = document.getElementById('card');
  let block = document.body.dataset.chapter12Block === 'practice' ? 'practice' : 'theory';
  let slides = [];
  let slideIndex = 0;
  let stepIndex = 0;
  let ready = false;
  let presentationWindow = window.opener && !window.opener.closed ? window.opener : null;

  const escapeHtml = (value) => String(value || '').replace(/[&<>"']/g, (character) => ({
    '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;'
  }[character]));

  const ttsRules = [
    [/\bSource of Truth\b/g,'소스 오브 트루스'],[/\bRDBMS\b/g,'알 디 비 엠 에스'],[/\bNoSQL\b/g,'노 에스큐엘'],
    [/\bKey-Value\b/g,'키 밸류'],[/\bDocument\b/g,'도큐먼트'],[/\bColumn-Family\b/g,'컬럼 패밀리'],[/\bGraph DB\b/g,'그래프 디비'],
    [/\bJSONB\b/g,'제이슨 비'],[/\bJSON\b/g,'제이슨'],[/\bTTL\b/g,'티티엘'],[/\bPoC\b/g,'피오씨'],
    [/\bCURRENT_TIMESTAMP\b/g,'커런트 타임스탬프'],[/\bpartition key\b/gi,'파티션 키'],[/\bclustering key\b/gi,'클러스터링 키'],
    [/\bEphemeral State\b/g,'이페머럴 스테이트'],[/\bDerived Cache\b/g,'디라이브드 캐시'],
    [/\bFlexible Metadata\b/g,'플렉서블 메타데이터'],[/\bEvent Log\b/g,'이벤트 로그'],[/\bRelationship Index\b/g,'릴레이션십 인덱스'],
    [/\binstructor_snapshot\b/g,'인스트럭터 스냅샷'],[/\bsource_course_id\b/g,'소스 코스 아이디'],
    [/\bsource_instructor_id\b/g,'소스 인스트럭터 아이디'],[/\bdocument_version\b/g,'도큐먼트 버전'],
    [/\bcourse_documents\b/g,'코스 도큐먼츠'],[/\bkey_value_cache_examples\b/g,'키 밸류 캐시 이그잼플스'],
    [/\bstorage_choice_cases\b/g,'스토리지 초이스 케이시스'],[/\bnosql_lab\b/g,'노 에스큐엘 랩'],
    [/\bcourse_project\b/g,'코스 프로젝트'],[/\btransaction_lab\b/g,'트랜잭션 랩'],
    [/\bperformance_lab\b/g,'퍼포먼스 랩'],[/\bsecurity_lab\b/g,'시큐리티 랩'],
    [/\bMongoDB\b/g,'몽고디비'],[/\bRedis\b/g,'레디스'],[/\bCassandra\b/g,'카산드라'],
    [/\bPostgreSQL\b/g,'포스트그레스큐엘'],[/\bDBeaver\b/g,'디비버'],[/\bSQL\b/g,'에스큐엘'],[/\bAI\b/g,'에이아이']
  ];

  const ttsText = (value) => ttsRules.reduce(
    (result, [pattern, replacement]) => result.replace(pattern, replacement),
    String(value || '')
  );

  function segments(index = slideIndex) {
    const paragraphs = String(slides[index]?.s || '')
      .trim()
      .split(/\n\s*\n/)
      .map((value) => value.replace(/\s+/g, ' ').trim())
      .filter(Boolean);
    if (paragraphs.length > 1) return paragraphs;

    const sentences = (paragraphs[0]?.match(/[^.!?。]+[.!?。]?/g) || [])
      .map((value) => value.trim())
      .filter(Boolean);
    if (sentences.length <= 1) return paragraphs.length ? paragraphs : ['핵심 내용을 설명합니다.'];

    const size = Math.max(1, Math.ceil(sentences.length / 4));
    const result = [];
    for (let cursor = 0; cursor < sentences.length; cursor += size) {
      result.push(sentences.slice(cursor, cursor + size).join(' '));
    }
    return result;
  }

  const maxStep = (index = slideIndex) => Number(slides[index]?.steps || segments(index).length || 1);

  function parseHash() {
    const raw = location.hash.slice(1);
    if (!raw) return { slideIndex: 0, stepIndex: 0 };
    if (/^\d+$/.test(raw)) return { slideIndex: Math.max(0, Number(raw) - 1), stepIndex: 0 };
    const [hashBlock, slide, step] = raw.split('/');
    if (hashBlock === 'theory' || hashBlock === 'practice') block = hashBlock;
    return {
      slideIndex: Math.max(0, (Number(slide) || 1) - 1),
      stepIndex: Math.max(0, Number(step) || 0)
    };
  }

  function send(type, extra = {}) {
    if (!presentationWindow || presentationWindow.closed) return false;
    try {
      presentationWindow.postMessage({ channel: CHANNEL, type, block, ...extra }, '*');
      return true;
    } catch (error) {
      return false;
    }
  }

  const sendState = () => send('navigate-presentation', { slideIndex, stepIndex });
  const presentationFile = () => block === 'practice'
    ? 'chapter12_practice_presentation.html'
    : 'chapter12_theory_presentation.html';

  function render() {
    const slide = slides[slideIndex];
    if (!slide) return;

    const parts = segments();
    const page = String(slideIndex + 1).padStart(2, '0');
    const total = String(slides.length).padStart(2, '0');

    document.getElementById('topCounter').textContent = `${page} / ${total}`;
    document.getElementById('counter').textContent = `${page} / ${total}`;
    document.getElementById('state').textContent = stepIndex === 0 ? '전체 보기' : `강조 ${stepIndex} / ${maxStep()}`;
    document.getElementById('prevPage').disabled = slideIndex === 0;
    document.getElementById('nextPage').disabled = slideIndex === slides.length - 1;
    document.getElementById('theoryBlock').classList.toggle('active', block === 'theory');
    document.getElementById('practiceBlock').classList.toggle('active', block === 'practice');

    card.innerHTML = `<h1>${escapeHtml(slide.t || slide.l || '핵심 내용')}</h1><p class="meta">${escapeHtml(slide.k || 'CHAPTER 12')} · ${block === 'practice' ? '실습 강의' : '이론 강의'} · 파란 버튼은 장표 창의 다음 강조와 같습니다.</p>${parts.map((text, index) => `<div class="script-text"><p>${escapeHtml(ttsText(text))}</p></div><div class="cue"><span class="line"></span><button class="cue-button" type="button" data-step="${index + 1}">${index + 1}단계 진행</button><span class="line"></span></div>`).join('')}<div class="hint">장표와 팝업은 장표 번호와 강조 단계를 양방향으로 동기화합니다.</div>`;

    card.querySelectorAll('.cue-button').forEach((button) => {
      const target = Number(button.dataset.step);
      button.classList.toggle('done', target < stepIndex);
      button.classList.toggle('current', target === stepIndex && stepIndex > 0);
      button.classList.toggle('next', target === stepIndex + 1);
      button.disabled = target !== stepIndex + 1;
      button.onclick = requestNext;
    });

    history.replaceState(null, '', `?block=${block}#${block}/${slideIndex + 1}/${stepIndex}`);
  }

  function showState(newBlock, newSlide, newStep = 0, { notify = true } = {}) {
    if (newBlock && newBlock !== block) {
      switchData(newBlock, newSlide, newStep, { notify });
      return;
    }
    if (!slides.length) return;
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

  function localPrev() {
    if (stepIndex > 0) showState(block, slideIndex, stepIndex - 1);
    else if (slideIndex > 0) showState(block, slideIndex - 1, maxStep(slideIndex - 1));
  }

  function requestNext() {
    if (!send('request-next')) localNext();
  }

  function requestPrev() {
    if (!send('request-prev')) localPrev();
  }

  async function switchData(target, newSlide = 0, newStep = 0, { notify = true } = {}) {
    block = target === 'practice' ? 'practice' : 'theory';
    document.body.dataset.chapter12Block = block;
    slides = await window.loadChapter12Slides(block);
    slideIndex = Math.max(0, Math.min(slides.length - 1, Number(newSlide) || 0));
    stepIndex = Math.max(0, Math.min(maxStep(slideIndex), Number(newStep) || 0));
    ready = true;
    render();
    if (notify) sendState();
  }

  async function switchBlock(target) {
    if (target === block) return;
    presentationWindow = window.open(
      `${target === 'practice' ? 'chapter12_practice_presentation.html' : 'chapter12_theory_presentation.html'}#${target}/1/0`,
      'chapter12Presentation'
    );
    await switchData(target, 0, 0, { notify: false });
    setTimeout(sendState, 450);
  }

  window.setScriptState = (newBlock, newSlide, newStep = 0) => {
    showState(newBlock, newSlide, newStep, { notify: false });
  };

  addEventListener('message', (event) => {
    const data = event.data || {};
    if (data.channel !== CHANNEL) return;
    if (event.source && !event.source.closed) presentationWindow = event.source;
    if (data.type === 'presentation-state') {
      showState(data.block || block, data.slideIndex, data.stepIndex, { notify: false });
    }
  });

  document.getElementById('prevPage').onclick = () => showState(block, slideIndex - 1, 0);
  document.getElementById('nextPage').onclick = () => showState(block, slideIndex + 1, 0);
  document.getElementById('focusSlides').onclick = () => {
    if (presentationWindow && !presentationWindow.closed) {
      presentationWindow.focus();
      sendState();
      return;
    }
    presentationWindow = window.open(
      `${presentationFile()}#${block}/${slideIndex + 1}/${stepIndex}`,
      'chapter12Presentation'
    );
    if (presentationWindow) {
      presentationWindow.focus();
      setTimeout(sendState, 400);
    }
  };
  document.getElementById('theoryBlock').onclick = () => switchBlock('theory');
  document.getElementById('practiceBlock').onclick = () => switchBlock('practice');

  addEventListener('keydown', (event) => {
    if (!ready) return;
    if (['ArrowRight', 'ArrowDown', 'PageDown', ' '].includes(event.key)) {
      event.preventDefault();
      requestNext();
    } else if (['ArrowLeft', 'ArrowUp', 'PageUp'].includes(event.key)) {
      event.preventDefault();
      requestPrev();
    } else if (event.key === 'Home') showState(block, 0, 0);
    else if (event.key === 'End') showState(block, slides.length - 1, maxStep(slides.length - 1));
  });

  function initialize() {
    if (ready || !window.CH12_SLIDES?.length) return;
    slides = window.CH12_SLIDES;
    const initial = parseHash();
    slideIndex = Math.max(0, Math.min(slides.length - 1, initial.slideIndex));
    stepIndex = Math.max(0, Math.min(maxStep(slideIndex), initial.stepIndex));
    ready = true;
    render();
    send('script-ready');
  }

  addEventListener('chapter12-slides-ready', initialize, { once: true });
  addEventListener('chapter12-slides-error', () => {
    card.innerHTML = '<div class="loading">Chapter 12 강의 계획서를 불러오지 못했습니다.</div>';
  }, { once: true });

  initialize();
})();
