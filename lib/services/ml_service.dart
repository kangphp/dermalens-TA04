import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  Interpreter? _interpreter;

  // Daftar kondisi kulit (sesuaikan dengan model Anda)
  static const List<String> skinConditions = [
    "Jerawat",
    "Berminyak",
    "Dermatitis Perioral",
    "Kering",
    "Normal",
    "Penuaan",
    "Vitiligo"
  ];

  // Deskripsi kondisi (dapat disesuaikan)
  static const List<String> descriptions = [
    "Jerawat adalah kondisi kulit yang terjadi akibat penyumbatan pori-pori oleh minyak dan sel kulit mati, sering kali menyebabkan bintik-bintik merah atau pustula.",
    "Kulit berminyak ditandai dengan produksi sebum berlebih yang membuat kulit tampak mengkilap, sering kali menyebabkan komedo dan jerawat.",
    "Dermatitis perioral adalah peradangan kulit berupa ruam kemerahan di sekitar mulut, kadang menyebar ke hidung dan mata, disertai rasa gatal atau terbakar.",
    "Kulit kering adalah kondisi kulit dengan tingkat kelembapan rendah yang menyebabkan tekstur kasar, pecah-pecah, dan mudah teriritasi.",
    "Kulit normal memiliki keseimbangan antara kandungan air dan minyak, tidak terlalu kering atau berminyak, serta jarang mengalami masalah kulit.",
    "Penuaan kulit ditandai dengan munculnya garis halus, kerutan, dan penurunan elastisitas akibat faktor usia atau paparan lingkungan.",
    "Vitiligo adalah kondisi autoimun yang menyebabkan hilangnya pigmen kulit secara bertahap, menghasilkan bercak putih pada berbagai area tubuh."
  ];

  // Metode initialize yang akan dipanggil oleh result_page.dart
  Future<void> initialize() async {
    bool success = await loadModel();
    if (!success) {
      throw Exception("Failed to initialize ML service: model loading failed");
    }
  }

  // Metode yang mungkin sudah ada di dashboard_page
  Future<bool> loadModel() async {
    try {
      // Gunakan path yang sama dengan yang di dashboard_page
      _interpreter = await Interpreter.fromAsset(
          'assets/model/efficientnetb3_model_opt.tflite');
      print("Model loaded successfully");

      // Cetak informasi tensor untuk verifikasi
      print(
          "Input shape: ${_interpreter!.getInputTensor(0).shape}, type: ${_interpreter!.getInputTensor(0).type}");
      print(
          "Output shape: ${_interpreter!.getOutputTensor(0).shape}, type: ${_interpreter!.getOutputTensor(0).type}");
      return true;
    } catch (e) {
      print("Error loading model: $e");
      return false;
    }
  }

  // Metode untuk menganalisis gambar
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    if (_interpreter == null) {
      throw Exception(
          "Model belum dimuat. Panggil initialize() terlebih dahulu.");
    }

    try {
      // Preprocess image - gunakan logika yang sama dengan dashboard_page
      final processedInput = await _preprocessImage(imageFile);

      // Set up output tensor
      var output = List<double>.filled(1 * 7, 0.0).reshape([1, 7]);

      // Run inference
      _interpreter!.run(processedInput, output);
      print("Inference results: $output");

      // Process results - ambil class dengan confidence tertinggi
      List<double> probabilities = List<double>.from(output[0]);

      // Mencari nilai tertinggi dan indeksnya
      int predictedClass = 0;
      double maxConfidence = probabilities[0];

      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxConfidence) {
          maxConfidence = probabilities[i];
          predictedClass = i;
        }
      }

      // Menentukan tingkat keparahan berdasarkan confidence
      String severity;
      if (maxConfidence > 0.8) {
        severity = 'Tinggi';
      } else if (maxConfidence > 0.6) {
        severity = 'Sedang';
      } else {
        severity = 'Rendah';
      }

      // Mengembalikan hasil analisis
      return {
        'condition': skinConditions[predictedClass],
        'confidence': maxConfidence,
        'severity': severity,
        'description': descriptions[predictedClass],
        'probabilities': probabilities,
        'timestamp': DateTime.now().toIso8601String(),
        'class_index': predictedClass,
      };
    } catch (e) {
      print("Error analyzing image: $e");
      rethrow;
    }
  }

  // Preprocessing sesuai dengan yang diimplementasikan di dashboard_page
  Future<List<dynamic>> _preprocessImage(File imageFile) async {
    // Baca gambar
    final imageBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes)!;

    // Resize ke 300x300 (sesuai dengan input shape model)
    final resizedImage = img.copyResize(originalImage, width: 300, height: 300);

    // Buat buffer untuk input tensor
    var inputData =
        List<double>.filled(1 * 300 * 300 * 3, 0.0).reshape([1, 300, 300, 3]);

    // Normalisasi pixel values (0-1)
    for (int y = 0; y < 300; y++) {
      for (int x = 0; x < 300; x++) {
        final pixel = resizedImage.getPixel(x, y);

        // Untuk image package v4+
        inputData[0][y][x][0] = pixel.r / 255.0; // Red
        inputData[0][y][x][1] = pixel.g / 255.0; // Green
        inputData[0][y][x][2] = pixel.b / 255.0; // Blue
      }
    }

    return inputData;
  }

  // Cleanup resources
  void close() {
    _interpreter?.close();
  }
}
