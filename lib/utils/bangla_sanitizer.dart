class BanglaSanitizer {
  static final RegExp _allowed = RegExp(
    r'[\u0980-\u09FF০-৯ \n:/\-]',
  );

  static String sanitize(String input) {
    final buffer = StringBuffer();

    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      if (_allowed.hasMatch(char)) {
        buffer.write(char);
      } else {
        buffer.write('*');
      }
    }

    return buffer.toString();
  }
}
