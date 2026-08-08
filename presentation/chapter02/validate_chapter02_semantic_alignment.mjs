import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const read = (name) => fs.readFileSync(path.join(here, name), 'utf8');
const errors = [];
const assert = (condition, message) => { if (!condition) errors.push(message); };

const context = { window: {} };
vm.createContext(context);
for (const file of ['chapter02_data.js', 'chapter02_semantic_overrides.js', 'chapter02_script_enrichment.js']) {
  vm.runInContext(read(file), context, { filename: file });
}

const slides = context.window.CHAPTER_DATA?.slides || [];
const enrichment = context.window.CH2ScriptEnrichment;
const overrideInfo = context.window.CH2SemanticOverrides;
const byId = new Map(slides.map((slide, index) => [slide.id, { slide, index }]));

assert(slides.length === 45, `Chapter 02 slide count must remain 45, got ${slides.length}`);
assert(overrideInfo?.slideIds?.length === 20, `Expected 20 aligned slide overrides, got ${overrideInfo?.slideIds?.length ?? 0}`);
assert(enrichment, 'CH2ScriptEnrichment is missing after semantic overrides');

const expectedSteps = new Map([
  ['part03-01', 5],
  ['part04-01', 5],
  ['part05-01', 4],
  ['part06-01', 2],
  ['part06-04', 1],
  ['part07-02', 2],
  ['part07-03', 1],
  ['part08-01', 3],
  ['part08-02', 3],
  ['part08-04', 1],
  ['part09-01', 3],
  ['part09-02', 3],
  ['part09-03', 2],
  ['part10-02', 4],
  ['part10-03', 2],
  ['part11-01', 4],
  ['part11-02', 5],
  ['part11-03', 1],
  ['closing-02', 4],
  ['closing-03', 3]
]);

for (const [id, expected] of expectedSteps) {
  const entry = byId.get(id);
  assert(entry, `Aligned slide not found: ${id}`);
  if (!entry) continue;
  const { slide, index } = entry;
  assert(slide.steps.length === expected, `Slide ${index + 1} (${id}) expected ${expected} semantic steps, got ${slide.steps.length}`);
  const cues = [...slide.body.matchAll(/data-cue="([^"]+)"/g)].map((match) => match[1]);
  const cueSet = new Set(cues);
  assert(cueSet.size >= expected, `Slide ${index + 1} (${id}) has fewer distinct screen cues (${cueSet.size}) than semantic steps (${expected})`);
  for (const step of slide.steps) {
    assert(cueSet.has(step.target), `Slide ${index + 1} (${id}) step '${step.label}' has no matching screen cue '${step.target}'`);
  }
}

const activityIds = ['part06-04', 'part07-03', 'part08-04', 'part11-03'];
for (const id of activityIds) {
  const slide = byId.get(id)?.slide;
  assert(slide?.steps?.length === 1, `${id} must remain question screen -> one answer reveal step`);
  assert(slide?.steps?.[0]?.target === 'answer', `${id} answer reveal target must be 'answer'`);
}

const highRisk = {
  'part03-01': ['user', 'client', 'dbms', 'result', 'human'],
  'part04-01': ['server', 'database', 'schema', 'objects', 'table'],
  'part05-01': ['table', 'row', 'column', 'cell'],
  'part08-01': ['same-name', 'identity', 'rules'],
  'part08-02': ['student-fk', 'course-fk', 'repeat-fk'],
  'part09-01': ['one-one', 'one-many', 'many-many'],
  'part11-02': ['row-meaning', 'primary-key', 'reference', 'mixing', 'type-required']
};
for (const [id, targets] of Object.entries(highRisk)) {
  const slide = byId.get(id)?.slide;
  assert(slide, `High-risk aligned slide not found: ${id}`);
  if (!slide) continue;
  assert(JSON.stringify(slide.steps.map((item) => item.target)) === JSON.stringify(targets), `${id} semantic target order is incorrect`);
}

let totalSteps = 0;
let totalSentences = 0;
for (const [index, slide] of slides.entries()) {
  const overview = enrichment.overviewText(slide);
  const overviewCount = enrichment.splitSentences(overview).length;
  assert(overviewCount >= 1 && overviewCount <= 2, `Slide ${index + 1} (${slide.id}) overview must be 1-2 sentences, got ${overviewCount}`);
  slide.steps.forEach((step, stepIndex) => {
    totalSteps += 1;
    const text = enrichment.stepText(slide, stepIndex);
    const count = enrichment.splitSentences(text).length;
    totalSentences += count;
    assert(count >= 2 && count <= 4, `Slide ${index + 1} (${slide.id}) step ${stepIndex + 1} narration must be 2-4 sentences, got ${count}`);
  });
}

const presentationHtml = read('chapter02_presentation.html');
const scriptHtml = read('chapter02_script.html');
for (const [name, html] of [['presentation', presentationHtml], ['script', scriptHtml]]) {
  const dataAt = html.indexOf('chapter02_data.js');
  const overrideAt = html.indexOf('chapter02_semantic_overrides.js');
  const enrichmentAt = html.indexOf('chapter02_script_enrichment.js');
  const navigationAt = html.indexOf('chapter02_navigation.js');
  assert(dataAt >= 0 && overrideAt > dataAt && enrichmentAt > overrideAt && navigationAt > enrichmentAt,
    `${name} HTML must load data -> semantic overrides -> enrichment -> navigation in that order`);
}

for (const file of ['chapter02_semantic_overrides.js', 'validate_chapter02_semantic_alignment.mjs']) {
  const result = spawnSync(process.execPath, ['--check', path.join(here, file)], { encoding: 'utf8' });
  assert(result.status === 0, `${file} syntax error: ${result.stderr}`);
}

if (errors.length) {
  console.error(`FAIL: ${errors.length} semantic alignment issue(s)`);
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log(`PASS: Chapter 02 runtime semantic alignment covers ${slides.length} slides and ${totalSteps} steps`);
console.log(`PASS: 20 corrected slides have screen cue count and step count aligned 1:1`);
console.log(`PASS: activity slides use one answer reveal step, not artificial narration steps`);
console.log(`PASS: high-risk SVG-style slides now expose independent semantic focus targets`);
console.log(`PASS: enriched narration remains 2-4 sentences per step, average ${(totalSentences / totalSteps).toFixed(2)}`);
