import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import 'team_detail_screen.dart';

class FavoritesDrawer extends StatelessWidget {
  const FavoritesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Center(
              child: Text(
                'Ulubione drużyny',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          Expanded(
            child: Consumer<FavoritesProvider>(
              builder: (context, favorites, child) {
                if (favorites.favoriteTeams.isEmpty) {
                  return const Center(
                    child: Text('Brak ulubionych drużyn'),
                  );
                }
                return ListView.builder(
                  itemCount: favorites.favoriteTeams.length,
                  itemBuilder: (context, index) {
                    final team = favorites.favoriteTeams[index];
                    return ListTile(
                      leading: team.badgeUrl != null
                          ? Image.network(team.badgeUrl!, height: 40)
                          : null,
                      title: Text(team.name),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamDetailScreen(
                              team: team,
                              scaffoldKey: GlobalKey(),
                            ),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => 
                          favorites.removeFavoriteTeam(team.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}