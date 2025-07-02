import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/league.dart';
import '../models/team.dart';

class ApiService {
  static const String sportsDbApiKey = '859598';
  static const String baseUrl = 'https://www.thesportsdb.com/api/v1/json';

  // Pobierz wszystkie ligi
  static Future<List<League>> fetchLeagues() async {
    final url = Uri.parse('$baseUrl/$sportsDbApiKey/all_leagues.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['leagues'] == null) return [];
      
      return (data['leagues'] as List)
          .map((json) => League.fromJson(json))
          .toList();
    } else {
      throw Exception('Nie udało się pobrać lig. Status: ${response.statusCode}');
    }
  }

  // Pobierz drużyny w lidze
  static Future<List<Team>> fetchTeams(String leagueName) async {
    final encodedName = Uri.encodeComponent(leagueName);
    final url = Uri.parse('$baseUrl/$sportsDbApiKey/search_all_teams.php?l=$encodedName');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['teams'] == null) return [];
      
      return (data['teams'] as List)
          .where((team) => team['strTeam'] != null && team['idTeam'] != null)
          .map((json) => Team.fromJson(json))
          .toList();
    } else {
      throw Exception('Nie udało się pobrać drużyn. Status: ${response.statusCode}');
    }
  }

  // Ostatnie mecze drużyny - bez strzelców bramek
  static Future<List<Map<String, String>>> fetchLastEvents(String teamId) async {
    final url = Uri.parse('$baseUrl/$sportsDbApiKey/eventslast.php?id=$teamId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] == null) return [];
      
      return (data['results'] as List)
          .take(5)
          .map<Map<String, String>>((e) {
            final date = e['dateEvent'] ?? '';
            final time = e['strTime'] ?? '';
            final homeGoals = e['intHomeScore']?.toString() ?? '0';
            final awayGoals = e['intAwayScore']?.toString() ?? '0';
            
            // Formatuj datę
            final dateTime = DateTime.tryParse('$date $time') ?? DateTime.now();
            final formattedDate = '${_formatDate(dateTime)}';
            final formattedTime = '${_formatTime(dateTime)}';
            
            return {
              'title': '${e['strHomeTeam']} vs ${e['strAwayTeam']}',
              'score': '$homeGoals : $awayGoals',
              'date': '$formattedDate',
              'time': '$formattedTime',
              'competition': e['strLeague']?.toString() ?? 'Brak danych',
            };
          })
          .toList();
    } else {
      throw Exception('Nie udało się pobrać ostatnich meczów');
    }
  }

  // Nadchodzące mecze drużyny
  static Future<List<Map<String, String>>> fetchNextEvents(String teamId) async {
    final url = Uri.parse('$baseUrl/$sportsDbApiKey/eventsnext.php?id=$teamId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['events'] == null) return [];
      
      return (data['events'] as List)
          .take(5)
          .map<Map<String, String>>((e) {
            final date = e['dateEvent'] ?? '';
            final time = e['strTime'] ?? '00:00';
            final dateTime = DateTime.tryParse('$date $time') ?? DateTime.now();
            
            return {
              'title': '${e['strHomeTeam']} vs ${e['strAwayTeam']}',
              'date': '${_formatDate(dateTime)}',
              'time': '${_formatTime(dateTime)}',
              'competition': e['strLeague']?.toString() ?? 'Brak danych',
            };
          })
          .toList();
    } else {
      throw Exception('Nie udało się pobrać nadchodzących meczów');
    }
  }

  // Skład drużyny
  static Future<List<Map<String, String>>> fetchTeamPlayers(String teamId) async {
    final url = Uri.parse('$baseUrl/$sportsDbApiKey/lookup_all_players.php?id=$teamId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['player'] == null) return [];
      
      final List players = data['player'] as List;
      
      // Oddziel menadżerów od zawodników
      final managers = players.where((p) {
        final position = (p['strPosition']?.toString() ?? '').toLowerCase();
        return position.contains('manager') || position.contains('coach');
      });
      
      final otherPlayers = players.where((p) {
        final position = (p['strPosition']?.toString() ?? '').toLowerCase();
        return !position.contains('manager') && !position.contains('coach');
      });
      
      return [
        ...managers.map<Map<String, String>>((p) => _mapPlayer(p, true)),
        ...otherPlayers.map<Map<String, String>>((p) => _mapPlayer(p, false)),
      ];
    } else {
      throw Exception('Nie udało się pobrać składu drużyny');
    }
  }

  static Map<String, String> _mapPlayer(dynamic p, bool isManager) {
    return {
      'name': p['strPlayer']?.toString() ?? 'Nieznany',
      'position': p['strPosition']?.toString() ?? 'Brak danych',
      'number': p['strNumber']?.toString() ?? '',
      'nationality': p['strNationality']?.toString() ?? '',
      'isManager': isManager.toString(),
    };
  }

  // Metody pomocnicze do formatowania daty
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}