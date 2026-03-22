import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/services/s3_upload_service.dart';
import 'package:fly/features/community/domain/usecases/create_community.dart';
import 'package:fly/features/create_community/controller/user_profile_controller.dart';
import 'package:fly/features/create_community/presentation/widgets/bio_input_field.dart';
import 'package:fly/features/create_community/presentation/widgets/profile_picture_picker.dart';
import 'package:fly/features/create_community/presentation/widgets/user_name_input_field.dart';
import 'package:fly/features/interests/data/server_tag_catalog.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

/// Model for a tag
class SupportCommunity {
  final String name;
  final IconData icon; // Placeholder for now, replace with assets later
  SupportCommunity({required this.name, required this.icon});
}

/// Base widget for tag picker
class SupportCommunityPicker extends StatefulWidget {
  final List<SupportCommunity> tags;
  final bool isSocial; // true = social, false = supported
  final String placeholder;
  final SupportCommunity? defaultTag;
  final Function(SupportCommunity?)? onTagSelected;

  const SupportCommunityPicker({
    super.key,
    required this.tags,
    required this.isSocial,
    this.placeholder = "Select a tag",
    this.defaultTag,
    this.onTagSelected,
  });

  @override
  State<SupportCommunityPicker> createState() => _SupportCommunityPickerState();
}

class _SupportCommunityPickerState extends State<SupportCommunityPicker> {
  SupportCommunity? _selectedTag;

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.defaultTag;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _selectedTag == null
        ? Colors.grey
        : Colors.deepPurple.shade200;

    final borderRadius = BorderRadius.circular(widget.isSocial ? 20 : 8);

    return GestureDetector(
      onTap: () => _openTagSelector(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: borderRadius,
        ),
        child: Row(
          children: [
            if (_selectedTag != null)
              Icon(_selectedTag!.icon, size: 28)
            else
              const Icon(
                Icons.tag,
                size: 28,
                color: Colors.grey,
              ), // placeholder

            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedTag?.name ?? widget.placeholder,
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedTag == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 24),
          ],
        ),
      ),
    );
  }

  void _openTagSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return ListView.builder(
              controller: controller,
              itemCount: widget.tags.length,
              itemBuilder: (context, index) {
                final tag = widget.tags[index];
                return ListTile(
                  leading: widget.isSocial
                      ? CircleAvatar(
                          radius: 18,
                          child: Icon(tag.icon, size: 20),
                        )
                      : Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.deepPurple.shade50,
                          ),
                          child: Icon(tag.icon, size: 20),
                        ),
                  title: Text(tag.name),
                  onTap: () {
                    setState(() => _selectedTag = tag);
                    widget.onTagSelected?.call(tag);
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class CreateSupportCommunityScreen extends StatefulWidget {
  const CreateSupportCommunityScreen({super.key});

  @override
  State<CreateSupportCommunityScreen> createState() =>
      _CreateSupportCommunityScreenState();
}

class _CreateSupportCommunityScreenState
    extends State<CreateSupportCommunityScreen> {
  double _dragPosition = 0.8;
  final CommunityController controller = Get.put(CommunityController());
  final CommunityMediaController mediaController = Get.put(
    CommunityMediaController(),
  );
  
  SupportCommunity? _selectedTag;
  String _bio = '';
  bool _isSaving = false;

  // Hardcoded lists
  final supportedTags = [
    SupportCommunity(name: "Emotional Healing", icon: Icons.healing),
    SupportCommunity(
      name: "Anxiety & Stress",
      icon: Icons.sentiment_dissatisfied,
    ),
    SupportCommunity(name: "Grief & Heartbreak", icon: Icons.heart_broken),
    SupportCommunity(name: "Work & Career", icon: Icons.work),
    SupportCommunity(name: "Trauma", icon: Icons.local_hospital),
    SupportCommunity(name: "Family & Relations", icon: Icons.family_restroom),
    SupportCommunity(name: "Self-Worth & Identity", icon: Icons.person),
  ];

  final socialTags = [
    SupportCommunity(name: "Motivational", icon: Icons.lightbulb),
    SupportCommunity(name: "Awwdorable", icon: Icons.pets),
    SupportCommunity(name: "Fun & Humour", icon: Icons.emoji_emotions),
    SupportCommunity(name: "Peace", icon: Icons.spa),
    SupportCommunity(name: "Words Of Wisdom", icon: Icons.menu_book),
    SupportCommunity(name: "News & Insights", icon: Icons.article),
    SupportCommunity(name: "Movies & Shows", icon: Icons.movie),
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveCommunity() async {
    // Validate inputs
    if (controller.username.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a community name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_bio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a tag'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await sl<ServerTagCatalog>().ensureLoaded();
    final tagId = sl<ServerTagCatalog>().tagIdForName(_selectedTag!.name);
    if (tagId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid tag selected: ${_selectedTag!.name}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String logoPath = '';
      
      // Upload image if selected
      if (controller.selectedImage.value != null) {
        final s3UploadService = sl<S3UploadService>();
        logoPath = await s3UploadService.uploadFile(
          file: controller.selectedImage.value!,
          isProfilePicture: true,
          role: 'mhp', // Community logo uploaded as MHP profile picture type
        );
        print('✅ [COMMUNITY] Logo uploaded: $logoPath');
      }

      // Create community
      final createCommunity = sl<CreateCommunity>();
      await createCommunity.call(
        name: controller.username.value,
        description: _bio,
        type: 'support',
        createdByType: 'mhp',
        logoPath: logoPath,
        tagId: tagId,
      );

      print('✅ [COMMUNITY] Community created successfully');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Community created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate to next screen
      Get.toNamed(AppRoutes.CommunitySupportProfile);
    } catch (e) {
      print('❌ [COMMUNITY] Error creating community: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating community: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
            top: _dragPosition > 0.3
                ? 50
                : MediaQuery.of(context).size.height * 0.3,
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
            minChildSize: 0.1,
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
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      const Text(
                        "Create your community, set the vibe that speaks to your mission",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 27,
                          fontWeight: FontWeight.w400,
                          height: 33.75 / 27,
                          letterSpacing: 0.25,
                        ),
                      ),
                      const SizedBox(height: 30),

                      /// Profile Image Picker
                      ProfileImagePicker(
                        role: "mhp", // 👈 send role down
                        onImagePicked: (file) {
                          controller.selectedImage.value = file;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// Image Selected Text
                      Obx(() {
                        final image = controller.selectedImage.value;
                        return image != null
                            ? Center(
                                child: Text(
                                  "Image selected: ${image.path.split('/').last}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              )
                            : const SizedBox();
                      }),

                      const SizedBox(height: 30),
                      const Text(
                        "Community Name",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 23,
                          fontWeight: FontWeight.w400,
                          height: 33.75 / 27,
                          letterSpacing: 0.25,
                        ),
                      ),

                      const SizedBox(height: 10),
                      CustomInputField(
                        hintText: "Enter community name",
                        onChanged: (value) => controller.username.value = value,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Add a description",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 23,
                          fontWeight: FontWeight.w400,
                          height: 33.75 / 27,
                          letterSpacing: 0.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      BioInputField(
                        hintText: "Tell us something about yourself...",
                        onChanged: (value) {
                          setState(() {
                            _bio = value;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      /// 👇 Supported Community Tag Picker
                      const Text(
                        "Select Supported Community Tag",
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SupportCommunityPicker(
                        tags: supportedTags,
                        isSocial: false,
                        onTagSelected: (tag) {
                          setState(() {
                            _selectedTag = tag;
                          });
                        },
                      ),

                      // const SizedBox(height: 20),

                      /// 👇 Social Community Tag Picker
                      // const Text(
                      //   "Select Social Community Tag",
                      //   style: TextStyle(
                      //     fontFamily: 'Lexend',
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.w400,
                      //   ),
                      // ),
                      // const SizedBox(height: 10),
                      // SupportCommunityPicker(tags: socialTags, isSocial: true),
                      const SizedBox(height: 30),
                      GradientButton(
                        text: _isSaving ? "Saving..." : "Verify and Continue",
                        onPressed: _isSaving
                            ? () {} // No-op when saving
                            : () async {
                                await _saveCommunity();
                              },
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
