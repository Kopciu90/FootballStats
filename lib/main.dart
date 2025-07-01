import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/favorites_drawer.dart';
import 'screens/home_screen.dart';
import 'screens/leagues_screen.dart';
import 'screens/teams_screen.dart';
import 'screens/team_detail_screen.dart';

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
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const FavoritesDrawer(),
      body: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) {
              switch (settings.name) {
                case '/leagues':
                  return LeaguesScreen(scaffoldKey: _scaffoldKey);
                case '/teams':
                  final args = settings.arguments as Map<String, dynamic>;
                  return TeamsScreen(
                    leagueName: args['leagueName'],
                    scaffoldKey: _scaffoldKey,
                  );
                case '/team-detail':
                  final args = settings.arguments as Map<String, dynamic>;
                  return TeamDetailScreen(
                    team: args['team'],
                    scaffoldKey: _scaffoldKey,
                  );
                default:
                  return HomeScreen(scaffoldKey: _scaffoldKey);
              }
            },
          );
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => HomeScreen(scaffoldKey: _scaffoldKey),
        ),
      ),
    );
  }
}