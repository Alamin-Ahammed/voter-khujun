import '../models/voter_model.dart';

class SearchResult {
  final VoterModel voter;
  final int score;
  final Map<String, bool> matches;

  SearchResult({
    required this.voter,
    required this.score,
    required this.matches,
  });
}

class SearchService {
  static List<SearchResult> searchAndRank(
    List<VoterModel> voters,
    SearchQuery query,
  ) {
    final List<SearchResult> results = [];

    for (final voter in voters) {
      final matches = findMatches(voter, query);
      final score = calculateScore(voter, query, matches);
      
      // DEBUG
      print('Voter: ${voter.name} - Score: $score');
      print('Matches: $matches');
      
      results.add(SearchResult(
        voter: voter,
        score: score,
        matches: matches,
      ));
    }

    // Filter with lower threshold for MVP
    final filtered = results
      .where((result) => result.score >= 30) // Lower threshold for testing
      .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    
    print('Filtered ${results.length} to ${filtered.length} results');
    
    return filtered;
  }

  static int calculateScore(VoterModel voter, SearchQuery query, Map<String, bool> matches) {
    int score = 0;

    // Give points for matches
    if (matches['name'] == true) score += 40;
    if (matches['father'] == true) score += 40;
    if (matches['mother'] == true) score += 20;
    if (matches['dob'] == true) score += 50;
    if (matches['ward'] == true) score += 10;

    // Bonus for exact name+father combination
    if (matches['name'] == true && matches['father'] == true) {
      score += 30;
    }

    return score;
  }

  static Map<String, bool> findMatches(VoterModel voter, SearchQuery query) {
    return {
      'name': query.name != null && 
              query.name!.isNotEmpty && 
              _containsIgnoreCase(voter.name, query.name!),
      'father': query.father != null && 
                query.father!.isNotEmpty && 
                _containsIgnoreCase(voter.father, query.father!),
      'mother': query.mother != null && 
                query.mother!.isNotEmpty && 
                _containsIgnoreCase(voter.mother, query.mother!),
      'dob': query.dob != null && 
             query.dob!.isNotEmpty && 
             voter.dob.contains(query.dob!),
      'ward': query.ward != null && 
              query.ward!.isNotEmpty && 
              voter.ward.contains(query.ward!),
    };
  }
  
  static bool _containsIgnoreCase(String source, String substring) {
    return source.toLowerCase().contains(substring.toLowerCase());
  }
}