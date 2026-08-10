(() => {
  'use strict';

  const VERSION = '20260808e';

  const splitSentences = (value) => {
    const text = String(value || '').replace(/\s+/g, ' ').trim();
    if (!text) return [];
    return (text.match(/[^.!?。]+[.!?。]?/g) || [text]).map((part) => part.trim()).filter(Boolean);
  };

  const normalize = (value) => String(value || '').toLowerCase().replace(/\s+/g, ' ').trim();

  const topicRules = [
    {
      pattern: /postgresql|포스트그레스큐엘|dbeaver|디비버|dbms|디비엠에스|서버|클라이언트|연결|connection|schema|스키마/,
      sentences: [
        '이 단계에서는 도구의 이름만 외우기보다 요청이 어느 프로그램을 거쳐 어떤 데이터베이스 객체에 도달하는지 연결해서 이해하는 것이 중요합니다.',
        '실제 작업에서는 현재 서버와 데이터베이스, 스키마가 어디인지 확인한 뒤 명령을 실행해야 다른 환경에 잘못 적용하는 실수를 줄일 수 있습니다.'
      ]
    },
    {
      pattern: /select|insert|update|delete|create table|alter table|crud|조회|삽입|수정|삭제|ddl|디디엘|dml/,
      sentences: [
        '문법 자체보다 이 명령이 어떤 행을 대상으로 하고 실행 전후에 데이터 상태가 어떻게 달라지는지를 함께 설명할 수 있어야 합니다.',
        '실행 결과가 성공으로 표시되더라도 대상 행과 조건이 의도한 범위였는지 다시 확인하는 습관이 필요합니다.'
      ]
    },
    {
      pattern: /요구사항|requirement|entity|엔터티|attribute|애트리뷰트|relationship|릴레이션십|erd|이알디|기본키|외래키|pk|fk|피케이|에프케이/,
      sentences: [
        '설계에서는 화면에 보이는 명사를 바로 테이블로 옮기기보다 한 행이 무엇을 의미하는지와 다른 엔터티와의 관계를 먼저 확인해야 합니다.',
        '키와 관계를 결정할 때는 중복 방지뿐 아니라 실제 업무에서 어떤 대상을 구분하고 무엇을 참조하는지도 함께 검토합니다.'
      ]
    },
    {
      pattern: /정규화|normalization|함수적 종속|1nf|2nf|3nf|이상|중복|anomaly/,
      sentences: [
        '정규화의 목적은 테이블을 많이 나누는 것이 아니라 한 사실을 한 곳에서 관리해 수정·삽입·삭제 이상을 줄이는 데 있습니다.',
        '분리 여부를 판단할 때는 컬럼의 주인이 누구인지와 같은 값이 여러 행에서 반복될 때 변경 위험이 생기는지를 확인합니다.'
      ]
    },
    {
      pattern: /join|조인|group by|그룹 바이|having|해빙|aggregate|집계|count|카운트|sum|avg|distinct|디스팅트/,
      sentences: [
        '조인과 집계에서는 SQL이 실행되는 것보다 결과의 한 행이 무엇을 의미하는지 먼저 정하는 것이 중요합니다.',
        '행 수가 늘거나 줄어드는 이유와 NULL이 집계에 어떤 영향을 주는지 확인하면 결과를 더 안전하게 해석할 수 있습니다.'
      ]
    },
    {
      pattern: /transaction|트랜잭션|commit|커밋|rollback|롤백|acid|lock|락|deadlock|데드락|savepoint/,
      sentences: [
        '트랜잭션은 여러 SQL을 하나의 업무 단위로 묶어 모두 성공하거나 모두 취소되도록 만드는 것이 핵심입니다.',
        'COMMIT과 ROLLBACK의 시점을 데이터 변경 순서와 함께 보면 장애나 동시 실행 상황에서 왜 일관성이 필요한지 이해하기 쉽습니다.'
      ]
    },
    {
      pattern: /index|인덱스|explain|analyze|seq scan|index scan|bitmap|cost|rows|성능|performance/,
      sentences: [
        '성능 판단은 인덱스가 있다는 사실보다 실제 실행 계획에서 어떤 경로로 몇 행을 읽는지를 확인하는 것이 중요합니다.',
        '개선 전후의 실행 계획과 실행 시간을 같은 조건에서 비교해야 인덱스가 실제로 도움이 되었는지 판단할 수 있습니다.'
      ]
    },
    {
      pattern: /role|권한|grant|revoke|login|nologin|security|보안|backup|백업|restore|복원|rpo|rto/,
      sentences: [
        '운영 보안에서는 필요한 권한만 부여하고 소유권과 역할 멤버십을 구분해 최소 권한 원칙을 유지하는 것이 중요합니다.',
        '백업은 파일을 만드는 것으로 끝나지 않으며 실제 복원과 검증까지 성공해야 운영 관점에서 사용할 수 있는 백업이라고 볼 수 있습니다.'
      ]
    },
    {
      pattern: /nosql|노에스큐엘|jsonb|document|도큐먼트|key-value|키 밸류|redis|레디스|mongodb|몽고디비|cassandra|카산드라|ttl/,
      sentences: [
        '저장소를 선택할 때는 기술 이름보다 어떤 조회 패턴과 변경 특성을 해결하려는지 먼저 정의해야 합니다.',
        '원본 데이터와 캐시·문서·검색용 데이터를 구분하면 여러 저장소를 함께 사용할 때 동기화와 재구축 책임도 더 명확해집니다.'
      ]
    },
    {
      pattern: /ai|에이아이|검토|review|diff|반례|test case|테스트|validation|검증/,
      sentences: [
        '에이아이가 만든 결과도 실행 성공만으로 승인하지 말고 요구사항과 데이터 의미, 제약조건, 반례를 기준으로 검증해야 합니다.',
        '검토 기준을 체크리스트와 테스트로 남기면 같은 변경을 다시 확인할 때 사람의 기억에만 의존하지 않을 수 있습니다.'
      ]
    },
    {
      pattern: /pandas|판다스|csv|view|뷰|analysis|분석|metric|지표|manifest|sha-256|dataframe|데이터프레임/,
      sentences: [
        '분석에서는 계산식보다 먼저 기간, 행 단위, 지표의 의미를 고정해야 SQL과 Python 결과를 같은 기준으로 비교할 수 있습니다.',
        '같은 데이터를 서로 다른 도구로 계산해 교차 검증하면 누락된 행이나 잘못된 집계 조건을 더 쉽게 발견할 수 있습니다.'
      ]
    },
    {
      pattern: /프로젝트|project|완료 기준|done criteria|최종|종합|gate|게이트/,
      sentences: [
        '종합 단계에서는 개별 SQL이 동작하는 것뿐 아니라 요구사항부터 설계, 데이터, 검증, 운영까지 하나의 흐름으로 재현되는지를 확인합니다.',
        '완료 기준을 숫자와 테스트 결과로 남겨 두면 결과물을 다른 사람이 다시 실행해도 같은 상태인지 판단할 수 있습니다.'
      ]
    }
  ];

  const genericSupport = (title, index) => {
    const cleanTitle = String(title || '이 내용').replace(/\s+/g, ' ').trim();
    return index % 2 === 0
      ? `${cleanTitle}에서는 화면에 보이는 결과만 확인하지 말고 이 요소가 앞뒤 단계에서 어떤 역할을 맡는지도 함께 연결해서 봅니다.`
      : `${cleanTitle}의 핵심은 용어를 암기하는 것이 아니라 실제 데이터와 실행 결과에서 이 기준을 스스로 확인할 수 있는 것입니다.`;
  };

  const supportSentence = (text, title, index) => {
    const source = normalize(`${title} ${text}`);
    const rule = topicRules.find((item) => item.pattern.test(source));
    if (!rule) return genericSupport(title, index);
    return rule.sentences[index % rule.sentences.length];
  };

  const enrichText = (value, title = '', index = 0) => {
    const original = splitSentences(value);
    if (!original.length) {
      return `이 단계의 핵심 내용을 화면 요소와 연결해서 확인합니다. ${supportSentence('', title, index)}`;
    }
    const output = original.slice();
    while (output.length < 2) {
      const addition = supportSentence(output.join(' '), title, index + output.length - 1);
      if (!output.includes(addition)) output.push(addition);
      else output.push(genericSupport(title, index + output.length));
    }
    return output.join(' ');
  };

  const overviewText = (title = '') => {
    const cleanTitle = String(title || '이 장표').replace(/\s+/g, ' ').trim();
    return `이 장표에서는 ${cleanTitle}의 핵심 의미와 확인 순서를 먼저 잡습니다. 아래 단계에서는 화면 요소를 의미 단위로 나누어 실제 데이터와 실행 흐름에 연결해 확인합니다.`;
  };

  const enhanceCard = (card) => {
    if (!card) return;
    const title = card.querySelector('h1')?.textContent?.trim() || '이 장표';
    const scriptBlocks = [...card.querySelectorAll('.script-text')];
    if (!scriptBlocks.length) return;

    const stepParagraphs = [...card.querySelectorAll('.script-text:not(.overview) p')];
    const alreadyEnhanced = Boolean(card.querySelector('.script-text.overview')) &&
      stepParagraphs.length > 0 &&
      stepParagraphs.every((paragraph) => paragraph.dataset.scriptEnhanced === VERSION);
    if (alreadyEnhanced) return;

    let overview = card.querySelector('.script-text.overview');
    if (!overview) {
      overview = document.createElement('div');
      overview.className = 'script-text overview';
      const paragraph = document.createElement('p');
      paragraph.textContent = overviewText(title);
      overview.appendChild(paragraph);
      scriptBlocks[0].before(overview);
      const note = document.createElement('p');
      note.className = 'focus-note enhancer-overview-note';
      note.textContent = '이 문단은 장표 전체의 도입 설명입니다. 아래 단계부터 화면 요소가 순서대로 강조됩니다.';
      overview.after(note);
    } else {
      const paragraph = overview.querySelector('p');
      if (paragraph && splitSentences(paragraph.textContent).length > 2) paragraph.textContent = overviewText(title);
    }

    [...card.querySelectorAll('.script-text:not(.overview) p')].forEach((paragraph, index) => {
      if (paragraph.dataset.scriptEnhanced === VERSION) return;
      paragraph.textContent = enrichText(paragraph.textContent, title, index);
      paragraph.dataset.scriptEnhanced = VERSION;
    });
    card.dataset.scriptEnhancerVersion = VERSION;
  };

  const apply = (root = document) => {
    if (document.body?.dataset?.scriptContentEnhancer === 'off') return;
    root.querySelectorAll?.('#card, .card').forEach(enhanceCard);
    const direct = root.matches?.('#card, .card') ? root : null;
    if (direct) enhanceCard(direct);
  };

  let scheduled = false;
  const schedule = () => {
    if (scheduled) return;
    scheduled = true;
    queueMicrotask(() => {
      scheduled = false;
      apply(document);
    });
  };

  const observer = new MutationObserver(schedule);
  const start = () => {
    if (document.body?.dataset?.scriptContentEnhancer === 'off') return;
    apply(document);
    observer.observe(document.body, { childList: true, subtree: true });
  };

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start, { once: true });
  else start();

  window.PresentationScriptEnhancer = Object.freeze({ VERSION, splitSentences, enrichText, overviewText, apply });
})();
