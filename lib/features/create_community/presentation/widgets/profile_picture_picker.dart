import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fly/core/utils/profile_picture_helper.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  final void Function(File) onImagePicked;

  /// Existing community logo URL/path (for edit mode).
  /// Pass null / empty when creating a new community.
  final String? currentImageUrl;

  /// Avatar radius; diameter = radius * 2. Default matches MHP edit profile (56).
  final double radius;

  const ProfileImagePicker({
    super.key,
    required this.onImagePicked,
    this.currentImageUrl,
    this.radius = 56,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      final file = File(picked.path);
      setState(() => _pickedImage = file);
      widget.onImagePicked(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _avatarShell(),
          const SizedBox(height: 6),
          const Text(
            'Tap to change photo',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarShell() {
    final r = widget.radius;
    final size = r * 2;

    return Stack(
      children: [
        SizedBox(width: size, height: size, child: _imageContent(r)),
        // Gradient scrim — darkens the bottom half so the camera icon is legible
        Positioned.fill(
          child: ClipOval(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.45),
                  ],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
          ),
        ),
        // Centered camera icon at the bottom
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
        ),
      ],
    );
  }

  Widget _imageContent(double r) {
    final size = r * 2;

    // Freshly picked local image takes priority
    if (_pickedImage != null) {
      return ClipOval(
        child: Image.file(
          _pickedImage!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    // Existing logo from the server
    final url =
        ProfilePictureHelper.getProfilePictureUrl(widget.currentImageUrl);
    if (url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        imageBuilder: (_, provider) => ClipOval(
          child: Image(
            image: provider,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        placeholder: (_, __) => _placeholder(r),
        errorWidget: (_, __, ___) => _placeholder(r),
      );
    }

    return _placeholder(r);
  }

  // Purple gradient circle with a community icon — shown when no image exists
  Widget _placeholder(double r) {
    return Container(
      width: r * 2,
      height: r * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF855DFC), Color(0xFF6C4EE4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.groups, color: Colors.white, size: 40),
    );
  }
}
