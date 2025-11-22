import 'package:flutter/material.dart';
import 'package:fly/features/profile_creation/presentation/widgets/input_field.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/services/s3_upload_service.dart';
import 'package:fly/features/profile_creation/controller/user_profile_controller.dart';
import 'package:fly/features/profile_creation/presentation/widgets/bio_input_field.dart';
import 'package:fly/features/profile_creation/presentation/widgets/dob_input_field.dart';
import 'package:fly/features/profile_creation/presentation/widgets/profile_picture_picker.dart';
import 'package:fly/features/profile_creation/presentation/widgets/user_name_input_field.dart';
import 'package:fly/features/profile_creation/domain/usecases/create_user_profile.dart';
import 'package:get/get.dart';

class CreateUserProfileScreen extends StatefulWidget {
  const CreateUserProfileScreen({super.key});

  @override
  State<CreateUserProfileScreen> createState() =>
      _CreateUserProfileScreenState();
}

class _CreateUserProfileScreenState extends State<CreateUserProfileScreen> {
  double _dragPosition = 0.8;
  late final String role;

  // Get controller safely - finds existing or creates new
  UserProfileController get controller {
    print("🔍 [USER PROFILE FORM] [CONTROLLER GETTER] Accessing controller...");
    try {
      print("🔍 [USER PROFILE FORM] [CONTROLLER GETTER] Attempting to find existing controller...");
      final foundController = Get.find<UserProfileController>(tag: 'UserProfileController');
      print("✅ [USER PROFILE FORM] [CONTROLLER GETTER] Found existing controller: ${foundController.hashCode}");
      return foundController;
    } catch (e) {
      print("📝 [USER PROFILE FORM] [CONTROLLER GETTER] Controller not found, creating new one. Error: $e");
        try {
          final createUserProfile = sl<CreateUserProfile>();
          final s3UploadService = sl<S3UploadService>();
          print("✅ [USER PROFILE FORM] [CONTROLLER GETTER] Dependencies retrieved from service locator");
          final newController = UserProfileController(
            createUserProfile: createUserProfile,
            s3UploadService: s3UploadService,
          );
        final registeredController = Get.put(
          newController,
          tag: 'UserProfileController',
          permanent: false,
        );
        print("✅ [USER PROFILE FORM] [CONTROLLER GETTER] Controller registered: ${registeredController.hashCode}");
        return registeredController;
      } catch (slError) {
        print("❌ [USER PROFILE FORM] [CONTROLLER GETTER] Error getting CreateUserProfile: $slError");
          final s3UploadService = sl<S3UploadService>();
          final fallbackController = UserProfileController(
            createUserProfile: null,
            s3UploadService: s3UploadService,
          );
        final registeredController = Get.put(
          fallbackController,
          tag: 'UserProfileController',
          permanent: false,
        );
        print("✅ [USER PROFILE FORM] [CONTROLLER GETTER] Fallback controller registered: ${registeredController.hashCode}");
        return registeredController;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    print("🚀 [USER PROFILE FORM] [INIT STATE] initState started");
    final args = Get.arguments;
    role = (args?['role'] ?? 'user').toLowerCase();
    print("✅ [USER PROFILE FORM] [INIT STATE] Role set to: $role");
    try {
      print("🔍 [USER PROFILE FORM] [INIT STATE] Initializing controller...");
      final ctrl = controller;
      ctrl.role.value = role; // Set role on controller for S3 uploads
      print("✅ [USER PROFILE FORM] [INIT STATE] Controller initialized: ${ctrl.hashCode}");
      print("✅ [USER PROFILE FORM] [INIT STATE] Controller role set to: ${ctrl.role.value}");
    } catch (e, stackTrace) {
      print("❌ [USER PROFILE FORM] [INIT STATE] Error initializing controller: $e");
      print("📚 [USER PROFILE FORM] [INIT STATE] Stack trace: $stackTrace");
    }
    print("✅ [USER PROFILE FORM] [INIT STATE] initState completed");
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
                        "Create your profile",
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
                      Builder(
                        builder: (context) {
                          try {
                            final ctrl = controller;
                            return ProfileImagePicker(
                              role: "user",
                              onImagePicked: (file) {
                                print('📸 [USER PROFILE FORM] Image picked: ${file.path}');
                                ctrl.selectedImage.value = file;
                                // Don't set picturePath here - it will be set after S3 upload
                                // Clear any previous S3 path so upload will trigger
                                ctrl.picturePath.value = '';
                                print('✅ [USER PROFILE FORM] Image selected, will upload to S3 on profile creation');
                              },
                            );
                          } catch (e) {
                            print("❌ [USER PROFILE FORM] Error accessing controller: $e");
                            return const SizedBox();
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      /// Image Selected Text
                      Builder(
                        builder: (context) {
                          try {
                            final ctrl = controller;
                            return Obx(() {
                              final image = ctrl.selectedImage.value;
                              return image != null
                                  ? Center(
                                      child: Text(
                                        "Image selected: ${image.path.split('/').last}",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    )
                                  : const SizedBox();
                            });
                          } catch (e) {
                            return const SizedBox();
                          }
                        },
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Create your alias username",
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

                      /// Username Input Field
                      Builder(
                        builder: (context) {
                          try {
                            final ctrl = controller;
                            return CustomInputField(
                              onChanged: (value) {
                                print('👤 [USER PROFILE FORM] Username changed: $value');
                                ctrl.username.value = value;
                              },
                            );
                          } catch (e) {
                            print("❌ [USER PROFILE FORM] Error accessing controller: $e");
                            return CustomInputField(onChanged: (value) {
                              // Empty handler for fallback
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "😮 Someone stole your idea.",
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 28.75 / 23,
                          color: Colors.red,
                        ),
                      ),
                      const Text(
                        "Username unavailable. Try another fictional name as fly is an anonymous platform!",
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 28.75 / 23,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "First Name",
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
                      Builder(
                        builder: (context) {
                          try {
                            final ctrl = controller;
                            return CustomInputField(
                              hintText: "Enter first name",
                              onChanged: (value) {
                                print('👤 [USER PROFILE FORM] First name changed: $value');
                                ctrl.firstName.value = value;
                              },
                            );
                          } catch (e) {
                            print("❌ [USER PROFILE FORM] Error accessing controller: $e");
                            return CustomInputField(
                              hintText: "Enter first name",
                              onChanged: (value) {
                                // Empty handler for fallback
                              },
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Last Name",
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
                      Builder(
                        builder: (context) {
                          try {
                            final ctrl = controller;
                            return CustomInputField(
                              hintText: "Enter last name",
                              onChanged: (value) {
                                print('👤 [USER PROFILE FORM] Last name changed: $value');
                                ctrl.lastName.value = value;
                              },
                            );
                          } catch (e) {
                            print("❌ [USER PROFILE FORM] Error accessing controller: $e");
                            return CustomInputField(
                              hintText: "Enter last name",
                              onChanged: (value) {
                                // Empty handler for fallback
                              },
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Date of Birth",
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
                      Builder(
                        builder: (context) {
                          try {
                            final ctrl = controller;
                            return DOBInputField(
                              onDateSelected: (dob) {
                                print('📅 [USER PROFILE FORM] DOB selected: $dob');
                                // Convert DateTime to ISO string format
                                ctrl.dateOfBirth.value = dob.toIso8601String();
                                print('✅ [USER PROFILE FORM] dateOfBirth set to: ${ctrl.dateOfBirth.value}');
                              },
                            );
                          } catch (e) {
                            print("❌ [USER PROFILE FORM] Error accessing controller: $e");
                            return DOBInputField(onDateSelected: (dob) {
                              // Empty handler for fallback
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Mood Check-In",
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
                      Builder(
                        builder: (context) {
                          try {
                            final ctrl = controller;
                            return GeneralCustomInputField(
                              hintText: "Type your mood",
                              onChanged: (value) {
                                print('😊 [USER PROFILE FORM] Mood changed: $value');
                                ctrl.mood.value = value;
                              },
                            );
                          } catch (e) {
                            print("❌ [USER PROFILE FORM] Error accessing controller: $e");
                            return GeneralCustomInputField(
                              hintText: "Type your mood",
                              onChanged: (value) {
                                // Empty handler for fallback
                              },
                            );
                          }
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
                      Builder(
                        builder: (context) {
                          try {
                            final ctrl = controller;
                            return BioInputField(
                              hintText: "Tell us something about yourself...",
                              onChanged: (value) {
                                print('📝 [USER PROFILE FORM] Bio changed: $value');
                                ctrl.bio.value = value;
                              },
                            );
                          } catch (e) {
                            print("❌ [USER PROFILE FORM] Error accessing controller: $e");
                            return BioInputField(
                              hintText: "Tell us something about yourself...",
                              onChanged: (value) {
                                // Empty handler for fallback
                              },
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Builder(
                        builder: (context) {
                          try {
                            final ctrl = controller;
                            return Obx(
                              () => Column(
                                children: [
                                  GradientButton(
                                    text: ctrl.isLoading.value
                                        ? "Creating Profile..."
                                        : "Verify and Continue",
                                    onPressed: ctrl.isLoading.value
                                        ? () {}
                                        : () async {
                                            print("🚀 [USER PROFILE FORM] Button pressed - starting profile creation");
                                            try {
                                              // Validate required fields
                                              if (ctrl.username.value.isEmpty) {
                                                Get.snackbar(
                                                  'Error',
                                                  'Username is required',
                                                  snackPosition: SnackPosition.BOTTOM,
                                                  backgroundColor: Colors.red,
                                                  colorText: Colors.white,
                                                );
                                                return;
                                              }

                                              print("🔍 [USER PROFILE FORM] Calling createUserProfileAPI...");
                                              final success = await ctrl.createUserProfileAPI();

                                              print("✅ [USER PROFILE FORM] createUserProfileAPI returned: $success");
                                              print("   - success: $success");
                                              print("   - message.value: ${ctrl.message.value}");
                                              print("   - message.value.isNotEmpty: ${ctrl.message.value.isNotEmpty}");

                                              if (success && ctrl.message.value.isNotEmpty) {
                                                print("✅ [USER PROFILE FORM] Profile created successfully, navigating to quiz...");
                                                // Navigate to quiz only on success
                                                Get.toNamed(
                                                  '/intro-quiz',
                                                  arguments: {'role': role},
                                                );
                                                print("✅ [USER PROFILE FORM] Navigation completed");
                                              } else {
                                                print("🔍 [USER PROFILE FORM] Checking error message...");
                                                print("   - errorMessage.value: ${ctrl.errorMessage.value}");
                                                print("   - errorMessage.value.isNotEmpty: ${ctrl.errorMessage.value.isNotEmpty}");

                                                if (ctrl.errorMessage.value.isNotEmpty) {
                                                  print("❌ [USER PROFILE FORM] Showing error message: ${ctrl.errorMessage.value}");
                                                  // Show error message
                                                  Get.snackbar(
                                                    'Error',
                                                    ctrl.errorMessage.value,
                                                    snackPosition: SnackPosition.BOTTOM,
                                                    backgroundColor: Colors.red,
                                                    colorText: Colors.white,
                                                  );
                                                } else {
                                                  print("⚠️ [USER PROFILE FORM] No success and no error message");
                                                }
                                              }
                                            } catch (e, stackTrace) {
                                              print("❌ [USER PROFILE FORM] Error in button handler: $e");
                                              print("📚 [USER PROFILE FORM] Stack trace: $stackTrace");
                                              Get.snackbar(
                                                'Error',
                                                'An unexpected error occurred: $e',
                                                snackPosition: SnackPosition.BOTTOM,
                                                backgroundColor: Colors.red,
                                                colorText: Colors.white,
                                              );
                                            }
                                          },
                                  ),
                                  if (ctrl.errorMessage.value.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        ctrl.errorMessage.value,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          } catch (e) {
                            print("❌ [USER PROFILE FORM] Error accessing controller: $e");
                            return GradientButton(
                              text: "Verify and Continue",
                              onPressed: () {
                                Get.snackbar(
                                  'Error',
                                  'Controller not available',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              },
                            );
                          }
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
