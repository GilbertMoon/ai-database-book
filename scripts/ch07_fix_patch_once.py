from pathlib import Path

path = Path(__file__).with_name('ch07_final_publication_review_once.py')
text = path.read_text(encoding='utf-8')
old = "    'course_project 스키마 존재\\n네 테이블 존재',\n    '현재 역할에 ai_database_book의 CREATE 권한 존재\\ncourse_project 스키마 존재\\n네 테이블 존재')"
new = "    'course_project 존재\\n네 테이블 존재',\n    '현재 역할에 ai_database_book의 CREATE 권한 존재\\ncourse_project 존재\\n네 테이블 존재')"
if old not in text:
    raise RuntimeError('README patch target not found in final review script')
path.write_text(text.replace(old, new, 1), encoding='utf-8')
print('Chapter 07 patch preflight fixed')
