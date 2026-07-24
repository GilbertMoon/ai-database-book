window.CH2_SLIDES=window.CH2_SLIDES||[];
window.CH2_SLIDES.push(...[
  {
    "k": "CHAPTER 02",
    "l": "Course Position",
    "t": "데이터와 DBMS의 기본 개념",
    "h": "<h1>데이터와 DBMS의<br>기본 개념</h1><p class=\"lead\">PostgreSQL 실습을 시작하기 전에 데이터베이스 구조와 공통 용어를 정확히 읽는 연습을 합니다.</p><div class=\"title-meta\"><span class=\"pill\">DBMS 구조</span><span class=\"pill\">테이블 읽기</span><span class=\"pill\">PK·FK 기초</span></div>",
    "s": "안녕하세요. 오늘은 2장, 데이터와 디비엠에스의 기본 개념을 공부합니다. 이번 장은 바로 포스트그레스큐엘을 설치하거나 디비버를 실행하는 시간이 아닙니다. 실제 설치와 연결은 다음 3장에서 진행합니다. 오늘의 목표는 실습을 시작하기 전에 꼭 알아야 할 기본 구조를 정확한 용어로 읽는 것입니다. 화면의 키워드처럼 디비엠에스 구조, 테이블 읽기, 기본키와 외래키의 기초를 중심으로 살펴보겠습니다."
  },
  {
    "k": "WHERE WE ARE",
    "l": "전체 과정 속 위치",
    "t": "2장은 설치 전 개념 정리 단계입니다",
    "h": "<h2>2장은 설치 전<br>개념 정리 단계입니다</h2><div class=\"flow\"><div class=\"flow-step done\">1장<br>왜 DB를 배우는가</div><div class=\"flow-arrow\">→</div><div class=\"flow-step current\">2장<br>기본 용어와 구조</div><div class=\"flow-arrow\">→</div><div class=\"flow-step\">3장<br>PostgreSQL·DBeaver 설치</div><div class=\"flow-arrow\">→</div><div class=\"flow-step\">4장<br>SQL 실행</div></div>",
    "s": "먼저 전체 과정에서 2장의 위치를 확인하겠습니다. 1장에서는 에이아이 시대에 왜 데이터베이스를 배워야 하는지 살펴보았습니다. 2장인 오늘은 데이터베이스 구조와 기본 용어를 정리합니다. 3장에서는 포스트그레스큐엘과 디비버를 설치하고 연결합니다. 4장부터는 실제 테이블을 만들고 에스큐엘을 실행합니다. 따라서 오늘은 도구 사용보다 구조 이해에 집중하면 됩니다."
  },
  {
    "k": "TODAY GOALS",
    "l": "학습 목표",
    "t": "오늘은 구조를 읽고 설명하는 것이 목표입니다",
    "h": "<h2>오늘은 구조를 읽고<br>설명하는 것이 목표입니다</h2><ul class=\"bullet-list\"><li>Data, Database, DBMS의 차이를 설명한다.</li><li>DBeaver와 PostgreSQL의 역할을 구분한다.</li><li>Server → Database → Schema → Table → Row·Column 구조를 읽는다.</li><li>PK와 FK가 어떤 역할을 하는지 설명한다.</li><li>AI가 만든 테이블 구조를 기본 용어로 검토한다.</li></ul>",
    "s": "오늘의 학습 목표입니다. 첫째, 데이터, 데이터베이스, 디비엠에스의 차이를 설명합니다. 둘째, 디비버와 포스트그레스큐엘의 역할을 구분합니다. 셋째, 서버에서 데이터베이스, 스키마, 테이블, 행과 열로 이어지는 구조를 읽습니다. 넷째, 기본키와 외래키의 역할을 설명합니다. 다섯째, 에이아이가 만든 테이블 구조를 기본 용어로 검토합니다."
  },
  {
    "k": "NOT YET PRACTICE",
    "l": "실습 안내",
    "t": "2장에서는 설치 실습을 하지 않습니다",
    "h": "<h2>2장에서는<br>설치 실습을 하지 않습니다</h2><div class=\"grid-2\"><article class=\"card\"><h3>오늘</h3><p>용어와 구조를 화면 중심으로 이해합니다.</p></article><article class=\"card emphasis\"><h3>다음 장</h3><p>PostgreSQL 설치, DBeaver 연결, 작업용 데이터베이스 생성을 직접 진행합니다.</p></article></div>",
    "s": "2장에서는 설치 실습을 하지 않습니다. 오늘은 화면에 보이는 구조와 용어를 중심으로 이해합니다. 포스트그레스큐엘 설치, 디비버 연결, 작업용 데이터베이스 생성은 다음 3장에서 직접 진행합니다. 그래서 오늘 수업에서는 설치 화면을 따라 하기보다, 다음 장에서 어떤 화면을 보게 될지 미리 이해하는 정도로 생각하면 됩니다."
  },
  {
    "k": "CHAPTER FLOW",
    "l": "이 장의 흐름",
    "t": "2장에서 살펴볼 큰 흐름",
    "h": "<h2>2장에서 살펴볼 큰 흐름</h2><div class=\"flow\"><div class=\"flow-step\">Data<br>Database<br>DBMS</div><div class=\"flow-arrow\">→</div><div class=\"flow-step\">Client<br>Server</div><div class=\"flow-arrow\">→</div><div class=\"flow-step\">Schema<br>Table</div><div class=\"flow-arrow\">→</div><div class=\"flow-step\">Row<br>Column<br>Cell</div><div class=\"flow-arrow\">→</div><div class=\"flow-step\">PK<br>FK<br>CRUD</div></div>",
    "s": "2장의 큰 흐름입니다. 먼저 데이터, 데이터베이스, 디비엠에스의 차이를 봅니다. 다음으로 클라이언트와 서버 구조를 봅니다. 그다음 포스트그레스큐엘의 데이터베이스, 스키마, 테이블 구조를 살펴봅니다. 이후 테이블 안의 행, 열, 셀을 읽고, 마지막으로 기본키, 외래키, 크러드와 에스큐엘의 의미를 미리 확인합니다."
  },
  {
    "k": "CORE HIERARCHY",
    "l": "핵심 계층",
    "t": "데이터베이스 구조는 계층으로 이해합니다",
    "h": "<h2>데이터베이스 구조는<br>계층으로 이해합니다</h2><div class=\"hierarchy\"><div>사용자</div><div>DBeaver 같은 Client</div><div>PostgreSQL DBMS</div><div>Database</div><div>Schema</div><div>Table</div><div>Row · Column</div></div>",
    "s": "오늘 가장 먼저 기억할 구조입니다. 사용자는 디비버 같은 클라이언트 도구에서 에스큐엘을 작성합니다. 디비버는 포스트그레스큐엘 디비엠에스에 명령을 전달합니다. 포스트그레스큐엘 안에는 데이터베이스가 있고, 데이터베이스 안에는 스키마가 있으며, 스키마 안에는 테이블이 있습니다. 테이블은 행과 열로 구성됩니다. 이 계층을 이해하면 오류 메시지나 연결 설정을 훨씬 쉽게 해석할 수 있습니다."
  },
  {
    "k": "EXAMPLE DOMAIN",
    "l": "온라인 강의 예시",
    "t": "온라인 강의 서비스에는 어떤 데이터가 필요할까요?",
    "h": "<h2>온라인 강의 서비스에는<br>어떤 데이터가 필요할까요?</h2><div class=\"grid-3\"><article class=\"card\"><span class=\"number\">1</span><h3>학생</h3><p>누가 신청하는가</p></article><article class=\"card\"><span class=\"number\">2</span><h3>강사</h3><p>누가 강의하는가</p></article><article class=\"card\"><span class=\"number\">3</span><h3>강의</h3><p>무엇을 신청하는가</p></article><article class=\"card\"><span class=\"number\">4</span><h3>수강신청</h3><p>누가 무엇을 신청했는가</p></article><article class=\"card emphasis\"><span class=\"number\">5</span><h3>신청 당시 금액</h3><p>그 시점에 기록된 금액</p></article></div>",
    "s": "온라인 강의 서비스를 예로 들어 보겠습니다. 기본적으로 학생, 강사, 강의, 수강신청 데이터가 필요합니다. 여기에 신청 당시 기록 금액이 들어갈 수 있습니다. 중요한 점은 신청 당시 기록 금액이 실제 결제 완료 금액이나 회계 매출과 자동으로 같은 의미는 아니라는 것입니다. 데이터베이스를 읽을 때는 값의 이름뿐 아니라 그 값이 업무에서 어떤 의미인지 함께 확인해야 합니다."
  },
  {
    "k": "DATABASE IDEA",
    "l": "데이터베이스 안의 구성",
    "t": "관계형 데이터베이스는 나누어 저장하고 연결합니다",
    "h": "<h2>관계형 데이터베이스는<br>나누어 저장하고 연결합니다</h2><div class=\"grid-2\"><article class=\"card\"><h3>Table</h3><p>같은 성격의 데이터를 행과 열로 정리합니다.</p></article><article class=\"card\"><h3>Key</h3><p>행을 구분하고 다른 테이블과 연결합니다.</p></article><article class=\"card\"><h3>Constraint</h3><p>잘못된 값과 잘못된 참조를 줄입니다.</p></article><article class=\"card\"><h3>SQL</h3><p>구조화된 데이터를 조회하고 변경합니다.</p></article></div>",
    "s": "관계형 데이터베이스는 모든 정보를 하나의 큰 표에 넣는 방식이 아닙니다. 같은 성격의 데이터를 테이블로 나누어 저장합니다. 키를 사용해 행을 구분하고 다른 테이블과 연결합니다. 제약조건을 사용해 잘못된 값과 잘못된 참조를 줄입니다. 그리고 에스큐엘을 사용해 필요한 데이터를 조회하고 변경합니다."
  },
  {
    "k": "DATA",
    "l": "데이터란 무엇인가",
    "t": "Data는 기록된 값이나 사실입니다",
    "h": "<h2>Data는 기록된<br>값이나 사실입니다</h2><div class=\"table-wrap\"><table><thead><tr><th>Data 예시</th><th>나타내는 의미</th></tr></thead><tbody><tr><td>김민지</td><td>학생 이름</td></tr><tr><td>20260001</td><td>학교 업무에서 사용하는 학번</td></tr><tr><td>데이터베이스 입문</td><td>강의 제목</td></tr><tr><td>2026-03-02</td><td>수강신청일</td></tr><tr><td>50000</td><td>신청 당시 기록 금액</td></tr></tbody></table></div>",
    "s": "데이터는 기록된 값이나 사실입니다. 화면의 예를 보겠습니다. 김민지는 학생 이름입니다. 이천이십육만일은 학교 업무에서 사용하는 학번입니다. 데이터베이스 입문은 강의 제목입니다. 이천이십육년 삼월 이일은 수강신청일입니다. 오만은 신청 당시 기록 금액입니다. 같은 숫자처럼 보여도 어떤 업무 의미를 갖는지에 따라 저장 방식과 해석이 달라집니다."
  },
  {
    "k": "ID VS BUSINESS ID",
    "l": "식별자 구분",
    "t": "id와 student_number는 역할이 다릅니다",
    "h": "<h2>id와 student_number는<br>역할이 다릅니다</h2><div class=\"grid-2\"><article class=\"card\"><h3>id = 1</h3><p>Database 내부에서 학생 행을 안정적으로 구분하는 식별자</p></article><article class=\"card emphasis\"><h3>student_number = 20260001</h3><p>학교 업무에서 부여한 업무 식별자</p></article></div>",
    "s": "아이디와 학번은 모두 학생을 구분하는 데 쓰일 수 있지만 역할이 다릅니다. 아이디는 데이터베이스 내부에서 학생 행을 안정적으로 구분하기 위한 식별자입니다. 스튜던트 넘버, 즉 학번은 학교 업무에서 부여한 업무 식별자입니다. 학번은 정책에 따라 형식이 바뀌거나 재발급 규칙이 생길 수 있습니다. 그래서 내부 식별자와 업무 식별자를 구분하는 습관이 중요합니다."
  },
  {
    "k": "FACT",
    "l": "값이 모이면 사실",
    "t": "여러 값이 연결되면 하나의 업무 사실이 됩니다",
    "h": "<h2>여러 값이 연결되면<br>하나의 업무 사실이 됩니다</h2><div class=\"quote\">학번 20260001인 김민지 학생이<br>2026년 3월 2일에<br>데이터베이스 입문 강의를 신청했고<br>신청 상태는 신청이다.</div>",
    "s": "여러 값이 연결되면 하나의 업무 사실이 됩니다. 화면의 문장을 읽어 보겠습니다. 학번 이천이십육만일인 김민지 학생이, 이천이십육년 삼월 이일에, 데이터베이스 입문 강의를 신청했고, 신청 상태는 신청이다. 이렇게 여러 값이 연결되어 하나의 업무 사실을 표현합니다. 데이터베이스는 이런 업무 사실을 안정적으로 저장하고 조회하기 위한 구조입니다."
  },
  {
    "k": "DATABASE VS DBMS",
    "l": "세 용어 구분",
    "t": "Data, Database, DBMS를 구분합니다",
    "h": "<h2>Data, Database, DBMS를<br>구분합니다</h2><div class=\"table-wrap\"><table><thead><tr><th>구분</th><th>의미</th><th>예시</th></tr></thead><tbody><tr><td>Data</td><td>기록된 개별 값이나 사실</td><td>학생 이름, 학번, 신청일</td></tr><tr><td>Database</td><td>관련 데이터가 저장되는 논리적 공간</td><td>ai_database_book</td></tr><tr><td>DBMS</td><td>Database를 관리하고 SQL을 실행하는 소프트웨어</td><td>PostgreSQL</td></tr></tbody></table></div>",
    "s": "데이터, 데이터베이스, 디비엠에스를 구분해 보겠습니다. 데이터는 기록된 개별 값이나 사실입니다. 학생 이름, 학번, 신청일이 예입니다. 데이터베이스는 관련 데이터가 저장되는 논리적 공간입니다. 이 책에서는 에이아이 데이터베이스 북이라는 이름의 데이터베이스를 사용합니다. 디비엠에스는 데이터베이스를 관리하고 에스큐엘을 실행하는 소프트웨어입니다. 포스트그레스큐엘이 대표적인 예입니다."
  },
  {
    "k": "DBMS ROLE",
    "l": "DBMS 역할",
    "t": "DBMS는 저장소 이상의 역할을 합니다",
    "h": "<h2>DBMS는 저장소 이상의<br>역할을 합니다</h2><div class=\"grid-3\"><article class=\"card\"><h3>저장</h3><p>데이터 보관</p></article><article class=\"card\"><h3>조회</h3><p>조건 검색</p></article><article class=\"card\"><h3>규칙 적용</h3><p>제약조건</p></article><article class=\"card\"><h3>동시 처리</h3><p>여러 사용자 조정</p></article><article class=\"card\"><h3>권한</h3><p>사용자별 접근 제어</p></article><article class=\"card\"><h3>복구</h3><p>백업과 장애 대응</p></article></div>",
    "s": "디비엠에스는 단순히 데이터를 저장하는 프로그램이 아닙니다. 데이터를 일정한 구조로 저장하고, 조건에 맞게 조회하며, 제약조건에 따라 잘못된 값을 제한합니다. 여러 사용자가 동시에 작업할 때 충돌을 조정하고, 사용자와 역할에 따라 접근 권한을 관리합니다. 또한 백업과 장애 복구에 필요한 기능도 제공합니다. 이런 기능들이 데이터베이스를 안전하게 운영하는 기반이 됩니다."
  },
  {
    "k": "CLIENT SERVER",
    "l": "Client와 Server",
    "t": "DBeaver는 Client, PostgreSQL은 DBMS입니다",
    "h": "<h2>DBeaver는 Client,<br>PostgreSQL은 DBMS입니다</h2><div class=\"grid-2\"><article class=\"card\"><h3>DBeaver</h3><p>SQL을 작성하고 결과를 보는 Client 도구</p></article><article class=\"card emphasis\"><h3>PostgreSQL</h3><p>데이터를 저장하고 SQL을 실행하는 DBMS</p></article></div>",
    "s": "디비버와 포스트그레스큐엘은 역할이 다릅니다. 디비버는 에스큐엘을 작성하고 결과를 보는 클라이언트 도구입니다. 포스트그레스큐엘은 데이터를 저장하고 에스큐엘을 실행하는 디비엠에스입니다. 디비버를 설치했다고 해서 데이터베이스가 설치되는 것은 아닙니다. 반대로 디비버를 종료해도 포스트그레스큐엘 서버와 저장소가 정상이라면 데이터는 유지됩니다."
  },
  {
    "k": "CONNECTION FLOW",
    "l": "연결 흐름",
    "t": "SQL은 Client에서 DBMS로 전달됩니다",
    "h": "<h2>SQL은 Client에서<br>DBMS로 전달됩니다</h2><div class=\"flow\"><div class=\"flow-step\">사용자<br>SQL 작성</div><div class=\"flow-arrow\">→</div><div class=\"flow-step\">DBeaver<br>SQL 전달</div><div class=\"flow-arrow\">→</div><div class=\"flow-step\">PostgreSQL<br>SQL 실행</div><div class=\"flow-arrow\">→</div><div class=\"flow-step\">결과·오류<br>반환</div></div>",
    "s": "에스큐엘이 실행되는 흐름을 보겠습니다. 사용자가 디비버에서 에스큐엘을 작성합니다. 디비버는 그 에스큐엘을 포스트그레스큐엘에 전달합니다. 포스트그레스큐엘은 에스큐엘을 실행하고 결과나 오류를 반환합니다. 디비버는 반환된 결과를 화면에 보여 줍니다. 오류가 발생했을 때는 디비버 문제인지, 연결 정보 문제인지, 포스트그레스큐엘 서버 문제인지 구분해야 합니다."
  },
  {
    "k": "POSTGRES STRUCTURE",
    "l": "PostgreSQL 기본 구조",
    "t": "PostgreSQL은 여러 계층으로 데이터를 관리합니다",
    "h": "<h2>PostgreSQL은 여러 계층으로<br>데이터를 관리합니다</h2><div class=\"hierarchy\"><div>PostgreSQL Server</div><div>Database</div><div>Schema</div><div>Table</div><div>Row</div><div>Column</div></div>",
    "s": "포스트그레스큐엘에서 데이터를 탐색할 때는 계층 구조를 이해해야 합니다. 가장 위에는 포스트그레스큐엘 서버가 있습니다. 서버 안에는 데이터베이스가 있습니다. 데이터베이스 안에는 스키마가 있고, 스키마 안에는 테이블이 있습니다. 테이블은 행과 열로 구성됩니다. 이 구조를 알아야 디비버 화면에서 원하는 테이블을 찾을 수 있습니다."
  },
  {
    "k": "BOOK STRUCTURE",
    "l": "이 책의 실습 구조",
    "t": "이 책에서는 구조가 단계적으로 만들어집니다",
    "h": "<h2>이 책에서는 구조가<br>단계적으로 만들어집니다</h2><div class=\"codebox\">PostgreSQL Server\n└── ai_database_book          Chapter 03\n    ├── public\n    │   └── students          Chapter 04\n    └── course_project        Chapter 07\n        ├── students\n        ├── instructors\n        ├── courses\n        └── enrollments</div>",
    "s": "이 책에서 사용할 구조는 단계적으로 만들어집니다. 3장에서는 에이아이 데이터베이스 북 데이터베이스를 만듭니다. 4장에서는 퍼블릭 스키마에 스튜던츠 테이블을 만듭니다. 7장에서는 코스 프로젝트 스키마에 학생, 강사, 강의, 수강신청 테이블을 구성합니다. 오늘 2장에서 보는 표는 개념 설명을 위한 축약 예제입니다."
  },
  {
    "k": "SERVER DATABASE SCHEMA",
    "l": "Server·Database·Schema",
    "t": "Server, Database, Schema의 역할",
    "h": "<h2>Server, Database, Schema의<br>역할을 구분합니다</h2><div class=\"grid-3\"><article class=\"card\"><h3>Server</h3><p>PostgreSQL DBMS가 실행되는 환경</p></article><article class=\"card\"><h3>Database</h3><p>업무나 프로젝트별 데이터를 분리하는 논리적 공간</p></article><article class=\"card emphasis\"><h3>Schema</h3><p>Database 안에서 객체 이름을 구분하는 이름 공간</p></article></div>",
    "s": "서버, 데이터베이스, 스키마의 역할을 구분하겠습니다. 서버는 포스트그레스큐엘 디비엠에스가 실행되는 환경입니다. 데이터베이스는 업무나 프로젝트별 데이터를 분리하는 논리적 공간입니다. 스키마는 데이터베이스 안에서 테이블과 뷰 같은 객체를 이름으로 구분하는 이름 공간입니다. 특히 포스트그레스큐엘에서는 스키마 개념을 자주 만나게 됩니다."
  },
  {
    "k": "SCHEMA PATH",
    "l": "Schema와 search_path",
    "t": "students와 public.students는 상황에 따라 다르게 해석될 수 있습니다",
    "h": "<h2>students와 public.students는<br>상황에 따라 다르게 해석될 수 있습니다</h2><div class=\"grid-2\"><article class=\"card\"><h3>students</h3><p>현재 search_path 기준으로 찾는 이름</p></article><article class=\"card emphasis\"><h3>public.students</h3><p>public Schema의 students Table을 명시</p></article></div><pre><code>SELECT current_database();\nSELECT current_schema();\nSHOW search_path;</code></pre>",
    "s": "스키마 이름을 생략하면 현재 검색 경로, 즉 서치 패스에 따라 테이블을 찾습니다. 스튜던츠라고만 쓰면 현재 서치 패스에서 스튜던츠라는 이름을 찾습니다. 퍼블릭 점 스튜던츠라고 쓰면 퍼블릭 스키마의 스튜던츠 테이블을 분명하게 지정합니다. 현재 데이터베이스, 현재 스키마, 서치 패스는 화면의 에스큐엘로 확인할 수 있습니다. 실제 실행은 3장 이후에 진행합니다."
  },
  {
    "k": "DBEAVER TREE",
    "l": "DBeaver 화면에서 찾기",
    "t": "DBeaver에서는 계층을 따라 Table을 찾습니다",
    "h": "<h2>DBeaver에서는 계층을 따라<br>Table을 찾습니다</h2><div class=\"codebox\">Databases\n→ ai_database_book\n→ Schemas\n→ public\n→ Tables</div><p class=\"body-text\">버전과 연결 설정에 따라 일부 중간 항목의 표시 방식은 달라질 수 있습니다.</p>",
    "s": "디비버 화면에서는 보통 데이터베이스, 에이아이 데이터베이스 북, 스키마, 퍼블릭, 테이블 순서로 탐색합니다. 버전이나 연결 설정에 따라 중간 항목의 표시 방식은 조금 달라질 수 있습니다. 중요한 것은 화면 이름을 외우는 것이 아니라 계층 구조를 이해하는 것입니다. 어느 데이터베이스의 어느 스키마 안에 있는 테이블인지 확인하는 습관이 필요합니다."
  },
  {
    "k": "TABLE ROW COLUMN CELL",
    "l": "Table 읽기",
    "t": "Table은 Row와 Column으로 구성됩니다",
    "h": "<h2>Table은 Row와 Column으로<br>구성됩니다</h2><div class=\"table-wrap\"><table><thead><tr><th>id</th><th>name</th><th>email</th><th>major</th></tr></thead><tbody><tr><td>1</td><td>김민지</td><td>minji@example.com</td><td>컴퓨터공학</td></tr><tr><td>2</td><td>이준호</td><td>junho@example.com</td><td>데이터사이언스</td></tr><tr><td>3</td><td>박서연</td><td>seoyeon@example.com</td><td>경영학</td></tr></tbody></table></div>",
    "s": "테이블은 행과 열로 구성됩니다. 화면의 표 전체가 스튜던츠 테이블입니다. 가로 한 줄은 한 명의 학생 기록입니다. 세로 방향의 아이디, 네임, 이메일, 메이저는 열입니다. 특정 행과 특정 열이 만나는 하나의 값은 셀이라고 부를 수 있습니다. 에스큐엘에서는 화면 위치가 아니라 행을 찾는 조건과 열 이름을 사용해 값을 조회합니다."
  },
  {
    "k": "ROW MEANING",
    "l": "한 행의 의미",
    "t": "좋은 구조는 한 행의 의미가 분명합니다",
    "h": "<h2>좋은 구조는<br>한 행의 의미가 분명합니다</h2><div class=\"quote\">students 한 행 = 학생 한 명<br><br>enrollments 한 행 = 학생 한 명의 강의 신청 한 건</div>",
    "s": "좋은 데이터 구조의 출발점은 한 행이 무엇을 의미하는지 분명하게 정하는 것입니다. 스튜던츠 테이블의 한 행은 학생 한 명을 나타냅니다. 인롤먼츠 테이블의 한 행은 학생 한 명의 강의 신청 한 건을 나타냅니다. 한 행의 의미가 불분명하면 중복, 누락, 잘못된 집계 문제가 생기기 쉽습니다."
  }
]);
