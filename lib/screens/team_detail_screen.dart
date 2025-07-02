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
      final nextMatches = await ApiService.fetchNextEvents(widget.team.name);
      final players = await ApiService.fetchTeamPlayers(widget.team.id);
      return {'last': lastMatches, 'next': nextMatches, 'players': players};
    } catch (e) {
      return {
        'last': [],
        'next': [],
        'players': []
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
            final players =
                snapshot.data!['players'] as List<Map<String, String>>;

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
            (match) => ListTile(
              title: Text(
                match['title'] ?? 'Mecz',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                match['score'] ?? 'Brak wyniku',
                style: const TextStyle(fontSize: 14),
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
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return ListTile(
          title: Text(
            player['name'] ?? 'Nieznany zawodnik',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            player['position'] ?? 'Nieznana pozycja',
            style: const TextStyle(fontSize: 14),
          ),
        );
      },
    );
  }
}