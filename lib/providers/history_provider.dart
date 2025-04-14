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

    // Ambil data JSON dari SharedPreferences
    final historyJson = prefs.getString('analysis_history') ?? '[]';
    print("DEBUG: History JSON: $historyJson");

    // Parsing JSON menjadi List<AnalysisResult>
    try {
      final historyList = jsonDecode(historyJson) as List;
      _history = historyList
          .map((item) {
            try {
              return AnalysisResult.fromMap(item as Map);
            } catch (e) {
              print("Error parsing item: $e");
              return null;
            }
          })
          .whereType<AnalysisResult>()
          .toList();
    } catch (e) {
      print("Error parsing history JSON: $e");
      _history = [];
    }

    notifyListeners();
  }

  Future<void> addResult(AnalysisResult result) async {
    _history.insert(0, result); // Tambahkan di awal daftar

    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        jsonEncode(_history.map((item) => item.toMap()).toList());

    await prefs.setString('analysis_history', historyJson);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('analysis_history');

    notifyListeners();
  }
}
