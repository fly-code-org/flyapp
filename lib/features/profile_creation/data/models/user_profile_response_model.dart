// data/models/user_profile_response_model.dart
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_profile_response.dart';

class UserProfileResponseModel extends UserProfileResponse {
  UserProfileResponseModel({
    required super.message,
    super.data,
  });

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing UserProfileResponseModel from JSON:');
    print('   Keys: ${json.keys.toList()}');
    print('   Full JSON: $json');

    // Handle success response: {"data": null, "msg": "User Profile created successfully"}
    if (json.containsKey('msg') && json['msg'] is String) {
      final message = json['msg'] as String;
      print('✅ Found success message: $message');
      return UserProfileResponseModel(
        message: message,
        data: json['data'],
      );
    }

    // Handle error response: {"msg": {"err: ": "error message"}}
    if (json.containsKey('msg') && json['msg'] is Map) {
      final msgMap = json['msg'] as Map<String, dynamic>;
      if (msgMap.containsKey('err: ')) {
        print('❌ Found error in "msg.err: "');
        throw ServerException(msgMap['err: '] as String);
      }
      if (msgMap.containsKey('err')) {
        print('❌ Found error in "msg.err"');
        throw ServerException(msgMap['err'] as String);
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

    throw ServerException(
      'Invalid response format for User profile creation: $json',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': message,
      'data': data,
    };
  }
}

