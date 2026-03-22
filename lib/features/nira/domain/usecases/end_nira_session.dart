// domain/usecases/end_nira_session.dart
import '../repositories/nira_repository.dart';

class EndNiraSession {
  final NiraRepository repository;

  EndNiraSession(this.repository);

  Future<void> call(String sessionId) => repository.endSession(sessionId);
}
