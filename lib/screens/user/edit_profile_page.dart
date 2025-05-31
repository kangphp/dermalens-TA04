import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dermalens/providers/auth_provider.dart';
import 'package:dermalens/models/user_model.dart'; // Pastikan UserModel diimpor

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

  String?
      _selectedAvatarPath; // Menyimpan path avatar yang dipilih atau dari user
  bool _isLoading = false;
  String? _errorMessage;

  // Daftar path ke stok avatar Anda
  final List<String> _stockAvatars = [
    'assets/avatars/ava_1.png',
    'assets/avatars/ava_2.png',
    'assets/avatars/ava_3.png',
    'assets/avatars/ava_4.png',
    'assets/avatars/ava_5.png',
    'assets/avatars/ava_6.png',
    'assets/avatars/ava_7.png',
    'assets/avatars/ava_8.png',
    'assets/avatars/ava_9.png',
    'assets/avatars/ava_10.png',
    'assets/avatars/ava_11.png',
    'assets/avatars/ava_12.png',
    // Pastikan path ini sesuai dengan yang ada di assets/avatars/
    // dan file gambar placeholder ada jika Anda menggunakannya
    // 'assets/avatars/default_placeholder.png'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _emailController.text = user.email;
      _selectedAvatarPath = user.avatar; // Muat avatar yang tersimpan
      // _birthDateController.text = user.birthDate ?? ''; // Jika ada
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
        avatar: _selectedAvatarPath, // Kirim path avatar yang dipilih
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(
            context, true); // Mengembalikan true untuk menandakan ada update
      }
    } catch (e) {
      if (mounted) {
        // Pastikan widget masih mounted sebelum memanggil setState
        setState(() {
          String errorMsg = e.toString();
          if (errorMsg.contains('Exception:')) {
            errorMsg = errorMsg.replaceAll('Exception:', '').trim();
          }
          _errorMessage = errorMsg;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        // Pastikan widget masih mounted sebelum memanggil setState
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAvatarDisplay(UserModel? user) {
    ImageProvider<Object>? backgroundImage;
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
    } else if (user == null && _nameController.text.isNotEmpty) {
      // Fallback ke _nameController jika user null tapi nama sedang diisi
      final nameParts = _nameController.text.split(' ');
      if (nameParts.isNotEmpty) {
        initials = nameParts[0][0];
        if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
          initials += nameParts[1][0];
        }
      }
      initials = initials.toUpperCase();
    }

    if (_selectedAvatarPath != null && _selectedAvatarPath!.isNotEmpty) {
      if (_selectedAvatarPath!.startsWith('assets/avatars/')) {
        backgroundImage = AssetImage(_selectedAvatarPath!);
      } else if (_selectedAvatarPath!.startsWith('http')) {
        backgroundImage = NetworkImage(_selectedAvatarPath!);
      }
    }

    // Jika tidak ada backgroundImage yang valid, tampilkan inisial atau placeholder
    if (backgroundImage == null) {
      initials =
          initials.isEmpty ? 'U' : initials; // Default 'U' jika tidak ada nama
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
      backgroundImage: backgroundImage,
      child: (backgroundImage == null)
          ? Text(
              initials,
              style: TextStyle(
                  fontSize: 40, color: Theme.of(context).primaryColor),
            )
          : null,
    );
  }

  Widget _buildAvatarSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Choose Avatar'),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _stockAvatars.length,
            itemBuilder: (context, index) {
              final avatarPath = _stockAvatars[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatarPath = avatarPath;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedAvatarPath == avatarPath
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      width: _selectedAvatarPath == avatarPath ? 3 : 1,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(avatarPath),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFfefeff),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFfefeff),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context,
                false); // Mengembalikan false karena tidak ada update dari tombol kembali
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Widget untuk menampilkan avatar yang dipilih atau default
                  _buildAvatarDisplay(user),
                  const SizedBox(height: 16),

                  // Widget untuk memilih dari stok avatar
                  _buildAvatarSelector(),
                  const SizedBox(height: 31),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style:
                            TextStyle(color: Colors.red.shade700, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

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
                    'Email',
                    _emailController,
                    enabled: false,
                  ),
                  const SizedBox(height: 13),
                  _buildInputField('Date of Birth', _birthDateController,
                      hintText: 'DD/MM/YYYY (Optional)'), // Contoh hintText
                  const SizedBox(height: 30),
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

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    String? Function(String?)? validator,
    String? hintText, // Tambahkan parameter hintText
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
            hintText: hintText, // Gunakan hintText
            border: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.5)),
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
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            labelStyle: const TextStyle(color: Colors.black54),
            filled: true,
            fillColor: enabled ? const Color(0xFFEBE2D7) : Colors.grey.shade300,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          ),
        ),
      ],
    );
  }

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
