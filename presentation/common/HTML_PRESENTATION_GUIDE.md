# HTML 발표 자료 공통 가이드

## 1. 기본 목적

이 템플릿은 교재 내용을 웹브라우저에서 발표하기 위한 공통 형식입니다.

- 별도 프로그램 없이 HTML 파일을 브라우저에서 실행
- 16:9 화면 비율
- 큰 글자와 높은 가독성
- 키보드·마우스 기반 이전/다음 이동
- 눈에 띄는 발표용 커서
- 단계적 항목 노출
- 발표자 노트
- 인쇄 또는 PDF 저장 지원

---

## 2. 실행 방법

1. `presentation_template.html` 파일을 Chrome 또는 Edge에서 엽니다.
2. `F` 키를 눌러 전체 화면으로 전환합니다.
3. 방향키 또는 화면 우측의 다음 버튼으로 이동합니다.
4. 발표용 커서가 불편하면 `C` 키를 눌러 기본 커서로 전환합니다.
5. 단축키가 기억나지 않으면 `H` 키를 누릅니다.

---

## 3. 주요 조작키

| 키 | 기능 |
|---|---|
| `→`, `↓`, `PageDown`, `Space` | 다음 단계 또는 다음 슬라이드 |
| `←`, `↑`, `PageUp` | 이전 단계 또는 이전 슬라이드 |
| `Home` | 첫 슬라이드 |
| `End` | 마지막 슬라이드 |
| `F` | 전체 화면 전환 |
| `C` | 발표용 커서와 기본 커서 전환 |
| `N` | 현재 슬라이드 발표자 노트 |
| `H` 또는 `?` | 도움말 |
| `Esc` | 열린 창 닫기 |

화면의 왼쪽 32% 영역을 클릭하면 이전으로, 나머지 영역을 클릭하면 다음으로 이동합니다.

---

## 4. 슬라이드 추가 방법

아래 구조를 복사하여 `<main class="viewport">` 안에 추가합니다.

```html
<section class="slide">
  <div class="slide-header">
    <span class="eyebrow">SECTION NAME</span>
    <span class="chapter-label">Chapter 01</span>
  </div>

  <div class="slide-body">
    <h2>슬라이드 제목</h2>
    <p class="lead">핵심 설명을 작성합니다.</p>
  </div>

  <aside class="speaker-notes">
    <p>발표자가 참고할 설명을 작성합니다.</p>
  </aside>
</section>
```

첫 슬라이드에만 `active` 클래스를 둡니다.

```html
<section class="slide active">
```

---

## 5. 콘텐츠 작성 원칙

### 한 장에 핵심 메시지 하나

- 제목은 한 문장으로 작성합니다.
- 본문은 3~5개 항목 이내로 제한합니다.
- 서로 다른 개념이 섞이면 슬라이드를 분리합니다.
- 교재의 문장을 그대로 옮기기보다 발표 흐름에 맞게 줄입니다.

### 글자 크기

- 제목: 42~76px 수준
- 본문: 22~34px 수준
- 보조 설명: 16~24px 수준
- 코드: 18~27px 수준

기본 크기는 CSS의 `:root`에 정의되어 있습니다.

### 첫 수업 권장 흐름

1. 질문
2. 익숙한 사례
3. 짧은 설명
4. 핵심 문장
5. 미니 활동
6. 정리

2시간 수업에서는 35~40장 정도를 기준으로 하되, 질문과 활동 시간을 충분히 둡니다.

---

## 6. 단계적으로 항목 보여 주기

나중에 나타나게 할 요소에 `fragment` 클래스를 추가합니다.

```html
<p class="lead fragment">두 번째로 나타날 문장</p>
```

```html
<ul class="bullet-list">
  <li class="fragment">첫 번째 항목</li>
  <li class="fragment">두 번째 항목</li>
  <li class="fragment">세 번째 항목</li>
</ul>
```

`Space` 또는 다음 키를 누를 때 한 항목씩 나타납니다.

---

## 7. 자주 사용하는 레이아웃

### 두 개 카드

```html
<div class="grid-2">
  <article class="card">
    <h3>왼쪽 제목</h3>
    <p class="small">설명</p>
  </article>

  <article class="card emphasis">
    <h3>오른쪽 제목</h3>
    <p class="small">설명</p>
  </article>
</div>
```

### 세 개 카드

```html
<div class="grid-3">
  <article class="card">...</article>
  <article class="card">...</article>
  <article class="card">...</article>
</div>
```

### 핵심 문장

```html
<div class="quote">
  AI는 초안을 만들고,
  사람은 결과를 검증합니다.
</div>
```

### 목록

```html
<ul class="bullet-list">
  <li>첫 번째 내용</li>
  <li>두 번째 내용</li>
  <li>세 번째 내용</li>
</ul>
```

### 흐름도

```html
<div class="flow">
  <div class="flow-step">요구사항</div>
  <div class="flow-arrow">→</div>
  <div class="flow-step">AI 초안</div>
  <div class="flow-arrow">→</div>
  <div class="flow-step">검증</div>
</div>
```

---

## 8. 코드와 SQL 작성

```html
<pre><code>SELECT *
FROM students
WHERE status = 'active';</code></pre>
```

작성 기준:

- 한 슬라이드에 8~12줄 이내
- 현재 설명하는 구문만 표시
- 긴 쿼리는 여러 슬라이드로 분리
- 강조가 필요하면 코드 아래에 짧은 설명 추가
- 실행 결과 표는 다음 슬라이드에 분리하는 것을 권장

---

## 9. 표 작성

```html
<div class="table-wrap">
  <table>
    <thead>
      <tr>
        <th>구분</th>
        <th>설명</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>기준 데이터</td>
        <td>업무 판단의 근거가 되는 원본 데이터</td>
      </tr>
    </tbody>
  </table>
</div>
```

권장 기준:

- 최대 4열
- 최대 4~5행
- 셀 안에 긴 문장을 넣지 않음
- 상세 비교는 여러 장으로 분리

---

## 10. SVG와 이미지 삽입

```html
<div class="media-frame">
  <img
    src="../../images/chapter01/ch01_01_storage_options.svg"
    alt="데이터 특성에 따른 저장 방식 선택 흐름"
  />
</div>
```

주의사항:

- HTML 파일 위치를 기준으로 상대 경로를 작성합니다.
- `alt` 속성에 그림의 의미를 작성합니다.
- 한 슬라이드에는 핵심 도식 하나만 크게 배치합니다.
- SVG 내부 글자는 발표 화면에서 충분히 크게 보여야 합니다.

---

## 11. 발표자 노트

각 슬라이드 안에 다음과 같이 작성합니다.

```html
<aside class="speaker-notes">
  <p>이 슬라이드에서 강조할 내용입니다.</p>
  <p>학생들에게 먼저 질문한 뒤 설명합니다.</p>
</aside>
```

발표 중 `N` 키를 누르면 현재 슬라이드의 노트가 표시됩니다.

---

## 12. 색상 변경

HTML 상단 CSS의 `:root`에서 변경합니다.

```css
:root {
  --primary: #155eef;
  --accent: #f59e0b;
  --text: #182230;
  --bg: #f6f8fb;
}
```

권장 사항:

- 주 색상은 한 가지
- 보조 강조색은 한 가지
- 빨간색은 오류·주의 또는 발표용 커서에만 사용
- 배경과 글자의 대비를 충분히 확보

---

## 13. 직접 링크

URL 뒤에 슬라이드 번호를 붙이면 해당 장에서 시작합니다.

```text
presentation_template.html#5
```

위 주소는 5번째 슬라이드에서 시작합니다.

---

## 14. PDF 저장

Chrome 또는 Edge에서 다음 순서로 저장합니다.

1. `Ctrl + P`
2. 대상: `PDF로 저장`
3. 레이아웃: `가로`
4. 여백: `없음`
5. 배경 그래픽: `사용`
6. 저장

인쇄 모드에서는 모든 슬라이드가 한 장씩 출력됩니다.

---

## 15. 파일 구성 권장안

장별 발표 자료를 만들 때는 다음 구조를 권장합니다.

```text
presentation/
├─ common/
│  ├─ presentation_template.html
│  └─ HTML_PRESENTATION_GUIDE.md
├─ chapter01/
│  ├─ chapter01.html
│  └─ assets/
├─ chapter02/
│  ├─ chapter02.html
│  └─ assets/
└─ README.md
```

처음에는 단일 HTML 파일로 운영하고, 공통 기능이 안정되면 CSS와 JavaScript를 별도 파일로 분리할 수 있습니다.

---

## 16. 검수 체크리스트

- [ ] 첫 화면에서 주제와 학습 목표가 명확한가?
- [ ] 한 장에 핵심 메시지가 하나인가?
- [ ] 본문 글자가 발표 화면에서 충분히 큰가?
- [ ] 표와 코드가 너무 빽빽하지 않은가?
- [ ] 방향키와 버튼 이동이 정상인가?
- [ ] 단계적 노출 순서가 자연스러운가?
- [ ] 발표용 커서가 잘 보이는가?
- [ ] 발표자 노트가 각 장과 일치하는가?
- [ ] SVG와 이미지 경로가 올바른가?
- [ ] 마지막 장에 핵심 문장이 남는가?
