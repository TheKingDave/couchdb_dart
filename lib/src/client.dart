import 'dart:convert';
import 'dart:io';

import 'package:couchdb_dart/couchdb_dart.dart';
import 'package:couchdb_dart/src/utils.dart';
import 'package:http/http.dart' as http;

class CouchDbClient {
  late final Uri connectUri;
  late final http.Client _client;
  final bool cors;

  CouchDbClient._fromUri(
      this.connectUri, BaseAuthentication authentication, this.cors) {
    _client = authentication.getClient(http.Client(), connectUri);
  }

  factory CouchDbClient({
    String scheme = 'https',
    String host = '0.0.0.0',
    int port = 5984,
    String path = '',
    bool cors = true,
    required BaseAuthentication authentication,
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

  factory CouchDbClient.fromUri(
    Uri uri, {
    bool cors = true,
    BaseAuthentication? authentication,
  }) {
    if (authentication == null) {
      if (uri.userInfo == '') {
        throw Exception('If not authentication is given, userInfo must be set');
      }
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

  Future<ApiResponse> head(String path,
      {Map<String, String>? headers,
      Map<String, String> query = const {}}) async {
    final res = await _client.head(_generateUri(path, query), headers: headers);
    if (_isErrorCode(res.statusCode)) {
      throw ErrorResponse('${res.statusCode}');
    }
    return ApiResponse({}, res.headers);
  }

  Future<ApiResponse> get(String path,
      {Map<String, String>? headers,
      Map<String, String> query = const {}}) async {
    final res = await _client.get(_generateUri(path, query), headers: headers);

    return _generateApiResponse(res);
  }

  Future<ApiResponse> put(String path,
      {Object? data,
      Map<String, String>? headers,
      Map<String, String> query = const {}}) async {
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

  Future<ApiResponse> post(String path,
      {Object? data,
      Map<String, String>? headers,
      Map<String, String> query = const {}}) async {
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

  Future<ApiResponse> delete(String path,
      {Map<String, String>? headers,
      Map<String, String> query = const {}}) async {
    final res =
        await _client.delete(_generateUri(path, query), headers: headers);

    return _generateApiResponse(res);
  }

  Future<http.Response> copy(String path,
      {Map<String, String>? headers,
      Map<String, String> query = const {}}) async {
    final request = http.Request('COPY', _generateUri(path, query));
    if (headers != null) request.headers.addAll(headers);
    return http.Response.fromStream(await _client.send(request));
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

  void close() {
    _client.close();
  }
}
