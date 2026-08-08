(() => {
  'use strict';

  const AUTO = 'AUTO';
  const PLANS = {
    theory: {
      'Chapter 14는 분석 결과를 믿을 수 있게 만드는 장입니다': AUTO,
      'SQL과 Python은 역할이 다릅니다': [['row:*']],
      '분석 질문에는 기준이 필요합니다': [['body-0','code-0'], ['body-1','code-1']],
      '분석 기간은 반개방 구간으로 고정합니다': [['code-0'], ['code-1']],
      '`paid_amount`는 실제 매출이 아니라 기록 금액입니다': [['code-0'], ['body-0','code-1']],
      'Chapter 14는 `analysis_lab`만 사용합니다': [['code-0'], ['body-0','code-1']],
      '기준 데이터와 검산값을 먼저 봅니다': [['code-0'], ['body-0','code-1']],
      '분석 전에 데이터 품질을 확인합니다': [['body-0','code:*']],
      'JOIN과 집계는 한 행의 단위에서 시작합니다': [['code:*']],
      '`COUNT(*)`, `COUNT(e.id)`, `COUNT(DISTINCT s.id)`는 다릅니다': [['row:*']],
      'date spine은 데이터가 없는 월도 유지합니다': [['code-0'], ['code-1']],
      '현재 완료 상태 비중과 완료율은 다릅니다': [['row:*']],
      '완료 기간은 완료된 신청에만 적용됩니다': [['code-0'], ['body-0','code-1']],
      '분석 VIEW는 Python이 사용할 기준 데이터셋입니다': [['code:*']],
      'CSV는 manifest와 함께 관리해야 합니다': AUTO,
      'Python 연결은 읽기 전용과 비밀 보호를 확인합니다': [['code:*']],
      'Python 공통 검증은 오류를 숨기지 않아야 합니다': AUTO,
      '시각화는 검증 뒤에 수행합니다': AUTO,
      '실제 SQL 결과와 pandas 결과를 교차 검증합니다': AUTO,
      '핵심 정리: 분석은 질문과 검증으로 완성됩니다': [['code:*']]
    },
    practice: {
      '이번 실습은 분석 결과를 검증하는 연습입니다': AUTO,
      '실습 파일 순서를 정확히 지킵니다': [['code:*']],
      '보호 범위와 실행 위치를 확인합니다': [['code-0'], ['body-0','code-1']],
      '분석 질문과 기간을 먼저 적습니다': [['code-0'], ['code-1']],
      '금액 지표의 의미를 확인합니다': [['code-0'], ['body-0','code-1']],
      '기준 구조와 행 수를 검산합니다': [['row:*']],
      '활성 신청 규칙과 중복 적재 규칙을 구분합니다': [['row:*']],
      '데이터 품질 점검은 집계 전 필수 단계입니다': [['body-0','code:*']],
      '상태별 신청 건수를 확인합니다': [['row:*']],
      '강의별 분석에서는 `COUNT(e.id)`를 사용합니다': [['body-0','code:*']],
      '지역별 분석은 학생 수와 신청 수를 구분합니다': [['row:*']],
      'date spine으로 월별 결과를 유지합니다': [['row:*']],
      '완료 상태 비중과 완료 기간을 구분합니다': [['code:*']],
      '분석 데이터셋 VIEW의 한 행 단위를 확인합니다': [['code:*']],
      'SQL 최종 게이트를 통과시킵니다': [['body-0','code:*']],
      'CSV를 사용할 때는 manifest와 SHA-256을 기록합니다': AUTO,
      'Python 환경과 읽기 전용 연결을 확인합니다': [['code:*']],
      'Python 공통 검증은 자료형 오류를 숨기지 않습니다': AUTO,
      'pandas 결과와 SQL 결과를 직접 비교합니다': AUTO,
      '관찰·해석·한계와 AI 코드 검토까지 기록합니다': AUTO
    }
  };

  const TARGET_SPECS = [
    ['.screen-text','body'], ['.bullet-list li','item'], ['table tbody tr','row'],
    ['.code-line','code'], ['.quote','quote'], ['.card','card'], ['.flow-step','flow'],
    ['.pill','pill'], ['.chip','chip']
  ];
  const STOP_WORDS = new Set(['이번','장표','단계','입니다','있습니다','합니다','됩니다','그리고','하지만','따라서','먼저','다음','마지막','확인','경우','대한','위해','사용','실습','분석','데이터','결과','기준','항목']);

  const normalize = (value) => String(value ?? '').toLowerCase()
    .replace(/analysis_lab/g,'분석 랩').replace(/analysis_parameters/g,'분석 파라미터')
    .replace(/enrollment_analysis_dataset/g,'수강신청 분석 데이터셋')
    .replace(/paid_amount/g,'기록 금액').replace(/recorded_amount_sum/g,'기록 금액 합계')
    .replace(/recorded_amount/g,'기록 금액').replace(/completion_days/g,'완료 기간')
    .replace(/is_completed/g,'완료 여부').replace(/enrollment_id/g,'수강신청 아이디')
    .replace(/date spine/g,'월 기준표').replace(/manifest/g,'매니페스트')
    .replace(/sha-256/g,'해시').replace(/assert_frame_equal/g,'데이터프레임 비교')
    .replace(/reference_metrics\.json/g,'기준 지표 파일').replace(/repeatable read/g,'반복 가능 읽기')
    .replace(/transaction_read_only/g,'읽기 전용 트랜잭션').replace(/pgdatabase/g,'데이터베이스 환경 변수')
    .replace(/database_url/g,'데이터베이스 연결 주소').replace(/p14-q/g,'분석 질문')
    .replace(/count\s*\(\s*distinct/g,'고유 개수').replace(/count\s*\(\s*\*/g,'행 개수')
    .replace(/count/g,'개수').replace(/group by/g,'그룹 집계').replace(/left join/g,'레프트 조인')
    .replace(/join/g,'조인').replace(/coalesce/g,'널 대체').replace(/view/g,'뷰')
    .replace(/dataframe/g,'데이터프레임').replace(/pandas/g,'판다스').replace(/python/g,'파이썬')
    .replace(/postgresql/g,'포스트그레스큐엘').replace(/csv/g,'씨에스브이').replace(/sql/g,'에스큐엘')
    .replace(/null/g,'널').replace(/[^0-9a-z가-힣]+/g,' ').replace(/\s+/g,' ').trim();
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

  window.CH14Navigation=Object.freeze({version:'2026-08-08-semantic-1',PLANS,buildSteps,prepareSlides,applyFocus,audit});
})();
