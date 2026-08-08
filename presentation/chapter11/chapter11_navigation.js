(() => {
  'use strict';

  const AUTO = 'AUTO';

  const PLANS = {
    theory: {
      'Chapter 11은 빠른 DB보다 안전한 DB를 다룹니다': AUTO,
      '보안은 여러 통제가 함께 작동해야 합니다': AUTO,
      'Chapter 11은 별도 `security_lab`에서 진행합니다': [['code:*'], ['item:*']],
      '먼저 보호할 자산과 위험을 정합니다': AUTO,
      '인증·권한·소유권을 구분합니다': AUTO,
      'LOGIN 역할과 NOLOGIN 권한 역할을 분리합니다': AUTO,
      '권한은 객체 범위별로 다릅니다': AUTO,
      '최소 권한은 작업 행렬로 설계합니다': AUTO,
      'GRANT·REVOKE 후에는 유효 권한과 경로를 모두 봅니다': AUTO,
      '현재 객체 권한과 미래 객체 권한은 다릅니다': AUTO,
      '권한은 실제 허용·차단 동작으로 검증합니다': AUTO,
      'PUBLIC과 소유권은 과소평가하면 안 됩니다': AUTO,
      '비밀 정보는 저장소와 로그에 남기지 않습니다': AUTO,
      'SQL Injection은 값과 SQL 구조를 분리해 막습니다': AUTO,
      '백업·복제·고가용성은 같은 말이 아닙니다': AUTO,
      '백업 전에는 버전·계정·의존성을 확인합니다': AUTO,
      '백업 파일은 생성 후 바로 검증합니다': AUTO,
      '복원은 원본이 아니라 별도 DB에서 검증합니다': AUTO,
      'RPO·RTO는 백업 전략의 목표입니다': AUTO,
      '핵심 정리: 보안은 허용·차단·복원으로 증명합니다': AUTO
    },
    practice: {
      '이번 실습은 허용·차단·복원을 확인합니다': AUTO,
      '실행 위치와 보호 범위를 먼저 확인합니다': [['code:*'], ['body:*']],
      '`security_lab` 스키마와 기본 데이터를 만듭니다': AUTO,
      '구조와 무결성 규칙을 확인합니다': [['item:*'], ['code:*']],
      '역할 생성·권한 부여는 선택 실행합니다': AUTO,
      '최소 권한 작업 행렬을 기준으로 GRANT합니다': AUTO,
      '유효 권한과 권한 경로를 확인합니다': AUTO,
      'PUBLIC 권한과 멤버십을 분리해서 봅니다': AUTO,
      '허용·차단 동작 테스트를 실행합니다': AUTO,
      '오류 후에는 트랜잭션을 복구합니다': AUTO,
      '현재 객체 권한과 미래 객체 권한을 기록합니다': AUTO,
      '비밀 정보와 저장소 보호를 점검합니다': AUTO,
      'SQL Injection 방어 기준을 정리합니다': AUTO,
      '백업 전 도구·서버·계정을 확인합니다': AUTO,
      '백업 파일을 만들고 파일 자체를 검증합니다': AUTO,
      '별도 DB에 원자적으로 복원합니다': AUTO,
      '복원 검증 1단계: 구조·데이터·소유권': AUTO,
      '복원 검증 2단계: 권한 재적용과 동작 확인': AUTO,
      'RPO·RTO와 Runbook을 기록합니다': AUTO,
      '최종 완료 기준은 허용·차단·복원 검증입니다': AUTO
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
    '먼저', '다음', '마지막', '확인', '경우', '대한', '위해', '사용', '실습', '데이터', '권한',
    '보안', '백업', '복원'
  ]);

  const normalize = (value) => String(value ?? '')
    .toLowerCase()
    .replace(/security_lab/g, '시큐리티 랩')
    .replace(/course_project/g, '코스 프로젝트')
    .replace(/transaction_lab/g, '트랜잭션 랩')
    .replace(/performance_lab/g, '퍼포먼스 랩')
    .replace(/ai_database_book_restore/g, '복원 검증 데이터베이스')
    .replace(/ai_database_book/g, '원본 데이터베이스')
    .replace(/alter default privileges/g, '미래 객체 기본 권한')
    .replace(/grant/g, '권한 부여')
    .replace(/revoke/g, '권한 회수')
    .replace(/nologin/g, '비로그인 역할')
    .replace(/login/g, '로그인 역할')
    .replace(/public/g, '퍼블릭')
    .replace(/acl/g, '권한 목록')
    .replace(/connect/g, '접속')
    .replace(/usage/g, '사용 권한')
    .replace(/truncate/g, '전체 삭제')
    .replace(/pg_dump/g, '백업 생성')
    .replace(/pg_restore/g, '백업 복원')
    .replace(/psql/g, '피에스큐엘')
    .replace(/sql injection/g, '에스큐엘 인젝션')
    .replace(/rpo/g, '복구 시점 목표')
    .replace(/rto/g, '복구 시간 목표')
    .replace(/runbook/g, '운영 절차서')
    .replace(/role/g, '역할')
    .replace(/owner/g, '소유자')
    .replace(/membership/g, '멤버십')
    .replace(/identity/g, '아이덴티티')
    .replace(/rollback to savepoint/g, '세이브포인트 복구')
    .replace(/rollback/g, '롤백')
    .replace(/savepoint/g, '세이브포인트')
    .replace(/select/g, '조회')
    .replace(/insert/g, '입력')
    .replace(/update/g, '수정')
    .replace(/delete/g, '삭제')
    .replace(/create/g, '생성')
    .replace(/unique/g, '고유')
    .replace(/foreign key|\bfk\b/g, '외래키')
    .replace(/primary key|\bpk\b/g, '기본키')
    .replace(/not null/g, '필수값')
    .replace(/check/g, '검사')
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
    const cacheKey = `__chapter11Steps_${block}`;
    if (slide?.[cacheKey]) return slide[cacheKey];
    const units = splitUnits(slide?.s || '');
    const targets = detachedTargets(slide?.h || '');
    const plan = planFor(slide, block);
    if (!plan) {
      console.warn(`[Chapter11] 단계 계획이 없는 장표: ${block} ${slideIndex + 1} ${slide?.t || ''}`);
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

  window.CH11Navigation = Object.freeze({
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
