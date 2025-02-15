import 'package:flutter/material.dart';

import '../auth/login_page.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

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
                _buildProfileImage(),

                const SizedBox(height: 31),

                // Fields
                _buildInputField('Full Name'),
                const SizedBox(height: 13),
                _buildInputField('Phone Number'),
                const SizedBox(height: 13),
                _buildInputField('Email'),
                const SizedBox(height: 13),
                _buildInputField('Date of Birth'),

                const SizedBox(height: 20),

                // Button for saving or submitting the profile changes
                ElevatedButton(
                  onPressed: () {
                    // You can add functionality here, such as navigating to a login page or saving changes
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF986A2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Update Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'LeagueSpartan',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Profile Image with edit button
  Widget _buildProfileImage() {
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
            // Border dihilangkan
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13), // Menambahkan radius
              borderSide:
                  BorderSide(color: Colors.transparent), // Menghilangkan border
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(13), // Menambahkan radius saat fokus
              borderSide: BorderSide(
                  color: Colors.transparent), // Menghilangkan border saat fokus
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
