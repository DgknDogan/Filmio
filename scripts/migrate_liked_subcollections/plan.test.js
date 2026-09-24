'use strict';

const test = require('node:test');
const assert = require('node:assert');
const { planUser } = require('./plan');

test('each liked title becomes {id} under its subcollection, keyed by the id', () => {
  const { writes } = planUser({
    liked_movies: [{ id: 550, title: 'Fight Club', poster_path: '/a.jpg' }],
    liked_series: [{ id: 1399, name: 'Game of Thrones' }],
  });

  assert.deepStrictEqual(writes, [
    { subcollection: 'LikedMovies', docId: '550', data: { id: 550 } },
    { subcollection: 'LikedSeries', docId: '1399', data: { id: 1399 } },
  ]);
});

test('a user with no liked fields plans nothing', () => {
  assert.deepStrictEqual(planUser({}), { writes: [], skipped: [] });
  assert.deepStrictEqual(planUser(undefined), { writes: [], skipped: [] });
});

test('the same title stored twice in the array is written once', () => {
  const { writes } = planUser({ liked_movies: [{ id: 1, title: 'A' }, { id: 1, title: 'A (renamed)' }] });

  assert.strictEqual(writes.length, 1);
});

test('an entry without a usable id is reported, not written', () => {
  const { writes, skipped } = planUser({ liked_movies: [{ title: 'no id' }, { id: '7' }, null, { id: 2 }] });

  assert.deepStrictEqual(writes, [{ subcollection: 'LikedMovies', docId: '2', data: { id: 2 } }]);
  assert.strictEqual(skipped.length, 3);
});

test('a movie and a series sharing an id land in their own subcollections', () => {
  const { writes } = planUser({ liked_movies: [{ id: 5 }], liked_series: [{ id: 5 }] });

  assert.deepStrictEqual(
    writes.map((w) => w.subcollection),
    ['LikedMovies', 'LikedSeries'],
  );
});
