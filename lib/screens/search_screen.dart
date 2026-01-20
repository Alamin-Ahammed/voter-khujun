import 'package:flutter/material.dart';
import '../models/voter_model.dart';
import '../services/search_service.dart';
import '../data/database.dart';
import '../utils/bangla_text_utils.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherController = TextEditingController();
  final TextEditingController _motherController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();

  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  late AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  Future<void> _performSearch() async {
  if (_isSearching) {
    return;
  }
  if (_nameController.text.isEmpty &&
      _fatherController.text.isEmpty &&
      _motherController.text.isEmpty &&
      _dobController.text.isEmpty &&
      _wardController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter at least one search term')),
    );
    return;
  }

  setState(() => _isSearching = true);

  try {
    final query = SearchQuery(
      name: _nameController.text.trim(),
      father: _fatherController.text.trim(),
      mother: _motherController.text.trim(),
      dob: _dobController.text.trim(),
      ward: _wardController.text.trim(),
    );

    print('=== SEARCH DEBUG ===');
    print('Search query: name="${query.name}", father="${query.father}"');
    print('Search fields: mother="${query.mother}", dob="${query.dob}", ward="${query.ward}"');

    // Get voters from database
    final dbResults = await _db.searchAdvanced(
      name: query.name,
      father: query.father,
      mother: query.mother,
      dob: query.dob,
      ward: query.ward,
    );

    print('Database returned ${dbResults.length} results');
    if (dbResults.isNotEmpty) {
      print('First DB result: ${dbResults.first}');
    }

    // Convert to VoterModel list
    final allVoters = dbResults.map((map) => VoterModel.fromMap(map)).toList();
    print('Converted to ${allVoters.length} VoterModel objects');

    // Rank and filter results
    final results = SearchService.searchAndRank(allVoters, query);
    
    print('After ranking: ${results.length} results');
    if (results.isNotEmpty) {
      print('First ranked result:');
      print('  Name: ${results.first.voter.name}');
      print('  Father: ${results.first.voter.father}');
      print('  Score: ${results.first.score}');
      print('  Matches: ${results.first.matches}');
    }

    setState(() {
      _searchResults = results;
    });
    
    print('UI updated with ${_searchResults.length} results');
    print('=== END SEARCH DEBUG ===');

  } catch (e) {
    print('Search error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Search error: $e')),
    );
  } finally {
    setState(() => _isSearching = false);
  }
}

  void _clearSearch() {
    _nameController.clear();
    _fatherController.clear();
    _motherController.clear();
    _dobController.clear();
    _wardController.clear();
    setState(() => _searchResults.clear());
  }

  Widget _buildHighlightedText(String text, bool isMatched) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: isMatched ? FontWeight.bold : FontWeight.normal,
        backgroundColor: isMatched ? Colors.yellow : Colors.transparent,
        color: isMatched ? Colors.black : Colors.black87,
      ),
    );
  }

  Widget _buildVoterCard(SearchResult result) {
    final voter = result.voter;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildHighlightedText(
                    'নাম: ${voter.name}',
                    result.matches['name'] == true,
                  ),
                ),
                Chip(
                  label: Text(
                    'Score: ${result.score}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor:
                      result.score >= 100 ? Colors.green : Colors.blue,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildHighlightedText(
              'পিতা: ${voter.father}',
              result.matches['father'] == true,
            ),
            const SizedBox(height: 4),
            _buildHighlightedText(
              'মাতা: ${voter.mother}',
              result.matches['mother'] == true,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildHighlightedText(
                  'জন্ম তারিখ: ${voter.dob}',
                  result.matches['dob'] == true,
                ),
                const Spacer(),
                _buildHighlightedText(
                  'ওয়ার্ড: ${voter.ward}',
                  result.matches['ward'] == true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ঠিকানা: ${voter.address}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Voters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearSearch,
            tooltip: 'Clear search',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Form
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'নাম',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _fatherController,
                  decoration: const InputDecoration(
                    labelText: 'পিতার নাম',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.man),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _motherController,
                  decoration: const InputDecoration(
                    labelText: 'মাতার নাম',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.woman),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _dobController,
                        decoration: const InputDecoration(
                          labelText: 'জন্ম তারিখ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _wardController,
                        decoration: const InputDecoration(
                          labelText: 'ওয়ার্ড নং',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _performSearch,
                        icon: const Icon(Icons.search),
                        label: Text(_isSearching ? 'Searching...' : 'Search'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results Section
          if (_searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Found ${_searchResults.length} results (showing exact matches only)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),

          // Results List
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 80, color: Colors.grey),
                            SizedBox(height: 20),
                            Text(
                              'Enter search terms to find voters\n\nTip: Try searching by name + father name for best results',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return _buildVoterCard(_searchResults[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
