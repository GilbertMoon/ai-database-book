import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const errors = [];
const warnings = [];
const assert = (condition, message) => { if (!condition) errors.push(message); };
const read = (file) => fs.readFileSync(file, 'utf8');

const dataFile = path.join(here, 'chapter02_data.js');
const source = read(dataFile);
const context = { window: {} };
vm.createContext(context);
vm.runInContext(source, context, { filename: dataFile });
const data = context.window.CHAPTER_DATA;
const slides = data?.slides || [];
const chapterFiles = fs.readdirSync(here);

assert(chapterFiles.filter((name) => /data\.js$/.test(name)).length === 1, '슬라이드 데이터 원본은 하나여야 합니다.');
assert(!chapterFiles.some((name) => /slides_0[12]\.js$/.test(name)), '기존 분할 슬라이드 파일이 남아 있습니다.');
assert(slides.length >= 42 && slides.length <= 46, `슬라이드 수 ${slides.length}장은 42~46장 범위를 벗어납니다.`);
const parts = [...new Set(slides.filter((slide) => slide.part > 0).map((slide) => slide.part))];
assert(parts.length >= 10 && parts.length <= 11, `마이크로 파트 수 ${parts.length}개는 10~11개 범위를 벗어납니다.`);
for (const part of parts) {
  const count = slides.filter((slide) => slide.part === part).length;
  assert(count >= 3 && count <= 5, `Part ${part}의 슬라이드 수 ${count}장이 3~5장이 아닙니다.`);
}

const ids = new Set();
const allText = [];
let scriptChars = 0;
for (const [index, slide] of slides.entries()) {
  const prefix = `${index + 1}장(${slide.id || 'ID 없음'})`;
  assert(slide.id && !ids.has(slide.id), `${prefix}: 슬라이드 ID가 없거나 중복입니다.`);
  ids.add(slide.id);
  for (const field of ['eyebrow', 'label', 'title', 'body', 'script']) assert(typeof slide[field] === 'string' && slide[field].trim(), `${prefix}: ${field}가 비었습니다.`);
  assert(Number.isFinite(slide.durationSec) && slide.durationSec >= 30 && slide.durationSec <= 100, `${prefix}: 설명 시간이 30~100초 범위를 벗어납니다.`);
  assert(Array.isArray(slide.steps) && slide.steps.length > 0 && slide.steps.length <= 5, `${prefix}: 강조 단계는 1~5개여야 합니다.`);
  const targets = new Set([...slide.body.matchAll(/data-cue="([^"]+)"/g)].map((match) => match[1]));
  for (const step of slide.steps || []) {
    assert(targets.has(step.target), `${prefix}: 강조 대상 '${step.target}'이 body에 없습니다.`);
    assert(typeof step.script === 'string' && step.script.trim(), `${prefix}: 단계 스크립트가 없습니다.`);
    scriptChars += step.script.replace(/\s/g, '').length;
  }
  scriptChars += slide.script.replace(/\s/g, '').length;
  const images = [...slide.body.matchAll(/<img\s+([^>]+)>/g)];
  for (const image of images) {
    const src = image[1].match(/src="([^"]+)"/)?.[1];
    const alt = image[1].match(/alt="([^"]*)"/)?.[1];
    assert(src && alt, `${prefix}: 모든 이미지에 src와 의미 있는 alt가 필요합니다.`);
    if (src) {
      const imagePath = path.resolve(here, src);
      assert(fs.existsSync(imagePath), `${prefix}: 이미지가 없습니다: ${src}`);
      if (fs.existsSync(imagePath) && path.extname(imagePath) === '.svg') {
        const svg = read(imagePath);
        assert(/<title[ >]/.test(svg) && /<desc[ >]/.test(svg), `${prefix}: SVG title 또는 desc가 없습니다: ${src}`);
      }
    }
  }
  for (const code of slide.body.matchAll(/<pre[^>]*>[\s\S]*?<code>([\s\S]*?)<\/code>[\s\S]*?<\/pre>/g)) {
    assert(code[1].trim().split(/\r?\n/).length <= 12, `${prefix}: SQL 코드가 12줄을 넘습니다.`);
  }
  for (const table of slide.body.matchAll(/<table[\s\S]*?<\/table>/g)) {
    const rows = [...table[0].matchAll(/<tr/g)].length - 1;
    const columns = Math.max(0, ...[...table[0].matchAll(/<tr[^>]*>([\s\S]*?)<\/tr>/g)].map((row) => [...row[1].matchAll(/<t[hd]/g)].length));
    assert(rows <= 5 && columns <= 4, `${prefix}: 표가 4열 × 5행을 넘습니다.`);
  }
  if (slide.durationSec >= 60 && slide.steps.length < 2 && !/<img/.test(slide.body) && !/class="activity"/.test(slide.body)) warnings.push(`${prefix}: 1분 이상 장표의 화면 변화가 한 단계뿐입니다.`);
  allText.push(slide.title, slide.body, slide.script, ...slide.steps.map((item) => item.script));
}

const combined = allText.join('\n');
for (const phrase of ['이번 장표에서는', '화면 왼쪽을 보겠습니다', '화면 오른쪽을 보겠습니다', '지금 모두 이해해야 합니다']) {
  assert(!combined.includes(phrase), `금지된 상투적 스크립트 표현이 있습니다: ${phrase}`);
}
assert(!/SHOW\s+search_path|CREATE\s+DATABASE|CREATE\s+TABLE\s+students/i.test(combined), 'Chapter 03~04의 실제 실습 명령이 포함되어 있습니다.');

const consistency = [
  ['DBeaver는 클라이언트', /DBeaver.{0,80}클라이언트/s],
  ['PostgreSQL은 DBMS', /PostgreSQL.{0,80}DBMS/s],
  ['데이터베이스와 DBMS 구분', /데이터베이스.{0,30}DBMS.{0,80}(다릅니다|같은 개념이 아닙니다)/s],
  ['한 행의 의미', /한 행.{0,30}의미/s],
  ['테이블과 조회 결과', /테이블과 조회 결과|저장 구조와 조회 결과/s],
  ['ORDER BY 순서', /ORDER BY.{0,40}순서.{0,30}보장되지/s],
  ['기본키 역할', /기본키.{0,30}(행을 구분|행을 고유)/s],
  ['외래키 역할', /외래키.{0,30}(참조|다른 행)/s],
  ['외래키 반복', /외래키.{0,50}반복/s],
  ['다섯 질문', /다섯 질문/s]
];
for (const [name, pattern] of consistency) assert(pattern.test(combined), `개념 일관성 문장을 찾지 못했습니다: ${name}`);

const presentationHtml = read(path.join(here, 'chapter02_presentation.html'));
const scriptHtml = read(path.join(here, 'chapter02_script.html'));
for (const oldName of ['chapter02_slides_01.js', 'chapter02_slides_02.js', 'chapter02_intro_patch.js']) assert(!presentationHtml.includes(oldName) && !scriptHtml.includes(oldName), `기존 파일 참조가 남아 있습니다: ${oldName}`);
for (const required of ['chapter02_data.js', '../common/presentation_runtime.js']) assert(presentationHtml.includes(required), `발표 HTML 참조가 없습니다: ${required}`);
for (const required of ['chapter02_data.js', '../common/script_runtime.js']) assert(scriptHtml.includes(required), `스크립트 HTML 참조가 없습니다: ${required}`);

const jsFiles = [
  dataFile,
  path.join(root, 'presentation/common/presentation_runtime.js'),
  path.join(root, 'presentation/common/script_runtime.js')
];
for (const file of jsFiles) {
  const result = spawnSync(process.execPath, ['--check', file], { encoding: 'utf8' });
  assert(result.status === 0, `JavaScript 문법 오류: ${path.relative(root, file)} ${result.stderr}`);
}

const readme = read(path.join(here, 'README.md'));
const outline = read(path.join(here, 'chapter02_outline.md'));
assert(/최종 슬라이드:\s*45장/.test(readme) && /최종 슬라이드:\s*45장/.test(outline), 'README 또는 outline의 슬라이드 수가 45장과 일치하지 않습니다.');
assert(/마이크로 파트:\s*11개/.test(readme) && /마이크로 파트:\s*11개/.test(outline), 'README 또는 outline의 파트 수가 11개와 일치하지 않습니다.');
assert(readme.includes(`공백 제외 ${scriptChars.toLocaleString('ko-KR')}자`), `README의 스크립트 글자 수가 실제 ${scriptChars}자와 다릅니다.`);
const speechMinutes = scriptChars / data.speechCharsPerMinute;
assert(speechMinutes >= 60 && speechMinutes <= 70, `스크립트 글자 수 기반 음성 시간 ${speechMinutes.toFixed(1)}분이 60~70분 범위를 벗어납니다.`);

console.log(`PASS: ${slides.length} slides, ${parts.length} parts, ${scriptChars.toLocaleString('ko-KR')} script chars, ${speechMinutes.toFixed(1)} estimated speech minutes`);
for (const warning of warnings) console.log(`WARN: ${warning}`);
if (errors.length) {
  console.error(`FAIL: ${errors.length} issue(s)`);
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}
console.log('PASS: data, scripts, cues, assets, accessibility metadata, chapter boundary, syntax, README and outline');
