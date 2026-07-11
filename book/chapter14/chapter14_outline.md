# Chapter 14 Outline

## 제목
Vector DB와 RAG 기초

## 권장 분량
25~30페이지

## 이 장의 목적
일반 DB 검색과 의미 기반 검색의 차이를 이해하고, PostgreSQL + pgvector를 활용해 간단한 Vector DB/RAG 흐름을 실습한다.

## 이 장에서 다룰 내용
- Embedding의 기본 개념을 설명할 수 있다.
- Vector DB가 필요한 이유를 이해할 수 있다.
- pgvector의 역할을 설명할 수 있다.
- RAG의 기본 흐름을 설명할 수 있다.
- 문서 저장, 벡터 검색, 답변 생성 흐름을 이해할 수 있다.

## 주요 개념
- Embedding
- Vector
- Vector DB
- pgvector
- Similarity Search
- RAG
- 문서 검색
- 의미 기반 검색

## 본문 구성안
1. 일반 검색과 의미 기반 검색
2. Embedding이란 무엇인가
3. Vector DB란 무엇인가
4. PostgreSQL과 pgvector
5. RAG 기본 흐름
6. 짧은 문서 저장과 검색 실습
7. AI 응답과 검색 결과 검토

## 실습 구성
- 짧은 문서 5~10개 준비
- 문서 임베딩 구조 이해
- pgvector 테이블 설계
- 질문과 유사한 문서 검색
- 검색 결과 기반 답변 생성 흐름 확인

## 실습 결과물
- documents 테이블 설계
- vector 검색 SQL 예제
- RAG 흐름도

## 다음 장 연결
다음 장에서는 두 번째 실전 프로젝트를 수행한다.
