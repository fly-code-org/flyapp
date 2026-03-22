// domain/repositories/nira_repository.dart
import '../../data/models/nira_message_model.dart';
import '../../data/models/nira_session_model.dart';

abstract class NiraRepository {
  Future<NiraMessageModel> sendMessage(String message);
  Future<List<NiraMessageModel>> getMessages(String sessionId);
  Future<NiraSessionModel?> getSession(String sessionId);
  Future<NiraSessionModel?> getActiveSession();
  Future<void> endSession(String sessionId);
}
