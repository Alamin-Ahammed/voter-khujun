class BanglaTextUtils {
  static final Map<String, List<RegExp>> patterns = {
    'name': [
      RegExp(r'নাম[:：]\s*(.*?)(?=\n|$)'),
      RegExp(r'নাম\s*[:：]\s*(.*?)(?=\n|$)'),
      RegExp(r'নাম\s*(.*?)(?=\n|$)'),
    ],
    'father': [
      RegExp(r'পিতা[:：]\s*(.*?)(?=\n|$)'),
      RegExp(r'পিতা\s*[:：]\s*(.*?)(?=\n|$)'),
      RegExp(r'পিতা\s*(.*?)(?=\n|$)'),
      RegExp(r'পিতার নাম[:：]\s*(.*?)(?=\n|$)'),
    ],
    'mother': [
      RegExp(r'মাতা[:：]\s*(.*?)(?=\n|$)'),
      RegExp(r'মাতা\s*[:：]\s*(.*?)(?=\n|$)'),
      RegExp(r'মাতা\s*(.*?)(?=\n|$)'),
      RegExp(r'মায়ের নাম[:：]\s*(.*?)(?=\n|$)'),
    ],
    'dob': [
      RegExp(r'জন্ম\s*তারিখ[:：]\s*(.*?)(?=\n|$)'),
      RegExp(r'জন্মতারিখ[:：]\s*(.*?)(?=\n|$)'),
      RegExp(r'জন্ম\s*তারিখ\s*(.*?)(?=\n|$)'),
      RegExp(r'জন্ম তারিখ[:：]\s*(.*?)(?=\n|$)'),
    ],
    'ward': [
      RegExp(r'ওয়ার্ড\s*নং[:：]\s*(.*?)(?=\n|$)'),
      RegExp(r'ওয়ার্ড[:：]\s*(.*?)(?=\n|$)'),
      RegExp(r'ওয়ার্ড\s*[:：]\s*(.*?)(?=\n|$)'),
      RegExp(r'ওয়ার্ড নং\s*(.*?)(?=\n|$)'),
    ],
    'address': [
      RegExp(r'ঠিকানা[:：]\s*(.*?)(?=\n|$)'),
      RegExp(r'ঠিকানা\s*[:：]\s*(.*?)(?=\n|$)'),
      RegExp(r'ঠিকানা\s*(.*?)(?=\n|$)'),
    ],
  };

  static String? extract(String text, String field) {
    final fieldPatterns = patterns[field];
    if (fieldPatterns == null) return null;
    
    for (final pattern in fieldPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        final extracted = match.group(1)!.trim();
        if (extracted.isNotEmpty) {
          return extracted;
        }
      }
    }
    
    return null;
  }

  static bool isBanglaText(String text) {
    // Check for Bangla Unicode range
    final banglaRegex = RegExp(r'[\u0980-\u09FF]');
    return banglaRegex.hasMatch(text);
  }

  static List<String> extractAllNames(String text) {
    final namePattern = RegExp(r'নাম[:：]\s*(.*?)(?=\n|$)');
    final matches = namePattern.allMatches(text);
    return matches.map((match) => match.group(1)?.trim() ?? '').toList();
  }
}