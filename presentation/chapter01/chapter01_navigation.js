(() => {
  'use strict';

  const slides = window.CH1_SLIDES || [];
  if (!slides.length) return;

  const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (char) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[char]);

  const findSlide = (key) => slides.find((slide) => slide.k === key);

  // 화면과 스크립트가 서로 달랐던 장표를 먼저 같은 내용으로 맞춥니다.
  const fiveReasons = findSlide('FIVE REASONS');
  if (fiveReasons) {
    fiveReasons.h = `<h2>데이터베이스를 배워야 하는 이유는<br>다섯 가지로 정리됩니다</h2>
<div class="grid-2">
  <article class="card"><h3>에이아이 결과 검증</h3><p class="small">이 숫자가 요구사항에 맞는가</p></article>
  <article class="card"><h3>업무 구조 표현</h3><p class="small">사용자, 주문, 강의, 신청은 어떻게 연결되는가</p></article>
  <article class="card"><h3>정확한 분석</h3><p class="small">중복, 누락, 널, 집계 기준이 올바른가</p></article>
  <article class="card"><h3>서비스 운영</h3><p class="small">사용자, 권한, 상태, 실행 이력과 검토 기록을 어떻게 관리하는가</p></article>
  <article class="card emphasis" style="grid-column:1/-1"><h3>안전성과 복구</h3><p class="small">잘못된 변경을 막고 문제가 생겼을 때 되돌릴 수 있는가</p></article>
</div>`;
  }

  const misconception = findSlide('MISCONCEPTION CHECK');
  if (misconception) {
    misconception.h = `<h2>오해를 실제 문장으로 바꾸어<br>확인합니다</h2>
<div class="grid-2">
  <article class="card"><h3>오해 1</h3><p class="small">에스큐엘이 실행되면 맞다.</p></article>
  <article class="card emphasis"><h3>수정 1</h3><p class="small">실행 후에도 요구사항, 기준과 검산이 필요하다.</p></article>
  <article class="card"><h3>오해 2</h3><p class="small">에이아이가 만들면 충분하다.</p></article>
  <article class="card emphasis"><h3>수정 2</h3><p class="small">에이아이 초안은 사람이 근거를 확인하고 승인해야 한다.</p></article>
  <article class="card"><h3>오해 3</h3><p class="small">데이터가 많아야만 데이터베이스가 필요하다.</p></article>
  <article class="card emphasis"><h3>수정 3</h3><p class="small">데이터가 적어도 관계, 권한, 이력과 복구가 중요하면 데이터베이스가 필요할 수 있다.</p></article>
</div>`;
  }

  // 화면 항목과 설명이 달랐던 스크립트도 화면 구조에 맞추어 정리합니다.
  const scriptFixes = {
    'ROLE SPLIT': `에이아이와 사람의 역할은 초안, 오류, 분석의 세 상황으로 나누어 보겠습니다.

초안 단계에서 에이아이는 테이블과 에스큐엘을 빠르게 제안할 수 있습니다. 사람은 그 구조가 실제 업무 규칙과 맞는지 확인해야 합니다.

오류가 발생하면 에이아이는 문법 오류와 수정 방향을 설명할 수 있습니다. 사람은 문법이 고쳐진 뒤에도 결과의 의미가 요구사항과 맞는지 확인해야 합니다.

분석 단계에서 에이아이는 집계 쿼리를 제안할 수 있습니다. 사람은 분모와 분자, 포함 대상, 영 건 대상이 올바르게 반영되었는지 검증해야 합니다.

에이아이를 사용하더라도 최종적으로 승인할 수 있는 근거는 사람이 남겨야 합니다.`,
    'AI LIMIT': `에이아이가 스스로 확정해서는 안 되는 업무 정책을 네 가지 예로 보겠습니다.

첫째, 학생 이메일의 중복을 허용할지 정해야 합니다. 같은 주소의 대소문자나 공백을 어떻게 처리할지도 실제 서비스 정책입니다.

둘째, 탈퇴한 학생 기록을 삭제할지 보존할지 정해야 합니다. 삭제와 비활성 보존은 모두 가능하지만 업무 정책에 따라 답이 달라집니다.

셋째, 질문이 없는 학생도 통계에 포함할지 정해야 합니다. 영 건 대상의 포함 여부는 집계 결과를 크게 바꿀 수 있습니다.

넷째, 완료 상태의 질문에는 반드시 답변이 있어야 하는지 정해야 합니다. 완료의 정의가 정해져야 저장 규칙과 조회 기준도 정할 수 있습니다.

에이아이는 규칙 후보를 제안할 수 있지만, 실제 정책을 확인하고 승인하는 일은 사람이 해야 합니다.`,
    'POLICY GAP': `정책이 빠졌을 때 생기는 문제를 네 가지 사례로 확인하겠습니다.

질문이 없는 학생을 통계에 포함할지 정하지 않으면 어떤 쿼리는 그 학생을 빼고 어떤 쿼리는 포함할 수 있습니다. 두 결과 모두 실행될 수 있지만 의미는 달라집니다.

탈퇴한 학생 기록도 삭제할지, 비활성 상태로 남길지, 분석에 포함할지 정해야 합니다. 정책이 없으면 테이블 구조와 조회 조건이 흔들립니다.

이메일 중복도 단순하지 않습니다. 대문자와 소문자를 같은 주소로 볼지, 앞뒤 공백을 어떻게 처리할지 정해야 합니다.

완료 상태도 정의가 필요합니다. 완료된 질문에는 답변이 반드시 있어야 하는지 정하지 않으면 같은 완료 상태가 서로 다른 의미로 사용될 수 있습니다.

따라서 에이아이가 만든 구조를 볼 때는 문법보다 먼저 빠진 정책이 없는지 확인해야 합니다.`,
    'HAND CHECK': `작은 데이터는 반드시 손으로 먼저 계산해 보는 것이 좋습니다.

먼저 전체 학생 수를 셉니다. 학생 에이, 학생 비, 학생 씨가 있으므로 전체 학생 수는 세 명입니다.

다음으로 질문 수를 셉니다. 학생 에이가 두 건, 학생 비가 한 건이므로 질문 수는 총 세 건입니다.

이번 예제에서는 두 숫자가 우연히 모두 3이지만 전체 학생 수 3명과 질문 수 3건은 완전히 다른 의미입니다.

실제 업무에서도 숫자가 우연히 같아 보이면 오류를 발견하기 어렵습니다. 그래서 실행 전에 기대 결과와 그 숫자의 의미를 먼저 적어야 합니다.`,
    'DATA QUALITY': `오류가 어떻게 전파되는지 단계별로 보겠습니다.

먼저 원본 데이터가 중복되어 있거나 조회 기준과 포함 조건이 잘못될 수 있습니다.

그 상태에서 조인이나 집계를 실행하면 에스큐엘 결과도 잘못됩니다.

에이아이가 그 결과를 근거로 설명하면 잘못된 숫자를 바탕으로 그럴듯한 분석을 만들 수 있습니다.

결국 잘못된 분석은 잘못된 의사결정으로 이어질 수 있습니다. 따라서 에이아이 답변을 검토할 때는 문장뿐 아니라 근거 데이터와 에스큐엘을 함께 확인해야 합니다.`,
    'NULL': `널과 영은 같은 값이 아닙니다. 널은 값이 알려지지 않았거나 아직 입력되지 않았거나 해당되지 않는 상태일 수 있고, 영은 실제 숫자 값입니다.

할인 금액이 영 원이라면 할인이 없다는 실제 값일 수 있습니다.

반면 완료일이 널이라면 아직 완료되지 않아 완료일이 없는 상태일 수 있습니다.

두 값을 확인 없이 바꾸면 분석 결과가 틀어질 수 있습니다. 정보가 없는 상태와 실제 값이 영인 상태를 구분해야 합니다.`,
    'ACTIVITY': `이제 온라인 강의 서비스의 저장 방식을 직접 판단해 보겠습니다.

학생은 여러 강의를 신청하고, 운영자는 학생, 강사, 강의와 신청 상태를 관리합니다. 학생별 신청 이력과 월별 신청 건수도 반복해서 조회합니다.

이처럼 관계, 반복 조회와 상태 관리가 중요하므로 관계형 디비엠에스 중심 관리를 검토하는 것이 적절합니다.

신청 당시 기록 금액도 보존해야 합니다. 나중에 강의 가격이 바뀌더라도 실제 신청 당시의 금액을 확인할 수 있어야 하기 때문입니다.

결제와 환불 기능은 이후 확장할 수 있습니다. 현재 범위에서 반드시 정확하게 관리해야 하는 데이터를 먼저 정하는 것이 프로젝트 범위를 정하는 출발점입니다.`,
    'MISUNDERSTANDINGS': `1장에서 바로잡을 다섯 가지 오해를 정리해 보겠습니다.

첫째, 데이터가 많아야만 데이터베이스가 필요한 것은 아닙니다. 데이터가 적어도 관계, 정확성, 권한과 이력이 중요하면 디비엠에스가 필요할 수 있습니다.

둘째, 스프레드시트와 데이터베이스는 단순히 크기만 다른 도구가 아닙니다. 관계, 동시 접근, 제약조건, 권한, 이력과 복구 같은 관리 요구사항이 다릅니다.

셋째, 에스큐엘이 실행된다고 결과가 맞는 것은 아닙니다. 요구사항과 포함 범위, 중복과 누락을 검증해야 합니다.

넷째, 데이터 분석은 파이썬에서만 하는 것이 아닙니다. 에스큐엘에서도 필터, 조인, 집계와 데이터 품질 확인을 할 수 있습니다.

다섯째, 처음부터 완벽한 구조를 만들 필요는 없습니다. 요구사항과 검증 근거를 따라 구조를 개선하고 확장하는 것이 중요합니다.

이 오해들을 바로잡는 것이 1장의 중요한 목표입니다.`,
    'NEXT CHAPTER': `다음 장에서는 기본 용어를 정확하게 연결해서 정리합니다.

먼저 데이터가 무엇인지 살펴봅니다. 업무에서 기록하고 해석하려는 사실과 값을 데이터라는 관점에서 봅니다.

그다음 데이터가 구조적으로 저장되고 관리되는 데이터베이스의 개념을 구분합니다.

이어서 데이터베이스를 생성하고 조회하고 보호하는 디비엠에스의 역할을 확인합니다.

마지막으로 포스트그레스큐엘 서버, 데이터베이스, 스키마, 테이블, 행과 열이 어떤 계층으로 연결되는지 배웁니다. 오늘 익힌 검증 관점을 바탕으로 실제 구성 요소를 하나씩 확인하겠습니다.`
  };

  Object.entries(scriptFixes).forEach(([key, script]) => {
    const slide = findSlide(key);
    if (slide) slide.s = script;
  });

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

  const STOP_WORDS = new Set([
    '이번', '장표', '에서는', '입니다', '있습니다', '합니다', '됩니다', '그리고', '하지만', '따라서',
    '먼저', '다음', '마지막', '정리하면', '중요한', '내용', '확인', '살펴보겠습니다', '살펴봅니다',
    '수', '것', '때', '이', '그', '저', '한', '두', '세', '네', '다섯'
  ]);

  const normalizeForMatch = (value) => String(value || '')
    .toLowerCase()
    .replace(/에이아이/g, 'ai')
    .replace(/에스큐엘/g, 'sql')
    .replace(/포스트그레스큐엘/g, 'postgresql')
    .replace(/디비엠에스/g, 'dbms')
    .replace(/이너 조인/g, 'inner join')
    .replace(/조인/g, 'join')
    .replace(/널/g, 'null')
    .replace(/영 건/g, '0건')
    .replace(/영 원/g, '0원')
    .replace(/카운트 별표/g, 'count')
    .replace(/학생 에이/g, '학생 a')
    .replace(/학생 비/g, '학생 b')
    .replace(/학생 씨/g, '학생 c')
    .replace(/[^0-9a-z가-힣]+/g, ' ')
    .replace(/\s+/g, ' ')
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

  const splitUnits = (value) => {
    const raw = String(value || '').trim();
    if (!raw) return ['핵심 내용을 설명합니다.'];
    const paragraphs = raw.split(/\n\s*\n/).map((part) => part.replace(/\s+/g, ' ').trim()).filter(Boolean);
    const units = [];
    paragraphs.forEach((paragraph) => {
      const sentences = (paragraph.match(/[^.!?。]+[.!?。]?/g) || []).map((part) => part.trim()).filter(Boolean);
      if (sentences.length) units.push(...sentences);
      else units.push(paragraph);
    });
    return units.length ? units : [raw.replace(/\s+/g, ' ').trim()];
  };

  // 49개 장표 전체의 화면 이동 순서를 명시합니다.
  // '*': 해당 종류의 화면 요소 전체를 한 단계에서 함께 강조합니다.
  const FOCUS_SEQUENCES = {
    'CHAPTER 01 · COURSE OVERVIEW': [['pill:*'], ['course-0', 'course-1', 'course-2'], ['course-3', 'course-4', 'course-5']],
    'LECTURE PACING': [['card-0'], ['card-1'], ['card-2']],
    'GOALS': [['card-0'], ['card-1'], ['card-2']],
    'COURSE ROADMAP': [['card-0'], ['card-1'], ['card-2'], ['card-3']],
    'KEY QUESTION': [['question:*', 'quote:*']],
    'ROLE SPLIT': [['row-0'], ['row-1'], ['row-2']],
    'AI CAN HELP': [['prompt:*']],
    'AI DRAFT REVIEW': [['flow-0'], ['flow-1'], ['flow-2'], ['flow-3']],
    'AI LIMIT': [['item-0'], ['item-1'], ['item-2'], ['item-3']],
    'POLICY GAP': [['card-0'], ['card-1'], ['card-2'], ['card-3']],
    'LEARNING POINT': [['card-0'], ['card-1'], ['card-2']],
    'FIVE QUESTIONS': [['item-0'], ['item-1'], ['item-2'], ['item-3'], ['item-4']],
    'FIVE REASONS': [['card-0'], ['card-1'], ['card-2'], ['card-3'], ['card-4']],
    'IMPORTANT IDEA': [['quote:*']],
    'RUNNING VS CORRECT': [['card-0'], ['card-1'], ['card-2']],
    'MINI EXAMPLE A': [['row:*']],
    'HAND CHECK': [['card-0'], ['card-1']],
    'EXPECTED RESULT': [['card-0'], ['card-1']],
    'JOIN RESULT': [['row-0', 'row-1', 'row-2'], ['row-3']],
    'JOIN MEANING': [['flow-0'], ['flow-1'], ['flow-2']],
    'WRONG SQL': [['code:*']],
    'COUNTER DATA': [['row-0'], ['row-1'], ['row-2']],
    'COUNT PATTERNS': [['row-0', 'row-1'], ['row-2']],
    'BETTER SQL': [['code:*'], ['card:*']],
    'CHECKLIST': [['item-0'], ['item-1'], ['item-2'], ['item-3'], ['item-4']],
    'MAIN EXAMPLE': [['code:*']],
    'BAD STRUCTURE': [['card-0', 'card-1'], ['card-2'], ['card-3']],
    'UPDATE ANOMALY': [['flow-0'], ['flow-1'], ['flow-2'], ['flow-3']],
    'AMOUNT MEANING': [['card-0'], ['card-1', 'card-2']],
    'DATA QUALITY': [['flow-0'], ['flow-1'], ['flow-2'], ['flow-3']],
    'NULL': [['card-0'], ['card-1']],
    'NULL DECISION': [['item-0'], ['item-1'], ['item-2'], ['item-3']],
    'REAL WORLD': [['flow:*']],
    'AI SERVICE': [['card-0', 'card-1', 'card-2'], ['card-3']],
    'NON-DEVELOPERS': [['row:*']],
    'STORAGE CHOICE': [['card-0', 'card-1'], ['card-2']],
    'TOOL BOUNDARY': [['row:*']],
    'WHEN DBMS': [['item-0', 'item-1', 'item-2', 'item-3'], ['item-4']],
    'DATA TYPES': [['card-0'], ['card-1'], ['card-2']],
    'DATA LIFECYCLE': [['flow-0'], ['flow-1'], ['flow-2'], ['flow-3']],
    'CACHE AND AI': [['card-0'], ['card-1']],
    'AI REVIEW CYCLE': [['flow-0', 'flow-1', 'flow-2'], ['flow-3', 'flow-4']],
    'BEFORE RUN CHECK': [['card-0'], ['card-1']],
    'ACTIVITY': [['activity-0', 'activity-1', 'activity-2'], ['activity-3'], ['activity-4']],
    'CLASS ACTIVITY': [['activity-0'], ['activity-1'], ['activity-2', 'activity-3']],
    'MISUNDERSTANDINGS': [['item-0'], ['item-1'], ['item-2'], ['item-3'], ['item-4']],
    'MISCONCEPTION CHECK': [['card-0', 'card-1'], ['card-2', 'card-3'], ['card-4', 'card-5']],
    'SUMMARY': [['quote:*', 'chip:*']],
    'NEXT CHAPTER': [['flow-0'], ['flow-1'], ['flow-2'], ['flow-3']]
  };

  const expandGroup = (specs, targets) => {
    const keys = [];
    specs.forEach((spec) => {
      if (spec.endsWith(':*')) {
        const prefix = spec.slice(0, -2);
        targets.filter((target) => target.prefix === prefix).forEach((target) => keys.push(target.key));
      } else if (targets.some((target) => target.key === spec)) {
        keys.push(spec);
      }
    });
    return [...new Set(keys)];
  };

  const groupTargetText = (groupKeys, targets) => groupKeys
    .map((key) => targets.find((target) => target.key === key)?.text || '')
    .join(' ');

  const ordinalIndex = (unit) => {
    const pairs = [
      [/첫째|첫 번째|첫번째/, 0], [/둘째|두 번째|두번째/, 1], [/셋째|세 번째|세번째/, 2],
      [/넷째|네 번째|네번째/, 3], [/다섯째|다섯 번째|다섯번째/, 4]
    ];
    const match = pairs.find(([pattern]) => pattern.test(unit));
    return match ? match[1] : -1;
  };

  const semanticScore = (unit, groupText, groupIndex, groupCount, unitIndex, unitCount) => {
    const unitTokens = tokensOf(unit);
    const groupTokens = tokensOf(groupText);
    let score = 0;
    unitTokens.forEach((token) => {
      if (groupTokens.has(token)) score += token.length >= 5 ? 5 : token.length >= 3 ? 3 : 2;
    });

    const ordinal = ordinalIndex(unit);
    if (ordinal >= 0) score += ordinal === groupIndex ? 12 : -4;

    const actual = (unitIndex + 0.5) / Math.max(1, unitCount);
    const expected = (groupIndex + 0.5) / Math.max(1, groupCount);
    score -= Math.abs(actual - expected) * 3;
    return score;
  };

  const mergeAdjacentGroups = (groups, maxGroups) => {
    if (groups.length <= maxGroups) return groups;
    const merged = Array.from({ length: maxGroups }, () => []);
    groups.forEach((group, index) => {
      const bucket = Math.min(maxGroups - 1, Math.floor(index * maxGroups / groups.length));
      merged[bucket].push(...group);
    });
    return merged.map((group) => [...new Set(group)]);
  };

  const partitionUnits = (units, groups, targets) => {
    if (!groups.length) return [{ text: units.join(' '), focusKeys: [] }];
    if (groups.length === 1) return [{ text: units.join(' '), focusKeys: groups[0] }];

    const effectiveGroups = mergeAdjacentGroups(groups, Math.max(1, Math.min(groups.length, units.length)));
    const n = units.length;
    const m = effectiveGroups.length;
    const texts = effectiveGroups.map((group) => groupTargetText(group, targets));

    const prefix = Array.from({ length: m }, () => Array(n + 1).fill(0));
    for (let g = 0; g < m; g += 1) {
      for (let i = 0; i < n; i += 1) {
        prefix[g][i + 1] = prefix[g][i] + semanticScore(units[i], texts[g], g, m, i, n);
      }
    }

    const blockScore = (g, start, end) => {
      const semantic = prefix[g][end] - prefix[g][start];
      const center = ((start + end - 1) / 2 + 0.5) / n;
      const expected = (g + 0.5) / m;
      const sizePenalty = Math.abs((end - start) - n / m) * 0.12;
      return semantic - Math.abs(center - expected) * 5 - sizePenalty;
    };

    const dp = Array.from({ length: m + 1 }, () => Array(n + 1).fill(-Infinity));
    const prev = Array.from({ length: m + 1 }, () => Array(n + 1).fill(-1));
    dp[0][0] = 0;

    for (let g = 1; g <= m; g += 1) {
      for (let end = g; end <= n - (m - g); end += 1) {
        for (let start = g - 1; start < end; start += 1) {
          if (!Number.isFinite(dp[g - 1][start])) continue;
          const candidate = dp[g - 1][start] + blockScore(g - 1, start, end);
          if (candidate > dp[g][end]) {
            dp[g][end] = candidate;
            prev[g][end] = start;
          }
        }
      }
    }

    const boundaries = [];
    let end = n;
    for (let g = m; g >= 1; g -= 1) {
      const start = prev[g][end];
      boundaries.push([Math.max(0, start), end]);
      end = Math.max(0, start);
    }
    boundaries.reverse();

    return boundaries.map(([start, finish], index) => ({
      text: units.slice(start, finish).join(' '),
      focusKeys: effectiveGroups[index]
    })).filter((step) => step.text);
  };

  const buildSteps = (slide, slideIndex) => {
    if (slide.__chapter01StepsV2) return slide.__chapter01StepsV2;
    const targets = detachedTargets(slide.h);
    const plan = FOCUS_SEQUENCES[slide.k];
    const units = splitUnits(slide.s);

    if (!plan) {
      console.warn(`[Chapter01] 단계 계획이 없는 장표: ${slideIndex + 1} ${slide.k}`);
      slide.__chapter01StepsV2 = [{ text: units.join(' '), focusKeys: [] }];
      return slide.__chapter01StepsV2;
    }

    const groups = plan.map((specs) => expandGroup(specs, targets)).filter((group) => group.length);
    slide.__chapter01StepsV2 = partitionUnits(units, groups, targets);
    return slide.__chapter01StepsV2;
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

  const audit = () => {
    const issues = [];
    slides.forEach((slide, index) => {
      const targets = detachedTargets(slide.h);
      const plan = FOCUS_SEQUENCES[slide.k];
      if (!plan) {
        issues.push({ slide: index + 1, key: slide.k, problem: '단계 계획 누락' });
        return;
      }
      const groups = plan.map((specs) => expandGroup(specs, targets));
      groups.forEach((group, groupIndex) => {
        if (!group.length) issues.push({ slide: index + 1, key: slide.k, problem: `${groupIndex + 1}단계 강조 대상 없음` });
      });
      const steps = buildSteps(slide, index);
      if (!steps.length) issues.push({ slide: index + 1, key: slide.k, problem: '스크립트 단계 없음' });
      if (steps.some((step) => !step.text.trim())) issues.push({ slide: index + 1, key: slide.k, problem: '빈 스크립트 단계' });
    });
    return issues;
  };

  const issues = audit();
  if (issues.length) console.warn('[Chapter01] 내비게이션 점검 결과', issues);

  window.CH1Navigation = Object.freeze({
    version: '2026-08-07-v2',
    buildSteps,
    prepareDOM,
    applyFocus,
    splitParagraphs: splitUnits,
    audit,
    slideCount: slides.length
  });
})();
