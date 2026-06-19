import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
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
  final _displayNameCtrl = TextEditingController();
  final _universityCtrl = TextEditingController();
  final _degreeCtrl = TextEditingController();
  final _workLocationCtrl = TextEditingController();
  final _yearsCtrl = TextEditingController();

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
    _displayNameCtrl.dispose();
    _universityCtrl.dispose();
    _degreeCtrl.dispose();
    _workLocationCtrl.dispose();
    _yearsCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _ds.getMhpProfile();
      _bioCtrl.text = data['bio']?.toString() ?? '';
      _displayNameCtrl.text = data['display_name']?.toString() ??
          data['username']?.toString() ??
          '';
      _universityCtrl.text = data['university']?.toString() ?? '';
      _degreeCtrl.text = data['degree']?.toString() ?? '';
      _workLocationCtrl.text = data['work_location']?.toString() ?? '';
      final yoe = data['years_of_experience'];
      if (yoe != null) _yearsCtrl.text = yoe.toString();
      _currentPictureUrl = data['picture_path']?.toString();
    } catch (_) {}
    setState(() => _loading = false);
  }

  String get _initials {
    final name = _displayNameCtrl.text.trim();
    final parts = name.split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'M';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
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
        'display_name': _displayNameCtrl.text.trim(),
        'university': _universityCtrl.text.trim(),
        'degree': _degreeCtrl.text.trim(),
        'work_location': _workLocationCtrl.text.trim(),
      };
      final yoe = int.tryParse(_yearsCtrl.text.trim());
      if (yoe != null) body['years_of_experience'] = yoe;
      if (uploadedPath != null) body['picture_path'] = uploadedPath;

      await _ds.updateProfile(body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated'),
              backgroundColor: Colors.green),
        );
        // Return true so callers can reload the profile
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildAvatar() {
    const double radius = 56;

    if (_pickedImage != null) {
      return _avatarShell(
        radius: radius,
        child: ClipOval(
          child: Image.file(_pickedImage!,
              width: radius * 2, height: radius * 2, fit: BoxFit.cover),
        ),
      );
    }

    final url = _currentPictureUrl != null && _currentPictureUrl!.isNotEmpty
        ? ProfilePictureHelper.getProfilePictureUrl(_currentPictureUrl!)
        : '';

    if (url.isNotEmpty) {
      return _avatarShell(
        radius: radius,
        child: CachedNetworkImage(
          imageUrl: url,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          imageBuilder: (_, imageProvider) => ClipOval(
            child: Image(
                image: imageProvider,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover),
          ),
          placeholder: (_, __) => _initialsCircle(radius),
          errorWidget: (_, __, ___) => _initialsCircle(radius),
        ),
      );
    }

    return _avatarShell(radius: radius, child: _initialsCircle(radius));
  }

  Widget _avatarShell({required double radius, required Widget child}) {
    return Stack(
      children: [
        SizedBox(width: radius * 2, height: radius * 2, child: child),
        Positioned.fill(
          child: ClipOval(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.45),
                  ],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
        ),
      ],
    );
  }

  Widget _initialsCircle(double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF855DFC), Color(0xFF6C4EE4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            fontFamily: 'Lexend',
          ),
        ),
      ),
    );
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
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.black),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: _buildAvatar(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'Tap to change profile picture',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontFamily: 'Lexend'),
                            ),
                          ),
                          const SizedBox(height: 28),
                          _label('Display Name'),
                          const SizedBox(height: 8),
                          _textField(_displayNameCtrl, 'Your name as shown to clients'),
                          const SizedBox(height: 20),
                          _label('Bio'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _bioCtrl,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Tell clients about yourself...',
                              hintStyle: const TextStyle(fontFamily: 'Lexend'),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Color(0xFFE0E0E0))),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: _purple),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _label('University / Institution'),
                          const SizedBox(height: 8),
                          _textField(_universityCtrl, 'e.g. Delhi University'),
                          const SizedBox(height: 20),
                          _label('Degree'),
                          const SizedBox(height: 8),
                          _textField(_degreeCtrl, 'e.g. M.Sc. Clinical Psychology'),
                          const SizedBox(height: 20),
                          _label('Work Location'),
                          const SizedBox(height: 8),
                          _textField(_workLocationCtrl, 'City, Country'),
                          const SizedBox(height: 20),
                          _label('Years of Experience'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _yearsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'e.g. 5',
                              hintStyle: const TextStyle(fontFamily: 'Lexend'),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: Color(0xFFE0E0E0))),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: _purple),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                  ),
                ],
              ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lexend',
            color: Colors.black87),
      );

  Widget _textField(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'Lexend', color: Colors.black38),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _purple),
          ),
        ),
      );
}
