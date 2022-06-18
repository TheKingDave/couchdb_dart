import 'dart:convert';

import 'package:couchdb_dart/src/authentication/base_auth.dart';
import 'package:couchdb_dart/src/utils.dart';
import 'package:http/http.dart' as http;

class CookieAuth extends BaseAuthentication {
  final String _authBody;

  CookieAuth(String username, String password)
      : _authBody = json.encode({'name': username, 'password': password});

  @override
  http.BaseClient getClient(http.Client parent, Uri baseUri) {
    return _CookieAuthClient(this, parent, baseUri);
  }
}

class _CookieAuthClient extends http.BaseClient {
  final CookieAuth _auth;
  final http.Client _inner;
  final Uri _baseUri;

  String? _cookie;

  _CookieAuthClient(this._auth, this._inner, this._baseUri);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_cookie == null) {
      await authenticate();
    }

    request.headers['cookie'] = _cookie!;
    http.StreamedResponse response = await _inner.send(copyRequest(request));

    // Did cookie time out? Re authenticate
    if (response.statusCode == 401) {
      await authenticate();
      request.headers['cookie'] = _cookie!;
      response = await _inner.send(request);

      if (response.statusCode == 401) {
        throw Exception(
            'Unknown behaviour from server, authentication successful but cookie not accepted');
      }
    }
    if (response.headers['set-cookie'] != null) {
      _cookie = response.headers['set-cookie'];
    }

    return response;
  }

  Future<void> authenticate() async {
    final authRequest = http.Request('POST', _baseUri.resolve('/_session'));

    authRequest.headers.addAll(jsonHeaders);
    authRequest.body = _auth._authBody;

    http.BaseResponse authResponse = await _inner.send(authRequest);
    if (authResponse.statusCode != 200) {
      throw ArgumentError('Username and Password not recognized by server');
    }
    if (authResponse.headers['set-cookie'] == null) {
      throw Exception('No "set-cookie" header received from server');
    }

    _cookie = authResponse.headers['set-cookie'];
  }
  
  @override
  void close() {
    _inner.close();
  }
}
