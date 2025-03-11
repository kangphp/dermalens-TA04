import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dermalens/screens/user/profile_page.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:provider/provider.dart';
import 'package:dermalens/providers/auth_provider.dart';
import 'package:dermalens/screens/landing_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  File? _selectedImage;
  late Interpreter _interpreter;
  bool _modelLoaded = false;

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        if (_modelLoaded) {
          _runInference(_selectedImage!);
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
    });
  }

  Future<void> _loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/model/model_mbnv3.tflite');
      setState(() {
        _modelLoaded = true;
      });
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load model: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        if (_modelLoaded) {
          _runInference(_selectedImage!);
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
    });
  }

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _runInference(File image) async {
    try {
      // Anda perlu mengubah gambar menjadi tensor yang sesuai untuk model
      // Contoh berikut menggunakan input sederhana, Anda perlu menyesuaikan dengan model Anda
      var input = List.filled(1 * 224 * 224 * 3, 0).reshape([1, 224, 224, 3]);
      var output = List.filled(1 * 1000, 0)
          .reshape([1, 1000]); // Sesuaikan dengan output model Anda

      // Jalankan inferensi
      _interpreter.run(input, output);

      print("Inference results: $output");
    } catch (e) {
      print("Error running inference: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        automaticallyImplyLeading: false, // Remove back button
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 180,
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
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
                onPressed: _takePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF986A2F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                onPressed: _pickImageFromGallery,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF986A2F)),
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
    );
  }
}
