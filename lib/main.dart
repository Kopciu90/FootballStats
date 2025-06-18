import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FootballStatsApp());
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
      home: const HomeScreen(),
    );
  }
}
