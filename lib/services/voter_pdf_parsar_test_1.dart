import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class VoterPdfParser {
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
      
      print('=== VOTER PARSER ===');
      print('Total text length: ${allText.length}');
      
      // Parse the text
      final voters = _parseVoterData(allText);
      
      print('Voters found: ${voters.length}');
      if (voters.isNotEmpty) {
        print('Sample voter 1: ${voters[0]}');
        if (voters.length > 1) print('Sample voter 2: ${voters[1]}');
      }
      
      return voters;
    } catch (e) {
      print('Voter parser error: $e');
      return [];
    }
  }
  
  static List<Map<String, dynamic>> _parseVoterData(String text) {
    final List<Map<String, dynamic>> voters = [];
    
    // Split by voter number pattern (e.g., "0001.", "0002.", etc.)
    final voterSections = text.split(RegExp(r'\d{4}\.\s*'));
    
    print('Found ${voterSections.length} voter sections');
    
    for (final section in voterSections) {
      if (section.trim().isEmpty) continue;
      
      final voter = _parseSingleVoter(section);
      if (voter['name'] != null && voter['name'].toString().isNotEmpty) {
        voters.add(voter);
      }
    }
    
    // If pattern splitting didn't work, try line-based parsing
    if (voters.isEmpty) {
      return _parseLineByLine(text);
    }
    
    return voters;
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
    
    final lines = section.split('\n');
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      // Parse name - could be "নাম: ছাফা রহমান" or just after the number
      if (trimmed.contains('নাম:')) {
        voter['name'] = _extractAfterColon(trimmed, 'নাম:');
      } 
      // Parse father - look for "িপতা:" or "পিতা:"
      else if (trimmed.contains('িপতা:') || trimmed.contains('পিতা:')) {
        final father = trimmed.contains('িপতা:') 
            ? _extractAfterColon(trimmed, 'িপতা:')
            : _extractAfterColon(trimmed, 'পিতা:');
        voter['father'] = father;
      }
      // Parse mother
      else if (trimmed.contains('মাতা:')) {
        voter['mother'] = _extractAfterColon(trimmed, 'মাতা:');
      }
      // Parse date of birth and address (they're on the same line)
      else if (trimmed.contains('জ তািরখ:') || trimmed.contains('জন্ম তারিখ:')) {
        final dobAddressLine = trimmed;
        
        // Extract DOB - look for "জ তািরখ:" or "জন্ম তারিখ:"
        if (dobAddressLine.contains('জ তািরখ:')) {
          voter['dob'] = _extractBetween(dobAddressLine, 'জ তািরখ:', 'ঠিকানা:');
        } else if (dobAddressLine.contains('জন্ম তারিখ:')) {
          voter['dob'] = _extractBetween(dobAddressLine, 'জন্ম তারিখ:', 'ঠিকানা:');
        }
        
        // Extract address - look for "ঠিকানা:"
        if (dobAddressLine.contains('ঠিকানা:')) {
          final addressStart = dobAddressLine.indexOf('ঠিকানা:');
          if (addressStart != -1) {
            voter['address'] = dobAddressLine.substring(addressStart + 'ঠিকানা:'.length).trim();
          }
        }
      }
      // Alternative DOB pattern
      else if (trimmed.contains('তারিখ:')) {
        voter['dob'] = _extractAfterColon(trimmed, 'তারিখ:');
      }
    }
    
    return voter;
  }
  
  static String? _extractAfterColon(String line, String keyword) {
    try {
      final index = line.indexOf(keyword);
      if (index == -1) return null;
      
      String value = line.substring(index + keyword.length).trim();
      
      // Remove any trailing commas or other punctuation
      value = value.replaceAll(RegExp(r'[.,;।]$'), '');
      
      // If there's another keyword after this, cut there
      final keywords = ['নাম:', 'িপতা:', 'পিতা:', 'মাতা:', 'তারিখ:', 'ঠিকানা:', 'ভাটার'];
      for (final kw in keywords) {
        if (value.contains(kw) && kw != keyword) {
          final kwIndex = value.indexOf(kw);
          if (kwIndex > 0) {
            value = value.substring(0, kwIndex).trim();
          }
        }
      }
      
      return value.isNotEmpty ? value : null;
    } catch (e) {
      return null;
    }
  }
  
  static String? _extractBetween(String line, String startKeyword, String endKeyword) {
    try {
      final startIndex = line.indexOf(startKeyword);
      if (startIndex == -1) return null;
      
      final endIndex = line.indexOf(endKeyword, startIndex + startKeyword.length);
      if (endIndex == -1) return line.substring(startIndex + startKeyword.length).trim();
      
      return line.substring(startIndex + startKeyword.length, endIndex).trim();
    } catch (e) {
      return null;
    }
  }
  
  // Fallback parsing method
  static List<Map<String, dynamic>> _parseLineByLine(String text) {
    final List<Map<String, dynamic>> voters = [];
    final lines = text.split('\n');
    
    Map<String, dynamic> currentVoter = {};
    bool expectingName = true;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      // Check if this line starts a new voter (contains a serial number)
      if (RegExp(r'^\d{3,4}\.').hasMatch(line) || 
          (line.contains('নাম:') && currentVoter.isNotEmpty)) {
        
        // Save previous voter if we have one
        if (currentVoter.containsKey('name') && currentVoter['name'] != null) {
          voters.add(Map.from(currentVoter));
        }
        
        currentVoter = {};
        expectingName = true;
      }
      
      // Try to extract name
      if (expectingName && line.contains('নাম:')) {
        currentVoter['name'] = _extractAfterColon(line, 'নাম:');
        expectingName = false;
      }
      // Extract father (handle both "িপতা:" and "পিতা:")
      else if (line.contains('িপতা:') || line.contains('পিতা:')) {
        if (line.contains('িপতা:')) {
          currentVoter['father'] = _extractAfterColon(line, 'িপতা:');
        } else {
          currentVoter['father'] = _extractAfterColon(line, 'পিতা:');
        }
      }
      // Extract mother
      else if (line.contains('মাতা:')) {
        currentVoter['mother'] = _extractAfterColon(line, 'মাতা:');
      }
      // Extract DOB - handle various patterns
      else if (line.contains('জ তািরখ:') || 
               line.contains('জন্ম তারিখ:') || 
               line.contains('তারিখ:')) {
        
        String? dob;
        if (line.contains('জ তািরখ:')) {
          dob = _extractAfterColon(line, 'জ তািরখ:');
        } else if (line.contains('জন্ম তারিখ:')) {
          dob = _extractAfterColon(line, 'জন্ম তারিখ:');
        } else {
          dob = _extractAfterColon(line, 'তারিখ:');
        }
        
        if (dob != null) {
          // Clean up DOB - remove any address part
          final addressIndex = dob.indexOf('ঠিকানা:');
          if (addressIndex != -1) {
            dob = dob.substring(0, addressIndex).trim();
          }
          currentVoter['dob'] = dob;
        }
        
        // Also try to extract address from same line
        if (line.contains('ঠিকানা:')) {
          final addressStart = line.indexOf('ঠিকানা:');
          if (addressStart != -1) {
            currentVoter['address'] = line.substring(addressStart + 'ঠিকানা:'.length).trim();
          }
        }
      }
    }
    
    // Don't forget the last voter
    if (currentVoter.containsKey('name') && currentVoter['name'] != null) {
      voters.add(Map.from(currentVoter));
    }
    
    return voters;
  }
}