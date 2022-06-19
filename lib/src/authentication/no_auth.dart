import 'dart:convert';

import 'package:couchdb_dart/src/authentication/base_auth.dart';
import 'package:http/http.dart' as http;

/// No authentication
class NoAuth extends BaseAuthentication {

  const NoAuth();
  
  @override
  http.BaseClient getClient(http.Client parent, Uri baseUri) {
    return _BasicAuthClient(parent);
  }
}

class _BasicAuthClient extends http.BaseClient {
  final http.Client _inner;
  
  _BasicAuthClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request);
  }
  
  @override
  void close() {
    _inner.close();
  }
}
