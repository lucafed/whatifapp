class Message {
  final String role;
  final String text;
  Message(this.role, this.text);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final convoProvider = StateNotifierProvider<Convo, List<Message>>((ref) => Convo());

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
    final data = state.map((m) => {"role": m.role, "text": m.text}).toList();
    prefs.setString("convo", jsonEncode(data));
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("convo");
    if (data != null) {
      final list = (jsonDecode(data) as List)
          .map((e) => Message(e["role"], e["text"]))
          .toList();
      state = list;
    }
  }
}
