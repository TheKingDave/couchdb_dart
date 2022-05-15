import 'package:couchdb_dart/couchdb_dart.dart';
import 'package:http/http.dart';

class Database {
  final CouchDbClient _client;
  final String database;

  Database(this._client, this.database);

  Future<Response> info() {
    return _client.get(database);
  }
  
  Future<void> create() async {
    await _client.put(database);
  }
  
  Future<void> delete() async {
    await _client.delete(database);
  }
}