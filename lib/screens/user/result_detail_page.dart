// lib/screens/user/result_detail_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermalens/models/analysis_result.dart';
import 'package:dermalens/providers/history_provider.dart';
import 'package:intl/intl.dart';

class ResultDetailPage extends StatelessWidget {
  final AnalysisResult result;
  final bool fromHistory;

  const ResultDetailPage({
    Key? key,
    required this.result,
    this.fromHistory = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Analisis'),
        actions: [
          if (!fromHistory)
            IconButton(
              icon: const Icon(Icons.save_alt),
              tooltip: 'Simpan ke Riwayat',
              onPressed: () {
                Provider.of<HistoryProvider>(context, listen: false)
                    .addResult(result);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hasil berhasil disimpan ke riwayat.'),
                    backgroundColor: Color(0xFF986A2F),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analisis pada ${DateFormat('d MMMM yyyy, HH:mm').format(result.dateTime)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (result.image != null) // Tampilkan dari File object jika ada
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(result.image!,
                    fit: BoxFit.cover, width: double.infinity),
              )
            else // Jika tidak, tampilkan dari path
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(result.imagePath),
                    fit: BoxFit.cover, width: double.infinity),
              ),
            const SizedBox(height: 24),
            _buildResultsCard(context, result),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context, AnalysisResult result) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Kondisi dan Severity ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kondisi Terdeteksi',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF986A2F)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(result.severity).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    result.severity,
                    style: TextStyle(
                        color: _getSeverityColor(result.severity),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: result.conditions.map((condition) {
                final confidence = (result.confidences[condition] ?? 0.0) * 100;
                return Chip(
                  label:
                      Text('${condition} (${confidence.toStringAsFixed(1)}%)'),
                  backgroundColor: const Color(0xFF986A2F).withOpacity(0.1),
                  labelStyle: const TextStyle(color: Color(0xFF986A2F)),
                  side: BorderSide.none,
                );
              }).toList(),
            ),
            const Divider(height: 32),

            // --- Bagian Deskripsi ---
            const Text('Tentang Kondisi Ini',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (int i = 0; i < result.conditions.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                          text: '${result.conditions[i]}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: result.descriptions[i]),
                    ],
                  ),
                ),
              ),
            const Divider(height: 32),

            // --- Bagian Rekomendasi ---
            const Text('Rekomendasi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...result.recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF986A2F))),
                      Expanded(
                          child: Text(rec,
                              style:
                                  const TextStyle(fontSize: 15, height: 1.4))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'tinggi':
        return Colors.red[700]!;
      case 'sedang':
        return Colors.orange[700]!;
      case 'rendah':
        return Colors.green[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}
