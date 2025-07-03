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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _teamsFuture = ApiService.fetchTeams(widget.leagueName);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Brak drużyn w tej lidze',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final teams = snapshot.data!;

          return isGrid
              ? _buildGridView(teams)
              : _buildListView(teams);
        },
      ),
    );
  }

  Widget _buildListView(List<Team> teams) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
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
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (team.badgeUrl != null)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(team.badgeUrl!),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  if (team.badgeUrl != null) const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      team.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Consumer<FavoritesProvider>(
                    builder: (context, favorites, child) {
                      return IconButton(
                        icon: Icon(
                          favorites.isFavoriteTeam(team.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: favorites.isFavoriteTeam(team.id)
                              ? Colors.red
                              : Colors.grey,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Team> teams) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: team.badgeUrl != null
                          ? Image.network(
                              team.badgeUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => 
                                const Icon(Icons.error, size: 40, color: Colors.grey),
                            )
                          : const Icon(Icons.sports_soccer, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Consumer<FavoritesProvider>(
                        builder: (context, favorites, child) {
                          return Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(
                                favorites.isFavoriteTeam(team.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: favorites.isFavoriteTeam(team.id)
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                if (favorites.isFavoriteTeam(team.id)) {
                                  favorites.removeFavoriteTeam(team.id);
                                } else {
                                  favorites.addFavoriteTeam(team);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}