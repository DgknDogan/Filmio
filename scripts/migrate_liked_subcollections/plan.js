'use strict';

const FIELDS = [
  { field: 'liked_movies', subcollection: 'LikedMovies' },
  { field: 'liked_series', subcollection: 'LikedSeries' },
];

// Mirrors how the app writes: document id is the TMDB id as a string, the
// document body holds the same id as a number.
function planUser(data) {
  const writes = [];
  const skipped = [];

  for (const { field, subcollection } of FIELDS) {
    const entries = Array.isArray(data?.[field]) ? data[field] : [];
    const seen = new Set();

    for (const entry of entries) {
      const id = entry?.id;
      if (!Number.isInteger(id) || id <= 0) {
        skipped.push({ field, entry });
        continue;
      }
      if (seen.has(id)) continue;
      seen.add(id);
      writes.push({ subcollection, docId: String(id), data: { id } });
    }
  }

  return { writes, skipped };
}

module.exports = { planUser, FIELDS };
