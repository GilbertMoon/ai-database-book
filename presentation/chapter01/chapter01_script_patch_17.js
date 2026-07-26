(() => {
  const customCursor = document.getElementById('cursor');
  const customHalo = document.getElementById('halo');

  window.cursor = customCursor;
  window.halo = customHalo;

  function moveCustomCursor(event) {
    if (!customCursor || !customHalo || document.body.classList.contains('native')) return;
    document.body.classList.add('ready');
    customCursor.style.left = `${event.clientX}px`;
    customCursor.style.top = `${event.clientY}px`;
    customHalo.style.left = `${event.clientX}px`;
    customHalo.style.top = `${event.clientY}px`;
  }

  if (customCursor && customHalo) {
    document.addEventListener('pointermove', moveCustomCursor, { passive: true });
    document.addEventListener('mousemove', moveCustomCursor, { passive: true });
  } else {
    document.body.classList.add('native');
  }

  if (!window.CH1_SLIDES) return;

  if (window.CH1_SLIDES[16]) {
    window.CH1_SLIDES[16].s = `이번 장표에서는 에스큐엘 결과가 나왔을 때 확인해야 할 다섯 가지 기준을 정리하겠습니다.

결과 숫자가 보이면 먼저 어떤 테이블의 한 행을 기준으로 계산했는지 확인해야 합니다.

다음으로 질문이 없는 학생처럼 포함되어야 할 대상이 제외되지 않았는지 살펴봐야 합니다.

또 조인 과정에서 같은 학생이 여러 번 나타나 중복 계산되지 않았는지도 확인해야 합니다.

카운트 별표가 실제로 세려는 대상을 계산하고 있는지도 중요합니다. 행 수를 세는 것인지, 학생 수를 세는 것인지 구분해야 합니다.

마지막으로 결과를 보기 전에 예상 결과를 먼저 생각해 보아야 합니다. 그래야 에이아이가 만든 에스큐엘 결과가 요구사항에 맞는지 판단할 수 있습니다.`;
  }

  if (window.CH1_SLIDES[17]) {
    window.CH1_SLIDES[17].s = `이번 장표에서는 에이아이가 만든 테이블 구조도 틀릴 수 있다는 점을 살펴보겠습니다.

예시 테이블은 학생 이름, 강의명, 강사명, 금액을 하나의 수강신청 테이블에 모두 저장하고 있습니다. 처음 보기에는 한 테이블에 필요한 정보가 모두 들어 있어서 편해 보일 수 있습니다.

하지만 이런 구조는 문제가 생기기 쉽습니다. 같은 강의를 여러 학생이 신청하면 강의명과 강사명이 계속 반복됩니다. 강사명이 바뀌면 여러 행을 모두 수정해야 하고, 일부만 수정되면 데이터가 서로 맞지 않게 됩니다.

또 학생, 강의, 강사, 금액은 모두 성격이 다른 데이터입니다. 이들을 한 테이블에 섞어 두면 어떤 정보가 기준 데이터이고, 어떤 정보가 수강신청 과정에서 생긴 데이터인지 구분하기 어렵습니다.

따라서 에이아이가 테이블을 만들어 주더라도 그대로 사용하면 안 됩니다. 중복이 생기지 않는지, 수정할 때 오류가 생기지 않는지, 서로 다른 데이터가 한 테이블에 섞여 있지 않은지 구조적으로 검토해야 합니다.`;
  }

  if (window.CH1_SLIDES[18]) {
    window.CH1_SLIDES[18].s = `이번 장표에서는 하나의 테이블에 모든 정보를 넣었을 때 생기는 문제를 살펴보겠습니다.

학생 이름, 강의 제목, 강사명만으로는 학생, 강의, 강사를 안정적으로 구분하기 어렵습니다. 이름이나 제목은 같을 수 있고, 나중에 변경될 수도 있기 때문입니다.

또 같은 강의를 여러 학생이 신청하면 강의 제목과 강사 이름이 여러 행에 반복해서 저장됩니다. 처음에는 단순해 보이지만, 데이터가 많아질수록 중복이 커집니다.

문제는 수정할 때 더 커집니다. 강의 제목이나 강사명이 바뀌면 관련된 모든 행을 수정해야 합니다. 일부 행만 수정되면 같은 강의인데 서로 다른 이름이나 강사명이 기록되는 불일치가 생길 수 있습니다.

또 필수값, 중복 신청, 허용 가능한 상태 같은 업무 규칙을 안정적으로 제한하기도 어렵습니다.

따라서 학생, 강의, 강사, 수강신청처럼 성격이 다른 데이터는 적절히 분리하고, 식별자와 관계를 기준으로 연결해야 합니다. 에이아이가 만든 테이블도 이런 기준으로 구조를 검토해야 합니다.`;
  }

  if (window.CH1_SLIDES[19]) {
    window.CH1_SLIDES[19].s = `이번 장표에서는 에이아이의 설계안을 어떻게 바라보아야 하는지 정리하겠습니다.

에이아이가 만든 테이블 생성문이나 에스큐엘이 실행 가능하다고 해서 바로 정답이라고 볼 수는 없습니다.

데이터베이스 설계는 현재 요구사항뿐 아니라 이후 운영 과정에서 데이터가 어떻게 추가되고, 수정되고, 삭제될지도 함께 고려해야 합니다.

따라서 에이아이의 설계안은 최종 답안이 아니라 검토할 변경 후보로 보아야 합니다. 중복은 없는지, 관계는 올바른지, 필수값과 중복 신청 같은 업무 규칙을 표현할 수 있는지 확인해야 합니다.

정리하면 에이아이는 빠르게 초안을 만들어 주는 도구이고, 그 초안이 실제 서비스와 운영 변화에 맞는지 판단하는 역할은 사람이 담당해야 합니다.`;
  }

  if (window.CH1_SLIDES[22]) {
    window.CH1_SLIDES[22].s = `널과 영은 비슷해 보이지만 의미가 다릅니다.

널은 값이 없거나 아직 확인되지 않은 상태를 나타냅니다. 반면 영은 실제로 입력된 숫자 값입니다. 예를 들어 결제 금액이 널이라면 결제 정보가 아직 등록되지 않았다는 뜻일 수 있습니다. 결제 금액이 영이라면 무료 결제처럼 실제 금액이 0원이라는 의미일 수 있습니다.

따라서 널을 무조건 영으로 바꾸면, 정보가 없는 상태와 실제 값이 0인 상태를 구분할 수 없게 됩니다. 변환하기 전에는 두 값이 해당 업무에서 정말 같은 의미인지 먼저 확인해야 합니다.`;
  }

  const chapterGoals = {
    k: 'CHAPTER GOALS',
    l: '학습 목표',
    t: '이번 장을 마치면 할 수 있는 일',
    h: `<h2>이번 장을 마치면<br>할 수 있는 일</h2><ul class="bullet-list"><li>AI가 초안을 만들어도 사람이 검증해야 하는 이유를 설명할 수 있습니다.</li><li>실행 성공과 요구사항에 맞는 결과를 구분할 수 있습니다.</li><li>누락·중복·잘못된 구조를 찾는 질문을 적용할 수 있습니다.</li><li>파일·스프레드시트·DBMS의 선택 기준을 설명할 수 있습니다.</li><li>기준 데이터·파생 데이터·AI 생성 결과를 구분할 수 있습니다.</li></ul>`,
    s: `1장을 마치면 에이아이가 초안을 만들어도 사람이 검증해야 하는 이유를 설명할 수 있어야 합니다. 실행에 성공한 결과와 실제 요구사항에 맞는 결과도 구분할 수 있어야 합니다. 또한 누락과 중복, 잘못된 데이터 구조를 찾는 질문을 적용하고, 상황에 맞는 저장 방식을 선택하며, 기준 데이터와 파생 데이터, 에이아이 생성 결과를 구분하는 것이 이번 장의 목표입니다.`
  };

  const chapterFlow = {
    k: 'CHAPTER FLOW',
    l: '학습 흐름',
    t: '이번 장은 다섯 단계로 진행합니다',
    h: `<h2>이번 장의 학습 흐름</h2><div class="flow"><div class="flow-step">왜 배우는가</div><div class="flow-arrow">→</div><div class="flow-step">실행과 정답<br>구분</div><div class="flow-arrow">→</div><div class="flow-step">구조와 저장 방식<br>판단</div><div class="flow-arrow">→</div><div class="flow-step">데이터와 AI 결과<br>검증</div><div class="flow-arrow">→</div><div class="flow-step">사례 적용과<br>정리</div></div>`,
    s: `먼저 에이아이 시대에도 데이터베이스를 배워야 하는 이유를 확인합니다. 다음으로 실행되는 명령과 요구사항에 맞는 결과가 왜 다른지 사례로 살펴봅니다. 그다음 데이터 구조와 저장 방식을 선택하는 기준을 배우고, 데이터 품질과 에이아이 결과를 검증하는 방법으로 이어집니다. 마지막에는 사례에 판단 기준을 적용하고 1장의 핵심을 정리합니다.`
  };

  const courseRoadmap = {
    k: 'COURSE ROADMAP',
    l: '15개 장의 학습 여정',
    t: '15개 장은 네 단계로 이어집니다',
    h: `<h2>15개 장은<br>네 단계로 이어집니다</h2>
<p class="body-text">기초 개념에서 시작해 직접 만들고 검증한 뒤, 확장 기술과 종합 프로젝트로 연결합니다.</p>
<div class="grid-2">
  <article class="card">
    <span class="number">1~3장</span>
    <h3>기초 이해</h3>
    <p class="small">필요성 → 기본 개념 → 실습 환경 구축</p>
  </article>
  <article class="card">
    <span class="number">4~6장</span>
    <h3>데이터 처리와 설계</h3>
    <p class="small">입력·조회·수정·삭제 → 데이터 모델링 → 정확성 규칙</p>
  </article>
  <article class="card">
    <span class="number">7~10장</span>
    <h3>실전 검증</h3>
    <p class="small">프로젝트 → 데이터 연결·집계 → 안전한 변경 → 성능</p>
  </article>
  <article class="card emphasis">
    <span class="number">11~15장</span>
    <h3>확장과 종합</h3>
    <p class="small">보안·복구 → 저장소 선택 → AI 검증 → Python → 종합 프로젝트</p>
  </article>
</div>`,
    s: `이 과정은 열다섯 개 장을 네 단계로 나누어 진행합니다.

먼저 1장부터 3장까지는 기초 이해 단계입니다. 데이터베이스가 왜 필요한지 생각하고, 기본 용어를 익힌 뒤, 직접 연습할 수 있는 환경을 준비합니다.

4장부터 6장까지는 데이터를 다루고 구조를 설계하는 단계입니다. 데이터를 입력하고 조회하고 수정하고 삭제하는 기본 방법을 배우고, 요구사항을 테이블 구조로 바꾸며, 잘못된 값이 저장되지 않도록 정확성 규칙을 적용합니다. 이런 데이터 처리 명령을 작성할 때 앞에서 설명한 에스큐엘을 사용합니다.

7장부터 10장까지는 실전 검증 단계입니다. 작은 프로젝트를 완성하고, 여러 데이터를 연결해 질문에 답하며, 변경 과정의 안전성과 조회 성능을 실제 실행 결과로 확인합니다.

마지막 11장부터 15장까지는 확장과 종합 단계입니다. 보안과 복구, 목적에 맞는 저장소 선택, 에이아이 결과 검증, 파이썬 확장을 거쳐 종합 프로젝트로 마무리합니다.

지금 모든 용어를 외울 필요는 없습니다. 기초 이해에서 시작해 설계, 검증, 확장으로 이어진다는 전체 흐름만 잡으면 됩니다.`
  };

  window.CH1_SLIDES.splice(1, 0, chapterGoals, chapterFlow, courseRoadmap);
})();