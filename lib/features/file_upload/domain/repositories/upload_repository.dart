// domain/repositories/upload_repository.dart
import '../entities/presigned_url_response.dart';

abstract class UploadRepository {
  Future<PresignedUrlResponse> getPresignedUrl({
    required String fileType,
    required String fileName,
    required String contentType,
  });
}

