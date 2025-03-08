class AuthResponse {
  final bool success;
  final String? email;
  final String message;
  final int userId;
  final String? token;

  AuthResponse({
    required this.success,
    this.email,
    required this.message,
    required this.userId,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      email: json['email'] as String?,
      message: json['mensaje'] as String? ?? '',
      userId: json['idUsuario'] is String 
          ? int.tryParse(json['idUsuario'] as String) ?? 0 
          : (json['idUsuario'] as num?)?.toInt() ?? 0,
      token: json['token'] as String?,
    );
  }
}

