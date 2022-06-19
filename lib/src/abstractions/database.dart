import 'dart:convert';

import 'package:couchdb_dart/couchdb_dart.dart';

/// Abstraction of the CouchDB database
///
///
class Database {
  final CouchDbClient _client;
  final String database;

  Database(this._client, this.database);

  /// Tests if the database exists
  ///
  /// This is done by sending a `HEAD` request and checking for an error response
  /// https://docs.couchdb.org/en/stable/api/database/common.html#head--db
  Future<bool> exists() async {
    try {
      await _client.head(database);
    } on ErrorResponse {
      return false;
    }
    return true;
  }

  /// Returns the info of the database
  ///
  /// https://docs.couchdb.org/en/stable/api/database/common.html#get--db
  Future<Json> info() async {
    return (await _client.get(database)).data;
  }

  /// Creates this database
  ///
  /// Throws error if it already exists
  /// https://docs.couchdb.org/en/stable/api/database/common.html#put--db
  Future<void> create({int? q, int? n, bool? partitioned}) async {
    final query = {
      if (q != null) 'q': '$q',
      if (n != null) 'n': '$n',
      if (partitioned != null) 'partitioned': '$partitioned',
    };

    await _client.put(database, query: query);
  }

  /// Deletes this database
  ///
  /// Throws error it does not exist
  /// https://docs.couchdb.org/en/stable/api/database/common.html#delete--db
  Future<void> delete() async {
    await _client.delete(database);
  }

  /// Crates a new document
  ///
  /// If no id is given uses
  /// https://docs.couchdb.org/en/stable/api/database/common.html#post--db
  /// otherwise uses
  /// https://docs.couchdb.org/en/stable/api/document/common.html#put--db-docid
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

  /// Get a document from the database
  ///
  /// https://docs.couchdb.org/en/stable/api/document/common.html#get--db-docid
  Future<Document> document(String id,
      {String? rev,
      bool? attachments,
      bool? attEncodingInfo,
      bool? conflicts,
      bool? deletedConflicts,
      bool? latest,
      bool? localSeq,
      bool? meta,
      bool? revs,
      bool? revsInfo}) async {
    final query = <String, String>{
      if (rev != null) 'rev': rev,
      if (attachments != null) 'attachments': '$attachments',
      if (attEncodingInfo != null) 'att_encoding_info': '$attEncodingInfo',
      if (conflicts != null) 'conflicts': '$conflicts',
      if (deletedConflicts != null) 'deleted_conflicts': '$deletedConflicts',
      if (latest != null) 'latest': '$latest',
      if (localSeq != null) 'local_seq': '$localSeq',
      if (meta != null) 'meta': '$meta',
      if (revs != null) 'revs': '$revs',
      if (revsInfo != null) 'revs_info': '$revsInfo',
    };

    final res = await _client.get('$database/$id', query: query);
    return Document.fromJson(res.data, this);
  }

  /// Get a document but return a ApiResponse
  ///
  /// https://docs.couchdb.org/en/stable/api/document/common.html#get--db-docid
  Future<ApiResponse> getDocument(String id, {String? rev, bool? batch}) async {
    final query = {
      if (rev != null) 'rev': rev,
      if (batch == true) 'batch': 'ok',
    };

    return _client.get('$database/$id', query: query);
  }

  /// Updates an existing document
  ///
  /// https://docs.couchdb.org/en/stable/api/document/common.html#put--db-docid
  Future<ApiResponse> updateDocument(String id, String rev, Json data,
      {bool? batch}) {
    final query = {
      'rev': rev,
      if (batch == true) 'batch': 'ok',
    };

    return _client.put('$database/$id', data: jsonEncode(data), query: query);
  }

  /// Delete an existing document
  ///
  /// https://docs.couchdb.org/en/stable/api/document/common.html#delete--db-docid
  Future<ApiResponse> deleteDocument(String id, String rev, {bool? batch}) {
    final query = {
      'rev': rev,
      if (batch == true) 'batch': 'ok',
    };

    return _client.delete('$database/$id', query: query);
  }

  /// Copy an existing document
  ///
  /// https://docs.couchdb.org/en/stable/api/document/common.html#copy--db-docid
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
