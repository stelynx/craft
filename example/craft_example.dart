/// This example shows how to use a wrapper [Craft] class to create an actual
/// craft variant. This is the preferred way of creating crafts, since swapping
/// from one implementation to the other can be done with ease.

import 'package:craft/craft.dart';
import 'package:http/http.dart' as http;

class LoginData implements Serializable {
  final String username;
  final String password;

  const LoginData(this.username, this.password);

  @override
  Json toJson() {
    return <String, dynamic>{
      'username': username,
      'password': password,
    };
  }
}

class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance!;

  ApiService._({
    required Craft<PersistableAutoRefreshingBearerOauthCraft> craft,
  }) : _craft = craft;

  factory ApiService({
    required Craft<PersistableAutoRefreshingBearerOauthCraft> craft,
  }) {
    if (_instance != null) throw StateError('Already created');

    _instance = ApiService._(craft: craft);
    return instance;
  }

  late final Craft<PersistableAutoRefreshingBearerOauthCraft> _craft;

  /// Brews the craft. If the refresh token has been previously persisted, the
  /// automatic promotion will succeed because access and (new) refresh token
  /// will be obtained using saved refresh token and a refreshTokenMethod. This
  /// means that this function basically returns if the user is already
  /// authenticated.
  Future<bool> init() async {
    _craft = await Craft.brew<PersistableAutoRefreshingBearerOauthCraft>(
      refreshTokenMethod: _refreshTokens,
      tokenExpiration: _tokenExpiration,
      tokenStorageKey: 'craft_example_token_storage_key',
    );

    return _craft.promoted;
  }

  Future<void> login(LoginData loginData) async {
    final http.Response response = await _craft.instance.send(
      Request<LoginData>(
        HttpMethod.post,
        Uri.parse('https://example.com/login'),
        body: loginData,
      ),
    );

    final TokenPair tokenPair = _tokensFromLoginResponse(response);

    await _craft.promote(
      accessToken: tokenPair.access,
      refreshToken: tokenPair.refresh,
      refreshTokenMethod: _refreshTokens,
      tokenExpiration: _tokenExpiration,
      tokenStorageKey: 'craft_example_token_storage_key',
    );
  }

  // Can be made private because it is unnecessary to call it manually. If
  // needed, it can of course be public as well.
  //
  // We assume here that only new access token is issued and refresh token stays
  // the same.
  Future<TokenPair> _refreshTokens(String refreshToken) async {
    final http.Response response = await _craft.instance.send(
      Request<String>.fromString(
        HttpMethod.post,
        'https://example.com/login/refresh',
        body: refreshToken,
      ),
    );

    final String newAccessToken = response.body;
    return TokenPair(newAccessToken, refreshToken);
  }

  Duration _tokenExpiration(String accessToken) {
    return Duration(
      milliseconds: _parseExpirationMsFromJwtToken(accessToken) -
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Returns dummy tokens for example purposes. This would usually be a method
  // that parses tokens from response body.
  TokenPair _tokensFromLoginResponse(http.Response response) {
    return const TokenPair('access', 'refresh');
  }

  // Returns dummy expiration ms since epoch. This would usually be extracted
  // from 'iat' JWT value.
  int _parseExpirationMsFromJwtToken(String jwtToken) {
    return DateTime.now().millisecondsSinceEpoch + 60000;
  }
}

/// This is what you would normally do in your splash screen or other
/// initialization logic.
Future<void> main() async {
  final ApiService apiService = ApiService.instance;

  final bool userLoggedIn = await apiService.init();
  if (userLoggedIn) {
    // e.g. proceed to home screen
    return;
  }

  // proceed to login screen and do:
  await apiService.login(const LoginData('username', 'password'));

  // The craft should now be promoted.
}
