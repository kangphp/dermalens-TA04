import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:dermalens/models/analysis_result.dart';
import 'package:dermalens/services/ml_service.dart';
import 'result_detail_page.dart';

class ResultPage extends StatelessWidget {
  final File image;
  final String condition;
  final double confidence;

  const ResultPage({
    Key? key,
    required this.image,
    required this.condition,
    required this.confidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create analysis result object
    final result = _createAnalysisResult();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Analisis'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF986A2F),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
            onPressed: () => _analyzeWithModel(context, image),
            tooltip: 'Analisis dengan model AI',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Display image
            Container(
              width: double.infinity,
              height: 300,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Show initial analysis result
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hasil Diagnosis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Kondisi: $condition'),
                  Text('Keyakinan: ${(confidence * 100).toStringAsFixed(1)}%'),
                  Text('Tingkat keparahan: ${result.severity}'),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultDetailPage(
                              image: image,
                              result: result,
                              fromHistory: false,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF986A2F),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Lihat Detail Hasil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to analyze with AI model
  Future<void> _analyzeWithModel(BuildContext context, File imageFile) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Menganalisis gambar...")
            ],
          ),
        ),
      );

      // Initialize ML service
      final mlService = MLService();
      await mlService.initialize(); // Load both model and labels

      // Run analysis - this now returns Map<String, dynamic>
      final Map<String, dynamic> results =
          await mlService.analyzeImage(imageFile);

      // Close loading dialog
      Navigator.of(context).pop();

      // Check for errors
      if (results.containsKey('error')) {
        throw Exception(results['error']);
      }

      // Show results dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hasil Analisis AI'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kondisi: ${results['condition']}'),
                Text(
                    'Keyakinan: ${(results['confidence'] * 100).toStringAsFixed(1)}%'),
                Text('Tingkat keparahan: ${results['severity']}'),
                if (results.containsKey('predictions')) ...[
                  const SizedBox(height: 16),
                  const Text('Detail Prediksi:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var entry
                              in (results['predictions'] as Map<String, double>)
                                  .entries)
                            if (entry.value > 0.01)
                              Text(
                                  '${entry.key}: ${(entry.value * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle error
      Navigator.of(context).pop(); // Close loading dialog if open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  AnalysisResult _createAnalysisResult() {
    // Generate unique ID
    final id = const Uuid().v4();

    // Determine severity based on confidence
    String severity;
    if (confidence > 0.8) {
      severity = 'High';
    } else if (confidence > 0.6) {
      severity = 'Moderate';
    } else {
      severity = 'Low';
    }

    // Get description and recommendations based on condition
    final description = AnalysisResult.getDescriptionForCondition(condition);
    final recommendations =
        AnalysisResult.getRecommendationsForCondition(condition);

    // Create AnalysisResult object
    return AnalysisResult(
      id: id,
      condition: condition,
      confidence: confidence,
      severity: severity,
      image: image,
      imagePath: image.path,
      dateTime: DateTime.now(),
      description: description,
      recommendations: recommendations,
    );
  }
}
