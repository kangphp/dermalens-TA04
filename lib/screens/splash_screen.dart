import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfefeff),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/dermalens.png',
              width: 250,
              height: 200,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Color(0xFF986A2F),
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading...',
              style: TextStyle(
                color: Color(0xFF986A2F),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
