(() => {
  'use strict';

  const slides = window.CHAPTER_DATA?.slides || [];
  const enrichment = window.CH2ScriptEnrichment;

  const buildSteps = (slide) => (slide?.steps || []).map((step, index) => ({
    text: String(enrichment?.stepText ? enrichment.stepText(slide, index) : (step.script || step.label || '')).trim(),
    label: String(step.label || '').trim(),
    target: String(step.target || '').trim(),
    pointerNote: String(step.pointerNote || '').trim(),
    focusKeys: step.target ? [String(step.target)] : []
  })).filter((step) => step.text);

  const prepareDOM = (root) => {
    if (!root) return [];
    return [...root.querySelectorAll('[data-cue]')].map((element) => {
      const cue = element.dataset.cue || '';
      element.classList.add('focus-target');
      element.dataset.focusKey = cue;
      return { cue, element };
    });
  };

  const applyFocus = (root, slide, slideIndex, stepIndex) => {
    const targets = prepareDOM(root);
    targets.forEach(({ element }) => element.classList.remove('focus-muted', 'focus-active', 'focus-context', 'is-active', 'is-past'));
    if (stepIndex <= 0) return;

    const step = buildSteps(slide, slideIndex)[stepIndex - 1];
    if (!step?.target) return;

    const active = targets.filter(({ cue }) => cue === step.target).map(({ element }) => element);
    if (!active.length) return;

    const activeSet = new Set(active);
    targets.forEach(({ element }) => {
      if (activeSet.has(element)) element.classList.add('focus-active');
      else element.classList.add('focus-muted');
    });
  };

  window.CH2Navigation = Object.freeze({
    buildSteps,
    prepareDOM,
    applyFocus,
    slideCount: slides.length
  });
})();
