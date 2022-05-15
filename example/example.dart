import 'dart:async';

import 'package:couchdb_dart/couchdb_dart.dart';

void main(List<String> args) async {
  
  final username = 'test';
  final password = 'test';

  Uri uri = Uri.parse('http://localhost:5984/');
  Uri uriUserInfo = Uri.parse('http://$username:$password@localhost:5984');
  
  // final client = CouchDbClient.fromUri(uri, authentication: ProxyAuth(username, roles: ['_admin'], secret: '1afca8880bd1e65bde479c9ff1bcbe01'));
  final client = CouchDbClient.fromUri(uri, authentication: CookieAuth(username, password));
  // final client = CouchDbClient.fromUri(uri, authentication: BasicAuth(username, password));
  // final client = CouchDbClient.fromUri(uriUserInfo);

  final database = Database(client, 'test_db');
  
  await database.create();
  print((await database.info()).body);
  await database.delete();
}