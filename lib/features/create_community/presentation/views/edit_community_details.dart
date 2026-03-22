import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/community/domain/entities/community.dart';
import 'package:fly/features/community/domain/usecases/update_community.dart';
import 'package:fly/features/create_community/presentation/views/create_support_community.dart';
import 'package:fly/features/create_community/presentation/widgets/profile_picture_picker.dart';
import 'package:fly/features/interests/data/server_tag_catalog.dart';
import 'package:fly/core/services/s3_upload_service.dart';
import 'package:fly/core/utils/safe_navigation.dart';
import 'package:get/get.dart';

class EditCommunityScreen extends StatefulWidget {
  const EditCommunityScreen({super.key});

  @override
  State<EditCommunityScreen> createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends State<EditCommunityScreen> {
  Community? _community;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _encourageController = TextEditingController();
  final _discourageController = TextEditingController();
  final _dontTolerateController = TextEditingController();
  SupportCommunity? _selectedTag;
  File? _selectedImage;
  bool _saving = false;

  static final supportedTags = [
    SupportCommunity(name: "Emotional Healing", icon: Icons.healing),
    SupportCommunity(name: "Anxiety & Stress", icon: Icons.sentiment_dissatisfied),
    SupportCommunity(name: "Grief & Heartbreak", icon: Icons.heart_broken),
    SupportCommunity(name: "Work & Career", icon: Icons.work),
    SupportCommunity(name: "Trauma", icon: Icons.local_hospital),
    SupportCommunity(name: "Family & Relations", icon: Icons.family_restroom),
    SupportCommunity(name: "Self-Worth & Identity", icon: Icons.person),
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['community'] is Community) {
      _community = args['community'] as Community;
      _nameController.text = _community!.name;
      _descriptionController.text = _community!.description;
      _encourageController.text = _community!.guidelinesEncourage;
      _discourageController.text = _community!.guidelinesDiscourage;
      _dontTolerateController.text = _community!.guidelinesDontTolerate;
      _syncSelectedTagFromCommunity();
    }
  }

  Future<void> _syncSelectedTagFromCommunity() async {
    await sl<ServerTagCatalog>().ensureLoaded();
    if (!mounted || _community == null) return;
    final tagName = sl<ServerTagCatalog>().displayNameForTagId(_community!.tagId);
    if (tagName == null) return;
    for (final t in supportedTags) {
      if (t.name == tagName) {
        setState(() => _selectedTag = t);
        break;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _encourageController.dispose();
    _discourageController.dispose();
    _dontTolerateController.dispose();
    super.dispose();
  }

  SupportCommunity _getDefaultTag() {
    if (_selectedTag != null) return _selectedTag!;
    if (_community != null) {
      final tagName = sl<ServerTagCatalog>().displayNameForTagId(_community!.tagId);
      if (tagName != null) {
        try {
          return supportedTags.firstWhere((t) => t.name == tagName);
        } catch (_) {}
      }
    }
    return supportedTags[2];
  }

  Future<void> _save() async {
    if (_community == null) {
      Get.snackbar('Error', 'No community to update', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    await sl<ServerTagCatalog>().ensureLoaded();
    final tagId = _selectedTag != null
        ? sl<ServerTagCatalog>().tagIdForName(_selectedTag!.name)
        : _community!.tagId;
    if (tagId == null) {
      Get.snackbar('Error', 'Please select a tag', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    setState(() => _saving = true);
    try {
      String logoPath = _community!.logoPath;
      if (_selectedImage != null) {
        final s3 = sl<S3UploadService>();
        logoPath = await s3.uploadFile(file: _selectedImage!, isProfilePicture: true, role: 'mhp');
      }
      await sl<UpdateCommunity>().call('mhp', {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'logo_path': logoPath,
        'tag_id': tagId,
        'guidelines_encourage': _encourageController.text.trim(),
        'guidelines_discourage': _discourageController.text.trim(),
        'guidelines_dont_tolerate': _dontTolerateController.text.trim(),
      });
      if (!mounted) return;
      Get.snackbar('Saved', 'Community updated', backgroundColor: Colors.green, colorText: Colors.white);
      popOrGoHome(context);
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28), onPressed: () => popOrGoHome(context)),
                const SizedBox(width: 8),
                const Text("Manage Community", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  ProfileImagePicker(
                    role: "mhp",
                    onImagePicked: (file) => setState(() => _selectedImage = file),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Update Community Name", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: _inputDecoration("Enter community name"),
                    ),
                    const SizedBox(height: 20),
                    SupportCommunityPicker(
                      tags: supportedTags,
                      isSocial: false,
                      defaultTag: _getDefaultTag(),
                      onTagSelected: (tag) => setState(() => _selectedTag = tag),
                    ),
                    const SizedBox(height: 20),
                    const Text("Update Community Bio", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: _inputDecoration("Enter community description"),
                    ),
                    const SizedBox(height: 20),
                    const Text("✅ We encourage", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.green)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _encourageController,
                      maxLines: 6,
                      decoration: _inputDecoration("What we encourage..."),
                    ),
                    const SizedBox(height: 20),
                    const Text("❌ We discourage", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.red)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _discourageController,
                      maxLines: 6,
                      decoration: _inputDecoration("What we discourage..."),
                    ),
                    const SizedBox(height: 20),
                    const Text("😠 We Don't Tolerate", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.orange)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dontTolerateController,
                      maxLines: 6,
                      decoration: _inputDecoration("What we don't tolerate..."),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(_saving ? "Saving..." : "Save Changes", style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}
