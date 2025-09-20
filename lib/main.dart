import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/ai_service.dart';
import 'src/models.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'What?f',
      theme: ThemeData.light(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _ctrl = TextEditingController();
  int _tab = 0;

  Future<void> _ask() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    ref.read(convoProvider.notifier).add(Message("user", text));
    _ctrl.clear();
    final reply = await AiService().ask(text);
    ref.read(convoProvider.notifier).add(Message("ai", reply));
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [_home(), _history(), _settings()];
    return Scaffold(
      appBar: AppBar(title: const Text('What?f')),
      body: tabs[_tab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Cronologia'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Impostazioni'),
        ],
      ),
    );
  }

  Widget _home() {
    final msgs = ref.watch(convoProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Scrivi la tua domanda...",
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _ctrl.text = "Simula 3 scenari Sliding Doors per: ";
                  },
                  child: const Text("Sliding Doors ��"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _ctrl.text = "Spiegami in modo sorprendente: ";
                  },
                  child: const Text("What the F?! 🤯"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _ask,
            child: const Text("Apri la porta"),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: msgs.length,
              itemBuilder: (c, i) {
                final m = msgs[i];
                return ListTile(
                  leading: Icon(m.role == "user" ? Icons.person : Icons.smart_toy),
                  title: Text(m.text),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _history() {
    final msgs = ref.watch(convoProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => ref.read(convoProvider.notifier).clear(),
            icon: const Icon(Icons.delete),
            label: const Text("Svuota cronologia"),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: msgs.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (c, i) {
                final m = msgs[i];
                return ListTile(
                  leading: Icon(m.role == 'user' ? Icons.person : Icons.smart_toy),
                  title: Text(m.text),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _settings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.info_outline),
          title: Text("Versione"),
          subtitle: Text("What?f - build locale"),
        ),
      ],
    );
  }
}
