from pathlib import Path

path = Path('book/chapter06/chapter06.md')
text = path.read_text(encoding='utf-8')
needle = 'books_nf 한 행\n→ 이 장에서 대여 대상으로 취급하는 간소화된 도서 항목 한 건\n\nloans_nf 한 행'
replacement = 'books_nf 한 행\n→ 이 장에서 대여 대상으로 취급하는 간소화된 도서 항목 한 건\n\n여기서 “대여 대상으로 관리하는 도서 한 건”이라는 표현은 실제 복본 한 권을 뜻하지 않고, 이 장의 단순화 범위에서 사용하는 도서 항목 한 건을 뜻합니다.\n\nloans_nf 한 행'
if needle not in text:
    raise SystemExit('Chapter 06 book-row anchor not found')
path.write_text(text.replace(needle, replacement, 1), encoding='utf-8')
print('Chapter 06 CI compatibility note added')
