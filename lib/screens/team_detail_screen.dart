import 'package:flutter/material.dart';
import '../models/team.dart';
import '../widgets/loading_ball.dart';
import '../services/api_service.dart';

class TeamDetailScreen extends StatefulWidget {
  final Team team;

  const TeamDetailScreen({super.key, required this.team});

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
    final lastMatches = await ApiService.fetchLastEvents(widget.team.id);
    final nextMatches = await ApiService.fetchNextEvents(widget.team.id);
    final players = await ApiService.fetchTeamPlayers(widget.team.id);

    return {'last': lastMatches, 'next': nextMatches, 'players': players};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team.name),
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
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Ostatnie mecze',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...last.map(
          (match) => ListTile(
            title: Text(match['title'] ?? ''),
            subtitle: Text(match['score'] ?? ''),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Nadchodzące mecze',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...next.map(
          (match) => ListTile(
            title: Text(match['title'] ?? ''),
            subtitle: Text(match['date'] ?? ''),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersTab(List<Map<String, String>> players) {
    if (players.isEmpty) {
      return const Center(child: Text('Brak danych o składzie'));
    }
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return ListTile(
          title: Text(player['name'] ?? ''),
          subtitle: Text(player['position'] ?? ''),
        );
      },
    );
  }
}
