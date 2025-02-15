import 'package:flutter/material.dart';
import 'edit_profile_page.dart'; // Import halaman edit profile

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfefeff), // Background warna baru

      // AppBar
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFfefeff),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF986A2F),
        ),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF986A2F),
            fontSize: 24,
            fontFamily: 'LeagueSpartan',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Body
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile Image
                _buildProfileImage(context), // Pass context to the method

                const SizedBox(height: 31),

                // Fields
                _buildInputField('Full Name'),
                const SizedBox(height: 13),
                _buildInputField('Phone Number'),
                const SizedBox(height: 13),
                _buildInputField('Email'),
                const SizedBox(height: 13),
                _buildInputField('Date of Birth'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Profile Image with edit button
  Widget _buildProfileImage(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF986A2F),
            child: const Text(
              'AH',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            radius: 48,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                // Navigasi ke halaman EditProfilePage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const EditProfilePage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.brown,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable input field widget
  Widget _buildInputField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        TextFormField(
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13), // Menambahkan radius
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            labelStyle: const TextStyle(color: Colors.black),
            filled: true,
            fillColor: const Color(0xFFEBE2D7), // Background warna text field
          ),
        ),
      ],
    );
  }

  // Field label widget
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}
