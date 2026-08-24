/// Whether a piece of text somebody else wrote carries language the app
/// should not put in front of a reader unasked.
///
/// Reviews come from TMDB, which does not moderate them for us, and App Review
/// guideline 1.2 asks any app showing user-generated content for "a method for
/// filtering objectionable material". This is that method: it does not delete
/// anything, it marks a review so the card can fold it behind a warning and
/// let the reader open it deliberately.
///
/// Deliberately conservative. A false positive costs one extra tap; a false
/// negative puts a slur in front of somebody who did not ask for it. What it
/// does not try to be is clever — no server, no model, no list that has to be
/// downloaded. A word list catches the overwhelming majority of what actually
/// turns up in film reviews.
abstract final class ContentFilter {
  /// Characters people substitute to slip a word past a filter, and what they
  /// stand in for.
  static const _substitutions = {
    '0': 'o',
    '1': 'i',
    '3': 'e',
    '4': 'a',
    '5': 's',
    '7': 't',
    '@': 'a',
    '\$': 's',
    '!': 'i',
    // Kept as a regex wildcard rather than dropped: "sh*t" is a censored
    // letter, not a missing one, and dropping it would leave "sht".
    '*': '.',
  };

  /// Matched whole-word after normalisation, which is what keeps "Scunthorpe",
  /// "assassin" and "classic" out of the results.
  static const _words = {
    'anal',
    'arse',
    'arsehole',
    'ass',
    'asshole',
    'bastard',
    'bitch',
    'bitches',
    'blowjob',
    'bollocks',
    'boner',
    'bullshit',
    'clit',
    'cock',
    'cocksucker',
    'coon',
    'cum',
    'cunt',
    'dick',
    'dickhead',
    'dildo',
    'douchebag',
    'dyke',
    'fag',
    'faggot',
    'fuck',
    'fucked',
    'fucker',
    'fucking',
    'fucks',
    'gook',
    'handjob',
    'jerkoff',
    'jizz',
    'kike',
    'motherfucker',
    'nigga',
    'nigger',
    'paki',
    'pussy',
    'retard',
    'retarded',
    'shit',
    'shite',
    'shitty',
    'slut',
    'spic',
    'tits',
    'titties',
    'towelhead',
    'tranny',
    'twat',
    'wank',
    'wanker',
    'whore',
  };

  /// True when [text] contains one of the flagged words.
  static bool isObjectionable(String? text) {
    if (text == null || text.isEmpty) return false;

    return _tokenise(text).any(_matches);
  }

  /// A token is objectionable when it is a flagged word, or when it is one
  /// flagged letter short of being one — "sh.t" against "shit".
  ///
  /// At most one wildcard, so a row of asterisks cannot match every
  /// three-letter word on the list by accident.
  static bool _matches(String token) {
    if (_words.contains(token)) return true;

    final wildcards = '.'.allMatches(token).length;
    if (wildcards != 1) return false;

    final pattern = RegExp('^$token\$');

    return _words.any((word) => word.length == token.length && pattern.hasMatch(word));
  }

  /// Lower-cases, undoes the common character substitutions, collapses a run
  /// of three or more of the same letter to one — "fuuuuck" lands on "fuck" —
  /// and splits on anything that is not a letter or a wildcard.
  ///
  /// Three or more rather than two, because collapsing doubles would turn
  /// "ass" into "as" and flag every other sentence.
  static Iterable<String> _tokenise(String text) {
    final buffer = StringBuffer();

    for (final rune in text.toLowerCase().runes) {
      final character = String.fromCharCode(rune);
      buffer.write(_substitutions[character] ?? character);
    }

    return buffer.toString().replaceAllMapped(RegExp(r'(.)\1{2,}'), (match) => match[1]!).split(RegExp(r'[^a-z.]+')).where((token) => token.isNotEmpty);
  }
}
