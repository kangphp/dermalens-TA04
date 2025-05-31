// lib/screens/user/history_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermalens/providers/history_provider.dart';
import 'package:dermalens/screens/user/result_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:dermalens/models/analysis_result.dart'; // <-- TAMBAHKAN BARIS INI

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<HistoryProvider>(context, listen: false).loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Analisis'),
        backgroundColor: const Color(0xFF986A2F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearHistoryDialog(context),
            tooltip: 'Hapus semua riwayat',
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          if (historyProvider.history.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: historyProvider.history.length,
            itemBuilder: (context, index) {
              final item = historyProvider.history[index];
              return _buildHistoryCard(context, item);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, AnalysisResult item) {
    final date = DateFormat('dd MMM yyyy, HH:mm').format(item.dateTime);
    // Gabungkan semua kondisi menjadi satu string
    final conditionsText = item.conditions.join(', ');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      // Penting untuk InkWell dan ClipRRect
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultDetailPage(
                result: item,
                fromHistory: true,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(
              File(item.imagePath),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image,
                      size: 40, color: Colors.grey[600]),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conditionsText, // Menampilkan semua kondisi
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF986A2F),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              _getSeverityColor(item.severity).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.severity,
                          style: TextStyle(
                            color: _getSeverityColor(item.severity),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Riwayat',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hasil analisis yang Anda simpan akan muncul di sini.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Riwayat'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus semua riwayat analisis?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Provider.of<HistoryProvider>(context, listen: false)
                  .clearHistory();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    // Sesuaikan nama severity jika ada perbedaan huruf besar/kecil
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
