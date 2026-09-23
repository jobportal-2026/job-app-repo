import 'api_response.dart';

abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<ApiFieldError>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'No internet connection or server unreachable']);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Unauthorized access']);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message, {super.statusCode, super.errors});
}

class BadRequestException extends ApiException {
  BadRequestException(super.message, {super.statusCode, super.errors});
}

class ConflictException extends ApiException {
  ConflictException(super.message, {super.statusCode, super.errors});
}

class RateLimitException extends ApiException {
  RateLimitException(super.message, {super.statusCode, super.errors});
}

class ServerException extends ApiException {
  ServerException([super.message = 'Internal server error', int? statusCode])
      : super(statusCode: statusCode);
}
