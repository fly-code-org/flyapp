import 'package:flutter/material.dart';
import 'package:fly/features/create_community/presentation/widgets/bottom_navbar.dart';
import 'package:fly/features/nira/widgets/intro_section.dart';
import 'package:fly/features/nira/widgets/nira_chat_ui.dart';
import 'package:get/get.dart';
import '../controller/nira_chat_controller.dart';

class NiraChatScreen extends StatelessWidget {
  final NiraChatController controller = Get.put(NiraChatController());
  final TextEditingController inputController = TextEditingController();
  final int _currentIndex = 2; // NIRA tab index

  NiraChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return WillPopScope(
        onWillPop: () async {
          if (controller.isChatStarted.value) {
            controller.clearChat(); // reset to intro instead of leaving
            return false; // don't exit yet
          }
          return true; // allow normal pop when intro screen is shown
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: controller.isChatStarted.value
              ? null // hide navbar when chat is active
              : BottomNavBar(currentIndex: _currentIndex),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (controller.isChatStarted.value) {
                    controller.clearChat(); // go back to intro
                  } else {
                    Navigator.pop(context); // exit screen
                  }
                },
              ),
              centerTitle: true,
              title: controller.isChatStarted.value
                  ? Image.asset(
                      "assets/images/nira.png", // your NIRA logo
                      height: 36,
                    )
                  : const Text(
                      "New Chat",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (_) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.info_outline,
                                color: Colors.blueGrey,
                              ),
                              title: const Text("About NIRA"),
                              onTap: () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("About NIRA"),
                                    content: const Text(
                                      "NIRA [Neural Interactive Response Assistant] is a chat assistant designed to support your emotional well-being. Whether you’re feeling overwhelmed, need someone to talk to, or just want to check in with yourself, NIRA is here to listen, guide, and help you feel a little lighter—anytime, anywhere.",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Close"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                              title: const Text(
                                "Clear Chat",
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                controller.clearChat();
                              },
                            ),
                            const Divider(thickness: 1),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          body: controller.isChatStarted.value
              ? NiraChatUI(
                  controller: controller,
                  inputController: inputController,
                )
              : IntroSection(controller: controller),
        ),
      );
    });
  }
}
