import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermalens/providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Isi form dengan data pengguna yang ada
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _emailController.text = user.email;
      // Tambahkan birthDate jika ada di model
      // _birthDateController.text = user.birthDate ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        // Tambahkan parameter lain jika diperlukan
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman profil
      }
    } catch (e) {
      setState(() {
        String errorMsg = e.toString();
        if (errorMsg.contains('Exception:')) {
          errorMsg = errorMsg.replaceAll('Exception:', '').trim();
        }
        _errorMessage = errorMsg;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to update profile'),
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

  @override
  Widget build(BuildContext context) {
    // Mengakses data pengguna dari AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Mendapatkan inisial nama pengguna untuk avatar
    String initials = '';
    if (user != null && user.name.isNotEmpty) {
      final nameParts = user.name.split(' ');
      if (nameParts.isNotEmpty) {
        initials = nameParts[0][0];
        if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
          initials += nameParts[1][0];
        }
      }
      initials = initials.toUpperCase();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFfefeff),

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
          'Edit Profile',
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Image
                  _buildProfileImage(initials),

                  const SizedBox(height: 31),

                  // Error message display
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),

                  // Fields
                  _buildInputField('Full Name', _nameController,
                      validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  }),
                  const SizedBox(height: 13),
                  _buildInputField('Phone Number', _phoneController),
                  const SizedBox(height: 13),
                  _buildInputField(
                    'Email', _emailController,
                    enabled: false, // Email tidak bisa diubah
                  ),
                  const SizedBox(height: 13),
                  _buildInputField('Date of Birth', _birthDateController),

                  const SizedBox(height: 30),

                  // Button for saving profile changes
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF986A2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Update Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Profile Image
  Widget _buildProfileImage(String initials) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF986A2F),
            radius: 48,
            child: Text(
              initials.isEmpty ? 'U' : initials,
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.brown,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_camera,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable input field widget
  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        TextFormField(
          controller: controller,
          enabled: enabled,
          validator: validator,
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Colors.red),
            ),
            labelStyle: const TextStyle(color: Colors.black),
            filled: true,
            fillColor: enabled
                ? const Color(0xFFEBE2D7)
                : const Color(
                    0xFFE0E0E0), // Warna berbeda untuk field yang disabled
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
