window.CH6_SLIDES = [
  {
    k: 'CHAPTER 06',
    l: '실습 강의',
    t: '정규화와 무결성 규칙을 실행으로 검증합니다',
    h: `<h1>정규화와 무결성 규칙을<br>실행으로 검증합니다</h1>
<p class="lead">구조 생성 → 기준 데이터 → 정상·경계·오류 테스트 → 복구와 최종 검증</p>
<div class="title-meta"><span class="pill">PostgreSQL</span><span class="pill">제약조건</span><span class="pill">검증 증거</span></div>`,
    s: `이번 실습의 목적은 SQL 파일을 끝까지 실행하는 것이 아닙니다.

정규화된 구조가 요구사항을 올바르게 표현하는지 확인하고, 확정한 규칙이 실제 포스트그레스큐엘에서 정상값은 허용하고 잘못된 값은 거부하는지 검증합니다.

실행 전에는 예상 결과를 먼저 정합니다. 실행 후에는 행 수와 오류 메시지를 확인하고, 실패 테스트 뒤에는 트랜잭션을 복구한 다음 기준 데이터가 그대로 남아 있는지 다시 확인합니다.

따라서 오늘의 완료 기준은 코드 실행이 아니라 예상한 데이터 상태를 실행 결과로 설명할 수 있는가입니다.`
  },
  {
    k: 'CHAPTER GOALS',
    l: '학습 목표',
    t: '이번 실습을 마치면 할 수 있는 일',
    h: `<h2>이번 실습을 마치면<br>할 수 있는 일</h2>
<ul class="bullet-list">
  <li>정규화 전 구조의 이상 현상을 설명합니다.</li>
  <li>회원·도서·대여 테이블과 관계를 생성합니다.</li>
  <li>확정 규칙과 제약조건을 연결합니다.</li>
  <li>정상·경계·오류 데이터를 구분해 테스트합니다.</li>
  <li>오류 후 롤백하고 기준 상태를 재검증합니다.</li>
</ul>`,
    s: `먼저 정규화 전 테이블에서 같은 현재 사실이 반복될 때 어떤 문제가 생기는지 설명할 수 있어야 합니다.

그다음 members_nf, books_nf, loans_nf를 만들고 기본키와 외래키가 세 테이블을 어떻게 연결하는지 확인합니다.

각 제약조건은 임의로 추가하지 않습니다. C-01부터 C-08까지 확정된 업무 규칙 가운데 어떤 규칙을 구현하는지 연결합니다.

마지막에는 성공해야 하는 값과 실패해야 하는 값을 구분해 실행하고, 오류 이후에도 원래 데이터 상태가 보존되는지 확인합니다.`
  },
  {
    k: 'CHAPTER FLOW',
    l: '학습 흐름',
    t: '예상하고 실행한 뒤 증거로 확인합니다',
    h: `<h2>실습은 다섯 단계로 진행합니다</h2>
<div class="flow">
  <div class="flow-step">① 위치·파일<br>확인</div><div class="flow-arrow">→</div>
  <div class="flow-step">② 구조·규칙<br>생성</div><div class="flow-arrow">→</div>
  <div class="flow-step">③ 기준 데이터<br>확인</div><div class="flow-arrow">→</div>
  <div class="flow-step">④ 정상·경계·오류<br>테스트</div><div class="flow-arrow">→</div>
  <div class="flow-step current">⑤ 복구·최종<br>검증</div>
</div>
<div class="quote" style="margin-top:26px;font-size:29px">예상 결과 → 한 문장 실행 → 실제 결과 → 규칙 확인</div>`,
    s: `실습은 다섯 단계로 진행합니다.

먼저 현재 데이터베이스와 스키마, 자동 커밋 상태를 확인합니다. 다음으로 테이블과 제약조건을 만들고 정상 샘플 데이터를 입력합니다.

기준 데이터가 준비되면 기대 행 수와 관계를 먼저 확인합니다. 이후 정상값, 허용해야 하는 경계값, 반드시 실패해야 하는 오류값을 구분해 한 테스트씩 실행합니다.

오류가 발생하면 트랜잭션 상태를 확인하고 필요할 때 롤백합니다. 마지막에는 기준 행 수와 관계가 그대로 유지되는지 다시 조회합니다.`
  },
  {
    k: 'PRACTICE SETUP',
    l: '실행 파일',
    t: '파일 역할과 실행 순서를 먼저 확인합니다',
    h: `<h2>파일 역할과 실행 순서</h2>
<div class="table-wrap"><table><thead><tr><th>순서</th><th>파일</th><th>역할</th></tr></thead><tbody>
<tr><td>1</td><td><strong>normalization_schema.sql</strong></td><td>테이블·제약조건·인덱스 생성</td></tr>
<tr><td>2</td><td><strong>normalization_seed.sql</strong></td><td>정상 기준 데이터 입력</td></tr>
<tr><td>3</td><td><strong>normalization_practice.sql</strong></td><td>행 수·관계·상태 조회</td></tr>
<tr><td>4</td><td><strong>integrity_tests.sql</strong></td><td>경계값과 오류값을 한 테스트씩 실행</td></tr>
<tr><td>선택</td><td>reset_normalization.sql</td><td>처음부터 다시 시작할 때만 초기화</td></tr>
</tbody></table></div>
<div class="quote" style="margin-top:22px;font-size:26px">reset 파일은 현재 DB와 삭제 대상을 확인한 뒤 사용합니다.</div>`,
    s: `파일을 한꺼번에 실행하기 전에 역할을 구분합니다.

스키마 파일은 구조와 규칙을 만듭니다. 시드 파일은 이후 테스트의 기준이 되는 정상 데이터를 입력합니다. 프랙티스 파일은 현재 상태가 예상과 같은지 조회합니다.

무결성 테스트 파일에는 성공해야 하는 예제와 의도적으로 실패해야 하는 예제가 포함되어 있습니다. 실패 SQL은 전체 선택 실행하지 않고 한 문장씩 실행합니다.

리셋 파일은 기존 실습 객체를 삭제하므로 처음부터 다시 시작할 때만 사용합니다.`
  },
  {
    k: 'SAFETY CHECK',
    l: '실행 위치',
    t: '현재 데이터베이스와 스키마를 확인합니다',
    h: `<h2>실행 전 안전 점검</h2>
<pre><code>SELECT current_database();
SELECT current_schema();
SHOW search_path;</code></pre>
<div class="grid-3" style="margin-top:22px">
  <article class="card"><h3>Database</h3><p>ai_database_book</p></article>
  <article class="card"><h3>Schema</h3><p>public</p></article>
  <article class="card emphasis"><h3>Transaction</h3><p>자동 커밋 상태 확인</p></article>
</div>`,
    s: `실습 오류의 상당수는 SQL 문법보다 실행 위치에서 발생합니다.

current_database로 연결한 데이터베이스를 확인하고, current_schema와 search_path로 스키마 이름을 생략했을 때 어떤 객체를 찾는지 확인합니다.

이 실습의 주요 객체는 public 스키마에 생성합니다. 다른 스키마가 먼저 검색되면 같은 이름의 테이블을 잘못 조회할 수 있으므로 주요 SQL에는 public을 명시합니다.

또한 디비버의 자동 커밋 상태를 확인합니다. 수동 커밋 상태에서는 하나의 오류가 트랜잭션 전체를 실패 상태로 만들 수 있습니다.`
  },
  {
    k: 'NORMALIZATION',
    l: '구조 분석',
    t: '한 행에 세 종류의 사실이 섞여 있습니다',
    h: `<h2>정규화 전 테이블의<br>행 의미를 분석합니다</h2>
<div class="table-wrap"><table><thead><tr><th>대여 사건</th><th>회원 현재 정보</th><th>도서 현재 정보</th></tr></thead><tbody>
<tr><td>loan_id<br>borrowed_at<br>due_at<br>returned_at</td><td>member_name<br>member_email</td><td>book_title<br>author</td></tr>
</tbody></table></div>
<div class="grid-3" style="margin-top:24px">
  <article class="card"><h3>삽입 이상</h3><p>대여 전 새 책 등록이 어려움</p></article>
  <article class="card"><h3>수정 이상</h3><p>회원 이메일을 여러 행에서 변경</p></article>
  <article class="card emphasis"><h3>삭제 이상</h3><p>마지막 대여 삭제로 책 정보 손실</p></article>
</div>`,
    s: `library_records_raw의 한 행은 대여 사건 한 건을 나타냅니다. 그러나 같은 행에 회원의 현재 정보와 도서의 현재 정보도 함께 저장되어 있습니다.

이 구조에서는 아직 대여되지 않은 책을 독립적으로 등록하기 어렵습니다. 회원 이메일을 바꿀 때는 해당 회원의 모든 대여 행을 수정해야 합니다. 마지막 대여 기록을 삭제하면 그 책의 유일한 정보도 함께 사라질 수 있습니다.

이상 현상은 SQL 오류가 아닙니다. 명령은 정상적으로 실행되지만 서로 다른 사실의 수명과 변경 이유를 한 행에 섞었기 때문에 데이터의 의미가 손상되는 구조 문제입니다.`
  },
  {
    k: 'NORMALIZATION',
    l: '개선 구조',
    t: '현재 정보와 사건 정보를 각각의 주인에게 저장합니다',
    h: `<h2>세 테이블로 분리하고<br>식별자로 연결합니다</h2>
<div class="grid-3">
  <article class="card"><h3>members_nf</h3><p>id · name<br>email · joined_at</p></article>
  <article class="card"><h3>books_nf</h3><p>id · title · author<br>published_year · isbn</p></article>
  <article class="card emphasis"><h3>loans_nf</h3><p>id · member_id · book_id<br>borrowed_at · due_at · returned_at</p></article>
</div>
<div class="quote" style="margin-top:26px;font-size:29px">현재 정보는 한 번 저장하고, 사건은 외래키로 연결합니다.</div>`,
    s: `회원 정보는 members_nf, 도서 정보는 books_nf, 대여 사건은 loans_nf에서 관리합니다.

loans_nf에는 회원 이름이나 책 제목을 다시 저장하지 않습니다. member_id와 book_id를 외래키로 저장해 어떤 회원이 어떤 책을 빌렸는지 연결합니다.

이렇게 하면 회원 이메일은 회원 한 행에서만 수정하고, 책 제목은 도서 한 행에서만 관리할 수 있습니다. 대여 기록을 삭제해도 회원과 도서 자체의 정보는 남습니다.

정규화는 테이블 수를 늘리는 작업이 아니라 각 사실을 실제 주인에게 저장하는 작업입니다.`
  },
  {
    k: 'BUSINESS RULES',
    l: '확정 정책',
    t: 'C-01부터 C-08까지 구현 대상을 확인합니다',
    h: `<h2>확정 규칙과 구현 방법</h2>
<div class="table-wrap"><table><thead><tr><th>ID</th><th>핵심 규칙</th><th>구현</th></tr></thead><tbody>
<tr><td>C-01</td><td>동일 이메일 문자열 중복 금지</td><td>UNIQUE</td></tr>
<tr><td>C-02</td><td>동일 ISBN 문자열 중복 금지</td><td>UNIQUE</td></tr>
<tr><td>C-03</td><td>이름·제목 공백 금지</td><td>CHECK</td></tr>
<tr><td>C-04·05</td><td>예정일·반납일 날짜 순서</td><td>CHECK</td></tr>
<tr><td>C-06·07</td><td>부모 존재·이력 보존</td><td>FK · RESTRICT</td></tr>
<tr><td>C-08</td><td>도서당 미반납 대여 최대 한 건</td><td>부분 고유 인덱스</td></tr>
</tbody></table></div>`,
    s: `제약조건을 읽을 때는 문법 이름보다 어떤 규칙을 구현하는지 먼저 확인합니다.

C-01과 C-02는 이번 실습에서 정확히 같은 이메일과 ISBN 문자열의 중복을 금지합니다. C-03은 널뿐 아니라 공백만 있는 이름과 제목도 거부합니다.

C-04와 C-05는 대여일보다 빠른 예정일이나 실제 반납일을 차단합니다. C-06은 존재하는 회원과 도서만 참조하게 하고, C-07은 대여 이력이 있는 부모를 바로 삭제하지 못하게 합니다.

C-08은 같은 도서의 현재 미반납 상태만 한 건으로 제한합니다.`
  },
  {
    k: 'DDL REVIEW',
    l: '제약조건',
    t: 'DDL에서 규칙이 구현된 위치를 찾습니다',
    h: `<h2>DDL을 규칙 단위로 읽습니다</h2>
<div class="grid-2">
  <article class="card"><h3>값의 조건</h3><pre><code>name TEXT NOT NULL
CHECK (btrim(name) &lt;&gt; '')
UNIQUE (email)</code></pre></article>
  <article class="card emphasis"><h3>관계와 상태</h3><pre><code>FOREIGN KEY (member_id)
REFERENCES public.members_nf(id)
ON DELETE RESTRICT</code></pre></article>
</div>
<div class="quote" style="margin-top:22px;font-size:26px">DDL 한 줄마다 어떤 규칙 ID를 구현하는지 설명합니다.</div>`,
    s: `전체 CREATE TABLE 문을 한 글자씩 읽지 않습니다. 제약조건이 어떤 오류를 막는지 중심으로 확인합니다.

NOT NULL은 값이 없는 상태를 막고, btrim을 사용한 체크는 공백만 입력된 문자열을 막습니다. UNIQUE는 이번 실습에서 확정한 동일 문자열 중복 금지를 구현합니다.

외래키는 입력한 회원 번호와 도서 번호가 실제 부모 테이블에 존재하는지 검사합니다. ON DELETE RESTRICT는 연결된 대여 이력이 있을 때 회원이나 도서를 삭제하지 못하게 합니다.

각 규칙은 뒤에서 실제 오류 데이터를 입력해 동작을 확인해야 완전히 검증됩니다.`
  },
  {
    k: 'BASELINE',
    l: '기준 데이터',
    t: '테스트 전 기대 상태를 숫자로 고정합니다',
    h: `<h2>정상 샘플 입력 후<br>기대 상태를 확인합니다</h2>
<div class="table-wrap"><table><thead><tr><th>확인 대상</th><th>기대 결과</th></tr></thead><tbody>
<tr><td>library_records_raw</td><td><strong>3행</strong></td></tr>
<tr><td>members_nf</td><td><strong>2행</strong></td></tr>
<tr><td>books_nf</td><td><strong>2행</strong></td></tr>
<tr><td>loans_nf</td><td><strong>3행</strong></td></tr>
<tr><td>회원 101의 대여 / 도서 201의 대여</td><td>각 2건</td></tr>
<tr><td>미반납 대여 / JOIN 결과</td><td>2건 / 3행</td></tr>
</tbody></table></div>`,
    s: `오류 테스트를 시작하기 전에 기준 상태를 숫자로 고정합니다.

원시 테이블은 세 행, 회원과 도서는 각각 두 행, 대여는 세 행이어야 합니다. 회원 101의 대여와 도서 201의 대여는 각각 두 건입니다. 미반납 대여는 두 건이고, 세 테이블을 관계로 연결한 조회 결과는 세 행입니다.

이 수치는 단순한 예시가 아니라 이후 테스트의 기준입니다. 오류 입력이 실패했다면 이 값들이 바뀌지 않아야 합니다.

예상값을 먼저 기록해야 실행 이후 데이터가 의도대로 유지되었는지 판단할 수 있습니다.`
  },
  {
    k: 'POSITIVE TEST',
    l: '정상 데이터',
    t: '정상 데이터는 저장되어야 합니다',
    h: `<h2>먼저 성공해야 하는 입력을 검증합니다</h2>
<pre><code>INSERT INTO public.members_nf
(name, email, joined_at)
VALUES ('최유진', 'yujin@example.com', DATE '2026-07-25')
RETURNING id, name, email;</code></pre>
<div class="grid-3" style="margin-top:22px">
  <article class="card"><h3>예상</h3><p>INSERT 성공</p></article>
  <article class="card"><h3>확인</h3><p>자동 ID 생성</p></article>
  <article class="card emphasis"><h3>정리</h3><p>임시 행 삭제</p></article>
</div>`,
    s: `제약조건 테스트는 실패 예제부터 시작하지 않습니다. 먼저 정상 데이터가 저장되는지 확인합니다.

이름과 이메일, 가입일이 규칙을 만족하는 회원을 입력하고 RETURNING으로 생성된 아이디와 저장된 값을 확인합니다. 시드 데이터에서 아이디를 직접 지정한 뒤 IDENTITY의 다음 값을 조정했으므로 자동 번호도 예상 범위에서 생성되어야 합니다.

테스트용 입력은 확인 후 삭제해 기준 상태로 되돌립니다. 정상 입력이 실패한다면 오류 데이터 테스트보다 먼저 스키마나 시드 상태를 점검해야 합니다.`
  },
  {
    k: 'BOUNDARY TEST',
    l: '경계값',
    t: '허용하기로 한 경계값도 성공해야 합니다',
    h: `<h2>경계값은 오류가 아니라<br>허용 범위의 끝입니다</h2>
<div class="table-wrap"><table><thead><tr><th>경계값</th><th>예상</th><th>확인 규칙</th></tr></thead><tbody>
<tr><td>due_at = borrowed_at</td><td>성공</td><td>C-04의 이상 조건</td></tr>
<tr><td>returned_at = borrowed_at</td><td>성공</td><td>C-05의 이상 조건</td></tr>
<tr><td>returned_at = NULL</td><td>성공</td><td>미반납 상태</td></tr>
<tr><td>published_year = NULL</td><td>성공</td><td>선택 정보</td></tr>
<tr><td>공백이 아닌 한 글자 이름</td><td>성공</td><td>C-03</td></tr>
</tbody></table></div>`,
    s: `경계값 테스트는 제약조건이 너무 강하게 만들어지지 않았는지 확인합니다.

반납예정일과 실제반납일은 대여일과 같은 날짜를 허용하기로 했으므로 같을 때 성공해야 합니다. returned_at의 널은 아직 반납하지 않은 정상 상태입니다. 출판 연도도 선택 정보이므로 널을 허용합니다.

이름은 공백만 입력하는 것은 금지하지만 실제 문자 한 글자는 허용합니다.

오류값만 테스트하면 정상 범위까지 잘못 차단하는 설계 오류를 발견하기 어렵습니다. 경계값은 허용 범위를 정확히 검증하는 테스트입니다.`
  },
  {
    k: 'NEGATIVE TEST',
    l: '오류 데이터',
    t: '실패해야 하는 SQL은 한 문장씩 실행합니다',
    h: `<h2>오류 데이터와 차단 규칙을<br>일대일로 확인합니다</h2>
<div class="table-wrap"><table><thead><tr><th>오류 입력</th><th>예상 차단 수단</th></tr></thead><tbody>
<tr><td>이름 NULL / 공백 이름</td><td>NOT NULL / CHECK</td></tr>
<tr><td>중복 이메일 / 중복 ISBN</td><td>UNIQUE</td></tr>
<tr><td>없는 회원 999 참조</td><td>FOREIGN KEY</td></tr>
<tr><td>대여일보다 빠른 예정일·반납일</td><td>CHECK</td></tr>
<tr><td>같은 도서의 두 번째 미반납 대여</td><td>부분 고유 인덱스</td></tr>
<tr><td>대여 이력이 있는 회원 삭제</td><td>RESTRICT</td></tr>
</tbody></table></div>`,
    s: `실패 테스트는 integrity_tests.sql에서 한 문장씩 선택해 실행합니다.

실행 전에는 어떤 규칙이 막아야 하는지 먼저 적습니다. 실행 후에는 단순히 오류가 났다는 사실이 아니라 예상한 제약조건이나 인덱스 이름이 오류 메시지에 나타나는지 확인합니다.

오류 SQL을 여러 개 동시에 실행하면 첫 번째 오류 이후 나머지 결과를 구분하기 어렵습니다. 특히 수동 커밋 상태에서는 트랜잭션이 실패 상태가 되어 이후 정상 조회도 실행되지 않을 수 있습니다.

각 테스트 뒤에는 기존 데이터가 추가되거나 삭제되지 않았는지 확인합니다.`
  },
  {
    k: 'PARTIAL UNIQUE',
    l: '활성 대여',
    t: '현재 미반납 상태의 중복만 차단합니다',
    h: `<h2>부분 고유 인덱스로<br>활성 대여만 제한합니다</h2>
<pre><code>CREATE UNIQUE INDEX uq_loans_nf_active_book
ON public.loans_nf (book_id)
WHERE returned_at IS NULL;</code></pre>
<div class="grid-2" style="margin-top:22px">
  <article class="card"><h3>과거 이력</h3><p>returned_at이 있으면<br>같은 도서 여러 건 허용</p></article>
  <article class="card emphasis"><h3>현재 대여</h3><p>returned_at이 NULL인 행은<br>도서당 한 건만 허용</p></article>
</div>`,
    s: `C-08은 같은 도서의 모든 대여 이력을 한 건으로 제한하는 규칙이 아닙니다.

반납된 과거 대여는 여러 건 보존할 수 있어야 합니다. 제한할 대상은 returned_at이 널인 현재 미반납 행입니다.

부분 고유 인덱스는 조건을 만족하는 행만 대상으로 book_id의 중복을 검사합니다. 따라서 도서 201의 과거 반납 이력은 여러 건 저장할 수 있지만, 현재 미반납 대여가 이미 있다면 두 번째 미반납 입력은 실패합니다.

이 인덱스는 과거 대여 기간 전체의 겹침까지 검사하지 않습니다. 이번 실습에서 확정한 범위만 구현합니다.`
  },
  {
    k: 'RECOVERY',
    l: '오류 후 복구',
    t: '트랜잭션 실패 상태에서는 롤백합니다',
    h: `<h2>오류 뒤 모든 SQL이 실패하면<br>트랜잭션 상태를 확인합니다</h2>
<pre><code>ERROR: current transaction is aborted

ROLLBACK;

-- 기준 상태 재확인
SELECT COUNT(*) FROM public.members_nf;
SELECT COUNT(*) FROM public.books_nf;
SELECT COUNT(*) FROM public.loans_nf;</code></pre>`,
    s: `수동 커밋 상태에서 제약조건 오류가 발생하면 포스트그레스큐엘은 현재 트랜잭션을 실패 상태로 표시합니다.

이 상태에서는 오류를 수정한 SQL이나 단순 조회도 실행되지 않고 current transaction is aborted 메시지가 반복될 수 있습니다.

이때 제약조건을 삭제하거나 연결을 다시 시작하는 것이 아니라 롤백으로 실패한 트랜잭션을 취소합니다. 그다음 기준 행 수와 주요 관계를 다시 조회합니다.

롤백은 오류 원인을 해결하는 명령이 아니라 실패한 작업 단위를 되돌려 다음 SQL을 실행할 수 있는 상태로 복구하는 명령입니다.`
  },
  {
    k: 'FINAL VERIFICATION',
    l: '최종 점검',
    t: '구조·규칙·검증 증거를 함께 확인합니다',
    h: `<h2>최종 완료 기준</h2>
<div class="grid-3">
  <article class="card"><span class="number">1</span><h3>구조</h3><p>회원·도서·대여의<br>행 의미가 분리됨</p></article>
  <article class="card"><span class="number">2</span><h3>규칙</h3><p>C-01~C-08이<br>DDL과 연결됨</p></article>
  <article class="card emphasis"><span class="number">3</span><h3>증거</h3><p>정상·경계는 성공하고<br>오류는 의도대로 실패함</p></article>
</div>
<div class="table-wrap" style="margin-top:24px"><table><thead><tr><th>마지막 확인</th><th>통과 기준</th></tr></thead><tbody>
<tr><td>기준 행 수와 관계</td><td>테스트 전 예상값과 일치</td></tr>
<tr><td>실패 테스트</td><td>예상한 규칙이 차단</td></tr>
<tr><td>오류 후 상태</td><td>ROLLBACK 후 정상 조회 가능</td></tr>
</tbody></table></div>`,
    s: `실습의 최종 결과는 세 가지로 정리합니다.

첫째, 회원과 도서의 현재 정보, 대여 사건의 정보가 각각의 테이블에 저장되어야 합니다. 둘째, C-01부터 C-08까지 확정한 규칙이 제약조건과 부분 고유 인덱스로 연결되어야 합니다.

셋째, 실행 증거가 있어야 합니다. 정상값과 허용 경계값은 성공하고, 오류값은 예상한 규칙으로 실패해야 합니다. 실패 테스트 뒤에도 기준 행 수와 관계가 유지되어야 합니다.

좋은 설계는 코드가 생성되었다는 사실이 아니라 잘못된 상태를 차단하고 그 결과를 재현 가능한 테스트로 설명할 수 있을 때 완성됩니다.`
  }
];
