import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/loading_ball.dart' as widgets;
import '../models/league.dart';
import 'teams_screen.dart'; // Dodaj ten import

class LeaguesScreen extends StatelessWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wybierz ligę'), centerTitle: true),
      body: FutureBuilder<List<League>>(
        future: ApiService.fetchLeagues(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: widgets.LoadingBall());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak danych'));
          }

          final leagues = snapshot.data!;
          return ListView.builder(
            itemCount: leagues.length,
            itemBuilder: (context, index) {
              final league = leagues[index];
              return ListTile(
                title: Text(league.name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TeamsScreen(leagueName: league.name),
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
