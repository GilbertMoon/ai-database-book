(() => {
  const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (character) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
  }[character]));

  const inline = (value) => escapeHtml(value)
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');

  // 강의안 원본을 그대로 렌더링합니다.
  // 오래된 용어를 런타임에서 조용히 치환하면 소스 불일치를 숨길 수 있으므로
  // 용어 변경은 Markdown 강의안 자체에 반영하고 CI에서 검증합니다.
  const normalizeSource = (value) => String(value ?? '');

  function renderTable(lines) {
    const rows = lines
      .filter((line, index) => index !== 1 || !/^\|?\s*:?-{3,}/.test(line.replace(/\|/g, '')))
      .map((line) => line.trim().replace(/^\||\|$/g, '').split('|').map((cell) => cell.trim()));
    if (!rows.length) return '';
    const [header, ...body] = rows;
    return `<div class="table-wrap"><table><thead><tr>${header.map((cell) => `<th>${inline(cell)}</th>`).join('')}</tr></thead><tbody>${body.map((row) => `<tr>${row.map((cell) => `<td>${inline(cell)}</td>`).join('')}</tr>`).join('')}</tbody></table></div>`;
  }

  function renderCode(lines, language) {
    const languageClass = language ? ` language-${escapeHtml(language)}` : '';
    return `<div class="codebox code-lines${languageClass}">${lines.map((line) => `<div class="code-line">${inline(line) || '&nbsp;'}</div>`).join('')}</div>`;
  }

  function renderScreen(markdown) {
    const lines = String(markdown || '').trim().split('\n');
    const chunks = [];
    let index = 0;
    while (index < lines.length) {
      const line = lines[index];
      if (!line.trim()) { index += 1; continue; }

      if (line.trim().startsWith('```')) {
        const language = line.trim().slice(3).trim();
        const code = [];
        index += 1;
        while (index < lines.length && !lines[index].trim().startsWith('```')) {
          code.push(lines[index]);
          index += 1;
        }
        index += 1;
        chunks.push(renderCode(code, language));
        continue;
      }

      if (line.trim().startsWith('|')) {
        const table = [];
        while (index < lines.length && lines[index].trim().startsWith('|')) {
          table.push(lines[index]);
          index += 1;
        }
        chunks.push(renderTable(table));
        continue;
      }

      if (/^\s*[-*]\s+/.test(line)) {
        const items = [];
        while (index < lines.length && /^\s*[-*]\s+/.test(lines[index])) {
          items.push(lines[index].replace(/^\s*[-*]\s+/, '').trim());
          index += 1;
        }
        chunks.push(`<ul class="bullet-list">${items.map((item) => `<li>${inline(item)}</li>`).join('')}</ul>`);
        continue;
      }

      const paragraph = [];
      while (index < lines.length && lines[index].trim() && !lines[index].trim().startsWith('```') && !lines[index].trim().startsWith('|') && !/^\s*[-*]\s+/.test(lines[index])) {
        paragraph.push(lines[index].trim());
        index += 1;
      }
      chunks.push(`<p class="body-text screen-text">${inline(paragraph.join(' '))}</p>`);
    }
    return chunks.join('');
  }

  function parseSections(text, block) {
    const matches = [...String(text).matchAll(/^##\s+(\d+)\.\s+(.+)$/gm)];
    const label = block === 'practice' ? '실습 강의' : '이론 강의';
    return matches.map((match, index) => {
      const number = Number(match[1]);
      const title = match[2].trim();
      const start = match.index + match[0].length;
      const end = index + 1 < matches.length ? matches[index + 1].index : text.length;
      const section = text.slice(start, end);
      const screenMatch = section.match(/\*\*화면 구성\*\*\s*([\s\S]*?)\n\*\*발표 스크립트\*\*/);
      const scriptMatch = section.match(/\*\*발표 스크립트\*\*\s*([\s\S]*?)(?=\n---|\s*$)/);
      const screen = screenMatch ? screenMatch[1].trim() : '';
      const script = scriptMatch ? scriptMatch[1].trim() : '';
      const heading = number === 1
        ? `<h1>${inline(title)}</h1>`
        : `<h2>${inline(title)}</h2>`;
      return {
        k: `CHAPTER 07 · ${block === 'practice' ? 'PRACTICE' : 'THEORY'} · ${String(number).padStart(2, '0')}`,
        l: label,
        t: title,
        h: `${heading}${renderScreen(screen)}`,
        s: script
      };
    });
  }

  async function loadChapter07Slides(targetBlock) {
    const block = targetBlock === 'practice' ? 'practice' : 'theory';
    const source = block === 'practice' ? 'chapter07_practice_lecture_plan.md' : 'chapter07_theory_lecture_plan.md';
    const response = await fetch(source, { cache: 'no-store' });
    if (!response.ok) throw new Error(`Chapter 07 강의 계획서 로드 실패: ${response.status}`);
    const text = normalizeSource(await response.text());
    const slides = parseSections(text, block);
    window.CH7_BLOCK = block;
    window.CH7_TITLE = block === 'practice' ? 'Chapter 07 실습 강의' : 'Chapter 07 이론 강의';
    window.CH7_SLIDES = slides;
    dispatchEvent(new CustomEvent('chapter07-slides-ready', { detail: { block, slides } }));
    return slides;
  }

  window.loadChapter07Slides = loadChapter07Slides;
  const initialBlock = document.body?.dataset?.chapter07Block === 'practice' ? 'practice' : 'theory';
  loadChapter07Slides(initialBlock).catch((error) => {
    console.error(error);
    dispatchEvent(new CustomEvent('chapter07-slides-error', { detail: error }));
  });
})();