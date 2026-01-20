import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'pdf_service.dart';

class FolderPdfService {
  // Find all PDF files recursively in a folder
  static Future<List<File>> findPdfFilesInFolder(String folderPath) async {
    final List<File> pdfFiles = [];
    final Directory directory = Directory(folderPath);
    
    if (!await directory.exists()) {
      print('Directory does not exist: $folderPath');
      return pdfFiles;
    }
    
    try {
      // Recursively list all files
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
          pdfFiles.add(entity);
        }
      }
      
      print('Found ${pdfFiles.length} PDF files in folder');
      return pdfFiles;
    } catch (e) {
      print('Error scanning folder: $e');
      return pdfFiles;
    }
  }

  // Extract voters from all PDFs in a folder
  static Future<List<Map<String, dynamic>>> extractVotersFromFolder(String folderPath) async {
    final List<Map<String, dynamic>> allVoters = [];
    
    // Find all PDF files
    final pdfFiles = await findPdfFilesInFolder(folderPath);
    
    if (pdfFiles.isEmpty) {
      print('No PDF files found in folder');
      return allVoters;
    }
    
    print('Processing ${pdfFiles.length} PDF files...');
    
    // Process each PDF file
    for (int i = 0; i < pdfFiles.length; i++) {
      final file = pdfFiles[i];
      print('Processing file ${i + 1}/${pdfFiles.length}: ${p.basename(file.path)}');
      
      try {
        // Extract voters from this PDF
        final voters = await PdfService.extractVotersFromPdf(file.path);
        
        // Add ward information from folder structure if available
        final enhancedVoters = _enhanceVotersWithFolderInfo(voters, file.path);
        allVoters.addAll(enhancedVoters);
        
        print('  → Found ${voters.length} voters (Total: ${allVoters.length})');
      } catch (e) {
        print('  → Error processing ${p.basename(file.path)}: $e');
      }
    }
    
    print('=== TOTAL VOTERS EXTRACTED ===');
    print('From ${pdfFiles.length} PDF files: ${allVoters.length} voters');
    
    return allVoters;
  }

  // Extract ward information from folder path
  static List<Map<String, dynamic>> _enhanceVotersWithFolderInfo(
    List<Map<String, dynamic>> voters,
    String filePath,
  ) {
    if (voters.isEmpty) return voters;
    
    // Try to extract ward number from folder names
    String? wardFromPath = _extractWardFromPath(filePath);
    
    // Try to extract gender from folder names
    String? genderFromPath = _extractGenderFromPath(filePath);
    
    // Enhance each voter with folder info
    return voters.map((voter) {
      final enhanced = Map<String, dynamic>.from(voter);
      
      // If voter doesn't have ward, add from folder path
      if ((enhanced['ward'] == null || 
           enhanced['ward'].toString().isEmpty) && 
          wardFromPath != null) {
        enhanced['ward'] = wardFromPath;
      }
      
      // Add gender if found in path
      if (genderFromPath != null) {
        enhanced['gender'] = genderFromPath;
      }
      
      // Add source file info for debugging
      enhanced['source_file'] = p.basename(filePath);
      
      return enhanced;
    }).toList();
  }

  static String? _extractWardFromPath(String path) {
    // Common patterns for ward in folder names
    final wardPatterns = [
      RegExp(r'ward[-_\s]*(\d+)', caseSensitive: false),
      RegExp(r'ওয়ার্ড[-_\s]*(\d+)'),
      RegExp(r'ward[-_\s]*(\d+)', caseSensitive: false),
      RegExp(r'(\d+)[-_\s]*ward', caseSensitive: false),
      RegExp(r'(\d+)[-_\s]*ওয়ার্ড'),
    ];
    
    for (final pattern in wardPatterns) {
      final match = pattern.firstMatch(path.toLowerCase());
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }
    
    // Try to find any number that might be a ward
    final anyNumber = RegExp(r'(\d{1,3})').firstMatch(path);
    if (anyNumber != null) {
      final num = int.tryParse(anyNumber.group(1)!);
      if (num != null && num > 0 && num < 100) {
        return anyNumber.group(1)!;
      }
    }
    
    return null;
  }

  static String? _extractGenderFromPath(String path) {
    final lowerPath = path.toLowerCase();
    
    if (lowerPath.contains('male') || 
        lowerPath.contains('পুরুষ') ||
        lowerPath.contains('men') ||
        lowerPath.contains('বালক')) {
      return 'পুরুষ';
    } else if (lowerPath.contains('female') || 
               lowerPath.contains('মহিলা') ||
               lowerPath.contains('women') ||
               lowerPath.contains('বালিকা')) {
      return 'মহিলা';
    }
    
    return null;
  }

  // Quick analysis of folder structure
  static Future<void> analyzeFolderStructure(String folderPath) async {
    print('=== FOLDER STRUCTURE ANALYSIS ===');
    print('Root folder: $folderPath');
    
    final pdfFiles = await findPdfFilesInFolder(folderPath);
    print('Total PDF files: ${pdfFiles.length}');
    
    // Group by directory
    final Map<String, List<String>> dirMap = {};
    for (final file in pdfFiles) {
      final dir = p.dirname(file.path);
      dirMap.putIfAbsent(dir, () => []).add(p.basename(file.path));
    }
    
    print('\n=== DIRECTORY STRUCTURE ===');
    dirMap.forEach((dir, files) {
      print('$dir (${files.length} files):');
      for (final file in files.take(3)) {
        print('  - $file');
      }
      if (files.length > 3) {
        print('  ... and ${files.length - 3} more');
      }
    });
    
    // Sample some files to check content
    if (pdfFiles.isNotEmpty) {
      print('\n=== SAMPLE FILE ANALYSIS ===');
      for (int i = 0; i < min(2, pdfFiles.length); i++) {
        final file = pdfFiles[i];
        print('\nFile: ${p.basename(file.path)}');
        
        try {
          final text = await PdfService.extractTextFromPage(file.path, 0);
          print('First 200 chars: ${text.substring(0, min(200, text.length))}...');
          
          // Try to extract voters
          final voters = await PdfService.extractVotersFromPdf(file.path);
          print('Voters found: ${voters.length}');
          if (voters.isNotEmpty) {
            print('Sample voter: ${voters.first}');
          }
        } catch (e) {
          print('Error analyzing: $e');
        }
      }
    }
    
    print('===============================');
  }
}