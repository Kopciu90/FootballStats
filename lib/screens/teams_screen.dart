import 'package:flutter/material.dart';
import '../models/team.dart';
import '../services/api_service.dart';
import '../widgets/loading_ball.dart';
import 'team_detail_screen.dart';

class TeamsScreen extends StatefulWidget {
  final String leagueName;

  const TeamsScreen({super.key, required this.leagueName});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  bool isGrid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.leagueName),
        actions: [
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGrid = !isGrid;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Team>>(
        future: ApiService.fetchTeams(widget.leagueName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingBall());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak drużyn'));
          }

          final teams = snapshot.data!;

          return isGrid
              ? GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamDetailScreen(team: team),
                          ),
                        );
                      },
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (team.badgeUrl != null)
                              Image.network(team.badgeUrl!, height: 50),
                            const SizedBox(height: 8),
                            Text(team.name, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return ListTile(
                      leading: team.badgeUrl != null
                          ? Image.network(team.badgeUrl!, height: 40)
                          : null,
                      title: Text(team.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamDetailScreen(team: team),
                          ),
                        );
                      },
                    );
                  },
                );
        },
      ),
    );
  }
}
