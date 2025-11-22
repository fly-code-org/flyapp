// domain/usecases/get_presigned_url.dart
import '../entities/presigned_url_response.dart';
import '../repositories/upload_repository.dart';

class GetPresignedUrl {
  final UploadRepository repository;

  GetPresignedUrl(this.repository);

  Future<PresignedUrlResponse> call({
    required String fileType,
    required String fileName,
    required String contentType,
  }) {
    return repository.getPresignedUrl(
      fileType: fileType,
      fileName: fileName,
      contentType: contentType,
    );
  }
}

