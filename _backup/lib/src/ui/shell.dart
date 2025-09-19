
import 'package:flutter/material.dart';
import 'home.dart';
import 'history.dart';
import 'top10.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class NavShell extends StatefulWidget {
  const NavShell({super.key});
  @override
  State<NavShell> createState() => _NavShellState();
}

class _NavShellState extends State<NavShell> {
  int idx = 0;
  final pages = const [HomeScreen(), HistoryScreen(), Top10Screen()];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      body: IndexedStack(index: idx, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i)=> setState(()=> idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), selectedIcon: Icon(Icons.history), label: 'Cronologia'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Esplora'),
        ],
      ),
      floatingActionButton: idx==0 ? null : FloatingActionButton.extended(
        onPressed: ()=> setState(()=> idx = 0),
        icon: const Icon(Icons.add),
        label: const Text('Nuova domanda'),
      ),
    );
  }
}
