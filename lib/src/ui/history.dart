
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../util/types.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.history.isEmpty) {
      return const Center(child: Text('Nessuna cronologia ancora.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.history.length,
      itemBuilder: (_, i) {
        final e = state.history[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.question, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(e.isFuture ? 'Futuro' : 'Passato', style: const TextStyle(color: Colors.grey)),
                const Divider(),
                Text('Sliding Doors: ${e.sliding.shortText}'),
                Text('What the F?!: ${e.wtf.shortText}'),
                Row(
                  children: [
                    const Spacer(),
                    IconButton(onPressed: ()=> context.read<AppState>().likeAnswer(e.id, ScenarioType.sliding), icon: const Icon(Icons.favorite_border)),
                    IconButton(onPressed: ()=> context.read<AppState>().likeAnswer(e.id, ScenarioType.wtf), icon: const Icon(Icons.favorite_border)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
