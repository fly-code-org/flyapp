import '../../../../core/error/exceptions.dart';
import '../../domain/entities/answer_response.dart';

class AnswerResponseModel extends AnswerResponse {
  AnswerResponseModel({
    required super.message,
    super.data,
  });

  factory AnswerResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['msg'] != null && json['msg'] is Map && json['msg']['error'] != null) {
      throw ServerException(
        json['msg']['error'].toString(),
        statusCode: 400,
      );
    }

    final message = json['msg']?.toString() ?? 'Answer submitted successfully';
    final data = json['data'];

    return AnswerResponseModel(
      message: message,
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': message,
      'data': data,
    };
  }
}

