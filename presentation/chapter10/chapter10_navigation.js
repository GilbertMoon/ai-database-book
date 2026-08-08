(() => {
  'use strict';

  const AUTO = 'AUTO';

  const PLANS = {
    theory: {
      'Chapter 10은 빠른 조회를 증거로 검증하는 장입니다': AUTO,
      '작은 프로젝트 데이터와 성능 실험 데이터는 분리합니다': AUTO,
      '합성 데이터도 검증 가능한 업무 의미를 가져야 합니다': AUTO,
      '인덱스는 검색을 돕는 별도 구조입니다': [['code:*'], ['item:*']],
      '자동 인덱스와 수동 인덱스를 먼저 구분합니다': AUTO,
      'ANALYZE와 EXPLAIN ANALYZE는 다릅니다': AUTO,
      '실행 계획은 결과표가 아니라 처리 경로입니다': AUTO,
      'Seq Scan은 항상 나쁜 계획이 아닙니다': AUTO,
      'WHERE 조건은 인덱스 후보의 출발점입니다': AUTO,
      'JOIN에서는 외래키 자식 컬럼을 검토합니다': AUTO,
      '복합 인덱스는 컬럼 순서가 중요합니다': [['code:*'], ['row-0'], ['row-1'], ['row-2']],
      'ORDER BY와 LIMIT도 계획에 영향을 줍니다': [['code-0'], ['code-1'], ['item:*']],
      '인덱스 전후 비교는 조건을 통제해야 합니다': AUTO,
      '결과 행 동일성은 실행 계획과 별도로 확인합니다': AUTO,
      '예상 rows와 actual rows 차이를 봅니다': AUTO,
      '인덱스에는 읽기 이점과 쓰기 비용이 함께 있습니다': AUTO,
      '운영 환경의 CREATE INDEX는 잠금을 고려해야 합니다': AUTO,
      '중복 인덱스와 미사용 인덱스를 조심합니다': AUTO,
      'AI 추천 인덱스는 실행 계획으로 검토합니다': AUTO,
      '핵심 정리: 인덱스의 가치는 측정으로 판단합니다': AUTO
    },
    practice: {
      '이번 실습은 인덱스 효과를 증거로 확인합니다': AUTO,
      '실행 전에 보호할 스키마를 구분합니다': AUTO,
      '기준 데이터 규모와 IDENTITY 값을 확인합니다': AUTO,
      '합성 데이터의 기준 결과를 먼저 기록합니다': AUTO,
      '자동 인덱스를 먼저 확인합니다': [['code:*'], ['item:*']],
      '기준 계획은 후보 인덱스가 없는 상태에서 기록합니다': AUTO,
      'EXPLAIN ANALYZE 결과에서 볼 항목을 정합니다': AUTO,
      '이메일 검색은 자동 인덱스 사용을 확인합니다': [['code:*'], ['item:*']],
      '강의 제목 검색은 전후 비교 대상입니다': [['code:*'], ['row:*']],
      '학생별 신청 JOIN은 FK 자식 인덱스를 검토합니다': [['code:*'], ['item:*']],
      '복합 인덱스는 세 조건을 나누어 봅니다': [['code:*'], ['row-0'], ['row-1'], ['row-2']],
      'ORDER BY와 LIMIT 계획을 비교합니다': AUTO,
      '후보 인덱스 3개를 만들고 같은 SQL을 다시 측정합니다': AUTO,
      '기준 계획과 사후 계획을 표로 비교합니다': AUTO,
      '결과 검증 파일로 데이터 상태를 확인합니다': AUTO,
      '예상 rows와 actual rows 차이를 기록합니다': AUTO,
      '인덱스 목록·크기·사용 통계를 검토합니다': AUTO,
      '읽기 이점과 쓰기 비용을 함께 판단합니다': AUTO,
      '운영 적용은 별도 질문입니다': AUTO,
      '최종 완료 기준은 측정 기록과 판단 근거입니다': AUTO
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
    '먼저', '다음', '마지막', '확인', '경우', '대한', '위해', '사용', '실습', '데이터', '인덱스'
  ]);

  const normalize = (value) => String(value ?? '')
    .toLowerCase()
    .replace(/performance_lab/g, '퍼포먼스 랩')
    .replace(/course_project/g, '코스 프로젝트')
    .replace(/transaction_lab/g, '트랜잭션 랩')
    .replace(/explain analyze/g, '실행 계획 실제 측정')
    .replace(/analyze/g, '통계 수집')
    .replace(/bitmap heap scan|bitmap index scan|bitmap scan/g, '비트맵 스캔')
    .replace(/index only scan|index scan/g, '인덱스 스캔')
    .replace(/seq scan/g, '순차 스캔')
    .replace(/index cond/g, '인덱스 조건')
    .replace(/execution time/g, '실행 시간')
    .replace(/actual rows/g, '실제 행')
    .replace(/buffers/g, '버퍼')
    .replace(/rows/g, '행')
    .replace(/cost/g, '비용')
    .replace(/filter/g, '필터')
    .replace(/order by/g, '정렬')
    .replace(/limit/g, '리밋')
    .replace(/where/g, '조건')
    .replace(/join/g, '조인')
    .replace(/foreign key|\bfk\b/g, '외래키')
    .replace(/primary key|\bpk\b/g, '기본키')
    .replace(/unique/g, '유니크')
    .replace(/b-tree|btree/g, '비트리')
    .replace(/skip scan/g, '스킵 스캔')
    .replace(/create index concurrently/g, '운영 인덱스 생성')
    .replace(/create index/g, '인덱스 생성')
    .replace(/pg_indexes/g, '인덱스 목록')
    .replace(/pg_stat_user_indexes/g, '인덱스 사용 통계')
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
    const cacheKey = `__chapter10Steps_${block}`;
    if (slide?.[cacheKey]) return slide[cacheKey];
    const units = splitUnits(slide?.s || '');
    const targets = detachedTargets(slide?.h || '');
    const plan = planFor(slide, block);
    if (!plan) {
      console.warn(`[Chapter10] 단계 계획이 없는 장표: ${block} ${slideIndex + 1} ${slide?.t || ''}`);
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

  function applyFocus(root, slide, slideIndex, stepIndex, block) {
    const targets = collectTargets(root);
    targets.forEach(({ element }) => element.classList.remove('focus-muted', 'focus-active'));
    if (stepIndex <= 0) return;
    const step = buildSteps(slide, slideIndex, block)[stepIndex - 1];
    if (!step?.focusKeys?.length) return;
    const active = new Set(step.focusKeys);
    targets.forEach(({ element, key }) => {
      element.classList.toggle('focus-active', active.has(key));
      element.classList.toggle('focus-muted', !active.has(key));
    });
  }

  function audit(slides, block) {
    const issues = [];
    slides.forEach((slide, index) => {
      if (!planKey(slide, block)) issues.push(`missing plan: ${block} ${index + 1} ${slide?.t || ''}`);
      if (!String(slide?.s || '').trim()) issues.push(`empty script: ${block} ${index + 1}`);
      if (!String(slide?.h || '').trim()) issues.push(`empty body: ${block} ${index + 1}`);
      if (!buildSteps(slide, index, block).length) issues.push(`empty steps: ${block} ${index + 1}`);
    });
    return issues;
  }

  window.CH10Navigation = Object.freeze({
    version: '2026-08-08-semantic-sync-1',
    buildSteps,
    prepareSlides,
    applyFocus,
    splitUnits,
    audit,
    planKey,
    all: PLANS
  });
})();
