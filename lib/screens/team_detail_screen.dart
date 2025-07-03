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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.team.badgeUrl != null)
              Image.network(
                widget.team.badgeUrl!,
                height: 30,
                width: 30,
              ),
            const SizedBox(width: 12),
            Text(widget.team.name),
          ],
        ),
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
            child: Center(
              child: Text(
                'OSTATNIE 5 MECZÓW',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          ...last.map(
            (match) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data i czas
                    Center(
                      child: Text(
                        '${match['date']} • ${match['time']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Rozgrywki
                    if ((match['competition'] ?? '').isNotEmpty)
                      Center(
                        child: Text(
                          match['competition']!,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    
                    // Drużyny i wynik z herbami
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Gospodarz
                        Expanded(
                          child: Column(
                            children: [
                              if ((match['homeBadge'] ?? '').isNotEmpty)
                                Image.network(
                                  match['homeBadge']!,
                                  height: 50,
                                  width: 50,
                                  errorBuilder: (context, error, stackTrace) => 
                                    const Icon(Icons.error),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                match['homeTeam'] ?? 'Gospodarz',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Wynik
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            match['score'] ?? '0:0',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        // Gość
                        Expanded(
                          child: Column(
                            children: [
                              if ((match['awayBadge'] ?? '').isNotEmpty)
                                Image.network(
                                  match['awayBadge']!,
                                  height: 50,
                                  width: 50,
                                  errorBuilder: (context, error, stackTrace) => 
                                    const Icon(Icons.error),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                match['awayTeam'] ?? 'Gość',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        
        if (next.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 8),
            child: Center(
              child: Text(
                'NADCHODZĄCE MECZE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          ...next.map(
            (match) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: (match['homeBadge'] ?? '').isNotEmpty
                  ? Image.network(
                      match['homeBadge']!,
                      height: 40,
                      width: 40,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.sports_soccer),
                    )
                  : null,
                title: Text(
                  match['title'] ?? 'Mecz',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${match['date']} • ${match['time']}',
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: (match['awayBadge'] ?? '').isNotEmpty
                  ? Image.network(
                      match['awayBadge']!,
                      height: 40,
                      width: 40,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.sports_soccer),
                    )
                  : null,
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
    
    // podział na menadżerów i zawodników
    final managers = players.where((p) => p['isManager'] == 'true').toList();
    final teamPlayers = players.where((p) => p['isManager'] != 'true').toList();
    
    return ListView(
      children: [
        // menadzer
        if (managers.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Text(
              'TRENERZY',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          ...managers.map((manager) => _buildManagerTile(manager)),
        ],
        
        // zawodnicy
        if (teamPlayers.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 24, left: 16, right: 16),
            child: Text(
              'ZAWODNICY',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: (manager['thumbnail'] ?? '').isNotEmpty
          ? CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(manager['thumbnail']!),
            )
          : const Icon(Icons.person, size: 40, color: Colors.green),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: (player['thumbnail'] ?? '').isNotEmpty
          ? CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(player['thumbnail']!),
            )
          : player['number']!.isNotEmpty
            ? CircleAvatar(
                radius: 22,
                backgroundColor: Colors.green,
                child: Text(
                  player['number']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white
                  ),
                ),
              )
            : const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey,
                child: Text(
                  '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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