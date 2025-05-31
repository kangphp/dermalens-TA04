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
      print("Model initialized successfully");
    } catch (e) {
      print("Error initializing model: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load model: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      if (_modelLoaded) {
        _analyzeImage(_selectedImage!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Model is still loading. Please wait.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });

      if (_modelLoaded) {
        _analyzeImage(_selectedImage!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Model is still loading. Please wait.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> _analyzeImage(File image) async {
    if (!_modelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Model is not ready yet. Please wait.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Menggunakan MLService untuk menganalisis gambar
      final result = await _mlService.analyzeImage(image);

      // Membuat objek AnalysisResult dari hasil analisis
      final analysisResult = AnalysisResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        condition: result['condition'],
        confidence: result['confidence'],
        severity: result['severity'],
        image: image,
        imagePath: image.path,
        dateTime: DateTime.now(),
        description: result['description'] ??
            AnalysisResult.getDescriptionForCondition(result['condition']),
        recommendations: _getRecommendations(result['condition']),
      );

      // Navigasi ke halaman detail hasil
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResultDetailPage(result: analysisResult, image: image),
          ),
        );
      }
    } catch (e) {
      print("Error analyzing image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Metode untuk mendapatkan rekomendasi berdasarkan kondisi
  List<String> _getRecommendations(String condition) {
    switch (condition) {
      case "Acne":
        return [
          "Gunakan pembersih wajah dengan bahan aktif salicylic acid atau benzoyl peroxide",
          "Hindari makanan berlemak dan tinggi gula",
          "Jangan memencet jerawat untuk mencegah peradangan dan bekas",
          "Konsultasikan dengan dokter kulit jika jerawat parah atau tidak membaik"
        ];
      case "Eczema":
        return [
          "Gunakan pelembab hypoallergenic secara rutin",
          "Hindari produk berbahan keras seperti sabun dengan pewangi",
          "Gunakan pakaian yang lembut dan tidak terlalu ketat",
          "Konsultasikan dengan dokter untuk pengobatan topikal bila diperlukan"
        ];
      case "Melanoma":
        return [
          "Segera konsultasikan dengan dokter spesialis kulit",
          "Lakukan biopsi untuk konfirmasi diagnosis",
          "Lindungi kulit dari paparan sinar UV dengan sunscreen SPF 30+",
          "Lakukan pemeriksaan kulit secara berkala untuk mendeteksi tanda-tanda baru"
        ];
      case "Normal Skin":
        return [
          "Pertahankan rutinitas perawatan kulit dengan pembersih lembut",
          "Aplikasikan sunscreen setiap hari",
          "Konsumsi makanan bergizi dan minum air yang cukup",
          "Lakukan eksfoliasi ringan 1-2 kali seminggu"
        ];
      case "Psoriasis":
        return [
          "Gunakan pelembab secara teratur untuk mengurangi kekeringan dan gatal",
          "Hindari pemicu seperti stres dan cedera pada kulit",
          "Gunakan obat topikal yang diresepkan dokter seperti kortikosteroid",
          "Pertimbangkan terapi cahaya (fototerapi) sesuai saran dokter"
        ];
      case "Rosacea":
        return [
          "Hindari pemicu seperti makanan pedas, alkohol, dan paparan sinar matahari",
          "Gunakan sunscreen setiap hari untuk melindungi kulit",
          "Pilih produk perawatan kulit yang lembut dan bebas alkohol",
          "Konsultasikan dengan dokter untuk pengobatan dengan antibiotik topikal"
        ];
      case "Tinea":
        return [
          "Gunakan obat antijamur topikal yang dijual bebas",
          "Jaga area yang terinfeksi tetap kering dan bersih",
          "Hindari berbagi handuk dan pakaian dengan orang lain",
          "Konsultasikan dengan dokter jika infeksi tidak membaik dalam 2 minggu"
        ];
      default:
        return [
          "Konsultasikan dengan dokter kulit untuk diagnosis dan penanganan lebih lanjut",
          "Jaga kebersihan dan kelembapan kulit",
          "Hindari penggunaan produk yang dapat mengiritasi kulit"
        ];
    }
  }

  void _logout() async {
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        // Remove back button
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
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    child: Image.asset(
                      'assets/images/images_1.jpg',
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
                    onPressed: _isLoading ? null : _takePhoto,
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
                    onPressed: _isLoading ? null : _pickImageFromGallery,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: _isLoading
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
