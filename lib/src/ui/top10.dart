
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Top10Screen extends StatelessWidget {
  const Top10Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(10, (i) => 'What?f #${i+1}: esempio di scenario popolare');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => Card(
        child: ListTile(
          leading: CircleAvatar(child: Text('${i+1}')),
          title: Text(items[i]),
          subtitle: const Text('♥ 123 • Sliding vs WTF'),
        ).animate().fadeIn(duration: const Duration(milliseconds: 300)).slideY(begin: 0.1, end: 0),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
    );
  }
}
