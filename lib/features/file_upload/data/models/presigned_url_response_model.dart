// data/models/presigned_url_response_model.dart
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/presigned_url_response.dart';

class PresignedUrlResponseModel extends PresignedUrlResponse {
  PresignedUrlResponseModel({
    required super.url,
    required super.type,
    required super.path,
  });

  factory PresignedUrlResponseModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing PresignedUrlResponseModel from JSON:');
    print('   Keys: ${json.keys.toList()}');
    print('   Full JSON: $json');

    // Handle success response: {"data": {"url": "...", "type": "...", "path": "..."}, "msg": "success"}
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      final data = json['data'] as Map<String, dynamic>;
      if (data.containsKey('url') && data.containsKey('path')) {
        print('✅ Found presigned URL in data object');
        return PresignedUrlResponseModel(
          url: data['url'] as String,
          type: data['type'] as String? ?? 'application/octet-stream',
          path: data['path'] as String,
        );
      }
    }

    // Handle error response: {"msg": {"error": "unknown file type"}}
    if (json.containsKey('msg') && json['msg'] is Map) {
      final msgMap = json['msg'] as Map<String, dynamic>;
      if (msgMap.containsKey('error')) {
        print('❌ Found error in "msg.error"');
        throw ServerException(msgMap['error'] as String);
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
      if (errorMsg.toLowerCase() != 'success') {
        print('❌ Found error message as string: $errorMsg');
        throw ServerException(errorMsg);
      }
    }

    throw ServerException(
      'Invalid response format for presigned URL: $json',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'type': type,
      'path': path,
    };
  }
}

