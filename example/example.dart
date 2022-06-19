import 'package:couchdb_dart/couchdb_dart.dart';

void main(List<String> args) async {
  final username = 'test';
  final password = 'test';

  Uri uri = Uri.parse('http://localhost:5984/');
  Uri uriUserInfo = Uri.parse('http://$username:$password@localhost:5984');

  // final client = CouchDbClient.fromUri(uri, authentication: ProxyAuth(username, roles: ['_admin'], secret: 'some_super_secret_secret'));
  // final client = CouchDbClient.fromUri(uri, authentication: CookieAuth(username, password));
  // final client = CouchDbClient.fromUri(uri, authentication: BasicAuth(username, password));
  final client = CouchDbClient.fromUri(uriUserInfo);

  final database = Database(client, 'test_db');

  if (await database.exists()) {
    await database.delete();
    print('Database existed, deleted it');
  }

  await database.create();
  print(await database.info());

  final doc1 = await database.createDocument({'data': 1}, id: 'some_id');
  await doc1.update({'data': 1, 'version': 'v2'});

  final doc2acc1 =
      await database.createDocument({'data': 2}, id: 'some_other_id');
  await doc2acc1.update({'data': 'xo'});

  final doc2acc2 = await database.document('some_other_id');
  print(doc2acc2);
  await doc2acc1.update({'data': 2});
  await doc2acc2.getLatest();
  print(doc2acc2);

  // await database.delete();
  client.close();
}
