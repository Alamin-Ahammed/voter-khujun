import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

class Voters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get father => text()();
  TextColumn get mother => text()();
  TextColumn get dob => text()();
  TextColumn get ward => text()();
  TextColumn get address => text()();
}

@DriftDatabase(tables: [Voters])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Helper method to convert VoterModel to VotersCompanion
  VotersCompanion _toCompanion(Map<String, dynamic> voter) {
    return VotersCompanion.insert(
      name: voter['name'] ?? '',
      father: voter['father'] ?? '',
      mother: voter['mother'] ?? '',
      dob: voter['dob'] ?? '',
      ward: voter['ward'] ?? '',
      address: voter['address'] ?? '',
    );
  }

  Future<void> insertVoters(List<Map<String, dynamic>> votersList) async {
    // Convert list of maps to list of VotersCompanion
    final companions = votersList.map(_toCompanion).toList();

    // Use batch insert
    await batch((batch) {
      batch.insertAll(voters, companions);
    });
  }

  // Single voter insert
  Future<void> insertVoter(Map<String, dynamic> voter) async {
    await into(voters).insert(_toCompanion(voter));
  }

  // Search with basic query
  Future<List<Map<String, dynamic>>> searchVoters(String query) async {
    final results = await (select(voters)
          ..where((t) =>
              t.name.contains(query) |
              t.father.contains(query) |
              t.mother.contains(query) |
              t.ward.contains(query) |
              t.dob.contains(query))
          ..limit(100))
        .get();

    return results.map(_fromRow).toList();
  }

  // Advanced search
  Future<List<Map<String, dynamic>>> searchAdvanced({
    String? name,
    String? father,
    String? mother,
    String? dob,
    String? ward,
  }) async {
    var query = select(voters);

    if (name != null && name.isNotEmpty) {
      query = query..where((t) => t.name.like('%$name%'));
    }
    if (father != null && father.isNotEmpty) {
      query = query..where((t) => t.father.like('%$father%'));
    }
    if (mother != null && mother.isNotEmpty) {
      query = query..where((t) => t.mother.like('%$mother%'));
    }
    if (dob != null && dob.isNotEmpty) {
      query = query..where((t) => t.dob.like('%$dob%'));
    }
    if (ward != null && ward.isNotEmpty) {
      query = query..where((t) => t.ward.like('%$ward%'));
    }

    final results = await query.get();
    return results.map(_fromRow).toList();
  }

  // Convert database row to map
  Map<String, dynamic> _fromRow(Voter row) {
    return {
      'id': row.id,
      'name': row.name,
      'father': row.father,
      'mother': row.mother,
      'dob': row.dob,
      'ward': row.ward,
      'address': row.address,
    };
  }

  // Get voter count
  Future<int> getVoterCount() async {
    final count = await select(voters).get();
    return count.length;
  }

  // Clear all data
  Future<void> clearAll() async {
    await delete(voters).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'voters.db'));
    return NativeDatabase(file);
  });
}
