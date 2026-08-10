from pathlib import Path
import subprocess
ROOT = Path(__file__).resolve().parents[1]

def r(p): return (ROOT/p).read_text(encoding='utf-8')
def w(p,s): (ROOT/p).write_text(s, encoding='utf-8')
def rep(p,a,b):
    s=r(p)
    if a not in s: raise RuntimeError(f'missing in {p}: {a[:80]}')
    w(p,s.replace(a,b,1))

p='book/chapter05/chapter05.md'
rep(p,'- N:M 관계를 사건 테이블로 변환한다.','- N:M 관계를 연결 테이블로 풀고, 사건 속성을 가진 연결 엔터티를 설명한다.')
rep(p,'```text\n[`01_library_schema.sql`](../../code/chapter05/01_library_schema.sql)\n[`02_library_seed.sql`](../../code/chapter05/02_library_seed.sql)\n[`03_library_validation.sql`](../../code/chapter05/03_library_validation.sql)\n[`reset_library.sql`](../../code/chapter05/reset_library.sql)\n```','- [`01_library_schema.sql`](../../code/chapter05/01_library_schema.sql)\n- [`02_library_seed.sql`](../../code/chapter05/02_library_seed.sql)\n- [`03_library_validation.sql`](../../code/chapter05/03_library_validation.sql)\n- [`reset_library.sql`](../../code/chapter05/reset_library.sql)')
rep(p,'| Q-01 | 이메일은 고유한가? | 미확정 | 제약조건 보류 | 정책 확인 필요 |\n| A-01 | `books` 한 행을 한 대여 대상으로 취급 | 가정 | 모델 범위 | 복본 미구분 명시 |','| Q-01 | 이메일은 고유한가? | 미확정 | 제약조건 보류 | 정책 확인 필요 |\n| Q-02 | ISBN은 항상 존재하며 고유한가? | 미확정 | `isbn` NULL 허용·UNIQUE 보류 | 정책 확인 필요 |\n| A-01 | `books` 한 행을 간소화된 대여 대상 도서 항목으로 취급 | 가정 | 모델 범위 | 복본 미구분 명시 |')

p='code/chapter05/01_library_schema.sql'
rep(p,'-- 도서 한 행 = 이 장에서 대여 대상으로 관리하는 도서 한 건','-- 도서 한 행 = 이 장에서 대여 대상으로 취급하는 간소화된 도서 항목 한 건')
if (ROOT/'code/chapter05/library_schema.sql').exists(): w('code/chapter05/library_schema.sql',r(p))

p='book/chapter05/chapter05_outline.md'
rep(p,'- N:M 관계를 사건 테이블로 변환한다.' if '- N:M 관계를 사건 테이블로 변환한다.' in r(p) else '- N:M 관계를 연결 테이블로 풀고, 사건 속성이 있는 연결 엔터티를 설명한다.','- N:M 관계를 연결 테이블로 풀고, 사건 속성이 있는 연결 엔터티를 설명한다.') if '- N:M 관계를 사건 테이블로 변환한다.' in r(p) else None

subprocess.run(['python',str(ROOT/'scripts/merge_chapters.py')],cwd=ROOT,check=True)
assert '```text\n[`01_library_schema.sql`]' not in r('book/chapter05/chapter05.md')
assert '| Q-02 | ISBN은 항상 존재하며 고유한가?' in r('book/chapter05/chapter05.md')
assert '- N:M 관계를 연결 테이블로 풀고' in r('book/chapter05/chapter05.md')
Path(__file__).unlink()
