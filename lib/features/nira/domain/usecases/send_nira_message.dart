// domain/usecases/send_nira_message.dart
import '../../data/models/nira_message_model.dart';
import '../repositories/nira_repository.dart';

class SendNiraMessage {
  final NiraRepository repository;

  SendNiraMessage(this.repository);

  Future<NiraMessageModel> call(String message) =>
      repository.sendMessage(message);
}
