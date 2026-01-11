// domain/usecases/create_post.dart
import '../entities/create_post_request.dart';
import '../repositories/post_repository.dart';

class CreatePost {
  final PostRepository repository;

  CreatePost(this.repository);

  Future<void> call(CreatePostRequest request) async {
    return await repository.createPost(request);
  }
}



