(() => {
  'use strict';

  const STOP_WORDS = new Set([
    '이번','장표','에서는','입니다','있습니다','합니다','됩니다','그리고','하지만','따라서','먼저','다음','마지막','정리하면',
    '중요한','내용','확인','단계','실행','결과','화면','현재','사용','경우','필요','위해','대한','것입니다','수','것','때','이','그','한'
  ]);

  const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (character) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[character]);

  const normalizeForMatch = (value) => String(value || '')
    .toLowerCase()
    .replace(/포스트그레스큐엘/g, 'postgresql')
    .replace(/디비버/g, 'dbeaver')
    .replace(/데이터베이스/g, 'database')
    .replace(/디비엠에스/g, 'dbms')
    .replace(/에스큐엘/g, 'sql')
    .replace(/에이아이/g, 'ai')
    .replace(/로컬호스트/g, 'localhost')
    .replace(/커런트 데이터베이스/g, 'current_database')
    .replace(/커런트 스키마/g, 'current_schema')
    .replace(/서치 패스|검색 경로/g, 'search_path')
    .replace(/트랜잭션 리드 온리|읽기 전용/g, 'transaction_read_only')
    .replace(/오토 커밋|자동 커밋/g, 'auto commit')
    .replace(/매뉴얼 커밋/g, 'manual commit')
    .replace(/테스트 커넥션/g, 'test connection')
    .replace(/호스트/g, 'host')
    .replace(/포트/g, 'port')
    .replace(/사용자 이름/g, 'username')
    .replace(/비밀번호/g, 'password')
    .replace(/퍼블릭/g, 'public')
    .replace(/스키마/g, 'schema')
    .replace(/테이블/g, 'table')
    .replace(/서버/g, 'server')
    .replace(/클라이언트/g, 'client')
    .replace(/셀렉트/g, 'select')
    .replace(/쇼/g, 'show')
    .replace(/크리에이트 데이터베이스/g, 'create database')
    .replace(/셋업 체크/g, 'setup_check')
    .replace(/셋업 밸리데이트 로컬/g, 'setup_validate_local')
    .replace(/오천사백삼십이/g, '5432')
    .replace(/영 행/g, '0행')
    .replace(/한 행/g, '1행')
    .replace(/[^0-9a-z가-힣_]+/g, ' ')
    .trim();

  const tokensOf = (value) => new Set(normalizeForMatch(value).split(/\s+/).filter((token) => {
    if (!token || STOP_WORDS.has(token)) return false;
    return token.length >= 2 || /^\d+$/.test(token);
  }));

  const textOf = (element) => (element?.innerText || element?.textContent || '').replace(/\s+/g, ' ').trim();

  const splitSentences = (value) => {
    const raw = String(value || '').replace(/\s+/g, ' ').trim();
    if (!raw) return [];
    return (raw.match(/[^.!?。]+(?:[.!?。]+|$)/g) || [raw]).map((part) => part.trim()).filter(Boolean);
  };

  const splitParagraphs = (value) => {
    const raw = String(value || '').trim();
    if (!raw) return ['핵심 내용을 설명합니다.'];
    const paragraphs = raw.split(/\n\s*\n/).map((part) => part.replace(/\s+/g, ' ').trim()).filter(Boolean);
    const output = [];
    paragraphs.forEach((paragraph) => {
      const sentences = splitSentences(paragraph);
      if (paragraph.length > 170 && sentences.length >= 3) sentences.forEach((sentence) => output.push(sentence));
      else output.push(paragraph);
    });
    return output.length ? output : [raw.replace(/\s+/g, ' ').trim()];
  };

  const prepareCodeLines = (root) => {
    root.querySelectorAll('pre').forEach((pre) => {
      if (pre.dataset.focusPrepared === 'true') return;
      const code = pre.querySelector('code') || pre;
      const lines = code.textContent.replace(/\r/g, '').split('\n');
      code.innerHTML = lines.map((line) => `<span class="code-line">${escapeHtml(line || ' ')}</span>`).join('');
      pre.dataset.focusPrepared = 'true';
    });
    root.querySelectorAll('.prompt-box').forEach((box) => {
      if (box.dataset.focusPrepared === 'true') return;
      const lines = box.innerHTML.split(/<br\s*\/?>|\n/gi).map((line) => line.trim()).filter(Boolean);
      if (lines.length > 1) box.innerHTML = lines.map((line) => `<span class="prompt-line">${line}</span>`).join('');
      box.dataset.focusPrepared = 'true';
    });
  };

  const TARGET_SPECS = [
    ['.lead', 'lead'], ['.title-meta .pill', 'pill'], ['.card', 'card'], ['.flow-step', 'flow'],
    ['.bullet-list li', 'item'], ['table tbody tr', 'row'], ['.quote', 'quote'],
    ['.step-box > h3', 'step-title'], ['.step-box > p', 'step-text'], ['.hierarchy > div', 'hierarchy'],
    ['pre .code-line', 'code'], ['.prompt-box .prompt-line', 'prompt'], ['.body-text', 'body'],
    ['.scenario > *', 'scenario'], ['.relation-line > *', 'relation'], ['.object-row > span', 'object'],
    ['.review-grid > span', 'review'], ['.type-card', 'type'], ['.key-card', 'key'], ['.role-card', 'role'],
    ['.id-card', 'id'], ['.legend', 'legend'], ['.activity', 'activity'], ['.activity-box', 'activity-box'],
    ['.codebox', 'codebox'], ['.band', 'band'], ['.warning', 'warning'], ['.answer-band', 'answer'],
    ['.return-line', 'return'], ['.small-note', 'note'], ['.next-band', 'next']
  ];

  const collectTargets = (root) => {
    prepareCodeLines(root);
    const targets = [];
    const seen = new Set();
    TARGET_SPECS.forEach(([selector, prefix]) => {
      [...root.querySelectorAll(selector)].forEach((element) => {
        if (seen.has(element)) return;
        const text = textOf(element);
        if (!text && (prefix === 'code' || prefix === 'prompt')) return;
        seen.add(element);
        const index = targets.filter((target) => target.prefix === prefix).length;
        const key = `${prefix}-${index}`;
        element.dataset.focusKey = key;
        element.classList.add('focus-target');
        targets.push({ key, element, prefix, index, text, tokens: tokensOf(text) });
      });
    });
    if (!targets.length) {
      [...root.children].filter((element) => !['H1','H2'].includes(element.tagName)).forEach((element, index) => {
        const key = `section-${index}`;
        element.dataset.focusKey = key;
        element.classList.add('focus-target');
        const text = textOf(element);
        targets.push({ key, element, prefix: 'section', index, text, tokens: tokensOf(text) });
      });
    }
    return targets;
  };

  const scoreTarget = (paragraph, paragraphTokens, target) => {
    let score = 0;
    paragraphTokens.forEach((token) => {
      if (target.tokens.has(token)) score += token.length >= 5 ? 4 : token.length >= 3 ? 3 : 2;
    });
    const normalized = normalizeForMatch(paragraph);
    const targetText = normalizeForMatch(target.text);
    if (targetText && normalized.includes(targetText)) score += 8;
    if (target.prefix === 'code' && /select|show|create database|setup_|current_|search_path|transaction_read_only|timezone|version|pg_database/.test(normalized)) score += 2;
    if (target.prefix === 'row' && /기준|항목|오류|증상|host|port|database|username|password|버전|운영체제|완료/.test(normalized)) score += 1;
    return score;
  };

  const ordinalFocus = (paragraph, targets) => {
    const ordinals = [
      ['첫째',0],['첫 번째',0],['첫번째',0],['둘째',1],['두 번째',1],['두번째',1],
      ['셋째',2],['세 번째',2],['세번째',2],['넷째',3],['네 번째',3],['네번째',3],
      ['다섯째',4],['다섯 번째',4],['다섯번째',4],['여섯째',5],['여섯 번째',5],['여섯번째',5]
    ];
    const found = ordinals.find(([word]) => paragraph.includes(word));
    if (!found) return [];
    const targetIndex = found[1];
    for (const prefix of ['card','item','row','flow','hierarchy','review','prompt','code']) {
      const match = targets.find((target) => target.prefix === prefix && target.index === targetIndex);
      if (match) return [match.key];
    }
    return [];
  };

  const resolveFocus = (paragraph, targets) => {
    const ordinal = ordinalFocus(paragraph, targets);
    if (ordinal.length) return ordinal;
    const paragraphTokens = tokensOf(paragraph);
    const scored = targets.map((target) => ({ target, score: scoreTarget(paragraph, paragraphTokens, target) }))
      .sort((left, right) => right.score - left.score);
    const best = scored[0]?.score || 0;
    if (best < 3) return [];
    const threshold = Math.max(3, Math.ceil(best * 0.7));
    return scored.filter((entry) => entry.score >= threshold).slice(0, 4).map((entry) => entry.target.key);
  };

  const sameFocus = (left, right) => left.length === right.length && left.every((key, index) => key === right[index]);

  const buildAutomaticSteps = (paragraphs, targets) => {
    const resolved = paragraphs.map((text) => ({ text, focusKeys: resolveFocus(text, targets) }));
    const steps = [];
    let pending = [];
    resolved.forEach((item) => {
      if (!item.focusKeys.length) {
        pending.push(item.text);
        return;
      }
      const text = pending.concat(item.text).join('\n\n');
      pending = [];
      if (steps.length && sameFocus(steps[steps.length - 1].focusKeys, item.focusKeys)) {
        steps[steps.length - 1].text += `\n\n${text}`;
      } else {
        steps.push({ text, focusKeys: item.focusKeys });
      }
    });
    if (pending.length) {
      if (steps.length) steps[steps.length - 1].text += `\n\n${pending.join('\n\n')}`;
      else steps.push({ text: pending.join('\n\n'), focusKeys: [] });
    }
    return steps;
  };

  const orderedTargets = (targets, prefixes) => prefixes.flatMap((prefix) => targets.filter((target) => target.prefix === prefix).map((target) => target.key));

  const keysFromSpec = (spec, targets) => {
    const [prefix, rawIndex = '*'] = String(spec || '').split(':');
    if (!prefix) return [];
    if (rawIndex === '*' || rawIndex === '') return targets.filter((target) => target.prefix === prefix).map((target) => target.key);
    const index = Number(rawIndex);
    if (!Number.isFinite(index)) return [];
    const match = targets.find((target) => target.prefix === prefix && target.index === index);
    return match ? [match.key] : [];
  };

  const planGroups = (plan, targets) => {
    if (!plan) return [];
    if (Array.isArray(plan.sequence)) {
      return plan.sequence.flatMap((prefix) => targets.filter((target) => target.prefix === prefix).map((target) => [target.key]));
    }
    if (Array.isArray(plan.groups)) {
      return plan.groups.map((group) => [...new Set((group || []).flatMap((spec) => keysFromSpec(spec, targets)))]).filter((group) => group.length);
    }
    return [];
  };

  const balancedChunks = (items, count) => {
    if (!count) return [];
    return Array.from({ length: count }, (_, index) => {
      const start = Math.floor(index * items.length / count);
      const end = Math.floor((index + 1) * items.length / count);
      return items.slice(start, end);
    });
  };

  const compressSentences = (sentences) => {
    const cleaned = sentences.map((sentence) => sentence.trim()).filter(Boolean);
    if (cleaned.length <= 4) return cleaned;
    const merged = cleaned.slice(3).map((sentence) => sentence.replace(/[.!?。]+$/g, '').trim()).filter(Boolean).join(' 그리고 ');
    return cleaned.slice(0, 3).concat(merged ? `${merged}.` : []);
  };

  const labelForKeys = (focusKeys, targets) => {
    const labels = focusKeys.map((key) => targets.find((target) => target.key === key)?.text || '').filter(Boolean);
    const joined = labels.join(' · ').replace(/\s+/g, ' ').trim();
    return joined.length > 72 ? `${joined.slice(0, 69)}...` : joined;
  };

  const ensureNarration = (sentences, focusKeys, targets) => {
    let output = compressSentences(sentences);
    const label = labelForKeys(focusKeys, targets);
    if (!output.length) {
      output = [
        label ? `${label} 항목을 중심으로 현재 단계의 의미를 확인합니다.` : '현재 단계의 핵심 의미를 화면과 함께 확인합니다.',
        '이 단계가 앞뒤 과정에서 어떤 역할을 하는지 연결해서 이해하면 다음 작업을 더 정확하게 진행할 수 있습니다.'
      ];
    } else if (output.length === 1) {
      output.push(label
        ? `${label} 항목이 다른 설정이나 결과와 어떻게 연결되는지도 함께 확인합니다.`
        : '이 내용을 앞뒤 단계와 연결해서 이해하면 실행 결과를 더 정확하게 판단할 수 있습니다.');
    }
    return output.join(' ');
  };

  const buildPlannedSteps = (slide, targets) => {
    const plan = slide?.__chapter03SemanticPlan;
    const groups = planGroups(plan, targets);
    if (!groups.length) return null;
    const sentences = splitSentences(slide.s);
    const chunks = balancedChunks(sentences, groups.length);
    return groups.map((focusKeys, index) => ({
      text: ensureNarration(chunks[index] || [], focusKeys, targets),
      focusKeys
    }));
  };

  const buildGuidedSteps = (slide, paragraphs, targets) => {
    const key = String(slide.k || '');
    const sequentialKeys = {
      'VERSION BASELINE': orderedTargets(targets, ['row']),
      'ROLE REVIEW': orderedTargets(targets, ['row']),
      'CONNECTION VALUES': orderedTargets(targets, ['row']),
      'ERROR TYPES': orderedTargets(targets, ['row']),
      'DONE CRITERIA': orderedTargets(targets, ['row']),
      'CHECK BEFORE': orderedTargets(targets, ['row']),
      'CONNECTION INPUT': orderedTargets(targets, ['row']),
      'CREATE ERRORS': orderedTargets(targets, ['row']),
      'CHECK RESULT': orderedTargets(targets, ['row']),
      'FINAL CHECKLIST': orderedTargets(targets, ['row']),
      'SECRET CHECK': orderedTargets(targets, ['item']),
      'VALIDATION FILE': orderedTargets(targets, ['item']),
      'ERROR DB DOES NOT EXIST': orderedTargets(targets, ['item']),
      'NAVIGATOR PATH': orderedTargets(targets, ['hierarchy']),
      'CHECK CURRENT': orderedTargets(targets, ['code']),
      'SCHEMA PATH': orderedTargets(targets, ['code','body']),
      'READ ONLY TIMEZONE': orderedTargets(targets, ['code','quote']),
      'ERROR TABLES INVISIBLE': orderedTargets(targets, ['code','body'])
    }[key];
    if (!sequentialKeys?.length) return null;

    const meaningful = paragraphs.filter(Boolean);
    const steps = [];
    sequentialKeys.forEach((focusKey, index) => {
      const textIndex = Math.min(index, meaningful.length - 1);
      const text = meaningful[textIndex] || meaningful[0] || '핵심 내용을 확인합니다.';
      steps.push({ text, focusKeys: [focusKey] });
    });
    if (meaningful.length > sequentialKeys.length && steps.length) {
      steps[steps.length - 1].text += `\n\n${meaningful.slice(sequentialKeys.length).join('\n\n')}`;
    }
    return steps;
  };

  const prepareSlide = (slide) => {
    if (!slide || typeof slide !== 'object') return;
    const root = document.createElement('div');
    root.innerHTML = slide.h || '';
    const targets = collectTargets(root);
    const paragraphs = splitParagraphs(slide.s);
    const planned = buildPlannedSteps(slide, targets);
    const guided = planned ? null : buildGuidedSteps(slide, paragraphs, targets);
    const steps = planned || guided || buildAutomaticSteps(paragraphs, targets);
    const finalSteps = steps.length ? steps : [{ text: ensureNarration(splitSentences(slide.s), [], targets), focusKeys: [] }];

    finalSteps.forEach((step, index) => {
      step.focusKeys.forEach((focusKey) => {
        const element = root.querySelector(`[data-focus-key="${focusKey}"]`);
        if (!element) return;
        const current = element.dataset.focusStep ? element.dataset.focusStep.split(',').filter(Boolean) : [];
        current.push(String(index + 1));
        element.dataset.focusStep = [...new Set(current)].join(',');
      });
    });

    root.querySelectorAll('[data-focus-key]').forEach((element) => element.removeAttribute('data-focus-key'));
    slide.h = root.innerHTML;
    slide.steps = finalSteps.length;
    slide.__chapter03Steps = finalSteps;
  };

  const prepareSlides = (slides, block = 'theory') => {
    window.CH3SemanticPlan?.apply?.(slides, block);
    (slides || []).forEach(prepareSlide);
    window.CH3_NAV_BLOCK = block;
    return slides || [];
  };

  const buildSteps = (slide) => slide?.__chapter03Steps || [{ text: String(slide?.s || '핵심 내용을 설명합니다.'), focusKeys: [] }];

  const style = document.createElement('style');
  style.textContent = `
.code-line,.prompt-line{display:block;min-height:1.45em;padding:1px 7px;border-radius:8px}
.code-line.focus-active,.prompt-line.focus-active{background:rgba(79,140,255,.28);box-shadow:none!important;transform:none!important}
.code-line.focus-muted,.prompt-line.focus-muted{opacity:.28;transform:none!important}
tbody tr.focus-active td{background:#e8f0ff}tbody tr.focus-muted{opacity:.25;transform:none!important}
.bullet-list li.focus-active,.hierarchy>div.focus-active{background:rgba(232,240,255,.82);border-radius:12px}
`;
  document.head.appendChild(style);

  window.CH3Navigation = Object.freeze({ prepareSlides, buildSteps, splitParagraphs, splitSentences });
  if (Array.isArray(window.CH3_SLIDES)) prepareSlides(window.CH3_SLIDES, document.body?.dataset?.chapter03Block || 'theory');
})();
