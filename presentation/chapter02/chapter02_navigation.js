(() => {
  'use strict';

  const slides = window.CH2_SLIDES || [];
  if (!slides.length) return;

  const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (char) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[char]);

  // 질문과 화면 요소가 한 단계에 뭉쳐 있던 장표는 설명 단위를 세분화합니다.
  if (slides[7]) {
    slides[7].s = `디비버의 탐색기는 포스트그레스큐엘 구조를 계층으로 보여 줍니다. 연결 아래에서 데이터베이스, 스키마와 테이블을 차례로 펼쳐 볼 수 있습니다.

첫 번째 질문입니다. 퍼블릭은 데이터베이스일까요, 스키마일까요? 퍼블릭은 에이아이 데이터베이스 북 데이터베이스 안의 스키마입니다.

두 번째 질문입니다. 스튜던츠는 데이터를 저장하는 어떤 객체일까요? 스튜던츠는 퍼블릭 스키마 안에서 데이터를 저장하는 테이블입니다.

따라서 전체 경로는 에이아이 데이터베이스 북 데이터베이스, 퍼블릭 스키마, 스튜던츠 테이블의 순서로 읽습니다. 실제 화면의 폴더 순서와 논리적 포함 관계를 연결해서 이해해야 합니다.`;
  }

  if (slides[15]) {
    slides[15].s = `에이아이가 학생 이름, 강의 제목과 강사 이름을 하나의 테이블에 저장하고 학생 이름으로 행을 구분하자고 제안했다고 가정해 보겠습니다.

첫 번째 검토 질문은 한 행이 무엇을 의미하는가입니다. 학생인지, 강의인지, 수강신청인지가 분명해야 합니다.

두 번째 질문은 학생 이름이 중복될 수 있는가입니다. 같은 이름의 학생이 존재할 수 있으므로 이름만으로 행을 안정적으로 구분하기 어렵습니다.

세 번째 질문은 반복되는 값이 무엇인가입니다. 강의 제목과 강사 이름이 여러 신청 행에 반복되면 수정과 불일치 문제가 생길 수 있습니다.

네 번째 질문은 관계를 안정적으로 연결할 수 있는가입니다. 학생과 강의를 내부 식별자와 외래키로 연결할 수 있는지 확인해야 합니다.

검증할 때 기준 데이터는 업무 판단의 근거가 되는 원본입니다.

결정적 파생 결과는 같은 입력과 계산식에서 같은 값이 나오며 다시 만들 수 있는 결과입니다.

에이아이 생성 결과는 모델과 입력 조건에 따라 달라질 수 있으며, 원본 데이터가 아니라 사람이 검토할 후보입니다.

챕터 02의 핵심은 데이터베이스 구조를 정확한 용어로 읽고 자신의 말로 설명한 뒤 에이아이 초안을 판단하는 것입니다. 다음 챕터 03에서는 포스트그레스큐엘과 디비버 환경을 실제로 준비합니다.`;
  }

  const TARGET_SPECS = [
    ['.lead', 'lead'],
    ['.question-card', 'question'],
    ['.quote', 'quote'],
    ['.pill-row span', 'pill'],
    ['.road-step', 'road'],
    ['.band', 'band'],
    ['.card', 'card'],
    ['.path-node', 'path'],
    ['.return-line', 'return'],
    ['.role-card', 'role'],
    ['.scenario > span', 'scenario'],
    ['.layer.server-layer', 'server'],
    ['.layer.db-layer', 'database'],
    ['.layer.schema-layer', 'schema'],
    ['.object-row span', 'object'],
    ['.nested + .code-line', 'codebox'],
    ['.explorer', 'explorer'],
    ['.activity', 'activity'],
    ['.answer-band', 'answer'],
    ['.media-frame', 'media'],
    ['.legend', 'legend'],
    ['table tbody tr', 'row'],
    ['.row-formula', 'formula'],
    ['.activity-box', 'activitybox'],
    ['.id-card', 'id'],
    ['.rule-row span', 'rule'],
    ['.type-card', 'type'],
    ['.warning', 'warning'],
    ['.code-pair .code-focus-line', 'codeline'],
    ['.code-pair > div', 'codeinfo'],
    ['.key-card', 'key'],
    ['.relation-line', 'relation'],
    ['.small-note', 'note'],
    ['.prompt-box', 'prompt'],
    ['.review-grid span', 'review'],
    ['.data-kinds span', 'kind'],
    ['.next-band > span', 'next']
  ];

  const splitParagraphs = (value) => {
    const raw = String(value || '').trim();
    if (!raw) return ['핵심 내용을 설명합니다.'];
    return raw.split(/\n\s*\n/).map((part) => part.replace(/\s+/g, ' ').trim()).filter(Boolean);
  };

  const prepareCodeLines = (root) => {
    root.querySelectorAll('.code-pair pre code').forEach((code) => {
      if (code.dataset.focusPrepared === 'true') return;
      const lines = code.textContent.replace(/\r/g, '').split('\n');
      code.innerHTML = lines.map((line) => `<span class="code-focus-line">${escapeHtml(line || ' ')}</span>`).join('');
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
        targets.push({ key, element });
      });
    });
    return targets;
  };

  const all = (prefix, count) => Array.from({ length: count }, (_, index) => `${prefix}-${index}`);

  const PLANS = {
    0: [
      { p: [0], f: ['lead-0'] },
      { p: [1], f: ['question-0'] },
      { p: [2], f: ['quote-0'] },
      { p: [3], f: all('pill', 5) }
    ],
    1: [
      { p: [0], f: ['road-0'] },
      { p: [1], f: ['road-1'] },
      { p: [2], f: ['road-2', 'road-3', 'band-0'] }
    ],
    2: [
      { p: [0], f: ['card-0'] },
      { p: [1], f: ['card-1'] },
      { p: [2], f: ['card-2'] },
      { p: [3], f: ['card-3'] }
    ],
    3: [
      { p: [0], f: ['path-0', 'path-1'] },
      { p: [1], f: ['path-2'] },
      { p: [2], f: ['path-3', 'path-4', 'path-5'] },
      { p: [3], f: ['path-6', 'return-0'] }
    ],
    4: [
      { p: [0], f: ['card-0'] },
      { p: [1], f: ['card-1'] },
      { p: [2], f: ['card-2'] },
      { p: [3], f: ['warning-0'] }
    ],
    5: [
      { p: [0], f: ['role-0'] },
      { p: [1], f: ['role-1'] },
      { p: [2], f: ['scenario-0', 'scenario-1'] }
    ],
    6: [
      { p: [0], f: ['server-0'] },
      { p: [1], f: ['database-0'] },
      { p: [2], f: ['schema-0'] },
      { p: [3], f: all('object', 4).concat(['codebox-0']) }
    ],
    7: [
      { p: [0], f: ['explorer-0'] },
      { p: [1], f: ['activity-0', 'activity-1'] },
      { p: [2], f: ['answer-0'] }
    ],
    8: [
      { p: [0], f: ['media-0', 'legend-0'] },
      { p: [1], f: ['legend-1'] },
      { p: [2], f: ['legend-2'] },
      { p: [3], f: ['legend-3'] }
    ],
    9: [
      { p: [0], f: ['row-0', 'row-1'] },
      { p: [1], f: ['row-2', 'formula-0'] },
      { p: [2], f: ['activitybox-0'] }
    ],
    10: [
      { p: [0], f: ['id-0'] },
      { p: [1], f: ['id-1'] },
      { p: [2], f: all('rule', 3) }
    ],
    11: [
      { p: [0], f: ['type-0'] },
      { p: [1], f: ['type-1'] },
      { p: [2], f: ['type-2', 'type-3'] },
      { p: [3], f: ['quote-0'] }
    ],
    12: [
      { p: [0], f: ['card-0'] },
      { p: [1], f: ['card-1'] },
      { p: [2], f: ['card-2'] },
      { p: [3], f: ['warning-0'] }
    ],
    13: [
      { p: [0], f: ['card-0'] },
      { p: [1], f: ['card-1'] },
      { p: [2], f: ['codeline-2', 'codeinfo-0'] },
      { p: [3], f: ['warning-0'] }
    ],
    14: [
      { p: [0], f: ['key-0'] },
      { p: [1], f: ['key-1'] },
      { p: [2], f: ['relation-0', 'note-0'] }
    ],
    15: [
      { p: [0], f: ['prompt-0'] },
      { p: [1], f: all('review', 4) },
      { p: [2], f: all('kind', 3) },
      { p: [3], f: ['next-0', 'next-1'] }
    ]
  };

  const buildSteps = (slide, slideIndex) => {
    if (slide.__chapter02Steps) return slide.__chapter02Steps;
    const paragraphs = splitParagraphs(slide.s);
    const plan = PLANS[slideIndex] || paragraphs.map((_, index) => ({ p: [index], f: [] }));
    const steps = plan.map((entry) => ({
      text: entry.p.map((index) => paragraphs[index]).filter(Boolean).join('\n\n'),
      focusKeys: entry.f || []
    })).filter((step) => step.text);
    slide.__chapter02Steps = steps.length ? steps : [{ text: paragraphs.join('\n\n'), focusKeys: [] }];
    slide.steps = slide.__chapter02Steps.length;
    return slide.__chapter02Steps;
  };

  const prepareDOM = (root) => collectTargets(root);

  const applyFocus = (root, slide, slideIndex, stepIndex) => {
    const targets = prepareDOM(root);
    targets.forEach(({ element }) => element.classList.remove('focus-muted', 'focus-context', 'focus-active'));
    if (stepIndex <= 0) return;
    const step = buildSteps(slide, slideIndex)[stepIndex - 1];
    if (!step || !step.focusKeys.length) return;
    const selected = new Set(step.focusKeys);
    const activeElements = new Set(targets.filter(({ key }) => selected.has(key)).map(({ element }) => element));
    const contextElements = new Set();
    activeElements.forEach((element) => {
      let parent = element.parentElement?.closest('.focus-target');
      while (parent && root.contains(parent)) {
        contextElements.add(parent);
        parent = parent.parentElement?.closest('.focus-target');
      }
    });
    targets.forEach(({ element }) => {
      if (activeElements.has(element)) element.classList.add('focus-active');
      else if (contextElements.has(element)) element.classList.add('focus-context');
      else element.classList.add('focus-muted');
    });
  };

  window.CH2Navigation = Object.freeze({ buildSteps, prepareDOM, applyFocus, splitParagraphs, slideCount: slides.length });
})();
