class ApiResponse {
  final Map<String, dynamic> data;
  final Map<String, String> headers;

  ApiResponse(this.data, this.headers);

  @override
  String toString() {
    return 'ApiResponse{data: $data, headers: $headers}';
  }
}