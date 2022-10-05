import 'package:meta/meta.dart';

/// A pair of [access] and [refresh] tokens used for OAuth2 authentication.
@immutable
class TokenPair {
  /// [access] token used to authorize requests.
  final String access;

  /// [refresh] token used to refresh the [access] token.
  final String refresh;

  /// Create a pair of [access] and [refresh] tokens.
  const TokenPair(this.access, this.refresh);
}
