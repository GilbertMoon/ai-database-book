import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const readHere = (name) => fs.readFileSync(path.join(here, name), 'utf8');
const readRoot = (name) => fs.readFileSync(path.join(root, name), 'utf8');
const errors = [];
const assert = (condition, message) => { if (!condition) errors.push(message); };

const loadSlides = (block) => {
  const context = { window: {} };
  vm.createContext(context);
  const files = block === 'practice'
    ? ['chapter04_practice_slides_raw.js', 'chapter04_content_patch.js']
    : ['chapter04_theory_slides_raw.js', 'chapter04_intro_patch.js', 'chapter04_content_patch.js'];
  for (const file of files) vm.runInContext(readHere(file), context, { filename: file });
  return context.window.CH4_SLIDES || [];
};

const theory = loadSlides('theory');
const practice = loadSlides('practice');
const narration = [...theory, ...practice].map((slide) => String(slide.s || '')).join('\n');
const sources = [
  'chapter04_theory_slides_raw.js',
  'chapter04_practice_slides_raw.js',
  'chapter04_intro_patch.js',
  'chapter04_content_patch.js',
  'chapter04_navigation.js',
  'chapter04_script.js'
];
const sourceText = sources.map(readHere).join('\n');
assert(!readHere('chapter04_script.html').includes('script_content_enhancer.js'), 'Chapter 04 script must not load the generic content enhancer');

assert(theory.length === 24, `expected 24 theory slides, got ${theory.length}`);
assert(practice.length === 38, `expected 38 practice slides, got ${practice.length}`);
assert(practice.filter((slide) => /^STEP \d+$/.test(slide.k)).length === 32, 'practice STEP slide count changed');

const forbidden = [
  /(?:첫|두|세|네|다섯|여섯|일곱|여덟|아홉|열|열한|열두|열세|열네|열다섯|열여섯|열일곱|열여덟|열아홉|스물|서른)[가-힣\s]*번째 단계입니다/,
  /앞뒤 과정|앞뒤 단계|다음 작업을 더 정확하게|실행 결과를 더 정확하게|연결해서 이해하면/,
  /핵심 내용을 설명합니다/,
  /티아이엠이에스티에이엠피티제트/
];
for (const pattern of forbidden) {
  assert(!pattern.test(sourceText), `forbidden narration remains: ${pattern}`);
}

const step02 = practice.find((slide) => slide.k === 'STEP 02');
assert(step02?.h.includes('01_create_students.sql'), 'STEP 02 must start with numbered SQL files');
assert(step02?.h.includes('verify_students.sql'), 'STEP 02 must include state verification');
assert(step02?.h.includes('basic_crud.sql: 기존 링크용 통합 참고'), 'STEP 02 must identify basic_crud.sql as reference only');
assert(!step02?.h.includes('basic_crud.sql을 엽니다'), 'STEP 02 must not open basic_crud.sql as the default path');
const step03 = practice.find((slide) => slide.k === 'STEP 03');
assert(step03?.s.includes('공일 생성 파일 전체를 실행합니다'), 'STEP 03 must execute the complete protected create file');
for (const key of ['STEP 05', 'STEP 06', 'STEP 07']) {
  const slide = practice.find((item) => item.k === key);
  assert(slide?.h.includes('02_insert_students.sql'), `${key} must be identified as part of 02_insert_students.sql`);
}

const expectedStates = {
  'CHECKPOINT A': ['초기 데이터 상태', '여섯 명', '삼 학년', '널'],
  'CHECKPOINT B': ['수정 실습 후 상태', '여섯 명', '사 학년', '존재'],
  'CHECKPOINT C': ['삭제 실습 후 상태', '다섯 명', '사 학년', '삭제']
};
for (const [key, fragments] of Object.entries(expectedStates)) {
  const slide = practice.find((item) => item.k === key);
  for (const fragment of fragments) assert(`${slide?.l || ''} ${slide?.s || ''}`.includes(fragment), `${key} missing state text: ${fragment}`);
}

const location = theory.find((slide) => slide.k === 'EXECUTION LOCATION')?.s || '';
assert(location.includes('환경에 따라 퍼블릭이 아닐 수 있습니다'), 'current_schema must not be described as always public');
assert(location.includes('퍼블릭 점 스튜던츠'), 'schema-qualified practice target is missing');

const sqlOrder = ['01_create_students.sql', '02_insert_students.sql', '03_select_students.sql', '04_update_delete_students.sql'];
const readme = readRoot('code/chapter04/README.md');
for (const file of sqlOrder) {
  assert(readme.includes(file), `README missing ${file}`);
  assert(sourceText.includes(file), `presentation missing ${file}`);
}
assert(readRoot('code/chapter04/01_create_students.sql').includes('created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP'), 'students schema differs from presentation');
assert((readRoot('code/chapter04/02_insert_students.sql').match(/@example\.com/g) || []).length >= 6, 'initial dataset must contain six students');
assert(readRoot('code/chapter04/04_update_delete_students.sql').includes('SET grade = 4'), 'update target differs from presentation');
assert(readRoot('code/chapter04/04_update_delete_students.sql').includes("WHERE email = 'seoyeon@example.com'"), 'delete target differs from presentation');
assert(readRoot('code/chapter04/reset_students.sql').includes('DROP TABLE IF EXISTS public.students'), 'reset target differs from presentation');

const count = (pattern) => (narration.match(pattern) || []).length;
assert(count(/실행 전/g) <= 12, `runtime narration repeats '실행 전' too often: ${count(/실행 전/g)}`);
assert(count(/중요합니다/g) <= 4, `runtime narration repeats '중요합니다' too often: ${count(/중요합니다/g)}`);

if (errors.length) {
  console.error(`FAIL: ${errors.length} issue(s)`);
  errors.forEach((error) => console.error(`- ${error}`));
  process.exit(1);
}

console.log(`PASS: Chapter 04 theory ${theory.length} slides, practice ${practice.length} slides`);
console.log('PASS: STEP ordinals and generic narration fallbacks are absent');
console.log('PASS: raw slides and runtime patches use numbered SQL files and named data states');
console.log('PASS: database, schema, students data, update, delete and reset descriptions align with code/chapter04');
