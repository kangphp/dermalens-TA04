import 'dart:io';
import 'dart:convert';

class AnalysisResult {
  final String id;
  final String condition;
  final double confidence;
  final String severity;
  final String imagePath;
  final File?
      image; // Make it nullable since we might not always have the File object
  final DateTime dateTime;
  final String description;
  final List<dynamic> recommendations;

  AnalysisResult({
    required this.id,
    required this.condition,
    required this.confidence,
    required this.severity,
    required this.imagePath,
    this.image, // Optional parameter
    required this.dateTime,
    required this.description,
    required this.recommendations,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'condition': condition,
      'confidence': confidence,
      'severity': severity,
      'imagePath': imagePath,
      'dateTime': dateTime.toIso8601String(),
      'description': description,
      'recommendations': jsonEncode(recommendations),
    };
  }

  // Create from Map when loading from storage
  factory AnalysisResult.fromMap(Map map) {
    var recommendationsData;

    // Handle both cases: when recommendations is a string or already a list
    if (map['recommendations'] is String) {
      recommendationsData = jsonDecode(map['recommendations']);
    } else {
      recommendationsData = map['recommendations'];
    }

    return AnalysisResult(
      id: map['id'],
      condition: map['condition'],
      confidence: map['confidence'],
      severity: map['severity'],
      imagePath: map['imagePath'],
      dateTime: DateTime.parse(map['dateTime']),
      description: map['description'],
      recommendations: recommendationsData,
    );
  }

  // Static method to get description for a condition
  static String getDescriptionForCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'akne':
        return 'Akne atau jerawat adalah kondisi kulit yang terjadi ketika folikel rambut tersumbat oleh minyak dan sel kulit mati.';
      case 'eksim':
        return 'Eksim (dermatitis atopik) adalah kondisi kulit kronis yang ditandai dengan kulit kering, gatal, dan kemerahan.';
      case 'psoriasis':
        return 'Psoriasis adalah kondisi autoimun yang menyebabkan pertumbuhan sel kulit yang terlalu cepat, menghasilkan bercak merah tebal dengan sisik putih atau perak.';
      case 'melanoma':
        return 'Melanoma adalah jenis kanker kulit yang paling berbahaya, yang berkembang dari sel-sel yang memberi warna pada kulit (melanosit).';
      default:
        return 'Kondisi kulit ini memerlukan perhatian medis. Silakan konsultasikan dengan dokter kulit untuk diagnosis dan perawatan yang tepat.';
    }
  }

  // Static method to get recommendations for a condition
  static List<String> getRecommendationsForCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'akne':
        return [
          'Cuci wajah dua kali sehari dengan pembersih yang lembut',
          'Hindari menyentuh wajah dengan tangan yang kotor',
          'Gunakan produk perawatan kulit non-komedogenik',
          'Konsultasikan dengan dokter kulit untuk pengobatan yang sesuai'
        ];
      case 'eksim':
        return [
          'Gunakan pelembab secara teratur',
          'Hindari pemicu yang diketahui (seperti deterjen keras, bahan kimia)',
          'Mandi dengan air hangat, tidak panas',
          'Konsultasikan dengan dokter kulit untuk pengobatan yang sesuai'
        ];
      case 'psoriasis':
        return [
          'Gunakan pelembab untuk mengurangi kekeringan dan iritasi',
          'Hindari pemicu seperti stres, cedera kulit, atau infeksi',
          'Paparan sinar matahari dalam jumlah terbatas dapat membantu (sesuai saran dokter)',
          'Konsultasikan dengan dokter kulit untuk pengobatan yang sesuai'
        ];
      case 'melanoma':
        return [
          'Segera periksakan diri ke dokter kulit',
          'Hindari paparan sinar UV berlebihan',
          'Lakukan pemeriksaan kulit secara rutin',
          'Ikuti semua rekomendasi pengobatan dari dokter'
        ];
      default:
        return [
          'Konsultasikan dengan dokter kulit untuk diagnosis yang akurat',
          'Hindari menggores atau mengganggu area yang terkena',
          'Catat perkembangan kondisi kulit Anda',
          'Ikuti rekomendasi pengobatan dokter'
        ];
    }
  }
}
