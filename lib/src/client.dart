import 'dart:convert';
import 'dart:io';

import 'package:couchdb_dart/couchdb_dart.dart';
import 'package:couchdb_dart/src/response/api_response.dart';
import 'package:couchdb_dart/src/response/error_response.dart';
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

  Future<http.Response> head(String path, {Map<String, String>? headers}) {
    return _client.head(connectUri.resolve(path), headers: headers);
  }

  Future<http.Response> get(String path, {Map<String, String>? headers}) {
    return _client.get(connectUri.resolve(path), headers: headers);
  }

  Future<ApiResponse> put(String path,
      {Object? data, Map<String, String> headers = const {}}) async {
    Object? encodedData;
    if (data != null) {
      encodedData = data is Map ? jsonEncode(data) : data;
      if (data is Map) {
        headers.addAll(jsonHeaders);
      }
    }

    final res = await _client.put(connectUri.resolve(path),
        headers: headers, body: encodedData);
    
    
    if(ContentType.parse(res.headers['content-type']!).mimeType != ContentType.json.mimeType) {
      throw Exception('Responses with content-type other than json are not supported');
    }

    final resBody = jsonDecode(res.body);
    Map<String, Object> json = resBody is List ? {'list': resBody} : Map.from(resBody);
    _checkForErrorCode(res.statusCode, json);
    
    return ApiResponse(json, res.headers);
  }

  Future<ApiResponse> post(String path,
      {Object? data, Map<String, String> headers = const {}}) async {

    Object? encodedData;
    if (data != null) {
      encodedData = data is Map ? jsonEncode(data) : data;
      if (data is Map) {
        headers.addAll(jsonHeaders);
      }
    }

    final res = await _client.post(connectUri.resolve(path),
        headers: headers, body: encodedData);

    final resBody = jsonDecode(res.body);
    Map<String, Object> json = resBody is List ? {'list': resBody} : resBody;
    _checkForErrorCode(res.statusCode, json);

    return ApiResponse(json, res.headers);
  }

  Future<http.Response> delete(String path, {Map<String, String>? headers}) {
    return _client.delete(connectUri.resolve(path), headers: headers);
  }

  Future<http.Response> copy(String path,
      {Map<String, String>? headers}) async {
    final request = http.Request('COPY', connectUri.resolve(path));
    if (headers != null) request.headers.addAll(headers);
    return http.Response.fromStream(await _client.send(request));
  }

  void _checkForErrorCode(int code, Map<String, dynamic> data) {
    if (code >= 200 && code <= 202) {
      return;
    }
    throw ErrorResponse.fromJson(data);
  }
}
