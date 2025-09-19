
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/openai_service.dart';
import '../util/types.dart';

class AppState extends ChangeNotifier {
  bool isDark = true;
  bool isFuture = true;
  List<WhatfEntry> history = [];
  int dailyCount = 0;
  DateTime lastReset = DateTime.now();
  bool loading = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    isDark = prefs.getBool('isDark') ?? true;
    isFuture = prefs.getBool('isFuture') ?? true;
    final raw = prefs.getString('history') ?? '[]';
    final resetStr = prefs.getString('lastReset');
    if (resetStr != null) lastReset = DateTime.tryParse(resetStr) ?? DateTime.now();
    _maybeResetDaily();
    history = (jsonDecode(raw) as List).map((e) => WhatfEntry.fromJson(e)).toList();
    dailyCount = prefs.getInt('dailyCount') ?? 0;
    notifyListeners();
  }

  void toggleTheme() async {
    isDark = !isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    notifyListeners();
  }

  void setTimeMode(bool future) async {
    isFuture = future;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFuture', isFuture);
    notifyListeners();
  }

  void _maybeResetDaily() async {
    final now = DateTime.now();
    final df = DateFormat('yyyy-MM-dd');
    if (df.format(now) != df.format(lastReset)) {
      dailyCount = 0;
      lastReset = now;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('dailyCount', dailyCount);
      await prefs.setString('lastReset', lastReset.toIso8601String());
    }
  }

  bool canAsk() {
    _maybeResetDaily();
    return dailyCount < 3;
  }

  Future<WhatfEntry?> askQuestion(String question) async {
    if (!canAsk()) return null;
    loading = true;
    notifyListeners();
    try {
      final service = OpenAIService();
      final result = await service.generateScenarios(question: question, isFuture: isFuture);
      final entry = WhatfEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: question,
        isFuture: isFuture,
        createdAt: DateTime.now().toIso8601String(),
        sliding: result.sliding,
        wtf: result.wtf,
      );
      history.insert(0, entry);
      dailyCount += 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('history', jsonEncode(history.map((e) => e.toJson()).toList()));
      await prefs.setInt('dailyCount', dailyCount);
      loading = false;
      notifyListeners();
      return entry;
    } catch (e) {
      loading = false;
      notifyListeners();
      rethrow;
    }
  }

  void likeAnswer(String entryId, ScenarioType type) async {
    final idx = history.indexWhere((e) => e.id == entryId);
    if (idx == -1) return;
    final entry = history[idx];
    if (type == ScenarioType.sliding) {
      entry.sliding = entry.sliding.copyWith(likes: entry.sliding.likes + 1);
    } else {
      entry.wtf = entry.wtf.copyWith(likes: entry.wtf.likes + 1);
    }
    history[idx] = entry;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('history', jsonEncode(history.map((e) => e.toJson()).toList()));
    notifyListeners();
  }
}
