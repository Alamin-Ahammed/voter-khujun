class BanglaCharReplacer {
  /// Comprehensive invalid character replacement for Bangla OCR text
  static String replaceInvalidChars(String text) {
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      final ch = text[i];
      final nextCh = i + 1 < text.length ? text[i + 1] : '';
      final prevCh = i > 0 ? text[i - 1] : '';
      
      // Check if character is valid Bangla, digit, or allowed punctuation
      final isValid = _isValidBanglaChar(ch) || 
                      _isDigit(ch) || 
                      _isBanglaDigit(ch) || 
                      _isAllowedPunctuation(ch);
      
      if (isValid) {
        buffer.write(ch);
      } else {
        // Try to replace with most likely Bangla character based on context
        final replacement = _getLikelyReplacement(ch, prevCh, nextCh);
        buffer.write(replacement);
      }
    }
    
    return buffer.toString();
  }
  
  static bool _isValidBanglaChar(String ch) {
    if (ch.isEmpty) return false;
    final code = ch.codeUnitAt(0);
    return code >= 0x0980 && code <= 0x09FF;
  }
  
  static bool _isDigit(String ch) {
    if (ch.isEmpty) return false;
    final code = ch.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }
  
  static bool _isBanglaDigit(String ch) {
    if (ch.isEmpty) return false;
    final code = ch.codeUnitAt(0);
    return code >= 0x09E6 && code <= 0x09EF;
  }
  
  static bool _isAllowedPunctuation(String ch) {
    return ' .,:;/()-—–\n\t\r'.contains(ch);
  }
  
  /// Get the most likely Bangla replacement for an invalid character
  /// Based on context analysis of your specific PDF
  static String _getLikelyReplacement(String ch, String prev, String next) {
    if (ch.isEmpty) return '';
    
    // Comprehensive mapping based on your sample text
    final Map<String, String> directMappings = {
      // Common OCR errors in your PDF
      'Ĕ': 'ত্র',    // যাত্রাবাড়ী -> যাত্রাবাড়ী
      'Ê': '্র',     // করশ -> করশ
      'Î': '্র',     // নিবÎাচন -> নির্বাচন
      'Ï': '',       // Often just noise before words
      'ē': 'ৎ',      // উēর -> উত্তর
      'ſ': 'র',      // অſ -> আর
      '×': 'খ',      // আ×ার -> আখতার
      'Ĩ': 'যা',     // ſƁĨাহার -> সখিনা
      'ĥ': 'ন্ম',     // জĥ -> জন্ম
      'å': 'ে',      // মাইেåট -> মাইএট
      'Ň': 'দ',      // ÏমাহাŇদ -> মাহাদ
      'Ō': 'ক',      // উŌাহ -> উকাহ
      'Ŏ': 'খ',      // Alternative for খ
      'ŏ': 'গ',      // For গ sound
      'ő': 'ঘ',      // For ঘ sound
      'Œ': 'ঙ',      // For ঙ sound
      'œ': 'চ',      // For চ sound
      'Ŕ': 'ছ',      // For ছ sound
      'ŕ': 'জ',      // For জ sound
      'Ŗ': 'ঝ',      // For ঝ sound
      'ŗ': 'ঞ',      // For ঞ sound
      'Ř': 'শি',     // Řমিক -> শিক্ষক
      'ř': 'ট',      // For ট sound
      'Ś': 'ঠ',      // For ঠ sound
      'ś': 'ড',      // For ড sound
      'Ŝ': 'ঢ',      // For ঢ sound
      'ŝ': 'ণ',      // For ণ sound
      'Ş': 'ত',      // For ত sound
      'ş': 'থ',      // For থ sound
      'Š': 'দ',      // For দ sound
      'š': 'ধ',      // For ধ sound
      'Ţ': 'ন',      // For ন sound
      'ţ': 'প',      // For প sound
      'Ť': 'ফ',      // For ফ sound
      'ť': 'ব',      // For ব sound
      'Ŧ': 'ভ',      // For ভ sound
      'ŧ': 'ম',      // For ম sound
      'Ũ': 'য',      // For য sound
      'ũ': 'র',      // For র sound
      'Ū': 'ল',      // For ল sound
      'ū': 'শ',      // For শ sound
      'Ŭ': 'ষ',      // For ষ sound
      'ŭ': 'স',      // For স sound
      'Ů': 'হ',      // For হ sound
      'ů': 'ড়',      // For ড় sound
      'Ű': 'ঢ়',     // For ঢ় sound
      'ű': 'য়',      // For য় sound
      'Ų': 'ৎ',      // For ৎ sound
      'ų': 'ং',      // For ং sound
      'Ŵ': 'ঃ',      // For ঃ sound
      'ŵ': 'ঁ',      // For ঁ sound
      'Ŷ': '্র',     // For ্র sound
      'ŷ': '্র',     // For ্র sound
      'Ÿ': '্র',     // For ্র sound
      'ƀ': 'ব',      // ƀলতানা -> লতিফা
      'Ɓ': 'স',      // Ɓমা -> সিমি
      'Ƃ': 'খ',      // Alternative খ
      'ƃ': 'গ',      // Alternative গ
      'Ƅ': 'য',      // ƄÑুর -> নুর
      'ƅ': 'জ',      // Alternative জ
      'Ɔ': 'হ',      // Ɔমাযুন -> মায়ুন
      'Ƈ': 'চ',      // Alternative চ
      'ƈ': 'ছ',      // Alternative ছ
      'Ɖ': 'জ',      // Alternative জ
      'Ɗ': 'ঝ',      // Alternative ঝ
      'Ƌ': 'ঞ',      // Alternative ঞ
      'ƌ': 'ট',      // Alternative ট
      'ƍ': 'ঠ',      // Alternative ঠ
      'Ǝ': 'ড',      // Alternative ড
      'Ə': 'ঢ',      // Alternative ঢ
      'Ɛ': 'ণ',      // Alternative ণ
      'Ƒ': 'ত',      // Alternative ত
      'ƒ': 'থ',      // Alternative থ
      'Ɠ': 'দ',      // Alternative দ
      'Ɣ': 'ধ',      // Alternative ধ
      'ƕ': 'ন',      // Alternative ন
      'Ɩ': 'প',      // Alternative প
      'Ɨ': 'ফ',      // Alternative ফ
      'Ƙ': 'ব',      // Alternative ব
      'ƙ': 'ভ',      // Alternative ভ
      'ƚ': 'ম',      // Alternative ম
      'ƛ': 'য',      // Alternative য
      'Ɯ': 'র',      // Alternative র
      'Ɲ': 'ল',      // Alternative ল
      'ƞ': 'শ',      // Alternative শ
      'Ɵ': 'ষ',      // Alternative ষ
      'Ơ': 'স',      // Alternative স
      'ơ': 'হ',      // Alternative হ
      'Ƣ': 'ড়',      // Alternative ড়
      'ƣ': 'ঢ়',     // Alternative ঢ়
      'Ƥ': 'য়',      // Alternative য়
      'ƥ': 'ৎ',      // Alternative ৎ
      'Ʀ': 'ং',      // Alternative ং
      'Ƨ': 'ঃ',      // Alternative ঃ
      'ƨ': 'ঁ',      // Alternative ঁ
      'Ʃ': '্র',     // Alternative ্র
      'ƪ': '্র',     // Alternative ্র
      'ƫ': '্র',     // Alternative ্র
      'Ƭ': '্র',     // Alternative ্র
      'ƭ': '্র',     // Alternative ্র
      'Ʈ': '্র',     // Alternative ্র
      'Ư': '্র',     // Alternative ্র
      'ư': '্র',     // Alternative ্র
      'Ʊ': '্র',     // Alternative ্র
      'Ʋ': '্র',     // Alternative ্র
      'Ƴ': '্র',     // Alternative ্র
      'ƴ': '্র',     // Alternative ্র
      'Ƶ': '্র',     // Alternative ্র
      'ƶ': '্র',     // Alternative ্র
      'Ʒ': '্র',     // Alternative ্র
      'Ƹ': '্র',     // Alternative ্র
      'ƹ': '্র',     // Alternative ্র
      'ƺ': '্র',     // Alternative ্র
      'ƻ': '্র',     // Alternative ্র
      'Ƽ': '্র',     // Alternative ্র
      'ƽ': '্র',     // Alternative ্র
      'ƾ': '্র',     // Alternative ্র
      'ƿ': '্র',     // Alternative ্র
      'ǀ': '্র',     // Alternative ্র
      'ǁ': '্র',     // Alternative ্র
      'ǂ': '্র',     // Alternative ্র
      'ǃ': '্র',     // Alternative ্র
      'Ð': 'স',      // Ðছযাল -> সৈয়াল
      'Ñ': 'শ',      // Alternative শ
      'Ò': 'ষ',      // Alternative ষ
      'Ó': 'স',      // Alternative স
      'Ô': 'হ',      // Alternative হ
      'Õ': 'ড়',      // Alternative ড়
      'Ö': 'ঢ়',     // Alternative ঢ়
      'Ø': 'য়',      // Alternative য়
      'Ù': 'ৎ',      // Alternative ৎ
      'Ú': 'ং',      // Alternative ং
      'Û': 'ঃ',      // Alternative ঃ
      'Ü': 'ঁ',      // Alternative ঁ
      'Ý': '্র',     // Alternative ্র
      'Þ': '্র',     // Alternative ্র
      'ß': '্র',     // Alternative ্র
      'à': '্র',     // Alternative ্র
      'á': '্র',     // Alternative ্র
      'â': '্র',     // Alternative ্র
      'ã': '্র',     // Alternative ্র
      'ä': '্র',     // Alternative ্র
      'å': '্র',     // Alternative ্র
      'æ': '্র',     // Alternative ্র
      'ç': '্র',     // Alternative ্র
      'è': '্র',     // Alternative ্র
      'é': '্র',     // Alternative ্র
      'ê': '্র',     // Alternative ্র
      'ë': '্র',     // Alternative ্র
      'ì': '্র',     // Alternative ্র
      'í': '্র',     // Alternative ্র
      'î': '্র',     // Alternative ্র
      'ï': '্র',     // Alternative ্র
      'ð': '্র',     // Alternative ্র
      'ñ': '্র',     // Alternative ্র
      'ò': '্র',     // Alternative ্র
      'ó': '্র',     // Alternative ্র
      'ô': '্র',     // Alternative ্র
      'õ': 'জ',      // রাõাক -> রাজাক
      'ö': '্র',     // Alternative ্র
      '÷': '্র',     // Alternative ্র
      'ø': '্র',     // Alternative ্র
      'ù': '্র',     // Alternative ্র
      'ú': '্র',     // Alternative ্র
      'û': '্র',     // Alternative ্র
      'ü': '্র',     // Alternative ্র
      'ý': '্র',     // Alternative ্র
      'þ': '্র',     // Alternative ্র
      'ÿ': '্র',     // Alternative ্র
      'Ā': 'আ',      // For আ sound
      'ā': 'া',      // For া sign
      'Ă': 'ই',      // For ই sound
      'ă': 'ি',      // For ি sign
      'Ą': 'ঈ',      // For ঈ sound
      'ą': 'ী',      // For ী sign
      'Ć': 'উ',      // For উ sound
      'ć': 'ু',      // For ু sign
      'Ĉ': 'ঊ',      // For ঊ sound
      'ĉ': 'ূ',      // For ূ sign
      'Ċ': 'ঋ',      // For ঋ sound
      'ċ': 'ৃ',      // For ৃ sign
      'Č': 'এ',      // For এ sound
      'č': 'ে',      // For ে sign
      'Ď': 'ঐ',      // For ঐ sound
      'ď': 'ৈ',      // For ৈ sign
      'Đ': 'ও',      // For ও sound
      'đ': 'ো',      // For ো sign
      'Ē': 'ঔ',      // For ঔ sound
      'ē': 'ৌ',      // For ৌ sign
      'Ė': 'ং',      // For ং sign
      'ė': 'ঃ',      // For ঃ sign
      'Ę': 'ঁ',      // For ঁ sign
      'ę': '্',      // For ্ sign
      'Ě': '্র',     // For ্র sign
      'ě': '্র',     // For ্র sign
      'Ĝ': '্র',     // For ্র sign
      'ĝ': '্র',     // For ্র sign
      'Ğ': '্র',     // For ্র sign
      'ğ': '্র',     // For ্র sign
      'Ġ': '্র',     // For ্র sign
      'ġ': '্র',     // For ্র sign
      'Ģ': '্র',     // For ্র sign
      'ģ': '্র',     // For ্র sign
      'Ĥ': '্র',     // For ্র sign
      'ĥ': '্র',     // For ্র sign
      'Ħ': '্র',     // For ্র sign
      'ħ': '্র',     // For ্র sign
      'Ĩ': '্র',     // For ্র sign
      'ĩ': '্র',     // For ্র sign
      'Ī': '্র',     // For ্র sign
      'ī': '্র',     // For ্র sign
      'Į': '্র',     // For ্র sign
      'į': '্র',     // For ্র sign
      'İ': '্র',     // For ্র sign
      'ı': '্র',     // For ্র sign
      'Ĳ': '্র',     // For ্র sign
      'ĳ': '্র',     // For ্র sign
      'Ĵ': '্র',     // For ্র sign
      'ĵ': '্র',     // For ্র sign
      'Ķ': '্র',     // For ্র sign
      'ķ': '্র',     // For ্র sign
      'ĸ': '্র',     // For ্র sign
      'Ĺ': '্র',     // For ্র sign
      'ĺ': '্র',     // For ্র sign
      'Ļ': '্র',     // For ্র sign
      'ļ': '্র',     // For ্র sign
      'Ľ': '্র',     // For ্র sign
      'ľ': '্র',     // For ্র sign
      'Ŀ': '্র',     // For ্র sign
      'ŀ': '্র',     // For ্র sign
      'Ł': '্র',     // For ্র sign
      'ł': '্র',     // For ্র sign
      'Ń': '্র',     // For ্র sign
      'ń': '্র',     // For ্র sign
      'Ņ': '্র',     // For ্র sign
      'ņ': '্র',     // For ্র sign
      'Ň': '্র',     // For ্র sign
      'ň': '্র',     // For ্র sign
      'ŉ': '্র',     // For ্র sign
      'Ŋ': '্র',     // For ্র sign
      'ŋ': '্র',     // For ্র sign
      'Ō': '্র',     // For ্র sign
      'ō': '্র',     // For ্র sign
      'Ŏ': '্র',     // For ্র sign
      'ŏ': '্র',     // For ্র sign
      'Ő': '্র',     // For ্র sign
      'ő': '্র',     // For ্র sign
      'Œ': '্র',     // For ্র sign
      'œ': '্র',     // For ্র sign
      'Ŕ': '্র',     // For ্র sign
      'ŕ': '্র',     // For ্র sign
      'Ŗ': '্র',     // For ্র sign
      'ŗ': '্র',     // For ্র sign
      'Ř': '্র',     // For ্র sign
      'ř': '্র',     // For ্র sign
      'Ś': '্র',     // For ্র sign
      'ś': '্র',     // For ্র sign
      'Ŝ': '্র',     // For ্র sign
      'ŝ': '্র',     // For ্র sign
      'Ş': '্র',     // For ্র sign
      'ş': '্র',     // For ্র sign
      'Š': '্র',     // For ্র sign
      'š': '্র',     // For ্র sign
      'Ţ': '্র',     // For ্র sign
      'ţ': '্র',     // For ্র sign
      'Ť': '্র',     // For ্র sign
      'ť': '্র',     // For ্র sign
      'Ŧ': '্র',     // For ্র sign
      'ŧ': '্র',     // For ্র sign
      'Ũ': '্র',     // For ্র sign
      'ũ': '্র',     // For ্র sign
      'Ū': '্র',     // For ্র sign
      'ū': '্র',     // For ্র sign
      'Ŭ': '্র',     // For ্র sign
      'ŭ': '্র',     // For ্র sign
      'Ů': '্র',     // For ্র sign
      'ů': '্র',     // For ্র sign
      'Ű': '্র',     // For ্র sign
      'ű': '্র',     // For ্র sign
      'Ų': '্র',     // For ্র sign
      'ų': '্র',     // For ্র sign
      'Ŵ': '্র',     // For ্র sign
      'ŵ': '্র',     // For ্র sign
      'Ŷ': '্র',     // For ্র sign
      'ŷ': '্র',     // For ্র sign
      'Ÿ': '্র',     // For ্র sign
      'Ź': '্র',     // For ্র sign
      'ź': '্র',     // For ্র sign
      'Ż': '্র',     // For ্র sign
      'ż': '্র',     // For ্র sign
      'Ž': '্র',     // For ্র sign
      'ž': '্র',     // For ্র sign
      'ſ': 'র',      // Alternative র
      'ƀ': 'ব',      // Alternative ব
      'Ɓ': 'স',      // Alternative স
      'Ƃ': 'খ',      // Alternative খ
      'ƃ': 'গ',      // Alternative গ
      'Ƅ': 'য',      // Alternative য
      'ƅ': 'জ',      // Alternative জ
      'Ɔ': 'ম',      // Alternative ম
      'Ƈ': 'চ',      // Alternative চ
      'ƈ': 'ছ',      // Alternative ছ
      'Ɖ': 'জ',      // Alternative জ
      'Ɗ': 'ঝ',      // Alternative ঝ
      'Ƌ': 'ঞ',      // Alternative ঞ
      'ƌ': 'ট',      // Alternative ট
      'ƍ': 'ঠ',      // Alternative ঠ
      'Ǝ': 'ড',      // Alternative ড
      'Ə': 'ঢ',      // Alternative ঢ
      'Ɛ': 'ণ',      // Alternative ণ
      'Ƒ': 'ত',      // Alternative ত
      'ƒ': 'থ',      // Alternative থ
      'Ɠ': 'দ',      // Alternative দ
      'Ɣ': 'ধ',      // Alternative ধ
      'ƕ': 'ন',      // Alternative ন
      'Ɩ': 'প',      // Alternative প
      'Ɨ': 'ফ',      // Alternative ফ
      'Ƙ': 'ব',      // Alternative ব
      'ƙ': 'ভ',      // Alternative ভ
      'ƚ': 'ম',      // Alternative ম
      'ƛ': 'য',      // Alternative য
      'Ɯ': 'র',      // Alternative র
      'Ɲ': 'ল',      // Alternative ল
      'ƞ': 'শ',      // Alternative শ
      'Ɵ': 'ষ',      // Alternative ষ
      'Ơ': 'স',      // Alternative স
      'ơ': 'হ',      // Alternative হ
      'Ƣ': 'ড়',      // Alternative ড়
      'ƣ': 'ঢ়',     // Alternative ঢ়
      'Ƥ': 'য়',      // Alternative য়
      'ƥ': 'ৎ',      // Alternative ৎ
      'Ʀ': 'ং',      // Alternative ং
      'Ƨ': 'ঃ',      // Alternative ঃ
      'ƨ': 'ঁ',      // Alternative ঁ
      'Ʃ': '্র',     // Alternative ্র
      'ƪ': '্র',     // Alternative ্র
      'ƫ': '্র',     // Alternative ্র
      'Ƭ': '্র',     // Alternative ্র
      'ƭ': '্র',     // Alternative ্র
      'Ʈ': '্র',     // Alternative ্র
      'Ư': '্র',     // Alternative ্র
      'ư': '্র',     // Alternative ্র
      'Ʊ': '্র',     // Alternative ্র
      'Ʋ': '্র',     // Alternative ্র
      'Ƴ': '্র',     // Alternative ্র
      'ƴ': '্র',     // Alternative ্র
      'Ƶ': '্র',     // Alternative ্র
      'ƶ': '্র',     // Alternative ্র
      'Ʒ': '্র',     // Alternative ্র
      'Ƹ': '্র',     // Alternative ্র
      'ƹ': '্র',     // Alternative ্র
      'ƺ': '্র',     // Alternative ্র
      'ƻ': '্র',     // Alternative ্র
      'Ƽ': '্র',     // Alternative ্র
      'ƽ': '্র',     // Alternative ্র
      'ƾ': '্র',     // Alternative ্র
      'ƿ': '্র',     // Alternative ্র
      'ǀ': '্র',     // Alternative ্র
      'ǁ': '্র',     // Alternative ্র
      'ǂ': '্র',     // Alternative ্র
      'ǃ': '্র',     // Alternative ্র
      'Ą': 'ন',      // Alternative ন
      'ą': 'ন',      // Alternative ন
      'Ć': 'চ',      // Alternative চ
      'ć': 'চ',      // Alternative চ
      'Ĉ': 'ছ',      // Alternative ছ
      'ĉ': 'ছ',      // Alternative ছ
      'Ċ': 'জ',      // Alternative জ
      'ċ': 'জ',      // Alternative জ
      'Č': 'ঝ',      // Alternative ঝ
      'č': 'ঝ',      // Alternative ঝ
      'Ď': 'ঞ',      // Alternative ঞ
      'ď': 'ঞ',      // Alternative ঞ
      'Đ': 'ট',      // Alternative ট
      'đ': 'ট',      // Alternative ট
      'Ē': 'ঠ',      // Alternative ঠ
      'ē': 'ঠ',      // Alternative ঠ
      // 'Ĕ': 'ড',      // Alternative ড
      'ĕ': 'ড',      // Alternative ড
      'Ė': 'ঢ',      // Alternative ঢ
      'ė': 'ঢ',      // Alternative ঢ
      'Ę': 'ণ',      // Alternative ণ
      'ę': 'ণ',      // Alternative ণ
      'Ě': 'ত',      // Alternative ত
      'ě': 'ত',      // Alternative ত
      'Ĝ': 'থ',      // Alternative থ
      'ĝ': 'থ',      // Alternative থ
      'Ğ': 'দ',      // Alternative দ
      'ğ': 'দ',      // Alternative দ
      'Ġ': 'ধ',      // Alternative ধ
      'ġ': 'ধ',      // Alternative ধ
      'Ģ': 'ন',      // Alternative ন
      'ģ': 'ন',      // Alternative ন
      'Ĥ': 'প',      // Alternative প
      'ĥ': 'প',      // Alternative প
      'Ħ': 'ফ',      // Alternative ফ
      'ħ': 'ফ',      // Alternative ফ
      'Ĩ': 'ব',      // Alternative ব
      'ĩ': 'ব',      // Alternative ব
      'Ī': 'ভ',      // Alternative ভ
      'ī': 'ভ',      // Alternative ভ
      'Į': 'ম',      // Alternative ম
      'į': 'ম',      // Alternative ম
      'İ': 'য',      // Alternative য
      'ı': 'য',      // Alternative য
      'Ĳ': 'র',      // Alternative র
      'ĳ': 'র',      // Alternative র
      'Ĵ': 'ল',      // Alternative ল
      'ĵ': 'ল',      // Alternative ল
      'Ķ': 'শ',      // Alternative শ
      'ķ': 'শ',      // Alternative শ
      'ĸ': 'ষ',      // Alternative ষ
      'Ĺ': 'স',      // Alternative স
      'ĺ': 'স',      // Alternative স
      'Ļ': 'হ',      // Alternative হ
      'ļ': 'হ',      // Alternative হ
      'Ľ': 'ড়',      // Alternative ড়
      'ľ': 'ড়',      // Alternative ড়
      'Ŀ': 'ঢ়',     // Alternative ঢ়
      'ŀ': 'ঢ়',     // Alternative ঢ়
      'Ł': 'য়',      // Alternative য়
      'ł': 'য়',      // Alternative য়
      'Ń': 'ৎ',      // Alternative ৎ
      'ń': 'ৎ',      // Alternative ৎ
      'Ņ': 'ং',      // Alternative ং
      'ņ': 'ং',      // Alternative ং
      'Ň': 'ঃ',      // Alternative ঃ
      'ň': 'ঃ',      // Alternative ঃ
      'ŉ': 'ঁ',      // Alternative ঁ
      'Ŋ': '্র',     // Alternative ্র
      'ŋ': '্র',     // Alternative ্র
    };
    
    // First check direct mapping
    if (directMappings.containsKey(ch)) {
      return directMappings[ch]!;
    }
    
    // Try to guess based on position in Bangla alphabet
    final code = ch.codeUnitAt(0);
    
    // For Latin letters that look/sound similar to Bangla
    if (code >= 65 && code <= 90) { // A-Z
      final lowerCh = ch.toLowerCase();
      final Map<String, String> latinToBangla = {
        'a': 'এ', 'b': 'ব', 'c': 'স', 'd': 'ড', 'e': 'ই',
        'f': 'ফ', 'g': 'জ', 'h': 'হ', 'i': 'আই', 'j': 'জ',
        'k': 'ক', 'l': 'ল', 'm': 'ম', 'n': 'ন', 'o': 'ও',
        'p': 'প', 'q': 'ক', 'r': 'র', 's': 'স', 't': 'ট',
        'u': 'উ', 'v': 'ভ', 'w': 'ডব্লিউ', 'x': 'এক্স', 'y': 'ওয়াই', 'z': 'জেড'
      };
      return latinToBangla[lowerCh] ?? '';
    }
    
    if (code >= 97 && code <= 122) { // a-z
      final Map<String, String> latinToBangla = {
        'a': 'এ', 'b': 'ব', 'c': 'স', 'd': 'ড', 'e': 'ই',
        'f': 'ফ', 'g': 'জ', 'h': 'হ', 'i': 'আই', 'j': 'জ',
        'k': 'ক', 'l': 'ল', 'm': 'ম', 'n': 'ন', 'o': 'ও',
        'p': 'প', 'q': 'ক', 'r': 'র', 's': 'স', 't': 'ট',
        'u': 'উ', 'v': 'ভ', 'w': 'ডব্লিউ', 'x': 'এক্স', 'y': 'ওয়াই', 'z': 'জেড'
      };
      return latinToBangla[ch] ?? '';
    }
    
    // Special case for combining characters
    if (prev.isNotEmpty && _isValidBanglaChar(prev)) {
      // If previous character is Bangla, this might be a vowel sign or modifier
      if (ch == '়') return '়'; // Nukta
      if (ch == '্') return '্'; // Hasanta
    }
    
    // Default: return empty string (remove) if we can't guess
    // This is better than '*' which makes text ugly
    return '';
  }
  
  /// Helper method to clean text with this replacer
  static String cleanText(String text) {
    // First pass: replace invalid characters
    String cleaned = replaceInvalidChars(text);
    
    // Second pass: fix common multi-character patterns
    cleaned = _fixCommonPatterns(cleaned);
    
    // Third pass: normalize spacing
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    return cleaned.trim();
  }
  
  static String _fixCommonPatterns(String text) {
    String fixed = text;
    
    // Fix specific patterns from your sample
    final patterns = {
      'Ïভোটার': 'ভোটার',
      'Ïজলো': 'জেলা',
      'Ïপৗর': 'পৌর',
      'Ïবগম': 'বেগম',
      'Ïমাঃ': 'মোঃ',
      'Ïশখ': 'শেখ',
      'Ïবকার': 'ব্যবসায়ী',
      'Ïলন': 'লেন',
      'Ïসানিযা': 'সানিয়া',
      'Ïরহানা': 'রেহানা',
      'Ïরোকযা': 'রোকেয়া',
      'Ïমাসাঃ': 'মোছাঃ',
      'Ïমাছাঃ': 'মোছাঃ',
      'Ïহাসনে': 'হাসিনা',
      'Ïভোটার': 'ভোটার',
      'Ïপশো': 'পেশা',
      'Ïসবািũন': 'সবিন',
    };
    
    patterns.forEach((wrong, correct) {
      fixed = fixed.replaceAll(wrong, correct);
    });
    
    return fixed;
  }
}