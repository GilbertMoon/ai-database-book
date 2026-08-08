(() => {
  'use strict';

  const AUTO = 'AUTO';
  const PLANS = {
    theory: {
      'Chapter 15는 책 전체를 하나의 프로젝트로 묶습니다': AUTO,
      '필수 경로와 선택 확장을 먼저 나눕니다': [['code:*']],
      '파일 구조는 실행 순서와 증거 흐름을 보여 줘야 합니다': [['code:*']],
      '문제·사용자·제외 범위를 명확히 합니다': [['row:*']],
      'P15 추적 ID로 요구사항과 후속 정책을 분리합니다': [['code-0'], ['code-1']],
      'ERD는 업무 문장을 테이블과 관계로 바꾸는 작업입니다': [['code:*']],
      '실제 메타데이터로 설계를 확인합니다': [['code:*']],
      'Seed 데이터는 테스트할 이야기를 담아야 합니다': [['code-0'], ['body-0','code-1']],
      '시간 정합성은 제약조건과 검증 SQL로 나눕니다': [['code:*']],
      '트랜잭션은 성공과 실패 후 복구를 모두 증명합니다': [['code:*']],
      '반례 테스트는 실패와 정상 경계값을 함께 봅니다': [['code:*']],
      '인덱스는 후보와 실제 효과 검증을 구분합니다': [['row:*']],
      '보안 점검은 분류 값과 실제 권한을 구분합니다': [['code:*']],
      '백업은 파일 생성이 아니라 별도 DB 복원으로 증명합니다': [['code:*']],
      '분석 VIEW는 질문 단위와 0건 포함 요약을 분리합니다': [['code:*']],
      'SQL과 pandas 결과는 같은 스냅샷에서 비교합니다': [['code:*']],
      'DB 완료 게이트와 전체 프로젝트 완료는 다릅니다': [['row:*']],
      'AI 변경은 diff와 실행 증거로 승인합니다': [['code:*']],
      '프로젝트 완성도는 일곱 축으로 설명합니다': [['code:*']],
      '핵심 정리: 프로젝트 완성은 재현 가능한 증거입니다': [['code:*']]
    },
    practice: {
      '이번 실습은 책 전체를 하나의 프로젝트로 실행하는 과정입니다': [['code:*']],
      '실행 순서를 먼저 고정합니다': [['code:*']],
      '보호 범위와 현재 DB를 확인합니다': [['code-0'], ['body-0','code-1']],
      '요구사항과 후속 정책을 먼저 적습니다': [['code:*']],
      '`01_schema.sql`은 구조를 만들고 기준을 세웁니다': [['code:*']],
      '`02_seed.sql`은 기준 데이터와 경계 사례를 만듭니다': [['row:*']],
      '`03_metadata_validation.sql`로 실제 구조를 검증합니다': [['code:*']],
      '`04_requirement_queries.sql`은 업무 질문을 확인합니다': [['code:*']],
      '`05_transaction_checks.sql`은 함께 바뀌어야 하는 작업을 확인합니다': [['code:*']],
      '`06_negative_tests.sql`은 실패와 정상 경계값을 함께 확인합니다': [['code:*']],
      '`07_performance_checks.sql`은 인덱스 후보를 점검합니다': [['row:*']],
      '`08_operations_checks.sql`은 권한·보안·분류 값을 점검합니다': [['code:*']],
      '`09_analysis_dataset.sql`은 분석 VIEW를 만듭니다': [['code:*']],
      '`10_completion_gate.sql`은 DB 완료 기준을 자동 판정합니다': [['code:*']],
      'Python 01~03은 실제 SQL 결과와 pandas 결과를 비교합니다': [['code:*']],
      '결과가 다르면 먼저 기준을 확인합니다': [['code:*']],
      '백업과 별도 DB 복원으로 복구 가능성을 확인합니다': [['code:*']],
      '완료 판단은 단계별 증거로 나눕니다': [['row:*']],
      'AI diff와 보고서는 사람이 승인합니다': [['code:*']],
      '최종 정리는 “재현 가능한 증거”로 마무리합니다': [['code:*']]
    }
  };

  const TARGET_SPECS = [
    ['.screen-text','body'], ['.bullet-list li','item'], ['table tbody tr','row'],
    ['.code-line','code'], ['.quote','quote'], ['.card','card'], ['.flow-step','flow'],
    ['.pill','pill'], ['.chip','chip']
  ];
  const STOP_WORDS = new Set(['이번','장표','단계','입니다','있습니다','합니다','됩니다','그리고','하지만','따라서','먼저','다음','마지막','확인','경우','대한','위해','사용','실습','프로젝트','데이터','결과','기준','항목','검증']);

  const normalize = (value) => String(value ?? '').toLowerCase()
    .replace(/tutor_project_restore/g,'튜터 프로젝트 복원').replace(/tutor_project/g,'튜터 프로젝트')
    .replace(/question_materials/g,'질문 자료 연결').replace(/learning_materials/g,'학습 자료')
    .replace(/question_analysis_dataset/g,'질문 분석 데이터셋').replace(/student_question_summary/g,'학생 질문 요약')
    .replace(/tutor_answer_summary/g,'튜터 답변 요약').replace(/analysis_parameters/g,'분석 파라미터')
    .replace(/access_scope/g,'접근 범위').replace(/p15-r/g,'확정 요구사항').replace(/p15-d/g,'후속 정책')
    .replace(/p15-t/g,'테스트').replace(/p15-v/g,'검증 단계').replace(/assert_frame_equal/g,'데이터프레임 비교')
    .replace(/repeatable read/g,'반복 가능 읽기').replace(/read only/g,'읽기 전용').replace(/pgpassfile/g,'비밀번호 파일')
    .replace(/pg_dump/g,'백업').replace(/pg_restore/g,'복원').replace(/sqlstate/g,'오류 코드')
    .replace(/seq scan/g,'시퀀셜 스캔').replace(/acl/g,'권한 목록').replace(/public/g,'퍼블릭')
    .replace(/identity/g,'자동 증가').replace(/foreign key|\bfk\b/g,'외래키').replace(/primary key|\bpk\b/g,'기본키')
    .replace(/cascade/g,'연쇄 삭제').replace(/constraint/g,'제약조건').replace(/unique/g,'고유')
    .replace(/left join/g,'레프트 조인').replace(/join/g,'조인').replace(/rollback/g,'롤백').replace(/commit/g,'커밋')
    .replace(/view/g,'뷰').replace(/diff/g,'변경 차이').replace(/pandas/g,'판다스').replace(/python/g,'파이썬')
    .replace(/postgresql/g,'포스트그레스큐엘').replace(/erd/g,'이알디').replace(/ddl/g,'디디엘').replace(/sql/g,'에스큐엘')
    .replace(/ai/g,'에이아이').replace(/null/g,'널').replace(/[^0-9a-z가-힣]+/g,' ').replace(/\s+/g,' ').trim();
  const tokensOf = (value) => new Set(normalize(value).split(' ').filter((token) => token.length >= 2 && !STOP_WORDS.has(token)));

  function splitUnits(text) {
    const paragraphs = String(text || '').trim().split(/\n\s*\n/).map((v) => v.replace(/\s+/g,' ').trim()).filter(Boolean);
    const units = [];
    paragraphs.forEach((p) => {
      const sentences = (p.match(/[^.!?。]+[.!?。]?/g) || []).map((v) => v.trim()).filter(Boolean);
      units.push(...(sentences.length > 1 ? sentences : [p]));
    });
    return units.length ? units : ['핵심 내용을 설명합니다.'];
  }

  function collectTargets(root) {
    const found = [], seen = new Set();
    TARGET_SPECS.forEach(([selector,prefix]) => root.querySelectorAll(selector).forEach((element) => {
      if (seen.has(element)) return;
      const text = (element.innerText || element.textContent || '').replace(/\s+/g,' ').trim();
      if (prefix === 'code' && !text) return;
      seen.add(element); found.push({element,prefix,text});
    }));
    found.sort((a,b) => a.element === b.element ? 0 : (a.element.compareDocumentPosition(b.element) & Node.DOCUMENT_POSITION_FOLLOWING ? -1 : 1));
    const counts = {};
    return found.map((target) => ({...target,key:`${target.prefix}-${counts[target.prefix] = counts[target.prefix] || 0}`, _inc:(counts[target.prefix] += 1)})).map(({_inc,...target}) => target);
  }

  function detachedTargets(html) { const holder = document.createElement('div'); holder.innerHTML = html || ''; return collectTargets(holder); }
  function expandGroup(specs, targets) {
    const keys = [];
    specs.forEach((spec) => {
      if (spec.endsWith(':*')) targets.filter((t) => t.prefix === spec.slice(0,-2)).forEach((t) => keys.push(t.key));
      else if (targets.some((t) => t.key === spec)) keys.push(spec);
    });
    return [...new Set(keys)];
  }
  function mergeGroups(groups,maxGroups) {
    if (groups.length <= maxGroups) return groups;
    const merged = Array.from({length:maxGroups},()=>[]);
    groups.forEach((group,index) => merged[Math.min(maxGroups-1,Math.floor(index*maxGroups/groups.length))].push(...group));
    return merged.map((group) => [...new Set(group)]);
  }
  function autoGroups(targets) {
    const detailed = targets.filter((target) => target.prefix !== 'body');
    const source = detailed.length ? detailed : targets;
    return mergeGroups(source.map((target) => [target.key]),6);
  }
  const groupText = (group,targets) => group.map((key) => targets.find((t) => t.key === key)?.text || '').join(' ');
  function score(unit,group,g,m,i,n,targets) {
    const a=tokensOf(unit), b=tokensOf(groupText(group,targets)); let s=0;
    a.forEach((token) => { if (b.has(token)) s += token.length >= 5 ? 6 : token.length >= 3 ? 4 : 2; });
    return s - Math.abs((i+.5)/Math.max(1,n) - (g+.5)/Math.max(1,m))*4;
  }
  function partition(units,groups,targets) {
    if (!groups.length) return [{text:units.join(' '),focusKeys:[]}];
    const effective = mergeGroups(groups,Math.max(1,Math.min(groups.length,units.length)));
    if (effective.length === 1) return [{text:units.join(' '),focusKeys:effective[0]}];
    const n=units.length,m=effective.length,prefix=Array.from({length:m},()=>Array(n+1).fill(0));
    for(let g=0;g<m;g++) for(let i=0;i<n;i++) prefix[g][i+1]=prefix[g][i]+score(units[i],effective[g],g,m,i,n,targets);
    const dp=Array.from({length:m+1},()=>Array(n+1).fill(-Infinity)), prev=Array.from({length:m+1},()=>Array(n+1).fill(-1)); dp[0][0]=0;
    for(let g=1;g<=m;g++) for(let end=g;end<=n-(m-g);end++) for(let start=g-1;start<end;start++) {
      if(!Number.isFinite(dp[g-1][start])) continue;
      const center=((start+end)/2)/n, expected=(g-.5)/m;
      const candidate=dp[g-1][start]+prefix[g-1][end]-prefix[g-1][start]-Math.abs(center-expected)*6;
      if(candidate>dp[g][end]){dp[g][end]=candidate;prev[g][end]=start;}
    }
    const bounds=[]; let end=n;
    for(let g=m;g>=1;g--){const start=Math.max(0,prev[g][end]);bounds.push([start,end]);end=start;}
    bounds.reverse();
    return bounds.map(([start,finish],index)=>({text:units.slice(start,finish).join(' '),focusKeys:effective[index]})).filter((step)=>step.text);
  }

  function planFor(slide,block){return PLANS[block]?.[slide?.t];}
  function buildSteps(slide,index,block='theory') {
    const targets=detachedTargets(slide?.h || ''), units=splitUnits(slide?.s || '');
    const plan=planFor(slide,block); let groups;
    if(plan===AUTO || plan==null) groups=autoGroups(targets);
    else groups=plan.map((specs)=>expandGroup(specs,targets)).filter((group)=>group.length);
    return partition(units,groups,targets);
  }
  function prepareSlides(slides,block='theory'){ slides.forEach((slide,index)=>{slide.steps=buildSteps(slide,index,block).length;}); return slides; }
  function applyFocus(root,slide,index,stepIndex,block='theory') {
    const targets=collectTargets(root); targets.forEach((target)=>target.element.classList.add('focus-target'));
    const activeKeys=new Set(buildSteps(slide,index,block)[Math.max(0,stepIndex-1)]?.focusKeys || []);
    targets.forEach((target)=>{const active=stepIndex>0&&activeKeys.has(target.key);target.element.classList.toggle('focus-active',active);target.element.classList.toggle('focus-muted',stepIndex>0&&!active);});
  }
  function audit(slides,block='theory') {
    const issues=[]; slides.forEach((slide,index)=>{if(!Object.prototype.hasOwnProperty.call(PLANS[block]||{},slide?.t)) issues.push(`slide ${index+1}: missing plan ${slide?.t}`); if(!String(slide?.s||'').trim()) issues.push(`slide ${index+1}: empty script`); if(!String(slide?.h||'').trim()) issues.push(`slide ${index+1}: empty screen`);}); return issues;
  }

  window.CH15Navigation=Object.freeze({version:'2026-08-08-semantic-1',PLANS,buildSteps,prepareSlides,applyFocus,audit});
})();
