import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/services/s3_upload_service.dart';
import 'package:fly/core/utils/profile_picture_helper.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/profile_creation/data/datasources/mhp_profile_remote_data_source.dart';
import 'package:image_picker/image_picker.dart';

const _purple = Color(0xFF6C4EE4);

class MhpEditProfileScreen extends StatefulWidget {
  const MhpEditProfileScreen({super.key});

  @override
  State<MhpEditProfileScreen> createState() => _MhpEditProfileScreenState();
}

class _MhpEditProfileScreenState extends State<MhpEditProfileScreen> {
  final _ds = MhpProfileRemoteDataSourceImpl();
  final _bioCtrl = TextEditingController();

  String? _currentPictureUrl;
  File? _pickedImage;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _ds.getMhpProfile();
      _bioCtrl.text = data['bio']?.toString() ?? '';
      _currentPictureUrl = data['picture_path']?.toString();
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      String? uploadedPath;
      if (_pickedImage != null) {
        final s3 = sl<S3UploadService>();
        uploadedPath = await s3.uploadFile(
          file: _pickedImage!,
          isProfilePicture: true,
          role: 'mhp',
        );
      }

      final body = <String, dynamic>{
        'bio': _bioCtrl.text.trim(),
      };
      if (uploadedPath != null) body['picture_path'] = uploadedPath;

      await _ds.updateProfile(body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated'), backgroundColor: Colors.green),
        );
        popOrGoHome(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: InkWell(
              onTap: () => popOrGoHome(context),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF2F2F2),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
            ),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 56,
                              backgroundColor: const Color(0xFFEDE9FB),
                              backgroundImage: _pickedImage != null
                                  ? FileImage(_pickedImage!) as ImageProvider
                                  : (_currentPictureUrl != null && _currentPictureUrl!.isNotEmpty
                                      ? NetworkImage(
                                          ProfilePictureHelper.getProfilePictureUrl(_currentPictureUrl!),
                                        )
                                      : null),
                              child: (_pickedImage == null &&
                                      (_currentPictureUrl == null || _currentPictureUrl!.isEmpty))
                                  ? const Icon(Icons.person, size: 48, color: _purple)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _purple,
                                ),
                                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Tap to change profile picture',
                        style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'Lexend'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Bio',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Lexend'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bioCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tell users about yourself...',
                        hintStyle: const TextStyle(fontFamily: 'Lexend'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _purple),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          _saving ? 'Saving...' : 'Save Changes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
