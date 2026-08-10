from pathlib import Path

path = Path('code/chapter06/integrity_tests.sql')
text = path.read_text(encoding='utf-8')
old = """-- 오류 테스트 3: C-02 ISBN UNIQUE / uq_books_nf_isbn
-- INSERT INTO public.books_nf (id, title, author, published_year, isbn)
-- VALUES (1903, '중복 ISBN 도서', '테스트 저자', 2026, 'ISBN-001');"""
new = """-- 오류 테스트 3: C-02 ISBN UNIQUE 위반
-- 기대 제약조건: uq_books_nf_isbn
-- INSERT INTO public.books_nf (id, title, author, published_year, isbn)
-- VALUES (1903, '중복 ISBN 도서', '테스트 저자', 2026, 'ISBN-001');"""
if old not in text:
    raise SystemExit('Compatibility ISBN test block not found')
path.write_text(text.replace(old, new, 1), encoding='utf-8')
print('Chapter 06 compatibility prepatch applied')
