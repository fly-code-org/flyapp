// domain/usecases/get_active_nira_session.dart
import '../../data/models/nira_session_model.dart';
import '../repositories/nira_repository.dart';

class GetActiveNiraSession {
  final NiraRepository repository;

  GetActiveNiraSession(this.repository);

  Future<NiraSessionModel?> call() => repository.getActiveSession();
}
