window.CH2_SLIDES=window.CH2_SLIDES||[];
window.CH2_SLIDES.push(...[
  {
    "k": "ORDER BY",
    "l": "행 순서 주의",
    "t": "Row 순서는 자동으로 보장되지 않습니다",
    "h": "<h2>Row 순서는 자동으로<br>보장되지 않습니다</h2><div class=\"quote\">ORDER BY가 없으면<br>조회 결과의 행 순서를 가정하면 안 됩니다.</div><p class=\"body-text\">화면에 보이는 위치나 id 값만으로 항상 같은 표시 순서를 기대하지 않습니다.</p>",
    "s": "관계형 데이터베이스에서 행 순서는 자동으로 보장되지 않습니다. 오더 바이로 정렬 기준을 지정하지 않으면 조회 결과가 항상 같은 순서로 보인다고 가정하면 안 됩니다. 화면에 첫 번째로 보이는 행이 항상 같은 데이터라고 생각하면 위험합니다. 정렬이 필요하면 반드시 오더 바이를 사용해야 합니다. 실제 오더 바이 사용은 이후 에스큐엘 실습에서 다룹니다."
  },
  {
    "k": "COLUMN CELL TYPE",
    "l": "Column·Cell·Type",
    "t": "Column은 항목이고 Cell은 값입니다",
    "h": "<h2>Column은 항목이고<br>Cell은 값입니다</h2><div class=\"grid-3\"><article class=\"card\"><h3>Column</h3><p>기록을 구성하는 데이터 항목</p></article><article class=\"card\"><h3>Cell</h3><p>특정 Row와 Column이 만나는 값</p></article><article class=\"card emphasis\"><h3>Data Type</h3><p>저장할 값의 종류와 사용 방식</p></article></div>",
    "s": "열은 기록을 구성하는 데이터 항목입니다. 예를 들어 아이디, 이름, 이메일, 전공이 열입니다. 셀은 특정 행과 특정 열이 만나는 하나의 값입니다. 데이터 타입은 각 열에 저장할 값의 종류와 사용 방식을 나타냅니다. 숫자로 보이는 값이라도 계산 대상이 아니면 문자열로 저장할 수 있습니다. 학번이 대표적인 예입니다."
  },
  {
    "k": "DATA TYPE ACTIVITY",
    "l": "활동 1",
    "t": "다음 값의 Data Type을 어떻게 정할까요?",
    "h": "<h2>다음 값의 Data Type을<br>어떻게 정할까요?</h2><div class=\"table-wrap\"><table><thead><tr><th>값</th><th>가능한 판단</th></tr></thead><tbody><tr><td>20260001</td><td>학번이면 문자열 가능</td></tr><tr><td>50000</td><td>금액이면 정수 또는 숫자형</td></tr><tr><td>2026-03-02</td><td>날짜</td></tr><tr><td>true</td><td>불리언</td></tr></tbody></table></div>",
    "s": "짧은 활동입니다. 화면의 값을 보고 데이터 타입을 어떻게 정할지 생각해 보겠습니다. 이천이십육만일은 숫자처럼 보이지만 학번이라면 문자열로 저장할 수 있습니다. 오만은 금액이라면 정수나 숫자형이 적절합니다. 이천이십육년 삼월 이일은 날짜입니다. 트루는 참과 거짓을 나타내는 불리언입니다. 데이터 타입은 값의 모양뿐 아니라 업무에서 어떻게 사용하는지를 고려해 정합니다."
  },
  {
    "k": "RELATIONSHIP",
    "l": "관계 모델과 업무 관계",
    "t": "Relation과 Relationship을 구분합니다",
    "h": "<h2>Relation과 Relationship을<br>구분합니다</h2><div class=\"table-wrap\"><table><thead><tr><th>용어</th><th>의미</th></tr></thead><tbody><tr><td>Relation</td><td>관계 모델에서 행과 열로 구성된 Table에 가까운 구조</td></tr><tr><td>Relationship</td><td>학생·강의·주문처럼 업무 대상이 서로 연결되는 규칙</td></tr><tr><td>Cardinality</td><td>1:1, 1:N, N:M처럼 최대 연결 개수를 표현</td></tr></tbody></table></div>",
    "s": "관계형 데이터베이스의 릴레이션과 업무에서 말하는 관계, 즉 릴레이션십은 구분해서 이해하는 것이 좋습니다. 릴레이션은 관계 모델에서 행과 열로 구성된 테이블에 가까운 구조입니다. 릴레이션십은 학생이 강의를 신청한다처럼 업무 대상이 서로 연결되는 규칙입니다. 카디널리티는 일대일, 일대다, 다대다처럼 연결 가능한 최대 개수를 표현합니다."
  },
  {
    "k": "DOMAIN TABLES",
    "l": "업무를 Table로 나누기",
    "t": "업무 대상은 Table로 나누어 읽습니다",
    "h": "<h2>업무 대상은 Table로<br>나누어 읽습니다</h2><div class=\"table-wrap\"><table><thead><tr><th>Table</th><th>한 Row가 나타내는 것</th></tr></thead><tbody><tr><td>students</td><td>학생 한 명</td></tr><tr><td>courses</td><td>강의 한 개</td></tr><tr><td>enrollments</td><td>학생 한 명의 강의 신청 한 건</td></tr></tbody></table></div><div class=\"codebox smallcode\">students ← enrollments → courses</div>",
    "s": "온라인 강의 서비스를 테이블로 나누어 보겠습니다. 스튜던츠 테이블의 한 행은 학생 한 명입니다. 코시즈 테이블의 한 행은 강의 한 개입니다. 인롤먼츠 테이블의 한 행은 학생 한 명의 강의 신청 한 건입니다. 이처럼 각 테이블의 한 행이 무엇을 나타내는지 먼저 정하면 구조를 읽기 쉬워집니다. 인롤먼츠는 학생과 강의를 연결하는 역할을 합니다."
  },
  {
    "k": "CARDINALITY",
    "l": "Cardinality",
    "t": "1:1, 1:N, N:M 관계를 구분합니다",
    "h": "<h2>1:1, 1:N, N:M 관계를<br>구분합니다</h2><div class=\"grid-3\"><article class=\"card\"><h3>1:1</h3><p>한 행이 상대편 최대 한 행과 연결</p></article><article class=\"card\"><h3>1:N</h3><p>한 행이 상대편 여러 행과 연결</p></article><article class=\"card emphasis\"><h3>N:M</h3><p>양쪽 여러 행이 서로 연결</p></article></div>",
    "s": "카디널리티는 연결 가능한 최대 개수를 표현합니다. 일대일은 한 행이 상대편 최대 한 행과 연결되는 경우입니다. 일대다는 한 행이 상대편 여러 행과 연결되는 경우입니다. 학생 한 명이 여러 질문을 작성하는 예가 있습니다. 다대다는 양쪽 여러 행이 서로 연결되는 경우입니다. 학생과 강의가 대표적입니다. 한 학생은 여러 강의를 신청할 수 있고, 한 강의도 여러 학생이 신청할 수 있습니다."
  },
  {
    "k": "MANY TO MANY",
    "l": "N:M 구현",
    "t": "N:M은 보통 연결 Table로 표현합니다",
    "h": "<h2>N:M은 보통<br>연결 Table로 표현합니다</h2><div class=\"flow\"><div class=\"flow-step\">students<br>1</div><div class=\"flow-arrow\">→</div><div class=\"flow-step current\">enrollments<br>N</div><div class=\"flow-arrow\">←</div><div class=\"flow-step\">courses<br>1</div></div><p class=\"body-text\">학생과 강의의 N:M 관계를 수강신청 Table이 두 개의 1:N 관계로 나누어 표현합니다.</p>",
    "s": "다대다 관계는 일반적으로 연결 테이블을 사용해 표현합니다. 학생과 강의의 다대다 관계를 그대로 하나의 선으로만 두는 것이 아니라, 인롤먼츠라는 수강신청 테이블을 둡니다. 그러면 학생과 수강신청은 일대다 관계가 되고, 강의와 수강신청도 일대다 관계가 됩니다. 연결 테이블은 누가 무엇을 신청했는지뿐 아니라 신청일, 상태, 신청 당시 금액 같은 정보를 함께 담을 수 있습니다."
  },
  {
    "k": "PRIMARY KEY",
    "l": "PK 미리보기",
    "t": "PK는 한 Table 안에서 Row를 구분합니다",
    "h": "<h2>PK는 한 Table 안에서<br>Row를 구분합니다</h2><div class=\"table-wrap\"><table><thead><tr><th>id</th><th>name</th><th>email</th></tr></thead><tbody><tr><td>1</td><td>김민지</td><td>minji@example.com</td></tr><tr><td>2</td><td>김민지</td><td>minji2@example.com</td></tr></tbody></table></div><p class=\"body-text\">이름이 같아도 id가 다르면 서로 다른 Row로 구분할 수 있습니다.</p>",
    "s": "기본키, 피케이는 한 테이블 안에서 각 행을 고유하게 구분하는 열 또는 열 조합입니다. 화면의 두 학생은 이름이 모두 김민지입니다. 이름만 보면 같은 사람인지 구분하기 어렵습니다. 하지만 아이디 값이 1과 2로 다르기 때문에 서로 다른 행으로 구분할 수 있습니다. 초반 실습에서는 이해하기 쉬운 단일 아이디 열을 기본키로 사용합니다."
  },
  {
    "k": "PK RULES",
    "l": "PK의 기본 규칙",
    "t": "PK는 중복되지 않고 NULL일 수 없습니다",
    "h": "<h2>PK는 중복되지 않고<br>NULL일 수 없습니다</h2><ul class=\"bullet-list\"><li>PK 값 또는 값의 조합은 중복되지 않는다.</li><li>PK를 구성하는 Column은 NULL일 수 없다.</li><li>각 Row를 안정적으로 구분한다.</li><li>가능하면 자주 바뀌지 않는 값을 사용한다.</li></ul>",
    "s": "기본키의 기본 규칙을 정리해 보겠습니다. 기본키 값 또는 값의 조합은 중복되지 않습니다. 기본키를 구성하는 열은 널일 수 없습니다. 기본키는 각 행을 안정적으로 구분해야 합니다. 가능하면 자주 바뀌지 않는 값을 사용합니다. 여러 열을 묶어 행을 구분하는 복합 기본키는 이후 정규화와 무결성 장에서 다시 다룹니다."
  },
  {
    "k": "FOREIGN KEY",
    "l": "FK 미리보기",
    "t": "FK는 다른 Row를 참조합니다",
    "h": "<h2>FK는 다른 Row를<br>참조합니다</h2><div class=\"table-wrap\"><table><thead><tr><th>id</th><th>student_id</th><th>course_id</th><th>status</th></tr></thead><tbody><tr><td>1</td><td>1</td><td>10</td><td>신청</td></tr><tr><td>2</td><td>1</td><td>20</td><td>수강중</td></tr><tr><td>3</td><td>2</td><td>10</td><td>완료</td></tr></tbody></table></div><p class=\"body-text\">student_id는 students.id를, course_id는 courses.id를 참조합니다.</p>",
    "s": "외래키, 에프케이는 다른 행을 참조하는 열 또는 열 조합입니다. 화면의 인롤먼츠 테이블에서 스튜던트 아이디는 스튜던츠 테이블의 아이디를 참조합니다. 코스 아이디는 코시즈 테이블의 아이디를 참조합니다. 외래키는 참조 대상 행이 존재하는지 확인하고 업무 관계를 표현합니다. 학생 1이 두 강의를 신청하면 스튜던트 아이디 1이 여러 번 반복될 수 있습니다."
  },
  {
    "k": "FK MISUNDERSTANDING",
    "l": "FK 오해",
    "t": "FK는 UNIQUE가 아니며 반복될 수 있습니다",
    "h": "<h2>FK는 UNIQUE가 아니며<br>반복될 수 있습니다</h2><ul class=\"bullet-list\"><li>FK 값은 여러 Row에서 반복될 수 있다.</li><li>FK는 기본적으로 UNIQUE가 아니다.</li><li>별도 NOT NULL 규칙이 없으면 NULL을 허용할 수 있다.</li><li>FK만으로 필수 관계나 1:1 관계가 자동 완성되지는 않는다.</li></ul>",
    "s": "외래키에 대해 자주 하는 오해를 정리하겠습니다. 외래키 값은 여러 행에서 반복될 수 있습니다. 외래키는 기본적으로 유니크가 아닙니다. 별도의 낫 널 규칙이 없으면 널을 허용할 수도 있습니다. 외래키만 정의했다고 해서 필수 관계나 일대일 관계가 자동으로 완성되지는 않습니다. 이런 차이는 나중에 제약조건을 설계할 때 매우 중요합니다."
  },
  {
    "k": "ACTIVITY PK FK",
    "l": "활동 2",
    "t": "PK와 FK를 찾아봅시다",
    "h": "<h2>PK와 FK를<br>찾아봅시다</h2><div class=\"codebox\">students\nid | name\n1  | 김민지\n2  | 이준호\n\nquestions\nid | student_id | title\n1  | 1          | JOIN 질문\n2  | 1          | NULL 질문\n3  | 2          | PK 질문</div>",
    "s": "두 번째 활동입니다. 화면의 두 테이블에서 기본키와 외래키를 찾아보겠습니다. 스튜던츠 테이블에서는 아이디가 기본키입니다. 퀘스천즈 테이블에서도 아이디가 기본키입니다. 퀘스천즈의 스튜던트 아이디는 스튜던츠의 아이디를 참조하는 외래키입니다. 김민지 학생의 질문은 두 개입니다. 스튜던트 아이디 1이 반복되어도 되는 이유는 한 학생이 여러 질문을 작성할 수 있기 때문입니다."
  },
  {
    "k": "CONSTRAINTS",
    "l": "제약조건",
    "t": "Constraint는 저장 가능한 값과 참조를 제한합니다",
    "h": "<h2>Constraint는 저장 가능한<br>값과 참조를 제한합니다</h2><div class=\"grid-3\"><article class=\"card\"><h3>PRIMARY KEY</h3><p>행 구분</p></article><article class=\"card\"><h3>FOREIGN KEY</h3><p>참조 확인</p></article><article class=\"card\"><h3>NOT NULL</h3><p>필수값</p></article><article class=\"card\"><h3>UNIQUE</h3><p>중복 제한</p></article><article class=\"card\"><h3>CHECK</h3><p>값 범위 제한</p></article><article class=\"card\"><h3>DEFAULT</h3><p>생략 시 기본값</p></article></div>",
    "s": "제약조건은 저장할 수 있는 값과 참조에 대한 규칙입니다. 프라이머리 키는 행을 구분합니다. 포린 키는 참조 대상이 존재하는지 확인합니다. 낫 널은 값이 반드시 있어야 한다는 규칙입니다. 유니크는 중복을 제한합니다. 체크는 값의 범위를 제한합니다. 디폴트는 값을 생략했을 때 사용할 기본값을 정하는 설정입니다. 디폴트는 잘못된 값을 직접 차단하는 제약조건과는 역할이 다릅니다."
  },
  {
    "k": "DBMS SAFETY",
    "l": "DBMS가 데이터를 지키는 방법",
    "t": "DBMS는 정확성, 동시성, 권한, 복구를 지원합니다",
    "h": "<h2>DBMS는 정확성, 동시성,<br>권한, 복구를 지원합니다</h2><div class=\"grid-2\"><article class=\"card\"><h3>정확성</h3><p>제약조건으로 잘못된 값과 참조를 줄입니다.</p></article><article class=\"card\"><h3>동시성</h3><p>여러 사용자의 작업 충돌을 조정합니다.</p></article><article class=\"card\"><h3>권한</h3><p>사용자와 역할별 접근 범위를 구분합니다.</p></article><article class=\"card\"><h3>백업·복구</h3><p>장애와 실수에 대비합니다.</p></article></div>",
    "s": "디비엠에스는 데이터를 안전하게 지키기 위한 여러 기능을 제공합니다. 제약조건으로 잘못된 값과 참조를 줄입니다. 트랜잭션과 동시성 제어로 여러 사용자의 작업 충돌을 조정합니다. 사용자와 역할별로 접근 권한을 구분합니다. 백업과 복구 기능도 제공합니다. 다만 백업 기능이 있다고 해서 데이터가 자동으로 안전해지는 것은 아닙니다. 실제 복구 가능 여부를 점검해야 합니다."
  },
  {
    "k": "SQL CRUD",
    "l": "SQL과 CRUD",
    "t": "SQL은 DBMS에 명령을 전달하는 언어입니다",
    "h": "<h2>SQL은 DBMS에 명령을<br>전달하는 언어입니다</h2><pre><code>SELECT *\nFROM students;</code></pre><div class=\"table-wrap\"><table><thead><tr><th>CRUD</th><th>의미</th><th>대표 SQL</th></tr></thead><tbody><tr><td>Create</td><td>행 추가</td><td>INSERT</td></tr><tr><td>Read</td><td>조회</td><td>SELECT</td></tr><tr><td>Update</td><td>수정</td><td>UPDATE</td></tr><tr><td>Delete</td><td>삭제 기능</td><td>DELETE 또는 상태 변경</td></tr></tbody></table></div>",
    "s": "에스큐엘은 관계형 디비엠에스에 명령을 전달하는 언어입니다. 화면의 셀렉트 별표 프롬 스튜던츠는 스튜던츠 테이블의 모든 행과 열을 조회하라는 의미입니다. 크러드는 애플리케이션에서 반복되는 네 가지 기본 데이터 작업입니다. 크리에이트는 행 추가, 리드는 조회, 업데이트는 수정, 딜리트는 삭제 기능입니다."
  },
  {
    "k": "CRUD CAUTION",
    "l": "CRUD 주의",
    "t": "CRUD Create와 CREATE TABLE은 다릅니다",
    "h": "<h2>CRUD Create와<br>CREATE TABLE은 다릅니다</h2><div class=\"grid-2\"><article class=\"card\"><h3>CRUD Create</h3><p>INSERT로 새로운 데이터 Row를 추가</p></article><article class=\"card emphasis\"><h3>CREATE TABLE</h3><p>데이터 Row가 아니라 Table 구조를 생성</p></article></div>",
    "s": "크러드의 크리에이트와 에스큐엘의 크리에이트 테이블은 다릅니다. 크러드 크리에이트는 새로운 데이터 행을 추가하는 기능이며 일반적으로 인서트에 해당합니다. 크리에이트 테이블은 데이터 행을 넣는 것이 아니라 테이블 구조를 만드는 디디엘 명령입니다. 이름이 비슷하다고 같은 의미로 이해하면 안 됩니다."
  },
  {
    "k": "DELETE CAUTION",
    "l": "Delete 의미",
    "t": "Delete 기능이 항상 SQL DELETE는 아닙니다",
    "h": "<h2>Delete 기능이 항상<br>SQL DELETE는 아닙니다</h2><div class=\"flow\"><div class=\"flow-step\">물리 삭제<br>DELETE로 Row 제거</div><div class=\"flow-arrow\">↔</div><div class=\"flow-step current\">상태 기반 삭제<br>status = 취소<br>deleted_at 기록</div></div>",
    "s": "삭제 기능도 항상 에스큐엘 딜리트를 의미하지는 않습니다. 물리 삭제는 딜리트로 행을 제거하는 방식입니다. 하지만 실제 업무에서는 거래나 신청 이력을 보존해야 하는 경우가 많습니다. 이때는 행을 삭제하지 않고 상태를 취소로 바꾸거나 삭제 시각을 기록하는 방식으로 삭제 기능을 구현할 수 있습니다. 업무 이력 보존 여부가 중요합니다."
  },
  {
    "k": "DATA STRUCTURE TYPES",
    "l": "데이터 구조 유형",
    "t": "정형·반정형·비정형 데이터를 구분합니다",
    "h": "<h2>정형·반정형·비정형<br>데이터를 구분합니다</h2><div class=\"table-wrap\"><table><thead><tr><th>구분</th><th>설명</th><th>예시</th></tr></thead><tbody><tr><td>정형</td><td>열과 데이터 타입이 명확</td><td>학생·주문 Table</td></tr><tr><td>반정형</td><td>키와 계층 구조가 있음</td><td>JSON, XML</td></tr><tr><td>비정형</td><td>고정된 행과 열로 표현하기 어려움</td><td>문서, 이미지, 음성, 영상</td></tr></tbody></table></div>",
    "s": "데이터는 구조의 명확성에 따라 정형, 반정형, 비정형으로 구분할 수 있습니다. 정형 데이터는 열과 데이터 타입이 명확합니다. 학생 테이블이나 주문 테이블이 예입니다. 반정형 데이터는 고정된 표는 아니지만 키와 계층 구조가 있습니다. 제이슨과 엑스엠엘이 예입니다. 비정형 데이터는 고정된 행과 열로 표현하기 어려운 데이터입니다. 문서, 이미지, 음성, 영상이 여기에 해당합니다."
  },
  {
    "k": "STORAGE TYPES",
    "l": "구조와 저장 방식 구분",
    "t": "데이터 구조와 저장소 유형은 같은 기준이 아닙니다",
    "h": "<h2>데이터 구조와 저장소 유형은<br>같은 기준이 아닙니다</h2><div class=\"grid-2\"><article class=\"card\"><h3>정형·반정형·비정형</h3><p>데이터 자체의 구조적 특성</p></article><article class=\"card emphasis\"><h3>RDBMS·문서형 DB·파일·객체 저장소</h3><p>데이터를 저장하고 사용하는 방식</p></article></div>",
    "s": "데이터 구조와 저장소 유형은 같은 기준이 아닙니다. 정형, 반정형, 비정형은 데이터 자체의 구조적 특성을 말합니다. 알디비엠에스, 문서형 디비, 파일, 객체 저장소는 데이터를 저장하고 사용하는 방식입니다. 포스트그레스큐엘도 제이슨비를 사용해 반정형 데이터를 저장할 수 있습니다. 반대로 정형 데이터가 씨에스브이 파일이나 스프레드시트로 전달될 수도 있습니다."
  },
  {
    "k": "SOURCE DERIVED AI",
    "l": "데이터 범주",
    "t": "기준 데이터, 결정적 파생 데이터, AI 생성 결과를 구분합니다",
    "h": "<h2>기준 데이터, 결정적 파생 데이터,<br>AI 생성 결과를 구분합니다</h2><div class=\"table-wrap\"><table><thead><tr><th>구분</th><th>의미</th><th>예시</th></tr></thead><tbody><tr><td>기준 데이터</td><td>업무 판단의 기준</td><td>신청, 결제 원장, 출석 기록</td></tr><tr><td>결정적 파생 데이터</td><td>정해진 계산식의 결과</td><td>학생별 질문 수, 월별 집계</td></tr><tr><td>AI 생성 결과</td><td>모델·입력·지시문과 조건으로 생성</td><td>요약, 분류, 추천</td></tr></tbody></table></div>",
    "s": "1장에서 본 기준 데이터, 결정적 파생 데이터, 에이아이 생성 결과를 다시 구분하겠습니다. 기준 데이터는 업무에서 직접 발생하고 판단의 기준이 되는 데이터입니다. 결정적 파생 데이터는 정해진 계산식으로 기준 데이터를 가공한 결과입니다. 학생별 질문 수나 월별 집계가 예입니다. 에이아이 생성 결과는 모델, 입력, 지시문, 실행 조건으로 생성한 결과입니다. 같은 문장이 항상 다시 만들어진다고 보장하기 어렵습니다."
  },
  {
    "k": "VIEW CACHE",
    "l": "파생 결과 처리",
    "t": "파생 결과는 계산하거나 저장할 수 있습니다",
    "h": "<h2>파생 결과는<br>계산하거나 저장할 수 있습니다</h2><div class=\"grid-2\"><article class=\"card\"><h3>실행할 때 계산</h3><p>SELECT<br>일반 VIEW</p></article><article class=\"card emphasis\"><h3>결과를 별도로 저장</h3><p>집계 Table<br>Materialized View<br>Cache</p></article></div>",
    "s": "파생 결과를 다루는 방법도 구분해야 합니다. 실행할 때 계산하는 방법에는 셀렉트와 일반 뷰가 있습니다. 일반 뷰는 조회 정의를 저장하고 호출할 때 원본 데이터를 조회합니다. 결과를 별도로 저장하는 방법에는 집계 테이블, 머티리얼라이즈드 뷰, 캐시가 있습니다. 일반 뷰가 조회 결과 자체를 저장한다고 오해하지 않는 것이 중요합니다."
  },
  {
    "k": "CASE READING",
    "l": "사례로 구조 읽기",
    "t": "students, courses, enrollments 구조를 읽어 봅니다",
    "h": "<h2>students, courses, enrollments<br>구조를 읽어 봅니다</h2><div class=\"table-wrap\"><table><thead><tr><th>개념</th><th>사례에서의 의미</th></tr></thead><tbody><tr><td>Table</td><td>students, courses, enrollments</td></tr><tr><td>PK</td><td>각 Table의 id</td></tr><tr><td>FK</td><td>enrollments.student_id, enrollments.course_id</td></tr><tr><td>1:N</td><td>학생 한 명과 여러 신청, 강의 한 개와 여러 신청</td></tr><tr><td>N:M</td><td>연결 Table을 통해 표현된 학생과 강의</td></tr></tbody></table></div>",
    "s": "앞에서 배운 용어를 학생, 강의, 수강신청 사례에 연결해 보겠습니다. 테이블은 스튜던츠, 코시즈, 인롤먼츠입니다. 기본키는 각 테이블의 아이디입니다. 외래키는 인롤먼츠 점 스튜던트 아이디와 인롤먼츠 점 코스 아이디입니다. 학생 한 명과 여러 신청, 강의 한 개와 여러 신청은 일대다 관계입니다. 학생과 강의는 연결 테이블을 통해 다대다 관계로 표현됩니다."
  },
  {
    "k": "AMOUNT WARNING",
    "l": "금액 의미 주의",
    "t": "recorded_amount는 회계 매출이 아닙니다",
    "h": "<h2>recorded_amount는<br>회계 매출이 아닙니다</h2><div class=\"quote\">신청 당시 기록 금액<br>≠ 결제 완료 금액<br>≠ 환불 반영 순금액<br>≠ 회계 매출</div>",
    "s": "레코디드 어마운트, 즉 신청 당시 기록 금액의 의미를 주의해야 합니다. 신청 당시 기록 금액은 결제 완료 금액과 같지 않을 수 있습니다. 환불이 반영된 순금액과도 다를 수 있습니다. 회계 매출과도 자동으로 같은 의미가 아닙니다. 열 이름이 금액처럼 보인다고 해서 바로 매출로 해석하면 안 됩니다. 데이터의 업무 의미를 반드시 확인해야 합니다."
  },
  {
    "k": "AI TABLE REVIEW",
    "l": "AI 구조 검토",
    "t": "AI가 만든 Table을 기본 용어로 검토합니다",
    "h": "<h2>AI가 만든 Table을<br>기본 용어로 검토합니다</h2><pre><code>CREATE TABLE student_courses (\n    student_name VARCHAR(50),\n    student_email VARCHAR(100),\n    course_title VARCHAR(100),\n    instructor_name VARCHAR(50)\n);</code></pre>",
    "s": "이제 에이아이가 만든 테이블 구조를 기본 용어로 검토해 보겠습니다. 화면의 테이블은 스튜던트 코시즈라는 하나의 테이블에 학생 이름, 학생 이메일, 강의 제목, 강사 이름을 저장합니다. 문법적으로는 실행될 수 있습니다. 하지만 기본 구조를 보면 여러 질문이 생깁니다. 한 행이 학생을 나타내는지 수강신청을 나타내는지 분명하지 않습니다. 기본키도 없습니다. 서로 다른 종류의 정보가 한 테이블에 섞여 있습니다."
  },
  {
    "k": "REVIEW CHECKLIST",
    "l": "검토 순서",
    "t": "AI 생성 구조는 질문으로 검토합니다",
    "h": "<h2>AI 생성 구조는<br>질문으로 검토합니다</h2><ul class=\"bullet-list\"><li>한 Row가 무엇을 나타내는가?</li><li>각 Row를 구분할 PK가 있는가?</li><li>학생·강의·강사 정보가 섞이지 않았는가?</li><li>반복되는 문자열을 FK로 분리해야 하지 않는가?</li><li>Data Type과 필수값·선택값이 맞는가?</li></ul>",
    "s": "에이아이 생성 구조는 질문으로 검토합니다. 한 행이 무엇을 나타내는지 먼저 확인합니다. 각 행을 구분할 기본키가 있는지 확인합니다. 학생, 강의, 강사 정보가 한 테이블에 섞이지 않았는지 봅니다. 반복되는 문자열을 외래키로 분리해야 하는지 생각합니다. 데이터 타입과 필수값, 선택값이 맞는지도 확인합니다. 오늘은 문제를 발견하는 데 집중하고, 테이블 분리와 이알디는 5장에서 자세히 다룹니다."
  },
  {
    "k": "ACTIVITY AI REVIEW",
    "l": "활동 3",
    "t": "다음 제안을 기본 용어로 비판해 봅시다",
    "h": "<h2>다음 제안을 기본 용어로<br>비판해 봅시다</h2><div class=\"prompt-box\">학생 이름, 강의 제목, 강사 이름을<br>student_courses Table 하나에 저장한다.<br><br>별도의 id는 만들지 않고<br>학생 이름으로 Row를 구분한다.</div>",
    "s": "세 번째 활동입니다. 화면의 제안을 기본 용어로 비판해 보겠습니다. 학생 이름, 강의 제목, 강사 이름을 스튜던트 코시즈 테이블 하나에 저장합니다. 별도의 아이디는 만들지 않고 학생 이름으로 행을 구분합니다. 이 제안의 문제는 무엇일까요. 한 행의 의미가 불분명합니다. 학생 이름은 중복될 수 있으므로 안정적인 기본키가 되기 어렵습니다. 강의 제목과 강사 이름이 반복될 수 있고, 학생과 강의의 업무 관계를 제대로 표현하기 어렵습니다."
  },
  {
    "k": "MISUNDERSTANDINGS",
    "l": "자주 하는 오해",
    "t": "2장에서 정리할 자주 하는 오해",
    "h": "<h2>2장에서 정리할<br>자주 하는 오해</h2><div class=\"grid-2\"><article class=\"card\"><h3>DBeaver가 Database이다</h3><p>아닙니다. DBeaver는 Client입니다.</p></article><article class=\"card\"><h3>DBMS와 Database는 같다</h3><p>PostgreSQL은 DBMS, ai_database_book은 Database입니다.</p></article><article class=\"card\"><h3>Row 순서는 항상 같다</h3><p>ORDER BY가 없으면 보장되지 않습니다.</p></article><article class=\"card\"><h3>FK는 중복될 수 없다</h3><p>1:N 관계에서는 반복될 수 있습니다.</p></article></div>",
    "s": "2장에서 자주 하는 오해를 정리해 보겠습니다. 첫째, 디비버가 데이터베이스라는 오해입니다. 디비버는 클라이언트입니다. 둘째, 디비엠에스와 데이터베이스가 같다는 오해입니다. 포스트그레스큐엘은 디비엠에스이고 에이아이 데이터베이스 북은 데이터베이스입니다. 셋째, 행 순서가 항상 같다는 오해입니다. 오더 바이가 없으면 보장되지 않습니다. 넷째, 외래키는 중복될 수 없다는 오해입니다. 일대다 관계에서는 반복될 수 있습니다."
  },
  {
    "k": "SELF CHECK",
    "l": "스스로 확인하기",
    "t": "오늘 배운 내용을 질문으로 확인합니다",
    "h": "<h2>오늘 배운 내용을<br>질문으로 확인합니다</h2><ul class=\"bullet-list\"><li>Data, Database, DBMS의 차이는 무엇인가?</li><li>DBeaver와 PostgreSQL의 역할은 어떻게 다른가?</li><li>Database, Schema, Table의 포함 관계는 무엇인가?</li><li>PK와 FK의 역할은 어떻게 다른가?</li><li>일반 VIEW와 Materialized View는 어떻게 다른가?</li></ul>",
    "s": "오늘 배운 내용을 질문으로 확인해 보겠습니다. 데이터, 데이터베이스, 디비엠에스의 차이는 무엇인가요. 디비버와 포스트그레스큐엘의 역할은 어떻게 다른가요. 데이터베이스, 스키마, 테이블의 포함 관계는 무엇인가요. 기본키와 외래키의 역할은 어떻게 다른가요. 일반 뷰와 머티리얼라이즈드 뷰는 어떻게 다른가요. 이 질문에 자신의 말로 답할 수 있으면 2장의 핵심을 잘 이해한 것입니다."
  },
  {
    "k": "SUMMARY",
    "l": "핵심 정리",
    "t": "데이터베이스를 이해한다는 것",
    "h": "<h2>데이터베이스를 이해한다는 것</h2><div class=\"quote\">DBMS, Database, Schema, Table과 Key가<br>어떤 역할로 연결되는지<br>설명할 수 있다는 뜻입니다.</div>",
    "s": "2장의 핵심을 한 문장으로 정리하겠습니다. 데이터베이스를 이해한다는 것은 디비엠에스, 데이터베이스, 스키마, 테이블과 키가 어떤 역할로 연결되는지 설명할 수 있다는 뜻입니다. 오늘은 실제 설치나 에스큐엘 실행보다 이 구조를 정확한 용어로 읽는 데 집중했습니다. 이 기본 용어를 알아야 다음 장에서 설치와 연결 오류를 스스로 해석할 수 있습니다."
  },
  {
    "k": "NEXT CHAPTER",
    "l": "다음 장",
    "t": "다음 장에서는 PostgreSQL과 DBeaver를 설치합니다",
    "h": "<h2>다음 장에서는<br>PostgreSQL과 DBeaver를 설치합니다</h2><div class=\"flow\"><div class=\"flow-step\">PostgreSQL<br>설치·실행</div><div class=\"flow-arrow\">→</div><div class=\"flow-step\">DBeaver<br>연결</div><div class=\"flow-arrow\">→</div><div class=\"flow-step\">ai_database_book<br>생성</div><div class=\"flow-arrow\">→</div><div class=\"flow-step\">current_database<br>current_schema<br>search_path 확인</div></div>",
    "s": "다음 장에서는 드디어 포스트그레스큐엘과 디비버를 설치합니다. 로컬 포스트그레스큐엘을 설치하고 실행 상태를 확인합니다. 디비버에서 포스트그레스큐엘 연결을 만듭니다. 에이아이 데이터베이스 북 데이터베이스를 생성하고, 새 데이터베이스로 다시 연결합니다. 그 다음 커런트 데이터베이스, 커런트 스키마, 서치 패스를 확인합니다. 오늘 배운 구조가 바로 다음 장 실습의 기준이 됩니다."
  }
]);
document.write('<script src="chapter02_intro_patch.js"><\/script>');
