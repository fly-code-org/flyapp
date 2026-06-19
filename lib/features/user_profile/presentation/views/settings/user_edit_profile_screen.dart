import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/services/s3_upload_service.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:fly/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:fly/features/user_profile/data/services/user_settings_remote_data_source.dart';
import 'package:fly/features/user_profile/presentation/controllers/user_profile_controller.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

const _purple = Color(0xFF6C4EE4);

const _moods = [
  ('🦋', 'Delicate'), ('😊', 'Happy'), ('😌', 'Calm'), ('😔', 'Sad'),
  ('😤', 'Frustrated'), ('🥰', 'Loved'), ('😴', 'Tired'), ('🌟', 'Energized'),
  ('🤔', 'Thoughtful'), ('😰', 'Anxious'),
];

class UserEditProfileScreen extends StatefulWidget {
  const UserEditProfileScreen({super.key});

  @override
  State<UserEditProfileScreen> createState() => _UserEditProfileScreenState();
}

class _UserEditProfileScreenState extends State<UserEditProfileScreen> {
  final _ds = UserSettingsRemoteDataSource();
  final _usernameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _selectedMood = '';
  String _selectedMoodEmoji = '';
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
    _usernameCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _bioCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _ds.getProfile();
      _usernameCtrl.text = data['username']?.toString() ?? '';
      _firstNameCtrl.text = data['first_name']?.toString() ?? '';
      _lastNameCtrl.text = data['last_name']?.toString() ?? '';
      _bioCtrl.text = data['bio']?.toString() ?? '';
      _phoneCtrl.text = data['phone']?.toString() ?? '';
      _currentPictureUrl = data['picture_path']?.toString();
      final mood = data['mood']?.toString() ?? '';
      if (mood.isNotEmpty) {
        final found = _moods.where((m) => m.$2 == mood).toList();
        if (found.isNotEmpty) {
          _selectedMood = found.first.$2;
          _selectedMoodEmoji = found.first.$1;
        } else {
          _selectedMood = mood;
        }
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    if (Get.isRegistered<SubscriptionController>()) {
      if (!Get.find<SubscriptionController>().requireAnyPlan()) return;
    } else {
      Get.toNamed(AppRoutes.subscriptionPlans);
      return;
    }
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
          role: 'user',
        );
      }

      final body = <String, dynamic>{
        'username': _usernameCtrl.text.trim(),
        'first_name': _firstNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'mood': _selectedMood,
      };
      if (uploadedPath != null) body['picture_path'] = uploadedPath;

      await _ds.updateProfile(body);
      // Refresh the profile controller so the profile screen shows updated data
      if (Get.isRegistered<UserProfileController>()) {
        await Get.find<UserProfileController>()
            .fetchUserProfile(forceRefresh: true);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  void _pickMood() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update mood',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moods.map((m) {
                final selected = _selectedMood == m.$2;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = m.$2;
                      _selectedMoodEmoji = m.$1;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? _purple : const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text('${m.$1} ${m.$2}',
                        style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontSize: 14)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
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
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: InkWell(
              onTap: () => popOrGoHome(context),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFF2F2F2)),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
            ),
          ),
          title: const Text('Edit Profile',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 18, color: Colors.black)),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _purple))
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 44,
                                    backgroundColor: const Color(0xFFE0E0E0),
                                    backgroundImage: _pickedImage != null
                                        ? FileImage(_pickedImage!) as ImageProvider
                                        : (_currentPictureUrl != null && _currentPictureUrl!.isNotEmpty)
                                            ? NetworkImage(_currentPictureUrl!)
                                            : null,
                                    child: (_pickedImage == null &&
                                            (_currentPictureUrl == null || _currentPictureUrl!.isEmpty))
                                        ? const Icon(Icons.person, size: 44, color: Colors.white)
                                        : null,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.edit,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _fieldLabel('Username'),
                          const SizedBox(height: 6),
                          _inputField(_usernameCtrl, 'Username'),
                          const SizedBox(height: 14),
                          _fieldLabel('First name'),
                          const SizedBox(height: 6),
                          _inputField(_firstNameCtrl, 'First name'),
                          const SizedBox(height: 14),
                          _fieldLabel('Last name'),
                          const SizedBox(height: 6),
                          _inputField(_lastNameCtrl, 'Last name'),
                          const SizedBox(height: 14),
                          _fieldLabel('Update mood'),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _pickMood,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedMood.isEmpty
                                          ? 'Select mood'
                                          : '$_selectedMoodEmoji $_selectedMood',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: _selectedMood.isEmpty
                                              ? Colors.black38
                                              : Colors.black87),
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down,
                                      color: Colors.black45),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _fieldLabel('Update bio'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _bioCtrl,
                            maxLines: 4,
                            maxLength: 100,
                            decoration: InputDecoration(
                              hintText: 'Tell us about yourself',
                              hintStyle: const TextStyle(
                                  color: Colors.black38, fontSize: 14),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    const BorderSide(color: _purple),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _fieldLabel('Phone Number'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: '+91 00000 00000',
                              hintStyle: const TextStyle(
                                  color: Colors.black38, fontSize: 14),
                              prefixIcon: const Icon(Icons.phone_outlined,
                                  color: Colors.black45),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide:
                                    const BorderSide(color: _purple),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('Save Changes',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(label,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87));

  Widget _inputField(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: _purple),
          ),
        ),
      );
}
