A small simple package to make it easier to use a [CouchDB](https://couchdb.apache.org/) server.

## Features

* Includes basic abstractions above the Database and Document api.
* Supports nearly all authentication options (excludes JWT).
* Low level access is possible if desired.
* Does not support live data.
* Does not support data other than json

## Usage

Example can be found in ['/example'](./example).

```dart
Uri uri = Uri.parse('http://localhost:5984/');
final client = CouchDbClient.fromUri(uri, authentication: CookieAuth(username, password));
final database = Database(client, 'test_db');
if (!(await database.exists())) {
  await database.create();
}

final doc = await database.createDocument({'data': 1}, id: 'some_id');
await doc.update({'data': 2});
print(doc);
await doc.delete();

client.close();
```

## Additional information

This package is a small abstraction above the CouchDB.

## Testing

For testing or development you can start the CouchDB instance defined in the couchdb directory with [Docker](https://www.docker.com/)

```bash
cd couchdb && docker-compose up
```

This includes predefined admin user (test:test) and required auth handlers enabled
