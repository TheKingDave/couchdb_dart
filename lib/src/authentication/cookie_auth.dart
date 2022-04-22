import 'dart:convert';
import 'dart:io';

import 'package:couchdb_dart/src/authentication/base_auth.dart';
import 'package:couchdb_dart/src/authentication/utils.dart';
import 'package:http/http.dart' as http;

class CookieAuth extends BaseAuthentication {
  final String _username;
  final String _password;

  CookieAuth(this._username, this._password);

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
      print('set-cookie in normal request');
      _cookie = response.headers['set-cookie'];
    }

    return response;
  }

  Future<void> authenticate() async {
    print('AUTHENTICATE');
    final authRequest = http.Request('POST', _baseUri.resolve('/_session'));

    authRequest.headers[HttpHeaders.contentTypeHeader] =
        ContentType.json.toString();
    authRequest.persistentConnection = true;
    authRequest.body =
        json.encode({'name': _auth._username, 'password': _auth._password});

    http.BaseResponse authResponse = await _inner.send(authRequest);
    if (authResponse.statusCode != 200) {
      throw ArgumentError('Username and Password not recognized by server');
    }
    if (authResponse.headers['set-cookie'] == null) {
      throw Exception('No "set-cookie" header received from server');
    }

    _cookie = authResponse.headers['set-cookie'];
  }
}
