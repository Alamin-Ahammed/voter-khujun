class BanglaTextFixer {
  /// Main entry point
  static String fix(String input) {
    if (input.isEmpty) return input;

    String text = input;

    // 1️⃣ Normalize Unicode
    text = text.replaceAll('\u00A0', ' '); // nbsp
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    // 2️⃣ Fix very common broken glyph patterns
    text = _fixCommonGlyphs(text);

    // 3️⃣ Fix vowel sign ordering (critical)
    text = _fixVowelOrder(text);

    // 4️⃣ Replace illegal characters with *
    // text = _replaceInvalidChars(text);

    // 5️⃣ Cleanup
    text = text.replaceAll(RegExp(r'\*+'), '*');
    text = text.replaceAll(RegExp(r'\s+'), ' ');

    return text.trim();
  }

  // -------------------------------
  // Common glyph corruption fixes
  // -------------------------------
  static String _fixCommonGlyphs(String text) {
    final Map<String, String> replacements = {
      'িা': 'াি',
      'ো': 'ো',
      'ৌ': 'ৌ',
      'াে': 'ো',
      'ৗে': 'ৌ',
      '়': '',

      // Very common PDF errors
      'তািরখ': 'তারিখ',
      'পশা': 'পেশা',
      'িঠকানা': 'ঠিকানা',
      'ভাটার': 'ভোটার',
      'নর': 'নং',
      'জলা': 'জেলা',
      'উপেজলা': 'উপজেলা',
      'ওয়াড': 'ওয়ার্ড',
      'িসিট': 'সিটি',
      'কেপােরশন': 'কর্পোরেশন',
      'ইউিনয়ন': 'ইউনিয়ন',
      'মাতা': 'মাতা',
      'িপতা': 'পিতা',
    };

    replacements.forEach((k, v) {
      text = text.replaceAll(k, v);
    });

    return text;
  }

  // ----------------------------------
  // Fix vowel sign order (Unicode rule)
  // ----------------------------------
  static String _fixVowelOrder(String text) {
    // vowel signs that must appear AFTER consonant
    const preVowels = ['ি', 'ে', 'ৈ'];

    for (final v in preVowels) {
      text = text.replaceAllMapped(
        RegExp('($v)([ক-হ])'),
        (m) => '${m[2]}${m[1]}',
      );
    }

    return text;
  }

  // ----------------------------------
  // Replace unknown chars with *
  // ----------------------------------
  static String _replaceInvalidChars(String text) {
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final ch = text[i];
      final code = ch.codeUnitAt(0);

      final isBangla = code >= 0x0980 && code <= 0x09FF;
      final isDigit = (code >= 48 && code <= 57);
      final isBanglaDigit = (code >= 0x09E6 && code <= 0x09EF);
      final isAllowedPunctuation =
          ' .,:;/()-\n'.contains(ch);

      if (isBangla || isDigit || isBanglaDigit || isAllowedPunctuation) {
        buffer.write(ch);
      } else {
        buffer.write('*');
      }
    }

    return buffer.toString();
  }
}
