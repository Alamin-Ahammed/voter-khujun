import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../utils/bangla_text_utils.dart';

class PdfService {
  static Future<List<Map<String, dynamic>>> extractVotersFromPdf(String filePath) async {
    try {
      // Read PDF file as bytes
      final bytes = await File(filePath).readAsBytes();
      final Uint8List pdfBytes = bytes.buffer.asUint8List();
      
      // Load PDF document
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      
      String fullText = '';
      
      // Extract text from all pages
      for (int i = 0; i < document.pages.count; i++) {
        try {
          // Create text extractor
          final PdfTextExtractor extractor = PdfTextExtractor(document);
          
          // Extract text from specific page
          final pageText = extractor.extractText(startPageIndex: i);
          fullText += pageText + '\n';
          
          // Progress indicator in console
          if (i % 10 == 0) {
            print('Processing page ${i + 1}/${document.pages.count}');
          }
        } catch (e) {
          print('Error extracting page $i: $e');
          fullText += '\n'; // Add newline even if page extraction fails
        }
      }
      
      // Dispose the document
      document.dispose();
      
      print('Total text extracted: ${fullText.length} characters');
      
      // Parse voters from text
      final voters = _parseVotersFromText(fullText);
      
      print('Total voters parsed: ${voters.length}');
      if (voters.isNotEmpty) {
        print('First voter: ${voters.first['name']} - ${voters.first['father']}');
      }
      
      return voters;
    } catch (e) {
      print('Error extracting PDF: $e');
      rethrow;
    }
  }

  // Alternative method: Extract text from specific page
  static Future<String> extractTextFromPage(String filePath, int pageIndex) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final Uint8List pdfBytes = bytes.buffer.asUint8List();
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      
      // Ensure page index is valid
      if (pageIndex < 0 || pageIndex >= document.pages.count) {
        document.dispose();
        throw Exception('Invalid page index: $pageIndex');
      }
      
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String extractedText = extractor.extractText(startPageIndex: pageIndex);
      
      document.dispose();
      return extractedText;
    } catch (e) {
      print('Error extracting text from page $pageIndex: $e');
      rethrow;
    }
  }

  // Helper method to parse voters from text
  static List<Map<String, dynamic>> _parseVotersFromText(String text) {
    final List<Map<String, dynamic>> voters = [];
    
    // Split text by lines
    final lines = text.split('\n');
    
    String currentName = '';
    String currentFather = '';
    String currentMother = '';
    String currentDob = '';
    String currentWard = '';
    String currentAddress = '';
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      if (line.isEmpty) continue;
      
      // Try to extract each field
      final name = BanglaTextUtils.extract(line, 'name') ?? 
                  _extractAlternative(line, 'নাম') ?? currentName;
      
      final father = BanglaTextUtils.extract(line, 'father') ?? 
                    _extractAlternative(line, 'পিতা') ?? currentFather;
      
      final mother = BanglaTextUtils.extract(line, 'mother') ?? 
                    _extractAlternative(line, 'মাতা') ?? currentMother;
      
      final dob = BanglaTextUtils.extract(line, 'dob') ?? 
                 _extractAlternative(line, 'জন্ম তারিখ') ??
                 _extractAlternative(line, 'জন্মতারিখ') ?? currentDob;
      
      final ward = BanglaTextUtils.extract(line, 'ward') ?? 
                  _extractAlternative(line, 'ওয়ার্ড') ??
                  _extractAlternative(line, 'ওয়ার্ড নং') ?? currentWard;
      
      final address = BanglaTextUtils.extract(line, 'address') ?? 
                     _extractAlternative(line, 'ঠিকানা') ?? currentAddress;
      
      // Update current values if we found something
      if (name.isNotEmpty && name != currentName) currentName = name;
      if (father.isNotEmpty && father != currentFather) currentFather = father;
      if (mother.isNotEmpty && mother != currentMother) currentMother = mother;
      if (dob.isNotEmpty && dob != currentDob) currentDob = dob;
      if (ward.isNotEmpty && ward != currentWard) currentWard = ward;
      if (address.isNotEmpty && address != currentAddress) currentAddress = address;
      
      // If we have both name and father (essential fields), save as voter
      if (currentName.isNotEmpty && 
          currentFather.isNotEmpty && 
          currentName != currentFather) { // Avoid same string for name and father
        
        // Check if this voter is already added
        final exists = voters.any((v) => 
          v['name'] == currentName && v['father'] == currentFather);
        
        if (!exists && currentName.length > 1) { // Ensure name is valid
          voters.add({
            'name': currentName,
            'father': currentFather,
            'mother': currentMother,
            'dob': currentDob,
            'ward': currentWard,
            'address': currentAddress,
          });
          
          // Reset for next voter (keep ward as it might be same for multiple voters)
          currentName = '';
          currentFather = '';
          currentMother = '';
          currentDob = '';
          currentAddress = '';
        }
      }
    }
    
    print('Parsed ${voters.length} voters from text');
    
    // If no voters found, try alternative parsing method
    if (voters.isEmpty) {
      return _parseVotersAlternative(text);
    }
    
    return voters;
  }

  // Alternative extraction method for different label formats
  static String? _extractAlternative(String text, String label) {
    // Try different patterns
    final patterns = [
      RegExp('$label[:：]\\s*(.*?)(?=\\n|\$|,|;)'),
      RegExp('$label\\s*[:：]\\s*(.*?)(?=\\n|\$|,|;)'),
      RegExp('$label\\s*(.*?)(?=\\n|\$)'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }
    
    return null;
  }

  // Fallback parsing method if primary method fails
  static List<Map<String, dynamic>> _parseVotersAlternative(String text) {
    final List<Map<String, dynamic>> voters = [];
    
    // Split by double newlines (common pattern for separate entries)
    final entries = text.split(RegExp(r'\n\s*\n'));
    
    for (final entry in entries) {
      if (entry.trim().isEmpty) continue;
      
      final lines = entry.split('\n');
      
      String name = '';
      String father = '';
      String mother = '';
      String dob = '';
      String ward = '';
      String address = '';
      
      for (final line in lines) {
        final trimmedLine = line.trim();
        
        // Check for each field in the line
        if (trimmedLine.contains('নাম') && name.isEmpty) {
          name = _extractFromLine(trimmedLine, 'নাম');
        } else if (trimmedLine.contains('পিতা') && father.isEmpty) {
          father = _extractFromLine(trimmedLine, 'পিতা');
        } else if ((trimmedLine.contains('মাতা') || trimmedLine.contains('মা')) && mother.isEmpty) {
          mother = _extractFromLine(trimmedLine, 'মাতা') ?? 
                  _extractFromLine(trimmedLine, 'মা') ?? '';
        } else if ((trimmedLine.contains('জন্ম') || trimmedLine.contains('তারিখ')) && dob.isEmpty) {
          dob = _extractFromLine(trimmedLine, 'জন্ম তারিখ') ??
               _extractFromLine(trimmedLine, 'জন্মতারিখ') ??
               _extractFromLine(trimmedLine, 'জন্ম') ??
               _extractFromLine(trimmedLine, 'তারিখ') ??
               '';
        } else if (trimmedLine.contains('ওয়ার্ড') && ward.isEmpty) {
          ward = _extractFromLine(trimmedLine, 'ওয়ার্ড') ??
                _extractFromLine(trimmedLine, 'ওয়ার্ড নং') ??
                '';
        } else if (trimmedLine.contains('ঠিকানা') && address.isEmpty) {
          address = _extractFromLine(trimmedLine, 'ঠিকানা');
        }
      }
      
      // Only add if we have name and father
      if (name.isNotEmpty && father.isNotEmpty) {
        voters.add({
          'name': name,
          'father': father,
          'mother': mother,
          'dob': dob,
          'ward': ward,
          'address': address,
        });
      }
    }
    
    return voters;
  }

  static String _extractFromLine(String line, String field) {
    final index = line.indexOf(field);
    if (index == -1) return '';
    
    // Get text after the field name
    String remaining = line.substring(index + field.length).trim();
    
    // Remove any trailing colon or separator
    if (remaining.startsWith(':') || remaining.startsWith('：')) {
      remaining = remaining.substring(1).trim();
    }
    
    // Take until end of line or next separator
    final separators = [',', ';', '।', '|', '\t'];
    for (final sep in separators) {
      if (remaining.contains(sep)) {
        remaining = remaining.split(sep)[0].trim();
      }
    }
    
    return remaining;
  }
}