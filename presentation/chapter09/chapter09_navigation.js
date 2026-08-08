(() => {
  'use strict';

  const AUTO = Symbol('auto');

  const PLANS = {
    theory: {
      'Chapter 09는 여러 변경을 안전하게 확정하는 장입니다': AUTO,
      '트랜잭션은 SQL 묶음이 아니라 업무 경계입니다': [['item:*']],
      '부분 성공은 정합성 문제를 만듭니다': [['row:*']],
      'Chapter 09는 별도 실습 스키마를 사용합니다': AUTO,
      '실행 전 사전 조건 검사가 필요합니다': AUTO,
      'BEGIN, COMMIT, ROLLBACK의 역할': [['row:*']],
      '트랜잭션만으로 정합성이 자동 보장되지는 않습니다': [['row:*']],
      'ACID는 업무 사례로 이해합니다': [['row:*']],
      '초기 상태는 좌석·신청·결제 검증의 기준입니다': [['row:*'], ['code:*']],
      '성공 트랜잭션은 좌석을 먼저 확보합니다': AUTO,
      '조건부 UPDATE의 영향 행 수가 핵심입니다': [['code:*'], ['item:*']],
      'CTE로 좌석 성공 결과에 신청·결제를 연결합니다': [['code:*'], ['item:*']],
      'COMMIT 전 검증이 확정 기준입니다': AUTO,
      'ROLLBACK은 미확정 변경만 되돌립니다': [['row:*']],
      'ROLLBACK과 IDENTITY 번호는 다릅니다': AUTO,
      '좌석 부족은 SQL 오류가 아니라 업무 실패일 수 있습니다': AUTO,
      'SQL 오류 후에는 트랜잭션 상태를 확인합니다': AUTO,
      'Lock 대기와 Deadlock을 구분합니다': AUTO,
      '트랜잭션은 너무 길어도 위험합니다': AUTO,
      'AI 트랜잭션 SQL은 실패 경로까지 검토합니다': [['item:*']]
    },
    practice: {
      '이번 실습은 조회가 아니라 변경을 다룹니다': AUTO,
      '같은 연결 세션에서 실행해야 합니다': [['item:*']],
      '실행 전 사전 조건을 확인합니다': AUTO,
      '스키마 생성도 하나의 트랜잭션입니다': AUTO,
      '초기 데이터는 좌석 검증의 기준입니다': [['row:*'], ['code:*']],
      '성공 COMMIT 실습의 업무 단위를 먼저 말합니다': AUTO,
      '`FOR UPDATE`는 좌석 행을 잠급니다': [['code:*'], ['item:*']],
      '좌석 확보는 UPDATE 1행으로 확인합니다': [['code:*'], ['row:*']],
      '신청과 결제는 좌석 성공 결과에 연결됩니다': AUTO,
      'COMMIT 전 검증 결과를 기록합니다': [['row:*']],
      'ROLLBACK 실습은 실패 상황을 안전하게 확인합니다': AUTO,
      'ROLLBACK 전후 상태를 비교합니다': [['row:*']],
      '두 번째 COMMIT으로 좌석 302를 소진합니다': AUTO,
      '좌석 부족은 ROLLBACK으로 종료합니다': AUTO,
      '최종 검증 파일로 정합성을 확인합니다': AUTO,
      '취소와 좌석 복구도 하나의 트랜잭션입니다': [['code:*'], ['item:*']],
      '오류와 SAVEPOINT 실습은 조심해서 진행합니다': AUTO,
      '두 세션 Lock 실습은 연결을 분리해야 합니다': AUTO,
      '초기화는 `transaction_lab`만 대상으로 합니다': AUTO,
      '최종 완료 기준은 성공·실패·복구를 모두 설명하는 것입니다': [['item:*']]
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
    '먼저', '다음', '마지막', '확인', '경우', '대한', '위해', '사용', '실습', '데이터', '트랜잭션'
  ]);

  const normalize = (value) => String(value ?? '')
    .toLowerCase()
    .replace(/transaction_lab/g, '트랜잭션 랩')
    .replace(/course_project/g, '코스 프로젝트')
    .replace(/course_inventory/g, '좌석')
    .replace(/enrollments/g, '수강신청')
    .replace(/payments/g, '결제')
    .replace(/recorded_amount/g, '기록 금액')
    .replace(/remaining_seats/g, '잔여 좌석')
    .replace(/for update/g, '행 잠금')
    .replace(/rollback to savepoint/g, '세이브포인트 복구')
    .replace(/rollback/g, '롤백')
    .replace(/savepoint/g, '세이브포인트')
    .replace(/commit/g, '커밋')
    .replace(/begin/g, '비긴')
    .replace(/returning/g, '리터닝')
    .replace(/update/g, '업데이트')
    .replace(/insert/g, '인서트')
    .replace(/select/g, '셀렉트')
    .replace(/cte/g, '씨티이')
    .replace(/identity/g, '아이덴티티')
    .replace(/atomicity/g, '아토미시티')
    .replace(/consistency/g, '컨시스턴시')
    .replace(/isolation/g, '아이솔레이션')
    .replace(/durability/g, '듀러빌리티')
    .replace(/acid/g, '에이씨아이디')
    .replace(/deadlock/g, '데드락')
    .replace(/lock/g, '락')
    .replace(/sql/g, '에스큐엘')
    .replace(/ai/g, '에이아이')
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

  function autoGroups(targets) {
    const rich = targets.filter((target) => target.prefix !== 'body');
    const selected = rich.length ? rich : targets;
    return selected.map((target) => [target.key]);
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
    const cacheKey = `__chapter09Steps_${block}`;
    if (slide?.[cacheKey]) return slide[cacheKey];

    const units = splitUnits(slide?.s || '');
    const targets = detachedTargets(slide?.h || '');
    const plan = planFor(slide, block);
    if (!plan) {
      console.warn(`[Chapter09] 단계 계획이 없는 장표: ${block} ${slideIndex + 1} ${slide?.t || ''}`);
      slide[cacheKey] = [{ text: units.join(' '), focusKeys: [] }];
      return slide[cacheKey];
    }

    const groups = plan === AUTO
      ? autoGroups(targets)
      : plan.map((specs) => expandGroup(specs, targets)).filter((group) => group.length);

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
    const active = new Set(step.focusKeys);
    targets.forEach(({ element, key }) => {
      element.classList.toggle('focus-active', active.has(key));
      element.classList.toggle('focus-muted', !active.has(key));
    });
  }

  function planKey(slide, block) {
    return Object.prototype.hasOwnProperty.call(PLANS[block] || {}, slide?.t || '') ? slide.t : null;
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

  window.CH9Navigation = Object.freeze({
    buildSteps,
    prepareSlides,
    applyFocus,
    splitUnits,
    audit,
    planKey,
    plans: PLANS
  });
})();
