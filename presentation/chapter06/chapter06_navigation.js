(() => {
  'use strict';

  const SCRIPT_FIXES = {
    theory: {
      '이번 장을 마치면 할 수 있는 일': `이번 장의 목표는 정규형 이름을 외우는 것이 아닙니다.\n\n첫째, 위험한 중복과 정상적인 반복을 구분하고 삽입·수정·삭제 이상이 왜 생기는지 설명합니다.\n\n둘째, 한 행의 의미와 컬럼의 주인을 기준으로 제일·제이·제삼 정규형을 질문으로 판단합니다.\n\n셋째, 확정된 업무 규칙을 기본키, 외래키, 낫 널, 유니크, 체크 같은 제약조건과 연결합니다.\n\n넷째, 정상 데이터와 허용 경계값은 성공하고 잘못된 데이터는 의도한 규칙으로 실패하는지 실행 결과로 검증합니다.`,
      '문제 발견에서 실행 검증까지 이어집니다': `먼저 같은 현재 사실을 여러 곳에 저장할 때 생기는 중복과 삽입·수정·삭제 이상을 확인합니다.\n\n다음으로 한 행이 무엇을 나타내는지와 어떤 값이 다른 값을 결정하는지 확인합니다.\n\n이 판단을 제일·제이·제삼 정규형에 적용해 각 사실을 적절한 테이블로 분리합니다.\n\n분리한 구조에는 확정된 업무 규칙을 제약조건으로 구현합니다.\n\n마지막으로 정상값, 허용 경계값, 오류값을 실행해 설계와 규칙이 의도대로 동작하는지 검증합니다.`
    },
    practice: {
      '이번 실습을 마치면 할 수 있는 일': `첫째, 정규화 전 구조에서 같은 현재 사실이 반복될 때 삽입·수정·삭제 이상이 왜 생기는지 설명합니다.\n\n둘째, members_nf, books_nf, loans_nf를 만들고 기본키와 외래키가 세 테이블을 어떻게 연결하는지 확인합니다.\n\n셋째, C-01부터 C-08까지 확정된 업무 규칙을 제약조건과 연결합니다.\n\n넷째, 정상 데이터와 허용 경계값, 반드시 실패해야 하는 오류 데이터를 구분해 테스트합니다.\n\n다섯째, 오류 뒤에는 롤백으로 트랜잭션을 복구하고 기준 행 수와 관계가 그대로 유지되는지 다시 검증합니다.`,
      '예상하고 실행한 뒤 증거로 확인합니다': `첫 번째는 위치와 파일 확인입니다. 현재 데이터베이스, 스키마와 자동 커밋 상태를 확인합니다.\n\n두 번째는 구조와 규칙 생성입니다. 정규화된 테이블과 확정된 제약조건을 만듭니다.\n\n세 번째는 기준 데이터 확인입니다. 테스트 전 예상 행 수와 관계를 숫자로 고정합니다.\n\n네 번째는 정상·경계·오류 테스트입니다. 한 테스트씩 실행하고 예상한 규칙이 동작하는지 확인합니다.\n\n다섯 번째는 복구와 최종 검증입니다. 오류 상태를 롤백한 뒤 기준 데이터와 관계가 유지되는지 다시 확인합니다.`
    }
  };

  const AUTO = 'auto';
  const PLANS = {
    theory: {
      '정규화와 데이터 무결성으로 좋은 테이블 만들기': [['lead:*']],
      '이번 장을 마치면 할 수 있는 일': [['item-0'], ['item-1'], ['item-2'], ['item-3']],
      '문제 발견에서 실행 검증까지 이어집니다': [['flow-0'], ['flow-1'], ['flow-2'], ['flow-3'], ['flow-4']],
      '@l:상황 소개': [['body:*', 'quote:*']],
      '@l:반복 확인': [['row-0'], ['row-1'], ['row-2']],
      '@l:이상 현상': [['card-0'], ['card-1'], ['card-2']],
      '@l:수정 이상': AUTO,
      '@l:삽입 이상': AUTO,
      '@l:삭제 이상': AUTO,
      '반복된 값이 모두 문제는 아닙니다': [['item-0'], ['item-1'], ['item-2']],
      '회원 번호로 회원과 대여 기록을 연결합니다': [['card-0'], ['card-1'], ['quote:*']],
      'member_id 반복은 회원과 대여의 관계를 표현합니다': AUTO,
      '회원 이메일 반복은 현재 사실의 복사입니다': AUTO,
      '정상 반복과 위험한 중복을 비교합니다': AUTO,
      '먼저 한 행이 무엇을 나타내는지 정의합니다': AUTO,
      '각 컬럼의 주인을 찾습니다': AUTO,
      '같은 회원 ID에 두 이메일이 저장되면 어느 값이 맞을까요?': AUTO,
      '한 값이 정해지면 다른 값도 하나로 정해집니다': AUTO,
      '제1정규형은 한 셀의 독립 값을 확인합니다': AUTO,
      '제2정규형은 복합키 일부 의존을 찾습니다': [['row:*'], ['card-0'], ['card-1'], ['card-2']],
      '제3정규형은 일반 컬럼 사이의 의존을 찾습니다': [['row:*'], ['flow-0'], ['flow-1'], ['flow-2']],
      '원시 테이블을 회원·도서·대여로 분리합니다': AUTO,
      '정규화가 끝나도 업무 정책은 별도로 결정해야 합니다': [['row-0'], ['row-1'], ['row-2'], ['row-3', 'quote:*']],
      '한 책의 현재 미반납 대여는 한 건만 허용합니다': [['row-0'], ['row-1'], ['row-2', 'quote:*']],
      '정규화해도 잘못된 값은 입력할 수 있습니다': [['row-0'], ['row-1'], ['row-2'], ['row-3'], ['row-4', 'quote:*']],
      '오류마다 막아야 할 규칙이 다릅니다': [['row-0'], ['row-1'], ['row-2'], ['row-3'], ['row-4', 'quote:*']],
      '외래키는 두 테이블의 유효한 연결을 확인합니다': [['card-0'], ['card-1'], ['quote:*']],
      '회원 999가 없으면 INSERT 전체가 취소됩니다': [['card-0'], ['card-1'], ['row-0', 'quote:*']],
      '기본키는 같은 회원 번호의 중복 저장을 막습니다': AUTO,
      '필수값·중복·날짜 오류는 서로 다른 규칙으로 막습니다': AUTO,
      '확정된 규칙은 테이블 정의에 선언합니다': AUTO,
      '같은 책의 미반납 대여는 한 건만 허용합니다': AUTO,
      '대여 이력이 있는 회원은 바로 삭제하지 않습니다': AUTO,
      '실습은 구조·샘플·조회·오류 검증 순서로 진행합니다': AUTO,
      '직접 지정한 ID 다음에는 자동 번호를 다시 맞춥니다': AUTO,
      '정상·경계·오류 데이터가 예상대로 동작해야 합니다': AUTO,
      '정보는 한 번 저장하고 조회할 때 관계로 연결합니다': AUTO,
      '정규화는 테이블 수를 최대한 늘리는 작업이 아닙니다': AUTO,
      'AI가 만든 DDL은 근거와 실행 결과로 검토합니다': [['row-0'], ['row-1'], ['row-2'], ['row-3', 'quote:*']],
      '주문 데이터도 컬럼의 주인부터 찾습니다': AUTO,
      '반복을 발견하면 삭제보다 의미를 먼저 확인합니다': AUTO,
      '실제 상황에서 어떤 규칙이 필요한지 판단해 봅니다': AUTO,
      '좋은 테이블은 구조·규칙·검증을 함께 갖춥니다': AUTO
    },
    practice: {
      '정규화와 무결성 규칙을 실행으로 검증합니다': [['lead:*', 'pill:*']],
      '이번 실습을 마치면 할 수 있는 일': [['item-0'], ['item-1'], ['item-2'], ['item-3'], ['item-4']],
      '예상하고 실행한 뒤 증거로 확인합니다': [['flow-0'], ['flow-1'], ['flow-2'], ['flow-3'], ['flow-4', 'quote:*']],
      '파일 역할과 실행 순서를 먼저 확인합니다': [['row-0'], ['row-1'], ['row-2'], ['row-3'], ['row-4', 'quote:*']],
      '현재 데이터베이스와 스키마를 확인합니다': [['code:*'], ['card-0'], ['card-1'], ['card-2']],
      '한 행에 세 종류의 사실이 섞여 있습니다': [['row-0'], ['card-0'], ['card-1'], ['card-2']],
      '현재 정보와 사건 정보를 각각의 주인에게 저장합니다': [['card-0'], ['card-1'], ['card-2'], ['quote:*']],
      'C-01부터 C-08까지 구현 대상을 확인합니다': [['row-0', 'row-1'], ['row-2'], ['row-3'], ['row-4'], ['row-5']],
      'DDL에서 규칙이 구현된 위치를 찾습니다': [['card-0'], ['card-1'], ['quote:*']],
      '테스트 전 기대 상태를 숫자로 고정합니다': [['row-0', 'row-1', 'row-2', 'row-3'], ['row-4'], ['row-5']],
      '정상 데이터는 저장되어야 합니다': [['code:*', 'card-0'], ['card-1'], ['card-2']],
      '허용하기로 한 경계값도 성공해야 합니다': [['row-0'], ['row-1'], ['row-2'], ['row-3'], ['row-4']],
      '실패해야 하는 SQL은 한 문장씩 실행합니다': [['row-0'], ['row-1'], ['row-2'], ['row-3'], ['row-4'], ['row-5']],
      '현재 미반납 상태의 중복만 차단합니다': [['code:*'], ['card-0'], ['card-1']],
      '트랜잭션 실패 상태에서는 롤백합니다': [['code-0'], ['code-1'], ['code-2', 'code-3', 'code-4', 'code-5']],
      '구조·규칙·검증 증거를 함께 확인합니다': [['card-0'], ['card-1'], ['card-2'], ['row-0', 'row-1', 'row-2']]
    }
  };

  const TARGET_SPECS = [
    ['.lead', 'lead'], ['.body-text', 'body'], ['.card', 'card'], ['.flow-step', 'flow'],
    ['.road-step', 'road'], ['.path-node', 'path'], ['.relation-node', 'relation'],
    ['.bullet-list li', 'item'], ['.checklist li', 'item'], ['table tbody tr', 'row'],
    ['.code-line[data-focusable="true"]', 'code'], ['.quote', 'quote'], ['.expect', 'expect'],
    ['.constraint', 'constraint'], ['.rule', 'rule'], ['.test-case', 'test'],
    ['.success', 'success'], ['.failure', 'failure'], ['.error', 'error'], ['.warning', 'warning'],
    ['.result', 'result'], ['.normal-form', 'normal'], ['.dependency', 'dependency'],
    ['.key-box', 'keybox'], ['.scenario', 'scenario'], ['.example', 'example'],
    ['.pill', 'pill'], ['.chip', 'chip']
  ];

  const STOP_WORDS = new Set([
    '이번', '장표', '단계', '입니다', '있습니다', '합니다', '됩니다', '그리고', '하지만', '따라서',
    '먼저', '다음', '마지막', '확인', '보겠습니다', '보면', '경우', '대한', '위해', '사용', '실습',
    '데이터', '테이블', '값', '규칙'
  ]);

  const normalize = (value) => String(value ?? '')
    .toLowerCase()
    .replace(/postgresql/g, '포스트그레스큐엘')
    .replace(/primary key|\bpk\b/g, '기본키')
    .replace(/foreign key|\bfk\b/g, '외래키')
    .replace(/not null/g, '낫 널')
    .replace(/unique/g, '유니크')
    .replace(/check/g, '체크')
    .replace(/references/g, '참조')
    .replace(/on delete restrict/g, '삭제 제한')
    .replace(/rollback/g, '롤백')
    .replace(/transaction/g, '트랜잭션')
    .replace(/1nf/g, '제일 정규형')
    .replace(/2nf/g, '제이 정규형')
    .replace(/3nf/g, '제삼 정규형')
    .replace(/null/g, '널')
    .replace(/members_nf|members/g, '회원')
    .replace(/books_nf|books/g, '도서')
    .replace(/loans_nf|loans/g, '대여')
    .replace(/member_id/g, '회원 아이디')
    .replace(/book_id/g, '도서 아이디')
    .replace(/loan_id/g, '대여 아이디')
    .replace(/member_email|email/g, '이메일')
    .replace(/book_title|title/g, '제목')
    .replace(/borrowed_at/g, '대여일')
    .replace(/due_at/g, '반납예정일')
    .replace(/returned_at/g, '실제반납일')
    .replace(/isbn/g, '아이에스비엔')
    .replace(/current_database/g, '현재 데이터베이스')
    .replace(/current_schema/g, '현재 스키마')
    .replace(/search_path/g, '검색 경로')
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
        span.dataset.focusable = line.trim() ? 'true' : 'false';
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

  function autoGroups(targets) {
    const by = (prefix) => targets.filter((target) => target.prefix === prefix).map((target) => [target.key]);
    const priorities = ['item', 'flow', 'row', 'card', 'constraint', 'rule', 'test', 'result'];
    for (const prefix of priorities) {
      const groups = by(prefix);
      if (groups.length > 1) return groups;
    }
    const code = by('code');
    if (code.length > 1) return code;
    if (targets.length) return [targets.map((target) => target.key)];
    return [];
  }

  const groupText = (group, targets) => group.map((key) => targets.find((target) => target.key === key)?.text || '').join(' ');

  function semanticScore(unit, group, groupIndex, groupCount, unitIndex, unitCount, targets) {
    const unitTokens = tokensOf(unit);
    const groupTokens = tokensOf(groupText(group, targets));
    let score = 0;
    unitTokens.forEach((token) => {
      if (groupTokens.has(token)) score += token.length >= 5 ? 6 : token.length >= 3 ? 4 : 2;
    });
    const ordinals = [[/첫째|첫 번째|첫번째|①/, 0], [/둘째|두 번째|두번째|②/, 1], [/셋째|세 번째|세번째|③/, 2], [/넷째|네 번째|네번째|④/, 3], [/다섯째|다섯 번째|다섯번째|⑤/, 4], [/여섯째|여섯 번째|여섯번째/, 5]];
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

  function planKey(slide, block) {
    const plans = PLANS[block] || {};
    if (slide?.t && Object.prototype.hasOwnProperty.call(plans, slide.t)) return slide.t;
    const labelKey = `@l:${slide?.l || ''}`;
    if (Object.prototype.hasOwnProperty.call(plans, labelKey)) return labelKey;
    const kindKey = `@k:${slide?.k || ''}`;
    if (Object.prototype.hasOwnProperty.call(plans, kindKey)) return kindKey;
    return '';
  }

  function applyScriptFixes(slides, block) {
    const fixes = SCRIPT_FIXES[block] || {};
    slides.forEach((slide) => {
      if (slide?.t && fixes[slide.t]) slide.s = fixes[slide.t];
    });
  }

  function buildSteps(slide, slideIndex = 0, block = 'theory') {
    const cacheKey = `__chapter06Steps_${block}`;
    if (slide?.[cacheKey]) return slide[cacheKey];
    const units = splitUnits(slide?.s || '');
    const targets = detachedTargets(slide?.h || '');
    const key = planKey(slide, block);
    const plan = key ? PLANS[block][key] : AUTO;
    let groups;
    if (plan === AUTO) groups = autoGroups(targets);
    else groups = plan.map((specs) => expandGroup(specs, targets)).filter((group) => group.length);
    if (!groups.length) groups = autoGroups(targets);
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
    slides.forEach((slide, index) => {
      const key = planKey(slide, block);
      if (!key) issues.push(`missing plan: ${block} ${index + 1} ${slide?.t || slide?.l || slide?.k || ''}`);
      const plan = key ? PLANS[block][key] : AUTO;
      if (plan !== AUTO) {
        const targets = detachedTargets(slide.h || '');
        const targetKeys = new Set(targets.map((target) => target.key));
        plan.flat().forEach((spec) => {
          if (spec.endsWith(':*')) {
            const prefix = spec.slice(0, -2);
            if (!targets.some((target) => target.prefix === prefix)) issues.push(`missing target group: ${block} ${index + 1} ${spec}`);
          } else if (!targetKeys.has(spec)) issues.push(`missing target: ${block} ${index + 1} ${spec}`);
        });
      }
      if (!buildSteps(slide, index, block).length) issues.push(`empty steps: ${block} ${index + 1}`);
    });
    return issues;
  }

  window.CH6Navigation = Object.freeze({
    buildSteps,
    prepareSlides,
    applyFocus,
    prepareCodeLines,
    splitUnits,
    audit,
    planKey,
    plans: PLANS
  });
})();