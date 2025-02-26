import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Color(0xFF986A2F),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_rounded),
            color: Color(0xFF986A2F),
            onPressed: () {
              // Arahkan ke halaman profil
            },
          )
        ],
      ),
      backgroundColor: const Color(0xFFF6F5F3), // Warna latar sesuai desain,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gambar ilustrasi wajah
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(
                  image: AssetImage('assets/images/images_1.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Judul dan instruksi
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

            // Tombol Take Photo
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Tambahkan logika untuk mengambil foto
                },
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

            // Tombol Upload Photo
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  // Tambahkan logika untuk mengunggah foto
                },
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
