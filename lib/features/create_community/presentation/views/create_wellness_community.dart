import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/widgets/safe_svg_icon.dart';
import 'package:fly/core/services/s3_upload_service.dart';
import 'package:fly/core/storage/onboarding_progress.dart';
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
class WellnessCommunity {
  final String name;
  final String svgPath;
  WellnessCommunity({required this.name, required this.svgPath});
}

/// Base widget for tag picker
class WellnessCommunityPicker extends StatefulWidget {
  final List<WellnessCommunity> tags;
  final bool isSocial; // true = social, false = wellness
  final String placeholder;
  final WellnessCommunity? defaultTag;
  final Function(WellnessCommunity?)? onTagSelected;

  const WellnessCommunityPicker({
    super.key,
    required this.tags,
    required this.isSocial,
    this.placeholder = "Select a tag",
    this.defaultTag,
    this.onTagSelected,
  });

  @override
  State<WellnessCommunityPicker> createState() => _WellnessCommunityPickerState();
}

class _WellnessCommunityPickerState extends State<WellnessCommunityPicker> {
  WellnessCommunity? _selectedTag;

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
            SafeSvgIcon(
              assetPath: _selectedTag?.svgPath ?? '',
              width: 28,
              height: 28,
              fallback: const Icon(Icons.tag, size: 28, color: Colors.grey),
            ),

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
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.isSocial ? 18 : 6),
                      color: Colors.deepPurple.shade50,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: SafeSvgIcon(
                      assetPath: tag.svgPath,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
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

class CreateWellnessCommunityScreen extends StatefulWidget {
  const CreateWellnessCommunityScreen({super.key});

  @override
  State<CreateWellnessCommunityScreen> createState() =>
      _CreateWellnessCommunityScreenState();
}

class _CreateWellnessCommunityScreenState
    extends State<CreateWellnessCommunityScreen> {
  double _dragPosition = 0.8;
  final CommunityController controller = Get.put(CommunityController());
  final CommunityMediaController mediaController = Get.put(
    CommunityMediaController(),
  );

  WellnessCommunity? _selectedTag;
  String _bio = '';
  bool _isSaving = false;

  // Hardcoded lists
  final wellnessTags = [
    WellnessCommunity(name: "Emotional Healing",    svgPath: 'assets/icon/support-tags/emotionalHealing.svg'),
    WellnessCommunity(name: "Anxiety & Stress",     svgPath: 'assets/icon/support-tags/anxietyAndStress.svg'),
    WellnessCommunity(name: "Grief & Heartbreak",   svgPath: 'assets/icon/support-tags/griefAndHeartbreak.svg'),
    WellnessCommunity(name: "Work & Career",        svgPath: 'assets/icon/support-tags/workAndCareer.svg'),
    WellnessCommunity(name: "Trauma",               svgPath: 'assets/icon/support-tags/traumaAndHealing.svg'),
    WellnessCommunity(name: "Family & Relations",   svgPath: 'assets/icon/support-tags/familyAndRelationship.svg'),
    WellnessCommunity(name: "Self-Worth & Identity",svgPath: 'assets/icon/support-tags/selfWorthAndIdentity.svg'),
  ];

  final socialTags = [
    WellnessCommunity(name: "Motivational",     svgPath: 'assets/icon/social-tags/motivational.svg'),
    WellnessCommunity(name: "Awwdorable",       svgPath: 'assets/icon/social-tags/awdorable.svg'),
    WellnessCommunity(name: "Fun & Humour",     svgPath: 'assets/icon/social-tags/funAndHumor.svg'),
    WellnessCommunity(name: "Peace",            svgPath: 'assets/icon/social-tags/peace.svg'),
    WellnessCommunity(name: "Words Of Wisdom",  svgPath: 'assets/icon/social-tags/wordsOfWisdom.svg'),
    WellnessCommunity(name: "News & Insights",  svgPath: 'assets/icon/social-tags/newsAndInsights.svg'),
    WellnessCommunity(name: "Movies & Shows",   svgPath: 'assets/icon/social-tags/moviesAndShows.svg'),
  ];

  @override
  void initState() {
    super.initState();
    // Final mandatory MHP step — resume here if killed before the community is created.
    OnboardingProgress.saveStep(
      step: AppRoutes.CreateWellnessCommunity,
      role: 'mhp',
    );
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

      // MHP onboarding fully complete (email + profile + community).
      await OnboardingProgress.markComplete();

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
      Get.toNamed(AppRoutes.CommunityWellnessProfile);
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
                        onImagePicked: (file) {
                          controller.selectedImage.value = file;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// Image Selected Text
                      Obx(() {
                        final image = controller.selectedImage.value;
                        return image != null
                            ? const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Color(0xFF34A853), size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      "Photo selected",
                                      style: TextStyle(
                                        fontFamily: 'Lexend',
                                        fontSize: 14,
                                        color: Color(0xFF34A853),
                                      ),
                                    ),
                                  ],
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

                      /// Wellness Community Tag Picker
                      const Text(
                        "Select Wellness Community Tag",
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      WellnessCommunityPicker(
                        tags: wellnessTags,
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
                      // WellnessCommunityPicker(tags: socialTags, isSocial: true),
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
