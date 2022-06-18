import 'dart:convert';

import 'package:couchdb_dart/src/authentication/base_auth.dart';
import 'package:http/http.dart' as http;

class BasicAuth extends BaseAuthentication {
  late final String _credentials;

  BasicAuth(String username, [String password = '']) {
    _credentials = 'Basic ${Base64Encoder().convert('$username:$password'.codeUnits)}';
  }
  
  factory BasicAuth.fromUserInfo(String userInfo) {
    int idx = userInfo.indexOf(':');
    return BasicAuth(userInfo.substring(0, idx), userInfo.substring(idx+1));
  }

  @override
  http.BaseClient getClient(http.Client parent, Uri baseUri) {
    return _BasicAuthClient(this, parent);
  }
}

class _BasicAuthClient extends http.BaseClient {
  final BasicAuth _basicAuth;
  final http.Client _inner;
  
  _BasicAuthClient(this._basicAuth, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = _basicAuth._credentials;
    return _inner.send(request);
  }
  
  @override
  void close() {
    _inner.close();
  }
}
