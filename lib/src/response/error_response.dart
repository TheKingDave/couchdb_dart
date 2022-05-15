class ErrorResponse {
  String error;
  String reason;

  ErrorResponse(this.error, this.reason);

  ErrorResponse.fromJson(Map<String, dynamic> json)
      : this(json['error'] as String, json['reason'] as String);

  @override
  String toString() {
    return 'ErrorResponse{error: $error, reason: $reason}';
  }
}
