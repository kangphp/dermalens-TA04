// lib/screens/user/dashboard_page.dart
import 'dart:io';
import 'package:dermalens/screens/user/history_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dermalens/screens/user/profile_page.dart';
import 'package:provider/provider.dart';
import 'package:dermalens/providers/auth_provider.dart';
import 'package:dermalens/screens/landing_page.dart';
import 'package:dermalens/services/ml_service.dart';
import 'package:dermalens/models/analysis_result.dart';
import 'package:dermalens/screens/user/result_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  File? _selectedImage;
  final MLService _mlService = MLService();
  bool _isLoading = false;
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _mlService.initialize();
      setState(() {
        _modelLoaded = true;
      });
      print("MLService initialized successfully on dashboard");
    } catch (e) {
      print("Error initializing MLService on dashboard: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat model: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processPickedImage(XFile? pickedFile) async {
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      if (_modelLoaded && _selectedImage != null) {
        _analyzeImage(_selectedImage!);
      } else if (!_modelLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Model belum siap, mohon tunggu.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    await _processPickedImage(pickedFile);
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    await _processPickedImage(pickedFile);
  }

  Future<void> _analyzeImage(File image) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final resultData = await _mlService.analyzeImage(image);

      if (mounted) {
        if (resultData.containsKey('error')) {
          String errorMessage = resultData['error'];
          // bool faceWasDetected = resultData['face_detected'] ?? false; // Bisa digunakan jika perlu logika berbeda

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor:
                  Colors.orange, // Umumnya error dari validasi atau deteksi
            ),
          );
        } else {
          // Tidak ada key 'error', berarti analisis berhasil
          final analysisResult = AnalysisResult(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            condition: resultData['condition'] ?? 'Tidak Diketahui',
            confidence: resultData['confidence'] ?? 0.0,
            severity: resultData['severity'] ?? 'Tidak Diketahui',
            image: image,
            imagePath: image.path,
            dateTime: resultData['timestamp'] != null
                ? DateTime.parse(resultData['timestamp'])
                : DateTime.now(),
            description: resultData['description'] ??
                MLService.getDescriptionForCondition(
                    resultData['condition'] ?? ''),
            recommendations: resultData['recommendations'] ??
                MLService.getRecommendationsForCondition(
                    resultData['condition'] ?? []),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ResultDetailPage(result: analysisResult, image: image),
            ),
          );
        }
      }
    } catch (e) {
      print("Error in _analyzeImage (Dashboard): $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan tidak terduga: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // HAPUS _getRecommendations DARI SINI KARENA SUDAH PINDAH KE MLService

  void _logout() async {
    // ... (implementasi logout tetap sama)
    try {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LandingPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (UI build tetap sama)
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: user != null
            ? Text(
                'Hello, ${user.name}',
                style: const TextStyle(
                  color: Color(0xFF986A2F),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            color: const Color(0xFF986A2F),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_rounded),
            color: const Color(0xFF986A2F),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            color: const Color(0xFF986A2F),
            onPressed: _logout,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6F5F3),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: Image.asset(
                      'assets/images/dashboard_image.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Mulai Selfie',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF070707),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '• Tidak memakai make up, kacamata, Masker\n'
                  '• Pastikan rambut tidak menutupi wajah\n'
                  '• Menghadap ke kamera dengan ekspresi rileks\n'
                  '• Pastikan cahaya ruangan cukup terang',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF707070),
                  ),
                  textAlign: TextAlign.left,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        (_isLoading || !_modelLoaded) ? null : _takePhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF986A2F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor:
                          const Color(0xFF986A2F).withOpacity(0.5),
                    ),
                    child: const Text(
                      'Take Photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: (_isLoading || !_modelLoaded)
                        ? null
                        : _pickImageFromGallery,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: (_isLoading || !_modelLoaded)
                              ? const Color(0xFF986A2F).withOpacity(0.5)
                              : const Color(0xFF986A2F)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Upload Photo',
                      style: TextStyle(
                        color: Color(0xFF986A2F),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF986A2F),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mlService.close();
    super.dispose();
  }
}
