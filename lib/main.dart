import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/pdf_picker_screen.dart';
import 'screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voter Khujun',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const InitialScreen(),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  bool _isPdfSelected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFolderStatus();
  }

  Future<void> _checkFolderStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasFolder = prefs.containsKey('folder_path');

    setState(() {
      _isPdfSelected = hasFolder;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isPdfSelected ? const SearchScreen() : const PdfPickerScreen();
  }
}
