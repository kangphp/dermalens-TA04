// lib/providers/history_provider.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dermalens/models/analysis_result.dart';

class HistoryProvider with ChangeNotifier {
  static const _historyKey = 'analysis_history';
  List<AnalysisResult> _history = [];

  List<AnalysisResult> get history => [..._history];

  /// Memuat riwayat analisis dari SharedPreferences saat aplikasi dimulai.
  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey) ?? '[]';
      final List<dynamic> historyList = jsonDecode(historyJson);

      _history = historyList
          .map((item) => AnalysisResult.fromMap(item as Map<String, dynamic>))
          .toList();

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading history: $e");
      _history = [];
      notifyListeners();
    }
  }

  /// Menambah hasil analisis baru, menyimpannya ke storage, dan memperbarui UI.
  Future<void> addResult(AnalysisResult result) async {
    try {
      // Pastikan path gambar permanen sebelum disimpan
      final permanentPath = await _saveImagePermanently(result.imagePath);

      // Buat objek baru dengan path gambar yang sudah permanen
      final resultToSave = AnalysisResult(
        id: result.id,
        conditions: result.conditions,
        confidences: result.confidences,
        severity: result.severity,
        imagePath: permanentPath, // Gunakan path baru
        dateTime: result.dateTime,
        descriptions: result.descriptions,
        recommendations: result.recommendations,
        image: result.image,
      );

      _history.insert(0, resultToSave); // Tambahkan di awal daftar

      final prefs = await SharedPreferences.getInstance();
      // Konversi semua riwayat ke List<Map> menggunakan toMap() dari model
      final historyData = _history.map((item) => item.toMap()).toList();
      await prefs.setString(_historyKey, jsonEncode(historyData));

      notifyListeners();
    } catch (e) {
      debugPrint("Error adding result to history: $e");
    }
  }

  /// Menghapus semua riwayat dari state dan SharedPreferences.
  Future<void> clearHistory() async {
    _history.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    notifyListeners();
  }

  /// Menyalin gambar dari path sementara (cache) ke direktori permanen aplikasi.
  Future<String> _saveImagePermanently(String temporaryPath) async {
    final tempFile = File(temporaryPath);
    if (!await tempFile.exists())
      return temporaryPath; // Kembalikan path lama jika file tidak ada

    final appDir = await getApplicationDocumentsDirectory();
    final permanentDir = Directory(path.join(appDir.path, 'history_images'));

    if (!await permanentDir.exists()) {
      await permanentDir.create(recursive: true);
    }

    final fileName = path.basename(temporaryPath);
    final permanentPath = path.join(permanentDir.path, fileName);

    // Salin file hanya jika belum ada di lokasi permanen
    if (await File(permanentPath).exists()) {
      return permanentPath;
    }

    await tempFile.copy(permanentPath);
    return permanentPath;
  }
}
