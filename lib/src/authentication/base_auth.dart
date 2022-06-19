import 'package:http/http.dart' as http;

/// Authentication strategy
/// Do the most work in [BaseAuthentication]
/// Do the least amount of work in the [http.BaseClient] from [getClient]
abstract class BaseAuthentication {
  const BaseAuthentication();

  http.BaseClient getClient(http.Client parent, Uri baseUri);
}
