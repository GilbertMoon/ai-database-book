(() => {
  const slides = window.CH6_SLIDES;
  if (!Array.isArray(slides)) return;

  const patchByTitle = (title, patch) => {
    const slide = slides.find((item) => item && item.t === title);
    if (!slide) {
      console.warn(`[Chapter 06] slide not found: ${title}`);
      return;
    }
    Object.assign(slide, patch);
  };

  patchByTitle('반복된 값이 모두 문제는 아닙니다', {
    s: `반복된 값이 보인다고 해서 모두 제거하면 안 됩니다.

대여일처럼 사건마다 독립적으로 기록되는 값은 같은 날짜가 나타날 수 있습니다. 외래키인 member_id도 여러 대여가 같은 회원을 참조하면 자연스럽게 반복됩니다.

문제가 되는 것은 회원의 현재 이메일이나 도서 제목처럼 하나의 현재 사실을 여러 행에 복사해 따로 관리하는 경우입니다. 이런 복사본은 일부만 수정되면 서로 다른 값이 됩니다.

따라서 반복을 발견하면 먼저 이 값이 관계를 나타내는지, 사건별 값인지, 아니면 같은 현재 사실의 복사본인지 확인해야 합니다.`
  });

  patchByTitle('회원 번호로 회원과 대여 기록을 연결합니다', {
    h: `<h2>회원 번호로 회원과<br>대여 기록을 연결합니다</h2>
<div class="grid-2">
  <article class="card">
    <h3>members · 회원</h3>
    <div class="table-wrap"><table><thead><tr><th>member_id</th><th>이름</th></tr></thead><tbody><tr><td><strong>101</strong></td><td>김민지</td></tr><tr><td>102</td><td>이준호</td></tr></tbody></table></div>
    <p class="small">member_id는 회원을 구분하는 기본키입니다.</p>
  </article>
  <article class="card emphasis">
    <h3>loans · 대여 기록</h3>
    <div class="table-wrap"><table><thead><tr><th>loan_id</th><th>member_id</th><th>book_id</th></tr></thead><tbody><tr><td>1</td><td><strong>101</strong></td><td>201</td></tr><tr><td>2</td><td><strong>101</strong></td><td>202</td></tr><tr><td>3</td><td>102</td><td>203</td></tr></tbody></table></div>
    <p class="small">member_id와 book_id는 부모 행을 가리키는 외래키입니다.</p>
  </article>
</div>
<div class="quote" style="margin-top:20px;font-size:28px">현재 정보는 부모 테이블에 한 번 저장하고, 대여 기록에서는 식별자로 연결합니다.</div>`,
    s: `회원 정보와 대여 사건을 분리하면 두 테이블을 다시 연결할 식별자가 필요합니다.

members의 member_id는 회원 한 명을 구분하는 기본키입니다. loans의 member_id는 해당 대여가 어느 회원의 것인지 가리키는 외래키입니다. 같은 방식으로 book_id는 대여한 도서를 가리킵니다.

대여 1과 대여 2에서 member_id 101이 반복되는 것은 김민지의 이름이나 이메일을 복사한 것이 아닙니다. 서로 다른 두 대여가 같은 회원을 참조한다는 뜻입니다.

따라서 정규화된 대여 테이블에는 책 제목을 다시 저장하지 않고 book_id를 저장합니다. 제목은 books 테이블에서 한 번 관리하고 조회할 때 관계를 따라 가져옵니다.`
  });

  patchByTitle('member_id 반복은 회원과 대여의 관계를 표현합니다', {
    s: `대여 1과 대여 2에는 같은 member_id 101이 들어 있습니다. 이는 한 회원이 서로 다른 두 권의 책을 빌린 두 사건을 나타냅니다.

외래키의 반복은 같은 정보를 복사한 것이 아니라 여러 자식 행이 하나의 부모 행을 참조하는 일대다 관계를 표현합니다. 회원 이름이나 이메일은 members에서 한 번만 관리하므로 member_id가 반복되어도 수정 불일치가 생기지 않습니다.`
  });

  patchByTitle('회원 이메일 반복은 현재 사실의 복사입니다', {
    s: `반대로 회원 이메일을 대여 행마다 저장하면 같은 현재 사실의 복사본이 여러 개 생깁니다.

회원 101의 이메일을 변경할 때 모든 대여 행을 함께 수정해야 하고, 한 행이라도 빠지면 서로 다른 이메일이 남습니다. 어느 값이 현재 값인지 판단하기 어려워집니다.

따라서 회원의 현재 이메일은 members의 회원 한 행에서 관리하고, 대여 기록은 member_id로 그 회원을 참조해야 합니다.`
  });

  patchByTitle('정상 반복과 위험한 중복을 비교합니다', {
    s: `반복의 모양이 아니라 의미를 비교해야 합니다.

loans.member_id는 여러 대여가 같은 회원을 참조하므로 정상적인 반복입니다. borrowed_at도 사건마다 독립적으로 기록되는 값이므로 우연히 같을 수 있습니다.

반면 member_email과 book_title을 대여 행마다 저장하면 회원과 도서의 현재 정보를 여러 곳에서 관리하게 됩니다. 이 값들은 변경될 때 복사본이 서로 달라질 수 있으므로 위험한 중복입니다.`
  });

  patchByTitle('먼저 한 행이 무엇을 나타내는지 정의합니다', {
    s: `정규화를 시작할 때는 테이블 이름보다 한 행의 의미를 먼저 정의합니다.

members의 한 행은 회원 한 명, books의 한 행은 도서 한 권, loans의 한 행은 대여 사건 한 건을 나타냅니다.

한 행의 의미가 분명하면 어떤 컬럼이 그 행에 속하는지도 판단하기 쉬워집니다. 회원의 현재 정보는 members에, 도서의 현재 정보는 books에, 대여 시각과 반납 상태는 loans에 두는 이유가 여기에서 나옵니다.`
  });

  patchByTitle('각 컬럼의 주인을 찾습니다', {
    s: `각 컬럼이 누구를 설명하는지 확인해 저장 위치를 정합니다.

회원 이름과 이메일은 회원이 대여하지 않는 동안에도 존재하고 회원 정보가 바뀔 때 함께 변경되므로 members의 컬럼입니다. 책 제목과 저자는 도서를 설명하므로 books에 둡니다.

대여일, 반납예정일, 실제반납일은 특정 대여 사건의 상태이므로 loans에 둡니다. loans에는 회원과 도서를 연결하기 위한 member_id와 book_id도 함께 저장합니다.`
  });

  patchByTitle('같은 회원 ID에 두 이메일이 저장되면 어느 값이 맞을까요?', {
    s: `같은 시점에 member_id 101이 같은 회원을 뜻한다면 현재 이메일도 하나로 정해져야 합니다.

그런데 같은 회원 번호에 서로 다른 이메일이 저장되어 있다면 두 값 중 어느 것이 현재 정보인지 결정할 수 없습니다. 이것은 샘플 데이터의 우연한 문제가 아니라 같은 현재 사실을 여러 곳에서 관리한 구조적 문제입니다.

따라서 member_id가 결정되면 회원의 현재 이름과 이메일이 하나로 결정된다는 업무 규칙을 세우고, 해당 정보는 members의 한 행에서 관리합니다.`
  });

  patchByTitle('한 값이 정해지면 다른 값도 하나로 정해집니다', {
    s: `정의된 업무 범위에서 같은 기준 값이면 다른 값도 항상 같아야 하는 관계를 함수적 종속이라고 합니다.

member_id가 정해지면 회원 이름과 현재 이메일이 정해지고, book_id가 정해지면 책 제목과 저자가 정해집니다. loan_id는 대여 사건 한 건을 식별하므로 회원, 도서와 대여 날짜를 결정합니다.

이 관계는 샘플에서 값이 우연히 반복되기 때문에 생기는 것이 아닙니다. 업무 규칙상 같은 식별자가 같은 대상을 가리켜야 하기 때문에 성립하며, 컬럼의 주인 테이블을 판단하는 근거가 됩니다.`
  });

  patchByTitle('제1정규형은 한 셀의 독립 값을 확인합니다', {
    s: `제1정규형에서는 한 셀에 업무상 독립적으로 다뤄야 할 값의 목록을 넣지 않습니다.

예를 들어 book_ids에 201과 202를 쉼표로 묶어 저장하면 책별 검색과 외래키 연결이 어렵고, 한 권만 추가하거나 삭제할 때 문자열을 다시 편집해야 합니다.

각 대여를 별도 행으로 만들면 회원 101과 책 201의 관계, 회원 101과 책 202의 관계를 각각 독립적으로 관리할 수 있습니다. book1, book2처럼 반복 열을 계속 추가하는 방식도 같은 이유로 피합니다.`
  });

  patchByTitle('제2정규형은 복합키 일부 의존을 찾습니다', {
    h: `<h2>제2정규형: 복합키 일부에만<br>의존하는 컬럼을 분리합니다</h2>
<p class="body-text" style="font-size:25px">한 학생이 같은 강의를 한 번만 수강한다고 가정합니다.</p>
<div class="table-wrap"><table><thead><tr><th>student_id</th><th>course_id</th><th>student_name</th><th>course_name</th><th>grade</th></tr></thead><tbody><tr><td>1</td><td>101</td><td>김민지</td><td>데이터베이스</td><td>A</td></tr><tr><td>1</td><td>102</td><td>김민지</td><td>알고리즘</td><td>B</td></tr><tr><td>2</td><td>101</td><td>이준호</td><td>데이터베이스</td><td>A</td></tr></tbody></table></div>
<div class="grid-3" style="margin-top:20px"><article class="card"><h3>student_id</h3><p>student_name 결정</p></article><article class="card"><h3>course_id</h3><p>course_name 결정</p></article><article class="card emphasis"><h3>전체 복합키</h3><p>grade 결정</p></article></div>`,
    s: `제2정규형은 제1정규형을 만족한 상태에서 복합 후보키의 일부에만 의존하는 일반 컬럼이 있는지 확인합니다.

이 예제에서는 한 학생이 같은 강의를 한 번만 수강한다고 가정해 student_id와 course_id의 조합을 키로 봅니다. 성적은 학생과 강의가 모두 정해져야 결정됩니다.

하지만 student_name은 student_id만으로 결정되고, course_name은 course_id만으로 결정됩니다. 따라서 학생 이름은 students로, 강의 이름은 courses로 옮기고 enrollments에는 두 식별자와 성적을 둡니다.

재수강이나 학기, 분반을 관리한다면 term_id나 section_id 같은 식별 요소가 키에 추가되어야 합니다. 이 업무 가정을 빼면 복합키 자체가 실제 대상을 올바르게 식별하지 못할 수 있습니다.`
  });

  patchByTitle('제3정규형은 일반 컬럼 사이의 의존을 찾습니다', {
    h: `<h2>제3정규형: 일반 컬럼 사이의<br>결정 관계를 분리합니다</h2>
<p class="body-text" style="font-size:25px">설명을 위해 하나의 우편번호가 하나의 도시를 결정한다고 가정합니다.</p>
<div class="table-wrap"><table><thead><tr><th>member_id</th><th>member_name</th><th>zip_code</th><th>city</th></tr></thead><tbody><tr><td>1</td><td>김민지</td><td>04524</td><td>서울</td></tr><tr><td>2</td><td>이준호</td><td>04524</td><td>서울</td></tr><tr><td>3</td><td>박서연</td><td>48058</td><td>부산</td></tr></tbody></table></div>
<div class="flow" style="margin-top:22px"><div class="flow-step">member_id</div><div class="flow-arrow">→</div><div class="flow-step">zip_code</div><div class="flow-arrow">→</div><div class="flow-step current">city</div></div>`,
    s: `제3정규형은 제2정규형을 만족한 상태에서 기본키가 아닌 컬럼이 다른 일반 컬럼을 결정하는지 확인합니다.

이 예제에서는 하나의 우편번호가 하나의 도시를 결정한다고 단순하게 가정합니다. member_id가 회원의 zip_code를 결정하고, zip_code가 city를 결정합니다. 따라서 city는 회원 아이디보다 우편번호에 직접 의존합니다.

city를 회원 행마다 저장하면 같은 우편번호의 도시명을 여러 곳에서 수정해야 합니다. zip_codes 테이블에서 우편번호와 도시를 한 번 관리하고 members는 zip_code를 참조하도록 분리할 수 있습니다.

실제 주소 체계에서는 이 결정 관계가 업무 범위에서 정말 성립하는지 기준 데이터와 정책을 먼저 확인해야 합니다.`
  });

  patchByTitle('원시 테이블을 회원·도서·대여로 분리합니다', {
    s: `원시 테이블에는 회원의 현재 정보, 도서의 현재 정보와 대여 사건이 한 행에 섞여 있습니다.

정규화 후 members는 회원 한 명과 현재 회원 정보를, books는 도서 한 권과 현재 도서 정보를, loans는 회원이 도서를 빌린 사건을 관리합니다. loans의 member_id와 book_id가 세 테이블의 관계를 연결합니다.

이때 joined_at이나 ISBN처럼 원시 테이블에 없던 속성이 정규화만으로 자동 생성되는 것은 아닙니다. 이런 값은 전체 요구사항에서 확인하거나 별도로 수집해야 합니다.`
  });

  patchByTitle('정규화가 끝나도 업무 정책은 별도로 결정해야 합니다', {
    h: `<h2>미확정 질문을<br>Chapter 06 실습 규칙으로 확정합니다</h2>
<div class="table-wrap"><table><thead><tr><th>ID</th><th>Chapter 06 확정 규칙</th><th>구현</th></tr></thead><tbody><tr><td>C-01</td><td>정확히 같은 이메일 문자열의 중복 금지</td><td><strong>UNIQUE(email)</strong></td></tr><tr><td>C-02</td><td>같은 ISBN 문자열의 도서 중복 금지</td><td><strong>UNIQUE(isbn)</strong></td></tr><tr><td>C-07</td><td>대여 이력이 있는 회원·도서 삭제 제한</td><td>ON DELETE RESTRICT</td></tr><tr><td>C-08</td><td>도서당 미반납 대여 최대 한 건</td><td>부분 고유 인덱스</td></tr></tbody></table></div>
<div class="quote" style="margin-top:20px;font-size:26px">이메일 대소문자, 동일 ISBN 복본과 여러 저자 관리는 이번 실습 범위에서 제외합니다.</div>`,
    s: `Chapter 05에서는 이메일과 ISBN의 고유성, 삭제 정책과 동시 대여 규칙을 미확정 질문으로 남겼습니다. Chapter 06 실습에서는 제약조건을 구현하기 위해 이 가운데 필요한 정책을 명시적으로 확정합니다.

C-01은 정확히 같은 이메일 문자열의 중복을 금지하고, C-02는 같은 ISBN 문자열의 도서 중복을 금지합니다. 따라서 두 컬럼에는 유니크 제약조건을 적용합니다.

C-07은 대여 이력이 있는 회원과 도서를 바로 삭제하지 않도록 제한하고, C-08은 같은 도서의 미반납 대여를 한 건으로 제한합니다.

다만 이메일의 대소문자를 같은 값으로 볼지, 동일 ISBN의 복본을 어떻게 관리할지, 한 책에 여러 저자를 어떻게 표현할지는 이번 실습 범위에서 제외합니다. 확정한 범위와 제외한 범위를 함께 제시해야 제약조건의 의미가 분명해집니다.`
  });

  patchByTitle('정규화해도 잘못된 값은 입력할 수 있습니다', {
    h: `<h2>정규화해도<br>잘못된 값은 입력할 수 있습니다</h2>
<div class="table-wrap"><table><thead><tr><th>입력하려는 데이터</th><th>남아 있는 문제</th></tr></thead><tbody><tr><td>이름이 없는 회원</td><td>필수 정보 누락</td></tr><tr><td>정확히 같은 이메일 문자열의 회원</td><td>C-01 고유성 위반</td></tr><tr><td>회원 999의 대여</td><td>존재하지 않는 대상 참조</td></tr><tr><td>반납예정일이 대여일보다 빠름</td><td>날짜 규칙 위반</td></tr><tr><td>같은 책의 미반납 대여 두 건</td><td>활성 대여 규칙 위반</td></tr></tbody></table></div>
<div class="quote" style="margin-top:18px;font-size:26px">정규화는 저장 위치를 정하고, 제약조건은 허용되는 값과 관계의 경계를 정합니다.</div>`,
    s: `회원, 도서와 대여를 올바르게 분리해도 잘못된 값이 자동으로 차단되지는 않습니다.

이름을 비워 두거나, 이번 실습에서 금지한 동일 이메일 문자열을 다시 입력할 수 있습니다. 존재하지 않는 회원 번호를 참조하거나 날짜의 순서를 거꾸로 입력할 수도 있습니다. 같은 책에 미반납 대여를 두 건 만들 가능성도 남아 있습니다.

정규화는 어떤 사실을 어느 테이블에 저장할지 정합니다. 저장하려는 값과 관계가 확정된 업무 규칙에 맞는지는 NOT NULL, UNIQUE, FOREIGN KEY, CHECK와 부분 고유 인덱스 같은 별도의 규칙으로 검사해야 합니다.`
  });

  patchByTitle('오류마다 막아야 할 규칙이 다릅니다', {
    h: `<h2>확정된 오류마다 막아야 할<br>데이터베이스 규칙이 다릅니다</h2>
<div class="table-wrap"><table><thead><tr><th>잘못된 입력</th><th>적용할 규칙</th><th>역할</th></tr></thead><tbody><tr><td>회원 이름 NULL</td><td>NOT NULL</td><td>필수값 확인</td></tr><tr><td>중복 이메일·ISBN 문자열</td><td>UNIQUE</td><td>C-01·C-02 구현</td></tr><tr><td>존재하지 않는 부모 참조</td><td>FOREIGN KEY</td><td>관계 유효성 확인</td></tr><tr><td>잘못된 날짜 순서</td><td>CHECK</td><td>값의 조건 확인</td></tr><tr><td>두 번째 활성 대여</td><td>부분 고유 인덱스</td><td>C-08 조건부 중복 금지</td></tr></tbody></table></div>
<div class="quote" style="margin-top:18px;font-size:26px">제약조건은 편의 기능이 아니라 확정된 업무 규칙의 구현입니다.</div>`,
    s: `오류의 종류에 따라 데이터베이스가 검사해야 할 방식이 다릅니다.

필수 이름은 낫 널이 검사합니다. Chapter 06에서 확정한 동일 이메일과 ISBN 문자열의 중복 금지는 유니크 제약조건으로 구현합니다. 존재하지 않는 회원이나 도서를 가리키는 관계는 외래키가 차단하고, 날짜의 선후 관계는 체크 제약조건이 검사합니다.

같은 책의 미반납 대여는 모든 행을 대상으로 하는 일반 유니크가 아니라 returned_at이 널인 행만 대상으로 하는 부분 고유 인덱스로 제한합니다.

중요한 점은 제약조건을 많이 추가하는 것이 아닙니다. 각 규칙이 어떤 확정 요구사항을 구현하는지 설명할 수 있어야 합니다.`
  });

  patchByTitle('AI가 만든 DDL은 근거와 실행 결과로 검토합니다', {
    h: `<h2>AI가 만든 DDL은<br>확정 규칙과 실행 결과로 검토합니다</h2>
<div class="table-wrap"><table><thead><tr><th>AI 제안</th><th>검토 기준</th><th>확인 방법</th></tr></thead><tbody><tr><td>email UNIQUE</td><td>C-01과 일치하는가?<br>대소문자 범위를 넘지 않는가?</td><td>규칙표·중복 테스트</td></tr><tr><td>모든 FK CASCADE</td><td>C-07의 이력 보존과 충돌하지 않는가?</td><td>삭제 영향 비교</td></tr><tr><td>날짜 CHECK 없음</td><td>C-04·C-05를 빠뜨리지 않았는가?</td><td>오류 날짜 실행</td></tr><tr><td>활성 대여 제한 없음</td><td>C-08을 구현했는가?</td><td>두 번째 미반납 대여 실행</td></tr></tbody></table></div>
<div class="quote" style="margin-top:18px;font-size:24px">규칙 ID 확인 → DDL 검토 → 정상·경계·오류 실행 순서로 검증합니다.</div>`,
    s: `에이아이는 DDL 초안을 빠르게 만들 수 있지만, 확정하지 않은 정책을 임의로 추가하거나 필요한 규칙을 빠뜨릴 수 있습니다.

예를 들어 email UNIQUE는 Chapter 06의 C-01과 일치하지만, 이메일 대소문자까지 같은 값으로 처리하도록 확장하면 이번 실습 범위를 넘어섭니다. 모든 외래키에 캐스케이드를 붙이면 C-07의 대여 이력 보존 정책과 충돌할 수 있습니다.

날짜 체크와 활성 대여 제한이 빠져 있다면 문법적으로 테이블은 생성되더라도 잘못된 상태를 저장할 수 있습니다.

따라서 AI 제안은 먼저 규칙 ID와 연결하고, 생성된 DDL을 읽은 뒤 정상값과 경계값은 성공하고 오류값은 정확한 규칙으로 실패하는지 실행해 확인합니다.`
  });
})();
