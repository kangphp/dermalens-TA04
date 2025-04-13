import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dermalens/models/analysis_result.dart';

class HistoryProvider with ChangeNotifier {
  List<AnalysisResult> _history = [];

  List<AnalysisResult> get history => [..._history];

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    print("DEBUG: Available keys: ${prefs.getKeys()}");
    final historyJson = prefs.getStringList('analysis_history') ?? [];

    final historyData = prefs.getStringList('analysis_history');
    print("DEBUG: History data found: ${historyData != null}");

    _history = historyJson.map((item) {
      return AnalysisResult.fromMap(jsonDecode(item));
    }).toList();

    notifyListeners();
  }

  Future<void> addResult(AnalysisResult result) async {
    _history.insert(0, result); // Tambahkan di awal daftar

    final prefs = await SharedPreferences.getInstance();
    final historyJson = _history.map((item) {
      return jsonEncode(item.toMap());
    }).toList();

    await prefs.setStringList('analysis_history', historyJson);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('analysis_history');

    notifyListeners();
  }
}
