import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  // Mengubah deskripsi menjadi Map agar tidak bergantung pada urutan
  static final Map<String, String> _descriptions = {
    "berjerawat":
        "Jerawat adalah kondisi kulit yang terjadi akibat penyumbatan pori-pori oleh minyak dan sel kulit mati, sering kali menyebabkan bintik-bintik merah atau pustula.",
    "berminyak":
        "Kulit berminyak ditandai dengan produksi sebum berlebih yang membuat kulit tampak mengkilap, sering kali menyebabkan komedo dan jerawat.",
    "dermatitis_perioral":
        "Dermatitis perioral adalah peradangan kulit berupa ruam kemerahan di sekitar mulut, kadang menyebar ke hidung dan mata, disertai rasa gatal atau terbakar.",
    "kering":
        "Kulit kering adalah kondisi kulit dengan tingkat kelembapan rendah yang menyebabkan tekstur kasar, pecah-pecah, dan mudah teriritasi.",
    "normal":
        "Kulit normal memiliki keseimbangan antara kandungan air dan minyak, tidak terlalu kering atau berminyak, serta jarang mengalami masalah kulit.",
    "penuaan":
        "Penuaan kulit ditandai dengan munculnya garis halus, kerutan, dan penurunan elastisitas akibat faktor usia atau paparan lingkungan.",
    "vitiligo":
        "Vitiligo adalah kondisi autoimun yang menyebabkan hilangnya pigmen kulit secara bertahap, menghasilkan bercak putih pada berbagai area tubuh."
  };

  // Metode untuk memuat model dan label, mirip dengan di kode Kotlin
  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/model/mobilenetv3_final_model.tflite');
      await _loadLabels(); // Memanggil fungsi untuk memuat label

      print("Model and labels loaded successfully");
      print(
          "Input shape: ${_interpreter!.getInputTensor(0).shape}, type: ${_interpreter!.getInputTensor(0).type}");
      print(
          "Output shape: ${_interpreter!.getOutputTensor(0).shape}, type: ${_interpreter!.getOutputTensor(0).type}");
    } catch (e) {
      print("Error initializing ML service: $e");
      throw Exception("Failed to initialize ML service");
    }
  }

  // Fungsi baru untuk memuat label dari file txt, mirip `loadLabelList` di Kotlin
  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/model/labels.txt');
      // Memisahkan setiap baris dan memfilter baris yang kosong
      _labels = labelsData
          .split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();
    } catch (e) {
      print("Error loading labels: $e");
      _labels = []; // Kosongkan jika gagal
    }
  }

  // Metode untuk menganalisis gambar
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    if (_interpreter == null || _labels.isEmpty) {
      throw Exception("Model or labels not loaded. Call initialize() first.");
    }

    try {
      final processedInput = await _preprocessImage(imageFile);
      var output = List<double>.filled(1 * _labels.length, 0.0)
          .reshape([1, _labels.length]);

      _interpreter!.run(processedInput, output);
      print("Inference results: $output");

      List<double> probabilities = List<double>.from(output[0]);
      int predictedClass = 0;
      double maxConfidence = 0.0;

      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxConfidence) {
          maxConfidence = probabilities[i];
          predictedClass = i;
        }
      }

      String severity;
      if (maxConfidence > 0.8) {
        severity = 'Tinggi';
      } else if (maxConfidence > 0.6) {
        severity = 'Sedang';
      } else {
        severity = 'Rendah';
      }

      // Menggunakan label yang sudah dimuat dari file
      final predictedLabel = _labels[predictedClass];

      return {
        'condition': predictedLabel,
        'confidence': maxConfidence,
        'severity': severity,
        // Mengambil deskripsi dari Map berdasarkan label yang diprediksi
        'description':
            _descriptions[predictedLabel] ?? "Deskripsi tidak tersedia.",
        'probabilities': probabilities,
        'timestamp': DateTime.now().toIso8601String(),
        'class_index': predictedClass,
      };
    } catch (e) {
      print("Error analyzing image: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> _preprocessImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes)!;

    if (originalImage == null) {
      print("--- MLService Error: Failed to decode image. ---");
      throw Exception("Gagal memproses gambar.");
    }

    // Pastikan gambar adalah RGB jika belum (ini penting jika sumber gambar bervariasi)
    img.Image rgbImage = originalImage;

    final resizedImage = img.copyResize(rgbImage, // Gunakan rgbImage
        width: 224,
        height: 224,
        interpolation:
            img.Interpolation.linear // Atau bilinear jika sudah dipastikan
        );

    var inputData =
        List<double>.filled(1 * 224 * 224 * 3, 0.0).reshape([1, 224, 224, 3]);

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);

        // PERUBAHAN UTAMA: Kirim nilai piksel [0, 255] sebagai double
        // dan pastikan urutan channel adalah RGB
        inputData[0][y][x][0] = pixel.r.toDouble(); // Merah
        inputData[0][y][x][1] = pixel.g.toDouble(); // Hijau
        inputData[0][y][x][2] = pixel.b.toDouble(); // Biru
      }
    }
    print(
        "--- DEBUG MLService: Input to TFLite (first pixel, [0-255] range): [${inputData[0][0][0][0].toStringAsFixed(1)}, ${inputData[0][0][0][1].toStringAsFixed(1)}, ${inputData[0][0][0][2].toStringAsFixed(1)}] ---");
    return inputData;
  }

  void close() {
    _interpreter?.close();
  }
}
