import 'package:dermalens/services/ml_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermalens/providers/auth_provider.dart';
import 'package:dermalens/providers/history_provider.dart';
import 'package:dermalens/screens/landing_page.dart';
import 'package:dermalens/screens/user/dashboard_page.dart';
import 'package:dermalens/screens/splash_screen.dart';

void main() async {
  // Pastikan binding diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  final mlService = MLService();
  await mlService.loadModel();

  runApp(
    // Bungkus aplikasi dengan MultiProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DermaLens',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF986A2F)),
        useMaterial3: true,
        fontFamily: 'LeagueSpartan',
        primaryColor: const Color(0xFF986A2F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFfefeff),
          foregroundColor: Color(0xFF986A2F),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF986A2F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      // Gunakan AuthWrapper sebagai home
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Inisialisasi auth provider setelah widget dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Akses auth provider
    final authProvider = Provider.of<AuthProvider>(context);

    // Tampilkan splash screen selama inisialisasi
    if (!authProvider.isInitialized) {
      return const SplashScreen();
    }

    // Jika user sudah login, tampilkan dashboard
    if (authProvider.isLoggedIn) {
      return const DashboardPage();
    }

    // Jika belum login, tampilkan landing page
    return const LandingPage();
  }
}
