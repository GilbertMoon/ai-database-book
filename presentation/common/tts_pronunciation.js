(() => {
  'use strict';

  const RULES = [
    [/\bROLLBACK TO SAVEPOINT\b/g, '롤백 투 세이브포인트'],
    [/\bEXPLAIN ANALYZE\b/g, '익스플레인 애널라이즈'],
    [/\bBITMAP INDEX SCAN\b/gi, '비트맵 인덱스 스캔'],
    [/\bBITMAP HEAP SCAN\b/gi, '비트맵 힙 스캔'],
    [/\bCREATE UNIQUE INDEX\b/g, '크리에이트 유니크 인덱스'],
    [/\bCREATE TABLE\b/g, '크리에이트 테이블'],
    [/\bPRIMARY KEY\b/g, '프라이머리 키'],
    [/\bFOREIGN KEY\b/g, '포린 키'],
    [/\bFULL OUTER JOIN\b/g, '풀 아우터 조인'],
    [/\bINNER JOIN\b/g, '이너 조인'],
    [/\bLEFT JOIN\b/g, '레프트 조인'],
    [/\bRIGHT JOIN\b/g, '라이트 조인'],
    [/\bCROSS JOIN\b/g, '크로스 조인'],
    [/\bGROUP BY\b/g, '그룹 바이'],
    [/\bORDER BY\b/g, '오더 바이'],
    [/\bPARTITION BY\b/g, '파티션 바이'],
    [/\bFOR UPDATE\b/g, '포 업데이트'],
    [/\bNOT EXISTS\b/g, '낫 이그지스츠'],
    [/\bNOT NULL\b/g, '낫 널'],
    [/\bON DELETE RESTRICT\b/g, '온 딜리트 리스트릭트'],
    [/\bON DELETE CASCADE\b/g, '온 딜리트 캐스케이드'],
    [/\bREPEATABLE READ\b/g, '리피터블 리드'],
    [/\bREAD COMMITTED\b/g, '리드 커미티드'],
    [/\bREAD ONLY\b/g, '리드 온리'],
    [/\bSQLSTATE\b/g, '에스큐엘 스테이트'],
    [/\bSQLAlchemy\b/g, '에스큐엘알케미'],
    [/\bPostgreSQL\b/g, '포스트그레스큐엘'],
    [/\bChatGPT\b/g, '챗지피티'],
    [/\bDBeaver\b/g, '디비버'],
    [/\bNoSQL\b/g, '노에스큐엘'],
    [/\bRDBMS\b/g, '알디비엠에스'],
    [/\bDBMS\b/g, '디비엠에스'],
    [/\bJSONB\b/g, '제이슨비'],
    [/\bJSON\b/g, '제이슨'],
    [/\bPython\b/g, '파이썬'],
    [/\bpandas\b/gi, '판다스'],
    [/\bmatplotlib\b/gi, '맷플롯립'],
    [/\bpsycopg\b/gi, '사이코피지'],
    [/\bCodex\b/g, '코덱스'],
    [/\bGitHub\b/g, '깃허브'],
    [/\bGit\b/g, '깃'],
    [/\bdiff\b/gi, '디프'],
    [/\bChapter\b/g, '챕터'],
    [/\bDatabase\b/g, '데이터베이스'],
    [/\bSchema\b/g, '스키마'],
    [/\bTable\b/g, '테이블'],
    [/\bColumn\b/g, '열'],
    [/\bRow\b/g, '행'],
    [/\bCell\b/g, '셀'],
    [/\bServer\b/g, '서버'],
    [/\bClient\b/g, '클라이언트'],
    [/\bEntity\b/g, '엔터티'],
    [/\bAttribute\b/g, '애트리뷰트'],
    [/\bRelationship\b/g, '릴레이션십'],
    [/\bRequirements?\b/g, '리콰이어먼트'],
    [/\bConceptual\b/g, '컨셉추얼'],
    [/\bLogical\b/g, '로지컬'],
    [/\bPhysical\b/g, '피지컬'],
    [/\bAuto-commit\b/gi, '오토 커밋'],
    [/\bManual commit\b/gi, '매뉴얼 커밋'],
    [/\bcurrent transaction is aborted\b/gi, '커런트 트랜잭션 이즈 어보티드'],
    [/\btransaction_lab\b/g, '트랜잭션 랩'],
    [/\bcourse_project\b/g, '코스 프로젝트'],
    [/\bcourse_inventory\b/g, '코스 인벤토리'],
    [/\btutor_project_restore\b/g, '튜터 프로젝트 리스토어'],
    [/\btutor_project\b/g, '튜터 프로젝트'],
    [/\bquestion_materials\b/g, '퀘스천 머티리얼즈'],
    [/\blearning_materials\b/g, '러닝 머티리얼즈'],
    [/\bstudents\b/g, '스튜던츠'],
    [/\binstructors\b/g, '인스트럭터스'],
    [/\bcourses\b/g, '코시스'],
    [/\benrollments\b/g, '인롤먼츠'],
    [/\bpayments\b/g, '페이먼츠'],
    [/\bSQL\b/g, '에스큐엘'],
    [/\bAI\b/g, '에이아이'],
    [/\bTTS\b/g, '티티에스'],
    [/\bAPI\b/g, '에이피아이'],
    [/\bERD\b/g, '이알디'],
    [/\bDDL\b/g, '디디엘'],
    [/\bDML\b/g, '디엠엘'],
    [/\bDCL\b/g, '디씨엘'],
    [/\bTCL\b/g, '티씨엘'],
    [/\bCRUD\b/g, '크러드'],
    [/\bCSV\b/g, '씨에스브이'],
    [/\bURL\b/g, '유알엘'],
    [/\bSSL\b/g, '에스에스엘'],
    [/\bCTE\b/g, '씨티이'],
    [/\bACID\b/g, '에이씨아이디'],
    [/\bRLS\b/g, '알엘에스'],
    [/\bACL\b/g, '에이씨엘'],
    [/\bPK\b/g, '피케이'],
    [/\bFK\b/g, '에프케이'],
    [/\bID\b/g, '아이디'],
    [/\bIDENTITY\b/g, '아이덴티티'],
    [/\bVIEW\b/g, '뷰'],
    [/\bRETURNING\b/g, '리터닝'],
    [/\bROLLBACK\b/g, '롤백'],
    [/\bCOMMIT\b/g, '커밋'],
    [/\bBEGIN\b/g, '비긴'],
    [/\bSAVEPOINT\b/g, '세이브포인트'],
    [/\bEXPLAIN\b/g, '익스플레인'],
    [/\bANALYZE\b/g, '애널라이즈'],
    [/\bSeq Scan\b/g, '시퀀셜 스캔'],
    [/\bIndex Only Scan\b/g, '인덱스 온리 스캔'],
    [/\bIndex Scan\b/g, '인덱스 스캔'],
    [/\bGIN\b/g, '진'],
    [/\bB-tree\b/gi, '비트리'],
    [/\bB\+Tree\b/g, '비플러스 트리'],
    [/\bJOIN\b/g, '조인'],
    [/\bNULL\b/g, '널'],
    [/\bINSERT\b/g, '인서트'],
    [/\bSELECT\b/g, '셀렉트'],
    [/\bUPDATE\b/g, '업데이트'],
    [/\bDELETE\b/g, '딜리트'],
    [/\bWHERE\b/g, '웨어'],
    [/\bHAVING\b/g, '해빙'],
    [/\bDISTINCT\b/g, '디스팅트'],
    [/\bFILTER\b/g, '필터'],
    [/\bCOALESCE\b/g, '코얼레스'],
    [/\bUNIQUE\b/g, '유니크'],
    [/\bCHECK\b/g, '체크'],
    [/\bREFERENCES\b/g, '레퍼런시스'],
    [/\bCASCADE\b/g, '캐스케이드'],
    [/\bRESTRICT\b/g, '리스트릭트'],
    [/\bDEFAULT\b/g, '디폴트'],
    [/\bPUBLIC\b/g, '퍼블릭'],
    [/\bGRANT\b/g, '그랜트'],
    [/\bPGPASSFILE\b/g, '피지 패스 파일'],
    [/\bpg_dump\b/g, '피지 덤프'],
    [/\bpg_restore\b/g, '피지 리스토어'],
    [/\bLock\b/g, '락'],
    [/\bDeadlock\b/g, '데드락'],
    [/\block_timeout\b/g, '락 타임아웃'],
    [/\bAtomicity\b/g, '아토미시티'],
    [/\bConsistency\b/g, '컨시스턴시'],
    [/\bIsolation\b/g, '아이솔레이션'],
    [/\bDurability\b/g, '듀러빌리티'],
    [/\b1NF\b/g, '제일 정규형'],
    [/\b2NF\b/g, '제이 정규형'],
    [/\b3NF\b/g, '제삼 정규형'],
    [/COUNT\(\*\)/g, '카운트 별표'],
    [/\bCOUNT\b/g, '카운트'],
    [/\bSUM\b/g, '썸'],
    [/\bAVG\b/g, '에버리지'],
    [/\bMIN\b/g, '민'],
    [/\bMAX\b/g, '맥스']
  ];

  const normalize = (value) => RULES.reduce(
    (result, [pattern, replacement]) => result.replace(pattern, replacement),
    String(value ?? '')
  );

  window.PresentationTTS = Object.freeze({ normalize, rules: RULES.slice() });

  const TARGET_SELECTOR = '.script-text, .text, .speaker-script, .narration, [data-tts], [data-tts-script]';
  const SKIP_SELECTOR = 'script, style, textarea, pre, code, kbd, samp';

  const isNarrationNode = (node) => {
    const parent = node.parentElement;
    return Boolean(parent && parent.closest(TARGET_SELECTOR) && !parent.closest(SKIP_SELECTOR));
  };

  const normalizeTextNode = (node) => {
    if (node.nodeType !== Node.TEXT_NODE || !isNarrationNode(node)) return;
    const updated = normalize(node.nodeValue);
    if (updated !== node.nodeValue) node.nodeValue = updated;
  };

  const normalizeElement = (root) => {
    if (!root) return;
    if (root.nodeType === Node.TEXT_NODE) {
      normalizeTextNode(root);
      return;
    }
    if (root.nodeType !== Node.ELEMENT_NODE && root.nodeType !== Node.DOCUMENT_NODE && root.nodeType !== Node.DOCUMENT_FRAGMENT_NODE) return;

    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
    const nodes = [];
    while (walker.nextNode()) nodes.push(walker.currentNode);
    nodes.forEach(normalizeTextNode);
  };

  const start = () => {
    normalizeElement(document);
    const observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        if (mutation.type === 'characterData') normalizeTextNode(mutation.target);
        mutation.addedNodes.forEach(normalizeElement);
      }
    });
    observer.observe(document.body, { childList: true, subtree: true, characterData: true });
  };

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start, { once: true });
  else start();
})();
