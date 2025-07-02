import 'package:flutter/material.dart';
import '../models/team.dart';
import '../widgets/loading_ball.dart';
import '../services/api_service.dart';

class TeamDetailScreen extends StatefulWidget {
  final Team team;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const TeamDetailScreen({
    super.key, 
    required this.team,
    required this.scaffoldKey,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>> _teamData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _teamData = _loadTeamData();
  }

  Future<Map<String, dynamic>> _loadTeamData() async {
    try {
      final lastMatches = await ApiService.fetchLastEvents(widget.team.id);
      final nextMatches = await ApiService.fetchNextEvents(widget.team.id);
      final players = await ApiService.fetchTeamPlayers(widget.team.id);
      return {
        'last': lastMatches,
        'next': nextMatches,
        'players': players,
      };
    } catch (e) {
      return {
        'last': <Map<String, String>>[],
        'next': <Map<String, String>>[],
        'players': <Map<String, String>>[],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mecze'),
            Tab(text: 'Skład'),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _teamData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingBall());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else {
            final last = snapshot.data!['last'] as List<Map<String, String>>;
            final next = snapshot.data!['next'] as List<Map<String, String>>;
            final players = snapshot.data!['players'] as List<Map<String, String>>;

            return TabBarView(
              controller: _tabController,
              children: [
                _buildMatchesTab(last, next),
                _buildPlayersTab(players),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildMatchesTab(
    List<Map<String, String>> last,
    List<Map<String, String>> next,
  ) {
    return ListView(
      children: [
        if (last.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Ostatnie mecze',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ...last.map(
            (match) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match['title'] ?? 'Mecz',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Data: ${match['date'] ?? 'Brak daty'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          match['score'] ?? '0 : 0',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if ((match['homeScorers'] ?? '').isNotEmpty) ...[
                      Text(
                        'Gole gospodarzy: ${match['homeScorers']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                    ],
                    if ((match['awayScorers'] ?? '').isNotEmpty) ...[
                      Text(
                        'Gole gości: ${match['awayScorers']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
        
        if (next.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Nadchodzące mecze',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ...next.map(
            (match) => ListTile(
              title: Text(
                match['title'] ?? 'Mecz',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                match['date'] ?? 'Brak daty',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
        
        if (last.isEmpty && next.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'Brak danych o meczach',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayersTab(List<Map<String, String>> players) {
    if (players.isEmpty) {
      return const Center(
        child: Text(
          'Brak danych o składzie',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    
    // Podziel na menadżerów i zawodników
    final managers = players.where((p) => p['isManager'] == 'true').toList();
    final teamPlayers = players.where((p) => p['isManager'] != 'true').toList();
    
    return ListView(
      children: [
        // Sekcja menadżerów
        if (managers.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Text(
              'Trenerzy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...managers.map((manager) => _buildManagerTile(manager)),
        ],
        
        // Sekcja zawodników
        if (teamPlayers.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 24, left: 16, right: 16),
            child: Text(
              'Zawodnicy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...teamPlayers.map((player) => _buildPlayerTile(player)),
        ],
      ],
    );
  }

  Widget _buildManagerTile(Map<String, String> manager) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.green[50],
      child: ListTile(
        leading: const Icon(Icons.person, size: 40, color: Colors.green),
        title: Text(
          manager['name']!,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pozycja: ${manager['position']}'),
            if (manager['nationality']?.isNotEmpty ?? false)
              Text('Narodowość: ${manager['nationality']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerTile(Map<String, String> player) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: player['number']!.isNotEmpty
            ? CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green,
                child: Text(
                  player['number']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
              )
            : const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                child: Text('?', style: TextStyle(color: Colors.white)),
              ),
        title: Text(
          player['name']!,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pozycja: ${player['position']}'),
            if (player['nationality']?.isNotEmpty ?? false)
              Text('Narodowość: ${player['nationality']}'),
          ],
        ),
      ),
    );
  }
}