import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class VoterPdfParser {
  // Parse voters from Bangladesh voter list PDF
  static Future<List<Map<String, dynamic>>> parseVoters(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final Uint8List pdfBytes = bytes.buffer.asUint8List();
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      
      String allText = '';
      
      // Extract all text
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      for (int i = 0; i < document.pages.count; i++) {
        String pageText = extractor.extractText(startPageIndex: i);
        
        // Clean up encoding issues
        pageText = _fixBanglaEncoding(pageText);
        
        allText += pageText + '\n';
        
        // Debug first page
        if (i == 0) {
          print('=== PAGE 1 TEXT (Cleaned) ===');
          print(pageText.substring(0, min(500, pageText.length)));
          print('===========================');
        }
      }
      
      document.dispose();
      
      // Parse voters from cleaned text
      return _parseCleanedText(allText);
    } catch (e) {
      print('VoterPdfParser error: $e');
      return [];
    }
  }
  
  // Fix common Bangla encoding issues
  static String _fixBanglaEncoding(String text) {
    String cleaned = text;
    
    // Common encoding fixes for Bangladesh voter PDFs
    final fixes = {
      'Î': '্', // Halant
      'Ĕ': 'য', // Ya
      'ē': 'ত', // Ta
      'ń': 'ব', // Ba
      'Ë': 'য়', // Yayya
      'Ï': '', // Remove weird characters
      'Ù': '',
      'į': '',
      'Ĵ': '',
      '×': 'ল', // La
      'স/o': 'স/o',
      'স/ও': 'স/ও',
    };
    
    fixes.forEach((wrong, correct) {
      cleaned = cleaned.replaceAll(wrong, correct);
    });
    
    return cleaned;
  }
  
  // Parse cleaned text for voter data
  static List<Map<String, dynamic>> _parseCleanedText(String text) {
    final List<Map<String, dynamic>> voters = [];
    final lines = text.split('\n');
    
    // Look for voter entries
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      // Skip empty lines and header lines
      if (line.isEmpty || 
          line.contains('বাংলাদেশ') ||
          line.contains('নির্বাচন কমিশন') ||
          line.contains('ভোটার তালিকা') ||
          line.contains('মোট ভোটার সংখ্যা')) {
        continue;
      }
      
      // Look for serial number pattern (e.g., "1.", "2.", "৩.", etc.)
      if (RegExp(r'^\d+[\.\)]\s').hasMatch(line) || 
          RegExp(r'^[০-৯]+[\.\)]\s').hasMatch(line)) {
        
        final voter = _parseVoterLine(line, i < lines.length - 1 ? lines[i + 1] : '');
        if (voter.isNotEmpty) {
          voters.add(voter);
        }
      }
      
      // Also look for "নাম:" pattern
      if (line.contains('নাম:')) {
        final voter = _parseNamedVoter(line);
        if (voter.isNotEmpty) {
          voters.add(voter);
        }
      }
    }
    
    print('Parsed ${voters.length} voters from PDF');
    if (voters.isNotEmpty) {
      print('Sample voters:');
      for (int i = 0; i < min(3, voters.length); i++) {
        print('  ${i + 1}. ${voters[i]['name']} - ${voters[i]['father']}');
      }
    }
    
    return voters;
  }
  
  // Parse a line with serial number pattern
  static Map<String, dynamic> _parseVoterLine(String line, String nextLine) {
    try {
      // Pattern 1: "1. আব্দুল করিম স/o মোঃ আলী"
      // Pattern 2: "২. হালিমা আক্তার অং/ও নুর মোহাম্মদ"
      
      String name = '';
      String father = '';
      String mother = '';
      String dob = '';
      String address = '';
      
      // Remove serial number
      String content = line.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '');
      content = content.replaceAll(RegExp(r'^[০-৯]+[\.\)]\s*'), '');
      
      // Check for "স/o" or "স/ও" pattern (son of / wife of)
      if (content.contains('স/o') || content.contains('স/ও')) {
        final parts = content.split(RegExp(r'স/[oও]'));
        if (parts.length >= 2) {
          name = parts[0].trim();
          
          // Father/mother name might have additional info
          String parentInfo = parts[1].trim();
          
          // Check if it's mother (অং/ও pattern for female voters)
          if (parentInfo.contains('অং/ও')) {
            final motherParts = parentInfo.split('অং/ও');
            father = motherParts[0].trim();
            if (motherParts.length > 1) {
              mother = motherParts[1].trim();
            }
          } else {
            father = parentInfo;
          }
        }
      } 
      // Check for other patterns
      else if (content.contains('পিতা:')) {
        final nameMatch = RegExp(r'^(.*?)(?=পিতা:)').firstMatch(content);
        final fatherMatch = RegExp(r'পিতা:\s*(.*?)(?=,|$)').firstMatch(content);
        final motherMatch = RegExp(r'মাতা:\s*(.*?)(?=,|$)').firstMatch(content);
        final dobMatch = RegExp(r'জন্ম তারিখ:\s*(.*?)(?=,|$)').firstMatch(content);
        
        name = nameMatch?.group(1)?.trim() ?? '';
        father = fatherMatch?.group(1)?.trim() ?? '';
        mother = motherMatch?.group(1)?.trim() ?? '';
        dob = dobMatch?.group(1)?.trim() ?? '';
      }
      
      // If we got a name but no father from this line, check next line
      if (name.isNotEmpty && father.isEmpty && nextLine.isNotEmpty) {
        if (nextLine.contains('পিতা:')) {
          father = _extractValue(nextLine, 'পিতা');
        }
        if (nextLine.contains('মাতা:')) {
          mother = _extractValue(nextLine, 'মাতা');
        }
        if (nextLine.contains('জন্ম তারিখ:')) {
          dob = _extractValue(nextLine, 'জন্ম তারিখ');
        }
      }
      
      if (name.isNotEmpty) {
        return {
          'name': name,
          'father': father,
          'mother': mother,
          'dob': dob,
          'ward': '', // Will be filled from folder name
          'address': address,
          'source': 'voter_list',
        };
      }
    } catch (e) {
      print('Error parsing voter line: $e');
    }
    
    return {};
  }
  
  // Parse "নাম:" pattern
  static Map<String, dynamic> _parseNamedVoter(String line) {
    try {
      final name = _extractValue(line, 'নাম');
      final father = _extractValue(line, 'পিতা');
      final mother = _extractValue(line, 'মাতা');
      final dob = _extractValue(line, 'জন্ম তারিখ');
      
      if (name.isNotEmpty) {
        return {
          'name': name,
          'father': father,
          'mother': mother,
          'dob': dob,
          'ward': '',
          'address': '',
          'source': 'named_entry',
        };
      }
    } catch (e) {
      print('Error parsing named voter: $e');
    }
    
    return {};
  }
  
  // Extract value after a field label - FIXED REGEX
  static String _extractValue(String text, String field) {
    try {
      // Escape special regex characters in field name
      final escapedField = RegExp.escape(field);
      
      // Pattern 1: field: value (with colon or fullwidth colon)
      final pattern1 = RegExp('$escapedField[:：]\\s*(.*?)(?=,|;|\\.|\$|\\n)');
      final match1 = pattern1.firstMatch(text);
      
      if (match1 != null && match1.group(1) != null) {
        return match1.group(1)!.trim();
      }
      
      // Pattern 2: field followed by value (no colon)
      final pattern2 = RegExp('$escapedField\\s+(.*?)(?=,|;|\\.|\$)');
      final match2 = pattern2.firstMatch(text);
      
      if (match2 != null && match2.group(1) != null) {
        return match2.group(1)!.trim();
      }
      
      // Pattern 3: Simple extract everything after field
      final index = text.indexOf(field);
      if (index != -1) {
        String remaining = text.substring(index + field.length).trim();
        
        // Remove colon if present
        if (remaining.startsWith(':') || remaining.startsWith('：')) {
          remaining = remaining.substring(1).trim();
        }
        
        // Take until next field or end
        final nextFields = ['নাম', 'পিতা', 'মাতা', 'জন্ম', 'তারিখ', 'ঠিকানা', 'ওয়ার্ড'];
        for (final nextField in nextFields) {
          if (nextField != field && remaining.contains(nextField)) {
            final nextIndex = remaining.indexOf(nextField);
            if (nextIndex > 0) {
              remaining = remaining.substring(0, nextIndex).trim();
            }
          }
        }
        
        if (remaining.isNotEmpty) {
          return remaining;
        }
      }
    } catch (e) {
      print('Error extracting $field: $e');
    }
    
    return '';
  }
  
  // Extract ward number from file path
  static String extractWardFromPath(String filePath) {
    try {
      // Look for ward number in path
      final wardPatterns = [
        RegExp(r'ওয়ার্ড[\s_-]*(\d+)'),
        RegExp(r'ward[\s_-]*(\d+)', caseSensitive: false),
        RegExp(r'(\d+)[\s_-]*ওয়ার্ড'),
        RegExp(r'(\d+)[\s_-]*ward', caseSensitive: false),
        RegExp(r'w[\s_-]*(\d+)', caseSensitive: false),
      ];
      
      for (final pattern in wardPatterns) {
        final match = pattern.firstMatch(filePath.toLowerCase());
        if (match != null && match.group(1) != null) {
          return match.group(1)!;
        }
      }
      
      // Look for any 2-3 digit number that might be a ward
      final numberPattern = RegExp(r'\b(\d{2,3})\b');
      final matches = numberPattern.allMatches(filePath);
      for (final match in matches) {
        final num = int.tryParse(match.group(1)!);
        if (num != null && num >= 1 && num <= 200) { // Reasonable ward range
          return match.group(1)!;
        }
      }
    } catch (e) {
      print('Error extracting ward: $e');
    }
    
    return '';
  }
}

// Helper extension for regex escaping
extension RegExpExt on RegExp {
  static String escape(String text) {
    return text.replaceAllMapped(RegExp(r'[.*+?^${}()|[\]\\]'), (match) {
      return '\\${match.group(0)}';
    });
  }
}