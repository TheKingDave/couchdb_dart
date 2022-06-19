import 'dart:convert';

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

  Future<Document> createDocument(Json document,
      {String? id, bool? batch}) async {
    final query = {
      if (batch == true) 'batch': 'ok',
    };

    final res = await (id == null
        ? _client.post(database, data: document, query: query)
        : _client.put('$database/$id', data: document, query: query));
    return Document.fromReference(res.data, this, data: document);
  }

  Future<ApiResponse> getDocument(String id, {String? rev, bool? batch}) async {
    final query = {
      if (rev != null) 'rev': rev,
      if (batch == true) 'batch': 'ok',
    };

    return _client.get('$database/$id', query: query);
  }

  Future<ApiResponse> updateDocument(String id, String rev, Json data,
      {bool? batch}) {
    final query = {
      'rev': rev,
      if (batch == true) 'batch': 'ok',
    };

    return _client.put('$database/$id', data: jsonEncode(data), query: query);
  }

  Future<ApiResponse> deleteDocument(String id, String rev, {bool? batch}) {
    final query = {
      'rev': rev,
      if (batch == true) 'batch': 'ok',
    };

    return _client.delete('$database/$id', query: query);
  }

  Future<ApiResponse> copyDocument(String srcId, String dstId,
      {String? srcRef, String? dstRef, bool? batch}) {
    final query = {
      if (srcRef != null) 'rev': srcRef,
      if (batch == true) 'batch': 'ok',
    };

    final headers = {
      'Destination': dstRef == null ? dstId : '$dstId?rev=$dstRef',
    };

    return _client.copy('$database/$srcId', headers: headers, query: query);
  }
}
