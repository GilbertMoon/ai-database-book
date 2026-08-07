(() => {
  'use strict';

  const normalizeSlides = (slides) => {
    (slides || []).forEach((slide) => {
      if (!slide || typeof slide.h !== 'string') return;
      const root = document.createElement('div');
      root.innerHTML = slide.h;
      root.querySelectorAll('[data-focus-step]').forEach((element) => {
        const steps = String(element.dataset.focusStep || '')
          .split(',')
          .map(Number)
          .filter(Number.isFinite)
          .sort((left, right) => left - right);
        if (steps.length <= 1) return;
        element.removeAttribute('data-focus-step');
        element.dataset.focusFrom = String(steps[0]);
        element.dataset.focusTo = String(steps[steps.length - 1]);
      });
      slide.h = root.innerHTML;
    });
    return slides || [];
  };

  window.normalizeChapter03FocusRanges = normalizeSlides;
  if (Array.isArray(window.CH3_SLIDES)) normalizeSlides(window.CH3_SLIDES);
})();
