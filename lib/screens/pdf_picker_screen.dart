import 'dart:math';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voter_khujun/services/best_pdf_parsar_1.dart';
import 'package:voter_khujun/services/enhanced_parser.dart';
import 'package:voter_khujun/services/simple_pdf_parser.dart';
import 'package:voter_khujun/services/voter_pdf_parser.dart';
import '../services/pdf_service.dart';
import '../data/database.dart';
import 'search_screen.dart';

class PdfPickerScreen extends StatefulWidget {
  const PdfPickerScreen({super.key});

  @override
  State<PdfPickerScreen> createState() => _PdfPickerScreenState();
}

class _PdfPickerScreenState extends State<PdfPickerScreen> {
  bool _isProcessing = false;
  String _status = '';

  Future<void> _pickAndProcessPdf() async {
    try {
      setState(() {
        _isProcessing = true;
        _status = 'Selecting PDF...';
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) {
        setState(() {
          _isProcessing = false;
          _status = 'No file selected';
        });
        return;
      }

      final filePath = result.files.single.path!;

      setState(() => _status = 'Extracting text from PDF...');

      // Extract voters from PDF
      List<Map<String, dynamic>> voters =
          await SimplePdfParserTest.parseVoters(filePath);

      // ADD THIS DEBUGGING
      print('=== DEBUG: Raw voters list ===');
      print('Number of voters parsed: ${voters.length}');
      if (voters.isNotEmpty) {
        print('First 3 voters:');
        for (int i = 0; i < (voters.length > 3 ? 3 : voters.length); i++) {
          print('Voter $i: ${voters[i]}');
        }
      } else {
        print('NO VOTERS PARSED!');
      }
      print('===========================');

      setState(() =>
          _status = 'Storing in database... ${voters.length} voters found');

      // Store in database
      final db = AppDatabase();
      try {
        // Clear existing data
        await db.clearAll();

        // Insert voters - use batch insert for efficiency
        if (voters.isNotEmpty) {
          await db.insertVoters(voters);

          // Get count and verify
          final count = await db.getVoterCount();
          print('=== DEBUG: Database count ===');
          print('Records in database: $count');
          print('===========================');

          setState(() => _status = 'Complete! $count voters loaded');
        } else {
          setState(() =>
              _status = 'Error: No voters found in PDF. Check PDF format.');
          return;
        }
      } finally {
        // ALWAYS close database in finally block
        await db.close();
      }

      // Save PDF path for future reference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pdf_path', filePath);

      // Navigate to search screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      }
    } catch (e) {
      print('Error in PDF processing: $e');
      setState(() {
        _status = 'Error: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Voter PDF'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              size: 100,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Voter List Search',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Select a Bangla PDF file containing voter list\n(200 pages with name, father name, mother name, DOB, address)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            if (_status.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        _status.contains('Error') ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickAndProcessPdf,
              icon: const Icon(Icons.upload_file),
              label: Text(_isProcessing ? 'Processing...' : 'Select PDF'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
