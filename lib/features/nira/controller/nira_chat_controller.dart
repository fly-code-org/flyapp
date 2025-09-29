import 'package:get/get.dart';
import '../model/message_model.dart';

class NiraChatController extends GetxController {
  var isChatStarted = false.obs;
  var messages = <Message>[].obs;

  void startChat() {
    isChatStarted.value = true;
    messages.add(
      Message(sender: "nira", text: "Hello! How are you feeling today?"),
    );
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    messages.add(Message(sender: "user", text: text));

    // Dummy NIRA response
    Future.delayed(Duration(milliseconds: 600), () {
      messages.add(
        Message(sender: "nira", text: "I hear you. Tell me more..."),
      );
    });
  }

  void clearChat() {
    messages.clear();
    isChatStarted.value = false;
  }
}
