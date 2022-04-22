import 'dart:async';

import 'package:couchdb_dart/couchdb_dart.dart';

void main(List<String> args) async {
  
  final username = 'test';
  final password = 'test';
  
  Uri uri = Uri.parse('http://$username:$password@localhost:8080/');
  
  // final client = CouchDbClient.fromUri(uri, authentication: ProxyAuth(username, roles: ['_admin'], secret: 'f43cec7fd64b0d667ae4eab9cac16b41'));
  // final client = CouchDbClient.fromUri(uri, authentication: CookieAuth(username, password));
  final client = CouchDbClient.fromUri(uri);

  print('0 ' + (await client.get('_session')).body.trim());
  Timer.periodic(Duration(seconds: 1), (timer) async {
    try {
      print('${timer.tick} ' + (await client.get('_all_dbs')).body.trim());
    } catch(e) {
      print(e.toString());
      timer.cancel();
    }
  });
}