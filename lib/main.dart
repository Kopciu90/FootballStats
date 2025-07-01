import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/favorites_drawer.dart';
import 'screens/home_screen.dart';
import 'screens/leagues_screen.dart';
import 'screens/teams_screen.dart';
import 'screens/team_detail_screen.dart';
// USUŃ TĘ LINIĘ: import 'models/team.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => FavoritesProvider(),
      child: const FootballStatsApp(),
    ),
  );
}

class FootballStatsApp extends StatelessWidget {
  const FootballStatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FootballStats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MainWrapper(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/leagues': (context) => const LeaguesScreen(),
      },
    );
  }
}

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const FavoritesDrawer(),
      body: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) {
              switch (settings.name) {
                case '/leagues':
                  return const LeaguesScreen();
                case '/teams':
                  final args = settings.arguments as Map<String, dynamic>;
                  return TeamsScreen(leagueName: args['leagueName']);
                case '/team-detail':
                  final args = settings.arguments as Map<String, dynamic>;
                  return TeamDetailScreen(team: args['team']);
                default:
                  return const HomeScreen();
              }
            },
          );
        },
      ),
    );
  }
}