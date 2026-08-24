import 'package:filmio/core/utils/content_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isObjectionable', () {
    test('passes ordinary criticism, however harsh', () {
      expect(ContentFilter.isObjectionable('A dull, self-important mess of a film.'), isFalse);
      expect(ContentFilter.isObjectionable('The third act assassinates every character.'), isFalse);
      expect(ContentFilter.isObjectionable('Shot in Scunthorpe, and it shows.'), isFalse);
      expect(ContentFilter.isObjectionable('A classic. Analysis could not improve it.'), isFalse);
    });

    test('catches a flagged word whatever the case or punctuation around it', () {
      expect(ContentFilter.isObjectionable('what a shit film'), isTrue);
      expect(ContentFilter.isObjectionable('WHAT A SHIT FILM'), isTrue);
      expect(ContentFilter.isObjectionable('Utter shit, honestly.'), isTrue);
      expect(ContentFilter.isObjectionable('"shit"'), isTrue);
    });

    test('sees through the usual character substitutions', () {
      expect(ContentFilter.isObjectionable('what a sh1t film'), isTrue);
      expect(ContentFilter.isObjectionable('what a sh*t film'), isTrue);
      expect(ContentFilter.isObjectionable('what a b!tch'), isTrue);
      expect(ContentFilter.isObjectionable('@sshole of a director'), isTrue);
      expect(ContentFilter.isObjectionable('total bullsh!t'), isTrue);
    });

    test('sees through a stretched word', () {
      expect(ContentFilter.isObjectionable('fuuuuuck this movie'), isTrue);
      expect(ContentFilter.isObjectionable('shiiiiit'), isTrue);
    });

    test('a row of asterisks matches nothing on its own', () {
      expect(ContentFilter.isObjectionable('*** what a film ***'), isFalse);
      expect(ContentFilter.isObjectionable('****'), isFalse);
    });

    test('treats nothing as nothing', () {
      expect(ContentFilter.isObjectionable(null), isFalse);
      expect(ContentFilter.isObjectionable(''), isFalse);
      expect(ContentFilter.isObjectionable('   '), isFalse);
    });
  });
}
