// lib/models/analysis_result.dart

import 'dart:io';

/// Kelas model data yang MURNI untuk menyimpan hasil analisis.
/// Kelas ini tidak mengandung logika bisnis seperti mengambil deskripsi atau rekomendasi.
/// Tanggung jawabnya hanya untuk MEMEGANG DATA.
class AnalysisResult {
  final String id;
  // DIUBAH: Mendukung multi-label
  final List<String> conditions;
  final Map<String, double> confidences;
  final String severity;
  final String imagePath;
  final File? image; // Nullable, karena tidak disimpan di database
  final DateTime dateTime;
  // DIUBAH: Mendukung multi-label
  final List<String> descriptions;
  final List<String> recommendations;

  AnalysisResult({
    required this.id,
    required this.conditions,
    required this.confidences,
    required this.severity,
    required this.imagePath,
    this.image,
    required this.dateTime,
    required this.descriptions,
    required this.recommendations,
  });

  /// Mengonversi objek AnalysisResult menjadi Map.
  /// Berguna untuk menyimpan ke database lokal (Hive, SharedPreferences) atau mengirim ke API.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conditions': conditions, // Disimpan sebagai List<String>
      'confidences': confidences, // Disimpan sebagai Map<String, double>
      'severity': severity,
      'imagePath': imagePath,
      'dateTime': dateTime.toIso8601String(),
      'descriptions': descriptions, // Disimpan sebagai List<String>
      'recommendations': recommendations, // Disimpan sebagai List<String>
    };
  }

  /// Membuat objek AnalysisResult dari Map.
  /// Berguna saat memuat data dari database lokal atau API.
  factory AnalysisResult.fromMap(Map<String, dynamic> map) {
    return AnalysisResult(
      id: map['id'] ?? '',
      // Dikuatkan dengan type casting dan nilai default untuk keamanan
      conditions: List<String>.from(map['conditions'] ?? []),
      confidences: Map<String, double>.from(map['confidences'] ?? {}),
      severity: map['severity'] ?? 'Tidak Diketahui',
      imagePath: map['imagePath'] ?? '',
      dateTime: DateTime.tryParse(map['dateTime'] ?? '') ?? DateTime.now(),
      descriptions: List<String>.from(map['descriptions'] ?? []),
      recommendations: List<String>.from(map['recommendations'] ?? []),
    );
  }

// DIHAPUS: Metode static getDescriptionForCondition
// DIHAPUS: Metode static getRecommendationsForCondition
// Alasan: Logika ini seharusnya berada di service layer (MLService), bukan di model data.
// Ini mengikuti Prinsip Tanggung Jawab Tunggal (Single Responsibility Principle).
}
