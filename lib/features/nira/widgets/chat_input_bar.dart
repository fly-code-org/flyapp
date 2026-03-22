import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Type your message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[100],
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          isSending
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: onSend,
                ),
        ],
      ),
    );
  }
}
