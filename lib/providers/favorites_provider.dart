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
    final favoritesJson = prefs.getString('favorites');
    if (favoritesJson != null) {
      final List<dynamic> data = json.decode(favoritesJson);
      _favoriteTeams = data.map((e) => Team.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = json.encode(
      _favoriteTeams.map((team) => team.toJson()).toList()
    );
    await prefs.setString('favorites', favoritesJson);
  }

  void addFavorite(Team team) {
    if (!_favoriteTeams.any((t) => t.id == team.id)) {
      _favoriteTeams.add(team);
      _saveFavorites();
      notifyListeners();
    }
  }

  void removeFavorite(String teamId) {
    _favoriteTeams.removeWhere((team) => team.id == teamId);
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String teamId) {
    return _favoriteTeams.any((team) => team.id == teamId);
  }
}