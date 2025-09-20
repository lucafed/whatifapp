
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../state/app_state.dart';
import '../util/types.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ctrl = TextEditingController();
  bool opening = false;
  WhatfEntry? lastEntry;
  String lastSignature = '';
  final tts = FlutterTts();

  String _signature(BuildContext context) {
    final state = context.read<AppState>();
    return '${state.isFuture}|${ctrl.text.trim()}';
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final canAsk = state.canAsk();
    final sig = _signature(context);
    final canRegenerate = lastEntry != null && sig != lastSignature;

    return Scaffold(
      appBar: AppBar(
        title: const Text('What?f'),
        actions: [
          IconButton(onPressed: state.toggleTheme, icon: const Icon(Icons.brightness_6)),
          IconButton(onPressed: _openGuided, icon: const Icon(Icons.tune), tooltip: 'Percorso guidato'),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tempo', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: [!state.isFuture, state.isFuture],
                onPressed: (i)=> state.setTimeMode(i==1),
                children: const [Padding(padding: EdgeInsets.all(8), child: Text('Passato')), Padding(padding: EdgeInsets.all(8), child: Text('Futuro'))],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(hintText: 'What?f...', border: OutlineInputBorder()),
                minLines: 1, maxLines: 4,
                onChanged: (_)=> setState((){}),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text(canAsk ? 'Puoi fare altre ${3 - state.dailyCount} domande oggi.' : 'Limite giornaliero raggiunto (3/3).', style: TextStyle(color: canAsk ? Colors.greenAccent : Colors.orangeAccent))),
                  const SizedBox(width: 8),
                  Tooltip(message: canRegenerate ? 'Puoi rigenerare: input modificato' : 'Modifica l\'input per rigenerare', child:
                    ElevatedButton.icon(onPressed: (!canRegenerate || state.loading) ? null : () async {
                      setState(()=> opening = true);
                      await Future.delayed(400.ms);
                      try {
                        final entry = await state.askQuestion(ctrl.text.trim());
                        setState(()=> lastEntry = entry);
                        setState(()=> lastSignature = _signature(context));
                      } catch (e) {
                        if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e'))); }
                      } finally { setState(()=> opening = false); }
                    }, icon: const Icon(Icons.refresh), label: const Text('Rigenera'))
                  )
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    DoorOpen(open: opening).animate().fadeIn(),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: state.loading || !canAsk || ctrl.text.trim().isEmpty ? null : () async {
                        setState(()=> opening = true);
                        await Future.delayed(400.ms);
                        try {
                          final entry = await state.askQuestion(ctrl.text.trim());
                          setState(()=> lastEntry = entry);
                          setState(()=> lastSignature = _signature(context));
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e')));
                          }
                        } finally {
                          setState(()=> opening = false);
                        }
                      },
                      child: const Text('Apri la porta'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (state.loading) const Center(child: CircularProgressIndicator()),
              if (lastEntry != null && !state.loading) _Result(
                entry: lastEntry!,
                onLike: (type)=> state.likeAnswer(lastEntry!.id, type),
                onShare: (scenario, title) async {
                  final text = '$title\n\n${scenario.shortText}\n\nProbabilità: ${scenario.probability}%\nPerché: ${scenario.rationale}\n\n— What?f';
                  await Share.share(text);
                },
                onSpeak: (text) async {
                  await tts.setLanguage('it-IT');
                  await tts.setSpeechRate(0.48);
                  await tts.speak(text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openGuided() async {
    final res = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const GuidedFlowSheet(),
    );
    if (res != null && res.isNotEmpty) {
      ctrl.text = res;
      setState((){});
    }
  }
}

class _Result extends StatefulWidget {
  final WhatfEntry entry;
  final void Function(ScenarioType) onLike;
  final void Function(Scenario, String title) onShare;
  final void Function(String text) onSpeak;
  const _Result({required this.entry, required this.onLike, required this.onShare, required this.onSpeak});
  @override
  State<_Result> createState() => _ResultState();
}

class _ResultState extends State<_Result> {
  bool showS = false;
  bool showW = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.entry.sliding;
    final w = widget.entry.wtf;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Risultati', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _ScenarioCard(title: 'Sliding Doors', color: Colors.lightBlueAccent, scenario: s, expanded: showS,
          onToggle: ()=> setState(()=> showS = !showS),
          onLike: ()=> widget.onLike(ScenarioType.sliding),
          onShare: ()=> widget.onShare(s, 'Sliding Doors'),
          onSpeak: ()=> widget.onSpeak(s.longText),
          icon: Icons.door_front_door,
        ),
        const SizedBox(height: 12),
        _ScenarioCard(title: 'What the F?!', color: Colors.purpleAccent, scenario: w, expanded: showW,
          onToggle: ()=> setState(()=> showW = !showW),
          onLike: ()=> widget.onLike(ScenarioType.wtf),
          onShare: ()=> widget.onShare(w, 'What the F?!'),
          onSpeak: ()=> widget.onSpeak(w.longText),
          icon: Icons.auto_awesome,
        ),
      ],
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final String title; final Color color; final Scenario scenario;
  final bool expanded; final VoidCallback onToggle; final VoidCallback onLike; final VoidCallback onShare; final VoidCallback onSpeak; final IconData icon;
  const _ScenarioCard({required this.title, required this.color, required this.scenario, required this.expanded, required this.onToggle, required this.onLike, required this.onShare, required this.onSpeak, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.4))),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color), const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Chip(label: Text('${scenario.probability}%'), backgroundColor: color.withOpacity(0.15)),
        ]),
        const SizedBox(height: 8),
        Text(scenario.shortText),
        const SizedBox(height: 8),
        Row(children: [
          TextButton(onPressed: onToggle, child: Text(expanded ? 'Vedi meno' : 'Vedi di più')),
          const Spacer(),
          IconButton(onPressed: onSpeak, icon: const Icon(Icons.volume_up)),
          IconButton(onPressed: onShare, icon: const Icon(Icons.share)),
          IconButton(onPressed: onLike, icon: const Icon(Icons.favorite_border)),
          Text('${scenario.likes}'),
        ]),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(padding: const EdgeInsets.only(top: 8), child: Text(scenario.longText)),
          crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst, duration: const Duration(milliseconds: 250),
        ),
      ]),
    );
  }
}

// -------- Guided flow -------
class GuidedFlowSheet extends StatefulWidget {
  const GuidedFlowSheet({super.key});
  @override
  State<GuidedFlowSheet> createState() => _GuidedFlowSheetState();
}

class _GuidedFlowSheetState extends State<GuidedFlowSheet> {
  int step = 0;
  final ageCtrl = TextEditingController();
  final interestsCtrl = TextEditingController();
  String category = 'lavoro';
  String specific = '';
  final freeCtrl = TextEditingController();

  final suggestions = <String, List<String>>{
    'lavoro': ['Se cambio lavoro tra 6 mesi?', 'Se chiedo un aumento ora?', 'Se apro una partita IVA?'],
    'amore': ['Se torno con il/la mio/a ex?', 'Se mi trasferisco per amore?', 'Se chiedo di uscire a X?'],
    'soldi': ['Se investo 500€/mese in ETF?', 'Se compro casa nel 2026?', 'Se riduco le spese del 20%?'],
    'salute': ['Se inizio palestra 3 volte a settimana?', 'Se smetto di fumare?', 'Se provo una dieta X?'],
    'studio': ['Se prendo un master in UX?', 'Se imparo a programmare?', 'Se cambio università?'],
    'altro': ['Se mi trasferisco all\'estero?', 'Se faccio un anno sabbatico?', 'Se avvio un canale YouTube?'],
  };

  @override
  Widget build(BuildContext context) {
    final pages = [
      _stepIntro(context),
      _stepCategory(context),
      _stepSpecific(context),
      _stepReview(context),
    ];
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, controller) => Scaffold(
        appBar: AppBar(title: const Text('Percorso guidato')),
        body: SingleChildScrollView(controller: controller, padding: const EdgeInsets.all(16), child: pages[step]),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            if (step>0) OutlinedButton(onPressed: ()=> setState(()=> step -= 1), child: const Text('Indietro')),
            const Spacer(),
            ElevatedButton(onPressed: ()=> setState(()=> step = (step+1).clamp(0, pages.length-1)), child: Text(step<pages.length-1 ? 'Avanti' : 'Rivedi')),
            const SizedBox(width: 8),
            if (step==pages.length-1) ElevatedButton.icon(onPressed: (){
              final q = _buildQuestion();
              Navigator.pop(context, q);
            }, icon: const Icon(Icons.check), label: const Text('Usa questa domanda')),
          ]),
        ),
      ),
    );
  }

  Widget _stepIntro(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('1) Info generali', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      TextField(controller: ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Età', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: interestsCtrl, decoration: const InputDecoration(labelText: 'Interessi (virgola-separati)', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      const Text('Questi dati servono a personalizzare i suggerimenti.'),
    ]);
  }

  Widget _stepCategory(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('2) Scegli un tema', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        initialValue: category,
        items: suggestions.keys.map((k)=> DropdownMenuItem(value: k, child: Text(k[0].toUpperCase()+k.substring(1)))).toList(),
        onChanged: (v)=> setState(()=> category = v ?? 'lavoro'),
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    ]);
  }

  Widget _stepSpecific(BuildContext context) {
    final opts = suggestions[category]!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('3) Domanda mirata', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final s in opts) ChoiceChip(label: Text(s), selected: specific == s, onSelected: (_)=> setState(()=> specific = s)),
      ]),
      const SizedBox(height: 12),
      TextField(controller: freeCtrl, decoration: const InputDecoration(labelText: 'Testo libero (opzionale)', border: OutlineInputBorder())),
    ]);
  }

  Widget _stepReview(BuildContext context) {
    final q = _buildQuestion();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('4) Riepilogo', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Text(q),
      const SizedBox(height: 12),
      const Text('Premi "Usa questa domanda" per riempire il campo in Home.'),
    ]);
  }

  String _buildQuestion() {
    final age = ageCtrl.text.trim();
    final interests = interestsCtrl.text.trim();
    final parts = <String>[];
    if (age.isNotEmpty) parts.add('Età: $age');
    if (interests.isNotEmpty) parts.add('Interessi: $interests');
    final ctx = parts.isEmpty ? '' : '(${parts.join(' • ')}) ';
    final core = specific.isNotEmpty ? specific : '...';
    final extra = freeCtrl.text.trim();
    final q = 'What?f $ctx$core${extra.isNotEmpty ? ' — $extra' : ''}';
    return q;
  }
}
