import 'package:flutter/material.dart';
import 'package:fly/features/profile_creation/presentation/widgets/add_media.dart';
import 'package:fly/features/profile_creation/presentation/widgets/input_field.dart';
import 'package:fly/features/profile_creation/presentation/widgets/list_input.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/profile_creation/controller/user_profile_controller.dart';
import 'package:fly/features/profile_creation/domain/usecases/create_mhp_profile.dart';
import 'package:fly/routes/app_routes.dart';
import 'package:get/get.dart';

class MoreInfoScreen extends StatefulWidget {
  const MoreInfoScreen({super.key});

  @override
  State<MoreInfoScreen> createState() => _MoreInfoScreenState();
}

class _MoreInfoScreenState extends State<MoreInfoScreen> {
  double _dragPosition = 0.8;
  late final String role;

  // Get controller safely - finds existing or creates new
  UserProfileController get controller {
    print("🔍 [MHP MORE INFO] [CONTROLLER GETTER] Accessing controller...");
    try {
      print(
        "🔍 [MHP MORE INFO] [CONTROLLER GETTER] Attempting to find existing controller...",
      );
      final foundController = Get.find<UserProfileController>(
        tag: 'UserProfileController',
      );
      print(
        "✅ [MHP MORE INFO] [CONTROLLER GETTER] Found existing controller: ${foundController.hashCode}",
      );
      return foundController;
    } catch (e) {
      print(
        "📝 [MHP MORE INFO] [CONTROLLER GETTER] Controller not found, creating new one. Error: $e",
      );
      try {
        final createMhpProfile = sl<CreateMhpProfile>();
        print(
          "✅ [MHP MORE INFO] [CONTROLLER GETTER] CreateMhpProfile retrieved from service locator",
        );
        final newController = UserProfileController(
          createMhpProfile: createMhpProfile,
        );
        final registeredController = Get.put(
          newController,
          tag: 'UserProfileController',
          permanent: false,
        );
        print(
          "✅ [MHP MORE INFO] [CONTROLLER GETTER] Controller registered: ${registeredController.hashCode}",
        );
        return registeredController;
      } catch (slError) {
        print(
          "❌ [MHP MORE INFO] [CONTROLLER GETTER] Error getting CreateMhpProfile: $slError",
        );
        final fallbackController = UserProfileController(
          createMhpProfile: null,
        );
        final registeredController = Get.put(
          fallbackController,
          tag: 'UserProfileController',
          permanent: false,
        );
        print(
          "✅ [MHP MORE INFO] [CONTROLLER GETTER] Fallback controller registered: ${registeredController.hashCode}",
        );
        return registeredController;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    print("🚀 [MHP MORE INFO] [INIT STATE] initState started");
    final args = Get.arguments;
    role = (args['role'] ?? 'user').toLowerCase();
    print("✅ [MHP MORE INFO] [INIT STATE] Role set to: $role");
    try {
      print("🔍 [MHP MORE INFO] [INIT STATE] Initializing controller...");
      final ctrl = controller;
      print(
        "✅ [MHP MORE INFO] [INIT STATE] Controller initialized: ${ctrl.hashCode}",
      );
    } catch (e, stackTrace) {
      print("❌ [MHP MORE INFO] [INIT STATE] Error initializing controller: $e");
      print("📚 [MHP MORE INFO] [INIT STATE] Stack trace: $stackTrace");
    }
    print("✅ [MHP MORE INFO] [INIT STATE] initState completed");
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
                      const Text(
                        "Where have you studied?",
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
                      const Text(
                        "Add the name of your college/university",
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
                      GeneralCustomInputField(
                        hintText: "Enter your college name",
                        onChanged: (value) {
                          controller.university.value = value;
                          controller.saveToCache();
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "What did you pursue",
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
                      GeneralCustomInputField(
                        hintText: "Enter your major",
                        onChanged: (value) {
                          controller.degree.value = value;
                          controller.saveToCache();
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Years of experience: ",
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
                      GeneralCustomInputField(
                        hintText: "1-3 yrs",
                        onChanged: (value) {
                          controller.yearsOfExperience.value = value;
                          controller.saveToCache();
                        },
                      ),

                      const SizedBox(height: 10),
                      ListInputWidget(
                        title: "Languages you know",
                        hintText: 'Type a language and press space',
                        onLanguagesChanged: (languages) {
                          controller.languages.value = languages;
                          controller.saveToCache();
                        },
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "State where you practice",
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
                      GeneralCustomInputField(
                        hintText: "Enter your state",
                        onChanged: (value) {
                          controller.workLocation.value = value;
                          controller.saveToCache();
                        },
                      ),
                      const SizedBox(height: 10),
                      const ListInputWidget(
                        title: "Add Specializations",
                        hintText: 'Enter your specializations',
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Upload your degree certificate",
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
                      const Text(
                        "Add your certificate in PDF format",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 33.75 / 27,
                          letterSpacing: 0.25,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Builder(
                        builder: (context) {
                          try {
                            final ctrl = controller;
                            return Obx(
                              () => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AddMediaWidget(
                                    onTap: () async {
                                      print(
                                        "🔍 [MHP MORE INFO] AddMediaWidget tapped",
                                      );
                                      try {
                                        await ctrl.pickDegreeFile();
                                        print(
                                          "✅ [MHP MORE INFO] File picker completed",
                                        );
                                      } catch (e) {
                                        print(
                                          "❌ [MHP MORE INFO] Error in file picker: $e",
                                        );
                                        Get.snackbar(
                                          'Error',
                                          'Failed to pick file: $e',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      }
                                    },
                                    text: ctrl.selectedDegreeFile.value != null
                                        ? "Change Degree Certificate"
                                        : "Add Degree Certificate",
                                  ),
                                  if (ctrl.selectedDegreeFile.value !=
                                      null) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[700]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.description,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  ctrl
                                                      .selectedDegreeFile
                                                      .value!
                                                      .name,
                                                  style: const TextStyle(
                                                    fontFamily: 'Lexend',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${(ctrl.selectedDegreeFile.value!.size / 1024).toStringAsFixed(2)} KB',
                                                  style: TextStyle(
                                                    fontFamily: 'Lexend',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              ctrl.selectedDegreeFile.value =
                                                  null;
                                              ctrl.degreePath.value = '';
                                              print(
                                                "🗑️ [MHP MORE INFO] File removed",
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          } catch (e) {
                            print(
                              "❌ [MHP MORE INFO] Error accessing controller: $e",
                            );
                            return AddMediaWidget(
                              onTap: () {
                                Get.snackbar(
                                  'Error',
                                  'Controller not available',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              },
                              text: "Add Degree Certificate",
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        text: "Verify and Continue",
                        onPressed: () async {
                          // Save current form data before navigating
                          await controller.saveToCache();
                          Get.toNamed(AppRoutes.AddSessionForm);
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
