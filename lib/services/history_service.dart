import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dermalens/models/analysis_result.dart';

class HistoryService {
  // Metode yang hilang - menambahkan implementasi saveResult
  Future<void> saveResult(AnalysisResult result) async {
    try {
      // Pastikan gambar disimpan permanen jika belum
      final permanentImagePath = await _ensurePermanentImage(result.imagePath);

      // Siapkan data untuk disimpan
      final resultMap = {
        'id': result.id,
        'condition': result.condition,
        'confidence': result.confidence,
        'severity': result.severity,
        'imagePath': permanentImagePath,
        'dateTime': result.dateTime.toIso8601String(),
        'description': result.description,
        'recommendations':
            jsonEncode(result.recommendations), // Encode sebagai string JSON
      };

      // Dapatkan data history yang ada
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = prefs.getString('analysis_history') ?? '[]';
      final List<dynamic> historyList = jsonDecode(historyJson);

      // Tambahkan hasil baru
      historyList.add(resultMap);

      // Simpan kembali ke SharedPreferences
      await prefs.setString('analysis_9history', jsonEncode(historyList));
    } catch (e) {
      print('Error saving result: $e');
      throw Exception('Failed to save result to history');
    }
  }

  // Metode helper untuk memastikan gambar disimpan secara permanen
  Future<String> _ensurePermanentImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Image file does not exist: $imagePath');
      }

      // Periksa apakah gambar sudah di direktori permanen
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/dermalens_images');

      if (imagePath.startsWith(imagesDir.path)) {
        // Gambar sudah di lokasi permanen
        return imagePath;
      }

      // Buat direktori jika belum ada
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Salin gambar ke lokasi permanen
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imagePath)}';
      final permanentPath = '${imagesDir.path}/$fileName';
      await file.copy(permanentPath);

      return permanentPath;
    } catch (e) {
      print('Error ensuring permanent image: $e');
      return imagePath; // Return original path if error
    }
  }

  // Metode lain yang mungkin dibutuhkan
  Future<List<AnalysisResult>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = prefs.getString('analysis_history') ?? '[]';
      final List historyList = jsonDecode(historyJson);

      return historyList.map((item) {
        final Map resultMap = Map.from(item);
        var recommendationsData;

        // Handle both cases: when recommendations is a string or already a list
        if (resultMap['recommendations'] is String) {
          recommendationsData = jsonDecode(resultMap['recommendations']);
        } else {
          recommendationsData = resultMap['recommendations'];
        }

        return AnalysisResult(
          id: resultMap['id'],
          condition: resultMap['condition'],
          confidence: resultMap['confidence'],
          severity: resultMap['severity'],
          imagePath: resultMap['imagePath'],
          dateTime: DateTime.parse(resultMap['dateTime']),
          description: resultMap['description'],
          recommendations: recommendationsData,
        );
      }).toList();
    } catch (e) {
      print('Error retrieving history: $e');
      return [];
    }
  }
}
