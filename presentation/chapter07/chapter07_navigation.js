(() => {
  'use strict';

  const PLANS = {
    theory: {
      'Chapter 07은 앞 장의 개념을 하나의 프로젝트로 묶습니다': [['code-0', 'code-1', 'code-2'], ['code-3', 'code-4', 'code-5']],
      '프로젝트 완료 기준은 재현성과 설명 가능성입니다': [['item-0', 'item-1'], ['item-2', 'item-3']],
      '전용 스키마 `course_project`를 사용합니다': [['code:*']],
      '범위 제외를 먼저 정해야 모델이 커지지 않습니다': [['row:*']],
      '확정 요구사항·프로젝트 결정·미확정 질문을 구분합니다': [['code-0'], ['code-1', 'code-2', 'code-3']],
      '한 행의 의미를 먼저 정합니다': [['row:*']],
      '현재 가격과 신청 당시 금액은 다른 사실입니다': [['code-0', 'code-1'], ['code-2', 'code-3']],
      '학생과 강의의 N:M 관계는 `enrollments`로 풉니다': [['code:*']],
      '관계 문장은 외래키 위치를 결정합니다': [['code:*']],
      '무결성 규칙은 확정된 정책만 구현합니다': [['row:*']],
      '진행 중 중복 신청은 부분 고유 인덱스로 막습니다': [['code-0', 'code-1'], ['code-2']],
      '샘플 데이터는 테스트 목적을 가진 기준 데이터입니다': [['row:*']],
      '변경 시나리오는 예상 이전 상태를 조건에 넣습니다': [['code:*']],
      '검증은 행 수, 관계, 상태, 금액을 함께 확인합니다': [['code-0'], ['code-1', 'code-2', 'code-3', 'code-4', 'code-5']],
      '정상값뿐 아니라 경계값과 오류값도 확인합니다': [['row-0'], ['row-1']],
      '초기화는 편의 기능이 아니라 삭제 작업입니다': [['code-0', 'code-1'], ['code-2', 'code-3']],
      'AI 제안은 요구사항 추적표로 검토합니다': [['item:*']],
      '핵심 정리: 프로젝트는 구조와 증거로 완성됩니다': [['code:*']]
    },
    practice: {
      '이번 실습은 파일 실행이 아니라 상태 검증입니다': [['code-0', 'code-1', 'code-2'], ['code-3', 'code-4']],
      '실행 전에 위치와 자동 커밋을 확인합니다': [['code:*', 'item-0', 'item-1'], ['item-2']],
      '`01_course_project_schema.sql`은 구조만 만듭니다': [['code:*']],
      '스키마 파일에서 제약조건의 역할을 읽습니다': [['row:*']],
      '`02_course_project_seed.sql`은 기준 데이터를 만듭니다': [['row:*']],
      '명시적 ID와 IDENTITY 다음 값을 구분합니다': [['code-0', 'code-1', 'code-2', 'code-3', 'code-4'], ['code-5', 'code-6']],
      '`03_course_project_changes.sql`은 변경 시나리오입니다': [['code:*']],
      '신규 신청 전에는 기존 활성 신청을 먼저 확인합니다': [['code:*'], ['item-0']],
      '변경 SQL은 `RETURNING`으로 결과를 확인합니다': [['code-0', 'code-1', 'code-2', 'code-3'], ['code-4']],
      '변경 파일 실행 후 핵심 상태를 확인합니다': [['row:*']],
      '`04_course_project_validation.sql`은 최종 상태를 조회합니다': [['code-0', 'code-1', 'code-2', 'code-3'], ['code-4']],
      '관계 검증은 “연결이 실제로 되는가”를 확인합니다': [['code-0', 'code-1', 'code-2'], ['code-3']],
      '최종 검산값은 다음 장의 기준 데이터가 됩니다': [['code:*']],
      '`05` 파일의 성공 경계값은 실제로 성공해야 합니다': [['item:*']],
      '실패해야 하는 오류값은 한 테스트씩 실행합니다': [['item:*']],
      '두 번째 활성 신청 오류는 부분 고유 인덱스의 증거입니다': [['code-0', 'code-1', 'code-2'], ['code-3', 'code-4']],
      '오류 후 `current transaction is aborted`가 나오면 `ROLLBACK`합니다': [['code-0', 'code-1', 'code-2'], ['code-3']],
      '초기화 파일은 마지막 수단으로 사용합니다': [['code-0', 'code-1'], ['code-2', 'code-3']],
      'AI 사용 기록은 수정 근거까지 남깁니다': [['code:*']],
      '최종 완료 기준은 구조·데이터·오류 테스트가 모두 맞는 것입니다': [['item:*']]
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
    '먼저', '다음', '마지막', '확인', '경우', '대한', '위해', '사용', '실습', '프로젝트', '데이터'
  ]);

  const normalize = (value) => String(value ?? '')
    .toLowerCase()
    .replace(/course_project/g, '코스 프로젝트')
    .replace(/students/g, '학생')
    .replace(/instructors/g, '강사')
    .replace(/courses/g, '강의')
    .replace(/enrollments/g, '수강신청')
    .replace(/recorded_amount|paid_amount/g, '기록 금액')
    .replace(/primary key|\bpk\b/g, '기본키')
    .replace(/foreign key|\bfk\b/g, '외래키')
    .replace(/not null/g, '낫 널')
    .replace(/unique/g, '유니크')
    .replace(/check/g, '체크')
    .replace(/identity/g, '아이덴티티')
    .replace(/returning/g, '리터닝')
    .replace(/rollback/g, '롤백')
    .replace(/join/g, '조인')
    .replace(/null/g, '널')
    .replace(/cascade/g, '캐스케이드')
    .replace(/restrict/g, '리스트릭트')
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
    return PLANS[block]?.[slide?.t] || null;
  }

  function buildSteps(slide, slideIndex = 0, block = 'theory') {
    const cacheKey = `__chapter07Steps_${block}`;
    if (slide?.[cacheKey]) return slide[cacheKey];
    const units = splitUnits(slide?.s || '');
    const targets = detachedTargets(slide?.h || '');
    const plan = planFor(slide, block);
    if (!plan) {
      console.warn(`[Chapter07] 단계 계획이 없는 장표: ${block} ${slideIndex + 1} ${slide?.t || ''}`);
      slide[cacheKey] = [{ text: units.join(' '), focusKeys: [] }];
      return slide[cacheKey];
    }
    const groups = plan.map((specs) => expandGroup(specs, targets)).filter((group) => group.length);
    slide[cacheKey] = partitionUnits(units, groups, targets);
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
    const selected = new Set(step.focusKeys);
    targets.forEach(({ key, element }) => element.classList.add(selected.has(key) ? 'focus-active' : 'focus-muted'));
  }

  function audit(slides, block) {
    const issues = [];
    slides.forEach((slide, index) => {
      const plan = planFor(slide, block);
      if (!plan) {
        issues.push(`missing plan: ${block} ${index + 1} ${slide?.t || ''}`);
        return;
      }
      const targets = detachedTargets(slide.h || '');
      const targetKeys = new Set(targets.map((target) => target.key));
      plan.flat().forEach((spec) => {
        if (spec.endsWith(':*')) {
          const prefix = spec.slice(0, -2);
          if (!targets.some((target) => target.prefix === prefix)) issues.push(`missing target group: ${block} ${index + 1} ${spec}`);
        } else if (!targetKeys.has(spec)) {
          issues.push(`missing target: ${block} ${index + 1} ${spec}`);
        }
      });
      if (!buildSteps(slide, index, block).length) issues.push(`empty steps: ${block} ${index + 1}`);
    });
    return issues;
  }

  window.CH7Navigation = Object.freeze({
    buildSteps,
    prepareSlides,
    applyFocus,
    splitUnits,
    audit,
    plans: PLANS
  });
})();