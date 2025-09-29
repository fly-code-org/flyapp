import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fly/features/create_community/presentation/widgets/bottom_navbar.dart';

import '../controller/nira_chat_controller.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/intro_section.dart';

class NiraChatScreen extends StatelessWidget {
  final NiraChatController controller = Get.put(NiraChatController());
  final TextEditingController inputController = TextEditingController();
  final int _currentIndex = 2; // NIRA tab index

  NiraChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: controller.isChatStarted.value
            ? null
            : BottomNavBar(currentIndex: _currentIndex),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Obx(() {
            return AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: controller.isChatStarted.value
                  ? Image.asset("assets/images/nira.png", height: 36)
                  : Text(
                      "New Chat",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
              actions: [
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () => _showMenu(context),
                ),
              ],
            );
          }),
        ),
        body: Obx(() {
          if (!controller.isChatStarted.value) {
            return IntroSection(controller: controller);
          } else {
            return Column(
              children: [
                Expanded(
                  child: Obx(() {
                    return ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        return ChatBubble(message: controller.messages[index]);
                      },
                    );
                  }),
                ),
                ChatInputBar(
                  controller: inputController,
                  onSend: () {
                    controller.sendMessage(inputController.text);
                    inputController.clear();
                  },
                ),
              ],
            );
          }
        }),
      );
    });
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.blueGrey),
              title: Text("About NIRA"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("About NIRA"),
                    content: Text(
                      "NIRA [Neural Interactive Response Assistant] is a chat assistant designed to support your emotional well-being. Whether you’re feeling overwhelmed, need someone to talk to, or just want to check in with yourself, NIRA is here to listen, guide, and help you feel a little lighter—anytime, anywhere.",
                      style: TextStyle(fontSize: 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Close"),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red),
              title: Text("Clear Chat", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                controller.clearChat();
              },
            ),
            Divider(thickness: 1),
          ],
        );
      },
    );
  }
}
