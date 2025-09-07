import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fly/features/auth/presentation/widgets/or_continue_with.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/features/profile_creation/controller/user_profile_controller.dart';
import 'package:fly/features/profile_creation/presentation/widgets/bio_input_field.dart';
import 'package:fly/features/profile_creation/presentation/widgets/dob_input_field.dart';
import 'package:fly/features/profile_creation/presentation/widgets/profile_picture_picker.dart';
import 'package:fly/features/profile_creation/presentation/widgets/user_name_input_field.dart';
import 'package:get/get.dart';

class MhpProfileScreen extends StatefulWidget {
  const MhpProfileScreen({super.key});

  @override
  State<MhpProfileScreen> createState() => _MhpProfileScreenState();
}

class _MhpProfileScreenState extends State<MhpProfileScreen> {
  double _dragPosition = 0.8;
  late final String role;
  final UserProfileController controller = Get.put(UserProfileController());

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    role = (args['role'] ?? 'user').toLowerCase();
    print("MhpProfileScreen role: $role");
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
                      CustomInputField(
                        hintText: "Enter first name",
                        onChanged: (value) => controller.username.value = value,
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
                          print("Bio: $value");
                        },
                      ),
                      const SizedBox(height: 10),
                      GradientButton(
                        text: "Verify and Continue",
                        onPressed: () {
                          Get.toNamed('/intro-quiz', arguments: {'role': role});
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
