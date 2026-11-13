
import {
  before,
  after,
  beforeEach,
  test
} from 'node:test';

import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';

import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds
} from '@firebase/rules-unit-testing';

import {
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  where,
  setDoc,
  updateDoc,
  deleteDoc,
  serverTimestamp,
  Timestamp
} from 'firebase/firestore';

let testEnv;

before(async () => {
  const rules = readFileSync(
    new URL('../firestore.rules', import.meta.url),
    'utf8'
  );

  testEnv = await initializeTestEnvironment({
    projectId: 'demo-notes',
    firestore: {
      host: '127.0.0.1',
      port: 8080,
      rules
    }
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

function getUserDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function getAnonymousDb() {
  return testEnv.unauthenticatedContext().firestore();
}

function validNote(ownerId) {
  return {
    title: 'Test note',
    content: 'Testing Firestore Security Rules',
    isFavourite: false,
    ownerId,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp()
  };
}

async function seedNote(noteId, ownerId) {
  await testEnv.withSecurityRulesDisabled(async context => {
    const db = context.firestore();

    await setDoc(doc(db, 'notes', noteId), {
      title: 'Existing note',
      content: 'Seeded test data',
      isFavourite: false,
      ownerId,
      createdAt: Timestamp.fromDate(
        new Date('2026-01-01T10:00:00Z')
      ),
      updatedAt: Timestamp.fromDate(
        new Date('2026-01-01T10:00:00Z')
      )
    });
  });
}

// 1. Unauthenticated users cannot read notes.

test('anonymous users cannot read notes', async () => {
  await seedNote('alice-note', 'alice');

  const db = getAnonymousDb();

  await assertFails(
    getDoc(doc(db, 'notes', 'alice-note'))
  );
});

// 2. Alice can create her own note.

test('user can create their own note', async () => {
  const db = getUserDb('alice');

  await assertSucceeds(
    setDoc(
      doc(db, 'notes', 'alice-new-note'),
      validNote('alice')
    )
  );
});

// 3. Alice cannot create a note belonging to Bob.

test('user cannot create notes for another user', async () => {
  const db = getUserDb('alice');

  await assertFails(
    setDoc(
      doc(db, 'notes', 'bob-note'),
      validNote('bob')
    )
  );
});

// 4. Invalid document structure is rejected.

test('invalid note documents are rejected', async () => {
  const db = getUserDb('alice');

  await assertFails(
    setDoc(doc(db, 'notes', 'invalid-note'), {
      content: 'Missing title and timestamps',
      ownerId: 'alice'
    })
  );
});

// 5. Alice can read her own note.

test('user can read their own note', async () => {
  await seedNote('alice-note', 'alice');

  const db = getUserDb('alice');

  await assertSucceeds(
    getDoc(doc(db, 'notes', 'alice-note'))
  );
});

// 6. Alice cannot read Bob's note.

test('user cannot read another user note', async () => {
  await seedNote('bob-note', 'bob');

  const db = getUserDb('alice');

  await assertFails(
    getDoc(doc(db, 'notes', 'bob-note'))
  );
});

// 7. Queries must constrain ownerId.

test('user can query only their own notes', async () => {
  await seedNote('alice-note', 'alice');
  await seedNote('bob-note', 'bob');

  const db = getUserDb('alice');

  const ownNotesQuery = query(
    collection(db, 'notes'),
    where('ownerId', '==', 'alice')
  );

  const result = await assertSucceeds(
    getDocs(ownNotesQuery)
  );

  assert.equal(result.size, 1);
  assert.equal(result.docs[0].id, 'alice-note');
});

// 8. Unfiltered queries must fail.

test('unfiltered note queries are rejected', async () => {
  await seedNote('alice-note', 'alice');
  await seedNote('bob-note', 'bob');

  const db = getUserDb('alice');

  await assertFails(
    getDocs(collection(db, 'notes'))
  );
});

// 9. Alice can update her own note.

test('user can update their own note', async () => {
  await seedNote('alice-note', 'alice');

  const db = getUserDb('alice');

  await assertSucceeds(
    updateDoc(doc(db, 'notes', 'alice-note'), {
      title: 'Updated title',
      updatedAt: serverTimestamp()
    })
  );
});

// 10. Alice cannot change ownership.

test('user cannot change note ownership', async () => {
  await seedNote('alice-note', 'alice');

  const db = getUserDb('alice');

  await assertFails(
    updateDoc(doc(db, 'notes', 'alice-note'), {
      ownerId: 'bob',
      updatedAt: serverTimestamp()
    })
  );
});

// 11. Alice cannot change creation timestamp.

test('user cannot change createdAt', async () => {
  await seedNote('alice-note', 'alice');

  const db = getUserDb('alice');

  await assertFails(
    updateDoc(doc(db, 'notes', 'alice-note'), {
      createdAt: Timestamp.fromDate(
        new Date('2020-01-01T00:00:00Z')
      ),
      updatedAt: serverTimestamp()
    })
  );
});

// 12. Alice can delete her own note.

test('user can delete their own note', async () => {
  await seedNote('alice-note', 'alice');

  const db = getUserDb('alice');

  await assertSucceeds(
    deleteDoc(doc(db, 'notes', 'alice-note'))
  );
});

// 13. Alice cannot delete Bob's note.
test('user cannot delete another user note', async () => {
  await seedNote('bob-note', 'bob');

  const db = getUserDb('alice');

  await assertFails(
    deleteDoc(doc(db, 'notes', 'bob-note'))
  );
});

// 14. Alice cannot update Bob's note.

test('user cannot update another user note', async () => {
  await seedNote('bob-note', 'bob');

  const db = getUserDb('alice');

  await assertFails(
    updateDoc(doc(db, 'notes', 'bob-note'), {
      title: 'Unauthorized modification',
      updatedAt: serverTimestamp()
    })
  );
});

// 15 . Alice can update her own note favourite status.
test('user can update their own note favourite status', async () => {
  await seedNote('alice-note', 'alice');

  const db = getUserDb('alice');

  await assertSucceeds(
    updateDoc(doc(db, 'notes', 'alice-note'), {
      isFavourite: true,
      updatedAt: serverTimestamp()
    })
  );

  const result = await getDoc(
    doc(db, 'notes', 'alice-note')
  );

  assert.equal(result.data().isFavourite, true);
});

// 16 . Invalid favourite values are rejected.
test('invalid favourite values are rejected', async () => {
  const db = getUserDb('alice');

  await assertFails(
    setDoc(doc(db, 'notes', 'invalid-favourite'), {
      ...validNote('alice'),
      isFavourite: 'true'
    })
  );
});