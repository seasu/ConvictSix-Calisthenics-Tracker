import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/history/history_screen.dart';
import 'features/home/home_screen.dart';
import 'features/program_setup/program_setup_screen.dart';
import 'features/workout/workout_screen.dart';
import 'shared/theme/app_theme.dart';

class ConvictSixApp extends StatelessWidget {
  const ConvictSixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConvictSix Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    WorkoutScreen(),
    HistoryScreen(),
    ProgramSetupScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: '訓練',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '歷史',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune_outlined),
            activeIcon: Icon(Icons.tune),
            label: '計畫',
          ),
        ],
      ),
    );
  }
}
