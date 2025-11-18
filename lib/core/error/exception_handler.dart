// core/error/exception_handler.dart
import '../error/exceptions.dart';
import '../error/failures.dart';

class ExceptionHandler {
  static Failure handleException(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    } else {
      return ServerFailure('Unexpected error: ${exception.toString()}');
    }
  }
}

