import 'dart:convert';

import 'package:couchdb_dart/src/authentication/base_auth.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class ProxyAuth extends BaseAuthentication {
  final Map<String, String> _headers = {};

  ProxyAuth(String username,
      {List<String>? roles,
      String? secret,
      String usernameHeader = 'X-Auth-CouchDB-UserName',
      String authRolesHeader = 'X-Auth-CouchDB-Roles',
      String tokenHeader = 'X-Auth-CouchDB-Token'}) {
    _headers[usernameHeader] = username;
    if (roles != null && roles.isNotEmpty) {
      _headers[authRolesHeader] = roles.join(',');
    }
    if (secret != null) {
      _headers[tokenHeader] = Hmac(sha1, utf8.encode(secret))
          .convert(utf8.encode(username))
          .toString();
    }
  }

  @override
  http.BaseClient getClient(http.Client parent, Uri baseUri) {
    return _ProxyAuthClient(this, parent);
  }
}

class _ProxyAuthClient extends http.BaseClient {
  final ProxyAuth _auth;
  final http.Client _inner;

  _ProxyAuthClient(this._auth, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_auth._headers);
    return _inner.send(request);
  }
  
  @override
  void close() {
    _inner.close();
  }
}
