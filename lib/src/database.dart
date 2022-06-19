import 'package:couchdb_dart/couchdb_dart.dart';

class Database {
  final CouchDbClient _client;
  final String database;

  Database(this._client, this.database);

  Future<bool> exists() async {
    try {
      await _client.head(database);
    } on ErrorResponse {
      return false;
    }
    return true;
  }

  Future<ApiResponse> info() {
    return _client.get(database);
  }

  Future<void> create({int? q, int? n, bool? partitioned}) async {
    final query = {
      if (q != null) 'q': '$q',
      if (n != null) 'n': '$n',
      if (partitioned != null) 'partitioned': '$partitioned',
    };

    await _client.put(database, query: query);
  }

  Future<void> delete() async {
    await _client.delete(database);
  }

  Future<Document> createDocument(Json document, {bool? batch}) async {
    final query = {
      if (batch != null) 'batch': '$batch',
    };

    final res = await _client.post(database, data: document, query: query);
    return Document.fromReference(res.data, this);
  }

  Future<Document> getDocument(String id, {String? rev, bool? batch}) async {
    final query = {
      if (rev != null) 'rev': rev,
      if (batch != null) 'batch': '$batch',
    };

    final res = await _client.get('$database/$id', query: query);
    return Document.fromJson(res.data, this);
  }
}
