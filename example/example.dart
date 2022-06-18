import 'package:couchdb_dart/couchdb_dart.dart';

void main(List<String> args) async {
  
  final username = 'test';
  final password = 'test';

  Uri uri = Uri.parse('http://localhost:5984/');
  Uri uriUserInfo = Uri.parse('http://$username:$password@localhost:5984');
  
  // final client = CouchDbClient.fromUri(uri, authentication: ProxyAuth(username, roles: ['_admin'], secret: 'some_super_secret_secret'));
  final client = CouchDbClient.fromUri(uri, authentication: CookieAuth(username, password));
  // final client = CouchDbClient.fromUri(uri, authentication: BasicAuth(username, password));
  // final client = CouchDbClient.fromUri(uriUserInfo);

  final database = Database(client, 'test_db');
  
  if(await database.exists()) {
    await database.delete();
    print('Database existed, deleted it');
  }
  await database.create(partitioned: true);
  print((await database.info()).data);
  await database.delete();
  client.close();
}