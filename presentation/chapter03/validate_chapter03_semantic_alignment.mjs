import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');
const errors = [];
const assert = (condition, message) => { if (!condition) errors.push(message); };
const read = (name) => fs.readFileSync(path.join(here, name), 'utf8');

const loadSlides = (block) => {
  const context = { window: {} };
  vm.createContext(context);
  const files = block === 'practice'
    ? ['chapter03_practice_slides_raw.js']
    : ['chapter03_theory_slides_raw.js', 'chapter03_intro_patch.js'];
  for (const file of files) vm.runInContext(read(file), context, { filename: file });
  return context.window.CH3_SLIDES || [];
};

const planContext = { window: {} };
vm.createContext(planContext);
vm.runInContext(read('chapter03_semantic_plan.js'), planContext, { filename: 'chapter03_semantic_plan.js' });
const plans = planContext.window.CH3SemanticPlan?.plans || {};
const theory = loadSlides('theory');
const practice = loadSlides('practice');

const count = (text, pattern) => (String(text || '').match(pattern) || []).length;
const tbodyRows = (html) => {
  const body = String(html || '').match(/<tbody>([\s\S]*?)<\/tbody>/i)?.[1] || '';
  return count(body, /<tr\b/gi);
};
const codeLines = (html) => {
  const code = String(html || '').match(/<pre[^>]*>([\s\S]*?)<\/pre>/i)?.[1] || '';
  return code.replace(/<[^>]+>/g, '').split(/\r?\n/).map((line) => line.trim()).filter(Boolean).length;
};
const promptLines = (html) => {
  const prompt = String(html || '').match(/<div class="prompt-box">([\s\S]*?)<\/div>/i)?.[1] || '';
  return prompt.split(/<br\s*\/?>|\r?\n/gi).map((line) => line.replace(/<[^>]+>/g, '').trim()).filter(Boolean).length;
};
const familyCount = (slide, prefix) => {
  const html = String(slide?.h || '');
  if (prefix === 'card') return count(html, /class="card(?:\s|"|>)/g);
  if (prefix === 'flow') return count(html, /class="flow-step(?:\s|"|>)/g);
  if (prefix === 'item') return count(html, /<li\b/g);
  if (prefix === 'row') return tbodyRows(html);
  if (prefix === 'code') return codeLines(html);
  if (prefix === 'prompt') return promptLines(html);
  if (prefix === 'hierarchy') {
    if (!html.includes('class="hierarchy"')) return 0;
    const start = html.indexOf('class="hierarchy"');
    const tail = html.slice(start);
    return Math.max(0, count(tail, /<div>/g) - count(tail, /<div class=/g));
  }
  if (prefix === 'quote') return count(html, /class="quote(?:\s|"|>)/g);
  if (prefix === 'body') return count(html, /class="body-text(?:\s|"|>)/g);
  if (prefix === 'lead') return count(html, /class="lead(?:\s|"|>)/g);
  if (prefix === 'pill') return count(html, /class="pill(?:\s|"|>)/g);
  if (prefix === 'codebox') return count(html, /class="codebox(?:\s|"|>)/g);
  return 0;
};

const stepCountForPlan = (slide, plan) => {
  if (!plan) return 0;
  if (Array.isArray(plan.sequence)) return plan.sequence.reduce((sum, prefix) => sum + familyCount(slide, prefix), 0);
  return Array.isArray(plan.groups) ? plan.groups.length : 0;
};

const auditBlock = (slides, block) => {
  const selected = plans[block] || {};
  const keys = new Set(slides.map((slide) => String(slide.k || '')));
  for (const key of Object.keys(selected)) assert(keys.has(key), `${block}: semantic plan target is missing: ${key}`);

  slides.forEach((slide, index) => {
    const key = String(slide.k || '');
    const major = Math.max(
      familyCount(slide, 'card'),
      familyCount(slide, 'flow'),
      familyCount(slide, 'item'),
      familyCount(slide, 'row')
    );
    if (major >= 2) assert(Boolean(selected[key]), `${block} ${index + 1}p ${key}: multiple visible semantic elements have no explicit plan`);
  });
};

auditBlock(theory, 'theory');
auditBlock(practice, 'practice');
assert(Object.keys(plans.theory || {}).length >= 25, `theory semantic plan coverage is too small: ${Object.keys(plans.theory || {}).length}`);
assert(Object.keys(plans.practice || {}).length >= 35, `practice semantic plan coverage is too small: ${Object.keys(plans.practice || {}).length}`);

const byKey = (slides, key) => slides.find((slide) => slide.k === key);
const expected = [
  ['theory', theory, 'CHAPTER GOALS', 5],
  ['theory', theory, 'CHAPTER FLOW', 5],
  ['theory', theory, 'CLIENT SERVER', 4],
  ['theory', theory, 'SETUP CHECK', 4],
  ['theory', theory, 'AI ERROR QUESTION', 4],
  ['practice', practice, 'CHECK BEFORE', 5],
  ['practice', practice, 'NEW CONNECTION', 4],
  ['practice', practice, 'CONNECTION INPUT', 5],
  ['practice', practice, 'CREATE DB', 4],
  ['practice', practice, 'READ ONLY TIMEZONE', 3],
  ['practice', practice, 'SAVE RECORD', 4],
  ['practice', practice, 'AI QUESTION', 4],
  ['practice', practice, 'FINAL CHECKLIST', 6],
  ['practice', practice, 'NEXT CHAPTER', 4]
];
for (const [block, slides, key, countExpected] of expected) {
  const slide = byKey(slides, key);
  assert(Boolean(slide), `${block}: required slide missing: ${key}`);
  if (!slide) continue;
  const actual = stepCountForPlan(slide, plans[block]?.[key]);
  assert(actual === countExpected, `${block} ${key}: expected ${countExpected} semantic steps, got ${actual}`);
}

const navigation = read('chapter03_navigation.js');
for (const token of ['CH3SemanticPlan', 'buildPlannedSteps', 'planGroups', 'balancedChunks', 'ensureNarration']) {
  assert(navigation.includes(token), `navigation missing semantic alignment logic: ${token}`);
}
assert(!navigation.includes('Math.floor(index * total'), 'navigation must not use proportional screen focus mapping');

const forbiddenNarration = [
  '앞뒤 과정에서 어떤 역할을 하는지 연결해서 이해하면 다음 작업을 더 정확하게 진행할 수 있습니다.',
  '이 내용을 앞뒤 단계와 연결해서 이해하면 실행 결과를 더 정확하게 판단할 수 있습니다.',
  '앞선 과정',
  '앞선 단계',
  '다음 작업을 더 정확하게',
  '실행 결과를 더 정확하게 판단'
];
const narrationFiles = [
  'chapter03_navigation.js',
  'chapter03_script.js',
  'chapter03_deck.js',
  'chapter03_theory_slides_raw.js',
  'chapter03_practice_slides_raw.js',
  'chapter03_theory_script_expansion.js',
  'chapter03_practice_script_expansion.js'
];
for (const phrase of forbiddenNarration) {
  const matches = narrationFiles.filter((file) => read(file).includes(phrase));
  assert(matches.length === 0, `forbidden generic narration remains: ${phrase} (${matches.join(', ')})`);
}
const ensureNarrationSource = navigation.slice(navigation.indexOf('const ensureNarration'), navigation.indexOf('const buildPlannedSteps'));
assert(!/output\.push\s*\(/.test(ensureNarrationSource), 'ensureNarration must not pad a one-sentence script');
const compressSource = navigation.slice(navigation.indexOf('const compressSentences'), navigation.indexOf('const labelForKeys'));
assert(!compressSource.includes("join(' 그리고 ')"), 'sentence compression must not inject conjunctions between source sentences');
for (const file of narrationFiles) {
  assert(!read(file).includes('핵심 내용을 설명합니다.'), `generic empty-script fallback remains: ${file}`);
}

const htmlFiles = [
  ['chapter03_theory_presentation.html', 'theory'],
  ['chapter03_practice_presentation.html', 'practice'],
  ['chapter03_script.html', 'script']
];
for (const [file, label] of htmlFiles) {
  const html = read(file);
  assert(html.includes('chapter03_semantic_plan.js?v=20260808f'), `${label}: semantic plan is not loaded with cache version`);
  assert(html.includes('chapter03_navigation.js?v=20260808f'), `${label}: navigation cache version is stale`);
  assert(html.indexOf('chapter03_semantic_plan.js') < html.indexOf('chapter03_navigation.js'), `${label}: semantic plan must load before navigation`);
}
for (const file of ['chapter03_theory_slides.js', 'chapter03_practice_slides.js']) {
  const loader = read(file);
  assert(loader.includes('chapter03_semantic_plan.js?v=20260808f'), `${file}: dynamic loader does not include semantic plan`);
}

if (errors.length) {
  console.error(`FAIL: ${errors.length} issue(s)`);
  errors.forEach((error) => console.error(`- ${error}`));
  process.exit(1);
}

console.log(`PASS: Chapter 03 theory ${theory.length} slides, explicit semantic plans ${Object.keys(plans.theory).length}`);
console.log(`PASS: Chapter 03 practice ${practice.length} slides, explicit semantic plans ${Object.keys(plans.practice).length}`);
console.log('PASS: all multi-element card/flow/list/table slides are explicitly aligned');
console.log('PASS: high-risk code, prompt, hierarchy, connection, validation and error slides use fixed semantic groups');
console.log('PASS: screen focus order and script step order use the same semantic plan');
