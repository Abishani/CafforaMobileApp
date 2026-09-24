class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };
}

class UserResponse {
  const UserResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.loyaltyStatus,
  });

  final int id;
  final String name;
  final String email;
  final String role; // "ADMIN" or "CUSTOMER"
  final String? loyaltyStatus;

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'CUSTOMER',
      loyaltyStatus: json['loyaltyStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        if (loyaltyStatus != null) 'loyaltyStatus': loyaltyStatus,
      };
}

class AuthResponse {
  const AuthResponse({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  final String token;
  final String tokenType;
  final UserResponse user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      user: UserResponse.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
