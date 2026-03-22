// data/repositories/nira_repository_impl.dart
import '../../domain/repositories/nira_repository.dart';
import '../datasources/nira_remote_data_source.dart';
import '../models/nira_message_model.dart';
import '../models/nira_session_model.dart';

class NiraRepositoryImpl implements NiraRepository {
  final NiraRemoteDataSource remoteDataSource;

  NiraRepositoryImpl(this.remoteDataSource);

  @override
  Future<NiraMessageModel> sendMessage(String message) =>
      remoteDataSource.sendMessage(message);

  @override
  Future<List<NiraMessageModel>> getMessages(String sessionId) =>
      remoteDataSource.getMessages(sessionId);

  @override
  Future<NiraSessionModel?> getSession(String sessionId) =>
      remoteDataSource.getSession(sessionId);

  @override
  Future<NiraSessionModel?> getActiveSession() =>
      remoteDataSource.getActiveSession();

  @override
  Future<void> endSession(String sessionId) =>
      remoteDataSource.endSession(sessionId);
}
