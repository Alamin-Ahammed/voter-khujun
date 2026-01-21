import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:voter_khujun/utils/bangla_char_replacer.dart';
import 'package:voter_khujun/utils/bangla_heuristic_fixer.dart';
import 'package:voter_khujun/utils/bangla_text_correcter.dart';
import 'package:voter_khujun/utils/bangla_text_decoder.dart';
import 'package:voter_khujun/utils/normalize_bangla.dart';

class SimplePdfParserTest {
  static Future<List<Map<String, dynamic>>> parseVoters(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final Uint8List pdfBytes = bytes.buffer.asUint8List();
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      
      String allText = '';
      
      // Extract all text
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      for (int i = 0; i < document.pages.count; i++) {
        allText += extractor.extractText(startPageIndex: i) + '\n';
      }
      
      document.dispose();
      
      print('=== SIMPLE PARSER ===');
      print('Total text length: ${allText.length}');
      print(allText);
      
      // First, clean the text - fix encoding issues
      // allText = _cleanBanglaText(allText);
      // allText = BanglaTextCorrector.correctBanglaText(allText); হালিমা আক্তার ফারজানা মমতাজ মরিয়ম হুরুন ডলি কাজী 

      allText = normalizeBangla(allText);
      allText = BanglaTextFixer.fix(allText);
      allText = BanglaCharReplacer.cleanText(allText);
      allText = BanglaHeuristicFixer.improve(allText);


      
      // Now parse the cleaned text
      final voters = _parseVotersFromText(allText);
      
      print('Voters found: ${voters.length}');
      if (voters.isNotEmpty) {
        print('Sample voter 1: ${voters[0]}');
        if (voters.length > 1) print('Sample voter 2: ${voters[1]}');
        if (voters.length > 2) print('Sample voter 3: ${voters[2]}');
      }
      
      return voters;
    } catch (e) {
      print('Simple parser error: $e');
      return [];
    }
  }
  
  static String _cleanBanglaText(String text) {
    // Fix common OCR/encoding errors in your PDF
    String cleaned = text;
    
    // Replace wrong characters with correct Bangla ones
    final replacements = {
      'িপতা': 'পিতা',
      'জ তািরখ': 'জন্ম তারিখ',
      'ঠকানা': 'ঠিকানা',
      'ী': 'ী',
      'ি': 'ি',
      'ু': 'ু',
      'ূ': 'ূ',
      'ে': 'ে',
      'ো': 'ো',
      'ৌ': 'ৌ',
      'ৎ': 'ৎ',
      'ং': 'ং',
      'ঃ': 'ঃ',
      'ঁ': 'ঁ',
    };
    
    replacements.forEach((wrong, correct) {
      cleaned = cleaned.replaceAll(wrong, correct);
    });
    
    return cleaned;
  }
  
  static List<Map<String, dynamic>> _parseVotersFromText(String text) {
    final List<Map<String, dynamic>> voters = [];
    
    // Split the text by voter entries - look for patterns like:
    // 1. Number followed by dot (0001., 0002., etc.)
    // 2. Or "নাম:" that starts a new entry
    final sections = _splitIntoSections(text);
    
    print('Found ${sections.length} voter sections');
    
    for (final section in sections) {
      if (section.trim().isEmpty) continue;
      
      final voter = _extractVoterFromSection(section);
      if (voter['name'] != null && voter['name'].toString().isNotEmpty) {
        voters.add(voter);
      }
    }
    
    return voters;
  }
  
  static List<String> _splitIntoSections(String text) {
    final List<String> sections = [];
    
    // Method 1: Split by serial numbers (0001., 0002., etc.)
    final serialPattern = RegExp(r'\d{3,4}\.');
    final matches = serialPattern.allMatches(text);
    
    if (matches.length > 1) {
      // We found serial numbers, split by them
      int lastEnd = 0;
      for (final match in matches) {
        if (match.start > lastEnd) {
          sections.add(text.substring(lastEnd, match.start));
        }
        lastEnd = match.start;
      }
      // Add the last section
      if (lastEnd < text.length) {
        sections.add(text.substring(lastEnd));
      }
    } else {
      // Method 2: Split by "নাম:" pattern
      final namePattern = RegExp(r'নাম:');
      final nameMatches = namePattern.allMatches(text);
      
      if (nameMatches.length > 1) {
        int lastEnd = 0;
        for (final match in nameMatches) {
          if (match.start > lastEnd) {
            sections.add(text.substring(lastEnd, match.start));
          }
          lastEnd = match.start;
        }
        if (lastEnd < text.length) {
          sections.add(text.substring(lastEnd));
        }
      } else {
        // Method 3: Just use the whole text as one section
        sections.add(text);
      }
    }
    
    return sections;
  }
  
  static Map<String, dynamic> _extractVoterFromSection(String section) {
    final Map<String, dynamic> voter = {
      'name': '',
      'father': '',
      'mother': '',
      'dob': '',
      'ward': '',
      'address': '',
    };
    
    // Extract name (most important)
    voter['name'] = _extractField(section, 'নাম');
    
    // Extract father (handle both correct and OCR versions)
    final father = _extractField(section, 'পিতা');
    if (father == null || father.isEmpty) {
      // Try alternative pattern
      voter['father'] = _extractField(section, 'িপতা') ?? '';
    } else {
      voter['father'] = father;
    }
    
    // Extract mother
    voter['mother'] = _extractField(section, 'মাতা') ?? '';
    
    // Extract date of birth (handle various patterns)
    final dob = _extractField(section, 'জন্ম তারিখ');
    if (dob == null || dob.isEmpty) {
      voter['dob'] = _extractField(section, 'জ তািরখ') ?? 
                    _extractField(section, 'তারিখ') ?? '';
    } else {
      voter['dob'] = dob;
    }
    
    // Extract address
    voter['address'] = _extractField(section, 'ঠিকানা') ?? '';
    
    // Try to extract ward from address or look for "ওয়ার্ড"
    final ward = _extractField(section, 'ওয়ার্ড');
    if (ward != null && ward.isNotEmpty) {
      voter['ward'] = ward;
    } else if (voter['address'] != null) {
      // Try to find ward number in address
      final wardMatch = RegExp(r'ওয়ার্ড\s*(\d+)').firstMatch(voter['address']!);
      if (wardMatch != null) {
        voter['ward'] = wardMatch.group(1) ?? '';
      }
    }
    
    return voter;
  }
  
  static String? _extractField(String text, String fieldName) {
    try {
      // First, find the field in the text
      final index = text.indexOf(fieldName);
      if (index == -1) return null;
      
      // Get everything after the field name
      String afterField = text.substring(index + fieldName.length);
      
      // Check if there's a colon immediately after
      if (afterField.isNotEmpty && (afterField[0] == ':' || afterField[0] == '：')) {
        afterField = afterField.substring(1);
      }
      
      // Trim whitespace
      afterField = afterField.trim();
      
      // Now we need to extract the value until the next field or end
      // List of possible next fields
      final nextFields = [
        'নাম:', 'পিতা:', 'িপতা:', 'মাতা:', 'মা:', 
        'জন্ম তারিখ:', 'জ তািরখ:', 'তারিখ:', 
        'ঠিকানা:', 'ঠকানা:', 'ওয়ার্ড:', 'ভাটার'
      ];
      
      // Find the earliest next field
      int earliestNext = afterField.length;
      for (final nextField in nextFields) {
        final nextIndex = afterField.indexOf(nextField);
        if (nextIndex != -1 && nextIndex < earliestNext) {
          earliestNext = nextIndex;
        }
      }
      
      // Also check for serial numbers (0001., 0002., etc.)
      final serialMatch = RegExp(r'\d{3,4}\.').firstMatch(afterField);
      if (serialMatch != null && serialMatch.start < earliestNext) {
        earliestNext = serialMatch.start;
      }
      
      // Extract the value
      String value = afterField.substring(0, earliestNext).trim();
      
      // Clean up the value - remove trailing commas, dots, etc.
      value = value.replaceAll(RegExp(r'[.,;।]\s*$'), '');
      
      return value.isNotEmpty ? value : null;
    } catch (e) {
      print('Error extracting $fieldName: $e');
      return null;
    }
  }
  
  // Alternative simpler extraction for testing
  static String? _simpleExtract(String text, String field) {
    try {
      // Create pattern that looks for field followed by colon and value
      final pattern = RegExp('$field[:：]\\s*([^\\n\\r]*)');
      final match = pattern.firstMatch(text);
      
      if (match != null && match.group(1) != null) {
        String value = match.group(1)!.trim();
        
        // Remove any trailing field indicators
        final endPattern = RegExp(r'[\d]{3,4}\.|নাম:|পিতা:|মাতা:|তারিখ:|ঠিকানা:|ওয়ার্ড:');
        final endMatch = endPattern.firstMatch(value);
        if (endMatch != null) {
          value = value.substring(0, endMatch.start).trim();
        }
        
        return value.isNotEmpty ? value : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}