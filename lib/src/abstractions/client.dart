import 'dart:convert';
import 'dart:io';

import 'package:couchdb_dart/couchdb_dart.dart';
import 'package:couchdb_dart/src/utils/utils.dart';
import 'package:http/http.dart' as http;

/// This is the underlying client used by other abstractions (Database, Document)
///
/// All request can be added with headers and query parameters
/// All request made through this client are prefixed with the Uri (baseUri)
/// All responses are checked for error codes and throws an `ErrorResponse`
/// All responses are mapped to `ApiResponse`
class CouchDbClient {
  late final Uri connectUri;
  late final http.Client _client;
  final bool cors;

  CouchDbClient._fromUri(
      this.connectUri, BaseAuthentication? authentication, this.cors) {
    _client = (authentication ?? NoAuth()).getClient(http.Client(), connectUri);
  }

  /// Creates a client from specified uri parts
  factory CouchDbClient({
    String scheme = 'https',
    String host = '0.0.0.0',
    int port = 5984,
    String path = '',
    bool cors = true,
    BaseAuthentication? authentication,
  }) =>
      CouchDbClient._fromUri(
          Uri(
            scheme: scheme,
            host: host,
            port: port,
            path: path,
          ),
          authentication,
          cors);

  /// Creates a client from a specified uri
  ///
  /// If no authentication is supplied ans userinfo is supplied uses basic auth
  factory CouchDbClient.fromUri(
    Uri uri, {
    bool cors = true,
    BaseAuthentication? authentication,
  }) {
    if (authentication == null && uri.userInfo.isNotEmpty) {
      authentication = BasicAuth.fromUserInfo(uri.userInfo);
    }

    return CouchDbClient._fromUri(
        Uri(
            scheme: uri.scheme == '' ? 'https' : uri.scheme,
            host: uri.host == '' ? '0.0.0.0' : uri.host,
            port: uri.port == 0 ? 5984 : uri.port),
        authentication,
        cors);
  }

  /// Makes a `HEAD` request
  Future<ApiResponse> head(String path,
      {Map<String, String>? headers, Map<String, String>? query}) async {
    final res = await _client.head(_generateUri(path, query), headers: headers);
    if (_isErrorCode(res.statusCode)) {
      throw ErrorResponse('${res.statusCode}');
    }
    return ApiResponse({}, res.headers);
  }

  /// Makes a `GET` request
  Future<ApiResponse> get(String path,
      {Map<String, String>? headers, Map<String, String>? query}) async {
    final res = await _client.get(_generateUri(path, query), headers: headers);

    return _generateApiResponse(res);
  }

  /// Makes a `PUT` request
  Future<ApiResponse> put(String path,
      {Object? data,
      Map<String, String>? headers,
      Map<String, String>? query}) async {
    Object? encodedData = data;
    if (data is Map) {
      encodedData = jsonEncode(data);
      headers ??= {};
      headers.addAll(jsonHeaders);
    }

    final res = await _client.put(_generateUri(path, query),
        headers: headers, body: encodedData);

    return _generateApiResponse(res);
  }

  /// Makes a `POST` request
  Future<ApiResponse> post(String path,
      {Object? data,
      Map<String, String>? headers,
      Map<String, String>? query}) async {
    Object? encodedData = data;

    if (data is Map) {
      encodedData = jsonEncode(data);
      headers ??= {};
      headers.addAll(jsonHeaders);
    }

    final res = await _client.post(_generateUri(path, query),
        headers: headers, body: encodedData);

    return _generateApiResponse(res);
  }

  /// Makes a `DELETE` request
  Future<ApiResponse> delete(String path,
      {Map<String, String>? headers, Map<String, String>? query}) async {
    final res =
        await _client.delete(_generateUri(path, query), headers: headers);

    return _generateApiResponse(res);
  }

  /// Makes a `COPY` request
  Future<ApiResponse> copy(String path,
      {Map<String, String>? headers, Map<String, String>? query}) async {
    final request = http.Request('COPY', _generateUri(path, query));
    if (headers != null) request.headers.addAll(headers);

    final res = await http.Response.fromStream(await _client.send(request));
    return _generateApiResponse(res);
  }

  Uri _generateUri(String path, [Map<String, String>? query]) {
    Uri ret = connectUri.resolve(path);
    if (query != null) ret = ret.replace(queryParameters: query);
    return ret;
  }

  ApiResponse _generateApiResponse(http.Response res) {
    if (ContentType.parse(res.headers['content-type']!).mimeType !=
        ContentType.json.mimeType) {
      throw Exception(
          'Responses with content-type other than json are not supported');
    }

    final resBody = jsonDecode(res.body);
    Map<String, Object> json =
        resBody is List ? {'list': resBody} : Map.from(resBody);
    _checkForErrorCode(res.statusCode, json);

    return ApiResponse(json, res.headers);
  }

  bool _isErrorCode(int code) {
    return !(code >= 200 && code <= 202);
  }

  void _checkForErrorCode(int code, Json data) {
    if (_isErrorCode(code)) {
      throw JsonErrorResponse.fromJson(data);
    }
  }

  /// Closes the client
  ///
  /// please call on end of program
  void close() {
    _client.close();
  }
}
