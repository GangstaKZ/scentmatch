import {initializeApp} from 'firebase-admin/app';
import {getFirestore} from 'firebase-admin/firestore';
import {onCall, HttpsError} from 'firebase-functions/v2/https';
import {defineSecret, defineString} from 'firebase-functions/params';
import {logger} from 'firebase-functions';
import {Fragrance, rank} from './ranking';
import {aiOrder} from './openai';

initializeApp();
const db = getFirestore();
const openaiKey = defineSecret('OPENAI_API_KEY');
const aiEnabled = defineString('AI_ENABLED', {default: 'false'});
const aiModel = defineString('OPENAI_MODEL', {default: 'gpt-4o-mini'});
// Secret binding is optional for the stub deployment; enable it together with AI.
const bindKey = process.env.SCENTMATCH_BIND_OPENAI === 'true';
export const recommendPerfumes = onCall({region: 'europe-west1', timeoutSeconds: 30,
  maxInstances: 10, enforceAppCheck: process.env.FUNCTIONS_EMULATOR !== 'true', secrets: bindKey ? [openaiKey] : []}, async request => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required');
  const profile = await db.doc(`users/${request.auth.uid}`).get();
  const quiz = profile.data()?.quizAnswers as Record<string, string> | undefined;
  if (!quiz || Object.keys(quiz).length !== 7) throw new HttpsError('failed-precondition', 'Complete the quiz');
  const day = new Date().toISOString().slice(0, 10);
  const counter = db.doc(`recommendationUsage/${request.auth.uid}_${day}`);
  await db.runTransaction(async tx => {
    const count = (await tx.get(counter)).data()?.count ?? 0;
    if (count >= 20) throw new HttpsError('resource-exhausted', 'Daily recommendation limit reached');
    tx.set(counter, {count: count + 1, expiresAt: new Date(Date.now() + 2 * 86400000)});
  });
  const snapshot = await db.collection('perfumes').limit(500).get();
  const catalog = snapshot.docs.map(doc => ({...doc.data(), id: doc.id} as Fragrance));
  const fallback = rank(catalog, quiz);
  if (aiEnabled.value() === 'true' && bindKey && fallback.length > 0) {
    try {
      const ids = await aiOrder(openaiKey.value(), aiModel.value(), catalog.filter(p => fallback.some(r => r.perfumeId === p.id)), quiz);
      // Scores stay deterministic quiz-match values; AI only reorders candidates.
      const ordered = ids.map(id => ({...fallback.find(r => r.perfumeId === id)!, reason: 'ai'}));
      return {recommendations: ordered, source: 'openai'};
    } catch (error) { logger.warn('AI unavailable; returning quiz matches', {kind: error instanceof Error ? error.name : 'Unknown'}); }
  }
  return {recommendations: fallback, source: 'local'};
});
