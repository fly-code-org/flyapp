import 'package:flutter/material.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/services/s3_upload_service.dart';
import 'package:fly/features/profile_creation/controller/user_profile_controller.dart';
import 'package:fly/features/profile_creation/domain/usecases/create_mhp_profile.dart';
import 'package:fly/features/profile_creation/presentation/widgets/bio_input_field.dart';
import 'package:fly/features/profile_creation/presentation/widgets/profile_picture_picker.dart';
import 'package:fly/features/profile_creation/presentation/widgets/user_name_input_field.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class CreateMhpProfileScreen extends StatefulWidget {
  const CreateMhpProfileScreen({super.key});

  @override
  State<CreateMhpProfileScreen> createState() => _CreateMhpProfileScreenState();
}

class _CreateMhpProfileScreenState extends State<CreateMhpProfileScreen> {
  double _dragPosition = 0.8;
  late final String role;

  // Get controller safely - finds existing or creates new
  UserProfileController get controller {
    print("🔍 [MHP PROFILE FORM] [CONTROLLER GETTER] Accessing controller...");
    try {
      print("🔍 [MHP PROFILE FORM] [CONTROLLER GETTER] Attempting to find existing controller...");
      final foundController = Get.find<UserProfileController>(tag: 'UserProfileController');
      print("✅ [MHP PROFILE FORM] [CONTROLLER GETTER] Found existing controller: ${foundController.hashCode}");
      return foundController;
    } catch (e) {
      print("📝 [MHP PROFILE FORM] [CONTROLLER GETTER] Controller not found, creating new one. Error: $e");
      try {
        final createMhpProfile = sl<CreateMhpProfile>();
        final s3UploadService = sl<S3UploadService>();
        print("✅ [MHP PROFILE FORM] [CONTROLLER GETTER] Dependencies retrieved from service locator");
        final newController = UserProfileController(
          createMhpProfile: createMhpProfile,
          s3UploadService: s3UploadService,
        );
        final registeredController = Get.put(
          newController,
          tag: 'UserProfileController',
          permanent: false,
        );
        print("✅ [MHP PROFILE FORM] [CONTROLLER GETTER] Controller registered: ${registeredController.hashCode}");
        return registeredController;
      } catch (slError) {
        print("❌ [MHP PROFILE FORM] [CONTROLLER GETTER] Error getting CreateMhpProfile: $slError");
        final s3UploadService = sl<S3UploadService>();
        final fallbackController = UserProfileController(
          createMhpProfile: null,
          s3UploadService: s3UploadService,
        );
        final registeredController = Get.put(
          fallbackController,
          tag: 'UserProfileController',
          permanent: false,
        );
        print("✅ [MHP PROFILE FORM] [CONTROLLER GETTER] Fallback controller registered: ${registeredController.hashCode}");
        return registeredController;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    print("🚀 [MHP PROFILE FORM] [INIT STATE] initState started");
    final args = Get.arguments;
    role = (args['role'] ?? 'user').toLowerCase();
    print("✅ [MHP PROFILE FORM] [INIT STATE] Role set to: $role");
    try {
      print("🔍 [MHP PROFILE FORM] [INIT STATE] Initializing controller...");
      final ctrl = controller;
      ctrl.role.value = role; // Set role on controller for S3 uploads
      print("✅ [MHP PROFILE FORM] [INIT STATE] Controller initialized: ${ctrl.hashCode}");
      print("✅ [MHP PROFILE FORM] [INIT STATE] Controller role set to: ${ctrl.role.value}");
    } catch (e, stackTrace) {
      print("❌ [MHP PROFILE FORM] [INIT STATE] Error initializing controller: $e");
      print("📚 [MHP PROFILE FORM] [INIT STATE] Stack trace: $stackTrace");
    }
    print("✅ [MHP PROFILE FORM] [INIT STATE] initState completed");
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
                        "Create your account",
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
                        onImagePicked: (file) async {
                          print('📸 [MHP PROFILE FORM] Image picked: ${file.path}');
                          controller.selectedImage.value = file;
                          // Don't set picturePath here - it will be set after S3 upload
                          // Clear any previous S3 path so upload will trigger
                          controller.picturePath.value = '';
                          print('✅ [MHP PROFILE FORM] Image selected, will upload to S3 on profile creation');
                          await controller.saveToCache();
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
                        "May I know your full name",
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
                        hintText: "full name",
                        onChanged: (value) {
                          controller.username.value = value;
                          controller.saveToCache();
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Add a quick bio",
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
                          controller.bio.value = value;
                          controller.saveToCache();
                        },
                      ),
                      const SizedBox(height: 10),
                      GradientButton(
                        text: "Verify and Continue",
                        onPressed: () async {
                          // Save current form data before navigating
                          await controller.saveToCache();
                          Get.toNamed(
                            AppRoutes.AddMoreInfo,
                            arguments: {'role': role},
                          );
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
