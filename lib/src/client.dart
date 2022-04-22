import 'package:couchdb_dart/couchdb_dart.dart';
import 'package:couchdb_dart/src/authentication/base_auth.dart';
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

  Future<http.Response> get(String path) {
    return _client.get(connectUri.resolve(path));
  }
}
