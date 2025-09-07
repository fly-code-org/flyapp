import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fly/features/auth/presentation/widgets/or_continue_with.dart';
import 'package:fly/features/profile_creation/presentation/widgets/input_field.dart';
import 'package:fly/features/profile_creation/presentation/widgets/list_input.dart';
import 'package:fly/features/profile_creation/presentation/widgets/select_pill_list.dart';
import 'package:fly/features/profile_creation/presentation/widgets/time_field.dart';
import 'package:fly/features/user_verification/presentation/widgets/gradient_button.dart';
import 'package:fly/features/profile_creation/controller/user_profile_controller.dart';
import 'package:fly/features/profile_creation/presentation/widgets/bio_input_field.dart';
import 'package:fly/features/profile_creation/presentation/widgets/dob_input_field.dart';
import 'package:fly/features/profile_creation/presentation/widgets/profile_picture_picker.dart';
import 'package:fly/features/profile_creation/presentation/widgets/user_name_input_field.dart';
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
  final UserProfileController controller = Get.put(UserProfileController());

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    role = (args['role'] ?? 'user').toLowerCase();
    print("AddSessionScreen role: $role");
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
