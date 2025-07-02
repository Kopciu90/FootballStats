import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team.dart';

class FavoritesProvider with ChangeNotifier {
  List<Team> _favoriteTeams = [];

  List<Team> get favoriteTeams => _favoriteTeams;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final teamsJson = prefs.getString('favorite_teams');
    if (teamsJson != null) {
      final List<dynamic> data = json.decode(teamsJson);
      _favoriteTeams = data.map((e) => Team.fromJson(e)).toList();
    }

    notifyListeners();
  }

  Future<void> _saveTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final teamsJson = json.encode(
      _favoriteTeams.map((team) => team.toJson()).toList(),
    );
    await prefs.setString('favorite_teams', teamsJson);
  }

  void addFavoriteTeam(Team team) {
    if (!_favoriteTeams.any((t) => t.id == team.id)) {
      _favoriteTeams.add(team);
      _saveTeams();
      notifyListeners();
    }
  }

  void removeFavoriteTeam(String teamId) {
    _favoriteTeams.removeWhere((team) => team.id == teamId);
    _saveTeams();
    notifyListeners();
  }

  bool isFavoriteTeam(String teamId) {
    return _favoriteTeams.any((team) => team.id == teamId);
  }
}