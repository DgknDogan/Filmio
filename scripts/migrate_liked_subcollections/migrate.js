'use strict';

// Usage: npm install, then
//   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json node migrate.js           (dry run)
//   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json node migrate.js --apply   (writes)
// Only adds documents; the liked_movies / liked_series arrays are never touched,
// and re-running is safe because every write is a set on a fixed id.

const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore, FieldPath } = require('firebase-admin/firestore');
const { planUser } = require('./plan');

const USER_COLLECTION = 'User';
const PAGE_SIZE = 300;

async function main() {
  const apply = process.argv.includes('--apply');
  const projectId = process.env.FIREBASE_PROJECT_ID || 'filmio-74b41';

  initializeApp(process.env.FIRESTORE_EMULATOR_HOST ? { projectId } : { credential: applicationDefault(), projectId });
  const db = getFirestore();
  const writer = apply ? db.bulkWriter() : null;

  let users = 0;
  let planned = 0;
  let skipped = 0;
  let last = null;

  for (;;) {
    let query = db.collection(USER_COLLECTION).orderBy(FieldPath.documentId()).limit(PAGE_SIZE);
    if (last) query = query.startAfter(last);
    const page = await query.get();
    if (page.empty) break;

    for (const userDoc of page.docs) {
      users++;
      const plan = planUser(userDoc.data());
      planned += plan.writes.length;
      skipped += plan.skipped.length;

      for (const s of plan.skipped) {
        console.warn(`skip ${userDoc.id} ${s.field}: entry without a valid id ${JSON.stringify(s.entry)}`);
      }
      for (const w of plan.writes) {
        const ref = userDoc.ref.collection(w.subcollection).doc(w.docId);
        if (writer) {
          writer.set(ref, w.data);
        } else {
          console.log(`would write ${ref.path} ${JSON.stringify(w.data)}`);
        }
      }
    }

    last = page.docs[page.docs.length - 1];
  }

  if (writer) await writer.close();

  console.log(`${apply ? 'Wrote' : 'Dry run: would write'} ${planned} documents for ${users} users (${skipped} entries skipped).`);
  if (!apply) console.log('Re-run with --apply to write.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
