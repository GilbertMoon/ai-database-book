(() => {
  const sentenceRules = [
    [
      /화면 오른쪽에는 전체 열다섯 개 장의 흐름이 정리되어 있습니다\./g,
      '이 장표에는 전체 열다섯 개 장의 흐름이 정리되어 있습니다.'
    ],
    [
      /화면에 보이는 내용을 위에서 아래 순서로 천천히 살펴보겠습니다\./g,
      '장표의 핵심 내용을 제시된 순서대로 살펴보겠습니다.'
    ],
    [
      /화면 왼쪽에는 이 (?:발표)?자료를 띄우고,\s*오른쪽에는 ([^.]+?)(?:을|를) 띄워(?: 놓는 방식으로|서)? 진행합니다\./g,
      (_, target) => `발표자료의 단계 안내와 함께 ${target}도 확인하며 진행합니다.`
    ],
    [
      /왼쪽에는 이 자료를,\s*오른쪽에는 ([^<.]+?)(?:을|를) 띄워(?:놓고)?/g,
      (_, target) => `발표자료의 단계 안내와 함께 ${target}도 확인하며`
    ],
    [
      /발표자료를 한쪽에 두고,\s*다른 쪽에는 ([^.]+?)(?:을|를) 띄워서 함께 따라갑니다\./g,
      (_, target) => `발표자료의 단계 안내와 함께 ${target}도 확인하며 따라갑니다.`
    ]
  ];

  const phraseRules = [
    [/위에서 아래 순서로/g, '제시된 순서대로'],
    [/왼쪽에서 오른쪽 순서로/g, '제시된 순서대로'],
    [/화면의 왼쪽/g, '장표의 첫 번째 내용'],
    [/화면의 오른쪽/g, '장표의 다음 내용'],
    [/화면 왼쪽/g, '장표의 첫 번째 내용'],
    [/화면 오른쪽/g, '장표의 다음 내용'],
    [/화면 상단/g, '장표의 제목 부분'],
    [/화면 하단/g, '장표의 보충 내용'],
    [/화면 위쪽/g, '장표의 앞부분'],
    [/화면 아래쪽/g, '장표의 뒷부분'],
    [/좌측/g, '첫 번째 영역'],
    [/우측/g, '다음 영역'],
    [/왼쪽 (표|카드|예시|SQL|코드|그림|영역)/g, '첫 번째 $1'],
    [/오른쪽 (표|카드|예시|SQL|코드|그림|영역)/g, '두 번째 $1']
  ];

  const neutralize = (value) => {
    let result = String(value || '');
    sentenceRules.forEach(([pattern, replacement]) => {
      result = result.replace(pattern, replacement);
    });
    phraseRules.forEach(([pattern, replacement]) => {
      result = result.replace(pattern, replacement);
    });
    return result;
  };

  Object.keys(window)
    .filter((key) => /^CH\d+_SLIDES$/.test(key) && Array.isArray(window[key]))
    .forEach((key) => {
      window[key].forEach((slide) => {
        if (!slide || typeof slide !== 'object') return;
        if (typeof slide.s === 'string') slide.s = neutralize(slide.s);
        if (typeof slide.h === 'string') slide.h = neutralize(slide.h);
      });
    });

  window.normalizePresentationScreenPosition = neutralize;
})();
