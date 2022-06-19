import 'package:couchdb_dart/couchdb_dart.dart';

class Document {
  final String id;
  final String rev;
  final Database _database;
  Json? _data;

  Future<Json> get data async {
    return _data ?? await _getDocument();
  }
  
  Future<Json> _getDocument() async {
    final data = await (await _database.getDocument(id, rev: rev)).data;
    _data = data;
    return data;
  }

  Document._(this.id, this.rev, this._database, [this._data]);

  Document.fromJson(Json json, Database database)
      : this._(
            json['_id'],
            json['_rev'],
            database,
            json
              ..remove('_id')
              ..remove('_rev'));

  Document.fromReference(Json json, Database database)
      : this._(json['id'], json['rev'], database);

  @override
  String toString() {
    return 'Document{id: $id, rev: $rev, data: $_data}';
  }
}
