window.CH6_SLIDES = [
  {
    k: 'CHAPTER 06',
    l: '실습 강의',
    t: '정규화와 무결성 규칙을 실행으로 검증합니다',
    h: `<h1>정규화와 무결성 규칙을<br>실행으로 검증합니다</h1><p class="lead">구조 생성 → 정상 샘플 → 정규화 비교 → 규칙 추가 → 정상·경계·오류 검증</p><div class="title-meta"><span class="pill">PostgreSQL</span><span class="pill">C-01~C-08</span><span class="pill">실행 증거</span></div>`,
    s: `이번 실습은 에스큐엘 파일을 끝까지 오류 없이 실행하는 것이 목표가 아닙니다. 먼저 정규화 전후 구조와 기준 데이터를 확인하고, 그다음 확정된 규칙을 별도 단계에서 제약조건으로 추가합니다. 정상값과 허용 경계값은 성공해야 하고, 규칙을 위반하는 오류값은 예상한 제약조건이나 인덱스가 거부해야 합니다. 마지막에는 실패 테스트 이후에도 기준 데이터가 그대로 유지되는지 확인합니다.`
  },
  {
    k: 'CHAPTER GOALS',
    l: '학습 목표',
    t: '이번 실습을 마치면 할 수 있는 일',
    h: `<h2>이번 실습을 마치면<br>할 수 있는 일</h2><ul class="bullet-list"><li>정규화 전 구조의 위험한 중복과 이상 현상을 설명합니다.</li><li>회원·도서·대여의 한 행 의미와 관계를 확인합니다.</li><li>C-01~C-08 규칙을 제약조건·인덱스와 연결합니다.</li><li>정상·경계·오류 데이터를 구분해 테스트합니다.</li><li>오류 뒤 기준 상태가 보존되는지 재검증합니다.</li></ul>`,
    s: `첫째, 정규화 전 구조에서 같은 현재 사실이 반복될 때 왜 문제가 생기는지 설명할 수 있어야 합니다. 둘째, members_nf, books_nf, loans_nf의 한 행 의미와 관계를 확인합니다. 셋째, C-01부터 C-08까지 확정된 규칙을 낫 널, 유니크, 체크, 외래키, 부분 고유 인덱스와 연결합니다. 넷째, 성공해야 하는 값과 실패해야 하는 값을 구분해 실행합니다. 다섯째, 오류 테스트 뒤에도 기준 행 수와 관계가 그대로 유지되는지 확인합니다.`
  },
  {
    k: 'CHAPTER FLOW',
    l: '학습 흐름',
    t: '예상하고 실행한 뒤 증거로 확인합니다',
    h: `<h2>실습은 다섯 단계로 진행합니다</h2><div class="flow"><div class="flow-step">① 위치·시작<br>상태 확인</div><div class="flow-arrow">→</div><div class="flow-step">② 기본 구조·샘플<br>생성</div><div class="flow-arrow">→</div><div class="flow-step">③ 정규화 전후<br>비교</div><div class="flow-arrow">→</div><div class="flow-step">④ 무결성 규칙<br>추가</div><div class="flow-arrow">→</div><div class="flow-step current">⑤ 경계·오류<br>검증</div></div><div class="quote" style="margin-top:24px;font-size:28px">예상 결과 → 한 단계 실행 → 실제 결과 → 규칙 확인</div>`,
    s: `현재 데이터베이스와 시작 상태를 먼저 확인합니다. 그다음 제약조건 적용 전의 기본 구조를 만들고 정상 샘플을 입력합니다. 세 번째 단계에서는 정규화 전후의 반복과 관계가 예상과 같은지 비교합니다. 네 번째 단계에서 기존 데이터가 새 규칙을 만족하는지 검사한 뒤 C-01부터 C-08을 추가합니다. 마지막으로 경계값과 오류값을 한 테스트씩 실행해 실제 저장 경계를 확인합니다.`
  },
  {
    k: 'PRACTICE SETUP',
    l: '실행 파일',
    t: '파일 역할과 실행 순서를 먼저 확인합니다',
    h: `<h2>번호형 파일을 역할별로 실행합니다</h2><div class="table-wrap"><table><thead><tr><th>순서</th><th>파일</th><th>완료 상태</th></tr></thead><tbody><tr><td>1</td><td><strong>01_normalization_schema.sql</strong></td><td>제약조건 전 빈 기본 구조</td></tr><tr><td>2</td><td><strong>02_normalization_seed.sql</strong></td><td>정상 샘플 3 / 2 / 2 / 3</td></tr><tr><td>3</td><td><strong>03_normalization_compare.sql</strong></td><td>정규화 전후와 관계 자동 확인</td></tr><tr><td>4</td><td><strong>04_add_integrity_rules.sql</strong></td><td>C-01~C-08 적용</td></tr><tr><td>5</td><td><strong>05_integrity_tests.sql</strong></td><td>경계·오류 테스트를 한 건씩 실행</td></tr></tbody></table></div><div class="quote" style="margin-top:20px;font-size:25px">처음부터 다시 시작할 때만 reset_normalization.sql을 사용합니다.</div>`,
    s: `처음 학습하는 경우에는 번호형 파일을 사용합니다. 01은 제약조건이 아직 없는 기본 구조만 만듭니다. 02는 정상 샘플을 입력하고 아이덴티티 다음 값을 조정합니다. 03은 데이터를 바꾸지 않고 정규화 전후 상태를 자동 비교합니다. 04가 기존 데이터를 검사한 뒤 낫 널, 유니크, 체크, 외래키와 부분 고유 인덱스를 추가합니다. 05에는 성공·실패 테스트가 있으므로 주석을 한 번에 하나씩 해제해 실행합니다. 기존 normalization_*.sql 파일은 호환용이므로 번호 파일과 중복 실행하지 않습니다.`
  },
  {
    k: 'SAFETY CHECK',
    l: '실행 위치',
    t: '현재 데이터베이스와 스키마를 확인합니다',
    h: `<h2>실행 전 위치와 커밋 상태를 확인합니다</h2><pre><code>SELECT current_database();
SELECT current_schema();
SHOW search_path;</code></pre><div class="grid-3"><article class="card"><h3>Database</h3><p>ai_database_book</p></article><article class="card"><h3>Object</h3><p>public.table_name 사용</p></article><article class="card emphasis"><h3>Transaction</h3><p>Auto-commit 상태 확인</p></article></div>`,
    s: `연결 이름만 보고 실행하지 않습니다. current_database로 에이아이 데이터베이스 북에 연결했는지 확인하고 current_schema와 search_path도 확인합니다. 이번 장의 주요 객체는 public 스키마를 이름에 직접 명시합니다. 오류 테스트 전에는 자동 커밋인지 수동 커밋인지도 확인합니다. 수동 커밋이나 명시적 트랜잭션에서 한 문장이 실패하면 다음 문장도 실행되지 않는 실패 상태가 될 수 있습니다.`
  },
  {
    k: 'NORMALIZATION',
    l: '구조 분석',
    t: '한 행에 세 종류의 사실이 섞여 있습니다',
    h: `<h2>정규화 전 한 행에는<br>서로 다른 사실이 섞여 있습니다</h2><div class="table-wrap"><table><thead><tr><th>대여 사건</th><th>회원 현재 정보</th><th>도서 현재 정보</th></tr></thead><tbody><tr><td>loan_id · borrowed_at<br>due_at · returned_at</td><td>member_name<br>member_email</td><td>book_title<br>author</td></tr></tbody></table></div><div class="grid-3"><article class="card"><h3>삽입 이상</h3><p>대여 전 새 도서 등록이 어려움</p></article><article class="card"><h3>수정 이상</h3><p>회원 이메일을 여러 행에서 변경</p></article><article class="card emphasis"><h3>삭제 이상</h3><p>마지막 대여와 도서 정보가 함께 사라짐</p></article></div>`,
    s: `library_records_raw의 한 행은 대여 사건 한 건을 중심으로 하지만 회원과 도서의 현재 정보까지 함께 저장합니다. 이 때문에 아직 대여되지 않은 도서를 독립적으로 등록하기 어렵고, 회원 이메일 변경 시 여러 행을 함께 수정해야 하며, 마지막 대여 행을 삭제할 때 도서 정보까지 잃을 수 있습니다. 이런 이상 현상은 에스큐엘 문법 오류가 아니라 서로 다른 사실의 주인을 한 행에 섞은 구조 문제입니다.`
  },
  {
    k: 'NORMALIZATION',
    l: '개선 구조',
    t: '현재 정보와 사건 정보를 각각의 주인에게 저장합니다',
    h: `<h2>각 사실을 주인 테이블에<br>한 번 저장합니다</h2><div class="grid-3"><article class="card"><h3>members_nf</h3><p>회원 한 명<br>name · email · joined_at</p></article><article class="card"><h3>books_nf</h3><p>대여 대상으로 관리하는 도서 한 건<br>title · author · isbn</p></article><article class="card emphasis"><h3>loans_nf</h3><p>대여 사건 한 건<br>member_id · book_id · 날짜</p></article></div><div class="quote" style="margin-top:22px;font-size:27px">현재 사실은 한 곳에서 관리하고 사건은 식별자로 연결합니다.</div>`,
    s: `회원의 현재 정보는 members_nf, 도서의 현재 정보는 books_nf, 대여 사건은 loans_nf에서 관리합니다. loans_nf에 회원 이메일이나 도서 제목을 다시 복사하지 않고 member_id와 book_id로 부모 행을 가리킵니다. 여기서 books_nf 한 행은 제목·판본·실제 복본을 모두 엄밀히 분리한 운영 모델이 아니라, 이 장에서 대여 대상으로 관리하는 도서 한 건이라는 단순화된 의미입니다.`
  },
  {
    k: 'BUSINESS RULES',
    l: '확정 정책',
    t: 'C-01부터 C-08까지 구현 대상을 확인합니다',
    h: `<h2>확정 규칙과 구현 방법</h2><div class="table-wrap"><table><thead><tr><th>ID</th><th>규칙</th><th>구현</th></tr></thead><tbody><tr><td>C-01</td><td>같은 이메일 문자열 중복 금지</td><td>UNIQUE</td></tr><tr><td>C-02</td><td>같은 ISBN 문자열 중복 금지</td><td>UNIQUE</td></tr><tr><td>C-03</td><td>공백 이름·제목 금지</td><td>CHECK</td></tr><tr><td>C-04·05</td><td>예정일·반납일 날짜 순서</td><td>CHECK</td></tr><tr><td>C-06·07</td><td>부모 존재·이력 보존</td><td>FK · RESTRICT</td></tr><tr><td>C-08</td><td>도서당 미반납 대여 최대 한 건</td><td>부분 고유 인덱스</td></tr></tbody></table></div>`,
    s: `제약조건은 좋은 아이디어를 임의로 추가하는 기능이 아닙니다. Chapter 05에서 미확정이었던 정책 가운데 이번 실습에서 명시적으로 확정한 C-01부터 C-08만 구현합니다. 이메일 대소문자 정규화, 동일 아이에스비엔의 여러 복본, 여러 저자와 과거 대여 기간 전체 중첩은 이번 범위에 포함하지 않습니다.`
  },
  {
    k: 'DDL',
    l: '규칙 적용',
    t: 'DDL에서 규칙이 구현된 위치를 찾습니다',
    h: `<h2>규칙은 04 파일에서<br>기존 데이터 검사 후 추가합니다</h2><div class="grid-2"><article class="card"><h3>01 기본 구조</h3><p>PK와 타입 중심<br>업무 규칙은 아직 미적용</p></article><article class="card emphasis"><h3>04 규칙 추가</h3><p>SET NOT NULL · UNIQUE · CHECK · FK · 부분 고유 인덱스</p></article></div><div class="quote" style="margin-top:24px;font-size:27px">정책 확정 → 기존 데이터 검사 → ALTER TABLE / INDEX → 적용 상태 검증</div>`,
    s: `01_normalization_schema.sql은 정규화 전후를 비교하기 위한 기본 테이블만 만듭니다. 업무 제약조건은 아직 넣지 않습니다. 정상 샘플과 비교를 끝낸 뒤 04_add_integrity_rules.sql이 널, 중복, 공백, 날짜, 고아 참조와 활성 중복을 먼저 검사합니다. 현재 데이터가 규칙을 만족할 때만 얼터 테이블과 부분 고유 인덱스로 C-01부터 C-08을 추가합니다. 적용 과정은 하나의 트랜잭션이므로 중간 오류 시 일부 규칙만 남기지 않습니다.`
  },
  {
    k: 'BASELINE',
    l: '기준 상태',
    t: '테스트 전 기대 상태를 숫자로 고정합니다',
    h: `<h2>테스트 전에 기준 상태를 고정합니다</h2><div class="table-wrap"><table><tbody><tr><th>library_records_raw</th><td>3행</td></tr><tr><th>members_nf</th><td>2행</td></tr><tr><th>books_nf</th><td>2행</td></tr><tr><th>loans_nf</th><td>3행</td></tr><tr><th>미반납</th><td>2행</td></tr><tr><th>반복·관계</th><td>회원 101 = 2건 · 도서 201 = 2건 · 고아 0 · 활성 중복 0</td></tr></tbody></table></div>`,
    s: `오류 테스트를 시작하기 전에 현재 상태를 숫자로 고정합니다. 원시 테이블은 3행, 회원 2행, 도서 2행, 대여 3행이며 미반납은 2행입니다. 회원 101과 도서 201은 각각 두 대여 이력을 갖습니다. 고아 회원 참조와 고아 도서 참조는 0이고, 같은 도서의 미반납 중복도 0이어야 합니다. 03 비교 파일이 이 상태와 날짜 순서를 자동 판정합니다.`
  },
  {
    k: 'NORMAL DATA',
    l: '정상 데이터',
    t: '정상 데이터는 저장되어야 합니다',
    h: `<h2>정상 데이터와 정상 관계는<br>성공해야 합니다</h2><pre><code>02_normalization_seed.sql
→ raw 3 / members 2 / books 2 / loans 3</code></pre><div class="grid-3"><article class="card"><h3>정상 관계</h3><p>회원 101의 여러 대여 허용</p></article><article class="card"><h3>시간 이력</h3><p>도서 201은 반납 후 재대여</p></article><article class="card emphasis"><h3>미반납</h3><p>도서당 현재 한 건만 존재</p></article></div>`,
    s: `정상 샘플이 규칙 때문에 거부되어서는 안 됩니다. 회원 한 명이 여러 대여 이력을 가질 수 있고 도서 한 건도 시간에 따라 여러 대여 이력을 가질 수 있습니다. 도서 201의 첫 대여는 반납된 뒤 다음 날 다시 시작되므로 반복 이력은 허용됩니다. C-08은 과거 이력을 금지하는 규칙이 아니라 현재 returned_at이 널인 대여가 도서당 하나만 존재하도록 제한합니다.`
  },
  {
    k: 'BOUNDARY',
    l: '경계값',
    t: '허용하기로 한 경계값도 성공해야 합니다',
    h: `<h2>경계값은 요구사항대로<br>허용되어야 합니다</h2><div class="table-wrap"><table><tbody><tr><td>due_at = borrowed_at</td><td>성공</td></tr><tr><td>returned_at = borrowed_at</td><td>성공</td></tr><tr><td>returned_at = NULL</td><td>성공</td></tr><tr><td>published_year = NULL</td><td>성공</td></tr><tr><td>공백이 아닌 한 글자 이름</td><td>성공</td></tr></tbody></table></div>`,
    s: `체크 제약조건은 잘못된 값을 막아야 하지만 요구사항이 허용한 경계값까지 거부하면 안 됩니다. 반납예정일과 실제반납일은 대여일과 같은 날일 수 있습니다. 실제반납일은 아직 반납하지 않았다면 널일 수 있고 출판연도는 이번 모델에서 선택값입니다. 이름은 공백만 아니면 한 글자도 허용됩니다. 05 파일의 경계 테스트는 임시 행을 넣고 바로 삭제해 기준 상태로 돌아옵니다.`
  },
  {
    k: 'FAILURE TEST',
    l: '오류값',
    t: '실패해야 하는 SQL은 한 문장씩 실행합니다',
    h: `<h2>오류 SQL은 한 번에<br>하나씩 실행합니다</h2><div class="table-wrap"><table><tbody><tr><td>NULL 이름</td><td>NOT NULL</td></tr><tr><td>중복 이메일·ISBN</td><td>UNIQUE</td></tr><tr><td>공백 이름·제목</td><td>CHECK</td></tr><tr><td>없는 회원·도서 참조</td><td>FOREIGN KEY</td></tr><tr><td>잘못된 날짜 순서</td><td>CHECK</td></tr><tr><td>참조 부모 삭제</td><td>RESTRICT / FK</td></tr></tbody></table></div>`,
    s: `05_integrity_tests.sql의 오류 예제는 기본적으로 주석 처리되어 있습니다. 한 테스트만 선택해 주석을 해제하고 실행합니다. 실패해야 하는 에스큐엘에서 오류가 발생하면 테스트가 성공한 것입니다. 오류 메시지에서 uq_members_nf_email, fk_loans_nf_member, chk_loans_nf_due_date 같은 객체 이름을 확인해 어떤 규칙이 동작했는지 기록합니다. C-06은 없는 회원뿐 아니라 없는 도서를 참조하는 경우도 각각 확인합니다.`
  },
  {
    k: 'PARTIAL UNIQUE',
    l: '활성 대여',
    t: '현재 미반납 상태의 중복만 차단합니다',
    h: `<h2>C-08은 현재 미반납 상태만<br>도서당 하나로 제한합니다</h2><pre><code>CREATE UNIQUE INDEX uq_loans_nf_active_book
ON public.loans_nf (book_id)
WHERE returned_at IS NULL;</code></pre><div class="grid-2"><article class="card"><h3>허용</h3><p>반납 완료 이력 여러 건</p></article><article class="card emphasis"><h3>차단</h3><p>같은 도서의 두 번째 미반납 대여</p></article></div>`,
    s: `부분 고유 인덱스는 returned_at이 널인 행만 대상으로 book_id의 고유성을 검사합니다. 따라서 반납된 과거 이력은 여러 건 존재할 수 있지만 같은 도서에 현재 미반납 대여를 두 건 만들면 두 번째 입력이 실패합니다. 이 규칙은 과거 대여 기간 전체의 중첩을 검사하는 규칙이 아닙니다. 기간 중첩은 별도의 심화 주제입니다.`
  },
  {
    k: 'TRANSACTION',
    l: '오류 복구',
    t: '트랜잭션 실패 상태에서는 롤백합니다',
    h: `<h2>오류 뒤에는 현재 트랜잭션<br>상태를 먼저 확인합니다</h2><pre><code>BEGIN;
-- 실패하는 테스트 한 문장
-- ERROR
SELECT ...;  -- current transaction is aborted
ROLLBACK;
-- 다음 테스트는 새 상태에서 실행</code></pre>`,
    s: `자동 커밋에서는 일반적으로 실패한 문장만 거부됩니다. 하지만 수동 커밋이나 BEGIN 안에서 오류가 발생하면 현재 트랜잭션이 실패 상태가 되어 이후 정상 쿼리도 실행되지 않을 수 있습니다. 이때 제약조건을 지우는 것이 아니라 롤백으로 실패한 트랜잭션을 끝냅니다. 그 후 다음 테스트를 새 상태에서 실행합니다. 트랜잭션의 상세 원리는 Chapter 09에서 다룹니다.`
  },
  {
    k: 'FINAL CHECK',
    l: '최종 검증',
    t: '구조·규칙·검증 증거를 함께 확인합니다',
    h: `<h2>완료 기준은 구조·규칙·데이터가<br>서로 일치하는 것입니다</h2><div class="grid-3"><article class="card"><h3>구조</h3><p>각 테이블의 한 행 의미와 사실의 주인</p></article><article class="card"><h3>규칙</h3><p>C-01~C-08과 8개 제약조건·부분 인덱스</p></article><article class="card emphasis"><h3>증거</h3><p>정상·경계 성공, 오류 실패, 기준 상태 유지</p></article></div><div class="table-wrap" style="margin-top:20px"><table><tbody><tr><th>03</th><td>Chapter 06 normalization comparison passed</td></tr><tr><th>04</th><td>제약조건 8개 · NOT NULL 열 10개 · 활성 인덱스 존재</td></tr><tr><th>05</th><td>Chapter 06 integrity test baseline preserved</td></tr></tbody></table></div>`,
    s: `최종 결과는 테이블을 여러 개 만들었다는 사실만으로 판단하지 않습니다. 각 테이블의 한 행 의미와 컬럼의 주인이 설명되어야 하고, C-01부터 C-08이 어떤 제약조건이나 인덱스로 구현되었는지 연결되어야 합니다. 정상값과 허용 경계값은 성공하고 오류값은 예상한 규칙으로 실패해야 합니다. 마지막으로 05 파일의 자동 기준 상태 확인까지 통과하면 실습 후 데이터가 원래 기준으로 돌아왔음을 확인할 수 있습니다.`
  }
];
