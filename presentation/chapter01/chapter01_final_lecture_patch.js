(() => {
  const chapters = [
    ["01", "AI 시대에 데이터베이스를 왜 배워야 하는가"],
    ["02", "데이터와 DBMS의 기본 개념"],
    ["03", "PostgreSQL과 DBeaver로 실습 환경 만들기"],
    ["04", "관계형 데이터베이스와 SQL 시작하기"],
    ["05", "요구사항에서 데이터 모델과 ERD 만들기"],
    ["06", "정규화와 데이터 무결성으로 좋은 테이블 만들기"],
    ["07", "온라인 강의 수강신청 DB 완성하기"],
    ["08", "JOIN과 집계로 서비스 질문에 답하기"],
    ["09", "트랜잭션으로 데이터 정합성 지키기"],
    ["10", "실행 계획으로 인덱스 효과 검증하기"],
    ["11", "권한·백업·복구"],
    ["12", "RDBMS와 NoSQL 선택"],
    ["13", "AI와 실행 증거로 설계 검증"],
    ["14", "SQL 데이터 분석과 Python 확장"],
    ["15", "데이터베이스 종합 프로젝트"]
  ];

  const courseList = chapters.map(([number, title]) => `
    <li class="course-item ${number === "01" ? "current" : ""}">
      <span class="course-number">${number}</span>
      <span class="course-title">${title}</span>
    </li>`).join("");

  const conceptBadge = `<div class="chips" style="margin-bottom:18px"><span class="chip">개념 설명용 SQL</span><span class="chip">지금은 실행하지 않습니다</span></div>`;
  const exampleMini = `<div class="chips" style="margin-bottom:18px"><span class="chip">미니 예제 A</span><span class="chip">학생과 질문</span></div>`;
  const exampleCourse = `<div class="chips" style="margin-bottom:18px"><span class="chip">책의 주 예제</span><span class="chip">온라인 강의 수강신청</span></div>`;
  const exampleAiService = `<div class="chips" style="margin-bottom:18px"><span class="chip">확장 예제</span><span class="chip">AI 튜터링 서비스</span></div>`;

  window.CH1_SLIDES = [
    {
      k: "CHAPTER 01 · COURSE OVERVIEW",
      l: "15-Chapter Roadmap",
      t: "AI 시대에 데이터베이스를 왜 배워야 할까요?",
      h: `
        <div class="cover-grid">
          <div class="cover-intro">
            <p class="cover-overline">AI × DATABASE · 15-CHAPTER COURSE</p>
            <h1>AI 시대에<br>데이터베이스를 왜 배워야 할까요?</h1>
            <p class="lead cover-lead">AI가 만든 데이터 구조와 SQL 결과를 이해하고, 실제 요구사항에 맞는지 검증하는 과정을 배웁니다.</p>
            <div class="title-meta">
              <span class="pill">AI 결과 검증</span>
              <span class="pill">데이터 구조 이해</span>
              <span class="pill">저장 방식 선택</span>
            </div>
          </div>
          <section class="course-overview" aria-label="전체 15장 목차">
            <div class="course-overview-head">
              <span>전체 과정 개요</span>
              <strong>15 Chapters</strong>
            </div>
            <ol class="course-list">${courseList}</ol>
          </section>
        </div>`,
      s: `오늘은 데이터베이스 과정의 첫 시간입니다. 이 과정의 목표는 SQL 문법만 외우는 것이 아닙니다. AI가 만든 데이터 구조와 SQL 결과를 이해하고, 실제 요구사항과 기준 데이터에 맞는지 검증하는 능력을 기르는 것입니다.

오른쪽에는 전체 15개 장의 흐름이 있습니다. 처음에는 데이터베이스가 왜 필요한지와 기본 용어를 익히고, 이후에는 PostgreSQL 실습, 설계, JOIN, 트랜잭션, 인덱스, 보안, 복구, 분석과 AI 검증으로 확장합니다.

오늘은 그 출발점으로, AI 시대에도 왜 사람이 데이터베이스를 이해해야 하는지부터 천천히 살펴보겠습니다.`
    },
    {
      k: "TODAY GOAL",
      l: "학습 목표와 진행 방식",
      t: "오늘은 정답 암기보다 판단 기준을 만듭니다",
      h: `<h2>오늘은 정답 암기보다<br>판단 기준을 만듭니다</h2><p class="body-text">첫 시간은 개념 설명, 사례 확인, 짧은 판단 활동을 섞어 진행합니다.</p><div class="grid-3"><article class="card"><span class="number">1</span><h3>왜 필요한가</h3><p class="small">AI가 SQL을 만들어도 사람이 확인해야 하는 이유</p></article><article class="card"><span class="number">2</span><h3>무엇을 검증하나</h3><p class="small">요구사항, 포함 대상, 중복과 누락</p></article><article class="card emphasis"><span class="number">3</span><h3>어떻게 판단하나</h3><p class="small">저장 방식, 기준 데이터, AI 결과 구분</p></article></div>`,
      s: `오늘의 목표는 정답을 암기하는 것이 아니라 판단 기준을 만드는 것입니다.

첫째, AI가 SQL이나 테이블 구조를 만들어도 왜 사람이 확인해야 하는지 이해합니다. 둘째, 결과 숫자가 나오면 요구사항과 포함 대상, 중복과 누락을 어떻게 확인할지 배웁니다. 셋째, 파일, 스프레드시트, DBMS 중 어떤 방식을 검토해야 하는지 판단합니다.

따라서 오늘은 어려운 문법을 깊게 들어가기보다, 앞으로 모든 장에서 사용할 검증 관점을 먼저 잡겠습니다.`
    },
    {
      k: "KEY QUESTION",
      l: "핵심 질문",
      t: "AI가 SQL을 작성한다면 사람은 무엇을 해야 할까요?",
      h: `<div class="question-mark">?</div><h2>AI가 SQL을 작성한다면<br>사람은 무엇을 해야 할까요?</h2><p class="lead">오늘 수업 전체를 관통하는 질문입니다.</p><div class="quote" style="font-size:38px">AI는 초안을 만들고, 사람은 의미와 정확성을 검증합니다.</div>`,
      s: `오늘 수업의 핵심 질문은 이것입니다. AI가 SQL을 작성한다면 사람은 무엇을 해야 할까요?

AI는 명령의 초안을 빠르게 만들 수 있습니다. 하지만 어떤 데이터를 포함해야 하는지, 어떤 데이터를 제외해야 하는지, 나온 숫자가 실제 질문에 맞는지는 자동으로 확정할 수 없습니다.

그래서 사람은 SQL을 모두 처음부터 외워 쓰는 사람이 아니라, 결과의 의미와 정확성을 검증하는 사람이 되어야 합니다.`
    },
    {
      k: "COURSE FLOW",
      l: "용어는 미리 보기만",
      t: "낯선 용어는 오늘 모두 외우지 않아도 됩니다",
      h: `<h2>낯선 용어는<br>오늘 모두 외우지 않아도 됩니다</h2><p class="body-text">JOIN, NULL, 기본키, 외래키, 제약조건, 트랜잭션, 인덱스는 뒤에서 실습으로 다시 배웁니다.</p><div class="chips"><span class="chip">JOIN</span><span class="chip">NULL</span><span class="chip">기본키</span><span class="chip">외래키</span><span class="chip">제약조건</span><span class="chip">트랜잭션</span><span class="chip">인덱스</span><span class="chip">실행 계획</span></div>`,
      s: `이번 장에서는 여러 용어가 미리 등장합니다. JOIN, NULL, 기본키, 외래키, 제약조건, 트랜잭션, 인덱스 같은 단어입니다.

지금 이 용어들을 모두 암기할 필요는 없습니다. 오늘은 이런 용어들이 데이터의 구조, 정확성, 안전성, 성능을 설명할 때 사용된다는 정도만 이해하면 됩니다.

각 개념은 뒤에서 실제 PostgreSQL 실습과 함께 하나씩 다시 다룹니다.`
    },
    {
      k: "AI CAN HELP",
      l: "AI가 잘하는 일",
      t: "AI는 테이블과 SQL 초안을 빠르게 제안합니다",
      h: `<h2>AI는 테이블과 SQL 초안을<br>빠르게 제안합니다</h2><p class="body-text">문법 초안, 오류 설명, 코드 수정은 AI가 잘 도와줄 수 있는 영역입니다.</p><div class="prompt-box">학생 정보를 저장할 PostgreSQL 테이블을 만들어 주세요.\n학생별 질문 수를 계산하는 SQL도 작성해 주세요.</div>`,
      s: `AI가 잘하는 일부터 보겠습니다. AI는 테이블 생성문이나 SQL 초안을 매우 빠르게 제안할 수 있습니다.

예를 들어 학생 정보를 저장할 PostgreSQL 테이블을 만들어 달라고 하거나, 학생별 질문 수를 계산하는 SQL을 작성해 달라고 요청할 수 있습니다. 문법 오류를 설명하고 수정 방향을 제안하는 데도 도움이 됩니다.

여기서 새롭게 기억할 내용은 속도입니다. AI는 초안을 빠르게 만드는 도구로 유용합니다.`
    },
    {
      k: "AI LIMIT",
      l: "사람이 정해야 할 일",
      t: "AI는 확인되지 않은 업무 규칙을 스스로 확정할 수 없습니다",
      h: `<h2>AI는 확인되지 않은 업무 규칙을<br>스스로 확정할 수 없습니다</h2><p class="body-text">규칙 후보를 제안할 수는 있지만, 실제 정책인지 확인하고 승인하는 일은 사람이 해야 합니다.</p><ul class="bullet-list"><li>학생 이메일은 중복될 수 있는가?</li><li>탈퇴한 학생 기록은 보존해야 하는가?</li><li>질문이 없는 학생도 통계에 포함해야 하는가?</li><li>완료 상태의 질문에는 반드시 답변이 있어야 하는가?</li><li>어떤 정보가 개인정보이며 누가 조회할 수 있는가?</li></ul>`,
      s: `이번 장표의 새 핵심은 정책 결정입니다.

AI는 규칙 후보를 제안할 수 있습니다. 하지만 학생 이메일 중복을 허용할지, 탈퇴한 학생 기록을 보존할지, 질문이 없는 학생을 통계에 포함할지는 실제 서비스 정책입니다.

이런 규칙이 제공되지 않았거나 아직 확인되지 않았다면 AI가 스스로 확정해서는 안 됩니다. 사람이 업무 규칙을 확인하고, AI가 만든 결과가 그 규칙을 반영했는지 검토해야 합니다.`
    },
    {
      k: "LEARNING POINT",
      l: "학습 관점",
      t: "데이터베이스 학습은 문법 암기만이 아닙니다",
      h: `<h2>데이터베이스 학습은<br>문법 암기만이 아닙니다</h2><p class="body-text">무엇을 저장할지, 어떻게 연결할지, 결과가 맞는지 검증하는 능력을 기르는 과정입니다.</p><div class="grid-3"><article class="card"><span class="number">1</span><h3>저장 대상</h3><p class="small">무엇을 데이터로 남겨야 하는가</p></article><article class="card"><span class="number">2</span><h3>관계</h3><p class="small">데이터가 어떻게 연결되는가</p></article><article class="card emphasis"><span class="number">3</span><h3>검증</h3><p class="small">숫자가 요구사항에 맞는가</p></article></div>`,
      s: `이번 장표에서는 데이터베이스 학습을 세 가지 관점으로 보겠습니다.

첫째, 저장 대상입니다. 서비스에서 어떤 사건과 상태를 데이터로 남길지 판단해야 합니다. 둘째, 관계입니다. 학생과 질문, 학생과 강의처럼 데이터가 서로 어떻게 연결되는지 이해해야 합니다. 셋째, 검증입니다. 결과 숫자가 나왔을 때 그 숫자가 실제 요구사항에 맞는지 확인해야 합니다.

앞으로의 SQL 문법도 결국 이 세 가지를 표현하고 확인하기 위한 도구로 볼 수 있습니다.`
    },
    {
      k: "FIVE REASONS",
      l: "다섯 가지 이유",
      t: "데이터베이스를 배워야 하는 이유는 다섯 가지로 정리됩니다",
      h: `<h2>데이터베이스를 배워야 하는 이유는<br>다섯 가지로 정리됩니다</h2><div class="grid-2"><article class="card"><h3>AI 결과 검증</h3><p class="small">이 숫자가 요구사항에 맞는가</p></article><article class="card"><h3>업무 구조 표현</h3><p class="small">사용자, 주문, 강의, 신청은 어떻게 연결되는가</p></article><article class="card"><h3>정확한 분석</h3><p class="small">중복, 누락, NULL, 집계 기준이 올바른가</p></article><article class="card"><h3>서비스 운영</h3><p class="small">상태, 권한, 실행 이력을 어떻게 관리하는가</p></article><article class="card emphasis"><h3>안전성과 복구</h3><p class="small">잘못된 변경을 막고 되돌릴 수 있는가</p></article></div>`,
      s: `이제 데이터베이스를 배워야 하는 이유를 다섯 가지로 정리합니다.

첫째는 AI 결과 검증입니다. 둘째는 현실의 업무 구조를 데이터로 표현하는 일입니다. 셋째는 정확한 분석과 의사결정입니다. 넷째는 AI 기능을 운영 가능한 서비스로 만드는 일입니다. 다섯째는 안전성, 이력, 복구입니다.

이 다섯 가지는 뒤 장들의 학습 기준이 됩니다.`
    },
    {
      k: "IMPORTANT IDEA",
      l: "핵심 개념",
      t: "실행되는 SQL과 올바른 SQL은 다릅니다",
      h: `<h2>실행되는 SQL과<br>올바른 SQL은 다릅니다</h2><p class="body-text">문법 오류가 없다고 해서 요구사항에 맞는 결과라고 볼 수는 없습니다.</p><div class="quote">실행 성공 ≠ 올바른 결과<br>그럴듯한 숫자 ≠ 검증된 숫자</div>`,
      s: `이제 가장 중요한 구분을 보겠습니다. 실행되는 SQL과 올바른 SQL은 다릅니다.

SQL이 문법적으로 실행되고 숫자를 보여 주더라도, 그 숫자가 요구사항에 맞는지는 별도 문제입니다. 포함해야 할 대상이 빠졌거나, 같은 대상이 여러 번 계산되었거나, 다른 기준으로 집계되었을 수 있습니다.

다음 장표부터는 이 차이를 작은 데이터로 직접 확인해 보겠습니다.`
    },
    {
      k: "MINI EXAMPLE A",
      l: "SQL보다 데이터 먼저",
      t: "먼저 작은 데이터를 보고 예상해 봅니다",
      h: `${exampleMini}<h2>먼저 작은 데이터를 보고<br>예상해 봅니다</h2><p class="body-text">아직 SQL을 보지 말고, 전체 학생 수와 질문 수를 눈으로 먼저 확인합니다.</p><div class="table-wrap"><table><thead><tr><th>학생</th><th>질문 수</th></tr></thead><tbody><tr><td>학생 A</td><td>2</td></tr><tr><td>학생 B</td><td>1</td></tr><tr><td>학생 C</td><td>0</td></tr></tbody></table></div>`,
      s: `이번 미니 예제에서는 SQL보다 데이터를 먼저 보겠습니다.

학생 A는 질문이 2개, 학생 B는 질문이 1개, 학생 C는 질문이 없습니다. 이때 전체 학생 수는 몇 명일까요? 답은 3명입니다.

지금 중요한 것은 SQL 문법이 아니라 무엇을 세려는지입니다. 우리가 세려는 것은 질문 수가 아니라 학생 수입니다.`
    },
    {
      k: "EXPECTED RESULT",
      l: "예상 결과",
      t: "요구사항을 숫자로 먼저 적습니다",
      h: `<h2>요구사항을 숫자로<br>먼저 적습니다</h2><p class="body-text">“전체 학생 수”와 “학생별 질문 수”는 서로 다른 질문입니다.</p><div class="grid-2"><article class="card emphasis"><h3>전체 학생 수</h3><p class="lead" style="color:var(--primary);font-weight:900">3명</p><p class="small">질문이 없는 학생 C도 포함</p></article><article class="card"><h3>학생별 질문 수</h3><p class="small">A: 2건<br>B: 1건<br>C: 0건</p></article></div>`,
      s: `이번 장표에서는 예상 결과를 먼저 적습니다.

요구사항이 전체 학생 수라면 답은 3명입니다. 질문이 없는 학생 C도 포함해야 합니다.

반면 학생별 질문 수를 묻는다면 A는 2건, B는 1건, C는 0건입니다. 두 질문은 비슷해 보이지만 결과의 단위가 다릅니다. 앞으로 SQL을 볼 때는 항상 먼저 무엇을 세려는지 확인해야 합니다.`
    },
    {
      k: "JOIN RESULT",
      l: "JOIN 후 행",
      t: "JOIN 후에는 학생이 아니라 연결된 행을 보게 됩니다",
      h: `<h2>JOIN 후에는 학생이 아니라<br>연결된 행을 보게 됩니다</h2><p class="body-text">학생 A는 질문 2개 때문에 2행, 학생 B는 1행, 학생 C는 0행이 됩니다.</p><div class="table-wrap"><table><thead><tr><th>학생</th><th>질문 수</th><th>JOIN 후 행 수</th></tr></thead><tbody><tr><td>학생 A</td><td>2</td><td>2</td></tr><tr><td>학생 B</td><td>1</td><td>1</td></tr><tr><td>학생 C</td><td>0</td><td>0</td></tr><tr><td>합계</td><td>3명</td><td>3행</td></tr></tbody></table></div>`,
      s: `이 장표가 예제의 핵심입니다.

학생 A는 질문이 2개이므로 JOIN 후 2행으로 나타납니다. 학생 B는 1행으로 나타납니다. 학생 C는 질문이 없기 때문에 JOIN 결과에서 사라질 수 있습니다.

결과 행 수는 우연히 3행입니다. 하지만 이 3은 학생 3명이 아니라 질문과 연결된 행 3개입니다. 숫자는 같지만 의미가 다릅니다.`
    },
    {
      k: "WRONG SQL",
      l: "개념 설명용 SQL",
      t: "이제 AI가 만든 잘못된 초안을 봅니다",
      h: `${conceptBadge}<h2>이제 AI가 만든<br>잘못된 초안을 봅니다</h2><p class="body-text">문법은 맞을 수 있지만, 요구사항과 맞지 않을 수 있습니다.</p><pre><code>SELECT COUNT(*) AS student_count
FROM students AS s
INNER JOIN questions AS q
    ON q.student_id = s.id;</code></pre>`,
      s: `이제 SQL을 보겠습니다. 이 SQL은 개념 설명용이며 지금 직접 실행하는 코드는 아닙니다.

이 SQL은 학생 테이블과 질문 테이블을 INNER JOIN한 뒤 COUNT(*)로 행 수를 셉니다. 문법적으로는 실행될 수 있습니다.

하지만 우리가 원한 것은 전체 학생 수입니다. 질문이 없는 학생까지 포함해야 한다면 이 SQL은 요구사항과 맞지 않습니다.`
    },
    {
      k: "WHY WRONG",
      l: "무엇을 셌는가",
      t: "COUNT(*)는 JOIN 결과 행을 셉니다",
      h: `<h2>COUNT(*)는<br>JOIN 결과 행을 셉니다</h2><p class="body-text">학생 수를 세는지, 질문과 연결된 행 수를 세는지 구분해야 합니다.</p><div class="grid-3"><article class="card"><span class="number">1</span><h3>누락</h3><p class="small">질문 없는 학생은 빠질 수 있습니다.</p></article><article class="card"><span class="number">2</span><h3>반복</h3><p class="small">질문이 여러 개인 학생은 여러 행이 됩니다.</p></article><article class="card emphasis"><span class="number">3</span><h3>의미 오류</h3><p class="small">학생 수가 아니라 연결된 행 수입니다.</p></article></div>`,
      s: `이번 장표의 새 설명은 COUNT(*)가 무엇을 세는가입니다.

COUNT(*)는 현재 결과에 남아 있는 행 수를 셉니다. 학생 테이블만 보고 있다면 학생 행 수를 셀 수 있지만, JOIN 후라면 연결된 결과 행을 셉니다.

그래서 질문이 없는 학생은 빠지고, 질문이 여러 개인 학생은 반복될 수 있습니다. 결과 숫자를 볼 때는 숫자 자체보다 숫자가 세는 대상의 단위를 확인해야 합니다.`
    },
    {
      k: "BETTER SQL",
      l: "올바른 기준과 전제",
      t: "전체 학생 수라면 학생 테이블을 기준으로 셉니다",
      h: `${conceptBadge}<h2>전체 학생 수라면<br>학생 테이블을 기준으로 셉니다</h2><pre><code>SELECT COUNT(*) AS student_count
FROM students;</code></pre><div class="grid-3" style="margin-top:20px"><article class="card"><h3>전제 1</h3><p class="small">students 한 행은 학생 한 명</p></article><article class="card"><h3>전제 2</h3><p class="small">중복·병합 학생 행 없음</p></article><article class="card emphasis"><h3>전제 3</h3><p class="small">비활성·탈퇴 제외 조건 없음</p></article></div>`,
      s: `전체 학생 수가 목적이라면 학생 테이블을 기준으로 세는 것이 가장 단순합니다.

하지만 이 SQL도 항상 무조건 정답은 아닙니다. 세 가지 전제가 필요합니다. students의 한 행이 학생 한 명이어야 하고, 중복된 학생 행이 없어야 하며, 비활성 또는 탈퇴 학생을 제외하라는 조건이 없어야 합니다.

정답 SQL은 문법만으로 결정되지 않습니다. 요구사항과 전제가 함께 맞아야 합니다.`
    },
    {
      k: "CHECKLIST",
      l: "검증 질문",
      t: "숫자가 나오면 다섯 가지를 확인합니다",
      h: `<h2>숫자가 나오면<br>다섯 가지를 확인합니다</h2><p class="body-text">결과를 보기 전에 기준과 예상 결과를 먼저 생각합니다.</p><ul class="bullet-list"><li>어떤 테이블의 한 행을 기준으로 세고 있는가?</li><li>포함되어야 할 대상이 빠지지 않았는가?</li><li>JOIN으로 같은 대상이 여러 번 나타나지 않았는가?</li><li>COUNT(*)가 실제로 세려는 대상을 계산하는가?</li><li>상태·기간·탈퇴 같은 업무 필터가 필요한가?</li></ul>`,
      s: `이 장표는 SQL 결과를 볼 때 사용할 검증 질문입니다.

첫째, 어떤 테이블의 한 행을 기준으로 세는지 확인합니다. 둘째, 포함되어야 할 대상이 빠지지 않았는지 봅니다. 셋째, JOIN 때문에 같은 대상이 여러 번 계산되지 않았는지 확인합니다.

넷째, COUNT(*)가 실제로 세려는 대상을 세는지 봅니다. 다섯째, 상태, 기간, 탈퇴 여부 같은 업무 필터가 필요한지 확인합니다. 이 질문들은 이후 장에서도 계속 사용합니다.`
    },
    {
      k: "MAIN EXAMPLE",
      l: "책의 주 예제",
      t: "온라인 강의 수강신청 구조도 검토해야 합니다",
      h: `${exampleCourse}<h2>온라인 강의 수강신청 구조도<br>검토해야 합니다</h2><p class="body-text">AI가 한 테이블에 모든 정보를 넣어 주면 처음에는 편해 보일 수 있습니다.</p><pre><code>CREATE TABLE enrollments (
    id INTEGER PRIMARY KEY,
    student_name VARCHAR(50),
    course_title VARCHAR(100),
    instructor_name VARCHAR(50),
    recorded_amount INTEGER
);</code></pre>`,
      s: `이번에는 책의 주 예제인 온라인 강의 수강신청으로 넘어갑니다.

AI가 수강신청 테이블 하나에 학생 이름, 강의 제목, 강사 이름, 금액을 모두 넣어 줄 수 있습니다. 처음에는 필요한 정보가 한 곳에 있으니 편해 보입니다.

하지만 데이터베이스 설계에서는 편해 보이는 한 테이블이 나중에 중복과 수정 오류를 만들 수 있습니다.`
    },
    {
      k: "BAD STRUCTURE",
      l: "구조 문제",
      t: "하나의 테이블에 섞으면 문제가 커집니다",
      h: `<h2>하나의 테이블에 섞으면<br>문제가 커집니다</h2><div class="grid-2"><article class="card"><h3>식별자 부족</h3><p class="small">이름과 제목만으로 학생·강의·강사를 안정적으로 구분하기 어렵습니다.</p></article><article class="card"><h3>반복 정보</h3><p class="small">같은 강의 제목과 강사 이름이 여러 행에 반복됩니다.</p></article><article class="card"><h3>수정 오류</h3><p class="small">일부 행만 바뀌면 같은 강의가 서로 다른 이름으로 남을 수 있습니다.</p></article><article class="card emphasis"><h3>규칙 부족</h3><p class="small">필수값, 허용 상태, 진행 중 중복 신청을 제한하기 어렵습니다.</p></article></div>`,
      s: `이 장표에서는 한 테이블 구조의 문제를 봅니다.

이름과 제목은 안정적인 식별자가 아닙니다. 같은 이름이 있을 수 있고 나중에 바뀔 수도 있습니다. 또 같은 강의를 여러 학생이 신청하면 강의 제목과 강사 이름이 계속 반복됩니다.

수정할 때도 문제가 생깁니다. 일부 행만 고치면 같은 강의인데 서로 다른 제목이 남을 수 있습니다. 그래서 성격이 다른 데이터는 분리하고, 식별자와 관계로 연결해야 합니다.`
    },
    {
      k: "AMOUNT MEANING",
      l: "금액의 의미",
      t: "신청 당시 기록 금액과 실제 매출은 다릅니다",
      h: `<h2>신청 당시 기록 금액과<br>실제 매출은 다릅니다</h2><p class="body-text">recorded_amount는 신청 시점에 기록한 금액입니다.</p><div class="grid-3"><article class="card emphasis"><h3>recorded_amount</h3><p class="small">신청 당시 기록 금액</p></article><article class="card"><h3>결제 완료 금액</h3><p class="small">결제 상태와 시각이 필요</p></article><article class="card"><h3>환불 반영 순금액</h3><p class="small">환불 이력과 원장이 필요</p></article></div>`,
      s: `이번 장표의 핵심은 금액 이름입니다.

recorded_amount는 신청 당시 기록한 금액입니다. 이 값만 보고 실제 결제가 완료되었다거나 회계 매출이라고 말하면 안 됩니다.

결제 성공, 실패, 환불을 분석하려면 별도의 결제 구조와 상태가 필요합니다. 그래서 데이터베이스에서는 컬럼 이름과 지표의 의미를 정확하게 구분해야 합니다.`
    },
    {
      k: "DATA QUALITY",
      l: "잘못된 데이터의 파급",
      t: "잘못된 데이터와 조회 기준은 AI 분석 오류로 이어집니다",
      h: `<h2>잘못된 데이터와 조회 기준은<br>AI 분석 오류로 이어집니다</h2><div class="flow"><div class="flow-step">데이터·조회 기준 문제</div><div class="flow-arrow">→</div><div class="flow-step">잘못된 SQL 결과</div><div class="flow-arrow">→</div><div class="flow-step">잘못된 AI 분석</div><div class="flow-arrow">→</div><div class="flow-step">잘못된 의사결정</div></div>`,
      s: `이번 장표는 오류가 어떻게 전파되는지를 보여 줍니다.

데이터가 중복되어 있거나, JOIN 조건이 잘못되었거나, 취소 데이터를 제외하지 않으면 SQL 결과가 틀어질 수 있습니다. AI가 그 결과를 바탕으로 설명하면 분석도 틀어집니다.

결국 잘못된 의사결정으로 이어질 수 있습니다. 그래서 AI 답변을 검토하려면 먼저 데이터와 조회 기준을 확인해야 합니다.`
    },
    {
      k: "NULL",
      l: "NULL과 0",
      t: "NULL을 0으로 바꾸는 것이 항상 맞는 것은 아닙니다",
      h: `<h2>NULL을 0으로 바꾸는 것이<br>항상 맞는 것은 아닙니다</h2><p class="body-text">NULL은 값이 알려지지 않았거나, 아직 입력되지 않았거나, 해당되지 않는 상태일 수 있습니다. 0은 실제 숫자 값입니다.</p><div class="grid-2"><article class="card"><h3>할인 금액 = 0원</h3><p class="small">할인이 없다는 실제 값일 수 있습니다.</p></article><article class="card emphasis"><h3>완료일 = NULL</h3><p class="small">아직 완료되지 않아 완료일이 없는 상태일 수 있습니다.</p></article></div>`,
      s: `이번 장표는 NULL과 0의 차이입니다.

NULL은 값이 알려지지 않았거나, 아직 입력되지 않았거나, 해당되지 않는 상태를 나타낼 수 있습니다. 반면 0은 실제로 저장된 숫자 값입니다.

예를 들어 할인 금액 0원은 할인이 없다는 실제 값일 수 있습니다. 하지만 완료일이 NULL이라는 것은 아직 완료되지 않았다는 뜻일 수 있습니다. 두 값을 확인 없이 바꾸면 분석 결과가 틀어질 수 있습니다.`
    },
    {
      k: "REAL WORLD",
      l: "현실의 관계",
      t: "현실의 업무는 데이터와 관계로 표현됩니다",
      h: `${exampleAiService}<h2>현실의 업무는<br>데이터와 관계로 표현됩니다</h2><p class="body-text">서비스는 하나의 표가 아니라 여러 대상과 관계로 구성됩니다.</p><div class="flow"><div class="flow-step">학생</div><div class="flow-arrow">→</div><div class="flow-step">질문</div><div class="flow-arrow">→</div><div class="flow-step">답변</div><div class="flow-arrow">→</div><div class="flow-step">튜터</div></div>`,
      s: `이번 장표는 확장 예제인 AI 튜터링 서비스입니다.

학생은 질문을 작성하고, 질문에는 답변이 달릴 수 있으며, 답변은 튜터와 연결됩니다. 이처럼 현실의 서비스는 하나의 데이터가 아니라 여러 대상과 관계로 구성됩니다.

데이터베이스 설계는 이런 업무 문장을 데이터 항목, 관계, 테이블과 제약조건으로 바꾸는 작업입니다.`
    },
    {
      k: "AI SERVICE",
      l: "운영 데이터",
      t: "운영되는 AI 서비스도 데이터를 관리해야 합니다",
      h: `<h2>운영되는 AI 서비스도<br>데이터를 관리해야 합니다</h2><p class="body-text">화면에 보이는 답변 외에도 사용자, 권한, 상태, 실행 이력과 검토 기록이 필요합니다.</p><div class="grid-2"><article class="card"><h3>사용자와 권한</h3><p class="small">누가 어떤 기능을 사용할 수 있는가</p></article><article class="card"><h3>작업 상태</h3><p class="small">요청 대기, 처리 중, 완료, 실패</p></article><article class="card"><h3>AI 실행 맥락</h3><p class="small">모델, 입력 기준 시점, 지시문 버전</p></article><article class="card emphasis"><h3>검토 기록</h3><p class="small">누가 승인하고 수정했는가</p></article></div>`,
      s: `AI 서비스가 실제로 운영되려면 답변만 저장해서는 부족합니다.

누가 기능을 실행할 수 있는지, 어떤 데이터에 접근할 수 있는지, 요청이 처리 중인지 실패했는지, 어떤 모델과 입력 기준 시점으로 결과가 만들어졌는지 기록해야 합니다.

또한 AI 결과를 누가 검토하고 승인했는지도 남겨야 합니다. 그래야 나중에 오류 원인을 추적하고 필요한 경우 복구할 수 있습니다.`
    },
    {
      k: "NON-DEVELOPERS",
      l: "비전공자 관점",
      t: "데이터베이스는 개발자만의 기술이 아닙니다",
      h: `<h2>데이터베이스는<br>개발자만의 기술이 아닙니다</h2><p class="body-text">데이터를 이용하는 사람은 숫자의 근거를 확인할 수 있어야 합니다.</p><div class="table-wrap"><table><thead><tr><th>역할</th><th>확인해야 할 일</th></tr></thead><tbody><tr><td>기획자</td><td>업무 요구사항과 데이터 관계</td></tr><tr><td>운영자</td><td>누락, 중복, 상태 오류</td></tr><tr><td>분석가</td><td>JOIN, 집계 기준, NULL 처리</td></tr><tr><td>관리자</td><td>AI 보고서와 대시보드 숫자의 근거</td></tr></tbody></table></div>`,
      s: `데이터베이스는 개발자만 사용하는 기술이 아닙니다.

기획자는 업무 요구사항과 데이터 관계를 정의해야 하고, 운영자는 누락과 중복, 상태 오류를 확인해야 합니다. 분석가는 JOIN, 집계 기준, NULL 처리를 검토해야 합니다. 관리자는 AI 보고서와 대시보드 숫자의 근거를 이해해야 합니다.

역할마다 필요한 깊이는 다르지만, 숫자가 어디에서 나왔는지 묻는 능력은 모두에게 필요합니다.`
    },
    {
      k: "STORAGE CHOICE",
      l: "저장 방식 선택",
      t: "모든 데이터를 처음부터 DBMS에 넣을 필요는 없습니다",
      h: `<h2>모든 데이터를 처음부터<br>DBMS에 넣을 필요는 없습니다</h2><p class="body-text">파일, 스프레드시트, DBMS는 데이터의 규모와 사용 목적에 따라 선택합니다.</p><div class="grid-3"><article class="card"><span class="number">1</span><h3>파일</h3><p class="small">개인 메모, 설정 파일, 단순 기록</p></article><article class="card"><span class="number">2</span><h3>스프레드시트</h3><p class="small">소규모 명단, 일정, 간단한 통계</p></article><article class="card emphasis"><span class="number">3</span><h3>DBMS</h3><p class="small">회원, 주문, 예약, 수강신청</p></article></div>`,
      s: `모든 데이터를 처음부터 DBMS에 넣을 필요는 없습니다.

파일은 개인 메모나 설정 파일처럼 작고 단순한 기록에 적합할 수 있습니다. 스프레드시트는 사람이 직접 보고 수정하는 소규모 명단이나 일정 관리에 편리합니다.

DBMS는 데이터가 계속 증가하고 서로 연결되며, 여러 사용자와 시스템이 함께 사용하고, 정확성·권한·복구가 중요할 때 검토합니다.`
    },
    {
      k: "WHEN DBMS",
      l: "검토 기준",
      t: "다음 조건이 많을수록 DBMS 중심 관리를 검토합니다",
      h: `<h2>다음 조건이 많을수록<br>DBMS 중심 관리를 검토합니다</h2><p class="body-text">도구 이름보다 관리 요구사항을 기준으로 판단합니다.</p><ul class="bullet-list"><li>데이터가 계속 증가하고 자주 변경된다.</li><li>여러 사용자가 동시에 접근한다.</li><li>데이터 사이의 관계가 중요하다.</li><li>검색과 집계가 반복적으로 필요하다.</li><li>정확성, 권한, 이력과 복구가 중요하다.</li><li>웹이나 앱에서 지속적으로 사용한다.</li></ul>`,
      s: `이번 장표에서는 DBMS가 필요한 가능성을 판단하는 기준을 봅니다.

데이터가 계속 늘어나고 자주 변경된다면 DBMS를 검토해야 합니다. 여러 사용자가 동시에 접근하거나, 데이터 사이의 관계가 중요하거나, 검색과 집계를 반복한다면 DBMS가 더 적합할 가능성이 높습니다.

다만 이것은 절대 규칙이 아닙니다. SQLite처럼 파일 하나로 사용하는 DBMS도 있고, 클라우드 스프레드시트처럼 공동 편집이 가능한 도구도 있습니다. 중요한 것은 도구 이름이 아니라 관리 요구사항입니다.`
    },
    {
      k: "DATA TYPES",
      l: "기준·파생·AI 결과",
      t: "기준 데이터, 파생 데이터, AI 결과를 구분합니다",
      h: `<h2>기준 데이터, 파생 데이터,<br>AI 결과를 구분합니다</h2><div class="grid-3"><article class="card emphasis"><h3>기준 데이터</h3><p class="small">업무 판단의 근거가 되는 원본</p></article><article class="card"><h3>결정적 파생 데이터</h3><p class="small">같은 원본·계산식·시점이면 다시 만들 수 있는 결과</p></article><article class="card"><h3>AI 생성 결과</h3><p class="small">모델·입력·지시문·조건에 따라 달라질 수 있는 결과</p></article></div>`,
      s: `데이터를 관리할 때는 세 가지를 구분해야 합니다.

기준 데이터는 업무 판단의 근거가 되는 원본입니다. 주문, 신청, 결제 원장 같은 데이터입니다. 결정적 파생 데이터는 같은 원본, 계산식, 기준 시점이 있으면 다시 만들 수 있는 월별 집계나 일부 캐시입니다.

AI 생성 결과는 모델, 입력 데이터, 지시문, 실행 조건에 따라 달라질 수 있습니다. 그래서 실행 맥락과 승인 상태를 별도로 기록해야 합니다.`
    },
    {
      k: "CACHE AND AI",
      l: "재생성과 보존",
      t: "모든 캐시와 AI 결과를 같은 방식으로 보지 않습니다",
      h: `<h2>모든 캐시와 AI 결과를<br>같은 방식으로 보지 않습니다</h2><div class="grid-2"><article class="card"><h3>캐시</h3><p class="small">같은 원본·계산 규칙·기준 시점으로 다시 만들 수 있을 때 파생 데이터로 봅니다.</p></article><article class="card emphasis"><h3>승인된 AI 결과</h3><p class="small">사람이 승인해 업무에 사용했다면 보존해야 할 업무 기록이 될 수 있습니다.</p></article></div>`,
      s: `이번 장표에서는 조금 더 세밀한 구분을 합니다.

캐시라고 해서 모두 자동으로 같은 의미는 아닙니다. 같은 원본, 계산 규칙, 기준 시점으로 다시 만들 수 있는 캐시는 파생 데이터로 볼 수 있습니다.

반면 AI 결과는 동일한 문장으로 완전히 재생성된다고 보장하기 어렵습니다. 특히 사람이 승인해서 실제 업무에 사용한 AI 결과는 단순 임시 결과가 아니라 보존해야 할 업무 기록이 될 수 있습니다.`
    },
    {
      k: "AI REVIEW CYCLE",
      l: "검증 사이클",
      t: "AI 결과는 실행 전 예상과 실행 후 비교로 검증합니다",
      h: `<h2>AI 결과는 실행 전 예상과<br>실행 후 비교로 검증합니다</h2><div class="flow"><div class="flow-step">질문·요구사항</div><div class="flow-arrow">→</div><div class="flow-step">테이블·컬럼 확인</div><div class="flow-arrow">→</div><div class="flow-step">예상 결과</div><div class="flow-arrow">→</div><div class="flow-step">실행 결과 비교</div><div class="flow-arrow">→</div><div class="flow-step">근거 기록</div></div>`,
      s: `AI가 만든 결과는 검증 사이클로 확인합니다.

먼저 해결하려는 질문과 요구사항을 확인합니다. 다음으로 실제 테이블과 컬럼을 확인합니다. 그리고 실행 전에 예상 결과를 적어 봅니다.

그다음 PostgreSQL에서 실행하고, 예상 결과와 실제 결과를 비교합니다. 마지막으로 어떤 이유로 수정했는지, 어떤 결과를 확인했는지 기록합니다. 이 흐름이 책 전체의 기본 학습 방식입니다.`
    },
    {
      k: "ACTIVITY",
      l: "직접 판단해 보기",
      t: "온라인 강의 서비스에는 어떤 저장 방식이 적절할까요?",
      h: `${exampleCourse}<h2>온라인 강의 서비스에는<br>어떤 저장 방식이 적절할까요?</h2><div class="activity-box"><ul><li>학생이 여러 강의를 신청합니다.</li><li>운영자는 학생·강사·강의와 신청 상태를 관리합니다.</li><li>학생별 신청 이력과 월별 신청 건수를 반복 조회합니다.</li><li>신청 당시 기록 금액을 보존합니다.</li><li>결제·환불 기능은 이후 확장할 수 있습니다.</li></ul></div>`,
      s: `이제 직접 판단해 보겠습니다.

온라인 강의 서비스에서 학생은 여러 강의를 신청할 수 있고, 운영자는 학생, 강사, 강의, 신청 상태를 관리합니다. 학생별 신청 이력과 월별 신청 건수도 반복 조회합니다.

이 경우 단순 파일이나 스프레드시트만으로 충분할까요? 관계, 반복 조회, 상태 관리, 이력 보존이 중요하므로 관계형 DBMS 중심 관리를 검토하는 것이 적절합니다.`
    },
    {
      k: "MISUNDERSTANDINGS",
      l: "자주 하는 오해",
      t: "첫 장에서 바로잡을 오해들입니다",
      h: `<h2>첫 장에서 바로잡을<br>오해들입니다</h2><ul class="bullet-list"><li>데이터가 많아야만 데이터베이스가 필요하다.</li><li>스프레드시트와 데이터베이스는 크기만 다르다.</li><li>SQL이 실행되면 결과도 맞다.</li><li>데이터 분석은 Python에서만 한다.</li><li>처음부터 완벽한 구조를 만들어야 한다.</li></ul>`,
      s: `1장에서 바로잡을 오해를 정리해 보겠습니다.

데이터가 많아야만 데이터베이스가 필요한 것은 아닙니다. 데이터가 적어도 관계, 정확성, 권한, 이력이 중요하면 DBMS가 필요할 수 있습니다.

SQL이 실행된다고 결과가 맞는 것도 아닙니다. 또한 분석은 Python에서만 하는 것이 아니라 SQL에서도 필터, JOIN, 집계와 데이터 품질 확인을 할 수 있습니다. 처음부터 완벽한 구조를 만들기보다, 요구사항과 검증 근거를 따라 확장하는 것이 중요합니다.`
    },
    {
      k: "SUMMARY",
      l: "핵심 정리",
      t: "AI가 도와줄수록 검증 능력이 더 중요해집니다",
      h: `<h2>AI가 도와줄수록<br>검증 능력이 더 중요해집니다</h2><div class="quote" style="font-size:38px">AI가 데이터베이스 작업을 더 많이 도와줄수록,<br>사람에게는 데이터 구조와 결과를 이해하고 검증하는 능력이 더 중요해집니다.</div><div class="chips" style="margin-top:24px"><span class="chip">요구사항</span><span class="chip">데이터 관계</span><span class="chip">결과 검증</span><span class="chip">저장 방식</span><span class="chip">근거 기록</span></div>`,
      s: `마지막으로 1장의 핵심을 정리합니다.

AI는 테이블과 SQL 초안을 빠르게 만들 수 있습니다. 그러나 업무 규칙, 데이터 의미, 결과 정확성은 사람이 검증해야 합니다.

SQL이 실행되는 것과 결과가 올바른 것은 다릅니다. 데이터베이스를 배우는 이유는 모든 SQL을 혼자 암기하기 위해서가 아니라, AI가 만든 구조와 결과를 이해하고 실제 요구사항에 맞는지 검증하기 위해서입니다.`
    },
    {
      k: "NEXT CHAPTER",
      l: "다음 장",
      t: "다음 장에서는 기본 용어를 정확히 정리합니다",
      h: `<h2>다음 장에서는<br>기본 용어를 정확히 정리합니다</h2><p class="body-text">데이터, 데이터베이스, DBMS의 차이와 PostgreSQL 서버·데이터베이스·스키마·테이블·행·열의 계층을 배웁니다.</p><div class="flow"><div class="flow-step">데이터</div><div class="flow-arrow">→</div><div class="flow-step">데이터베이스</div><div class="flow-arrow">→</div><div class="flow-step">DBMS</div><div class="flow-arrow">→</div><div class="flow-step">PostgreSQL 계층</div></div>`,
      s: `다음 장에서는 기본 용어를 정확히 정리합니다.

데이터, 데이터베이스, DBMS가 어떻게 다른지 살펴보고, PostgreSQL 서버, 데이터베이스, 스키마, 테이블, 행과 열이 어떤 계층으로 연결되는지 배웁니다.

오늘 배운 검증 관점을 바탕으로, 다음 장부터는 실제 데이터베이스의 구성 요소를 하나씩 익혀 가겠습니다.`
    }
  ];
})();