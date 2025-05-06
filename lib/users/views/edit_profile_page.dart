// lib/users/views/edit_profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';                        // ← added
import 'package:caching/users/services/profile_service.dart';
import 'package:caching/users/model/edit_profile.dart';                   // ← added

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _profileService = ProfileService();
  final picker = ImagePicker();

  final List<String> _genderOptions = ['Male', 'Female', 'Prefer not to say'];

  File? _image;
  String? _selectedGender;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final profile = await _profileService.getUserOnce();
    if (profile != null) {
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _descController.text = profile.description;
      _phoneController.text = profile.phoneNumber;
      _emailController.text = _auth.currentUser?.email ?? '';
      _selectedGender = _genderOptions.contains(profile.gender) ? profile.gender : null;

      if (profile.photoUrl.isNotEmpty) {
        final file = File(profile.photoUrl);
        if (await file.exists()) {
          _image = file;
        }
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _ageController,
      _descController,
      _phoneController,
      _emailController,
      _currentPasswordController,
      _newPasswordController,
      _confirmPasswordController
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser!;
    final currentPwd = _currentPasswordController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPwd = _newPasswordController.text.trim();
    String photoUrl = '';

    try {
      // Reauthentication if email or password is changed
      if (newEmail != user.email || newPwd.isNotEmpty) {
        if (currentPwd.isEmpty) {
          throw FirebaseAuthException(
              code: 'requires-recent-login',
              message: 'You must enter your current password to change email or password.');
        }
        final cred = EmailAuthProvider.credential(
            email: user.email!, password: currentPwd);
        await user.reauthenticateWithCredential(cred);

        if (newEmail != user.email) {
          await user.updateEmail(newEmail);
        }
        if (newPwd.isNotEmpty) {
          await user.updatePassword(newPwd);
        }
      }

      if (_image != null) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/profile.png';
        await _image!.copy(path);
        photoUrl = path;
      }

      final data = EditProfileData(
        photoUrl: photoUrl,
        name: _nameController.text.trim(),
        gender: _selectedGender ?? '',
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        description: _descController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      await _profileService.updateUserProfile(data);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')));
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB0CCFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // Profile Image
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : const AssetImage('assets/images/blank_image.jpg')
                    as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name
              _buildField(_nameController, 'Name', 'Enter name',
                  validator: (v) => v!.isEmpty ? 'Name required' : null),

              // Age
              _buildField(_ageController, 'Age', 'Enter age',
                  keyboard: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Age required' : null),

              // Gender
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _genderOptions.contains(_selectedGender)
                    ? _selectedGender
                    : null,
                hint: const Text('Select gender'),
                onChanged: (v) => setState(() => _selectedGender = v),
                items: _genderOptions
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                validator: (v) => v == null ? 'Select gender' : null,
              ),
              const SizedBox(height: 16),

              // Description
              _buildField(_descController, 'Description', 'Enter description',
                  maxLines: 3),

              // Phone
              _buildField(_phoneController, 'Phone Number', 'Enter phone',
                  keyboard: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Phone required' : null),

              // Email
              // _buildField(_emailController, 'Email', 'Enter email',
              //     keyboard: TextInputType.emailAddress,
              //     validator: (v) {
              //       if (v!.isEmpty) return 'Email required';
              //       if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v)) return 'Invalid email';
              //       return null;
              //     }),

              // const SizedBox(height: 24),

              // Password Section Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),

              // Current Password
              _buildField(_currentPasswordController, null, 'Enter current password',
                  obscureText: true),

              // New Password Section Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('New Password', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),

              // New Password
              _buildField(_newPasswordController, null, 'Enter new password',
                  obscureText: true,
                  validator: (v) {
                    if (v != null && v.isNotEmpty && v.length < 6) return 'Minimum 6 characters';
                    return null;
                  }),

              // Confirm Password
              _buildField(_confirmPasswordController, null, 'Re-enter new password',
                  obscureText: true,
                  validator: (v) {
                    if (v!.isNotEmpty &&
                        v != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  }),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB3B3),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Back', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF0B3),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller,
      String? label,
      String hint, {
        bool obscureText = false,
        TextInputType keyboard = TextInputType.text,
        String? Function(String?)? validator,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (label != null) const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboard,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}