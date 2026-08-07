(() => {
  'use strict';

  const slides = window.CH1_SLIDES || [];
  if (!slides.length) return;

  const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (char) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[char]);

  // 화면과 스크립트의 내용이 달랐던 두 장표를 바로잡습니다.
  if (slides[12]) {
    slides[12].h = `<h2>데이터베이스를 배워야 하는 이유는<br>다섯 가지로 정리됩니다</h2>
<div class="grid-2">
  <article class="card"><h3>에이아이 결과 검증</h3><p class="small">이 숫자가 요구사항에 맞는가</p></article>
  <article class="card"><h3>업무 구조 표현</h3><p class="small">사용자, 주문, 강의, 신청은 어떻게 연결되는가</p></article>
  <article class="card"><h3>정확한 분석</h3><p class="small">중복, 누락, 널, 집계 기준이 올바른가</p></article>
  <article class="card"><h3>서비스 운영</h3><p class="small">사용자, 권한, 상태, 실행 이력과 검토 기록을 어떻게 관리하는가</p></article>
  <article class="card emphasis" style="grid-column:1/-1"><h3>안전성과 복구</h3><p class="small">잘못된 변경을 막고 문제가 생겼을 때 되돌릴 수 있는가</p></article>
</div>`;
  }

  if (slides[46]) {
    slides[46].h = `<h2>오해를 실제 문장으로 바꾸어<br>확인합니다</h2>
<div class="grid-2">
  <article class="card"><h3>오해 1</h3><p class="small">에스큐엘이 실행되면 맞다.</p></article>
  <article class="card emphasis"><h3>수정 1</h3><p class="small">실행 후에도 요구사항, 기준과 검산이 필요하다.</p></article>
  <article class="card"><h3>오해 2</h3><p class="small">에이아이가 만들면 충분하다.</p></article>
  <article class="card emphasis"><h3>수정 2</h3><p class="small">에이아이 초안은 사람이 근거를 확인하고 승인해야 한다.</p></article>
  <article class="card"><h3>오해 3</h3><p class="small">데이터가 많아야만 데이터베이스가 필요하다.</p></article>
  <article class="card emphasis"><h3>수정 3</h3><p class="small">데이터가 적어도 관계, 권한, 이력과 복구가 중요하면 데이터베이스가 필요할 수 있다.</p></article>
</div>`;
  }

  const STOP_WORDS = new Set([
    '이번', '장표', '에서는', '입니다', '있습니다', '합니다', '됩니다', '그리고', '하지만', '따라서',
    '먼저', '다음', '마지막', '정리하면', '중요한', '내용', '확인', '살펴보겠습니다', '살펴봅니다',
    '수', '것', '때', '이', '그', '저', '한', '두', '세', '네', '다섯', '첫째', '둘째', '셋째', '넷째', '다섯째'
  ]);

  const TARGET_SPECS = [
    ['.course-item', 'course'],
    ['.card', 'card'],
    ['.bullet-list li', 'item'],
    ['.flow-step', 'flow'],
    ['table tbody tr', 'row'],
    ['.activity-box li', 'activity'],
    ['pre .code-line', 'code'],
    ['.prompt-box', 'prompt'],
    ['.quote', 'quote'],
    ['.chip', 'chip'],
    ['.pill', 'pill'],
    ['.question-mark', 'question']
  ];

  const splitParagraphs = (value) => {
    const raw = String(value || '').trim();
    if (!raw) return ['핵심 내용을 설명합니다.'];
    const paragraphs = raw.split(/\n\s*\n/).map((part) => part.replace(/\s+/g, ' ').trim()).filter(Boolean);
    if (paragraphs.length > 1) return paragraphs;
    const sentences = (raw.match(/[^.!?。]+[.!?。]?/g) || []).map((part) => part.trim()).filter(Boolean);
    if (sentences.length <= 2) return [raw.replace(/\s+/g, ' ').trim()];
    const grouped = [];
    for (let index = 0; index < sentences.length; index += 2) grouped.push(sentences.slice(index, index + 2).join(' '));
    return grouped;
  };

  const normalizeForMatch = (value) => String(value || '')
    .toLowerCase()
    .replace(/에이아이/g, 'ai')
    .replace(/에스큐엘/g, 'sql')
    .replace(/포스트그레스큐엘/g, 'postgresql')
    .replace(/디비엠에스/g, 'dbms')
    .replace(/이너 조인/g, 'inner join')
    .replace(/조인/g, 'join')
    .replace(/널/g, 'null')
    .replace(/카운트 별표/g, 'count')
    .replace(/학생 에이/g, '학생 a')
    .replace(/학생 비/g, '학생 b')
    .replace(/학생 씨/g, '학생 c')
    .replace(/[^0-9a-z가-힣]+/g, ' ')
    .trim();

  const tokensOf = (value) => new Set(normalizeForMatch(value).split(/\s+/).filter((token) => {
    if (!token || STOP_WORDS.has(token)) return false;
    if (/^[a-z]$/.test(token)) return true;
    return token.length >= 2 || /^\d+$/.test(token);
  }));

  const textOf = (element) => (element?.innerText || element?.textContent || '').replace(/\s+/g, ' ').trim();

  const prepareCodeLines = (root) => {
    root.querySelectorAll('pre code').forEach((code) => {
      if (code.dataset.focusPrepared === 'true') return;
      const lines = code.textContent.replace(/\r/g, '').split('\n');
      code.innerHTML = lines.map((line) => `<span class="code-line">${escapeHtml(line || ' ')}</span>`).join('');
      code.dataset.focusPrepared = 'true';
    });
  };

  const collectTargets = (root) => {
    prepareCodeLines(root);
    const targets = [];
    TARGET_SPECS.forEach(([selector, prefix]) => {
      [...root.querySelectorAll(selector)].forEach((element, index) => {
        const key = `${prefix}-${index}`;
        element.dataset.focusKey = key;
        element.classList.add('focus-target');
        targets.push({ key, element, text: textOf(element), tokens: tokensOf(textOf(element)), prefix, index });
      });
    });
    return targets;
  };

  const detachedTargets = (html) => {
    const root = document.createElement('div');
    root.innerHTML = html || '';
    return collectTargets(root).map(({ key, text, tokens, prefix, index }) => ({ key, text, tokens, prefix, index }));
  };

  const all = (prefix, count) => Array.from({ length: count }, (_, index) => `${prefix}-${index}`);

  // 문단 인덱스와 화면 요소를 직접 연결해야 하는 장표입니다.
  const MANUAL = {
    0: [
      { p: [0], f: ['pill-0', 'pill-1', 'pill-2'] },
      { p: [1], f: ['course-0', 'course-1', 'course-2'] },
      { p: [2], f: ['course-3', 'course-4', 'course-5'] }
    ],
    1: [
      { p: [0, 1], f: all('card', 3) },
      { p: [2], f: ['card-1'] },
      { p: [3], f: ['card-2'] }
    ],
    2: [
      { p: [0], f: all('card', 3) },
      { p: [1], f: ['card-0'] },
      { p: [2], f: ['card-1'] },
      { p: [3], f: ['card-2'] }
    ],
    3: [
      { p: [0], f: all('card', 4) },
      { p: [1], f: ['card-0'] },
      { p: [2], f: ['card-1', 'card-2'] },
      { p: [3], f: ['card-3'] }
    ],
    5: [
      { p: [0], f: all('row', 3) },
      { p: [1], f: ['row-0'] },
      { p: [2], f: ['row-1'] },
      { p: [3, 4], f: ['row-2'] }
    ],
    7: [
      { p: [0], f: all('flow', 4) },
      { p: [1], f: ['flow-0'] },
      { p: [2], f: ['flow-1'] },
      { p: [3], f: ['flow-2'] },
      { p: [4], f: ['flow-3'] }
    ],
    11: [
      { p: [0], f: all('item', 5) },
      { p: [1], f: ['item-0'] },
      { p: [2], f: ['item-1'] },
      { p: [3], f: ['item-2'] },
      { p: [4], f: ['item-3'] },
      { p: [5], f: ['item-4'] }
    ],
    12: [
      { p: [0], f: all('card', 5) },
      { p: [1], f: ['card-0'] },
      { p: [2], f: ['card-1'] },
      { p: [3], f: ['card-2'] },
      { p: [4], f: ['card-3'] },
      { p: [5], f: ['card-4'] }
    ],
    15: [
      { p: [0], f: all('row', 3) },
      { p: [1], f: all('row', 3) },
      { p: [2, 3], f: all('row', 3) }
    ],
    16: [
      { p: [0], f: all('card', 2) },
      { p: [1], f: ['card-0'] },
      { p: [2], f: ['card-1'] },
      { p: [3], f: all('card', 2) }
    ],
    17: [
      { p: [0], f: all('card', 2) },
      { p: [1], f: ['card-0'] },
      { p: [2], f: ['card-1'] },
      { p: [3, 4], f: all('card', 2) }
    ],
    18: [
      { p: [0], f: all('row', 4) },
      { p: [1], f: ['row-0'] },
      { p: [2], f: ['row-1'] },
      { p: [3], f: ['row-2', 'row-3'] }
    ],
    19: [
      { p: [0], f: all('flow', 3) },
      { p: [1], f: ['flow-0'] },
      { p: [2], f: ['flow-1', 'flow-2'] },
      { p: [3], f: all('flow', 3) }
    ],
    20: [
      { p: [0, 1], f: all('code', 4) },
      { p: [2], f: ['code-1', 'code-2', 'code-3'] },
      { p: [3], f: all('code', 4) }
    ],
    21: [
      { p: [0], f: ['row-0'] },
      { p: [1], f: ['row-1'] },
      { p: [2], f: ['row-2'] },
      { p: [3], f: all('row', 3) }
    ],
    22: [
      { p: [0], f: all('row', 3) },
      { p: [1], f: ['row-0'] },
      { p: [2], f: ['row-1'] },
      { p: [3], f: ['row-2'] }
    ],
    23: [
      { p: [0], f: all('code', 2) },
      { p: [1], f: all('card', 3) },
      { p: [2], f: all('card', 3) },
      { p: [3], f: all('code', 2).concat(all('card', 3)) }
    ],
    24: [
      { p: [0], f: all('item', 5) },
      { p: [1], f: ['item-0'] },
      { p: [2], f: ['item-1'] },
      { p: [3], f: ['item-2'] },
      { p: [4], f: ['item-3'] },
      { p: [5], f: ['item-4'] }
    ],
    25: [
      { p: [0, 1], f: all('code', 7) },
      { p: [2], f: ['code-2', 'code-3', 'code-4', 'code-5'] },
      { p: [3], f: all('code', 7) }
    ],
    34: [
      { p: [0], f: all('row', 4) },
      { p: [1], f: ['row-0', 'row-1'] },
      { p: [2], f: ['row-2', 'row-3'] },
      { p: [3], f: all('row', 4) }
    ],
    36: [
      { p: [0], f: all('row', 3) },
      { p: [1], f: ['row-0'] },
      { p: [2], f: ['row-1'] },
      { p: [3, 4], f: ['row-2'] }
    ],
    38: [
      { p: [0], f: all('card', 3) },
      { p: [1], f: ['card-0'] },
      { p: [2], f: ['card-1'] },
      { p: [3], f: ['card-2'] },
      { p: [4], f: all('card', 3) }
    ],
    41: [
      { p: [0], f: all('flow', 5) },
      { p: [1], f: ['flow-0', 'flow-1'] },
      { p: [2], f: ['flow-2'] },
      { p: [3], f: ['flow-3', 'flow-4'] },
      { p: [4], f: all('flow', 5) }
    ],
    42: [
      { p: [0], f: all('card', 2) },
      { p: [1, 2], f: ['card-0'] },
      { p: [3, 4], f: ['card-1'] }
    ],
    43: [
      { p: [0, 1], f: all('activity', 5) },
      { p: [2], f: ['activity-0', 'activity-1', 'activity-2'] },
      { p: [3], f: ['activity-4'] },
      { p: [4], f: all('activity', 5) }
    ],
    44: [
      { p: [0], f: all('activity', 4) },
      { p: [1], f: ['activity-0'] },
      { p: [2], f: ['activity-1'] },
      { p: [3], f: ['activity-2', 'activity-3'] },
      { p: [4], f: all('activity', 4) }
    ],
    46: [
      { p: [0], f: all('card', 6) },
      { p: [1], f: ['card-0', 'card-1'] },
      { p: [2], f: ['card-2', 'card-3'] },
      { p: [3], f: ['card-4', 'card-5'] },
      { p: [4], f: ['card-1', 'card-3', 'card-5'] }
    ],
    48: [
      { p: [0, 1], f: all('flow', 4) },
      { p: [2, 3], f: all('flow', 4) }
    ]
  };

  const scoreTarget = (paragraphTokens, target) => {
    let score = 0;
    paragraphTokens.forEach((token) => {
      if (target.tokens.has(token)) score += token.length >= 4 ? 3 : 2;
    });
    return score;
  };

  const ordinalTarget = (paragraph, targets) => {
    const ordinals = [
      ['첫째', 0], ['첫 번째', 0], ['둘째', 1], ['두 번째', 1], ['셋째', 2], ['세 번째', 2],
      ['넷째', 3], ['네 번째', 3], ['다섯째', 4], ['다섯 번째', 4]
    ];
    const pair = ordinals.find(([word]) => paragraph.includes(word));
    if (!pair) return [];
    const index = pair[1];
    for (const prefix of ['card', 'item', 'row', 'flow', 'activity']) {
      const match = targets.find((target) => target.prefix === prefix && target.index === index);
      if (match) return [match.key];
    }
    return [];
  };

  const resolveFocus = (paragraph, targets) => {
    const ordinal = ordinalTarget(paragraph, targets);
    if (ordinal.length) return ordinal;
    const paragraphTokens = tokensOf(paragraph);
    const scored = targets.map((target) => ({ target, score: scoreTarget(paragraphTokens, target) }))
      .sort((left, right) => right.score - left.score);
    const best = scored[0]?.score || 0;
    if (best < 2) return [];
    const threshold = Math.max(2, Math.ceil(best * 0.66));
    return scored.filter((entry) => entry.score >= threshold).slice(0, 4).map((entry) => entry.target.key);
  };

  const sameFocus = (left, right) => left.length === right.length && left.every((key, index) => key === right[index]);

  const buildManualSteps = (paragraphs, plan) => plan.map((entry) => ({
    text: entry.p.map((index) => paragraphs[index]).filter(Boolean).join('\n\n'),
    focusKeys: entry.f || []
  })).filter((step) => step.text);

  const buildAutomaticSteps = (paragraphs, targets) => {
    const resolved = paragraphs.map((text) => ({ text, focusKeys: resolveFocus(text, targets) }));
    const steps = [];
    let pending = [];
    resolved.forEach((item) => {
      if (!item.focusKeys.length) {
        pending.push(item.text);
        return;
      }
      const text = pending.concat(item.text).join('\n\n');
      pending = [];
      if (steps.length && sameFocus(steps[steps.length - 1].focusKeys, item.focusKeys)) {
        steps[steps.length - 1].text += `\n\n${text}`;
      } else {
        steps.push({ text, focusKeys: item.focusKeys });
      }
    });
    if (pending.length) {
      if (steps.length) steps[steps.length - 1].text += `\n\n${pending.join('\n\n')}`;
      else steps.push({ text: pending.join('\n\n'), focusKeys: [] });
    }
    return steps;
  };

  const buildSteps = (slide, slideIndex) => {
    if (slide.__chapter01Steps) return slide.__chapter01Steps;
    const paragraphs = splitParagraphs(slide.s);
    const targets = detachedTargets(slide.h);
    const plan = MANUAL[slideIndex];
    const steps = plan ? buildManualSteps(paragraphs, plan) : buildAutomaticSteps(paragraphs, targets);
    slide.__chapter01Steps = steps.length ? steps : [{ text: paragraphs.join('\n\n'), focusKeys: [] }];
    return slide.__chapter01Steps;
  };

  const prepareDOM = (root) => collectTargets(root);

  const applyFocus = (root, slide, slideIndex, stepIndex) => {
    const targets = prepareDOM(root);
    targets.forEach(({ element }) => element.classList.remove('focus-muted', 'focus-active'));
    if (stepIndex <= 0) return;
    const step = buildSteps(slide, slideIndex)[stepIndex - 1];
    if (!step || !step.focusKeys.length) return;
    const selected = new Set(step.focusKeys);
    targets.forEach(({ key, element }) => element.classList.add(selected.has(key) ? 'focus-active' : 'focus-muted'));
  };

  window.CH1Navigation = Object.freeze({ buildSteps, prepareDOM, applyFocus, splitParagraphs, slideCount: slides.length });
})();
