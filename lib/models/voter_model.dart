class VoterModel {
  final int id;
  final String name;
  final String father;
  final String mother;
  final String dob;
  final String ward;
  final String address;

  VoterModel({
    required this.id,
    required this.name,
    required this.father,
    required this.mother,
    required this.dob,
    required this.ward,
    required this.address,
  });

  // Factory method to create from map
  factory VoterModel.fromMap(Map<String, dynamic> map) {
    return VoterModel(
      id: map['id'] as int,
      name: map['name'] as String,
      father: map['father'] as String,
      mother: map['mother'] as String,
      dob: map['dob'] as String,
      ward: map['ward'] as String,
      address: map['address'] as String,
    );
  }

  // Method to convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'father': father,
      'mother': mother,
      'dob': dob,
      'ward': ward,
      'address': address,
    };
  }
}

class SearchQuery {
  final String? name;
  final String? father;
  final String? mother;
  final String? dob;
  final String? ward;

  SearchQuery({
    this.name,
    this.father,
    this.mother,
    this.dob,
    this.ward,
  });

  bool get isEmpty => name == null && father == null && mother == null && dob == null && ward == null;
}