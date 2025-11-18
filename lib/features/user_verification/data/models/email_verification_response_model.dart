// data/models/email_verification_response_model.dart
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/email_verification_response.dart';

class EmailVerificationResponseModel extends EmailVerificationResponse {
  EmailVerificationResponseModel({required super.message});

  factory EmailVerificationResponseModel.fromJson(Map<String, dynamic> json) {
    // Debug: Log the JSON structure
    print('🔍 Parsing EmailVerificationResponseModel from JSON:');
    print('   Keys: ${json.keys.toList()}');
    print('   Full JSON: $json');

    // Handle success response: {"message": "Verification successful"}
    if (json.containsKey('message') && json['message'] is String) {
      print('✅ Found success message');
      return EmailVerificationResponseModel(
        message: json['message'] as String,
      );
    }

    // Handle error response: {"error": "error message"}
    if (json.containsKey('error') && json['error'] is String) {
      final errorMsg = json['error'] as String;
      print('❌ Found error: $errorMsg');
      throw ServerException(errorMsg);
    }

    // Fallback with detailed error
    print('❌ Invalid response format - no recognized structure');
    throw ServerException(
      'Invalid response format. Expected {"message": "..."} or {"error": "..."}. '
      'Received: $json',
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message};
  }
}

