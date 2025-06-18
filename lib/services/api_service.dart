import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/league.dart';
import '../models/team.dart';

class ApiService {
  static Future<List<League>> fetchLeagues() async {
    final url = Uri.parse(
      'https://www.thesportsdb.com/api/v1/json/3/all_leagues.php',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List leagues = data['leagues'];
      return leagues.map((json) => League.fromJson(json)).toList();
    } else {
      throw Exception('Nie udało się pobrać lig');
    }
  }

  static Future<List<Team>> fetchTeams(String leagueName) async {
    final url = Uri.parse(
      'https://www.thesportsdb.com/api/v1/json/3/search_all_teams.php?l=$leagueName',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List teams = data['teams'];
      return teams.map((json) => Team.fromJson(json)).toList();
    } else {
      throw Exception('Nie udało się pobrać drużyn');
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
    String teamId,
  ) async {
    final url = Uri.parse(
      'https://www.thesportsdb.com/api/v1/json/3/eventsnext.php?id=$teamId',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List events = data['events'] ?? [];
      return events
          .take(5)
          .map<Map<String, String>>(
            (e) => {
              'title': '${e['strHomeTeam']} vs ${e['strAwayTeam']}',
              'date': '${e['dateEvent']} o ${e['strTime']}',
            },
          )
          .toList();
    } else {
      throw Exception('Nie udało się pobrać nadchodzących meczów');
    }
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
