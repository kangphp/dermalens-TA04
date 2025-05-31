// lib/services/ml_service.dart
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class MLService {
  Interpreter? _skinAnalysisInterpreter;
  List<String> _skinLabels = [];

  // Dibuat private dan diakses melalui metode publik jika perlu, atau digunakan internal
  static final Map<String, String> _descriptions = {
    "berjerawat":
        "Jerawat adalah kondisi kulit yang terjadi akibat penyumbatan pori-pori oleh minyak dan sel kulit mati, sering kali menyebabkan bintik-bintik merah atau pustula.",
    "berminyak":
        "Kulit berminyak ditandai dengan produksi sebum berlebih yang membuat kulit tampak mengkilap, sering kali menyebabkan komedo dan jerawat.",
    "dermatitis perioral":
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

  // Metode untuk mendapatkan deskripsi, bisa dipanggil dari luar jika dibuat static public
  static String getDescriptionForCondition(String conditionKey) {
    return _descriptions[conditionKey.toLowerCase()] ??
        "Deskripsi tidak tersedia.";
  }

  // Metode untuk mendapatkan rekomendasi, dipindahkan ke sini
  static List<String> getRecommendationsForCondition(String condition) {
    final lowerCaseCondition = condition.toLowerCase();
    // Anda bisa menggunakan _descriptions.containsKey(lowerCaseCondition) di sini jika perlu
    // sebelum switch, atau langsung saja seperti ini jika semua label ada di switch.

    switch (lowerCaseCondition) {
      case "Berjerawat": // Pastikan label ini sesuai dengan yang ada di labels.txt dan _descriptions
        return [
          "Gunakan pembersih wajah dengan bahan aktif salicylic acid atau benzoyl peroxide.",
          "Hindari makanan berlemak dan tinggi gula.",
          "Jangan memencet jerawat untuk mencegah peradangan dan bekas.",
          "Konsultasikan dengan dokter kulit jika jerawat parah atau tidak membaik."
        ];
      case "Berminyak":
        return [
          "Gunakan pembersih wajah yang lembut dan non-komedogenik.",
          "Gunakan pelembap berbahan dasar air (water-based).",
          "Gunakan kertas minyak untuk menyerap kelebihan sebum.",
          "Hindari produk berbasis minyak."
        ];
      case "Dermatitis Perioral":
        return [
          "Hentikan penggunaan krim steroid topikal jika sedang digunakan (konsultasi dokter).",
          "Gunakan pembersih yang sangat lembut dan hindari produk iritatif.",
          "Hindari pasta gigi berfluoride tinggi untuk sementara jika ruam di sekitar mulut.",
          "Konsultasikan dengan dokter untuk antibiotik topikal atau oral."
        ];
      case "Kering":
        return [
          "Gunakan pelembap kaya emolien secara teratur, terutama setelah mandi.",
          "Hindari mandi air panas terlalu lama.",
          "Gunakan sabun yang lembut dan melembapkan.",
          "Pertimbangkan penggunaan humidifier di ruangan ber-AC."
        ];
      case "Normal":
        return [
          "Pertahankan rutinitas perawatan kulit dengan pembersih lembut.",
          "Gunakan pelembap ringan dan sunscreen setiap hari.",
          "Lakukan eksfoliasi ringan 1-2 kali seminggu jika perlu."
        ];
      case "Penuaan":
        return [
          "Gunakan produk dengan retinoid atau retinol (konsultasi untuk memulai).",
          "Gunakan sunscreen SPF 30+ setiap hari.",
          "Konsumsi antioksidan dan jaga hidrasi kulit.",
          "Pertimbangkan perawatan profesional seperti chemical peeling atau microneedling."
        ];
      case "Vitiligo":
        return [
          "Segera konsultasikan dengan dokter kulit untuk diagnosis dan pilihan terapi.",
          "Lindungi area kulit yang terkena dari paparan sinar matahari dengan sunscreen tinggi SPF.",
          "Pertimbangkan penggunaan kosmetik kamuflase jika diinginkan.",
          "Pahami bahwa ini adalah kondisi autoimun dan manajemennya berkelanjutan."
        ];
      // Tambahkan case lain jika ada
      default:
        return [
          "Konsultasikan dengan dokter kulit untuk diagnosis dan penanganan lebih lanjut.",
          "Jaga kebersihan dan kelembapan kulit.",
          "Hindari penggunaan produk yang dapat mengiritasi kulit."
        ];
    }
  }

  Future<void> initialize() async {
    try {
      _skinAnalysisInterpreter = await Interpreter.fromAsset(
          'assets/model/mobilenetv3_final_model.tflite');
      await _loadSkinLabels();
      print(
          "Skin analysis model loaded successfully. Face detection will use ML Kit.");
      if (_skinAnalysisInterpreter != null) {
        print(
            "Input shape (skin): ${_skinAnalysisInterpreter!.getInputTensor(0).shape}, type: ${_skinAnalysisInterpreter!.getInputTensor(0).type}");
        print(
            "Output shape (skin): ${_skinAnalysisInterpreter!.getOutputTensor(0).shape}, type: ${_skinAnalysisInterpreter!.getOutputTensor(0).type}");
      }
    } catch (e) {
      print("Error initializing ML service: $e");
      throw Exception("Failed to initialize ML service");
    }
  }

  Future<void> _loadSkinLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/model/labels.txt');
      _skinLabels = labelsData
          .split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();
    } catch (e) {
      print("Error loading skin labels: $e");
      _skinLabels = [];
    }
  }

  Future<bool> _detectFaceWithMLKit(File imageFile) async {
    print("Attempting face detection with ML Kit...");
    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final options = FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
      );
      final faceDetector = FaceDetector(options: options);

      final List<Face> faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();

      if (faces.isNotEmpty) {
        print("${faces.length} face(s) detected.");
        return true;
      } else {
        print("No face detected.");
        return false;
      }
    } catch (e) {
      print("Error during ML Kit face detection: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    final bool faceDetected = await _detectFaceWithMLKit(imageFile);
    if (!faceDetected) {
      return {
        'error':
            'Wajah tidak terdeteksi pada gambar. Pastikan wajah terlihat jelas.',
        'face_detected': false,
      };
    }

    if (_skinAnalysisInterpreter == null || _skinLabels.isEmpty) {
      return {
        'error': "Model analisis kulit belum siap. Silakan coba lagi.",
        'face_detected': true,
      };
    }

    try {
      final processedInput = await _preprocessImageForSkinAnalysis(imageFile);
      var output = List<double>.filled(1 * _skinLabels.length, 0.0)
          .reshape([1, _skinLabels.length]);

      _skinAnalysisInterpreter!.run(processedInput, output);
      print("Skin analysis inference results: $output");

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

      final predictedLabel = _skinLabels[predictedClass];

      return {
        'face_detected': true,
        'condition': predictedLabel,
        'confidence': maxConfidence,
        'severity': severity,
        'description': getDescriptionForCondition(
            predictedLabel), // Memanggil metode static
        'recommendations': getRecommendationsForCondition(
            predictedLabel), // Memanggil metode static
        'probabilities': probabilities,
        'timestamp': DateTime.now().toIso8601String(),
        'class_index': predictedClass,
      };
    } catch (e) {
      print("Error analyzing skin image: $e");
      return {
        'error':
            'Terjadi kesalahan saat menganalisis kondisi kulit: ${e.toString()}',
        'face_detected': true,
      };
    }
  }

  Future<List<dynamic>> _preprocessImageForSkinAnalysis(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      print(
          "--- MLService Error: Failed to decode image for skin analysis. ---");
      throw Exception("Gagal memproses gambar untuk analisis kulit.");
    }

    img.Image rgbImage = originalImage;
    final resizedImage = img.copyResize(rgbImage,
        width: 224, height: 224, interpolation: img.Interpolation.linear);

    var inputData =
        List<double>.filled(1 * 224 * 224 * 3, 0.0).reshape([1, 224, 224, 3]);

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);
        inputData[0][y][x][0] = pixel.r.toDouble();
        inputData[0][y][x][1] = pixel.g.toDouble();
        inputData[0][y][x][2] = pixel.b.toDouble();
      }
    }
    print(
        "--- DEBUG MLService: Input to Skin TFLite (first pixel, [0-255] range): [${inputData[0][0][0][0].toStringAsFixed(1)}, ${inputData[0][0][0][1].toStringAsFixed(1)}, ${inputData[0][0][0][2].toStringAsFixed(1)}] ---");
    return inputData;
  }

  void close() {
    _skinAnalysisInterpreter?.close();
  }
}
