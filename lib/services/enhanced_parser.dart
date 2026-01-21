import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class EnhancedPdfParser {
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
      
      print('=== ENHANCED PARSER ===');
      print('Total text length: ${allText.length}');
      
      // Apply comprehensive OCR correction
      allText = _correctOCRText(allText);
      
      // Now parse with improved logic
      final voters = _parseWithOCRCorrection(allText);
      
      print('Voters found: ${voters.length}');
      if (voters.isNotEmpty) {
        print('\n=== SAMPLE VOTERS ===');
        for (int i = 0; i < min(3, voters.length); i++) {
          print('Voter ${i + 1}:');
          print('  Name: ${voters[i]['name']}');
          print('  Father: ${voters[i]['father']}');
          print('  Mother: ${voters[i]['mother']}');
          print('  DOB: ${voters[i]['dob']}');
          print('  Ward: ${voters[i]['ward']}');
          print('  Address: ${voters[i]['address']}');
          print('');
        }
      }
      
      return voters;
    } catch (e) {
      print('Enhanced parser error: $e');
      return [];
    }
  }
  
  static String _correctOCRText(String text) {
    String corrected = text;
    
    // Comprehensive OCR correction mapping for Bangla
    final Map<String, String> ocrCorrections = {
      // Common OCR errors in your PDF
      'Ïপশা': 'পেশা',
      'গৃিহনী': 'গৃহিণী',
      'জĥ': 'জন্ম',
      'তািরখ': 'তারিখ',
      'যাĔাবাড়ী': 'যাত্রাবাড়ী',
      'উওর': 'উত্তর',
      'সিখনা': 'সখিনা',
      'মহািল': 'মহিলা',
      'বী': 'বি',
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
      'ঞ': 'ঞ',
      'ট': 'ট',
      'ঠ': 'ঠ',
      'ড': 'ড',
      'ঢ': 'ঢ',
      'ণ': 'ণ',
      'ত': 'ত',
      'থ': 'থ',
      'দ': 'দ',
      'ধ': 'ধ',
      'ন': 'ন',
      'প': 'প',
      'ফ': 'ফ',
      'ব': 'ব',
      'ভ': 'ভ',
      'ম': 'ম',
      'য': 'য',
      'র': 'র',
      'ল': 'ল',
      'শ': 'শ',
      'ষ': 'ষ',
      'স': 'স',
      'হ': 'হ',
      'ড়': 'ড়',
      'ঢ়': 'ঢ়',
      'য়': 'য়',
      'ৎ': 'ৎ',
      'ং': 'ং',
      'ঃ': 'ঃ',
      'ঁ': 'ঁ',
    };
    
    // Apply corrections
    ocrCorrections.forEach((wrong, correct) {
      corrected = corrected.replaceAll(wrong, correct);
    });
    
    // Fix specific patterns
    corrected = corrected
        .replaceAll('িপতা', 'পিতা')
        .replaceAll('জ তািরখ', 'জন্ম তারিখ')
        .replaceAll('ঠকানা', 'ঠিকানা')
        .replaceAll('জĥ তািরখ', 'জন্ম তারিখ')
        .replaceAll('Ïপশা:', 'পেশা:')
        .replaceAll('গৃিহনী', 'গৃহিণী')
        .replaceAll('যাĔাবাড়ী', 'যাত্রাবাড়ী')
        .replaceAll('উওর', 'উত্তর');
    
    return corrected;
  }
  
  static List<Map<String, dynamic>> _parseWithOCRCorrection(String text) {
    final List<Map<String, dynamic>> voters = [];
    
    // Split by voter entries using multiple strategies
    final sections = _splitByVoterEntries(text);
    
    print('Found ${sections.length} voter sections');
    
    for (final section in sections) {
      if (section.trim().isEmpty) continue;
      
      final voter = _parseSingleVoter(section);
      if (voter['name'] != null && voter['name'].toString().isNotEmpty) {
        voters.add(voter);
      }
    }
    
    return voters;
  }
  
  static List<String> _splitByVoterEntries(String text) {
    final List<String> sections = [];
    
    // Strategy 1: Look for serial numbers (0001., 0002., etc.)
    final serialPattern = RegExp(r'\d{3,4}\.\s*');
    final serialMatches = serialPattern.allMatches(text);
    
    if (serialMatches.length > 10) { // If we find many serials
      int lastEnd = 0;
      for (final match in serialMatches) {
        if (match.start > lastEnd) {
          sections.add(text.substring(lastEnd, match.start).trim());
        }
        lastEnd = match.start;
      }
      if (lastEnd < text.length) {
        sections.add(text.substring(lastEnd).trim());
      }
      return sections;
    }
    
    // Strategy 2: Look for "নাম:" pattern
    final namePattern = RegExp(r'নাম:\s*');
    final nameMatches = namePattern.allMatches(text);
    
    if (nameMatches.length > 10) {
      int lastEnd = 0;
      for (final match in nameMatches) {
        if (match.start > lastEnd) {
          sections.add(text.substring(lastEnd, match.start).trim());
        }
        lastEnd = match.start;
      }
      if (lastEnd < text.length) {
        sections.add(text.substring(lastEnd).trim());
      }
      return sections;
    }
    
    // Strategy 3: Fallback - split by double newlines
    return text.split(RegExp(r'\n\s*\n')).where((s) => s.trim().isNotEmpty).toList();
  }
  
  static Map<String, dynamic> _parseSingleVoter(String section) {
    final Map<String, dynamic> voter = {
      'name': '',
      'father': '',
      'mother': '',
      'dob': '',
      'ward': '',
      'address': '',
    };
    
    // Extract using robust regex patterns
    voter['name'] = _extractWithRegex(section, r'নাম:\s*([^\n\r,;।]*?)');
    voter['father'] = _extractWithRegex(section, r'পিতা:\s*([^\n\r,;।]*?)');
    voter['mother'] = _extractWithRegex(section, r'মাতা:\s*([^\n\r,;।]*?)');
    
    // Handle DOB - it's often with "পেশা" on same line
    voter['dob'] = _extractDOB(section);
    
    // Extract address
    voter['address'] = _extractAddress(section);
    
    // Extract ward from address or separate
    voter['ward'] = _extractWard(section, voter['address']);
    
    return voter;
  }
  
  static String? _extractWithRegex(String text, String patternStr) {
    try {
      final pattern = RegExp(patternStr);
      final match = pattern.firstMatch(text);
      
      if (match != null && match.group(1) != null) {
        String value = match.group(1)!.trim();
        
        // Clean up - remove trailing field indicators
        final stopPatterns = [
          RegExp(r'\d{3,4}\.'),
          RegExp(r'নাম:'),
          RegExp(r'পিতা:'),
          RegExp(r'মাতা:'),
          RegExp(r'পেশা:'),
          RegExp(r'তারিখ:'),
          RegExp(r'ঠিকানা:'),
          RegExp(r'ওয়ার্ড:'),
        ];
        
        for (final stopPattern in stopPatterns) {
          final stopMatch = stopPattern.firstMatch(value);
          if (stopMatch != null) {
            value = value.substring(0, stopMatch.start).trim();
          }
        }
        
        // Remove punctuation
        value = value.replaceAll(RegExp(r'[.,;।]$'), '');
        
        return value.isNotEmpty ? value : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  static String? _extractDOB(String section) {
    // Try multiple patterns for DOB extraction
    final dobPatterns = [
      // Pattern 1: Direct DOB pattern
      RegExp(r'জন্ম তারিখ:\s*(\d{1,2}/\d{1,2}/\d{4})'),
      RegExp(r'তারিখ:\s*(\d{1,2}/\d{1,2}/\d{4})'),
      
      // Pattern 2: DOB with পেশা on same line
      RegExp(r'পেশা:[^,]*,\s*তারিখ:\s*(\d{1,2}/\d{1,2}/\d{4})'),
      RegExp(r'পেশা:[^,]*,\s*জন্ম তারিখ:\s*(\d{1,2}/\d{1,2}/\d{4})'),
      
      // Pattern 3: Look for date pattern anywhere
      RegExp(r'(\d{1,2}/\d{1,2}/\d{4})'),
    ];
    
    for (final pattern in dobPatterns) {
      final match = pattern.firstMatch(section);
      if (match != null && match.group(1) != null) {
        return match.group(1);
      }
    }
    
    return '';
  }
  
  static String? _extractAddress(String section) {
    // Look for ঠিকানা: pattern
    final addressMatch = RegExp(r'ঠিকানা:\s*([^\n\r]*?)(?=\d{3,4}\.|নাম:|পিতা:|$)', dotAll: true).firstMatch(section);
    
    if (addressMatch != null && addressMatch.group(1) != null) {
      String address = addressMatch.group(1)!.trim();
      
      // Clean up address
      address = address.replaceAll(RegExp(r'[.,;।]$'), '');
      
      // Remove any trailing numbers (like voter numbers)
      address = address.replaceAll(RegExp(r'\s*\d{10,}$'), '');
      
      return address.isNotEmpty ? address : null;
    }
    
    return '';
  }
  
  static String? _extractWard(String section, String? address) {
    // Try to find ward in the section
    final wardPatterns = [
      RegExp(r'ওয়ার্ড\s*নং?\s*[:]?\s*(\d+)'),
      RegExp(r'ওয়ার্ড\s*[:]?\s*(\d+)'),
      RegExp(r'ওয়ার্ড\s*(\d+)'),
    ];
    
    for (final pattern in wardPatterns) {
      final match = pattern.firstMatch(section);
      if (match != null && match.group(1) != null) {
        return match.group(1);
      }
    }
    
    // If not found, check in address
    if (address != null && address.isNotEmpty) {
      for (final pattern in wardPatterns) {
        final match = pattern.firstMatch(address);
        if (match != null && match.group(1) != null) {
          return match.group(1);
        }
      }
    }
    
    return '';
  }
}