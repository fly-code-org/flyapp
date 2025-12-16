// core/utils/jwt_decoder.dart
import 'dart:convert';

class JwtDecoder {
  /// Decode JWT token and extract payload
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      // Decode the payload (second part)
      final payload = parts[1];
      
      // Add padding if needed
      String normalizedPayload = payload;
      switch (payload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      print('⚠️ [JWT] Error decoding token: $e');
      return null;
    }
  }

  /// Extract role from JWT token
  static String? getRole(String? token) {
    if (token == null || token.isEmpty) {
      return null;
    }

    final payload = decodePayload(token);
    if (payload == null) {
      return null;
    }

    return payload['role'] as String?;
  }

  /// Check if user is MHP
  static bool isMhp(String? token) {
    final role = getRole(token);
    return role?.toLowerCase() == 'mhp';
  }

  /// Extract user ID from JWT token
  static String? getUserId(String? token) {
    if (token == null || token.isEmpty) {
      return null;
    }

    final payload = decodePayload(token);
    if (payload == null) {
      return null;
    }

    return payload['user_id'] as String?;
  }

  /// Extract user name from JWT token
  static String? getUserName(String? token) {
    if (token == null || token.isEmpty) {
      return null;
    }

    final payload = decodePayload(token);
    if (payload == null) {
      return null;
    }

    return payload['user_name'] as String?;
  }
}

