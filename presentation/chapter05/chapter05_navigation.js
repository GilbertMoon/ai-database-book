(() => {
  'use strict';

  const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (char) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[char]);

  const SCRIPT_FIXES = {
    theory: {
      'CHAPTER GOAL': `이번 장의 목표는 예쁜 그림을 그리는 것이 아닙니다.\n\n첫째, 업무 사실과 업무 규칙을 구분합니다.\n\n둘째, 확정된 규칙과 아직 정해지지 않은 규칙을 분리합니다.\n\n셋째, 엔터티와 속성을 판단 근거와 함께 도출합니다.\n\n넷째, 관계를 한 방향이 아니라 양방향 문장으로 작성합니다.\n\n다섯째, 완성한 이알디를 포스트그레스큐엘 테이블 구조로 변환합니다. 각 요구사항이 어떤 구조에 반영되었는지 설명할 수 있는 모델을 만드는 것이 핵심입니다.`,
      'REQUIREMENT SAMPLE': `이 장에서는 도서 대여 시스템을 예제로 사용합니다.\n\n알원은 도서관이 회원을 관리한다는 관리 대상을 알려 줍니다. 알투는 회원이 이름, 이메일, 가입일을 가진다는 속성을 알려 줍니다.\n\n알쓰리는 도서가 제목, 저자, 출판연도, 아이에스비엔을 가진다는 속성을 알려 줍니다.\n\n알포는 회원이 여러 권의 책을 대여할 수 있다는 관계와 수량을 알려 줍니다.\n\n알파이브는 책이 시간에 따라 여러 번 대여될 수 있다는 이력 요구사항을 알려 줍니다.\n\n알식스는 대여 기록에 대여일, 반납예정일, 실제반납일을 저장한다는 사건의 속성을 알려 줍니다. 알세븐은 아직 반납되지 않았다면 실제반납일이 비어 있을 수 있다는 널 허용 규칙을 알려 줍니다.`,
      'OPTIONALITY': `관계에서는 몇 개까지 연결되는지뿐 아니라 연결이 필수인지 선택인지도 중요합니다.\n\n영에서 하나는 연결 대상이 없거나 최대 하나만 있을 수 있다는 뜻입니다.\n\n일은 반드시 하나의 대상과 연결되어야 한다는 뜻입니다.\n\n영에서 엔은 아직 연결 대상이 없을 수도 있고 여러 개가 생길 수도 있다는 뜻입니다. 회원은 아직 대여 기록이 없을 수 있으므로 회원에서 대여 기록은 영에서 엔으로 볼 수 있습니다.\n\n일에서 엔은 최소 하나 이상이 반드시 존재하면서 여러 개까지 연결될 수 있다는 뜻입니다. 실제 요구사항 문장을 확인해 어떤 선택성이 맞는지 판단해야 합니다.`
    },
    practice: {
      'STEP 04': `네 번째 단계입니다. 요구사항에 없는 정책은 질문 목록으로 둡니다.\n\n첫째, 회원 이메일은 반드시 유일한지 확인해야 합니다.\n\n둘째, 아이에스비엔은 한 권당 반드시 유일한지 확인해야 합니다.\n\n셋째, 동일 아이에스비엔을 가진 복본을 서로 구분해야 하는지 확인해야 합니다.\n\n넷째, 한 책에 동시에 미반납 대여가 두 건 이상 생기는 것을 데이터베이스에서 차단해야 하는지 확인해야 합니다.\n\n다섯째, 연체와 삭제 정책을 어떻게 처리할지 확인해야 합니다. 이런 정책이 요구사항에 없다면 설계자가 임의로 확정하지 않고 질문 목록이나 범위 제외로 남깁니다.`
    }
  };

  const PLANS = {
    theory: {
      'CHAPTER 05 · THEORY': [['lead:*', 'pill:*']],
      'WHERE WE ARE': [['flow-0'], ['flow-1'], ['flow-2'], ['flow-3']],
      'CHAPTER GOAL': [['item-0'], ['item-1'], ['item-2'], ['item-3'], ['item-4']],
      'CORE PRINCIPLE': [['quote:*']],
      'MODEL LEVELS': [['row-0'], ['row-1'], ['row-2']],
      'MODELING FLOW': [['flow-0'], ['flow-1'], ['flow-2'], ['flow-3'], ['flow-4']],
      'REQUIREMENT SAMPLE': [['code-0', 'code-1'], ['code-2'], ['code-3'], ['code-4'], ['code-5', 'code-6']],
      'FACT VS RULE': [['card-0'], ['card-1']],
      'CONFIRMED UNKNOWN': [['row-0'], ['row-1'], ['row-2'], ['row-3']],
      'ENTITY CANDIDATES': [['card-0'], ['card-1'], ['card-2']],
      'ENTITY ATTRIBUTE': [['row-0'], ['row-1'], ['row-2'], ['row-3']],
      'IDENTIFIER': [['card-0'], ['card-1']],
      'RELATION SENTENCE': [['quote:*']],
      'CARDINALITY': [['card-0'], ['card-1'], ['card-2']],
      'OPTIONALITY': [['row-0'], ['row-1'], ['row-2'], ['row-3']],
      'MANY TO MANY': [['flow-0', 'flow-2'], ['flow-1'], ['flow:*', 'body:*']],
      'PK FK POSITION': [['code-0'], ['code-1']],
      'ERD ELEMENTS': [['card-0'], ['card-1'], ['card-2'], ['card-3']],
      'TRACEABILITY': [['row-0'], ['row-1'], ['row-2']],
      'DDL CONVERSION': [['code-0'], ['code-1'], ['code-2'], ['code-3'], ['code-4', 'code-5', 'code-6']],
      'SAMPLE CHECK': [['row-0'], ['row-1']],
      'AI ERD REVIEW': [['item-0'], ['item-1'], ['item-2'], ['item-3'], ['item-4']],
      'COMMON MISTAKES': [['item-0'], ['item-1'], ['item-2'], ['item-3'], ['item-4']],
      'SELF CHECK': [['item-0'], ['item-1'], ['item-2'], ['item-3'], ['item-4']],
      'SUMMARY': [['quote:*']],
      'NEXT CHAPTER': [['lead:*']]
    },
    practice: {
      'CHAPTER 05 · PRACTICE': [['lead:*', 'pill:*']],
      'PRACTICE RULE': [['flow-0'], ['flow-1'], ['flow-2'], ['flow-3']],
      'FILES': [['row-0'], ['row-1'], ['row-2'], ['row-3']],
      'STEP 01': [['code:*'], ['body:*']],
      'STEP 02': [['code-0', 'code-1'], ['code-2'], ['code-3'], ['code-4'], ['code-5', 'code-6']],
      'STEP 03': [['row-0'], ['row-1'], ['row-2']],
      'STEP 04': [['item-0'], ['item-1'], ['item-2'], ['item-3'], ['item-4']],
      'STEP 05': [['card-0'], ['card-1'], ['card-2']],
      'STEP 06': [['quote:*']],
      'STEP 07': [['flow-0'], ['flow-1'], ['flow-2', 'body:*']],
      'STEP 08': [['item-0'], ['item-1'], ['item-2'], ['item-3']],
      'STEP 09': [['code-0'], ['code-1'], ['code-2', 'code-3', 'code-4'], ['code-3']],
      'STEP 10': [['code-0'], ['code-1'], ['code-2', 'code-3'], ['code-4', 'code-5']],
      'STEP 11': [['code-0'], ['code-1', 'code-2'], ['code-3', 'code-4'], ['code-5']],
      'STEP 12': [['code:*']],
      'STEP 13': [['row-0'], ['row-1'], ['row-2']],
      'STEP 14': [['code-0'], ['code-1'], ['code-2']],
      'STEP 15': [['code:*']],
      'STEP 16': [['code-0', 'code-1'], ['code-2'], ['code-3'], ['body:*']],
      'STEP 17': [['code-0', 'code-1'], ['code-2', 'code-3'], ['code-4']],
      'STEP 18': [['code-0', 'code-1'], ['code-2'], ['code-3']],
      'STEP 19': [['row-0'], ['row-1'], ['row-2']],
      'STEP 20': [['item-0'], ['item-1'], ['item-2'], ['item-3']],
      'STEP 21': [['code-0'], ['code-1'], ['code-2']],
      'STEP 22': [['item-0'], ['item-1'], ['item-2'], ['item-3'], ['item-4']],
      'STEP 23': [['card-0'], ['card-1']],
      'CHECKPOINT': [['item-0'], ['item-1'], ['item-2'], ['item-3'], ['item-4']],
      'TROUBLESHOOTING': [['row-0'], ['row-1'], ['row-2'], ['row-3']],
      'SUMMARY': [['quote:*']]
    }
  };

  const TARGET_SPECS = [
    ['.lead', 'lead'], ['.body-text', 'body'], ['.card', 'card'], ['.flow-step', 'flow'],
    ['.road-step', 'road'], ['.path-node', 'path'], ['.relation-node', 'relation'],
    ['.bullet-list li', 'item'], ['.checklist li', 'item'], ['table tbody tr', 'row'],
    ['.activity-box li', 'activity'], ['.code-line', 'code'], ['.quote', 'quote'],
    ['.expect', 'expect'], ['.step-box', 'stepbox'], ['.entity', 'entity'],
    ['.attribute', 'attribute'], ['.relationship', 'relationship'], ['.rule', 'rule'],
    ['.assumption', 'assumption'], ['.question', 'question'], ['.decision', 'decision'],
    ['.mapping', 'mapping'], ['.scenario', 'scenario'], ['.example', 'example'],
    ['.result', 'result'], ['.hierarchy > div', 'hierarchy'], ['.erd-list > div', 'erd'],
    ['.trace-list > div', 'trace'], ['.pill', 'pill'], ['.chip', 'chip']
  ];

  const STOP_WORDS = new Set([
    '이번', '장표', '단계', '입니다', '있습니다', '합니다', '됩니다', '그리고', '하지만', '따라서',
    '먼저', '다음', '마지막', '확인', '보겠습니다', '보면', '경우', '대한', '위해', '사용', '실습'
  ]);

  const normalize = (value) => String(value ?? '')
    .toLowerCase()
    .replace(/postgresql/g, '포스트그레스큐엘')
    .replace(/requirements?/g, '요구사항')
    .replace(/relationship/g, '관계')
    .replace(/attribute/g, '속성')
    .replace(/entity/g, '엔터티')
    .replace(/erd/g, '이알디')
    .replace(/ddl/g, '디디엘')
    .replace(/primary key|\bpk\b/g, '기본키')
    .replace(/foreign key|\bfk\b/g, '외래키')
    .replace(/null/g, '널')
    .replace(/unique/g, '유니크')
    .replace(/identity/g, '아이덴티티')
    .replace(/join/g, '조인')
    .replace(/table/g, '테이블')
    .replace(/column/g, '열')
    .replace(/row/g, '행')
    .replace(/members/g, '멤버스')
    .replace(/books/g, '북스')
    .replace(/loans/g, '로운스')
    .replace(/member_id/g, '멤버 아이디')
    .replace(/book_id/g, '북 아이디')
    .replace(/returned_at/g, '리턴드 앳')
    .replace(/borrowed_at/g, '보로우드 앳')
    .replace(/due_at/g, '듀 앳')
    .replace(/isbn/g, '아이에스비엔')
    .replace(/[^0-9a-z가-힣]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

  const tokensOf = (value) => new Set(normalize(value).split(' ').filter((token) => token.length >= 2 && !STOP_WORDS.has(token)));

  function splitUnits(text) {
    const paragraphs = String(text || '').trim().split(/\n\s*\n/).map((value) => value.replace(/\s+/g, ' ').trim()).filter(Boolean);
    const units = [];
    paragraphs.forEach((paragraph) => {
      const sentences = (paragraph.match(/[^.!?。]+[.!?。]?/g) || []).map((value) => value.trim()).filter(Boolean);
      if (sentences.length <= 1) units.push(paragraph);
      else units.push(...sentences);
    });
    return units.length ? units : ['핵심 내용을 설명합니다.'];
  }

  function prepareCodeLines(root) {
    root.querySelectorAll('pre, .codebox, .prompt-box').forEach((element) => {
      if (element.querySelector('.code-line')) return;
      const text = element.textContent || '';
      const lines = text.replace(/^\n|\n$/g, '').split('\n');
      element.textContent = '';
      lines.forEach((line) => {
        const span = document.createElement('span');
        span.className = 'code-line';
        span.textContent = line || ' ';
        element.appendChild(span);
      });
    });
  }

  function collectTargets(root) {
    prepareCodeLines(root);
    const found = [];
    const seen = new Set();
    TARGET_SPECS.forEach(([selector, prefix]) => {
      root.querySelectorAll(selector).forEach((element) => {
        if (seen.has(element)) return;
        seen.add(element);
        found.push({ element, prefix, text: (element.innerText || element.textContent || '').replace(/\s+/g, ' ').trim() });
      });
    });
    found.sort((a, b) => {
      if (a.element === b.element) return 0;
      const position = a.element.compareDocumentPosition(b.element);
      return position & Node.DOCUMENT_POSITION_FOLLOWING ? -1 : 1;
    });
    const counters = {};
    return found.map((target) => {
      const index = counters[target.prefix] || 0;
      counters[target.prefix] = index + 1;
      return { ...target, key: `${target.prefix}-${index}` };
    });
  }

  function detachedTargets(html) {
    const holder = document.createElement('div');
    holder.innerHTML = html || '';
    return collectTargets(holder);
  }

  function expandGroup(specs, targets) {
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
  }

  const groupText = (group, targets) => group.map((key) => targets.find((target) => target.key === key)?.text || '').join(' ');

  function semanticScore(unit, group, groupIndex, groupCount, unitIndex, unitCount, targets) {
    const unitTokens = tokensOf(unit);
    const groupTokens = tokensOf(groupText(group, targets));
    let score = 0;
    unitTokens.forEach((token) => {
      if (groupTokens.has(token)) score += token.length >= 5 ? 6 : token.length >= 3 ? 4 : 2;
    });
    const ordinals = [[/첫째|첫 번째|첫번째/, 0], [/둘째|두 번째|두번째/, 1], [/셋째|세 번째|세번째/, 2], [/넷째|네 번째|네번째/, 3], [/다섯째|다섯 번째|다섯번째/, 4]];
    const ordinal = ordinals.find(([pattern]) => pattern.test(unit));
    if (ordinal) score += ordinal[1] === groupIndex ? 14 : -5;
    const actual = (unitIndex + 0.5) / Math.max(1, unitCount);
    const expected = (groupIndex + 0.5) / Math.max(1, groupCount);
    return score - Math.abs(actual - expected) * 4;
  }

  function mergeGroups(groups, maxGroups) {
    if (groups.length <= maxGroups) return groups;
    const merged = Array.from({ length: maxGroups }, () => []);
    groups.forEach((group, index) => {
      const bucket = Math.min(maxGroups - 1, Math.floor(index * maxGroups / groups.length));
      merged[bucket].push(...group);
    });
    return merged.map((group) => [...new Set(group)]);
  }

  function partitionUnits(units, groups, targets) {
    if (!groups.length) return [{ text: units.join(' '), focusKeys: [] }];
    if (groups.length === 1) return [{ text: units.join(' '), focusKeys: groups[0] }];
    const effective = mergeGroups(groups, Math.max(1, Math.min(groups.length, units.length)));
    const n = units.length;
    const m = effective.length;
    const prefix = Array.from({ length: m }, () => Array(n + 1).fill(0));
    for (let g = 0; g < m; g += 1) {
      for (let i = 0; i < n; i += 1) prefix[g][i + 1] = prefix[g][i] + semanticScore(units[i], effective[g], g, m, i, n, targets);
    }
    const blockScore = (g, start, end) => {
      const semantic = prefix[g][end] - prefix[g][start];
      const center = ((start + end) / 2) / n;
      const expected = (g + 0.5) / m;
      return semantic - Math.abs(center - expected) * 6 - Math.abs((end - start) - n / m) * 0.15;
    };
    const dp = Array.from({ length: m + 1 }, () => Array(n + 1).fill(-Infinity));
    const prev = Array.from({ length: m + 1 }, () => Array(n + 1).fill(-1));
    dp[0][0] = 0;
    for (let g = 1; g <= m; g += 1) {
      for (let end = g; end <= n - (m - g); end += 1) {
        for (let start = g - 1; start < end; start += 1) {
          if (!Number.isFinite(dp[g - 1][start])) continue;
          const candidate = dp[g - 1][start] + blockScore(g - 1, start, end);
          if (candidate > dp[g][end]) { dp[g][end] = candidate; prev[g][end] = start; }
        }
      }
    }
    const boundaries = [];
    let end = n;
    for (let g = m; g >= 1; g -= 1) {
      const start = Math.max(0, prev[g][end]);
      boundaries.push([start, end]);
      end = start;
    }
    boundaries.reverse();
    return boundaries.map(([start, finish], index) => ({ text: units.slice(start, finish).join(' '), focusKeys: effective[index] })).filter((step) => step.text);
  }

  function applyScriptFixes(slides, block) {
    const fixes = SCRIPT_FIXES[block] || {};
    slides.forEach((slide) => {
      if (fixes[slide.k]) slide.s = fixes[slide.k];
    });
  }

  function buildSteps(slide, slideIndex = 0, block = 'theory') {
    const cacheKey = `__chapter05Steps_${block}`;
    if (slide?.[cacheKey]) return slide[cacheKey];
    const units = splitUnits(slide?.s || '');
    const targets = detachedTargets(slide?.h || '');
    const plan = PLANS[block]?.[slide?.k];
    if (!plan) {
      console.warn(`[Chapter05] 단계 계획이 없는 장표: ${block} ${slideIndex + 1} ${slide?.k || ''}`);
      slide[cacheKey] = [{ text: units.join(' '), focusKeys: [] }];
      return slide[cacheKey];
    }
    const groups = plan.map((specs) => expandGroup(specs, targets)).filter((group) => group.length);
    slide[cacheKey] = partitionUnits(units, groups, targets);
    slide.steps = slide[cacheKey].length;
    return slide[cacheKey];
  }

  function prepareSlides(slides, block) {
    applyScriptFixes(slides, block);
    slides.forEach((slide, index) => buildSteps(slide, index, block));
    return slides;
  }

  function applyFocus(root, slide, slideIndex, stepIndex, block) {
    const targets = collectTargets(root);
    targets.forEach(({ element }) => element.classList.remove('focus-muted', 'focus-active'));
    if (stepIndex <= 0) return;
    const step = buildSteps(slide, slideIndex, block)[stepIndex - 1];
    if (!step?.focusKeys?.length) return;
    const selected = new Set(step.focusKeys);
    targets.forEach(({ key, element }) => element.classList.add(selected.has(key) ? 'focus-active' : 'focus-muted'));
  }

  function audit(slides, block) {
    const issues = [];
    const plans = PLANS[block] || {};
    slides.forEach((slide, index) => {
      if (!plans[slide.k]) issues.push(`missing plan: ${block} ${index + 1} ${slide.k}`);
      const targets = detachedTargets(slide.h || '');
      const targetKeys = new Set(targets.map((target) => target.key));
      (plans[slide.k] || []).flat().forEach((spec) => {
        if (spec.endsWith(':*')) {
          const prefix = spec.slice(0, -2);
          if (!targets.some((target) => target.prefix === prefix)) issues.push(`missing target group: ${block} ${slide.k} ${spec}`);
        } else if (!targetKeys.has(spec)) issues.push(`missing target: ${block} ${slide.k} ${spec}`);
      });
      if (!buildSteps(slide, index, block).length) issues.push(`empty steps: ${block} ${index + 1} ${slide.k}`);
    });
    return issues;
  }

  window.CH5Navigation = Object.freeze({
    buildSteps,
    prepareSlides,
    applyFocus,
    prepareCodeLines,
    splitUnits,
    audit,
    plans: PLANS
  });
})();
