(() => {
  'use strict';

  const slides = window.CH4_SLIDES;
  if (!Array.isArray(slides) || !slides.length) return;

  const find = (key) => slides.find((slide) => slide?.k === key);
  const set = (key, values) => {
    const slide = find(key);
    if (slide) Object.assign(slide, values);
  };

  const isPractice = String(window.CH4_TITLE || '').includes('실습');

  if (!isPractice) {
    set('CHECKPOINTS', {
      l: '데이터 상태',
      h: `<h2>실습 데이터 상태는<br>자연어로 구분합니다</h2><div class="table-wrap"><table><thead><tr><th>상태</th><th>학생 수</th><th>이준호 학년</th><th>박서연</th></tr></thead><tbody><tr><td>초기 데이터 상태</td><td>6</td><td>3</td><td>존재</td></tr><tr><td>수정 실습 후 상태</td><td>6</td><td>4</td><td>존재</td></tr><tr><td>삭제 실습 후 상태</td><td>5</td><td>4</td><td>삭제</td></tr></tbody></table></div>`,
      s: `실습 중에는 데이터 상태가 계속 바뀝니다. 그래서 문제나 에스큐엘을 해석할 때 현재 상태를 먼저 확인해야 합니다. 처음 여섯 명을 입력한 상태가 초기 데이터 상태입니다. 이준호 학년을 사 학년으로 바꾸면 수정 실습 후 상태가 됩니다. 박서연을 삭제하면 학생이 다섯 명인 삭제 실습 후 상태가 됩니다. 체크포인트 기호보다 실제 데이터 상태를 문장으로 기록하면 다른 독자도 기준을 바로 이해할 수 있습니다.`
    });

    set('AI SQL REVIEW', {
      h: `<h2>AI가 만든 SQL은<br>실행 전에 영향 범위를 검토합니다</h2><ul class="bullet-list"><li>현재 데이터 상태는 무엇인가?</li><li>대상 Table과 Column이 맞는가?</li><li>WHERE 조건이 충분히 좁은가?</li><li>NULL과 정렬 기준을 고려했는가?</li><li>변경 SQL을 바로 실행해도 안전한가?</li></ul>`,
      s: `에이아이가 만든 에스큐엘은 실행 전에 영향 범위를 검토해야 합니다. 먼저 현재 데이터 상태가 초기 상태인지, 수정 후인지, 삭제 후인지 확인합니다. 대상 테이블과 열이 맞는지 보고, 웨어 조건이 충분히 좁은지 확인합니다. 널과 정렬 기준도 검토합니다. 특히 업데이트나 딜리트 같은 변경 에스큐엘은 바로 실행하지 않고 먼저 같은 조건의 셀렉트로 대상 행을 확인해야 합니다.`
    });
    return;
  }

  set('PRACTICE RULE', {
    h: `<h2>실습은 번호 파일을<br>순서대로 사용합니다</h2><div class="grid-2"><article class="card"><h3>권장 흐름</h3><p>01 생성 → 02 입력 → 상태 검증 → 03 조회 → 04 수정·삭제 → 상태 검증</p></article><article class="card emphasis"><h3>통합 파일</h3><p>basic_crud.sql은 기존 링크용 참고 파일이며 기본 실습의 출발점이 아닙니다.</p></article></div>`,
    s: `기본 실습은 번호 파일을 사용합니다. 공일 파일로 테이블을 만들고 공이 파일로 학생 여섯 명을 입력한 뒤, 베리파이 스튜던츠로 초기 상태를 봅니다. 공삼 파일에서 조회를 연습하고 공사 파일에서 수정과 삭제를 실행한 뒤 최종 상태를 다시 검증합니다. 베이식 크러드 에스큐엘은 기존 링크용 통합 참고 파일입니다.`
  });

  set('STEP 02', {
    l: '번호 파일 확인',
    h: `<h2>번호 SQL 파일을<br>순서대로 사용합니다</h2><div class="codebox">01_create_students.sql<br>→ 02_insert_students.sql<br>→ verify_students.sql<br>→ 03_select_students.sql<br>→ 04_update_delete_students.sql<br>→ verify_students.sql</div><ul class="bullet-list"><li>reset_students.sql: 처음부터 다시 시작할 때만 사용</li><li>basic_crud.sql: 기존 링크용 통합 참고</li></ul>`,
    s: `기본 실습은 공일 생성, 공이 입력, 상태 검증, 공삼 조회, 공사 수정과 삭제, 최종 상태 검증 순서입니다. 베리파이 스튜던츠는 데이터를 바꾸지 않습니다. 리셋 스튜던츠는 처음부터 다시 시작할 때만 사용하고, 베이식 크러드 파일은 통합 참고 자료로만 봅니다.`
  });

  set('CHECKPOINT A', {
    l: '초기 데이터 상태',
    h: `<h2>초기 데이터 상태</h2><pre>SELECT COUNT(*) AS student_count\nFROM public.students;</pre><div class="table-wrap"><table><thead><tr><th>항목</th><th>예상 상태</th></tr></thead><tbody><tr><td>학생 수</td><td>6명</td></tr><tr><td>이준호 학년</td><td>3</td></tr><tr><td>박서연</td><td>존재</td></tr><tr><td>NULL 학생</td><td>윤서진</td></tr></tbody></table></div>`,
    s: `초기 데이터에는 학생이 여섯 명 있습니다. 이준호는 삼 학년이고 박서연은 존재합니다. 윤서진의 전공과 학년에는 널이 저장되어 있습니다. 공삼 조회 파일은 이 상태를 기준으로 실행합니다.`
  });

  set('CHECKPOINT B', {
    l: '수정 실습 후 상태',
    h: `<h2>수정 실습 후 상태</h2><div class="table-wrap"><table><thead><tr><th>항목</th><th>상태</th></tr></thead><tbody><tr><td>학생 수</td><td>6명</td></tr><tr><td>이준호 학년</td><td>4</td></tr><tr><td>박서연</td><td>존재</td></tr></tbody></table></div>`,
    s: `수정 실습 후에도 학생은 여섯 명입니다. 이준호의 학년만 사 학년으로 바뀌었고 박서연은 아직 존재합니다.`
  });

  set('CHECKPOINT C', {
    l: '삭제 실습 후 상태',
    h: `<h2>삭제 실습 후 상태</h2><pre>SELECT COUNT(*) AS student_count\nFROM public.students;</pre><div class="table-wrap"><table><thead><tr><th>항목</th><th>상태</th></tr></thead><tbody><tr><td>학생 수</td><td>5명</td></tr><tr><td>이준호 학년</td><td>4</td></tr><tr><td>박서연</td><td>삭제</td></tr></tbody></table></div>`,
    s: `삭제 실습 후에는 학생이 다섯 명입니다. 이준호는 사 학년이고 박서연은 더 이상 존재하지 않습니다.`
  });

  set('STEP 30', {
    h: `<h2>WHERE 없는 UPDATE·DELETE는 실행하지 않습니다</h2><div class="grid-2"><article class="card"><h3>위험한 UPDATE</h3><pre>-- 실행하지 않습니다.\n-- UPDATE public.students\n-- SET grade = 1;</pre></article><article class="card emphasis"><h3>위험한 DELETE</h3><pre>-- 실행하지 않습니다.\n-- DELETE FROM public.students;</pre></article></div><p class="body-text">문법 오류는 아니지만 영향 범위가 전체 Table입니다.</p>`,
    s: `화면의 두 문장은 주석으로 표시한 실행 금지 예제입니다. 웨어 없는 업데이트는 모든 학생의 학년을 바꾸고, 웨어 없는 딜리트는 모든 행을 삭제합니다. 두 문장 모두 문법적으로 유효하기 때문에 더 위험합니다.`
  });

  set('STEP 31', {
    h: `<h2>AI가 만든 DELETE SQL을<br>실행 전 검토합니다</h2><pre>DELETE FROM public.students\nWHERE major = '컴퓨터공학';</pre><ul class="bullet-list"><li>현재 데이터 상태는 무엇인가?</li><li>삭제 대상은 몇 Row인가?</li><li>정말 물리 삭제가 맞는가?</li><li>먼저 SELECT로 대상 확인했는가?</li></ul>`,
    s: `에이아이가 전공이 컴퓨터공학인 학생을 삭제하는 문장을 만들었다고 가정합니다. 먼저 같은 조건의 셀렉트로 김민지와 최현우 두 명이 대상인지 봅니다. 요구사항이 물리 삭제인지도 검토합니다. 이 딜리트 문은 설명용이며 실행하지 않습니다.`
  });

  set('STEP 32', {
    h: `<h2>필요할 때만 reset_students.sql을 사용합니다</h2><div class="codebox">code/chapter04/reset_students.sql</div><ul class="bullet-list"><li>현재 Database가 ai_database_book인지 확인</li><li>삭제 대상이 public.students인지 확인</li><li>읽기 전용 연결이 아닌지 확인</li><li>실습을 처음부터 다시 시작할 때만 실행</li></ul>`,
    s: `실습을 처음부터 다시 시작해야 할 때만 리셋 스튜던츠 에스큐엘을 사용합니다. 이 파일은 현재 데이터베이스가 에이아이 데이터베이스 북인지, 퍼블릭 스키마가 있는지, 읽기 전용 연결이 아닌지를 확인한 뒤 퍼블릭 스튜던츠만 삭제합니다. 단순 오류가 났다고 즉시 실행하지 않습니다.`
  });

  set('PRACTICE SUMMARY', {
    h: `<h2>실습 완료 기준</h2><ul class="bullet-list"><li>번호 SQL 파일의 역할과 실행 순서를 설명한다.</li><li>초기 데이터 상태: 학생 6명·이준호 grade 3</li><li>SELECT, WHERE, LIKE, NULL, ORDER BY, LIMIT 실행</li><li>수정 실습 후 상태: 이준호 grade 4·학생 6명</li><li>삭제 실습 후 상태: 박서연 삭제·학생 5명</li><li>위험 SQL과 AI SQL을 실행 전 검토</li></ul>`,
    s: `퍼블릭 스튜던츠를 만들고 학생 여섯 명을 입력했습니다. 조회 문법을 연습한 뒤 이준호의 학년을 사 학년으로 수정하고 박서연을 삭제했습니다. 최종 상태는 학생 다섯 명, 이준호 사 학년, 박서연 없음입니다. 웨어 없는 변경문과 에이아이가 제안한 딜리트는 영향 범위를 검토한 뒤 실행 여부를 결정합니다.`
  });
})();
