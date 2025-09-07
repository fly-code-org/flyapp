import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fly/features/auth/presentation/widgets/or_continue_with.dart';
import 'package:fly/features/profile_creation/presentation/widgets/add_media.dart';
import 'package:fly/features/profile_creation/presentation/widgets/input_field.dart';
import 'package:fly/features/profile_creation/presentation/widgets/list_input.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/features/profile_creation/controller/user_profile_controller.dart';
import 'package:fly/features/profile_creation/presentation/widgets/bio_input_field.dart';
import 'package:fly/features/profile_creation/presentation/widgets/dob_input_field.dart';
import 'package:fly/features/profile_creation/presentation/widgets/profile_picture_picker.dart';
import 'package:fly/features/profile_creation/presentation/widgets/user_name_input_field.dart';
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
  final UserProfileController controller = Get.put(UserProfileController());

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    role = (args['role'] ?? 'user').toLowerCase();
    print("MoreInfoScreen role: $role");
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
                        "Add the name of your college/univerity",
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
                        onChanged: (value) => controller.username.value = value,
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
                        hintText: "Enter your college name",
                        onChanged: (value) => controller.username.value = value,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Years of experience",
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
                        onChanged: (value) => controller.username.value = value,
                      ),

                      const SizedBox(height: 10),
                      const ListInputWidget(
                        title: "Languages you know",
                        hintText: 'Type a language and press space',
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
                        onChanged: (value) => controller.username.value = value,
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
                      AddMediaWidget(
                        onTap: () {
                          // Open file picker here
                          print("Pick a PDF or media file");
                        },
                        text: "Add Degree Certificate",
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        text: "Verify and Continue",
                        onPressed: () {
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
