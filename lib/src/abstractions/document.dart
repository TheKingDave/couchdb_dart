import 'package:couchdb_dart/couchdb_dart.dart';

/// Abstraction for an CouchDB document
class Document {
  final String id;
  String rev;
  final Database _database;
  Json? _data;

  /// Gets the data, if not locally available fetches it from the server
  ///
  /// https://docs.couchdb.org/en/stable/api/document/common.html#get--db-docid
  Future<Json> get data async {
    return _data ?? await _getDocument();
  }

  Future<Json> _getDocument() async {
    final res = await _database.getDocument(id, rev: rev);
    _data = res.data;
    return res.data;
  }

  void _setData(Json? data) {
    _data = data
      ?..remove('_id')
      ..remove('_rev');
  }

  Document._(this.id, this.rev, this._database, [Json? data]) {
    _setData(data);
  }

  Document.fromJson(Json json, Database database)
      : this._(json['_id'], json['_rev'], database, json);

  Document.fromReference(Json json, Database database, {Json? data})
      : this._(json['id'], json['rev'], database, data);

  /// Gets the latest version from the server
  ///
  /// https://docs.couchdb.org/en/stable/api/document/common.html#get--db-docid
  Future<void> getLatest() async {
    final res = await _database.getDocument(id);
    rev = res.data['_rev'];
    _setData(res.data);
  }

  /// Updates the local and remote document
  ///
  /// https://docs.couchdb.org/en/stable/api/document/common.html#put--db-docid
  Future<void> update(Json data, {bool? batch}) async {
    final res = await _database.updateDocument(id, rev, data, batch: batch);
    rev = res.data['rev'];
    _setData(data);
  }

  /// Deletes this document from the server
  ///
  /// https://docs.couchdb.org/en/stable/api/document/common.html#delete--db-docid
  Future<void> delete({bool? batch}) async {
    await _database.deleteDocument(id, rev, batch: batch);
  }

  /// Copy this document
  ///
  /// https://docs.couchdb.org/en/stable/api/document/common.html#copy--db-docid
  Future<Document> copy(String id, {String? rev, bool? batch}) async {
    final res = await _database.copyDocument(this.id, id,
        srcRef: this.rev, dstRef: rev, batch: batch);
    return Document.fromReference(res.data, _database, data: _data);
  }

  @override
  String toString() {
    return 'Document{id: $id, rev: $rev, data: $_data}';
  }
}
