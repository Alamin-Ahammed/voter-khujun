import 'package:characters/characters.dart';

class BanglaGlyphFixer {
  static const Set<String> preKars = {'ি', 'ে', 'ৈ'};

  static bool _isBanglaConsonant(String ch) {
    final code = ch.codeUnitAt(0);
    return code >= 0x0995 && code <= 0x09B9;
  }

  static String fix(String text) {
    final chars = text.characters.toList();
    final result = <String>[];

    for (int i = 0; i < chars.length; i++) {
      final ch = chars[i];

      if (preKars.contains(ch) &&
          result.isNotEmpty &&
          _isBanglaConsonant(result.last)) {
        final consonant = result.removeLast();
        result.add(ch);
        result.add(consonant);
      } else {
        result.add(ch);
      }
    }

    return result.join();
  }
}
