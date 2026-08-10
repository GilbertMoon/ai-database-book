# Overview 출판용 JPG 자산

`book/overview/overview.html`에서 사용하는 출판용 도식입니다.

| 파일 | 역할 |
| --- | --- |
| `overview_learning_roadmap.jpg` | Chapter 01~15의 4단계 전체 학습 로드맵 |
| `overview_book_structure.jpg` | 15개 Chapter의 단계별 구조 |
| `overview_study_flow.jpg` | 읽기→예상→실행→검증→AI 활용→기록 학습 흐름 |

## 제작 원칙

- 로고나 특정 AI 서비스의 브랜드 아이콘을 사용하지 않습니다.
- 텍스트와 구조 전달이 우선인 교재형 도식으로 제작합니다.
- HTML, 브라우저 미리보기, Word/PDF/eBook 변환에서 읽을 수 있도록 충분한 해상도를 사용합니다.
- 색상만으로 단계를 구분하지 않고 단계명과 번호를 함께 표시합니다.
- JPG 원본은 `scripts/generate_overview_jpg.py`로 다시 생성할 수 있습니다.

## 재생성

Ubuntu 계열에서 Noto Sans CJK와 Pillow가 설치되어 있다면 다음처럼 생성합니다.

```bash
python scripts/generate_overview_jpg.py
```

출판 PDF를 만들기 전에는 세 JPG의 텍스트 가독성, 축소 비율, 페이지 분할 위치를 실제 PDF에서 다시 확인합니다.
