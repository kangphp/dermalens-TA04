// lib/screens/user/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermalens/providers/auth_provider.dart'; //
import 'package:dermalens/models/user_model.dart'; // Pastikan UserModel diimpor
import 'edit_profile_page.dart'; // Import halaman edit profile

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key}); //

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false; //

  @override
  void initState() {
    //
    super.initState();
    _refreshUserData(); //
  }

  Future<void> _refreshUserData() async {
    //
    if (!mounted) return; // Tambahkan pengecekan mounted di awal
    setState(() {
      _isLoading = true; //
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .refreshUserData(); //
    } catch (e) {
      if (mounted) {
        // Tambahkan pengecekan mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'), //
            backgroundColor: Colors.red, //
          ),
        );
      }
    } finally {
      if (mounted) {
        //
        setState(() {
          _isLoading = false; //
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengakses data pengguna dari AuthProvider
    final authProvider = Provider.of<AuthProvider>(context); //
    final UserModel? user = authProvider.user; //

    return Scaffold(
      backgroundColor: const Color(0xFFfefeff), // Background warna baru

      // AppBar
      appBar: AppBar(
        centerTitle: true, //
        backgroundColor: const Color(0xFFfefeff), //
        actions: <Widget>[
          IconButton(
            //
            icon: const Icon(Icons.settings), //
            onPressed: () {
              // Arahkan ke halaman pengaturan jika ada, atau biarkan kosong
            },
          ),
        ],
        leading: IconButton(
          //
          icon: const Icon(Icons.arrow_back_ios_new_rounded), //
          onPressed: () {
            //
            Navigator.pop(context); //
          },
        ),
        iconTheme: const IconThemeData(
          //
          color: Color(0xFF986A2F), //
        ),
        elevation: 0, //
        title: const Text(
          //
          'Profile', //
          style: TextStyle(
            //
            color: Color(0xFF986A2F), //
            fontSize: 24, //
            fontFamily: 'LeagueSpartan', //
            fontWeight: FontWeight.w600, //
          ),
        ),
      ),

      // Body
      body: _isLoading //
          ? const Center(
              //
              child: CircularProgressIndicator(
                //
                color: Color(0xFF986A2F), //
              ),
            )
          : RefreshIndicator(
              //
              onRefresh: _refreshUserData, //
              color: const Color(0xFF986A2F), //
              child: SafeArea(
                //
                child: SingleChildScrollView(
                  //
                  physics: const AlwaysScrollableScrollPhysics(), //
                  child: Padding(
                    //
                    padding: const EdgeInsets.all(24.0), //
                    child: Column(
                      //
                      children: [
                        // Profile Image
                        _buildProfileImageWidget(
                            context, user), // Menggunakan widget baru

                        const SizedBox(height: 31), //

                        // Fields
                        _buildDisplayField(
                            //
                            'Full Name',
                            user?.name ?? 'Not set'), //
                        const SizedBox(height: 13), //
                        _buildDisplayField(
                            //
                            'Phone Number',
                            user?.phone ?? 'Not set'), //
                        const SizedBox(height: 13), //
                        _buildDisplayField(
                            'Email', user?.email ?? 'Not set'), //
                        const SizedBox(height: 13), //
                        _buildDisplayField(
                            'Date of Birth', //
                            'Not set'), // Tambahkan di UserModel jika diperlukan
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // Widget baru untuk menampilkan gambar profil atau inisial
  Widget _buildProfileImageWidget(BuildContext context, UserModel? user) {
    ImageProvider<Object>? backgroundImage;
    String initials = '';

    if (user != null) {
      // Logika untuk mendapatkan inisial nama pengguna
      if (user.name.isNotEmpty) {
        //
        final nameParts = user.name.split(' '); //
        if (nameParts.isNotEmpty) {
          //
          initials = nameParts[0][0]; //
          if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
            //
            initials += nameParts[1][0]; //
          }
        }
        initials = initials.toUpperCase(); //
      }

      // Tentukan ImageProvider berdasarkan user.avatar
      if (user.avatar != null && user.avatar!.isNotEmpty) {
        if (user.avatar!.startsWith('assets/avatars/')) {
          // Jika avatar adalah aset lokal dari stok avatar
          backgroundImage = AssetImage(user.avatar!);
        } else if (user.avatar!.startsWith('http')) {
          // Jika avatar adalah URL (misalnya dari unggahan pengguna di masa depan)
          backgroundImage = NetworkImage(user.avatar!);
        }
        // Anda bisa menambahkan logika lain di sini jika ada sumber avatar lain
      }
    }

    // Jika tidak ada backgroundImage atau user null, gunakan inisial
    if (backgroundImage == null) {
      initials = initials.isEmpty
          ? (user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U')
          : initials;
    }

    return Center(
      //
      child: Stack(
        //
        children: [
          CircleAvatar(
            //
            radius: 48, //
            backgroundColor: const Color(0xFF986A2F).withOpacity(0.7), //
            backgroundImage: backgroundImage,
            child: (backgroundImage == null)
                ? Text(
                    initials, //
                    style:
                        const TextStyle(fontSize: 24, color: Colors.white), //
                  )
                : null,
          ),
          Positioned(
            //
            bottom: 0, //
            right: 0, //
            child: GestureDetector(
              //
              onTap: () {
                //
                Navigator.push(
                  //
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(), //
                  ),
                ).then((value) {
                  //
                  // Refresh data setelah kembali dari halaman edit,
                  // periksa apakah ada perubahan yang disimpan
                  if (value == true) {
                    // Asumsikan EditProfilePage mengembalikan true jika ada perubahan
                    _refreshUserData(); //
                  } else {
                    // Jika tidak ada perubahan signifikan yang memerlukan refresh dari server,
                    // cukup panggil setState untuk memperbarui UI dengan data dari AuthProvider
                    // yang mungkin sudah diperbarui oleh EditProfilePage secara lokal.
                    setState(() {});
                  }
                });
              },
              child: Container(
                //
                padding: const EdgeInsets.all(4), //
                decoration: const BoxDecoration(
                  //
                  color: Colors.brown, //
                  shape: BoxShape.circle, //
                ),
                child: const Icon(
                  //
                  Icons.edit, //
                  color: Colors.white, //
                  size: 20, //
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Display field widget (read-only)
  Widget _buildDisplayField(String label, String value) {
    //
    return Column(
      //
      crossAxisAlignment: CrossAxisAlignment.start, //
      children: [
        _buildFieldLabel(label), //
        Container(
          //
          width: double.infinity, //
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15), //
          decoration: BoxDecoration(
            //
            color: const Color(0xFFEBE2D7), //
            borderRadius: BorderRadius.circular(13), //
          ),
          child: Text(
            //
            value, //
            style: const TextStyle(
              //
              fontSize: 16, //
              color: Colors.black87, //
            ),
          ),
        ),
      ],
    );
  }

  // Field label widget
  Widget _buildFieldLabel(String label) {
    //
    return Padding(
      //
      padding: const EdgeInsets.only(bottom: 8), //
      child: Text(
        //
        label, //
        style: const TextStyle(
          //
          fontSize: 16, //
          fontWeight: FontWeight.w500, //
          color: Colors.black87, //
        ),
      ),
    );
  }
}
