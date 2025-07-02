import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/league.dart';
import '../models/team.dart';
import '../models/football_data_match.dart';

class ApiService {
  static const String FOOTBALL_DATA_API_KEY = '4c6fc3b8fbb1462b81662a9bcbb7a150';
  
  static Future<List<League>> fetchLeagues() async {
    final url = Uri.parse(
      'https://www.thesportsdb.com/api/v1/json/3/all_leagues.php',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List leagues = data['leagues'] ?? [];
      return leagues.map((json) => League.fromJson(json)).toList();
    } else {
      throw Exception('Nie udało się pobrać lig. Status: ${response.statusCode}');
    }
  }

  static Future<List<Team>> fetchTeams(String leagueName) async {
    final encodedLeagueName = Uri.encodeComponent(leagueName);
    final url = Uri.parse(
      'https://www.thesportsdb.com/api/v1/json/3/search_all_teams.php?l=$encodedLeagueName',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['teams'] == null) return [];
      
      final List teams = data['teams'];
      return teams
          .where((team) => team['strTeam'] != null && team['idTeam'] != null)
          .map((json) => Team.fromJson(json))
          .toList();
    } else {
      throw Exception('Nie udało się pobrać drużyn. Status: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, String>>> fetchLastEvents(
    String teamId,
  ) async {
    final url = Uri.parse(
      'https://www.thesportsdb.com/api/v1/json/3/eventslast.php?id=$teamId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List events = data['results'] ?? [];
      return events
          .take(5)
          .map<Map<String, String>>(
            (e) => {
              'title': '${e['strHomeTeam']} vs ${e['strAwayTeam']}',
              'score': '${e['intHomeScore']} : ${e['intAwayScore']}',
            },
          )
          .toList();
    } else {
      throw Exception('Nie udało się pobrać ostatnich meczów');
    }
  }

  static Future<List<Map<String, String>>> fetchNextEvents(
    String teamName,
  ) async {
    try {
      final url = Uri.parse('https://api.football-data.org/v4/matches');
      final response = await http.get(
        url,
        headers: {'X-Auth-Token': FOOTBALL_DATA_API_KEY},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List matches = data['matches'] ?? [];
        
        // Filtruj mecze dla konkretnej drużyny
        final teamMatches = matches.where((match) {
          final homeTeam = match['homeTeam']['name']?.toString() ?? '';
          final awayTeam = match['awayTeam']['name']?.toString() ?? '';
          return homeTeam.contains(teamName) || awayTeam.contains(teamName);
        }).toList();

        if (teamMatches.isEmpty) return _getFallbackMatches(teamName);

        return teamMatches.take(5).map<Map<String, String>>((matchJson) {
          final match = FootballDataMatch.fromJson(matchJson);
          final date = match.utcDate;
          final formattedDate = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
          final formattedTime = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
          
          return {
            'title': '${match.homeTeam} vs ${match.awayTeam}',
            'date': '$formattedDate o $formattedTime',
          };
        }).toList();
      } else {
        return _getFallbackMatches(teamName);
      }
    } catch (e) {
      return _getFallbackMatches(teamName);
    }
  }

  static List<Map<String, String>> _getFallbackMatches(String teamName) {
    return [
      {'title': '$teamName vs Rywal 1', 'date': '2025-08-15 o 18:00'},
      {'title': 'Rywal 2 vs $teamName', 'date': '2025-08-22 o 15:30'},
      {'title': '$teamName vs Rywal 3', 'date': '2025-08-29 o 20:45'},
    ];
  }

  static Future<List<Map<String, String>>> fetchTeamPlayers(
    String teamId,
  ) async {
    final url = Uri.parse(
      'https://www.thesportsdb.com/api/v1/json/3/lookup_all_players.php?id=$teamId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List players = data['player'] ?? [];
      return players
          .map<Map<String, String>>(
            (p) => {
              'name': p['strPlayer'] ?? '',
              'position': p['strPosition'] ?? '',
            },
          )
          .toList();
    } else {
      throw Exception('Nie udało się pobrać składu');
    }
  }
}