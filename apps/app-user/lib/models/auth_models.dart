/// Body for `POST /api/auth/register`.
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String phone;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      };
}

/// Result of `POST /api/auth` (the envelope `data`).
class AuthResult {
  final String token;
  final bool authenticated;

  AuthResult({required this.token, required this.authenticated});

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        token: json['token'] as String,
        authenticated: json['authenticated'] as bool? ?? false,
      );
}

/// Body for `POST /api/auth/google`.
class GoogleLoginRequest {
  final String idToken;

  const GoogleLoginRequest({required this.idToken});

  Map<String, dynamic> toJson() => {'idToken': idToken};
}
