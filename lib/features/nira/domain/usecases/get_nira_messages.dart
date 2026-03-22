// domain/usecases/get_nira_messages.dart
import '../../data/models/nira_message_model.dart';
import '../repositories/nira_repository.dart';

class GetNiraMessages {
  final NiraRepository repository;

  GetNiraMessages(this.repository);

  Future<List<NiraMessageModel>> call(String sessionId) =>
      repository.getMessages(sessionId);
}
