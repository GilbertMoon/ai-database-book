import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const read = (name) => fs.readFileSync(path.join(here, name), 'utf8');
const readRoot = (name) => fs.readFileSync(path.join(root, name), 'utf8');
const errors = [];
const assert = (value, message) => { if (!value) errors.push(message); };

const load = (block) => {
  const context = { window: {} };
  vm.createContext(context);
  const files = block === 'practice'
    ? ['chapter05_practice_slides_raw.js', 'chapter05_content_patch.js']
    : ['chapter05_theory_slides_raw.js', 'chapter05_intro_patch.js', 'chapter05_content_patch.js'];
  for (const file of files) vm.runInContext(read(file), context, { filename: file });
  return context.window.CH5_SLIDES || [];
};

const theory = load('theory');
const practice = load('practice');
const sourceFiles = ['chapter05_theory_slides_raw.js', 'chapter05_practice_slides_raw.js', 'chapter05_navigation.js', 'chapter05_content_patch.js'];
const source = sourceFiles.map(read).join('\n');
const narration = [...theory, ...practice].map((slide) => String(slide.s || '')).join('\n');

assert(theory.length >= 25, `theory slide count is too small: ${theory.length}`);
assert(practice.filter((slide) => /^STEP \d+$/.test(slide.k)).length === 23, 'practice must retain Step 01 through Step 23');
for (const pattern of [/번째 단계입니다/, /핵심 내용을 설명합니다/, /앞뒤 과정|앞뒤 단계|다음 작업을 더 정확하게|연결해서 이해하면/]) {
  assert(!pattern.test(source), `forbidden narration remains: ${pattern}`);
}

const filesSlide = practice.find((slide) => slide.k === 'FILES');
for (const file of ['01_library_schema.sql', '02_library_seed.sql', '03_library_validation.sql', 'reset_library.sql']) {
  assert(filesSlide?.h.includes(file), `FILES slide missing ${file}`);
  assert(readRoot('code/chapter05/README.md').includes(file), `README missing ${file}`);
}
assert(filesSlide?.h.includes('호환용'), 'compatibility files must be identified as non-default');

const location = practice.find((slide) => slide.k === 'STEP 01');
assert(location?.s.includes('환경에 따라 퍼블릭이 아닐 수'), 'current_schema must not be forced to public');
for (const table of ['public.members', 'public.books', 'public.loans']) assert(location?.h.includes(table), `STEP 01 missing ${table}`);

const entities = theory.find((slide) => slide.k === 'ENTITY CANDIDATES');
assert(entities?.s.includes('물리적인 복본 한 권과 같다고 단정하지 않습니다'), 'books row meaning is ambiguous');
assert(entities?.s.includes('사건 엔터티'), 'loans must be explained as an event entity');
const rules = theory.find((slide) => slide.k === 'CONFIRMED UNKNOWN');
for (const word of ['확정', '미확정', '가정', '범위 제외']) assert(`${rules?.h} ${rules?.s}`.includes(word), `rule categories missing ${word}`);

const schema = readRoot('code/chapter05/01_library_schema.sql');
for (const fragment of ['title VARCHAR(200) NOT NULL', 'author VARCHAR(100) NOT NULL', 'published_year INTEGER', 'isbn VARCHAR(20) NOT NULL']) {
  assert(schema.includes(fragment), `schema missing ${fragment}`);
  assert(source.includes(fragment), `presentation missing ${fragment}`);
}
const seed = readRoot('code/chapter05/02_library_seed.sql');
for (const id of ['101', '102', '103', '201', '202', '203', '1001', '1002', '1003', '1004']) assert(seed.includes(id), `seed missing ${id}`);
assert(narration.includes('멤버스는 세 행, 북스는 세 행, 로운스는 네 행'), '3·3·4 runtime narration is missing');
const reset = readRoot('code/chapter05/reset_library.sql');
assert(reset.indexOf('DROP TABLE IF EXISTS public.loans') < reset.indexOf('DROP TABLE IF EXISTS public.books'), 'reset must drop loans before books');

if (errors.length) {
  console.error(`FAIL: ${errors.length} issue(s)`);
  errors.forEach((error) => console.error(`- ${error}`));
  process.exit(1);
}
console.log(`PASS: Chapter 05 theory ${theory.length} slides, practice ${practice.length} slides`);
console.log('PASS: STEP ordinals and generic narration fallbacks are absent');
console.log('PASS: model concepts, numbered files, 3·3·4 seed and canonical SQL are aligned');
