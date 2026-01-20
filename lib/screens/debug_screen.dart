import 'package:flutter/material.dart';
import '../data/database.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final AppDatabase _db = AppDatabase();
  List<Map<String, dynamic>> _voters = [];
  int _count = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      _count = await _db.getVoterCount();
      _voters = await _db.searchVoters('');
      setState(() => _loading = false);
    } catch (e) {
      print('Debug error: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebugScreen()),
              );
            },
            tooltip: 'Debug Database',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Database Status',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Text('Total voters: $_count'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            await _db.clearAll();
                            _loadData();
                          },
                          child: const Text('Clear Database'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _voters.length,
                    itemBuilder: (context, index) {
                      final voter = _voters[index];
                      return ListTile(
                        title: Text(voter['name'] ?? 'No Name'),
                        subtitle: Text(voter['father'] ?? 'No Father'),
                        trailing: Text('ID: ${voter['id']}'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Voter Details'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('নাম: ${voter['name']}'),
                                    Text('পিতা: ${voter['father']}'),
                                    Text('মাতা: ${voter['mother']}'),
                                    Text('জন্ম তারিখ: ${voter['dob']}'),
                                    Text('ওয়ার্ড: ${voter['ward']}'),
                                    Text('ঠিকানা: ${voter['address']}'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
