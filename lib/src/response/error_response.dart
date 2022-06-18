class ErrorResponse {
  String message;

  ErrorResponse(this.message);

  @override
  String toString() {
    return 'ErrorResponse{$message}';
  }
}

class JsonErrorResponse extends ErrorResponse {
  JsonErrorResponse(String error, String reason)
      : super('error: $error, reason: $reason');

  JsonErrorResponse.fromJson(Map<String, dynamic> json)
      : this(json['error'] as String, json['reason'] as String);
}
