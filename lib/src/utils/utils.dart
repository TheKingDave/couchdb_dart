import 'dart:io';

import 'package:http/http.dart' as http;

final jsonHeader = ContentType.json.toString();
final Map<String, String> jsonHeaders = {
  HttpHeaders.contentTypeHeader: jsonHeader
};

/// Returns a copy of [original] with the given [body].
http.Request _copyNormalRequest(http.Request original) {
  final request = http.Request(original.method, original.url)
    ..followRedirects = original.followRedirects
    ..headers.addAll(original.headers)
    ..maxRedirects = original.maxRedirects
    ..persistentConnection = original.persistentConnection
    ..body = original.body;

  return request;
}

http.BaseRequest copyRequest(http.BaseRequest original) {
  if (original is http.Request) {
    return _copyNormalRequest(original);
  } else {
    throw UnimplementedError(
        'cannot handle requests of type ${original.runtimeType} yet');
  }
}
