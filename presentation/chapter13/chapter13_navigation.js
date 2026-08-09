(() => {
  'use strict';

  const AUTO = 'AUTO';

  const PLANS = {
    theory: {
      'Chapter 13은 AI 결과를 검증하는 장입니다': AUTO,
      '실행 성공과 설계 검증은 다릅니다': AUTO,
      'ChatGPT·Codex·사람의 역할을 구분합니다': [['row:*']],
      'AI에는 질문 한 줄이 아니라 문맥 묶음을 줍니다': [['code:*']],
      '요구사항·결정·테스트·검증을 ID로 분리합니다': [['code:*']],
      '활성 신청 중복은 전체 UNIQUE가 아닙니다': [['code-0'], ['body-0', 'code-1']],
      'ERD는 예쁘게 그렸는지가 아니라 요구사항 반영으로 봅니다': [['body-0', 'code:*']],
      '나쁜 설계는 한 행에 너무 많은 역할을 섞습니다': [['code:*']],
      '타입과 제약조건은 업무 의미로 검토합니다': [['row:*']],
      '이메일 UNIQUE의 범위를 명확히 합니다': [['code:*']],
      '현재 가격·신청 시점 기록 금액·결제 상태 기록 금액은 다릅니다': [['code:*']],
      '결제 시각과 환불 시각을 분리합니다': [['row:*']],
      '실습은 ai_review_lab에서만 진행합니다': [['code:*']],
      '실제 메타데이터를 정확히 확인합니다': [['code:*']],
      '정상 경계값과 실패 반례를 함께 봅니다': [['code-0'], ['body-0', 'code-1']],
      'LEFT JOIN의 NULL을 놓치지 않습니다': [['body-0', 'code-0'], ['body-1', 'code-1']],
      '제약조건 이후에도 업무 정합성 조회가 필요합니다': [['body-0', 'code-0'], ['body-1', 'code-1']],
      '민감정보 미저장은 여러 증거로 확인합니다': [['code:*']],
      'AI가 만든 diff와 파괴적 SQL을 별도로 검토합니다': [['body-0', 'code:*']],
      '핵심 정리: AI 결과는 증거로 승인합니다': [['code:*']]
    },
    practice: {
      '이번 실습은 AI 설계를 바로 믿지 않는 연습입니다': AUTO,
      '실행 파일 순서를 먼저 확인합니다': [['row:*']],
      '보호 범위와 실행 위치를 확인합니다': [['code-0'], ['body-0', 'code-1']],
      '요구사항 ID를 워크북에 먼저 기록합니다': [['code-0'], ['body-0', 'code-1']],
      'AI에 제공할 문맥 묶음을 점검합니다': [['row:*']],
      '나쁜 설계 테이블을 먼저 관찰합니다': [['body-0', 'code:*']],
      '좋은 설계의 테이블 역할을 구분합니다': [['row:*']],
      '관계와 카디널리티를 확인합니다': [['code:*']],
      '전체 UNIQUE와 부분 고유 인덱스를 비교합니다': [['code:*']],
      '이메일과 문자열 정책을 확인합니다': [['body-0', 'code:*']],
      '가격·신청 시점 기록 금액·결제 상태 기록 금액을 구분합니다': [['row:*']],
      '결제·환불 시각 조합을 검증합니다': [['row:*']],
      '기준 데이터와 IDENTITY 다음 값을 확인합니다': [['code:*']],
      '실제 메타데이터 검증 파일을 실행합니다': [['body-0', 'code:*']],
      '업무 정합성 검증 파일을 실행합니다': [['body-0', 'code:*']],
      'LEFT JOIN과 NULL 검증을 직접 설명합니다': [['body-0', 'code-0'], ['body-1', 'code-1']],
      '반례 24개와 정상 경계값 6개를 확인합니다': [['code:*']],
      '민감정보 미저장 증거를 기록합니다': [['row:*']],
      '최종 자동 검증 파일을 실행합니다': [['body-0', 'code-0'], ['body-1', 'code-1']],
      'diff 검토와 승인 상태를 기록합니다': [['body-0', 'code-0'], ['body-1', 'code-1']]
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
    '먼저', '다음', '마지막', '확인', '경우', '대한', '위해', '사용', '실습', '데이터', '설계',
    '검증', '결과', '기준', '항목'
  ]);

  const normalize = (value) => String(value ?? '')
    .toLowerCase()
    .replace(/chatgpt/g, '챗지피티')
    .replace(/codex/g, '코덱스')
    .replace(/ai_review_lab/g, '에이아이 리뷰 랩')
    .replace(/course_project/g, '코스 프로젝트')
    .replace(/transaction_lab/g, '트랜잭션 랩')
    .replace(/performance_lab/g, '퍼포먼스 랩')
    .replace(/security_lab/g, '시큐리티 랩')
    .replace(/nosql_lab/g, '노에스큐엘 랩')
    .replace(/bad_enrollments/g, '나쁜 수강신청')
    .replace(/recorded_amount/g, '신청 시점 기록 금액')
    .replace(/payment_reference/g, '결제 참조값')
    .replace(/payment_status/g, '결제 상태')
    .replace(/paid_at/g, '결제 시각')
    .replace(/refunded_at/g, '환불 시각')
    .replace(/p13-r/g, '확인 요구사항')
    .replace(/p13-d/g, '결정 정책')
    .replace(/p13-t/g, '테스트')
    .replace(/p13-v/g, '검증 단계')
    .replace(/is distinct from/g, '널 안전 비교')
    .replace(/left join/g, '레프트 조인')
    .replace(/sqlstate/g, '오류 코드')
    .replace(/identity/g, '아이덴티티')
    .replace(/constraint/g, '제약조건')
    .replace(/foreign key|\bfk\b/g, '외래키')
    .replace(/primary key|\bpk\b/g, '기본키')
    .replace(/create unique index/g, '부분 고유 인덱스')
    .replace(/unique/g, '고유')
    .replace(/check/g, '검사')
    .replace(/no action/g, '삭제 제한')
    .replace(/cascade/g, '연쇄 삭제')
    .replace(/restrict/g, '삭제 제한')
    .replace(/alter column type/g, '컬럼 타입 변경')
    .replace(/set not null/g, '필수값 변경')
    .replace(/not null/g, '필수값')
    .replace(/diff/g, '변경 차이')
    .replace(/drop/g, '삭제 명령')
    .replace(/truncate/g, '전체 삭제')
    .replace(/update/g, '수정')
    .replace(/delete/g, '삭제')
    .replace(/insert/g, '입력')
    .replace(/select/g, '조회')
    .replace(/erd/g, '이알디')
    .replace(/ddl/g, '디디엘')
    .replace(/sql/g, '에스큐엘')
    .replace(/ai/g, '에이아이')
    .replace(/null/g, '널')
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
    const cacheKey = `__chapter13Steps_${block}`;
    if (slide?.[cacheKey]) return slide[cacheKey];
    const units = splitUnits(slide?.s || '');
    const targets = detachedTargets(slide?.h || '');
    const plan = planFor(slide, block);
    if (!plan) {
      console.warn(`[Chapter13] 단계 계획이 없는 장표: ${block} ${slideIndex + 1} ${slide?.t || ''}`);
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

  window.CH13Navigation = Object.freeze({
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
