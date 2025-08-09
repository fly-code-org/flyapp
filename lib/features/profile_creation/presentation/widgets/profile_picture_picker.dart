import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  final void Function(File) onImagePicked;

  const ProfileImagePicker({super.key, required this.onImagePicked});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final file = File(image.path);
      setState(() {
        _selectedImage = file;
      });

      // Send image to parent callback
      widget.onImagePicked(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 120,
        height: 120,
        child: ClipOval(
          child: _selectedImage != null
              ? Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: FileImage(_selectedImage!))
                  ),
                )
              : Center(
                  child: SvgPicture.network(
                    'https://cdn.flyapp.in/assets/image_picker.svg',
                    width: 120,
                    height: 120,
                    placeholderBuilder: (context) =>
                        const CircularProgressIndicator(),
                  ),
                ),
        ),
      ),
    );
  }
}
