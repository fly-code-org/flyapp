// data/models/auth_response_model.dart
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/auth_response.dart';

class AuthResponseModel extends AuthResponse {
  AuthResponseModel({
    required super.token,
    required super.message,
    super.isEmailVerified = false,
    super.isPhoneVerified = false,
    super.isNewUser = false,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Debug: Log the JSON structure
    print('🔍 Parsing AuthResponseModel from JSON:');
    print('   Keys: ${json.keys.toList()}');
    print('   Full JSON: $json');

    // Handle login API format: {"token": {"jwt_token": "...", "is_email_verified": false, ...}}
    if (json.containsKey('token') && json['token'] is Map) {
      print('🔍 Found "token" as Map (login API format)');
      final tokenMap = json['token'] as Map<String, dynamic>;
      if (tokenMap.containsKey('jwt_token')) {
        final jwtToken = tokenMap['jwt_token'] as String;
        print('✅ Found jwt_token in "token" object');
        // Extract verification status from login response if available
        final isEmailVerified = tokenMap['is_email_verified'] as bool? ?? false;
        final isPhoneVerified = tokenMap['is_phone_verified'] as bool? ?? false;
        final isNewUser = tokenMap['is_new_user'] as bool? ?? false;

        return AuthResponseModel(
          token: jwtToken,
          message: 'Login successful',
          isEmailVerified: isEmailVerified,
          isPhoneVerified: isPhoneVerified,
          isNewUser: isNewUser,
        );
      }
    }

    // Handle signup API format: {"data": "token_string", "msg": "Success message"}
    if (json.containsKey('data') && json['data'] is String) {
      print('✅ Found token in "data" field (signup API format)');
      return AuthResponseModel(
        token: json['data'] as String,
        message: json['msg'] as String? ?? 'Success',
        isEmailVerified: false, // Signup doesn't include verification status
        isPhoneVerified: false,
      );
    }

    // Handle Google login format: {"data": {"jwt_token": "...", "is_email_verified": true, ...}}
    if (json.containsKey('data') && json['data'] is Map) {
      print('🔍 Found "data" as Map, checking for token...');
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap.containsKey('token') || dataMap.containsKey('jwt_token')) {
        final token =
            dataMap['token'] as String? ?? dataMap['jwt_token'] as String?;
        if (token != null) {
          print('✅ Found token in nested "data" object');

          // Extract email verification status and is_new_user for Google login
          final isEmailVerified =
              dataMap['is_email_verified'] as bool? ?? false;
          final isPhoneVerified =
              dataMap['is_phone_verified'] as bool? ?? false;
          final isNewUser = dataMap['is_new_user'] as bool? ?? false;

          print('📧 Email verified: $isEmailVerified');
          print('📱 Phone verified: $isPhoneVerified');
          print('🆕 Is new user: $isNewUser');

          return AuthResponseModel(
            token: token,
            message:
                dataMap['message'] as String? ??
                json['msg'] as String? ??
                'Success',
            isEmailVerified: isEmailVerified,
            isPhoneVerified: isPhoneVerified,
            isNewUser: isNewUser,
          );
        }
      }
    }

    // Handle error response: {"msg": {"err": "error message"}} or {"msg": {"err: ": "error message"}}
    if (json.containsKey('msg') && json['msg'] is Map) {
      final msgMap = json['msg'] as Map<String, dynamic>;
      // Check for "err" key
      if (msgMap.containsKey('err')) {
        print('❌ Found error in "msg.err"');
        throw ServerException(msgMap['err'] as String);
      }
      // Check for "err: " key (with colon and space - signup API format)
      if (msgMap.containsKey('err: ')) {
        print('❌ Found error in "msg.err: "');
        throw ServerException(msgMap['err: '] as String);
      }
      // Check for any key starting with "err"
      for (final key in msgMap.keys) {
        if (key.toString().trim().startsWith('err')) {
          print('❌ Found error in "msg.$key"');
          throw ServerException(msgMap[key] as String);
        }
      }
    }

    // Handle error response: {"msg": "error message"} (string format)
    if (json.containsKey('msg') && json['msg'] is String) {
      final errorMsg = json['msg'] as String;
      print('❌ Found error message as string: $errorMsg');
      throw ServerException(errorMsg);
    }

    // Fallback with detailed error
    print('❌ Invalid response format - no recognized structure');
    throw ServerException(
      'Invalid response format. Expected {"token": {"jwt_token": "..."}} or {"data": "token", "msg": "message"}. '
      'Received: $json',
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': token, 'msg': message};
  }
}
