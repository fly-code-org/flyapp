// domain/entities/presigned_url_response.dart
class PresignedUrlResponse {
  final String url;
  final String type;
  final String path;

  PresignedUrlResponse({
    required this.url,
    required this.type,
    required this.path,
  });
}

