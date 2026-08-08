(() => {
  'use strict';

  const splitSentences = (value) => {
    const text = String(value || '').replace(/\s+/g, ' ').trim();
    if (!text) return ['핵심 내용을 설명합니다.'];
    return (text.match(/[^.!?。]+[.!?。]?/g) || [text]).map((part) => part.trim()).filter(Boolean);
  };

  const balancedGroups = (items, count) => {
    const source = items.filter(Boolean);
    if (!source.length) return Array.from({ length: Math.max(1, count) }, () => []);
    const total = Math.max(1, Math.min(count, source.length));
    const groups = [];
    let cursor = 0;
    for (let index = 0; index < total; index += 1) {
      const remainingItems = source.length - cursor;
      const remainingGroups = total - index;
      const size = Math.ceil(remainingItems / remainingGroups);
      groups.push(source.slice(cursor, cursor + size));
      cursor += size;
    }
    return groups;
  };

  const targetFamily = (root) => {
    const families = [
      ['row', 'table tbody tr'],
      ['item', '.bullet-list li'],
      ['code', '.code-line'],
      ['card', '.card'],
      ['flow', '.flow-step,.road-step,.path-node,.join-path'],
      ['metric', '.metric,.aggregate,.result,.success,.failure,.error,.warning'],
      ['text', '.screen-text']
    ];

    for (const [kind, selector] of families) {
      const elements = [...root.querySelectorAll(selector)].filter((element) => element.textContent.trim());
      if (elements.length) return { kind, elements };
    }
    const elements = [...root.children].filter((element) => !['H1', 'H2'].includes(element.tagName));
    return { kind: 'section', elements };
  };

  const targetGroups = (elements, desired) => balancedGroups(elements, Math.max(1, Math.min(desired, 5)));

  const prepareSlide = (slide) => {
    if (!slide || slide.__chapter08Prepared) return slide;
    const root = document.createElement('div');
    root.innerHTML = slide.h || '';
    const { kind, elements } = targetFamily(root);
    const sentences = splitSentences(slide.s);
    const textStepCount = Math.max(1, Math.ceil(sentences.length / 2));
    const visualCount = Math.max(1, Math.min(elements.length || 1, 5));
    const stepCount = Math.max(1, Math.min(textStepCount, visualCount, 5));
    const visuals = targetGroups(elements, stepCount);
    const texts = balancedGroups(sentences, stepCount);
    const steps = [];

    visuals.forEach((group, index) => {
      const focusKeys = [];
      group.forEach((element, elementIndex) => {
        const key = `ch8-${kind}-${index}-${elementIndex}`;
        element.dataset.focusKey = key;
        element.dataset.focusStep = String(index + 1);
        element.classList.add('focus-target');
        focusKeys.push(key);
      });
      steps.push({
        text: (texts[index] || texts[texts.length - 1] || []).join(' ') || '핵심 내용을 설명합니다.',
        focusKeys
      });
    });

    if (!steps.length) steps.push({ text: sentences.join(' '), focusKeys: [] });
    slide.h = root.innerHTML;
    slide.steps = steps.length;
    slide.__chapter08Steps = steps;
    slide.__chapter08Prepared = true;
    return slide;
  };

  const prepareSlides = (slides) => (slides || []).map(prepareSlide);
  const buildSteps = (slide) => slide?.__chapter08Steps || [{ text: String(slide?.s || '핵심 내용을 설명합니다.'), focusKeys: [] }];

  const applyFocus = (root, stepIndex) => {
    if (!root) return;
    const targets = [...root.querySelectorAll('[data-focus-step]')];
    targets.forEach((element) => {
      const active = stepIndex > 0 && Number(element.dataset.focusStep) === stepIndex;
      element.classList.toggle('focus-active', active);
      element.classList.toggle('focus-muted', stepIndex > 0 && !active);
    });
  };

  window.CH8Navigation = Object.freeze({ prepareSlide, prepareSlides, buildSteps, applyFocus, splitSentences });
})();
