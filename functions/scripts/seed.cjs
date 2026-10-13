const {initializeApp, applicationDefault} = require('firebase-admin/app');
const {getFirestore} = require('firebase-admin/firestore');
const data = require('../../assets/data/perfumes.json');

// Production catalog writes are deliberate and run only with Admin credentials.
const projectId = process.env.GCLOUD_PROJECT;
if (!projectId) throw new Error('Set GCLOUD_PROJECT explicitly');
if (!process.env.FIRESTORE_EMULATOR_HOST && process.env.ALLOW_PRODUCTION_SEED !== projectId) {
  throw new Error('Set ALLOW_PRODUCTION_SEED to the exact target project ID');
}
initializeApp({projectId, ...(process.env.FIRESTORE_EMULATOR_HOST ? {} : {credential: applicationDefault()})});
(async () => {
  const batch = getFirestore().batch();
  for (const {id, ...perfume} of data) batch.set(getFirestore().doc(`perfumes/${id}`), perfume);
  await batch.commit();
  console.log(`Seeded ${data.length} fragrances into ${projectId}`);
})().catch(error => { console.error(error.message); process.exitCode = 1; });
