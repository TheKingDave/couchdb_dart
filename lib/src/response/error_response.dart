import 'package:couchdb_dart/couchdb_dart.dart';

class ErrorResponse {
  final String message;

  ErrorResponse(this.message);

  @override
  String toString() {
    return 'ErrorResponse{$message}';
  }
}

class JsonErrorResponse extends ErrorResponse {
  JsonErrorResponse(String error, String reason)
      : super('error: $error, reason: $reason');

  JsonErrorResponse.fromJson(Json json)
      : this(json['error'] as String, json['reason'] as String);
}
