import 'package:get/get.dart';
import '../data/models/nira_message_model.dart';
import '../domain/usecases/end_nira_session.dart';
import '../domain/usecases/get_active_nira_session.dart';
import '../domain/usecases/get_nira_messages.dart';
import '../domain/usecases/send_nira_message.dart';
import '../model/message_model.dart';

class NiraChatController extends GetxController {
  final SendNiraMessage sendNiraMessage;
  final GetNiraMessages getNiraMessages;
  final GetActiveNiraSession getActiveNiraSession;
  final EndNiraSession endNiraSession;

  NiraChatController({
    required this.sendNiraMessage,
    required this.getNiraMessages,
    required this.getActiveNiraSession,
    required this.endNiraSession,
  });

  var isChatStarted = false.obs;
  var messages = <Message>[].obs;
  var currentSessionId = Rxn<String>();
  var isSending = false.obs;
  var isLoadingSession = false.obs;
  var errorMessage = Rxn<String>();

  static const String _welcomeText =
      "Hello! How are you feeling today?";

  /// Start chat: try to restore active session and history; otherwise show welcome only.
  Future<void> startChat() async {
    if (isChatStarted.value) return;
    isLoadingSession.value = true;
    errorMessage.value = null;
    try {
      final session = await getActiveNiraSession();
      if (session != null) {
        currentSessionId.value = session.id;
        final list = await getNiraMessages(session.id);
        messages.value = _messagesFromApi(list);
        isChatStarted.value = true;
      } else {
        messages.value = [
          Message(sender: "nira", text: _welcomeText),
        ];
        isChatStarted.value = true;
      }
    } catch (e) {
      final msg = e.toString();
      errorMessage.value = msg;
      _showError(msg);
      // Still start chat with welcome message so user can try sending
      messages.value = [Message(sender: "nira", text: _welcomeText)];
      isChatStarted.value = true;
    } finally {
      isLoadingSession.value = false;
    }
  }

  /// Placeholder when backend/ML returns no NIRA reply (so user always sees feedback).
  static const String _noReplyPlaceholder =
      "Your message was saved. NIRA couldn't respond right now—please try again.";

  /// Send a message to NIRA and append user + NIRA reply from API.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (isSending.value) return;
    errorMessage.value = null;
    isSending.value = true;
    try {
      final msg = await sendNiraMessage(text);
      currentSessionId.value ??= msg.sessionId;
      messages.add(Message(sender: "user", text: msg.userMessage));
      final niraText = (msg.niraResponse != null && msg.niraResponse!.trim().isNotEmpty)
          ? msg.niraResponse!
          : _noReplyPlaceholder;
      messages.add(Message(sender: "nira", text: niraText));
    } catch (e) {
      final msg = e.toString();
      errorMessage.value = msg;
      _showError(msg);
    } finally {
      isSending.value = false;
    }
  }

  /// Clear chat and end session on backend if we have an active session.
  Future<void> clearChat() async {
    final sessionId = currentSessionId.value;
    if (sessionId != null && sessionId.isNotEmpty) {
      try {
        await endNiraSession(sessionId);
      } catch (_) {
        // Still clear UI
      }
    }
    currentSessionId.value = null;
    messages.clear();
    isChatStarted.value = false;
    errorMessage.value = null;
  }

  void clearError() {
    errorMessage.value = null;
  }

  void _showError(String message) {
    final friendly = _toFriendlyMessage(message);
    Get.snackbar(
      'Something went wrong',
      friendly,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  /// Map raw exception messages to user-friendly text.
  String _toFriendlyMessage(String raw) {
    final lower = raw.toLowerCase().trim();
    if (lower.contains('unauthorized') || lower.contains('401') || lower.contains('token') ||
        lower.contains('authorization')) {
      return 'Please sign in again to use NIRA.';
    }
    if (lower.contains('timeout') || lower.contains('connection')) {
      return 'Connection issue. Check your internet and try again.';
    }
    if (lower.contains('network') || lower.contains('internet')) {
      return 'No internet connection. Check your network and try again.';
    }
    if (lower.contains('404') || lower.contains('not found')) {
      return 'NIRA is temporarily unavailable. Please try again later.';
    }
    // Avoid showing raw "Request failed" or "failed"
    if (lower == 'request failed' || lower == 'failed' || lower.isEmpty ||
        lower.startsWith('exception') || lower.contains('serverexception')) {
      return 'Something went wrong. Please try again.';
    }
    // Show server message if it looks readable (no stack traces)
    if (raw.length < 120 && !raw.contains('Exception')) {
      return raw;
    }
    return 'Something went wrong. Please try again.';
  }

  /// Map API message list to UI Message list (each API message → user + nira bubbles).
  /// Messages without a NIRA reply show a placeholder so history is consistent.
  List<Message> _messagesFromApi(List<NiraMessageModel> list) {
    final result = <Message>[];
    for (final m in list) {
      result.add(Message(sender: "user", text: m.userMessage));
      final niraText = (m.niraResponse != null && m.niraResponse!.trim().isNotEmpty)
          ? m.niraResponse!
          : _noReplyPlaceholder;
      result.add(Message(sender: "nira", text: niraText));
    }
    return result;
  }
}
