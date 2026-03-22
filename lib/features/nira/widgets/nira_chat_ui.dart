// features/nira_chat/widgets/nira_chat_ui.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/nira_chat_controller.dart';
import 'chat_bubble.dart';
import 'chat_input_bar.dart';

class NiraChatUI extends StatefulWidget {
  final NiraChatController controller;
  final TextEditingController inputController;

  const NiraChatUI({
    Key? key,
    required this.controller,
    required this.inputController,
  }) : super(key: key);

  @override
  State<NiraChatUI> createState() => _NiraChatUIState();
}

class _NiraChatUIState extends State<NiraChatUI> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // auto-scroll to bottom whenever messages change
    ever(widget.controller.messages, (_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            final msgs = widget.controller.messages;
            if (msgs.isEmpty) {
              // helpful placeholder
              return const Center(
                child: Text(
                  "No messages yet — say hi 👋",
                  style: TextStyle(color: Colors.black54),
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: msgs.length,
              itemBuilder: (context, index) {
                final message = msgs[index];
                return ChatBubble(message: message);
              },
            );
          }),
        ),
        Obx(() => ChatInputBar(
          controller: widget.inputController,
          onSend: () {
            final text = widget.inputController.text;
            if (text.trim().isEmpty) return;
            widget.controller.sendMessage(text);
            widget.inputController.clear();
          },
          isSending: widget.controller.isSending.value,
        )),
      ],
    );
  }
}
