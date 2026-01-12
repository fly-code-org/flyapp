// data/datasources/post_remote_data_source.dart
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/post_model.dart';
import '../models/create_post_request_model.dart';

abstract class PostRemoteDataSource {
  Future<void> createPost(CreatePostRequestModel request);
  // Backend gets authorId from JWT token, so no parameter needed
  Future<List<PostModel>> getPostsByAuthorId();
  Future<List<PostModel>> getPostsByCommunityId(String communityId);
  Future<List<PostModel>> getPostsByTagId(int tagId);
  Future<List<PostModel>> getPostsByIds(List<String> postIds);
  Future<void> deletePost(String postId);
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<void> bookmarkPost(String postId);
  Future<void> unbookmarkPost(String postId);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio client;

  PostRemoteDataSourceImpl({Dio? dio}) : client = dio ?? ApiClient.dio;

  @override
  Future<void> createPost(CreatePostRequestModel request) async {
    try {
      print('📝 [POST API] Creating post...');
      print('   - Tag ID: ${request.tagId}');
      print('   - Content: ${request.content ?? "null"}');
      print('   - Attachments: ${request.attachments.length}');
      print('   - Has Poll: ${request.poll != null}');

      final requestData = request.toJson();
      print('📤 [POST API] Request data: $requestData');

      final response = await client.post(
        '/post/external/v1',
        data: requestData,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [POST API] Response Status: ${response.statusCode}');
      print('📦 [POST API] Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Backend returns {"msg": "Post created successfully", "data": "success"}
        print('✅ [POST API] Post created successfully');
        return;
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [POST API] DioException: ${e.type}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'No internet connection. Please check your network.',
        );
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'Failed to create post';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is Map && msg.containsKey('err: ')) {
              errorMessage = msg['err: '] as String;
            } else if (msg is String) {
              errorMessage = msg;
            }
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getPostsByAuthorId() async {
    try {
      print('🔍 [POST API] Fetching posts by author ID...');
      print('   - Author ID: (from JWT token)');

      final response = await client.get(
        '/post/external/v1/author/',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [POST API] Response Status: ${response.statusCode}');
      print('📦 [POST API] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is! Map<String, dynamic>) {
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}',
          );
        }

        final responseData = response.data as Map<String, dynamic>;
        final postsList = <PostModel>[];

        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          print('📦 [POST API] Response data type: ${data.runtimeType}');
          
          if (data == null) {
            print('⚠️ [POST API] Data is null, returning empty list');
            return [];
          } else if (data is List) {
            print('📦 [POST API] Data is a list with ${data.length} items');
            for (var item in data) {
              if (item is Map<String, dynamic>) {
                try {
                  final post = PostModel.fromJson(item);
                  postsList.add(post);
                  print('✅ [POST API] Parsed post: id=${post.id}, tagId=${post.tagId}');
                } catch (e, stackTrace) {
                  print('❌ [POST API] Error parsing post: $e');
                  print('❌ [POST API] Item: $item');
                  print('❌ [POST API] Stack: $stackTrace');
                }
              } else {
                print('⚠️ [POST API] Item is not a Map: ${item.runtimeType}');
              }
            }
          } else {
            print('⚠️ [POST API] Data is not a list: ${data.runtimeType}');
            print('⚠️ [POST API] Data content: $data');
          }
        } else {
          print('⚠️ [POST API] Response does not contain "data" key');
          print('⚠️ [POST API] Response keys: ${responseData.keys.toList()}');
        }

        print('✅ [POST API] Fetched ${postsList.length} posts');
        return postsList;
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [POST API] DioException: ${e.type}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'No internet connection. Please check your network.',
        );
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'Failed to fetch posts';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is Map && msg.containsKey('err: ')) {
              errorMessage = msg['err: '] as String;
            } else if (msg is String) {
              errorMessage = msg;
            }
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getPostsByCommunityId(String communityId) async {
    try {
      print('🔍 [POST API] Fetching posts by community ID...');
      print('   - Community ID: $communityId');

      final response = await client.get(
        '/post/external/v1/community/$communityId',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [POST API] Response Status: ${response.statusCode}');
      print('📦 [POST API] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is! Map<String, dynamic>) {
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}',
          );
        }

        final responseData = response.data as Map<String, dynamic>;
        final postsList = <PostModel>[];

        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          print('📦 [POST API] Response data type: ${data.runtimeType}');
          
          if (data == null) {
            print('⚠️ [POST API] Data is null, returning empty list');
            return [];
          } else if (data is List) {
            print('📦 [POST API] Data is a list with ${data.length} items');
            for (var item in data) {
              if (item is Map<String, dynamic>) {
                try {
                  final post = PostModel.fromJson(item);
                  postsList.add(post);
                  print('✅ [POST API] Parsed post: id=${post.id}, tagId=${post.tagId}');
                } catch (e, stackTrace) {
                  print('❌ [POST API] Error parsing post: $e');
                  print('❌ [POST API] Item: $item');
                  print('❌ [POST API] Stack: $stackTrace');
                }
              } else {
                print('⚠️ [POST API] Item is not a Map: ${item.runtimeType}');
              }
            }
          } else {
            print('⚠️ [POST API] Data is not a list: ${data.runtimeType}');
            print('⚠️ [POST API] Data content: $data');
          }
        } else {
          print('⚠️ [POST API] Response does not contain "data" key');
          print('⚠️ [POST API] Response keys: ${responseData.keys.toList()}');
        }

        print('✅ [POST API] Fetched ${postsList.length} posts');
        return postsList;
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [POST API] DioException: ${e.type}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'No internet connection. Please check your network.',
        );
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'Failed to fetch posts';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is Map && msg.containsKey('err: ')) {
              errorMessage = msg['err: '] as String;
            } else if (msg is String) {
              errorMessage = msg;
            }
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getPostsByTagId(int tagId) async {
    try {
      print('🔍 [POST API] Fetching posts by tag ID...');
      print('   - Tag ID: $tagId');

      final response = await client.get(
        '/post/external/v1/tag/$tagId',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [POST API] Response Status: ${response.statusCode}');
      print('📦 [POST API] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is! Map<String, dynamic>) {
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}',
          );
        }

        final responseData = response.data as Map<String, dynamic>;
        final postsList = <PostModel>[];

        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          print('📦 [POST API] Response data type: ${data.runtimeType}');
          
          if (data == null) {
            print('⚠️ [POST API] Data is null, returning empty list');
            return [];
          } else if (data is List) {
            print('📦 [POST API] Data is a list with ${data.length} items');
            for (var item in data) {
              if (item is Map<String, dynamic>) {
                try {
                  final post = PostModel.fromJson(item);
                  postsList.add(post);
                  print('✅ [POST API] Parsed post: id=${post.id}, tagId=${post.tagId}');
                } catch (e, stackTrace) {
                  print('❌ [POST API] Error parsing post: $e');
                  print('❌ [POST API] Item: $item');
                  print('❌ [POST API] Stack: $stackTrace');
                }
              } else {
                print('⚠️ [POST API] Item is not a Map: ${item.runtimeType}');
              }
            }
          } else {
            print('⚠️ [POST API] Data is not a list: ${data.runtimeType}');
            print('⚠️ [POST API] Data content: $data');
          }
        } else {
          print('⚠️ [POST API] Response does not contain "data" key');
          print('⚠️ [POST API] Response keys: ${responseData.keys.toList()}');
        }

        print('✅ [POST API] Fetched ${postsList.length} posts');
        return postsList;
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [POST API] DioException: ${e.type}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'No internet connection. Please check your network.',
        );
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'Failed to fetch posts';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is Map && msg.containsKey('err: ')) {
              errorMessage = msg['err: '] as String;
            } else if (msg is String) {
              errorMessage = msg;
            }
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<PostModel>> getPostsByIds(List<String> postIds) async {
    try {
      print('🔍 [POST API] Fetching posts by IDs...');
      print('   - Post IDs: ${postIds.length}');

      final response = await client.post(
        '/post/external/v1/ids',
        data: {'post_ids': postIds},
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [POST API] Response Status: ${response.statusCode}');
      print('📦 [POST API] Response Data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is! Map<String, dynamic>) {
          throw ServerException(
            'Invalid response format: Expected Map but got ${response.data.runtimeType}',
          );
        }

        final responseData = response.data as Map<String, dynamic>;
        final postsList = <PostModel>[];

        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          print('📦 [POST API] Response data type: ${data.runtimeType}');
          
          if (data == null) {
            print('⚠️ [POST API] Data is null, returning empty list');
            return [];
          } else if (data is List) {
            print('📦 [POST API] Data is a list with ${data.length} items');
            for (var item in data) {
              if (item is Map<String, dynamic>) {
                try {
                  final post = PostModel.fromJson(item);
                  postsList.add(post);
                  print('✅ [POST API] Parsed post: id=${post.id}, tagId=${post.tagId}');
                } catch (e, stackTrace) {
                  print('❌ [POST API] Error parsing post: $e');
                  print('❌ [POST API] Item: $item');
                  print('❌ [POST API] Stack: $stackTrace');
                }
              } else {
                print('⚠️ [POST API] Item is not a Map: ${item.runtimeType}');
              }
            }
          } else {
            print('⚠️ [POST API] Data is not a list: ${data.runtimeType}');
            print('⚠️ [POST API] Data content: $data');
          }
        } else {
          print('⚠️ [POST API] Response does not contain "data" key');
          print('⚠️ [POST API] Response keys: ${responseData.keys.toList()}');
        }

        print('✅ [POST API] Fetched ${postsList.length} posts');
        return postsList;
      } else {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [POST API] DioException: ${e.type}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'No internet connection. Please check your network.',
        );
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'Failed to fetch posts';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is Map && msg.containsKey('err: ')) {
              errorMessage = msg['err: '] as String;
            } else if (msg is String) {
              errorMessage = msg;
            }
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      print('🗑️ [POST API] Deleting post...');
      print('   - Post ID: $postId');

      final response = await client.delete(
        '/post/external/v1/$postId',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [POST API] Delete Response Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('❌ [POST API] Delete DioException: ${e.type}');
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'Failed to delete post';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is Map && msg.containsKey('err: ')) {
              errorMessage = msg['err: '] as String;
            } else if (msg is String) {
              errorMessage = msg;
            }
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> likePost(String postId) async {
    try {
      print('❤️ [POST API] Liking post...');
      print('   - Post ID: $postId');

      final response = await client.post(
        '/post/external/v1/$postId/like',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [POST API] Like Response Status: ${response.statusCode}');
      print('📦 [POST API] Like Response Data: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
      print('✅ [POST API] Post liked successfully');
    } on DioException catch (e) {
      print('❌ [POST API] Like DioException: ${e.type}');
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'Failed to like post';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is Map && msg.containsKey('err: ')) {
              errorMessage = msg['err: '] as String;
            } else if (msg is String) {
              errorMessage = msg;
            }
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> unlikePost(String postId) async {
    try {
      print('💔 [POST API] Unliking post...');
      print('   - Post ID: $postId');

      final response = await client.delete(
        '/post/external/v1/$postId/like',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [POST API] Unlike Response Status: ${response.statusCode}');
      print('📦 [POST API] Unlike Response Data: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
      print('✅ [POST API] Post unliked successfully');
    } on DioException catch (e) {
      print('❌ [POST API] Unlike DioException: ${e.type}');
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'Failed to unlike post';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is Map && msg.containsKey('err: ')) {
              errorMessage = msg['err: '] as String;
            } else if (msg is String) {
              errorMessage = msg;
            }
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> bookmarkPost(String postId) async {
    try {
      print('🔖 [POST API] Bookmarking post...');
      print('   - Post ID: $postId');

      final response = await client.post(
        '/post/external/v1/$postId/bookmark',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [POST API] Bookmark Response Status: ${response.statusCode}');
      print('📦 [POST API] Bookmark Response Data: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
      print('✅ [POST API] Post bookmarked successfully');
    } on DioException catch (e) {
      print('❌ [POST API] Bookmark DioException: ${e.type}');
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'Failed to bookmark post';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is Map && msg.containsKey('err: ')) {
              errorMessage = msg['err: '] as String;
            } else if (msg is String) {
              errorMessage = msg;
            }
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> unbookmarkPost(String postId) async {
    try {
      print('🔓 [POST API] Unbookmarking post...');
      print('   - Post ID: $postId');

      final response = await client.delete(
        '/post/external/v1/$postId/bookmark',
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      print('📦 [POST API] Unbookmark Response Status: ${response.statusCode}');
      print('📦 [POST API] Unbookmark Response Data: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          'Unexpected status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
      print('✅ [POST API] Post unbookmarked successfully');
    } on DioException catch (e) {
      print('❌ [POST API] Unbookmark DioException: ${e.type}');
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        String errorMessage = 'Failed to unbookmark post';
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('msg')) {
            final msg = responseData['msg'];
            if (msg is Map && msg.containsKey('err: ')) {
              errorMessage = msg['err: '] as String;
            } else if (msg is String) {
              errorMessage = msg;
            }
          }
        }
        throw ServerException(errorMessage, statusCode: statusCode);
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}

