(() => {
  'use strict';

  const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (char) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  })[char]);

  const STOP_WORDS = new Set([
    '이번', '장표', '단계', '에서는', '입니다', '있습니다', '합니다', '됩니다', '그리고', '하지만',
    '따라서', '먼저', '다음', '마지막', '정리하면', '중요한', '내용', '확인', '실행', '결과',
    '사용', '사용합니다', '보겠습니다', '봅니다', '수', '것', '때', '이', '그', '한', '두', '세',
    '네', '다섯', '첫째', '둘째', '셋째', '넷째', '다섯째'
  ]);

  const TARGET_SPECS = [
    ['.card', 'card'],
    ['.flow-step', 'flow'],
    ['.bullet-list li', 'item'],
    ['table tbody tr', 'row'],
    ['.expect', 'expect'],
    ['.quote', 'quote'],
    ['.prompt-box', 'prompt'],
    ['.codebox', 'codebox'],
    ['.body-text', 'body'],
    ['.pill', 'pill'],
    ['.chip', 'chip'],
    ['.code-line', 'code']
  ];

  const splitSentences = (value) => {
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

  const normalizeForMatch = (value) => String(value || '')
    .toLowerCase()
    .replace(/에이아이/g, 'ai')
    .replace(/에스큐엘/g, 'sql')
    .replace(/포스트그레스큐엘/g, 'postgresql')
    .replace(/디비버/g, 'dbeaver')
    .replace(/크러드/g, 'crud')
    .replace(/크리에이트 테이블/g, 'create table')
    .replace(/크리에이트 데이터베이스/g, 'create database')
    .replace(/인서트/g, 'insert')
    .replace(/셀렉트/g, 'select')
    .replace(/업데이트/g, 'update')
    .replace(/딜리트/g, 'delete')
    .replace(/웨어/g, 'where')
    .replace(/오더 바이/g, 'order by')
    .replace(/널스 라스트/g, 'nulls last')
    .replace(/널/g, 'null')
    .replace(/리터닝/g, 'returning')
    .replace(/아이덴티티/g, 'identity')
    .replace(/아이디/g, 'id')
    .replace(/퍼블릭/g, 'public')
    .replace(/스튜던츠/g, 'students')
    .replace(/커런트 데이터베이스/g, 'current database')
    .replace(/커런트 스키마/g, 'current schema')
    .replace(/쇼 서치 패스/g, 'search path')
    .replace(/서치 패스/g, 'search path')
    .replace(/라이크/g, 'like')
    .replace(/아이라이크/g, 'ilike')
    .replace(/리밋/g, 'limit')
    .replace(/애즈/g, 'as')
    .replace(/메이저/g, 'major')
    .replace(/그레이드/g, 'grade')
    .replace(/크리에이티드 앳/g, 'created at')
    .replace(/타임스탬프 위드 타임존/g, 'timestamptz')
    .replace(/티아이엠이에스티에이엠피티제트/g, 'timestamptz')
    .replace(/디폴트 커런트 타임스탬프/g, 'default current timestamp')
    .replace(/낫 널/g, 'not null')
    .replace(/유니크/g, 'unique')
    .replace(/프라이머리 키/g, 'primary key')
    .replace(/카운트 별표/g, 'count')
    .replace(/이즈 낫 널/g, 'is not null')
    .replace(/이즈 널/g, 'is null')
    .replace(/앤드/g, 'and')
    .replace(/오알/g, 'or')
    .replace(/\b인\b/g, 'in')
    .replace(/오름차순/g, 'asc')
    .replace(/내림차순/g, 'desc')
    .replace(/영 행/g, '0 row')
    .replace(/한 행/g, '1 row')
    .replace(/일 행/g, '1 row')
    .replace(/네 행/g, '4 row')
    .replace(/여섯 명/g, '6')
    .replace(/다섯 명/g, '5')
    .replace(/삼 학년/g, '3')
    .replace(/사 학년/g, '4')
    .replace(/[_·/()=<>,'";:+-]+/g, ' ')
    .replace(/[^0-9a-z가-힣%]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

  const tokensOf = (value) => new Set(normalizeForMatch(value).split(/\s+/).filter((token) => {
    if (!token || STOP_WORDS.has(token)) return false;
    if (/^[a-z]$/.test(token)) return true;
    return token.length >= 2 || /^\d+$/.test(token);
  }));

  const textOf = (element) => (element?.innerText || element?.textContent || '').replace(/\s+/g, ' ').trim();

  const prepareCodeLines = (root) => {
    root.querySelectorAll('pre').forEach((pre) => {
      if (pre.closest('.card') || pre.dataset.focusPrepared === 'true') return;
      const lines = pre.textContent.replace(/\r/g, '').split('\n');
      pre.innerHTML = lines.map((line) => `<span class="code-line">${escapeHtml(line || ' ')}</span>`).join('');
      pre.dataset.focusPrepared = 'true';
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

  const keys = (targets, prefix) => targets.filter((target) => target.prefix === prefix).map((target) => target.key);

  const scoreTarget = (sentenceTokens, target, sentence) => {
    let score = 0;
    sentenceTokens.forEach((token) => {
      if (target.tokens.has(token)) score += token.length >= 5 ? 4 : token.length >= 3 ? 3 : 2;
    });

    const normalized = normalizeForMatch(sentence);
    if (target.prefix === 'expect' && /(예상|완료 기준|완료|영향.*row|반환.*row|확인)/.test(sentence)) score += 4;
    if (target.prefix === 'code' && /\b(select|insert|update|delete|where|order|returning|null|limit|like|ilike|current|show|create)\b/.test(normalized)) score += 2;
    if (target.prefix === 'row' && /(체크포인트|학생 수|학년|존재|삭제|column|type|rule|crud)/i.test(normalized)) score += 2;
    if (target.prefix === 'flow' && /(먼저|다음|그다음|마지막|흐름|순서|재확인)/.test(sentence)) score += 1;
    if (target.prefix === 'item' && /(검토|확인|기준|조건|없음|위험|안전)/.test(sentence)) score += 1;
    return score;
  };

  const ordinalTarget = (sentence, targets) => {
    const ordinals = [
      ['첫째', 0], ['첫 번째', 0], ['첫번째', 0], ['둘째', 1], ['두 번째', 1], ['두번째', 1],
      ['셋째', 2], ['세 번째', 2], ['세번째', 2], ['넷째', 3], ['네 번째', 3], ['네번째', 3],
      ['다섯째', 4], ['다섯 번째', 4], ['다섯번째', 4]
    ];
    const pair = ordinals.find(([word]) => sentence.includes(word));
    if (!pair) return [];
    for (const prefix of ['card', 'item', 'row', 'flow']) {
      const match = targets.find((target) => target.prefix === prefix && target.index === pair[1]);
      if (match) return [match.key];
    }
    return [];
  };

  const resolveFocus = (sentence, targets) => {
    const ordinal = ordinalTarget(sentence, targets);
    if (ordinal.length) return ordinal;

    const sentenceTokens = tokensOf(sentence);
    const scored = targets.map((target) => ({ target, score: scoreTarget(sentenceTokens, target, sentence) }))
      .sort((left, right) => right.score - left.score);
    const best = scored[0]?.score || 0;
    if (best < 3) return [];
    const threshold = Math.max(3, Math.ceil(best * 0.72));
    return scored.filter((entry) => entry.score >= threshold).slice(0, 4).map((entry) => entry.target.key);
  };

  const sameFocus = (left, right) => left.length === right.length && left.every((key, index) => key === right[index]);

  const mergeResolved = (resolved) => {
    const steps = [];
    let pending = [];
    resolved.forEach((item) => {
      if (!item.focusKeys.length) {
        pending.push(item.text);
        return;
      }
      const text = pending.concat(item.text).join(' ');
      pending = [];
      if (steps.length && sameFocus(steps[steps.length - 1].focusKeys, item.focusKeys)) {
        steps[steps.length - 1].text += ` ${text}`;
      } else {
        steps.push({ text, focusKeys: item.focusKeys });
      }
    });
    if (pending.length) {
      if (steps.length) steps[steps.length - 1].text += ` ${pending.join(' ')}`;
      else steps.push({ text: pending.join(' '), focusKeys: [] });
    }
    return steps;
  };

  const manualPlan = (slide, sentences, targets) => {
    const key = String(slide?.k || '');
    const cardKeys = keys(targets, 'card');
    const flowKeys = keys(targets, 'flow');
    const itemKeys = keys(targets, 'item');
    const quoteKeys = keys(targets, 'quote');

    if (key === 'CHAPTER GOALS' && itemKeys.length >= 5) {
      return [
        { text: sentences.slice(0, 2).join(' '), focusKeys: itemKeys.slice(0, 2) },
        { text: sentences[2] || '', focusKeys: [itemKeys[2]] },
        { text: sentences.slice(3).join(' '), focusKeys: itemKeys.slice(3, 5) }
      ].filter((step) => step.text);
    }

    if (key === 'CHAPTER FLOW' && flowKeys.length >= 5) {
      return [
        { text: sentences[0] || '', focusKeys: [flowKeys[0]] },
        { text: sentences[1] || '', focusKeys: flowKeys.slice(1, 3) },
        { text: sentences.slice(2).join(' '), focusKeys: flowKeys.slice(3, 5) }
      ].filter((step) => step.text);
    }

    if (key === 'LEARNING LOOP' && flowKeys.length >= 4) {
      return [
        { text: sentences.slice(0, 2).join(' '), focusKeys: [flowKeys[0]] },
        { text: sentences[2] || '', focusKeys: [flowKeys[1]] },
        { text: sentences[3] || '', focusKeys: [flowKeys[2]] },
        { text: sentences.slice(4).join(' '), focusKeys: [flowKeys[3], ...quoteKeys] }
      ].filter((step) => step.text);
    }

    if ((key === 'UPDATE SAFETY' || key === 'DELETE SAFETY') && flowKeys.length >= 4) {
      const parts = sentences.filter(Boolean);
      return [
        { text: parts.slice(0, 2).join(' '), focusKeys: [flowKeys[0]] },
        { text: parts[2] || '', focusKeys: [flowKeys[1]] },
        { text: parts[3] || '', focusKeys: [flowKeys[2]] },
        { text: parts.slice(4).join(' '), focusKeys: [flowKeys[3]] }
      ].filter((step) => step.text);
    }

    if (key === 'PRACTICE RULE' && cardKeys.length >= 2) {
      return [
        { text: sentences.slice(0, 2).join(' '), focusKeys: [cardKeys[0]] },
        { text: sentences.slice(2).join(' '), focusKeys: [cardKeys[1]] }
      ].filter((step) => step.text);
    }

    if (key === 'STEP 30' && cardKeys.length >= 2) {
      return [
        { text: sentences.slice(0, 2).join(' '), focusKeys: [cardKeys[0]] },
        { text: sentences.slice(2).join(' '), focusKeys: [cardKeys[1]] }
      ].filter((step) => step.text);
    }

    return null;
  };

  const buildAutomaticSteps = (sentences, targets) => {
    const resolved = sentences.map((text) => ({ text, focusKeys: resolveFocus(text, targets) }));
    return mergeResolved(resolved);
  };

  const buildSteps = (slide) => {
    if (!slide) return [{ text: '핵심 내용을 설명합니다.', focusKeys: [] }];
    if (slide.__chapter04Steps) return slide.__chapter04Steps;

    const sentences = splitSentences(slide.s);
    const targets = detachedTargets(slide.h);
    const planned = manualPlan(slide, sentences, targets);
    let steps = planned || buildAutomaticSteps(sentences, targets);

    if (!steps.length) steps = [{ text: sentences.join(' '), focusKeys: [] }];
    if (steps.length > 8) {
      const compact = [];
      steps.forEach((step) => {
        if (compact.length && sameFocus(compact[compact.length - 1].focusKeys, step.focusKeys)) {
          compact[compact.length - 1].text += ` ${step.text}`;
        } else compact.push(step);
      });
      steps = compact;
    }

    slide.__chapter04Steps = steps;
    return steps;
  };

  const prepareDOM = (root) => collectTargets(root);

  const applyFocus = (root, slide, stepIndex) => {
    const targets = prepareDOM(root);
    targets.forEach(({ element }) => element.classList.remove('focus-muted', 'focus-active'));
    if (stepIndex <= 0) return;
    const step = buildSteps(slide)[stepIndex - 1];
    if (!step || !step.focusKeys.length) return;
    const selected = new Set(step.focusKeys);
    targets.forEach(({ key, element }) => element.classList.add(selected.has(key) ? 'focus-active' : 'focus-muted'));
  };

  const clearCache = (slides) => (slides || []).forEach((slide) => { if (slide) delete slide.__chapter04Steps; });

  window.CH4Navigation = Object.freeze({
    buildSteps,
    prepareDOM,
    applyFocus,
    splitSentences,
    clearCache
  });
})();
