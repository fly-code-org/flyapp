import 'package:flutter/material.dart';
import 'package:fly/features/profile_creation/presentation/widgets/list_input.dart';
import 'package:fly/features/profile_creation/presentation/widgets/select_pill_list.dart';
import 'package:fly/features/profile_creation/presentation/widgets/time_field.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/core/services/s3_upload_service.dart';
import 'package:fly/features/profile_creation/controller/user_profile_controller.dart';
import 'package:fly/features/profile_creation/domain/usecases/create_mhp_profile.dart';
import 'package:fly/features/profile_creation/domain/usecases/create_user_profile.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class AddSessionScreen extends StatefulWidget {
  const AddSessionScreen({super.key});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  double _dragPosition = 0.8;
  late final String role;

  // Get controller safely - finds existing or creates new
  UserProfileController get controller {
    print("🔍 [ADD SESSION FORM] [CONTROLLER GETTER] Accessing controller...");
    
    // Check if controller is already registered
    if (Get.isRegistered<UserProfileController>(tag: 'UserProfileController')) {
      print("✅ [ADD SESSION FORM] [CONTROLLER GETTER] Found existing controller");
      return Get.find<UserProfileController>(tag: 'UserProfileController');
    }
    
    // Create new controller
    print("📝 [ADD SESSION FORM] [CONTROLLER GETTER] Creating new controller...");
    try {
      final createMhpProfile = sl<CreateMhpProfile>();
      final createUserProfile = sl<CreateUserProfile>();
      final s3UploadService = sl<S3UploadService>();
      print("✅ [ADD SESSION FORM] [CONTROLLER GETTER] Dependencies retrieved from service locator");
      final newController = UserProfileController(
        createMhpProfile: createMhpProfile,
        createUserProfile: createUserProfile,
        s3UploadService: s3UploadService,
      );
      print("✅ [ADD SESSION FORM] [CONTROLLER GETTER] Controller created: ${newController.hashCode}");
      return Get.put(newController, tag: 'UserProfileController', permanent: false);
    } catch (slError) {
      print("❌ [ADD SESSION FORM] [CONTROLLER GETTER] Error getting dependencies: $slError");
      // Fallback: create controller with minimal dependencies
      final s3UploadService = sl<S3UploadService>();
      final fallbackController = UserProfileController(
        createMhpProfile: null,
        createUserProfile: null,
        s3UploadService: s3UploadService,
      );
      print("✅ [ADD SESSION FORM] [CONTROLLER GETTER] Fallback controller created: ${fallbackController.hashCode}");
      return Get.put(fallbackController, tag: 'UserProfileController', permanent: false);
    }
  }

  @override
  void initState() {
    super.initState();
    print("🚀 [INIT STATE] AddSessionScreen initState started");
    role = 'mhp';
    print("✅ [INIT STATE] Role set to: $role");
    // Initialize controller early to ensure it's available
    try {
      print("🔍 [INIT STATE] Initializing controller...");
      final ctrl = controller;
      ctrl.role.value = role; // Set role on controller for S3 uploads
      print(
        "✅ [INIT STATE] Controller initialized successfully: ${ctrl.hashCode}",
      );
      print("✅ [INIT STATE] Controller role set to: ${ctrl.role.value}");
      print("🔍 [INIT STATE] Checking controller properties...");
      print("   - isLoading: ${ctrl.isLoading.value}");
      print("   - message: ${ctrl.message.value}");
      print("   - errorMessage: ${ctrl.errorMessage.value}");
      print("   - createMhpProfile: ${ctrl.createMhpProfile != null}");
    } catch (e, stackTrace) {
      print("❌ [INIT STATE] Error initializing controller: $e");
      print("📚 [INIT STATE] Stack trace: $stackTrace");
    }
    print("✅ [INIT STATE] AddSessionScreen initState completed");
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
                        "Tell us about yourself",
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
                      const ListInputWidget(
                        title: "What are your types of therapies you provide",
                        hintText: 'Type a language and press space',
                      ),
                      const SizedBox(height: 10),
                      const ListInputWidget(
                        title: "Select the mode of session",
                        hintText: 'Enter your specializations',
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Select the mode of session",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 33.75 / 27,
                          letterSpacing: 0.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SelectablePillList(
                        options: ["Online", "In-Person", "Hybrid"],
                        onSelectionChanged: (selected) {
                          print("Selected options: $selected");
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Select your available days",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 33.75 / 27,
                          letterSpacing: 0.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SelectablePillList(
                        options: [
                          "Mon",
                          "Tue",
                          "Wed",
                          "Thu",
                          "Fri",
                          "Sat",
                          "Sun",
                        ],
                        onSelectionChanged: (selected) {
                          print("Selected options: $selected");
                        },
                      ),
                      // 👇 NEW SECTION: Time Availability
                      const SizedBox(height: 20),
                      const Text(
                        "Set your availability time",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 33.75 / 27,
                          letterSpacing: 0.25,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TimeAvailabilityField(
                        onTimeSelected: (from, to) {
                          print(
                            "From: ${from.format(context)}, To: ${to.format(context)}",
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Builder(
                        builder: (context) {
                          print(
                            "🔍 [BUTTON BUILDER] Building button widget...",
                          );
                          try {
                            print(
                              "🔍 [BUTTON BUILDER] Accessing controller...",
                            );
                            final ctrl = controller;
                            print(
                              "✅ [BUTTON BUILDER] Controller accessed: ${ctrl.hashCode}",
                            );
                            return Obx(() {
                              print("🔍 [OBX] Rebuilding button widget...");
                              try {
                                print("🔍 [OBX] Accessing ctrl.isLoading...");
                                final isLoadingValue = ctrl.isLoading.value;
                                print(
                                  "✅ [OBX] isLoading.value = $isLoadingValue",
                                );
                                final buttonText = isLoadingValue
                                    ? "Creating Profile..."
                                    : "Verify and Continue";
                                print("✅ [OBX] Button text: $buttonText");

                                return GradientButton(
                                  text: buttonText,
                                  onPressed: isLoadingValue
                                      ? () {
                                          print(
                                            "⏸️ [BUTTON] Button disabled (loading)",
                                          );
                                        }
                                      : () async {
                                          print(
                                            "🚀 [BUTTON] Button pressed - starting profile creation",
                                          );
                                          try {
                                            print(
                                              "🔍 [BUTTON] Step 1: Saving to cache...",
                                            );
                                            await ctrl.saveToCache();
                                            print(
                                              "✅ [BUTTON] Step 1 completed: Cache saved",
                                            );

                                            print(
                                              "🔍 [BUTTON] Step 2: Calling createProfile API...",
                                            );
                                            final success = await ctrl
                                                .createProfile();
                                            print(
                                              "✅ [BUTTON] Step 2 completed: createProfile returned: $success",
                                            );

                                            print(
                                              "🔍 [BUTTON] Step 3: Checking success and message...",
                                            );
                                            print("   - success: $success");
                                            print(
                                              "   - message.value: ${ctrl.message.value}",
                                            );
                                            print(
                                              "   - message.value.isNotEmpty: ${ctrl.message.value.isNotEmpty}",
                                            );

                                            if (success &&
                                                ctrl.message.value.isNotEmpty) {
                                              print(
                                                "✅ [BUTTON] Profile created successfully, navigating to create support community...",
                                              );
                                              // MHP profile created: go to create support community
                                              Get.toNamed(
                                                AppRoutes.CreateSupportCommunity,
                                              );
                                              print(
                                                "✅ [BUTTON] Navigation completed",
                                              );
                                            } else {
                                              print(
                                                "🔍 [BUTTON] Checking error message...",
                                              );
                                              print(
                                                "   - errorMessage.value: ${ctrl.errorMessage.value}",
                                              );
                                              print(
                                                "   - errorMessage.value.isNotEmpty: ${ctrl.errorMessage.value.isNotEmpty}",
                                              );

                                              if (ctrl
                                                  .errorMessage
                                                  .value
                                                  .isNotEmpty) {
                                                print(
                                                  "❌ [BUTTON] Showing error message: ${ctrl.errorMessage.value}",
                                                );
                                                // Show error message
                                                Get.snackbar(
                                                  'Error',
                                                  ctrl.errorMessage.value,
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  backgroundColor: Colors.red,
                                                  colorText: Colors.white,
                                                );
                                              } else {
                                                print(
                                                  "⚠️ [BUTTON] No success and no error message",
                                                );
                                              }
                                            }
                                          } catch (e, stackTrace) {
                                            print(
                                              "❌ [BUTTON] Error in button handler: $e",
                                            );
                                            print(
                                              "📚 [BUTTON] Stack trace: $stackTrace",
                                            );
                                            Get.snackbar(
                                              'Error',
                                              'An unexpected error occurred: $e',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                          }
                                        },
                                );
                              } catch (e, stackTrace) {
                                print(
                                  "❌ [OBX] Error accessing controller properties: $e",
                                );
                                print("📚 [OBX] Stack trace: $stackTrace");
                                return GradientButton(
                                  text: "Error Loading...",
                                  onPressed: () {
                                    Get.snackbar(
                                      'Error',
                                      'Controller property access error: $e',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  },
                                );
                              }
                            });
                          } catch (e, stackTrace) {
                            print(
                              '❌ [BUTTON BUILDER] Error accessing controller: $e',
                            );
                            print(
                              '📚 [BUTTON BUILDER] Stack trace: $stackTrace',
                            );
                            return GradientButton(
                              text: "Verify and Continue",
                              onPressed: () {
                                Get.snackbar(
                                  'Error',
                                  'Controller not available. Please try again.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              },
                            );
                          }
                        },
                      ),
                      Builder(
                        builder: (context) {
                          print(
                            "🔍 [ERROR MESSAGE BUILDER] Building error message widget...",
                          );
                          try {
                            print(
                              "🔍 [ERROR MESSAGE BUILDER] Accessing controller...",
                            );
                            final ctrl = controller;
                            print(
                              "✅ [ERROR MESSAGE BUILDER] Controller accessed: ${ctrl.hashCode}",
                            );
                            return Obx(() {
                              print(
                                "🔍 [ERROR OBX] Rebuilding error message widget...",
                              );
                              try {
                                print(
                                  "🔍 [ERROR OBX] Accessing ctrl.errorMessage...",
                                );
                                final errorMsg = ctrl.errorMessage.value;
                                print(
                                  "✅ [ERROR OBX] errorMessage.value = '$errorMsg'",
                                );
                                print(
                                  "✅ [ERROR OBX] errorMessage.isNotEmpty = ${errorMsg.isNotEmpty}",
                                );

                                return errorMsg.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          errorMsg,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    : const SizedBox();
                              } catch (e, stackTrace) {
                                print(
                                  "❌ [ERROR OBX] Error accessing errorMessage: $e",
                                );
                                print(
                                  "📚 [ERROR OBX] Stack trace: $stackTrace",
                                );
                                return const SizedBox();
                              }
                            });
                          } catch (e, stackTrace) {
                            print(
                              "❌ [ERROR MESSAGE BUILDER] Error accessing controller: $e",
                            );
                            print(
                              "📚 [ERROR MESSAGE BUILDER] Stack trace: $stackTrace",
                            );
                            return const SizedBox();
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
