(() => {
  'use strict';

  const plans = {
    theory: {
      'CHAPTER 03 · THEORY': { groups: [['lead:0'], ['pill:*']] },
      'CHAPTER GOALS': { sequence: ['item'] },
      'CHAPTER FLOW': { sequence: ['flow'] },
      'CHAPTER GOAL': { sequence: ['item'] },
      'NOT THIS CHAPTER': { sequence: ['card'] },
      'PRACTICE PATH': { sequence: ['flow'] },
      'ENVIRONMENT': { sequence: ['card'] },
      'VERSION BASELINE': { sequence: ['row'] },
      'ROLE REVIEW': { sequence: ['row'] },
      'CLIENT SERVER': { sequence: ['flow'] },
      'LOCAL VS MANAGED': { sequence: ['card'] },
      'CONNECTION VALUES': { sequence: ['row'] },
      'POSTGRES NAME': { sequence: ['card'] },
      'SECURITY FIRST': { sequence: ['item'] },
      'DATABASE CREATION': { groups: [['code:*']] },
      'CREATE DATABASE': { groups: [['code:*'], ['quote:0']] },
      'RECONNECT': { sequence: ['flow'] },
      'CHECK CURRENT': { sequence: ['code'] },
      'SCHEMA CAVEAT': { groups: [['quote:0']] },
      'EXECUTION RANGE': { sequence: ['card'] },
      'AUTO COMMIT': { sequence: ['card'] },
      'SETUP CHECK': { groups: [['code:0','code:1'], ['code:2','code:3'], ['code:4','code:5'], ['code:6']] },
      'VALIDATION FILE': { sequence: ['item'] },
      'ERROR TYPES': { sequence: ['row'] },
      'AI ERROR QUESTION': { groups: [['prompt:0','prompt:1'], ['prompt:2','prompt:3'], ['prompt:4','prompt:5'], ['prompt:6','prompt:7']] },
      'DONE CRITERIA': { sequence: ['row'] },
      'THEORY WRAP-UP': { groups: [['quote:0'], ['body:0']] }
    },
    practice: {
      'CHAPTER 03 · PRACTICE': { groups: [['lead:0'], ['pill:*']] },
      'PRACTICE RULE': { sequence: ['card'] },
      'CHECK BEFORE': { sequence: ['row'] },
      'DOWNLOAD POSTGRESQL': { sequence: ['item'] },
      'RUN INSTALLER': { sequence: ['card'] },
      'SET PASSWORD': { sequence: ['card'] },
      'PORT 5432': { groups: [['quote:0'], ['body:0']] },
      'STACK BUILDER': { sequence: ['card'] },
      'SERVICE STATUS': { sequence: ['item'] },
      'OPTIONAL PSQL': { groups: [['code:*'], ['body:0']] },
      'DOWNLOAD DBEAVER': { sequence: ['item'] },
      'NEW CONNECTION': { sequence: ['flow'] },
      'DRIVER DOWNLOAD': { sequence: ['card'] },
      'CONNECTION INPUT': { sequence: ['row'] },
      'TEST CONNECTION': { sequence: ['card'] },
      'SAVE CONNECTION': { sequence: ['item'] },
      'CHECK DB EXISTS': { groups: [['code:*']] },
      'IF EXISTS': { sequence: ['card'] },
      'CREATE DB': { groups: [['code:*'], ['item:0'], ['item:1'], ['item:2']] },
      'CREATE ERRORS': { sequence: ['row'] },
      'RECONNECT DB': { sequence: ['flow'] },
      'CURRENT DATABASE': { groups: [['code:*'], ['quote:0']] },
      'SCHEMA PATH': { groups: [['code:0'], ['code:1'], ['body:0']] },
      'NAVIGATOR PATH': { sequence: ['hierarchy'] },
      'READ ONLY TIMEZONE': { groups: [['code:0'], ['code:1'], ['quote:0']] },
      'SETUP CHECK RUN': { sequence: ['item'] },
      'CHECK RESULT': { sequence: ['row'] },
      'VALIDATE RUN': { groups: [['codebox:*'], ['body:0']] },
      'SAVE RECORD': { groups: [['code:0','code:1','code:2'], ['code:3','code:4','code:5'], ['code:6','code:7'], ['code:8','code:9']] },
      'SECRET CHECK': { sequence: ['item'] },
      'ERROR CONNECTION REFUSED': { sequence: ['card'] },
      'ERROR PASSWORD': { sequence: ['card'] },
      'ERROR DB DOES NOT EXIST': { sequence: ['item'] },
      'ERROR TRANSACTION': { sequence: ['card'] },
      'ERROR TABLES INVISIBLE': { groups: [['code:0'], ['code:1'], ['code:2'], ['body:0']] },
      'AI QUESTION': { groups: [['prompt:0','prompt:1'], ['prompt:2','prompt:3'], ['prompt:4','prompt:5','prompt:6'], ['prompt:7','prompt:8']] },
      'FINAL CHECKLIST': { sequence: ['row'] },
      'NEXT CHAPTER': { sequence: ['flow'] }
    }
  };

  const apply = (slides, block = 'theory') => {
    const selected = plans[block === 'practice' ? 'practice' : 'theory'];
    (slides || []).forEach((slide) => {
      if (!slide || typeof slide !== 'object') return;
      const plan = selected[String(slide.k || '')];
      if (plan) slide.__chapter03SemanticPlan = plan;
      else delete slide.__chapter03SemanticPlan;
    });
    return slides || [];
  };

  window.CH3SemanticPlan = Object.freeze({ plans, apply });
})();
