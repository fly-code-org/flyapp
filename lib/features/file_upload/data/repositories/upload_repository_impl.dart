// data/repositories/upload_repository_impl.dart
import '../../domain/entities/presigned_url_response.dart';
import '../../domain/repositories/upload_repository.dart';
import '../datasources/upload_remote_data_source.dart';

class UploadRepositoryImpl implements UploadRepository {
  final UploadRemoteDataSource remoteDataSource;
  UploadRepositoryImpl(this.remoteDataSource);

  @override
  Future<PresignedUrlResponse> getPresignedUrl({
    required String fileType,
    required String fileName,
    required String contentType,
  }) async {
    final response = await remoteDataSource.getPresignedUrl(
      fileType: fileType,
      fileName: fileName,
      contentType: contentType,
    );
    return response;
  }
}

