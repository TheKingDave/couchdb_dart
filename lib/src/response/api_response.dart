import 'package:couchdb_dart/couchdb_dart.dart';

class ApiResponse {
  final Json data;
  final Map<String, String> headers;

  ApiResponse(this.data, this.headers);

  @override
  String toString() {
    return 'ApiResponse{data: $data, headers: $headers}';
  }
}
