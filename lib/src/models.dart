import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Message {
  final String role;
  final String text;
  Message(this.role, this.text);
}

final convoProvider =
    StateNotifierProvider<Convo, List<Message>>((ref) => Convo());

class Convo extends StateNotifier<List<Message>> {
  Convo() : super([]) {
    _load();
  }

  void add(Message m) {
    state = [...state, m];
    _save();
  }

  void clear() {
    state = [];
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data =
        state.map((m) => {"role": m.role, "text": m.text}).toList();
    await prefs.setString("convo", jsonEncode(data));
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("convo");
    if (raw == null) return;
    final list = (jsonDecode(raw) as List)
        .map((e) => Message(e["role"] as String, e["text"] as String))
        .toList();
    state = list;
  }
}
