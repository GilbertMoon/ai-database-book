# Chapter 14 이미지/도식 설계

## Chapter 14. SQL 데이터 분석과 Python 확장

이 문서는 Chapter 14의 SQL 분석, 데이터 품질, 분석 데이터셋, PostgreSQL·Python 연결, pandas 분석과 결과 검증 흐름을 설명하는 Mermaid·SVG 자산을 정리합니다.

## 공통 원칙

```text
- 데이터베이스와 SQL을 중심에 둔다.
- Python은 SQL 결과를 확장하는 도구로 표현한다.
- 분석 질문·기간·행 단위·집계 기준을 먼저 보여 준다.
- 데이터 품질 확인을 집계보다 앞에 둔다.
- SQL과 Python 결과를 별도의 기준값으로 교차 검증한다.
- 그래프가 검증 결과를 대신하는 것처럼 표현하지 않는다.
- 비밀번호·접속 URL·운영 데이터 노출을 정상 흐름으로 표현하지 않는다.
- 필수 단계는 색상뿐 아니라 단계명과 텍스트로 구분한다.
- title, desc, role="img", aria-labelledby, width="100%", viewBox를 유지한다.
```

## 도식 목록

| 번호 | 파일 | 제목 | 본문 역할 |
| --- | --- | --- | --- |
| 그림 14-1 | `ch14_01_analysis_workflow.svg` | SQL에서 Python으로 확장되는 데이터 분석 흐름 | 질문→SQL→데이터셋→Python→검증 |
| 그림 14-2 | `ch14_02_sql_python_role_split.svg` | SQL과 Python의 분석 역할 구분 | DB 처리와 확장 분석의 역할 분리 |
| 그림 14-3 | `ch14_04_data_quality_checks.svg` | 분석 전 데이터 품질 점검 | 행 수·NULL·중복·고아·업무 규칙 |
| 그림 14-4 | `ch14_03_sql_aggregation_flow.svg` | JOIN과 집계로 분석 결과 만들기 | 필터·JOIN·GROUP BY·검산 |
| 그림 14-5 | `ch14_05_analysis_dataset_pipeline.svg` | 업무 테이블에서 분석용 데이터셋 만들기 | 원본→VIEW→CSV·DB 연결 |
| 그림 14-6 | `ch14_06_postgresql_python_connection.svg` | PostgreSQL 데이터를 Python과 pandas로 읽기 | 환경변수·읽기 전용·DataFrame |
| 그림 14-7 | `ch14_07_pandas_analysis_flow.svg` | pandas 데이터 분석 확장 흐름 | 구조 확인·집계·피벗·시각화 |
| 그림 14-8 | `ch14_08_analysis_result_validation.svg` | SQL 결과와 Python 결과 교차 검증 | 행 수·건수·합계·평균 비교 |

모든 SVG에는 동일 이름의 `.mmd` 원본이 있습니다.

## 실습 기준

```text
students 8
instructors 3
courses 5
enrollments 24
분석 VIEW 24행
상태별 12·5·4·3
월별 3·4·5·4·4·4
결제금액 합계 2,770,000
완료 건수 12
평균 완료 기간 25일
데이터 품질 이상 0
```

## 색상 의미

```text
파랑: 분석 질문·입력·기준
초록: SQL·검증 통과
노랑: 품질 확인·판단
보라: Python·pandas 확장
청록: 분석 데이터셋·연결
빨강: 불일치·재검토
```

## 도식에서 피할 표현

```text
- Python이 데이터베이스 전체를 먼저 가져와 모든 작업을 처리한다.
- SQL과 Python 중 하나만 선택해야 한다.
- NULL은 모두 오류다.
- 중복은 원인 확인 없이 삭제하면 된다.
- 그래프가 생성되면 분석이 완료된다.
- SQL과 Python 결과가 달라도 둘 다 정답이다.
- 비밀번호를 Python 코드에 직접 입력한다.
- 운영 DB에서 분석 스크립트를 바로 실행한다.
- AI가 만든 분석 결과는 실행되면 승인한다.
```

## 검수 기준

```text
- 본문 그림 번호 14-1~14-8과 README 순서 일치
- SVG와 Mermaid의 노드·순서·분기 일치
- 텍스트 겹침과 박스 밖 돌출 없음
- 화살표가 텍스트나 다른 카드를 관통하지 않음
- SQL→Python 확장 방향이 명확함
- 데이터 품질 단계가 분석 전에 위치함
- SQL·Python 결과 불일치 시 재검토 흐름 포함
- 보안 정보는 환경변수로 표현
- GitHub·브라우저·Word·PDF·eBook 렌더링은 수동 확인
```
