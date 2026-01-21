class BanglaHeuristicFixer {
  static String improve(String text) {
    if (text.isEmpty) return text;

    text = _fixVeryCommonWords(text);
    text = _fixAdministrativeTerms(text);
    text = _fixRelations(text);
    text = _fixProfessions(text);
    text = _fixIslamicPrefixes(text);
    text = _fixLocations(text);
    text = _fixDatesAndForms(text);

    // Cleanup leftover isolated *
    text = text.replaceAll(RegExp(r'\s\*\s'), ' ');
    text = text.replaceAll(RegExp(r'\*+'), '*');

    return text;
  }

  // -------------------------------
  // 1️⃣ High frequency common words
  // -------------------------------
  static String _fixVeryCommonWords(String t) {
    final map = {
      'নিব*াচন': 'নির্বাচন',
      'ভোটার তালিকা': 'ভোটার তালিকা',
      'চূড়া*': 'চূড়ান্ত',
      'ন*র': 'নং',
      'সংখ*া': 'সংখ্যা',
      'কাড': 'কোড',
      'সটিি': 'সিটি',
      'কপে*োরশন': 'কর্পোরেশন',
      'ইউনিয়ন': 'ইউনিয়ন',
      'পৗরসভা': 'পৌরসভা',
      'ওয়াড*': 'ওয়ার্ড',
      'মাইে*ট হেয়ছে': 'মাইগ্রেট হয়েছে',
    };

    map.forEach((k, v) => t = t.replaceAll(k, v));
    return t;
  }

  // -------------------------------
  // 2️⃣ Admin & field labels
  // -------------------------------
  static String _fixAdministrativeTerms(String t) {
    final map = {
      'নাম:': 'নাম:',
      'ভোটার নং': 'ভোটার নং',
      'ভোটার এলাকার ন*র': 'ভোটার এলাকার নম্বর',
      'ভোটার এলাকার নাম': 'ভোটার এলাকার নাম',
      'জলো': 'জেলা',
      'উপজেলো': 'উপজেলা',
      'থানা': 'থানা',
      'ডাকঘর': 'ডাকঘর',
      'পা*কোড': 'পোস্টকোড',
      'ঠিকানা': 'ঠিকানা',
      'ঠকিানা': 'ঠিকানা',
    };

    map.forEach((k, v) => t = t.replaceAll(k, v));
    return t;
  }

  // -------------------------------
  // 3️⃣ Family relations
  // -------------------------------
  static String _fixRelations(String t) {
    final map = {
      'পতিা': 'পিতা',
      'মাতা': 'মাতা',
      'স্বামী': 'স্বামী',
    };

    map.forEach((k, v) => t = t.replaceAll(k, v));
    return t;
  }

  // -------------------------------
  // 4️⃣ Professions (very safe list)
  // -------------------------------
  static String _fixProfessions(String t) {
    final map = {
      'পশো': 'পেশা',
      'ছা*/ছা*ী': 'ছাত্র/ছাত্রী',
      '*মিক': 'শ্রমিক',
      '*বকার': 'ব্যবসায়ী',
      'শি*ক': 'শিক্ষক',
      'সরকারী চা*রী': 'সরকারি চাকরি',
      '*বসরকারী চা*রী': 'বেসরকারি চাকরি',
      'অ*া*': 'অবসরপ্রাপ্ত',
    };

    map.forEach((k, v) => t = t.replaceAll(k, v));
    return t;
  }

  // -------------------------------
  // 5️⃣ Islamic & Bangla prefixes
  // -------------------------------
  static String _fixIslamicPrefixes(String t) {
    final map = {
      '*মাঃ': 'মোঃ',
      'আঃ': 'আঃ',
      '*বগম': 'বেগম',
      '*নসা': 'নেছা',
      '*খাতুন': 'খাতুন',
    };

    map.forEach((k, v) => t = t.replaceAll(k, v));
    return t;
  }

  // -------------------------------
  // 6️⃣ Location-specific fixes
  // -------------------------------
  static String _fixLocations(String t) {
    final map = {
      'যা*াবাড়ী': 'যাত্রাবাড়ী',
      'উ*র': 'উত্তর',
      'দি*ণ': 'দক্ষিণ',
      'উঃ': 'উত্তর',
      'উওর': 'উত্তর',
    };

    map.forEach((k, v) => t = t.replaceAll(k, v));
    return t;
  }

  // -------------------------------
  // 7️⃣ Dates & form labels
  // -------------------------------
  static String _fixDatesAndForms(String t) {
    final map = {
      'তারখি': 'তারিখ',
      'জ* তারখি': 'জন্ম তারিখ',
      'ফরম-১': 'ফরম-১',
      'ছবি ছাড়া': 'ছবি ছাড়া',
    };

    map.forEach((k, v) => t = t.replaceAll(k, v));
    return t;
  }
}
