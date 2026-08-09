(() => {
  'use strict';

  const base = window.CH4Navigation;
  if (!base) return;

  const patchTheoryVisuals = () => {
    const slides = window.CH4_SLIDES;
    if (!Array.isArray(slides) || !slides.length) return;
    if (String(window.CH4_TITLE || '').includes('실습')) return;

    const setHtml = (key, html) => {
      const slide = slides.find((item) => item?.k === key);
      if (slide) slide.h = html;
    };

    setHtml('CRUD OVERVIEW', `<h2>CRUD는 서비스 기능과<br>SQL 명령으로 연결됩니다</h2><div class="table-wrap"><table><thead><tr><th>CRUD</th><th>SQL</th><th>서비스 기능 예시</th></tr></thead><tbody><tr><td>Create</td><td>INSERT</td><td>학생 등록</td></tr><tr><td>Read</td><td>SELECT</td><td>학생 목록 확인</td></tr><tr><td>Update</td><td>UPDATE</td><td>학생 정보 변경</td></tr><tr><td>Delete</td><td>DELETE</td><td>학생 정보 삭제</td></tr></tbody></table></div><p class="body-text">CRUD의 Create는 INSERT이며 CREATE TABLE과는 다른 개념입니다.</p>`);

    setHtml('EXECUTION LOCATION', `<h2>SQL 실행 전에는<br>위치를 먼저 확인합니다</h2><pre>SELECT current_database();\nSELECT current_schema();\nSHOW search_path;</pre><p class="body-text">실습 SQL은 public.students처럼 Schema를 직접 적어 작업 대상을 명확하게 지정합니다.</p>`);

    setHtml('IDENTITY', `<h2>IDENTITY 값은<br>빈틈없는 순번이 아닙니다</h2><div class="quote">id는 Row 식별자입니다.<br>현재 학생 수나 완벽한 순번이 아닙니다.</div><p class="body-text">입력 실패, 삭제, 취소 등으로 번호 공백이 생길 수 있습니다. 학생 수는 COUNT(*)로 확인합니다.</p>`);

    setHtml('LIKE ILIKE', `<h2>LIKE와 ILIKE는<br>문자열 패턴 검색에 사용합니다</h2><div class="table-wrap"><table><thead><tr><th>패턴</th><th>의미</th></tr></thead><tbody><tr><td>'김%'</td><td>김으로 시작</td></tr><tr><td>'%민%'</td><td>중간에 민 포함</td></tr><tr><td>'%우'</td><td>우로 끝남</td></tr><tr><td>'김__'</td><td>김 뒤 정확히 두 글자</td></tr></tbody></table></div><p class="body-text">PostgreSQL에서는 ILIKE로 대소문자를 구분하지 않는 패턴 검색을 할 수 있습니다.</p>`);

    setHtml('NULL', `<h2>NULL은 0이나 빈 문자열이 아닙니다</h2><div class="quote">NULL = 값이 없거나<br>아직 알려지지 않은 상태</div><div class="grid-2"><article class="card"><h3>잘못된 비교</h3><pre>WHERE major = NULL</pre></article><article class="card emphasis"><h3>올바른 확인</h3><pre>WHERE major IS NULL\nWHERE major IS NOT NULL</pre></article></div><p class="body-text">0, 빈 문자열, NULL은 서로 다른 상태입니다.</p>`);
  };

  patchTheoryVisuals();

  const THEORY_TTS_SCRIPTS = Object.freeze({
      'CHAPTER 04 · THEORY': `안녕하세요. 4장은 관계형 데이터베이스와 에스큐엘을 실제로 시작하는 장입니다. 이번 장부터 처음으로 테이블을 만들고, 데이터를 입력하고, 조회하고, 수정하고, 삭제합니다.

이론 강의에서는 바로 코드를 실행하기보다 먼저 기본 개념과 안전한 실행 순서를 정리하겠습니다. 어떤 에스큐엘을 실행하는지뿐 아니라, 실행하면 데이터가 어떻게 달라지는지도 함께 살펴보겠습니다.

특히 이번 장에서는 에스큐엘이 오류 없이 실행됐다는 사실만으로 끝내지 않습니다. 실행 전에 결과를 예상하고, 실행 후에는 실제 결과가 예상과 같은지 확인하는 습관을 익히겠습니다.`,
      'CHAPTER GOALS': `4장의 목표는 첫 번째 테이블을 직접 만들고 기본적인 데이터 처리를 안전하게 실행하는 것입니다.

먼저 현재 어떤 데이터베이스와 스키마에서 작업하고 있는지 확인합니다. 그다음 테이블을 만들고, 각 열의 데이터 타입과 규칙이 무엇을 의미하는지 살펴봅니다.

테이블이 준비되면 데이터를 입력하고, 조회하고, 수정하고, 삭제하는 기본 작업을 직접 수행합니다. 조건을 사용해 필요한 데이터만 찾고, 널과 정렬도 함께 다룹니다.

마지막으로 실행 전에 예상했던 결과와 실제 결과가 같은지 비교할 수 있어야 합니다. 이번 장에서는 이 검증 습관을 에스큐엘 문법만큼 중요하게 다루겠습니다.`,
      'CHAPTER FLOW': `이번 장의 학습 흐름을 보겠습니다. 가장 먼저 실행 위치를 확인합니다. 현재 데이터베이스가 에이아이 데이터베이스 북인지 확인하고, 이번 실습의 대상이 퍼블릭 스키마의 스튜던츠 테이블이라는 점을 분명히 합니다.

그다음 학생 테이블을 만들고 데이터를 입력합니다. 입력이 끝나면 셀렉트로 데이터를 조회하면서 원하는 열과 행을 선택하는 방법을 익힙니다.

이후에는 웨어 조건, 정렬, 널을 이용해 필요한 데이터를 찾습니다. 마지막으로 업데이트와 딜리트로 데이터를 변경하고, 변경 전후의 상태를 비교합니다.

전체 흐름은 실행 위치 확인, 테이블 생성, 데이터 입력과 조회, 조건과 정렬 그리고 널, 수정과 삭제, 결과 검증 순서로 이어집니다.`,
      'LEARNING LOOP': `이번 장에서 반복해서 사용할 학습 방법입니다. 먼저 에스큐엘을 읽고, 이 명령을 실행하면 어떤 결과가 나올지 예상합니다.

예를 들어 어떤 열이 표시될지, 몇 명의 학생이 조회될지, 또는 몇 개의 행이 수정될지를 먼저 생각해 봅니다. 그다음 실제로 에스큐엘을 실행합니다.

실행이 끝나면 예상했던 결과와 실제 결과를 비교합니다. 에스큐엘이 오류 없이 실행됐다고 해서 항상 올바른 결과가 나온 것은 아닙니다.

반환된 행의 수, 변경된 행의 수, 정렬 순서, 널 처리까지 확인해야 합니다. 앞으로의 실습에서도 이 순서를 반복해서 사용하겠습니다.`,
      'TABLE SCOPE': `이번 장에서 사용할 테이블은 퍼블릭 스키마의 스튜던츠입니다. 퍼블릭 점 스튜던츠라고 읽겠습니다.

이 테이블에서 한 행은 학생 한 명을 의미합니다. 따라서 학생이 여섯 명 저장되어 있다면 기본적으로 여섯 개의 행이 존재한다고 생각할 수 있습니다.

학생 한 명에 대해서는 아이디, 이름, 이메일, 전공, 학년, 등록 시각을 저장합니다. 아이디는 각 학생 행을 구분하는 기본키로 사용합니다.

여기서 한 행이 무엇을 의미하는지 먼저 이해하는 것이 중요합니다. 그래야 이후에 데이터를 조회하거나 수정하고 삭제할 때, 에스큐엘이 실제로 몇 명의 학생에게 영향을 주는지 정확하게 해석할 수 있습니다.`,
      'CRUD OVERVIEW': `크러드는 애플리케이션에서 가장 자주 사용하는 네 가지 기본 데이터 작업을 의미합니다. 크리에이트, 리드, 업데이트, 딜리트입니다.

크리에이트는 새로운 데이터를 추가하는 작업입니다. 에스큐엘에서는 인서트가 여기에 해당합니다. 리드는 저장된 데이터를 조회하는 작업이고, 셀렉트를 사용합니다.

업데이트는 이미 저장된 데이터를 수정하는 작업입니다. 딜리트는 기존 데이터를 삭제하는 작업입니다.

여기서 한 가지 구분해야 할 것이 있습니다. 크러드에서 말하는 크리에이트는 크리에이트 테이블이 아닙니다. 크리에이트 테이블은 데이터가 들어갈 구조를 만드는 명령이고, 크러드의 크리에이트는 그 구조 안에 새로운 데이터 행을 추가하는 작업입니다.`,
      'EXECUTION LOCATION': `에스큐엘을 실행하기 전에 현재 어디에서 작업하고 있는지 먼저 확인합니다.

가장 먼저 커런트 데이터베이스를 확인합니다. 이번 실습에서는 현재 데이터베이스가 에이아이 데이터베이스 북이어야 합니다.

커런트 스키마는 검색 경로에서 현재 선택되는 첫 번째 유효 스키마를 보여 줍니다. 이 값은 환경에 따라 퍼블릭이 아닐 수도 있습니다. 서치 패스는 스키마 이름을 생략했을 때 어떤 스키마를 차례로 찾을지 보여 주는 설정입니다.

이번 장의 에스큐엘에서는 퍼블릭 점 스튜던츠처럼 스키마 이름을 직접 적습니다. 이렇게 하면 현재 스키마가 무엇이든 실제 작업 대상을 퍼블릭 스키마의 스튜던츠 테이블로 명확하게 지정할 수 있습니다.`,
      'CREATE TABLE': `이제 실제로 테이블의 구조를 살펴보겠습니다. 크리에이트 테이블은 데이터를 입력하는 명령이 아니라, 데이터가 들어갈 구조와 규칙을 만드는 명령입니다.

이번 장에서는 퍼블릭 스키마에 스튜던츠 테이블을 만듭니다. 아이디는 각 학생 행을 구분하는 정수형 기본키이고, 아이덴티티를 사용해 자동으로 생성합니다.

이름과 이메일은 반드시 값이 있어야 합니다. 이메일에는 유니크 규칙도 적용되어 있기 때문에 같은 이메일 문자열을 중복해서 저장할 수 없습니다.

전공과 학년은 선택값입니다. 값을 모르는 경우에는 널을 저장할 수 있습니다. 등록 시각에는 타임스탬프 위드 타임존 타입을 사용하고, 값을 직접 넣지 않으면 커런트 타임스탬프가 기본값으로 들어갑니다.`,
      'COLUMN MEANING': `테이블의 열은 이름만 보는 것이 아니라 데이터 타입과 규칙을 함께 읽어야 합니다.

아이디는 정수형이고, 아이덴티티와 프라이머리 키 규칙이 적용되어 있습니다. 각 학생 행을 구분하기 위한 내부 식별자입니다.

이름은 문자열이고 반드시 입력해야 합니다. 이메일도 문자열이며 반드시 값이 있어야 하고, 같은 이메일을 중복해서 저장할 수 없습니다.

전공은 문자열이고 학년은 정수형입니다. 두 열에는 낫 널 규칙이 없기 때문에 값을 입력하지 않으면 널이 저장될 수 있습니다.

이처럼 열을 볼 때는 어떤 값을 저장하는지만 보지 말고, 어떤 타입인지 그리고 어떤 규칙이 적용되어 있는지를 함께 읽어야 합니다.`,
      'IDENTITY': `아이덴티티로 자동 생성되는 아이디는 각 행을 고유하게 구분하기 위한 값입니다. 학생 수를 의미하는 숫자가 아닙니다.

예를 들어 입력이 실패하거나, 기존 행을 삭제하거나, 트랜잭션이 취소되는 과정에서 아이디 번호 사이에 빈 구간이 생길 수 있습니다.

따라서 가장 큰 아이디 값이 6이라고 해서 현재 학생이 반드시 여섯 명이라고 판단하면 안 됩니다.

현재 저장되어 있는 학생 수를 알고 싶다면 아이디 값이 아니라 카운트 별표로 실제 행의 개수를 세어야 합니다. 업무에서 사용하는 학번처럼 별도의 의미가 있는 번호가 필요하다면 그것도 아이디와 구분해서 따로 설계해야 합니다.`,
      'CURRENT TIMESTAMP': `등록 시각에는 포스트그레스큐엘의 타임스탬프 위드 타임존 타입을 사용합니다. 날짜와 시각을 다룰 때 시간대까지 고려할 수 있는 타입입니다.

스튜던츠 테이블에서는 등록 시각에 디폴트 커런트 타임스탬프를 지정했습니다. 따라서 새로운 학생을 입력할 때 등록 시각을 직접 넣지 않아도 포스트그레스큐엘이 자동으로 값을 저장합니다.

여기서 커런트 타임스탬프는 단순히 에스큐엘 문장이 실행되는 순간마다 새로운 시간을 가져오는 것으로 생각하면 안 됩니다. 포스트그레스큐엘에서는 현재 트랜잭션을 기준으로 시각이 정해집니다.

따라서 같은 트랜잭션 안에서 여러 학생을 입력하면 등록 시각이 같을 수도 있습니다. 최신 데이터를 정확한 순서로 보고 싶다면 등록 시각 하나만 사용하기보다 아이디 같은 보조 정렬 기준을 함께 사용하는 것이 좋습니다.`,
      'INSERT': `이제 테이블에 실제 데이터를 추가하는 인서트를 보겠습니다. 인서트는 기존 테이블에 새로운 행을 추가하는 명령입니다.

화면의 예제에서는 이름, 이메일, 전공, 학년 값을 직접 입력합니다. 문자열 값은 작은따옴표로 감싸고, 학년처럼 숫자로 저장하는 값은 따옴표 없이 입력합니다.

아이디와 등록 시각은 직접 입력하지 않았습니다. 아이디는 아이덴티티에 의해 자동으로 생성되고, 등록 시각은 앞에서 지정한 기본값에 의해 자동으로 들어갑니다.

마지막에 리터닝을 사용하면 방금 추가된 행의 값을 바로 볼 수 있습니다. 여기서는 자동으로 생성된 아이디와 이름, 등록 시각을 확인합니다.

리터닝을 사용하면 인서트가 끝난 뒤 별도의 셀렉트를 다시 작성하지 않아도 실제로 어떤 행이 추가되었는지 바로 확인할 수 있습니다.`,
      'SELECT': `데이터를 저장했다면 이제 셀렉트로 조회할 수 있습니다. 셀렉트는 테이블에 저장된 데이터를 읽어 오는 가장 기본적인 에스큐엘 명령입니다.

셀렉트 별표를 사용하면 테이블의 모든 열을 조회합니다. 테이블의 전체 구조와 데이터를 처음 확인할 때는 편리하게 사용할 수 있습니다.

하지만 항상 모든 열이 필요한 것은 아닙니다. 이름, 이메일, 전공처럼 필요한 열만 지정하면 결과에 어떤 정보가 포함되는지 더 명확하게 알 수 있습니다.

조회 결과를 볼 때는 값만 보지 말고 몇 가지를 함께 살펴봅니다. 어떤 열이 반환되었는지, 몇 개의 행이 나왔는지, 정렬 기준이 있는지, 그리고 예상했던 데이터가 실제로 조회되었는지를 봅니다.`,
      'ORDER WARNING': `셀렉트 결과에서 특히 주의해야 할 것이 행의 순서입니다. 오더 바이가 없는 조회 결과는 특정한 순서를 보장하지 않습니다.

화면에서는 데이터를 입력한 순서나 아이디 순서대로 보일 수도 있습니다. 하지만 지금 그렇게 보인다고 해서 다음 실행에서도 같은 순서가 나온다고 가정하면 안 됩니다.

데이터를 반드시 정해진 순서로 보고 싶다면 오더 바이를 사용해 정렬 기준을 직접 지정해야 합니다.

화면의 예제에서는 아이디를 오름차순으로 정렬합니다. 따라서 아이디가 작은 학생부터 큰 학생 순서로 결과를 볼 수 있습니다.

데이터베이스에서는 화면에 우연히 보이는 순서와 에스큐엘로 명시한 순서를 구분해야 합니다.`,
      'WHERE': `전체 데이터를 조회하는 방법을 알았으니 이제 필요한 행만 선택해 보겠습니다. 이때 사용하는 것이 웨어 조건입니다.

화면의 예제는 전공이 컴퓨터공학인 학생만 조회합니다. 메이저 열의 값이 컴퓨터공학과 같은 행만 결과에 남게 됩니다.

컴퓨터공학처럼 문자열 값을 비교할 때는 값을 작은따옴표로 감쌉니다. 반면 학년처럼 정수 타입의 숫자를 비교할 때는 일반적으로 따옴표 없이 숫자를 사용합니다.

웨어 조건을 읽을 때는 먼저 어떤 열을 보고 있는지 확인하고, 그 열을 어떤 값과 어떤 연산자로 비교하는지 살펴보면 됩니다.

예를 들어 메이저가 컴퓨터공학과 같은가, 또는 학년이 3 이상인가처럼 자연어 문장으로 먼저 읽어 보면 조건을 훨씬 쉽게 이해할 수 있습니다.`,
      'AND OR IN': `하나의 웨어 조건만으로 부족할 때는 앤드, 오알, 인을 사용해 여러 조건을 조합할 수 있습니다.

앤드는 여러 조건을 모두 만족하는 행을 선택합니다. 예를 들어 전공이 컴퓨터공학이면서 학년이 2학년인 학생처럼 두 조건이 모두 참이어야 할 때 사용합니다.

오알은 여러 조건 가운데 하나 이상을 만족하면 됩니다. 예를 들어 학년이 2학년이거나 3학년인 학생을 찾는 경우입니다.

같은 열을 여러 값과 비교할 때는 인을 사용하면 조건을 더 간결하게 표현할 수 있습니다. 학년이 2 또는 3인지를 여러 개의 오알로 작성하는 대신, 후보값을 한 번에 지정할 수 있습니다.

앤드와 오알을 함께 사용할 때는 괄호를 사용해 조건의 범위를 명확하게 표현하는 것이 좋습니다. 문법적으로 실행되는 것과 내가 의도한 조건으로 실행되는 것은 다를 수 있기 때문입니다.`,
      'LIKE ILIKE': `문자열의 일부가 일치하는 데이터를 찾을 때는 라이크를 사용합니다.

예를 들어 김 퍼센트는 김으로 시작하는 문자열을 찾습니다. 퍼센트 기호는 문자가 하나도 없거나, 하나 이상 이어지는 모든 경우를 의미합니다.

퍼센트 민 퍼센트처럼 앞뒤에 퍼센트 기호를 사용하면 문자열 중간에 민이라는 글자가 포함된 경우를 찾을 수 있습니다. 퍼센트 우는 우로 끝나는 문자열을 찾습니다.

언더스코어는 퍼센트와 의미가 다릅니다. 퍼센트가 길이에 제한이 없는 여러 문자를 의미한다면, 언더스코어는 정확히 한 문자를 의미합니다.

포스트그레스큐엘에서는 대소문자를 구분하지 않고 문자열 패턴을 검색할 때 아이라이크를 사용할 수 있습니다. 아이라이크는 포스트그레스큐엘에서 제공하는 문법이므로 다른 데이터베이스에서는 사용 방법이 다를 수 있습니다.`,
      'NULL': `이번에는 널을 살펴보겠습니다. 널은 숫자 0이나 빈 문자열과 같은 하나의 값이 아닙니다. 값이 없거나 아직 알려지지 않은 상태를 나타냅니다.

그래서 전공이 널인지 찾으면서 메이저 이퀄 널처럼 일반적인 등호 비교를 사용하면 원하는 결과를 얻을 수 없습니다.

에스큐엘에서 널을 일반 값과 비교하면 결과가 단순히 참이나 거짓으로 결정되지 않고, 알 수 없음을 의미하는 언노운 상태가 될 수 있습니다.

널인 행을 찾으려면 이즈 널을 사용합니다. 반대로 값이 들어 있는 행을 찾으려면 이즈 낫 널을 사용합니다.

따라서 널을 다룰 때는 0, 빈 문자열, 널을 서로 다른 상태로 구분해서 생각해야 합니다.`,
      'ORDER LIMIT': `조회 결과의 순서를 정할 때는 오더 바이를 사용하고, 그중 일부 행만 가져오고 싶을 때는 리밋을 사용합니다.

예를 들어 학년이 높은 학생부터 보고 싶다면 학년을 내림차순으로 정렬할 수 있습니다. 그런데 윤서진처럼 학년이 널인 학생도 있기 때문에, 널을 결과의 마지막에 두고 싶다면 널스 라스트를 사용할 수 있습니다.

최신 학생 세 명처럼 일부 데이터만 가져오는 경우에는 먼저 어떤 기준으로 최신을 판단할지 정해야 합니다. 화면의 예제에서는 등록 시각을 내림차순으로 정렬한 뒤 리밋 3을 적용합니다.

하지만 여러 학생의 등록 시각이 같을 수도 있습니다. 이런 경우 결과 순서를 안정적으로 만들기 위해 아이디 내림차순을 두 번째 정렬 기준으로 사용합니다.

즉, 리밋을 사용할 때는 몇 행을 가져올지만 보는 것이 아니라 어떤 정렬 기준에서 그 행들을 선택하는지도 함께 생각해야 합니다.`,
      'UPDATE SAFETY': `이제 데이터를 조회하는 것에서 실제로 변경하는 작업으로 넘어가겠습니다. 먼저 업데이트입니다.

업데이트는 이미 저장되어 있는 행의 값을 변경합니다. 변경 작업에서는 에스큐엘을 바로 실행하기보다 먼저 같은 웨어 조건으로 셀렉트를 실행해 어떤 행이 대상인지 확인합니다.

대상이 맞다면 업데이트를 실행합니다. 리터닝을 사용하면 실제로 변경된 행과 변경된 값을 바로 볼 수 있습니다.

그다음 디비버의 실행 결과에서 영향받은 행 수가 예상과 같은지 확인합니다. 한 학생만 수정하려고 했다면 실제 영향받은 행 수도 한 행이어야 합니다.

마지막으로 같은 조건으로 다시 셀렉트를 실행해 값이 실제로 변경되었는지 확인합니다.

안전한 업데이트의 흐름은 간단합니다. 먼저 셀렉트로 대상을 확인하고, 업데이트와 리터닝으로 변경 결과를 보고, 영향받은 행 수를 확인한 뒤, 마지막 셀렉트로 최종 상태를 확인합니다.`
  });

  const THEORY_TTS_FOCUS = Object.freeze({
    'CHAPTER 04 · THEORY': [
      { pill: '*' },
      { pill: [0, 1] },
      { pill: [2, 3] }
    ],
    'CHAPTER GOALS': [
      { item: '*' },
      { item: [0, 1] },
      { item: [2, 3] },
      { item: [4] }
    ],
    'CHAPTER FLOW': [
      { flow: [0] },
      { flow: [1, 2] },
      { flow: [3, 4] },
      { flow: '*' }
    ],
    'LEARNING LOOP': [
      { flow: [0, 1] },
      { flow: [1, 2] },
      { flow: [3], quote: '*' },
      { flow: [3], quote: '*' }
    ],
    'TABLE SCOPE': [
      { row: [0, 1] },
      { row: [2] },
      { row: [3, 4] },
      { row: '*' }
    ],
    'CRUD OVERVIEW': [
      { row: '*' },
      { row: [0, 1] },
      { row: [2, 3] },
      { row: [0], body: '*' }
    ],
    'EXECUTION LOCATION': [
      { code: '*' },
      { code: [0] },
      { code: [1, 2] },
      { body: '*' }
    ],
    'CREATE TABLE': [
      { code: '*' },
      { code: [0, 1] },
      { code: [2, 3] },
      { code: [4, 5, 6] }
    ],
    'COLUMN MEANING': [
      { row: '*' },
      { row: [0] },
      { row: [1, 2] },
      { row: [3, 4] },
      { row: '*' }
    ],
    'IDENTITY': [
      { quote: '*' },
      { body: '*' },
      { quote: '*', body: '*' },
      { body: '*' }
    ],
    'CURRENT TIMESTAMP': [
      { card: [0] },
      { card: [1] },
      { card: [1] },
      { card: '*' }
    ],
    'INSERT': [
      { code: [0] },
      { code: [1] },
      { code: [0, 1], body: '*' },
      { code: [2] },
      { code: [2], body: '*' }
    ],
    'SELECT': [
      { card: '*' },
      { card: [0] },
      { card: [1] },
      { card: '*' }
    ],
    'ORDER WARNING': [
      { quote: '*' },
      { quote: '*' },
      { code: [2] },
      { code: '*' },
      { quote: '*' }
    ],
    'WHERE': [
      { code: '*' },
      { code: [2] },
      { body: '*' },
      { code: [2] },
      { body: '*' }
    ],
    'AND OR IN': [
      { card: '*' },
      { card: [0] },
      { card: [1] },
      { card: [2] },
      { body: '*' }
    ],
    'LIKE ILIKE': [
      { row: '*' },
      { row: [0] },
      { row: [1, 2] },
      { row: [3] },
      { body: '*' }
    ],
    'NULL': [
      { quote: '*' },
      { card: [0] },
      { card: [0], quote: '*' },
      { card: [1] },
      { body: '*' }
    ],
    'ORDER LIMIT': [
      { code: '*' },
      { code: [0, 1, 2] },
      { code: [3, 4, 5, 6] },
      { code: [5] },
      { code: [5, 6] }
    ],
    'UPDATE SAFETY': [
      { flow: '*' },
      { flow: [0] },
      { flow: [1] },
      { flow: [2] },
      { flow: [3] },
      { flow: '*' }
    ]
  });

  const keysForSpec = (targets, spec = {}) => {
    const selected = [];
    Object.entries(spec).forEach(([prefix, indexes]) => {
      const available = targets.filter((target) => target.prefix === prefix);
      if (indexes === '*') {
        available.forEach((target) => selected.push(target.key));
        return;
      }
      (Array.isArray(indexes) ? indexes : [indexes]).forEach((index) => {
        const target = available[index];
        if (target) selected.push(target.key);
      });
    });
    return [...new Set(selected)];
  };

  const explicitSteps = (slide) => {
    const key = String(slide?.k || '');
    const script = THEORY_TTS_SCRIPTS[key];
    const plan = THEORY_TTS_FOCUS[key];
    if (!script || !plan) return null;

    const paragraphs = String(script)
      .trim()
      .split(/\n\s*\n/)
      .map((part) => part.replace(/\s+/g, ' ').trim())
      .filter(Boolean);

    if (paragraphs.length !== plan.length) {
      console.warn(`[Chapter04 TTS] ${key}: TTS paragraph count ${paragraphs.length} != focus plan ${plan.length}`);
      return null;
    }

    const detached = document.createElement('div');
    detached.innerHTML = slide?.h || '';
    const targets = base.prepareDOM(detached).map(({ key: targetKey, prefix, index }) => ({
      key: targetKey,
      prefix,
      index
    }));

    return paragraphs.map((text, index) => ({
      text,
      focusKeys: keysForSpec(targets, plan[index])
    }));
  };

  const buildSteps = (slide) => {
    if (!slide) return [];
    if (slide.__chapter04TtsSteps) return slide.__chapter04TtsSteps;
    const steps = explicitSteps(slide) || base.buildSteps(slide);
    slide.__chapter04TtsSteps = steps;
    return steps;
  };

  const applyFocus = (root, slide, stepIndex) => {
    const targets = base.prepareDOM(root);
    targets.forEach(({ element }) => element.classList.remove('focus-muted', 'focus-active'));
    if (stepIndex <= 0) return;
    const step = buildSteps(slide)[stepIndex - 1];
    if (!step || !step.focusKeys.length) return;
    const selected = new Set(step.focusKeys);
    targets.forEach(({ key, element }) => {
      element.classList.add(selected.has(key) ? 'focus-active' : 'focus-muted');
    });
  };

  const clearCache = (slides) => {
    base.clearCache(slides);
    (slides || []).forEach((slide) => {
      if (slide) delete slide.__chapter04TtsSteps;
    });
  };

  window.CH4Navigation = Object.freeze({
    ...base,
    buildSteps,
    applyFocus,
    clearCache
  });
})();
