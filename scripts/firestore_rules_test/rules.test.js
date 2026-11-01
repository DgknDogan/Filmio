// What `firebase/firestore.rules` actually admits, read back from the
// emulator rather than from the file.
//
// Run with `npm test` in this directory: that starts the Firestore emulator,
// runs these, and shuts it down. Nothing here touches a real project — the
// project id is `demo-filmio`, and the `demo-` prefix is what tells the
// Firebase tooling there is no cloud project behind it.

const { readFileSync } = require('node:fs');
const { join } = require('node:path');
const { after, before, beforeEach, describe, it } = require('node:test');

const { initializeTestEnvironment, assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');
const { doc, getDoc, getDocs, setDoc, deleteDoc, collection, addDoc, serverTimestamp } = require('firebase/firestore');

const OWNER = 'owner-uid';
const STRANGER = 'stranger-uid';

/** A report exactly as `ReviewModerationRepositoryImpl` files it. */
function report(overrides = {}) {
  return {
    review_id: 'tmdb-review-1',
    author: 'someone',
    media_id: 550,
    media_type: 'movie',
    reason: 'spam',
    excerpt: 'a copy of what was on screen',
    reported_by: OWNER,
    created_at: serverTimestamp(),
    ...overrides,
  };
}

let testEnv;

before(async () => {
  const host = process.env.FIRESTORE_EMULATOR_HOST ?? '127.0.0.1:8080';
  const [hostname, port] = host.split(':');

  testEnv = await initializeTestEnvironment({
    projectId: 'demo-filmio',
    firestore: {
      rules: readFileSync(join(__dirname, '..', '..', 'firebase', 'firestore.rules'), 'utf8'),
      host: hostname,
      port: Number(port),
    },
  });
});

after(async () => {
  await testEnv?.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

describe('User/{uid}', () => {
  it('is readable by its owner', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    await assertSucceeds(getDoc(doc(db, 'User', OWNER)));
  });

  it('is not readable by anybody else', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(getDoc(doc(db, 'User', OWNER)));
  });

  it('is not readable without an account', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'User', OWNER)));
  });

  it('cannot be enumerated, even by somebody with an account', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    await assertFails(getDocs(collection(db, 'User')));
  });

  it('accepts the document `register` writes', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    await assertSucceeds(setDoc(doc(db, 'User', OWNER), { liked_movies: [] }));
  });

  it('accepts both arrays of titles', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    const movie = { id: 550, title: 'Fight Club', poster_path: '/a.jpg' };

    await assertSucceeds(setDoc(doc(db, 'User', OWNER), { liked_movies: [movie], liked_series: [] }));
  });

  it('refuses a liked list that is not a list', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    await assertFails(setDoc(doc(db, 'User', OWNER), { liked_movies: 'all of them' }));
  });

  it('refuses a liked list long enough to threaten the document limit', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    const tooMany = Array.from({ length: 2001 }, (_, index) => ({ id: index }));

    await assertFails(setDoc(doc(db, 'User', OWNER), { liked_movies: tooMany }));
  });

  it('cannot be written by anybody else', async () => {
    const db = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(setDoc(doc(db, 'User', OWNER), { liked_movies: [] }));
  });

  it('can be deleted by its owner and nobody else', async () => {
    const stranger = testEnv.authenticatedContext(STRANGER).firestore();
    await assertFails(deleteDoc(doc(stranger, 'User', OWNER)));

    const owner = testEnv.authenticatedContext(OWNER).firestore();
    await assertSucceeds(deleteDoc(doc(owner, 'User', OWNER)));
  });
});

for (const subcollection of ['LikedMovies', 'LikedSeries']) {
  describe(`User/{uid}/${subcollection}`, () => {
    it('accepts the id, under the id', async () => {
      const db = testEnv.authenticatedContext(OWNER).firestore();
      await assertSucceeds(setDoc(doc(db, 'User', OWNER, subcollection, '550'), { id: 550 }));
    });

    it('refuses an id that disagrees with the document name', async () => {
      const db = testEnv.authenticatedContext(OWNER).firestore();
      await assertFails(setDoc(doc(db, 'User', OWNER, subcollection, '550'), { id: 551 }));
    });

    it('refuses anything beyond the id', async () => {
      const db = testEnv.authenticatedContext(OWNER).firestore();
      await assertFails(setDoc(doc(db, 'User', OWNER, subcollection, '550'), { id: 550, title: 'Fight Club' }));
    });

    it('refuses an id that is not a number', async () => {
      const db = testEnv.authenticatedContext(OWNER).firestore();
      await assertFails(setDoc(doc(db, 'User', OWNER, subcollection, '550'), { id: '550' }));
    });

    it('is closed to everybody but the owner', async () => {
      const db = testEnv.authenticatedContext(STRANGER).firestore();

      await assertFails(getDoc(doc(db, 'User', OWNER, subcollection, '550')));
      await assertFails(setDoc(doc(db, 'User', OWNER, subcollection, '550'), { id: 550 }));
      await assertFails(deleteDoc(doc(db, 'User', OWNER, subcollection, '550')));
    });

    it('lets the owner take a like back', async () => {
      const db = testEnv.authenticatedContext(OWNER).firestore();
      await assertSucceeds(deleteDoc(doc(db, 'User', OWNER, subcollection, '550')));
    });
  });
}

describe('ReviewReport', () => {
  it('accepts a report from an account', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    await assertSucceeds(addDoc(collection(db, 'ReviewReport'), report()));
  });

  it('accepts a report from a guest, who has no uid', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertSucceeds(addDoc(collection(db, 'ReviewReport'), report({ reported_by: null })));
  });

  it('refuses a report filed in somebody else\'s name', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    await assertFails(addDoc(collection(db, 'ReviewReport'), report({ reported_by: STRANGER })));
  });

  it('refuses a timestamp the client chose', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    await assertFails(addDoc(collection(db, 'ReviewReport'), report({ created_at: new Date(0) })));
  });

  it('refuses a reason that is not one of the five', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    await assertFails(addDoc(collection(db, 'ReviewReport'), report({ reason: 'i just do not like it' })));
  });

  it('refuses a media type that is neither catalogue', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    await assertFails(addDoc(collection(db, 'ReviewReport'), report({ media_type: 'book' })));
  });

  it('refuses an excerpt past the 500 the app truncates to', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    await assertFails(addDoc(collection(db, 'ReviewReport'), report({ excerpt: 'x'.repeat(501) })));
  });

  it('refuses a field the app does not write', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    await assertFails(addDoc(collection(db, 'ReviewReport'), report({ resolved: true })));
  });

  it('refuses a report with a field missing', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();
    const { excerpt, ...withoutExcerpt } = report();

    await assertFails(addDoc(collection(db, 'ReviewReport'), withoutExcerpt));
  });

  it('cannot be read back by the app', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();

    await assertFails(getDocs(collection(db, 'ReviewReport')));
    await assertFails(getDoc(doc(db, 'ReviewReport', 'any-report')));
  });
});

describe('a collection nobody has written rules for', () => {
  it('is closed', async () => {
    const db = testEnv.authenticatedContext(OWNER).firestore();

    await assertFails(getDoc(doc(db, 'Whatever', 'some-id')));
    await assertFails(setDoc(doc(db, 'Whatever', 'some-id'), { anything: true }));
  });
});
