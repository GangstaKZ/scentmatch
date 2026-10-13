const {test} = require('node:test');
const assert = require('node:assert/strict');
const {rank} = require('../lib/ranking');
const rows = require('../../assets/data/perfumes.json');
test('matches family, budget, season and longevity deterministically', () => {
  const quiz = {family:'woody',gender:'male',budget:'budget',season:'summer',longevity:'medium',mood:'day',age:'any'};
  const result = rank(rows,quiz);
  assert.equal(result[0].perfumeId,'montblanc-explorer');
  assert.equal(result[0].score,100);
  assert.deepEqual(result,rank(rows,{...quiz,age:'45+'}));
  assert.equal(new Set(result.map(r=>r.perfumeId)).size,6);
  assert(result.every(r=>r.score>=0 && r.score<=100));
});
