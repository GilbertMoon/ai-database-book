(() => {
  if (!window.CH1_SLIDES || !window.CH1_SLIDES[0]) return;

  window.CH1_SLIDES[0].s = `안녕하세요. 오늘은 데이터베이스 과정의 첫 시간입니다. 오늘 첫 시간에는 ‘에이아이 시대에 왜 데이터베이스를 배워야 하는가’를 살펴보겠습니다. 이 과정의 목표는 에스큐엘 문법만 외우는 것이 아닙니다. 에이아이가 만든 데이터 구조와 에스큐엘 결과를 이해하고, 실제 요구사항과 기준 데이터에 맞는지 검증하는 능력을 기르는 것입니다.

이 장표에는 전체 열다섯 개 장의 흐름이 정리되어 있습니다. 1장에서는 에이아이 시대에 데이터베이스를 배워야 하는 이유를 살펴봅니다. 2장에서는 데이터와 디비엠에스의 기본 개념을 정리합니다. 3장에서는 포스트그레스큐엘과 디비버로 실습 환경을 만들고, 4장에서는 관계형 데이터베이스와 에스큐엘을 시작합니다. 5장에서는 요구사항을 데이터 모델과 이알디로 바꾸는 방법을 배우고, 6장에서는 정규화와 데이터 무결성을 통해 좋은 테이블을 설계합니다.

7장에서는 온라인 강의 수강신청 데이터베이스를 완성하는 첫 번째 프로젝트를 진행합니다. 8장에서는 조인과 집계로 실제 서비스 질문에 답하고, 9장에서는 트랜잭션으로 데이터 정합성을 지킵니다. 10장에서는 실행 계획을 이용해 인덱스 효과를 검증하며, 11장에서는 권한, 백업과 복구를 포함한 안전한 운영 방법을 살펴봅니다.

12장에서는 조회 패턴을 기준으로 알디비엠에스와 노에스큐엘을 선택하는 방법을 배웁니다. 13장에서는 에이아이와 실제 실행 증거를 함께 사용해 데이터베이스 설계를 검증합니다. 14장에서는 에스큐엘 데이터 분석을 파이썬으로 확장하고, 마지막 15장에서는 앞에서 배운 내용을 하나의 종합 프로젝트로 완성합니다.

오늘은 전체 과정의 출발점으로, 에이아이 시대에도 데이터베이스 지식이 필요한 이유와 에이아이 결과를 검증하는 기본 관점을 살펴보겠습니다.`;

  if (window.CH1_SLIDES[1]) {
    window.CH1_SLIDES[1] = {
      ...window.CH1_SLIDES[1],
      k: 'CLASS FLOW',
      l: '수업 진행 방식',
      t: '질문, 사례, 판단 활동으로 진행합니다',
      h: `<h2>오늘 수업은 질문 → 사례 →<br>판단 활동으로 진행합니다</h2><p class="body-text">SQL 문법을 바로 외우기보다, 먼저 문제를 생각하고 사례를 분석한 뒤 자신의 판단 기준을 설명합니다.</p><div class="grid-3"><article class="card"><span class="number">1</span><h3>핵심 질문 확인</h3><p class="small">AI가 SQL을 작성하는 시대에 사람이 무엇을 확인해야 하는지 생각합니다.</p></article><article class="card"><span class="number">2</span><h3>사례 분석</h3><p class="small">학생, 질문, 수강신청처럼 익숙한 데이터로 오류와 누락을 살펴봅니다.</p></article><article class="card emphasis"><span class="number">3</span><h3>판단 기준 적용</h3><p class="small">실행되는 SQL과 요구사항에 맞는 SQL의 차이를 직접 판단해 봅니다.</p></article></div>`,
      s: `이번 첫 시간은 에스큐엘 문법을 바로 외우는 방식으로 진행하지 않습니다.

먼저 에이아이가 에스큐엘을 작성할 수 있는 시대에 사람이 어떤 역할을 해야 하는지 핵심 질문을 확인하겠습니다.

다음으로 학생, 질문, 수강신청처럼 익숙한 사례를 이용해 같은 숫자라도 의미가 달라질 수 있고, 실행되는 에스큐엘이라도 요구사항에는 맞지 않을 수 있다는 점을 살펴보겠습니다.

마지막에는 짧은 판단 활동을 진행합니다. 정답을 외우기보다 어떤 데이터가 누락되거나 중복될 수 있는지, 결과를 신뢰하려면 무엇을 확인해야 하는지를 자신의 말로 설명해 보겠습니다.

따라서 오늘 수업의 흐름은 질문을 이해하고, 사례에 적용하고, 판단 기준을 직접 말해 보는 순서입니다.`
    };
  }

  if (window.CH1_SLIDES[14]) {
    window.CH1_SLIDES[14].s = `이 사례에서는 학생 A가 질문 두 개, 학생 B가 질문 한 개, 학생 C가 질문을 작성하지 않은 상황을 가정합니다.

전체 학생 수는 세 명입니다. 그런데 학생과 질문을 이너 조인한 뒤 행 수를 세어도 결과가 우연히 세 행으로 나타납니다. 학생 A가 두 번, 학생 B가 한 번 나타나고 학생 C는 결과에서 빠지기 때문입니다.

두 결과의 숫자는 모두 3이지만 의미는 전혀 다릅니다. 하나는 학생 세 명을 센 결과이고, 다른 하나는 질문과 연결된 행 세 개를 센 결과입니다.

따라서 결과 숫자만 보고 SQL이 맞다고 판단해서는 안 됩니다. 어떤 테이블의 한 행을 기준으로 계산했는지, 누락된 대상과 중복된 대상은 없는지를 함께 확인해야 합니다.`;
  }

  const oldPositionSentence = '화면에 보이는 내용을 위에서 아래 순서로 천천히 살펴보겠습니다.';

  const textFromMarkup = (markup) => {
    const element = document.createElement('div');
    element.innerHTML = String(markup || '');
    return element.innerText.replace(/\s+/g, ' ').trim();
  };

  const buildContextScript = (slide) => {
    const title = slide.t || slide.l || '핵심 내용';
    const text = textFromMarkup(slide.h);
    const points = text
      .split(/[.!?。]/)
      .map((value) => value.trim())
      .filter((value) => value && value !== title)
      .slice(0, 5);

    const summary = points.length ? ` ${points.join('. ')}.` : '';
    return `이번에는 ‘${title}’이라는 주제를 살펴보겠습니다.${summary} 각 항목의 뜻을 단순히 외우기보다 데이터의 의미와 업무 요구사항에 연결해 이해하는 것이 중요합니다. 에이아이가 만든 결과도 같은 기준으로 확인해야 합니다.`;
  };

  window.CH1_SLIDES.forEach((slide) => {
    if (!slide || typeof slide !== 'object') return;

    if (typeof slide.s !== 'string' || !slide.s.trim()) {
      slide.s = buildContextScript(slide);
      return;
    }

    if (slide.s.includes(oldPositionSentence)) {
      slide.s = slide.s.replace(oldPositionSentence, '').replace(/\s{2,}/g, ' ').trim();
    }
  });
})();

document.write('<script src="../common/screen_position_patch.js"><\/script>');