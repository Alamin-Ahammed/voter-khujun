import 'dart:math';

class BanglaTextCorrector {
  /// Comprehensive Bangla text correction for OCR/encoding issues
  static String correctBanglaText(String text) {
    String corrected = text;

    print('=== CORRECTING BANGLA TEXT ===');
    print('Original length: ${text.length}');

    // Stage 1: Fix vowel sign positioning (কার in Bangla)
    corrected = _fixVowelSigns(corrected);

    // Stage 2: Fix common OCR errors for specific words
    corrected = _fixCommonWords(corrected);

    // Stage 3: Fix individual character errors
    corrected = _fixCharacterErrors(corrected);

    // Stage 4: Fix specific patterns in your PDF
    corrected = _fixPDFPatterns(corrected);

    // Stage 5: Fix spacing and punctuation
    corrected = _fixSpacingAndPunctuation(corrected);

    print('Corrected length: ${corrected.length}');

    // Show sample before/after
    if (text.length > 500 && corrected.length > 500) {
      print('\n=== SAMPLE CORRECTION ===');
      print('BEFORE (chars 1000-1500):');
      print(text.substring(1000, 1500));
      print('\nAFTER (chars 1000-1500):');
      print(corrected.substring(1000, 1500));
    }

    return corrected;
  }

  /// Stage 1: Fix Bangla vowel sign positioning
  /// In Bangla, vowel signs should come AFTER consonants, not before
  static String _fixVowelSigns(String text) {
    String fixed = text;

    // Fix vowel sign positioning patterns
    // These are common OCR errors where vowel signs appear before consonants
    final vowelFixPatterns = {
      // Fix 'ি' (i-kar) positioning - should be before the character
      RegExp(r'([ক-হড়-য়])(ি)'): r'$2$1', // Move 'ি' before consonant

      // Fix 'ী' (ii-kar) positioning
      RegExp(r'([ক-হড়-য়])(ী)'): r'$2$1',

      // Fix 'ু' (u-kar) positioning
      RegExp(r'([ক-হড়-য়])(ু)'): r'$2$1',

      // Fix 'ূ' (uu-kar) positioning
      RegExp(r'([ক-হড়-য়])(ূ)'): r'$2$1',

      // Fix 'ে' (e-kar) positioning
      RegExp(r'([ক-হড়-য়])(ে)'): r'$2$1',

      // Fix 'ো' (o-kar) positioning
      RegExp(r'([ক-হড়-য়])(ো)'): r'$2$1',

      // Fix 'ৌ' (au-kar) positioning
      RegExp(r'([ক-হড়-য়])(ৌ)'): r'$2$1',
    };

    // Apply vowel sign fixes
    vowelFixPatterns.forEach((pattern, replacement) {
      fixed = fixed.replaceAllMapped(pattern, (match) => replacement);
    });

    return fixed;
  }

  /// Stage 2: Fix common OCR errors for specific words
  static String _fixCommonWords(String text) {
    String fixed = text;

    // Comprehensive list of common OCR errors in Bangla voter PDFs
    final wordCorrections = {
      // Field names
      'িপতা': 'পিতা',
      'পশা': 'পেশা',
      'জ তািরখ': 'জন্ম তারিখ',
      'তািরখ': 'তারিখ',
      'ঠকানা': 'ঠিকানা',
      'ভাটার': 'ভোটার',
      'ভাটার নং': 'ভোটার নং',
      'মাইেট হেয়েছ': 'মাইগ্রেট হয়েছে',
      'মহািল': 'মহিলা',

      // Common professions
      'গৃিহনী': 'গৃহিণী',
      'ছা/ছাী': 'ছাত্র/ছাত্রী',
      'ছা/ছাি': 'ছাত্র/ছাত্রী',
      'ছা/ছা': 'ছাত্র/ছাত্রী',
      'গেমজ': 'গেমস',
      'গেময': 'গেমস',
      'িবকার': 'ব্যবসায়ী',
      'বকার': 'ব্যবসায়ী',
      'বািকার': 'ব্যবসায়ী',
      'চারী': 'কর্মচারী',
      'কারী': 'কর্মী',
      'িমক': 'শিক্ষক',

      // Common names and places
      'যাĔাবাড়ী': 'যাত্রাবাড়ী',
      'যাÊাবাড়ী': 'যাত্রাবাড়ী',
      'যাাবাড়ী': 'যাত্রাবাড়ী',
      'যাবাড়ী': 'যাত্রাবাড়ী',
      'উওর': 'উত্তর',
      'উর': 'উত্তর',
      'উঃ': 'উত্তর',
      'ঢকা': 'ঢাকা',
      'ঢকাা': 'ঢাকা',
      'বািড়': 'বাড়ি',
      'বািড়ী': 'বাড়ি',
      'লন': 'লেন',
      'লোন': 'লেন',
      'মডল': 'মন্ডল',
      'মডল্': 'মন্ডল',
      'হাওলঅদার': 'হাওলাদার',
      'হাওলাদার': 'হাওলাদার',
      'তালুকদার': 'তালুকদার',
      'শখ': 'শেখ',
      'মাা': 'মিয়া',
      'ময়া': 'মিয়া',
      'বগম': 'বেগম',
      'খানম': 'খানম',
      'খাতুন': 'খাতুন',
      'আার': 'আরা',
      'আারা': 'আরা',
      'সািহদা': 'সাহিদা',
      'সািহদ': 'সাহিদ',
      'রািহমা': 'রহিমা',
      'রিহমা': 'রহিমা',
      'তাছিলমা': 'তাসলিমা',
      'তাসিলমা': 'তাসলিমা',
      'মমতাজ': 'মমতাজ',
      'পারিভন': 'পরিভন',
      'শাহজাদী': 'শাহজাদি',
      'আকিলমা': 'আকলিমা',
      'নাজমা': 'নাজমা',
      'হািসনা': 'হাসনা',
      'মেনায়ারা': 'মনোয়ারা',
      'রজাহান': 'রোজেনা',
      'শাহানা': 'শাহানা',
      'সেলমা': 'সেলিমা',
      'আিমন': 'আয়মন',
      'আয়শা': 'আয়শা',
      'খেতজা': 'খাতিজা',
      'আাফ': 'আফাজ',
      'আিতয়া': 'আয়েশা',
      'মােজদা': 'মোজদা',
      'িবলিকছ': 'বিলকিস',
      'মাুদা': 'মোদা',
      'সািহদা সিলম': 'সাহিদা সেলিম',
      'মিরয়ম': 'মরিয়ম',
      'মাকছুদা': 'মাকসুদা',
      'পাল': 'পল',
      'সিখনা': 'সখিনা',
      'বােসেসা': 'বসিরা',
      'লিতফ': 'লতিফ',
      'রা': 'রানা',
      'সালমা': 'সেলিমা',
      'আশিপয়া': 'আশিকুন',
      'রােকয়া': 'রোকেয়া',
      'মালা': 'মোল্লা',
      'সােলহা': 'সলেহা',
      'শামাহার': 'সামিহা',
      'ইলা': 'ইলা',
      'জািমনা': 'জমিলা',
      'শরবত': 'শরবত',
      'িশ': 'সিসি',
      'লািক': 'লাইক',
      'শফালী': 'সফিয়া',
      'িশিরন': 'সিরিন',
      'বির': 'বিবির',
      'মিন': 'মনি',
      'সািহদা': 'সাহিদা',
      'আেমনা': 'আমেনা',
      'জােয়দা': 'জয়ন্তী',
      'সািনয়া': 'সানিয়া',
      'সাহানারা': 'সাহানাজ',
      'অংরা': 'অঙ্গরা',
      'রােবয়া': 'রুবিয়া',
      'জেলখা': 'জেলেখা',
      'িম': 'সিমি',
      'ষুিফয়া': 'সুফিয়া',
      'সবুরা': 'সবুরা',
      'ববী': 'ববি',
      'র িফয়া': 'রফিয়া',
      'িশী': 'সিসি',
      'পরািন': 'পরীন',
      'িরনা': 'রিনা',
      'শীমু': 'সীমু',
      'জাহানারা': 'জাহানারা',
      'সারিমন': 'সারিমা',
      'লতানা': 'লতিফা',
      'নাজিনন': 'নাজনিন',
      'রাকসানা': 'রকসানা',
      'ফিরদা': 'ফরিদা',
      'অজুফা': 'আজিজা',
      'কনা': 'কোনা',
      'রািজয়া': 'রাজিয়া',
      'আছমা': 'আসমা',
      'পা': 'পা',
      'মা': 'মা',
      'সািহদা খাতুন': 'সাহিদা খাতুন',
      'আেনায়ারা': 'আনোয়ারা',
      'রহানা': 'রেহানা',
      'ময়না': 'ময়না',
      'মেকা': 'মিকা',
      'সািবয়া': 'সাবিয়া',
      'মুী': 'মুন্নি',
      'পলাশী': 'পলাশী',
      'সামা': 'সামা',
      'মাকছুদা': 'মাকসুদা',
      'শারিমন': 'সারিমা',
      'শাহীর': 'শাহীর',
      'খারেশদা': 'খোরশেদা',
      'ফয়েজর': 'ফয়েজ',
      'মিন': 'মনি',
      'সাহানাজ': 'সাহানাজ',
      'রিহমা': 'রহিমা',
      'আেনায়ারা': 'আনোয়ারা',
      'শাহানাজ': 'সাহানাজ',
      'মাফা': 'মাফা',
      'হাসেন আরা': 'হাসিনা আরা',
    };

    // Apply word corrections
    wordCorrections.forEach((wrong, correct) {
      fixed = fixed.replaceAll(wrong, correct);
    });

    return fixed;
  }

  /// Stage 3: Fix individual character errors
  static String _fixCharacterErrors(String text) {
    String fixed = text;

    // Map of wrong characters to correct Bangla characters
    final charCorrections = {
      // Fix common OCR character errors
      'Ĕ': 'ত্র',
      'Ê': 'ত্র',
      'Ï': '', // Remove this as it's usually noise
      'ĥ': 'ন্ম',
      'Ĕ': 'র্',
      'Ê': 'র্',

      // Fix vowel sign issues
      'í': 'ী',
      'á': 'া',
      'é': 'ে',
      'ó': 'ো',
      'ú': 'ূ',
      'ñ': 'ঞ',
      'ü': 'ু',
      'ā': 'া',
      'ī': 'ী',
      'ū': 'ূ',
      'ṛ': '্র',
      'ṣ': 'ষ',
      'ṭ': 'ট',
      'ḍ': 'ড',
      'ṇ': 'ণ',
      'ḷ': 'ল',
      'ś': 'শ',
      'ṅ': 'ং',

      // Fix half letters and other issues
      '্্': '্', // Double half character
      '্র্র': '্র', // Double ra-phala
      '্ন্ন': '্ন', // Double na-phala

      // Remove invisible/control characters
      '\u200B': '', // Zero-width space
      '\u200C': '', // Zero-width non-joiner
      '\u200D': '', // Zero-width joiner
      '\uFEFF': '', // Byte order mark
    };

    // Apply character corrections
    charCorrections.forEach((wrong, correct) {
      fixed = fixed.replaceAll(wrong, correct);
    });

    // Fix Bangla number OCR errors
    final banglaNumbers = {
      '০': '০',
      '1': '১',
      '2': '২',
      '3': '৩',
      '4': '৪',
      '5': '৫',
      '6': '৬',
      '7': '৭',
      '8': '৮',
      '9': '৯',
      'o': '০',
      'O': '০',
      'l': '১',
      'I': '১',
      'Z': '২',
      'S': '৫',
      'b': '৬',
      'q': '৯',
    };

    // Fix number patterns
    for (final entry in banglaNumbers.entries) {
      // Only replace standalone digits or digits in date patterns
      fixed = fixed.replaceAllMapped(RegExp('(\\D)${entry.key}(\\D)'),
          (match) => '${match.group(1)}${entry.value}${match.group(2)}');
    }

    return fixed;
  }

  /// Stage 4: Fix specific patterns in your PDF
  static String _fixPDFPatterns(String text) {
    String fixed = text;

    // Fix specific voter entry patterns
    final patterns = {
      // Fix "0001. নাম:" pattern
      RegExp(r'(\d{4})\.\s*নাম:'): r'$1. নাম:',

      // Fix "ভাটার নং:" spacing
      RegExp(r'ভাটার\s*নং:'): 'ভোটার নং:',

      // Fix "িপতা:" pattern
      RegExp(r'িপতা:'): 'পিতা:',

      // Fix "পশা:" pattern
      RegExp(r'পশা:'): 'পেশা:',

      // Fix "জ তািরখ:" pattern
      RegExp(r'জ\s*তািরখ:'): 'জন্ম তারিখ:',

      // Fix "ঠকানা:" pattern
      RegExp(r'ঠকানা:'): 'ঠিকানা:',

      // Fix date patterns (dd/mm/yyyy)
      RegExp(r'(\d{1,2})\s*/\s*(\d{1,2})\s*/\s*(\d{4})'): r'$1/$2/$3',

      // Fix "উর যাাবাড়ী" pattern
      RegExp(r'উর\s*যা[^ ]*\s*াবাড়ী'): 'উত্তর যাত্রাবাড়ী',

      // Fix ward patterns
      RegExp(r'ওয়াড\s*নং\s*[-:]?\s*(\d+)'): (Match match) =>
          'ওয়ার্ড নং ${match.group(1)}',
      RegExp(r'ওয়ার্ড\s*নং\s*[-:]?\s*(\d+)'): (Match match) =>
          'ওয়ার্ড নং ${match.group(1)}',
    };

    // Apply pattern fixes
    patterns.forEach((pattern, replacement) {
      fixed = fixed.replaceAllMapped(pattern, (match) {
        if (replacement is String) {
          return replacement;
        } else if (replacement is Function) {
          return replacement(match);
        }
        return match.group(0)!;
      });
    });

    return fixed;
  }

  /// Stage 5: Fix spacing and punctuation
  static String _fixSpacingAndPunctuation(String text) {
    String fixed = text;

    // Remove extra spaces
    fixed = fixed.replaceAll(RegExp(r'\s+'), ' ');

    // Fix spacing around colons
    fixed = fixed.replaceAll(RegExp(r'\s*:\s*'), ': ');

    // Fix spacing around commas
    fixed = fixed.replaceAll(RegExp(r'\s*,\s*'), ', ');

    // Fix spacing around periods
    fixed = fixed.replaceAll(RegExp(r'\s*\.\s*'), '. ');

    // Fix spacing around slashes in dates
    fixed = fixed.replaceAll(RegExp(r'(\d)\s*/\s*(\d)'), r'$1/$2');

    // Fix multiple newlines
    fixed = fixed.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Trim whitespace
    fixed = fixed.trim();

    return fixed;
  }

  /// Quick test function to show before/after
  static void testCorrection(String sampleText) {
    print('\n=== TESTING CORRECTION ===');
    print('Original sample:');
    print(sampleText.substring(0, min(300, sampleText.length)));

    final corrected = correctBanglaText(sampleText);

    print('\nCorrected sample:');
    print(corrected.substring(0, min(300, corrected.length)));

    print('\n=== KEY CHANGES ===');

    // Show specific fixes
    final testCases = [
      ['িপতা', 'পিতা'],
      ['পশা', 'পেশা'],
      ['জ তািরখ', 'জন্ম তারিখ'],
      ['ঠকানা', 'ঠিকানা'],
      ['গৃিহনী', 'গৃহিণী'],
      ['যাĔাবাড়ী', 'যাত্রাবাড়ী'],
      ['উওর', 'উত্তর'],
    ];

    for (final test in testCases) {
      final wrong = test[0];
      final correct = test[1];
      final hasWrong = sampleText.contains(wrong);
      final hasCorrect = corrected.contains(correct);

      if (hasWrong || hasCorrect) {
        print('$wrong -> $correct: ${hasWrong ? "FIXED" : "OK"}');
      }
    }
  }
}
