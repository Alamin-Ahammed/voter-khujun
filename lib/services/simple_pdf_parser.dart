import 'dart:io';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class SimplePdfParser {
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
      
      // Split by lines
      final lines = allText.split('\n');
      final List<Map<String, dynamic>> voters = [];
      
      Map<String, dynamic> currentVoter = {};
      
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        
        // Look for patterns in the line
        if (trimmed.contains('নাম')) {
          // If we have a previous voter with name, save it
          if (currentVoter.containsKey('name') && currentVoter['name'] != null) {
            voters.add(Map.from(currentVoter));
            currentVoter.clear();
          }
          currentVoter['name'] = _extractValue(trimmed, 'নাম');
        } else if (trimmed.contains('পিতা')) {
          currentVoter['father'] = _extractValue(trimmed, 'পিতা');
        } else if (trimmed.contains('মাতা') || trimmed.contains('মা')) {
          currentVoter['mother'] = _extractValue(trimmed, 'মাতা') ?? 
                                  _extractValue(trimmed, 'মা');
        } else if (trimmed.contains('জন্ম তারিখ') || trimmed.contains('জন্মতারিখ')) {
          currentVoter['dob'] = _extractValue(trimmed, 'জন্ম তারিখ') ??
                               _extractValue(trimmed, 'জন্মতারিখ');
        } else if (trimmed.contains('ওয়ার্ড')) {
          currentVoter['ward'] = _extractValue(trimmed, 'ওয়ার্ড') ??
                                _extractValue(trimmed, 'ওয়ার্ড নং');
        } else if (trimmed.contains('ঠিকানা')) {
          currentVoter['address'] = _extractValue(trimmed, 'ঠিকানা');
        }
        
        // If we have a complete voter, add it
        if (currentVoter.containsKey('name') && 
            currentVoter.containsKey('father') &&
            !voters.any((v) => v['name'] == currentVoter['name'] && 
                              v['father'] == currentVoter['father'])) {
          voters.add(Map.from(currentVoter));
          currentVoter.clear();
        }
      }
      
      // Don't forget the last voter
      if (currentVoter.isNotEmpty) {
        voters.add(Map.from(currentVoter));
      }
      
      print('Voters found: ${voters.length}');
      if (voters.isNotEmpty) {
        print('Sample voter: ${voters.first}');
      }
      
      return voters;
    } catch (e) {
      print('Simple parser error: $e');
      return [];
    }
  }
  
  static String? _extractValue(String line, String field) {
    try {
      // Remove field name and get what's after
      final index = line.indexOf(field);
      if (index == -1) return null;
      
      String value = line.substring(index + field.length).trim();
      
      // Remove colon if present
      if (value.startsWith(':') || value.startsWith('：')) {
        value = value.substring(1).trim();
      }
      
      // Take until end or next field indicator
      final fieldIndicators = ['নাম', 'পিতা', 'মাতা', 'জন্ম', 'ওয়ার্ড', 'ঠিকানা'];
      for (final indicator in fieldIndicators) {
        if (value.contains(indicator) && indicator != field) {
          value = value.substring(0, value.indexOf(indicator)).trim();
        }
      }
      
      return value.isNotEmpty ? value : null;
    } catch (e) {
      return null;
    }
  }
}