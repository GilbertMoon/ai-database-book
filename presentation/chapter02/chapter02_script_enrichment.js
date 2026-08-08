(() => {
  'use strict';

  const STOP_WORDS = new Set([
    '그리고','그러나','따라서','이것은','이렇게','합니다','됩니다','있습니다','없습니다','입니다','이라는','라는','에서','으로','에게','처럼','보다','먼저','다시','화면','단계','내용','설명','확인','부분','경우','대한','위해','같은','다른','있는','없는','하나','각각','현재','실제','핵심','관련','통해'
  ]);

  const normalizeSpace = (value) => String(value ?? '').replace(/\s+/g, ' ').trim();

  const splitSentences = (value) => {
    const text = normalizeSpace(value);
    if (!text) return [];
    const matches = text.match(/[^.!?]+[.!?]+|[^.!?]+$/g) || [text];
    return matches.map((sentence) => normalizeSpace(sentence)).filter(Boolean);
  };

  const sentenceKey = (value) => normalizeSpace(value)
    .toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, '');

  const uniqueSentences = (sentences) => {
    const seen = new Set();
    return sentences.filter((sentence) => {
      const key = sentenceKey(sentence);
      if (!key || seen.has(key)) return false;
      seen.add(key);
      return true;
    });
  };

  const tokens = (value) => {
    const words = normalizeSpace(value)
      .toLowerCase()
      .replace(/[^\p{L}\p{N}_-]+/gu, ' ')
      .split(/\s+/)
      .map((word) => word.replace(/(은|는|이|가|을|를|의|에|에서|으로|와|과|도|만|부터|까지)$/u, ''))
      .filter((word) => word.length >= 2 && !STOP_WORDS.has(word));
    return [...new Set(words)];
  };

  const relevanceScore = (sentence, step) => {
    const haystack = normalizeSpace(sentence).toLowerCase();
    const stepTokens = tokens(`${step.label || ''} ${step.script || ''} ${step.pointerNote || ''}`);
    return stepTokens.reduce((score, token) => score + (haystack.includes(token) ? Math.min(4, token.length) : 0), 0);
  };

  const conceptSentence = (slide, step) => {
    const context = normalizeSpace(`${slide.title || ''} ${step.label || ''} ${step.script || ''}`).toLowerCase();
    const rules = [
      [/dbeaver|디비버|클라이언트/u, '디비버는 데이터를 직접 보관하는 서버가 아니라 디비엠에스에 접속해 요청을 보내고 결과를 확인하는 클라이언트라는 점을 구분합니다.'],
      [/dbms|디비엠에스|postgresql|포스트그레스/u, '디비엠에스는 저장 공간의 이름이 아니라 데이터베이스를 만들고 관리하며 에스큐엘 요청을 처리하는 소프트웨어라는 점이 중요합니다.'],
      [/데이터베이스/u, '데이터베이스는 관련 데이터를 구조적으로 담는 논리적인 공간이며, 관리 프로그램인 디비엠에스와 같은 개념으로 섞어 부르지 않습니다.'],
      [/스키마/u, '스키마는 데이터베이스 안에서 테이블과 같은 객체를 묶는 이름 공간이므로 데이터베이스 자체와 구분해서 읽어야 합니다.'],
      [/테이블/u, '테이블을 볼 때는 열 이름을 외우기보다 먼저 한 행이 어떤 업무 대상을 나타내는지 한 문장으로 설명해 보는 것이 좋습니다.'],
      [/한 행|행과 열|row/u, '표를 읽을 때 열 이름보다 먼저 한 행이 무엇을 나타내는지 확인하면 저장 구조의 의미와 조회 결과를 훨씬 정확하게 구분할 수 있습니다.'],
      [/기본키|primary key|피케이/u, '기본키는 화면에 보이는 이름이 아니라 각 행을 안정적으로 구분하는 식별자라는 관점에서 확인합니다.'],
      [/외래키|foreign key|에프케이/u, '외래키 값은 반복될 수 있으며, 그 반복은 다른 테이블의 한 행을 여러 행이 참조하는 관계를 표현할 수 있습니다.'],
      [/관계|1:n|n:m|일대다|다대다/u, '관계는 단순히 값이 비슷하다는 뜻이 아니라 어떤 행이 어떤 행을 참조하는지 키를 통해 설명할 수 있어야 합니다.'],
      [/null|널/u, '널은 빈 문자열이나 숫자 영과 같은 값이 아니라 값이 없거나 아직 정해지지 않았음을 표현한다는 점을 구분합니다.'],
      [/타입|자료형|integer|text|date/u, '자료형은 값의 모양만 정하는 것이 아니라 허용할 값과 연산의 범위를 제한하므로 실제 업무 의미에 맞는지 확인해야 합니다.'],
      [/조회|select|order by|정렬/u, '조회 결과는 원본 저장 구조와 같다고 단정할 수 없으며, 필요한 열과 행을 선택하거나 정렬한 결과라는 점을 함께 확인합니다.'],
      [/ai|에이아이|검토|질문/u, '에이아이가 만든 초안은 빠른 출발점으로 활용하되 한 행의 의미, 키, 참조, 데이터 혼합, 타입과 필수 여부를 사람이 다시 검토해야 합니다.'],
      [/데이터/u, '데이터는 이름이나 날짜처럼 기록된 값과 사실이며, 데이터를 관리하는 소프트웨어나 데이터를 담는 논리적 공간과는 구분해서 이해합니다.']
    ];
    const found = rules.find(([pattern]) => pattern.test(context));
    if (found) return found[1];
    return `${step.label || '이 단계'}의 역할을 화면 요소와 연결해 설명하고, 앞뒤 단계와 무엇이 다른지 자신의 말로 구분할 수 있어야 합니다.`;
  };

  const buildNarration = (slide) => {
    const rawSteps = Array.isArray(slide?.steps) ? slide.steps : [];
    if (!rawSteps.length) return { overview: normalizeSpace(slide?.script), steps: [] };

    const overviewSentences = splitSentences(slide.script);
    const introCount = overviewSentences.length >= 5 ? 2 : 1;
    const overview = overviewSentences.slice(0, Math.max(1, introCount)).join(' ');
    const detailPool = overviewSentences.slice(Math.max(1, introCount));
    const assigned = rawSteps.map(() => []);

    detailPool.forEach((sentence, sentenceIndex) => {
      const scores = rawSteps.map((step) => relevanceScore(sentence, step));
      const bestScore = Math.max(...scores, 0);
      let targetIndex;
      if (bestScore > 0) targetIndex = scores.indexOf(bestScore);
      else targetIndex = Math.min(rawSteps.length - 1, Math.floor(sentenceIndex * rawSteps.length / Math.max(1, detailPool.length)));
      assigned[targetIndex].push(sentence);
    });

    const enriched = rawSteps.map((step, index) => {
      const original = splitSentences(step.script || step.label);
      const related = assigned[index];
      let sentences = uniqueSentences([...original, ...related]);

      const reinforcement = conceptSentence(slide, step);
      if (sentences.length < 3 && !sentences.some((sentence) => sentenceKey(sentence) === sentenceKey(reinforcement))) {
        sentences.push(reinforcement);
      }

      if (sentences.length < 2 && overviewSentences.length) {
        const fallback = overviewSentences[Math.min(index, overviewSentences.length - 1)];
        sentences = uniqueSentences([...sentences, fallback]);
      }

      return {
        ...step,
        enrichedScript: sentences.slice(0, 4).join(' '),
        sentenceCount: Math.min(4, sentences.length)
      };
    });

    return { overview, steps: enriched };
  };

  const cache = new WeakMap();
  const narrationFor = (slide) => {
    if (!slide || typeof slide !== 'object') return { overview: '', steps: [] };
    if (!cache.has(slide)) cache.set(slide, buildNarration(slide));
    return cache.get(slide);
  };

  const overviewText = (slide) => narrationFor(slide).overview;
  const stepText = (slide, index) => narrationFor(slide).steps[index]?.enrichedScript || normalizeSpace(slide?.steps?.[index]?.script);

  const audit = (slides) => {
    const report = { slides: 0, steps: 0, shortSteps: [], longSteps: [], averageSentences: 0 };
    let totalSentences = 0;
    (slides || []).forEach((slide, slideIndex) => {
      report.slides += 1;
      narrationFor(slide).steps.forEach((step, stepIndex) => {
        report.steps += 1;
        const count = splitSentences(step.enrichedScript).length;
        totalSentences += count;
        if (count < 2) report.shortSteps.push(`${slideIndex + 1}/${stepIndex + 1}`);
        if (count > 4) report.longSteps.push(`${slideIndex + 1}/${stepIndex + 1}`);
      });
    });
    report.averageSentences = report.steps ? totalSentences / report.steps : 0;
    return report;
  };

  window.CH2ScriptEnrichment = Object.freeze({
    splitSentences,
    narrationFor,
    overviewText,
    stepText,
    audit
  });
})();
