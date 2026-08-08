(() => {
  'use strict';

  const AUTO = 'AUTO';

  const PLANS = {
    theory: {
      'Chapter 12는 저장소 이름보다 데이터 역할을 먼저 봅니다': AUTO,
      'NoSQL은 RDBMS의 반대말이 아닙니다': AUTO,
      'RDBMS와 NoSQL은 역할을 나눌 수 있습니다': AUTO,
      'Source of Truth를 먼저 정해야 합니다': AUTO,
      'NoSQL 유형은 조회 방식으로 구분합니다': AUTO,
      'Key-Value는 좋은 키와 만료 정책이 핵심입니다': [['code:*'], ['body:*']],
      '캐시는 Seed 기준과 현재 기준을 구분합니다': [['code:*']],
      'Document 모델은 포함과 참조의 경계를 정합니다': [['body-0'], ['code-0'], ['body-1'], ['code-1']],
      '안정된 컬럼과 가변 메타데이터를 분리합니다': [['row:*']],
      'instructor_snapshot은 원본이 아니라 표시용 복사본입니다': [['code:*']],
      'Column-Family는 조회 문장에서 역으로 설계합니다': [['body-0'], ['code-0'], ['body-1'], ['code-1']],
      'Graph DB는 관계의 존재보다 탐색 깊이가 중요합니다': AUTO,
      '일관성은 제품 이름이 아니라 범위로 확인합니다': AUTO,
      '여러 저장소를 쓰면 동기화 실패를 설계해야 합니다': AUTO,
      'JSONB는 조회 연산자와 검증 책임을 함께 봅니다': [['row:*']],
      'document_version은 낙관적 잠금의 핵심입니다': [['code:*']],
      'JSONB 인덱스도 실제 질의 형태에서 출발합니다': [['code:*']],
      '후보 저장소와 채택 결정은 다릅니다': [['code:*']],
      '작은 PoC는 성능보다 실패 조건까지 봐야 합니다': AUTO,
      '핵심 정리: 저장소 선택은 역할·조회·복구 책임의 결정입니다': AUTO
    },
    practice: {
      '이번 실습은 NoSQL 제품 실습이 아니라 선택 기준 검증입니다': AUTO,
      '실습 전 실행 위치와 보호 범위를 확인합니다': [['code:*'], ['body:*']],
      '세 테이블의 역할을 먼저 이해합니다': [['row:*']],
      '시스템 역할을 분류합니다': [['row:*']],
      'Key-Value 캐시 키를 읽습니다': [['body-0'], ['code-0'], ['body-1'], ['code-1']],
      'Seed 기준 캐시와 현재 기준 캐시를 구분합니다': [['row:*']],
      'Document 테이블에서 일반 컬럼과 JSONB를 구분합니다': [['row:*']],
      'Chapter 07 원본과 문서 매핑을 확인합니다': [['row:*']],
      'instructor_snapshot을 원본과 대조합니다': [['code:*'], ['body:*']],
      'JSONB 연산자를 실행해 봅니다': [['row:*']],
      'JSONB 구조 검증 책임을 기록합니다': [['row:*']],
      'document_version으로 낙관적 잠금을 확인합니다': [['row:*']],
      '`jsonb_set`은 경로 확인이 필요합니다': [['code:*']],
      'Column-Family는 조회 패턴을 워크북에 적습니다': [['code:*']],
      'Graph DB 후보는 관계 탐색 깊이로 판단합니다': [['row:*']],
      '저장소 후보와 결정 상태를 검토합니다': [['row:*']],
      '여러 저장소 동기화 실패를 검토합니다': [['row:*']],
      'JSONB 인덱스 후보를 생성하고 정의를 확인합니다': [['code:*'], ['body:*']],
      '최종 검증 SQL로 기준 상태를 확인합니다': AUTO,
      'AI 저장소 추천과 최종 완료 기준을 정리합니다': AUTO
    }
  };

  const TARGET_SPECS = [
    ['.screen-text', 'body'],
    ['.bullet-list li', 'item'],
    ['table tbody tr', 'row'],
    ['.code-line', 'code'],
    ['.quote', 'quote'],
    ['.card', 'card'],
    ['.flow-step', 'flow'],
    ['.pill', 'pill'],
    ['.chip', 'chip']
  ];

  const STOP_WORDS = new Set([
    '이번', '장표', '단계', '입니다', '있습니다', '합니다', '됩니다', '그리고', '하지만', '따라서',
    '먼저', '다음', '마지막', '확인', '경우', '대한', '위해', '사용', '실습', '데이터', '저장소',
    '모델', '기준', '후보'
  ]);

  const normalize = (value) => String(value ?? '')
    .toLowerCase()
    .replace(/source of truth/g, '원본 기준')
    .replace(/rdbms/g, '관계형 데이터베이스')
    .replace(/nosql/g, '노에스큐엘')
    .replace(/key-value/g, '키 밸류')
    .replace(/column-family/g, '컬럼 패밀리')
    .replace(/graph db/g, '그래프 데이터베이스')
    .replace(/document db/g, '문서 데이터베이스')
    .replace(/document/g, '문서')
    .replace(/jsonb/g, '제이슨비')
    .replace(/jsonb_set/g, '제이슨비 수정')
    .replace(/json/g, '제이슨')
    .replace(/ttl/g, '만료 시간')
    .replace(/poc/g, '검증 실험')
    .replace(/current_timestamp/g, '현재 시각')
    .replace(/partition key/g, '파티션 키')
    .replace(/clustering key/g, '정렬 키')
    .replace(/ephemeral state/g, '임시 상태')
    .replace(/derived cache/g, '파생 캐시')
    .replace(/flexible metadata/g, '가변 메타데이터')
    .replace(/event log/g, '이벤트 로그')
    .replace(/relationship index/g, '관계 인덱스')
    .replace(/instructor_snapshot/g, '강사 스냅샷')
    .replace(/source_course_id/g, '원본 강의 아이디')
    .replace(/source_instructor_id/g, '원본 강사 아이디')
    .replace(/document_version/g, '문서 버전')
    .replace(/course_documents/g, '강의 문서')
    .replace(/key_value_cache_examples/g, '키 밸류 캐시 예시')
    .replace(/storage_choice_cases/g, '저장소 선택 기록')
    .replace(/nosql_lab/g, '노에스큐엘 랩')
    .replace(/course_project/g, '코스 프로젝트')
    .replace(/transaction_lab/g, '트랜잭션 랩')
    .replace(/performance_lab/g, '퍼포먼스 랩')
    .replace(/security_lab/g, '시큐리티 랩')
    .replace(/gin/g, '진 인덱스')
    .replace(/metadata/g, '메타데이터')
    .replace(/cache/g, '캐시')
    .replace(/snapshot/g, '스냅샷')
    .replace(/seed/g, '시드')
    .replace(/rollback/g, '롤백')
    .replace(/index/g, '인덱스')
    .replace(/select/g, '조회')
    .replace(/update/g, '수정')
    .replace(/create/g, '생성')
    .replace(/[^0-9a-z가-힣]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

  const tokensOf = (value) => new Set(
    normalize(value).split(' ').filter((token) => token.length >= 2 && !STOP_WORDS.has(token))
  );

  function splitUnits(text) {
    const paragraphs = String(text || '').trim().split(/\n\s*\n/)
      .map((value) => value.replace(/\s+/g, ' ').trim())
      .filter(Boolean);
    const units = [];
    paragraphs.forEach((paragraph) => {
      const sentences = (paragraph.match(/[^.!?。]+[.!?。]?/g) || [])
        .map((value) => value.trim())
        .filter(Boolean);
      if (sentences.length <= 1) units.push(paragraph);
      else units.push(...sentences);
    });
    return units.length ? units : ['핵심 내용을 설명합니다.'];
  }

  function collectTargets(root) {
    const found = [];
    const seen = new Set();
    TARGET_SPECS.forEach(([selector, prefix]) => {
      root.querySelectorAll(selector).forEach((element) => {
        if (seen.has(element)) return;
        const text = (element.innerText || element.textContent || '').replace(/\s+/g, ' ').trim();
        if (prefix === 'code' && !text) return;
        seen.add(element);
        found.push({ element, prefix, text });
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

  function mergeGroups(groups, maxGroups) {
    if (groups.length <= maxGroups) return groups;
    const merged = Array.from({ length: maxGroups }, () => []);
    groups.forEach((group, index) => {
      const bucket = Math.min(maxGroups - 1, Math.floor(index * maxGroups / groups.length));
      merged[bucket].push(...group);
    });
    return merged.map((group) => [...new Set(group)]);
  }

  function autoGroups(targets) {
    const detailed = targets.filter((target) => target.prefix !== 'body');
    const source = detailed.length ? detailed : targets;
    if (!source.length) return [];
    return mergeGroups(source.map((target) => [target.key]), 6);
  }

  const groupText = (group, targets) => group
    .map((key) => targets.find((target) => target.key === key)?.text || '')
    .join(' ');

  function semanticScore(unit, group, groupIndex, groupCount, unitIndex, unitCount, targets) {
    const unitTokens = tokensOf(unit);
    const groupTokens = tokensOf(groupText(group, targets));
    let score = 0;
    unitTokens.forEach((token) => {
      if (groupTokens.has(token)) score += token.length >= 5 ? 6 : token.length >= 3 ? 4 : 2;
    });
    const actual = (unitIndex + 0.5) / Math.max(1, unitCount);
    const expected = (groupIndex + 0.5) / Math.max(1, groupCount);
    return score - Math.abs(actual - expected) * 4;
  }

  function partitionUnits(units, groups, targets) {
    if (!groups.length) return [{ text: units.join(' '), focusKeys: [] }];
    if (groups.length === 1) return [{ text: units.join(' '), focusKeys: groups[0] }];
    const effective = mergeGroups(groups, Math.max(1, Math.min(groups.length, units.length)));
    const n = units.length;
    const m = effective.length;
    const prefix = Array.from({ length: m }, () => Array(n + 1).fill(0));
    for (let g = 0; g < m; g += 1) {
      for (let i = 0; i < n; i += 1) {
        prefix[g][i + 1] = prefix[g][i] + semanticScore(units[i], effective[g], g, m, i, n, targets);
      }
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
      const start = Math.max(0, prev[g][end]);
      boundaries.push([start, end]);
      end = start;
    }
    boundaries.reverse();
    return boundaries
      .map(([start, finish], index) => ({ text: units.slice(start, finish).join(' '), focusKeys: effective[index] }))
      .filter((step) => step.text);
  }

  function planFor(slide, block) {
    return PLANS[block]?.[slide?.t] ?? null;
  }

  function planKey(slide, block) {
    return Object.prototype.hasOwnProperty.call(PLANS[block] || {}, slide?.t) ? slide.t : null;
  }

  function buildSteps(slide, slideIndex = 0, block = 'theory') {
    const cacheKey = `__chapter12Steps_${block}`;
    if (slide?.[cacheKey]) return slide[cacheKey];
    const units = splitUnits(slide?.s || '');
    const targets = detachedTargets(slide?.h || '');
    const plan = planFor(slide, block);
    if (!plan) {
      console.warn(`[Chapter12] 단계 계획이 없는 장표: ${block} ${slideIndex + 1} ${slide?.t || ''}`);
      slide[cacheKey] = [{ text: units.join(' '), focusKeys: [] }];
      return slide[cacheKey];
    }
    const groups = plan === AUTO
      ? autoGroups(targets)
      : plan.map((specs) => expandGroup(specs, targets)).filter((group) => group.length);
    slide[cacheKey] = partitionUnits(units, groups.length ? groups : autoGroups(targets), targets);
    slide.steps = slide[cacheKey].length;
    return slide[cacheKey];
  }

  function prepareSlides(slides, block) {
    slides.forEach((slide, index) => buildSteps(slide, index, block));
    return slides;
  }

  function clearFocus(root) {
    root.querySelectorAll('.focus-target,.focus-active,.focus-muted').forEach((element) => {
      element.classList.remove('focus-target', 'focus-active', 'focus-muted');
    });
  }

  function applyFocus(root, slide, slideIndex = 0, stepIndex = 0, block = 'theory') {
    if (!root) return;
    clearFocus(root);
    const targets = collectTargets(root);
    targets.forEach((target) => target.element.classList.add('focus-target'));
    if (stepIndex <= 0) return;
    const steps = buildSteps(slide, slideIndex, block);
    const step = steps[Math.max(0, Math.min(steps.length - 1, stepIndex - 1))];
    const activeKeys = new Set(step?.focusKeys || []);
    targets.forEach((target) => {
      target.element.classList.toggle('focus-active', activeKeys.has(target.key));
      target.element.classList.toggle('focus-muted', !activeKeys.has(target.key));
    });
  }

  function describeSteps(slide, slideIndex = 0, block = 'theory') {
    return buildSteps(slide, slideIndex, block).map((step, index) => ({
      step: index + 1,
      text: step.text,
      focusKeys: step.focusKeys.slice()
    }));
  }

  function audit(slides, block) {
    const issues = [];
    slides.forEach((slide, index) => {
      if (!planKey(slide, block)) issues.push(`missing-plan:${index + 1}:${slide?.t || ''}`);
      const steps = buildSteps(slide, index, block);
      if (!steps.length) issues.push(`empty-steps:${index + 1}:${slide?.t || ''}`);
    });
    return issues;
  }

  window.CH12Navigation = Object.freeze({
    version: '2026-08-08-semantic-sync-1',
    buildSteps,
    prepareSlides,
    clearFocus,
    applyFocus,
    describeSteps,
    audit,
    planKey,
    all: PLANS
  });
})();
