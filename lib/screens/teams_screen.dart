import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/team.dart';
import '../providers/favorites_provider.dart';
import '../services/api_service.dart';
import '../widgets/loading_ball.dart';
import 'team_detail_screen.dart';

class TeamsScreen extends StatefulWidget {
  final String leagueName;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const TeamsScreen({
    super.key, 
    required this.leagueName,
    required this.scaffoldKey,
  });

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  bool isGrid = false;
  late Future<List<Team>> _teamsFuture;

  @override
  void initState() {
    super.initState();
    _teamsFuture = ApiService.fetchTeams(widget.leagueName);
  }

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
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
          ),
        ],
      ),
      body: FutureBuilder<List<Team>>(
        future: _teamsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingBall());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Błąd podczas ładowania drużyn:'),
                  Text(snapshot.error.toString()),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _teamsFuture = ApiService.fetchTeams(widget.leagueName);
                      });
                    },
                    child: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak drużyn w tej lidze'));
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
                            builder: (context) => TeamDetailScreen(
                              team: team,
                              scaffoldKey: widget.scaffoldKey,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (team.badgeUrl != null)
                                  Image.network(team.badgeUrl!, height: 50),
                                const SizedBox(height: 8),
                                Text(team.name, textAlign: TextAlign.center),
                              ],
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Consumer<FavoritesProvider>(
                                builder: (context, favorites, child) {
                                  return IconButton(
                                    icon: Icon(
                                      favorites.isFavoriteTeam(team.id)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      if (favorites.isFavoriteTeam(team.id)) {
                                        favorites.removeFavoriteTeam(team.id);
                                      } else {
                                        favorites.addFavoriteTeam(team);
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
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
                      trailing: Consumer<FavoritesProvider>(
                        builder: (context, favorites, child) {
                          return IconButton(
                            icon: Icon(
                              favorites.isFavoriteTeam(team.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              if (favorites.isFavoriteTeam(team.id)) {
                                favorites.removeFavoriteTeam(team.id);
                              } else {
                                favorites.addFavoriteTeam(team);
                              }
                            },
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamDetailScreen(
                              team: team,
                              scaffoldKey: widget.scaffoldKey,
                            ),
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