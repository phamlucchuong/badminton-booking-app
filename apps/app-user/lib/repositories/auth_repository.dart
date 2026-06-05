import '../services/api_client.dart';
import '../services/token_store.dart';
import '../models/auth_models.dart';

/// Auth flows backed by `/api/auth`, `/api/auth/register`, `/api/otp/*`.
class AuthRepository {
  final ApiClient _api;
  final TokenStore _tokens;

  AuthRepository(this._api, this._tokens);

  Future<void> register(RegisterRequest request) async {
    await _api.post('/api/auth/register', body: request.toJson());
  }

  Future<void> sendOtp(String email) async {
    await _api.post('/api/otp/send', query: {'email': email});
  }

  Future<bool> verifyOtp(String email, String otp) async {
    final data = await _api.get('/api/otp/verify', query: {
      'email': email,
      'otp': otp,
    });
    return data as bool;
  }

  Future<AuthResult> login(String email, String password) async {
    final data = await _api
        .post('/api/auth', body: {'email': email, 'password': password});
    final result = AuthResult.fromJson(data as Map<String, dynamic>);
    await _tokens.save(result.token);
    return result;
  }

  Future<void> logout() async {
    await _api.post('/api/auth/logout');
    await _tokens.clear();
  }
}
