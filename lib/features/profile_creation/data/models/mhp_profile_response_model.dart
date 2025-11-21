// data/models/mhp_profile_response_model.dart
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/mhp_profile_response.dart';

class MhpProfileResponseModel extends MhpProfileResponse {
  MhpProfileResponseModel({
    required super.message,
    super.data,
  });

  factory MhpProfileResponseModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing MhpProfileResponseModel from JSON:');
    print('   Keys: ${json.keys.toList()}');
    print('   Full JSON: $json');

    // Handle success response: {"data": null, "msg": "MHP Profile created successfully"}
    if (json.containsKey('msg') && json['msg'] is String) {
      final message = json['msg'] as String;
      print('✅ Found success message: $message');
      return MhpProfileResponseModel(
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
      'Invalid response format for MHP profile creation: $json',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': message,
      'data': data,
    };
  }
}

