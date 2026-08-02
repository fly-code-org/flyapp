import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fly/features/user_profile/data/services/profile_pictures_service.dart';
import 'package:fly/features/user_profile/data/services/profile_update_service.dart';
import 'package:fly/features/start_quiz/widgets/gradient_button.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class SelectAvatarScreen extends StatefulWidget {
  const SelectAvatarScreen({super.key});

  @override
  State<SelectAvatarScreen> createState() => _SelectAvatarScreenState();
}

class _SelectAvatarScreenState extends State<SelectAvatarScreen> {
  final ProfilePicturesService _picturesService = ProfilePicturesService();
  final ProfileUpdateService _updateService = ProfileUpdateService();

  List<ProfilePictureItem> _pictures = [];
  bool _isLoading = true;
  bool _isSaving = false;
  ProfilePictureItem? _selectedPicture;
  double _dragPosition = 0.8;

  @override
  void initState() {
    super.initState();
    _loadPictures();
  }

  Future<void> _loadPictures() async {
    final pictures = await _picturesService.getProfilePictures();
    if (mounted) {
      setState(() {
        _pictures = pictures;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAndContinue() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      String picturePath;

      if (_selectedPicture != null) {
        picturePath = _selectedPicture!.path;
      } else if (_pictures.isNotEmpty) {
        final random = Random();
        final randomPicture = _pictures[random.nextInt(_pictures.length)];
        picturePath = randomPicture.path;
      } else {
        Get.toNamed(AppRoutes.GetInterest);
        return;
      }

      await _updateService.updateProfilePicture(picturePath);
      Get.toNamed(AppRoutes.GetInterest);
    } catch (e) {
      print('❌ [SELECT_AVATAR] Error saving avatar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save avatar. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _skipAndContinue() async {
    if (_pictures.isNotEmpty) {
      final random = Random();
      final randomPicture = _pictures[random.nextInt(_pictures.length)];
      try {
        await _updateService.updateProfilePicture(randomPicture.path);
      } catch (e) {
        print('⚠️ [SELECT_AVATAR] Could not save random avatar: $e');
      }
    }
    Get.toNamed(AppRoutes.GetInterest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg_fly.png', fit: BoxFit.cover),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _dragPosition > 0.3 ? 50 : MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/fly_logo.png',
                fit: BoxFit.none,
                height: 100,
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.8,
            minChildSize: 0.8,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  setState(() {
                    _dragPosition = notification.extent;
                  });
                  return true;
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              'Choose Your Avatar',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF855DFC),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Pick an avatar to represent you anonymously',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _pictures.isEmpty
                                ? const Center(child: Text('No avatars available'))
                                : GridView.builder(
                                    controller: scrollController,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: _pictures.length,
                                    itemBuilder: (context, index) {
                                      final picture = _pictures[index];
                                      final isSelected = _selectedPicture?.id == picture.id;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedPicture = picture;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF855DFC)
                                                  : Colors.transparent,
                                              width: 3,
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: picture.url,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) =>
                                                  Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.person,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            GradientButton(
                              text: _isSaving ? "Saving..." : "Continue",
                              onPressed: _isSaving ? () {} : _saveAndContinue,
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _skipAndContinue,
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  color: Color(0xFF8545E1),
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
