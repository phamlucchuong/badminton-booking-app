import '../models/auth_models.dart';
import '../services/api_client.dart';
import '../services/api_exception.dart';
import '../services/token_store.dart';

/// Auth flows backed by `/api/auth`, `/api/auth/register`, `/api/otp/*`.
class AuthRepository {
  final ApiClient _api;
  final TokenStore _tokens;

  AuthRepository(this._api, this._tokens);

  Future<void> register(RegisterRequest request) async {
    await _api.post('/api/auth/register',
        body: request.toJson(), authenticated: false);
  }

  Future<void> sendOtp(String email) async {
    await _api.post('/api/otp/send',
        query: {'email': email}, authenticated: false);
  }

  Future<bool> verifyOtp(String email, String otp) async {
    final data = await _api.get('/api/otp/verify',
        query: {
          'email': email,
          'otp': otp,
        },
        authenticated: false);
    return data as bool;
  }

  Future<AuthResult> login(String email, String password) async {
    final data = await _api.post('/api/auth',
        body: {'email': email, 'password': password}, authenticated: false);
    if (data is! Map<String, dynamic>) {
      throw ApiException(
        500,
        'Login response is missing token data. Check backend response shape.',
      );
    }
    final result = AuthResult.fromJson(data);
    await _tokens.save(result.token);
    return result;
  }

  Future<AuthResult> loginWithGoogle(String idToken) async {
    final data = await _api.post(
      '/api/auth/google',
      body: GoogleLoginRequest(idToken: idToken).toJson(),
      authenticated: false,
    );
    if (data is! Map<String, dynamic>) {
      throw ApiException(
        500,
        'Google login response is missing token data.',
      );
    }
    final result = AuthResult.fromJson(data);
    await _tokens.save(result.token);
    return result;
  }

  Future<void> logout() async {
    await _api.post('/api/auth/logout');
    await _tokens.clear();
  }
}
